import 'dart:async';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_pressable.dart';
import '../../../features/quota/state/chat_quota_providers.dart';
import 'models/attach_action.dart';
import 'services/attach_picker_service.dart';
import 'services/camera_preview_controller.dart';
import 'services/recent_photos_service.dart';
import 'state/attach_sheet_controller.dart';
import 'widgets/add_chat_card.dart';
import 'widgets/recent_photos_strip.dart';
import 'widgets/scan_tile.dart';
import 'widgets/scanner_page.dart';
import 'widgets/utility_tile.dart';

Future<int?> showAttachSheet({
  required BuildContext context,
  VoidCallback? onCameraPicked,
  VoidCallback? onPhotosPicked,
  VoidCallback? onFilesPicked,
  VoidCallback? onAddChat,
  VoidCallback? onLimitReached,
  ValueChanged<XFile>? onPhotoPicked,
  ValueChanged<XFile>? onRecentPhotoPicked,
  ValueChanged<XFile>? onFilePicked,
}) {
  HapticFeedback.lightImpact();

  final colors = AppColors.of(context);
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    showDragHandle: false,
    backgroundColor: colors.card,
    shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheetsTopSmall),
    clipBehavior: Clip.antiAlias,
    barrierColor: colors.scrim.withValues(alpha: AppOpacity.attachSheetScrim),
    sheetAnimationStyle: AnimationStyle(
      duration: AppMotion.sheetOpenDuration,
      reverseDuration: AppMotion.sheetCloseDuration,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ),
    builder: (_) => _AttachSheetContent(
      onCameraPicked: onCameraPicked,
      onPhotosPicked: onPhotosPicked,
      onFilesPicked: onFilesPicked,
      onAddChat: onAddChat,
      onLimitReached: onLimitReached,
      onPhotoPicked: onPhotoPicked,
      onRecentPhotoPicked: onRecentPhotoPicked,
      onFilePicked: onFilePicked,
    ),
  );
}

class _AttachSheetContent extends ConsumerStatefulWidget {
  const _AttachSheetContent({
    this.onCameraPicked,
    this.onPhotosPicked,
    this.onFilesPicked,
    this.onAddChat,
    this.onLimitReached,
    this.onPhotoPicked,
    this.onRecentPhotoPicked,
    this.onFilePicked,
  });

  final VoidCallback? onCameraPicked;
  final VoidCallback? onPhotosPicked;
  final VoidCallback? onFilesPicked;
  final VoidCallback? onAddChat;
  final VoidCallback? onLimitReached;
  final ValueChanged<XFile>? onPhotoPicked;
  final ValueChanged<XFile>? onRecentPhotoPicked;
  final ValueChanged<XFile>? onFilePicked;

  @override
  ConsumerState<_AttachSheetContent> createState() =>
      _AttachSheetContentState();
}

class _AttachSheetContentState extends ConsumerState<_AttachSheetContent>
    with WidgetsBindingObserver {
  late final AttachSheetController _controller;
  Animation<double>? _routeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AttachSheetController(
      cameraController: ref.read(cameraPreviewControllerFactoryProvider)(),
      recentPhotosService: ref.read(recentPhotosServiceProvider),
      pickerService: ref.read(attachPickerServiceProvider),
    )..addListener(_handleControllerChanged);
    _controller.initializePhotos();
  }

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animation = ModalRoute.of(context)?.animation;
    if (identical(animation, _routeAnimation)) return;
    _routeAnimation?.removeStatusListener(_handleRouteStatus);
    _routeAnimation = animation;
    _routeAnimation?.addStatusListener(_handleRouteStatus);
    if (animation?.status == AnimationStatus.completed) {
      _prepareCameraAfterOpen();
    }
  }

  void _handleRouteStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _prepareCameraAfterOpen();
  }

  void _prepareCameraAfterOpen() {
    _controller.prepareCameraAfterOpen();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller.handleLifecycle(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _routeAnimation?.removeStatusListener(_handleRouteStatus);
    _controller.removeListener(_handleControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _reportPhotoError(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'attach sheet photo library',
      ),
    );
  }

  Future<void> _onRecentPhotoTap(RecentPhoto photo) async {
    try {
      final file = await _controller.loadPhotoFile(photo);
      if (!mounted) return;
      if (file == null) {
        _showMessage('This photo is no longer available.');
        return;
      }
      Navigator.of(context).pop(1);
      widget.onRecentPhotoPicked?.call(file);
    } on PlatformException catch (error, stackTrace) {
      _reportPhotoError(error, stackTrace);
      if (mounted) _showMessage('Could not open this photo. Try another.');
    } on FileSystemException catch (error, stackTrace) {
      _reportPhotoError(error, stackTrace);
      if (mounted) _showMessage('Could not open this photo. Try another.');
    }
  }

  Future<void> _pickGalleryPhoto() async {
    XFile? photo;
    try {
      photo = await _controller.pickGalleryPhoto();
    } on PlatformException catch (error, stackTrace) {
      _reportPhotoError(error, stackTrace);
      if (mounted) _showMessage('Could not open the photo library.');
      return;
    }
    if (photo == null || !mounted) return;
    Navigator.of(context).pop(1);
    widget.onPhotosPicked?.call();
    widget.onPhotoPicked?.call(photo);
  }

  Future<void> _pickFile() async {
    XFile? file;
    try {
      file = await _controller.pickFile();
    } on PlatformException catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'attach sheet file picker',
        ),
      );
      if (mounted) _showMessage('Could not open the file picker.');
      return;
    }
    if (file == null || !mounted) return;
    Navigator.of(context).pop(2);
    widget.onFilesPicked?.call();
    widget.onFilePicked?.call(file);
  }

  Future<void> _scanNotes() async {
    var status = _controller.cameraController.status.value;
    if (status.state == CameraPreviewState.needsPermission) {
      if (status.permissionPermanentlyDenied) {
        await _showCameraSettingsDialog();
        return;
      }
      await _controller.cameraController.checkPermissionAndInitialize(
        requestPermission: true,
      );
      if (!mounted) return;
      status = _controller.cameraController.status.value;
      if (status.state == CameraPreviewState.needsPermission) {
        if (status.permissionPermanentlyDenied) {
          await _showCameraSettingsDialog();
        } else {
          _showMessage('Camera access was not granted.');
        }
        return;
      }
    }

    if (status.state == CameraPreviewState.ready) {
      await _openScanner();
      return;
    }
    if (status.state == CameraPreviewState.initializing) return;
    _showMessage(
      status.errorMessage ?? 'Camera is unavailable on this device.',
    );
  }

  Future<void> _showCameraSettingsDialog() async {
    final colors = AppColors.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cards),
        title: Text(
          'Camera access is off',
          style: AppTextStyles.attachSheetTitle.copyWith(color: colors.green),
        ),
        content: Text(
          'Allow camera access in settings to scan your notes.',
          style: AppTextStyles.uiBody.copyWith(color: colors.gray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              unawaited(_openCameraSettings());
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _openCameraSettings() async {
    try {
      await _controller.openCameraSettings();
    } on PlatformException catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'attach sheet camera settings',
        ),
      );
      if (mounted) _showMessage('Could not open settings.');
    }
  }

  Future<void> _openPhotoSettings() async {
    try {
      await _controller.openPhotoSettings();
    } on PlatformException catch (error, stackTrace) {
      _reportPhotoError(error, stackTrace);
      if (mounted) _showMessage('Could not open settings.');
    }
  }

  Future<void> _openScanner() async {
    final photo = await Navigator.of(context).push<XFile?>(
      createScannerRoute(
        context: context,
        controller: _controller.cameraController,
      ),
    );
    if (!mounted || photo == null) return;
    Navigator.of(context).pop(0);
    widget.onCameraPicked?.call();
    widget.onPhotoPicked?.call(photo);
  }

  void _showQuotaLimitMessage() {
    _showMessage("You've used your chats for today");
    widget.onLimitReached?.call();
    // TODO(phase-5): route to the real limit-state screen.
  }

  void _showMessage(String message) {
    final colors = AppColors.of(context);
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.uiBody.copyWith(color: colors.card),
          ),
          backgroundColor: colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.cards),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(chatQuotaProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              library: 'chat quota',
            ),
          );
          if (mounted) _showMessage('Could not load chat availability.');
        },
      );
    });
    final quota = ref.watch(chatQuotaProvider).valueOrNull;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bentoHeight = (screenHeight * AppSizes.attachSheetBentoHeightFactor)
        .clamp(
          AppSizes.attachSheetBentoMinHeight,
          AppSizes.attachSheetBentoMaxHeight,
        )
        .toDouble();
    final actions = <AttachAction>[
      AttachAction(
        id: 'scan-notes',
        label: 'Scan notes',
        subtitle: 'Use your camera',
        icon: AppIcons.camera,
        kind: AttachActionKind.hero,
        onTap: _scanNotes,
      ),
      AttachAction(
        id: 'photos',
        label: 'Photos',
        icon: AppIcons.image,
        kind: AttachActionKind.utility,
        onTap: _pickGalleryPhoto,
      ),
      AttachAction(
        id: 'files',
        label: 'Files',
        icon: AppIcons.fileArrowUp,
        kind: AttachActionKind.utility,
        onTap: _pickFile,
      ),
    ];

    final modalRoute = ModalRoute.of(context);
    final secondaryAnimation = modalRoute?.secondaryAnimation;
    final sheet = SafeArea(
      top: false,
      left: false,
      right: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * AppSizes.attachSheetMaxHeightFactor,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.space16,
                  bottom: AppSpacing.space16,
                ),
                child: Center(
                  child: Container(
                    width: AppSizes.attachSheetHandleWidth,
                    height: AppSizes.attachSheetHandleHeight,
                    decoration: BoxDecoration(
                      color: AppColors.of(
                        context,
                      ).gray.withValues(alpha: AppOpacity.muted),
                      borderRadius: AppRadii.pill,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.attachSheetPadding,
                ),
                child: _SheetHeader(onClose: () => Navigator.of(context).pop()),
              ),
              const SizedBox(height: AppSpacing.attachSheetHeaderToBento),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.attachSheetPadding,
                ),
                child: _BentoActions(
                  actions: actions,
                  cameraController: _controller.cameraController,
                  height: bentoHeight,
                ),
              ),
              const SizedBox(height: AppSpacing.attachSheetBentoToRecent),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.attachSheetPadding,
                ),
                child: Text(
                  'Recent',
                  style: AppTextStyles.attachSheetSectionLabel.copyWith(
                    color: AppColors.of(context).gray,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.attachSheetRecentLabelToStrip),
              RecentPhotosStrip(
                isLoading: _controller.isLoadingPhotos,
                photos: _controller.recentPhotos,
                access: _controller.photoAccess,
                errorMessage: _controller.photoError,
                onRequestAccess: () =>
                    unawaited(_controller.requestPhotoAccess()),
                onOpenSettings: () => unawaited(_openPhotoSettings()),
                onRetry: () => unawaited(_controller.retryRecentPhotos()),
                onPhotoTap: _onRecentPhotoTap,
              ),
              const SizedBox(height: AppSpacing.attachSheetStripToAddChat),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.attachSheetPadding,
                ),
                child: AddChatCard(
                  quota: quota,
                  onAddChat: () {
                    Navigator.of(context).pop(3);
                    widget.onAddChat?.call();
                  },
                  onLimitReached: _showQuotaLimitMessage,
                ),
              ),
              const SizedBox(height: AppSpacing.attachSheetBottomPadding),
            ],
          ),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: secondaryAnimation ?? const AlwaysStoppedAnimation(0),
      builder: (context, child) {
        final opacity = (1 - (secondaryAnimation?.value ?? 0))
            .clamp(0.0, 1.0)
            .toDouble();
        return Opacity(opacity: opacity, child: child);
      },
      child: sheet,
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bring something in',
                style: AppTextStyles.attachSheetTitle.copyWith(
                  color: colors.green,
                ),
              ),
              Text(
                'Notes, photos or a past chat',
                style: AppTextStyles.attachSheetHeaderSubtitle.copyWith(
                  color: colors.gray,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.space12),
        _SheetCloseButton(onTap: onClose),
      ],
    );
  }
}

class _SheetCloseButton extends StatelessWidget {
  const _SheetCloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AppPressable(
      semanticLabel: 'Close attach sheet',
      onTap: onTap,
      minimumWidth: AppSizes.buttonMinTapTarget,
      minimumHeight: AppSizes.buttonMinTapTarget,
      child: Container(
        width: AppSizes.attachSheetCloseButton,
        height: AppSizes.attachSheetCloseButton,
        decoration: BoxDecoration(color: colors.hover, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: AppIcon(
          AppIcons.x,
          size: AppSizes.iconMenu,
          color: colors.green,
        ),
      ),
    );
  }
}

class _BentoActions extends StatelessWidget {
  const _BentoActions({
    required this.actions,
    required this.cameraController,
    required this.height,
  });

  final List<AttachAction> actions;
  final CameraPreviewController cameraController;
  final double height;

  @override
  Widget build(BuildContext context) {
    final heroAction = actions.firstWhere(
      (action) => action.kind == AttachActionKind.hero,
    );
    final utilityActions = actions
        .where((action) => action.kind != AttachActionKind.hero)
        .toList(growable: false);
    final gapCount = utilityActions.isEmpty ? 0 : utilityActions.length - 1;
    final tileHeight = utilityActions.isNotEmpty && utilityActions.length <= 2
        ? (height - gapCount * AppSizes.attachSheetBentoGap) /
              utilityActions.length
        : AppSizes.attachSheetSideTileHeight;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: ValueListenableBuilder<CameraPreviewSnapshot>(
              valueListenable: cameraController.status,
              builder: (context, snapshot, _) => ScanTile(
                snapshot: snapshot,
                cameraController: cameraController,
                onTap: heroAction.onTap,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.attachSheetBentoGap),
          Expanded(
            flex: 4,
            child: utilityActions.isEmpty
                ? const SizedBox.shrink()
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    primary: false,
                    itemCount: utilityActions.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSizes.attachSheetBentoGap),
                    itemBuilder: (context, index) => SizedBox(
                      height: tileHeight,
                      child: UtilityTile(action: utilityActions[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
