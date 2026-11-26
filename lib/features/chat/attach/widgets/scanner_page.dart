import 'dart:io';

import 'package:camera/camera.dart' as camera;
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_pressable.dart';
import '../services/camera_preview_controller.dart';
import 'scan_tile.dart';

Route<XFile?> createScannerRoute({
  required BuildContext context,
  required CameraPreviewController controller,
}) {
  final colors = AppColors.of(context);
  return PageRouteBuilder<XFile?>(
    opaque: false,
    barrierDismissible: false,
    barrierColor: colors.cameraScannerBackground.withValues(
      alpha: AppOpacity.transparent,
    ),
    transitionDuration: AppMotion.attachSheetScannerDuration,
    reverseTransitionDuration: AppMotion.attachSheetScannerDuration,
    pageBuilder: (context, animation, secondaryAnimation) =>
        ScannerPage(controller: controller),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );
      return FadeTransition(opacity: curved, child: child);
    },
  );
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key, required this.controller});

  final CameraPreviewController controller;

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  XFile? _capturedPhoto;
  camera.FlashMode _flashMode = camera.FlashMode.off;
  bool _isCapturing = false;

  String get _flashName => switch (_flashMode) {
    camera.FlashMode.off => 'off',
    camera.FlashMode.auto => 'auto',
    _ => 'on',
  };

  Future<void> _toggleFlash() async {
    final nextMode = switch (_flashMode) {
      camera.FlashMode.off => camera.FlashMode.auto,
      camera.FlashMode.auto => camera.FlashMode.always,
      _ => camera.FlashMode.off,
    };
    try {
      await widget.controller.setFlashMode(nextMode);
      if (mounted) setState(() => _flashMode = nextMode);
    } on camera.CameraException {
      if (mounted) {
        _showMessage('Flash is unavailable for this camera.');
      }
    } on PlatformException {
      if (mounted) {
        _showMessage('Flash is unavailable for this camera.');
      }
    }
  }

  Future<void> _flipCamera() async {
    try {
      await widget.controller.flipCamera();
    } on camera.CameraException {
      if (mounted) _showMessage('Could not switch cameras.');
    } on PlatformException {
      if (mounted) _showMessage('Could not switch cameras.');
    }
  }

  Future<void> _capture() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);
    HapticFeedback.mediumImpact();
    try {
      final photo = await widget.controller.capture();
      if (!mounted) return;
      setState(() {
        _capturedPhoto = photo;
        _isCapturing = false;
      });
    } on camera.CameraException {
      if (mounted) {
        setState(() => _isCapturing = false);
        _showMessage('Could not capture photo. Try again.');
      }
    } on PlatformException {
      if (mounted) {
        setState(() => _isCapturing = false);
        _showMessage('Could not capture photo. Try again.');
      }
    } on StateError {
      if (mounted) {
        setState(() => _isCapturing = false);
        _showMessage('Camera is not ready yet.');
      }
    }
  }

  Future<void> _focusAt(TapUpDetails details, Size size) async {
    try {
      await widget.controller.focusAt(
        Offset(
          (details.localPosition.dx / size.width).clamp(0, 1).toDouble(),
          (details.localPosition.dy / size.height).clamp(0, 1).toDouble(),
        ),
      );
    } on camera.CameraException {
      if (mounted) _showMessage('Could not focus the camera.');
    } on PlatformException {
      if (mounted) _showMessage('Could not focus the camera.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.uiBody.copyWith(
              color: AppColors.of(context).card,
            ),
          ),
          backgroundColor: AppColors.of(context).green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.cards),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final cameraController = widget.controller.cameraController;
    final isReviewing = _capturedPhoto != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colors.cameraScannerBackground,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (isReviewing)
              Image.file(
                File(_capturedPhoto!.path),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  FlutterError.reportError(
                    FlutterErrorDetails(
                      exception: error,
                      stack: stackTrace,
                      library: 'captured scanner photo',
                    ),
                  );
                  return ColoredBox(
                    color: colors.cameraScannerBackground,
                    child: Center(
                      child: Text(
                        'Photo could not be displayed',
                        style: AppTextStyles.uiBody.copyWith(
                          color: colors.card,
                        ),
                      ),
                    ),
                  );
                },
              )
            else if (cameraController != null)
              LayoutBuilder(
                builder: (context, constraints) => Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: attachScannerHeroTag,
                      createRectTween: (begin, end) =>
                          RectTween(begin: begin, end: end),
                      child: CoverCameraPreview(controller: cameraController),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (details) => _focusAt(
                        details,
                        Size(constraints.maxWidth, constraints.maxHeight),
                      ),
                    ),
                  ],
                ),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.attachSheetPadding,
                    vertical: AppSpacing.space8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundScannerButton(
                        semanticLabel: 'Close scanner',
                        icon: AppIcons.x,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      if (!isReviewing)
                        _RoundScannerButton(
                          semanticLabel: 'Flash $_flashName. Tap to change.',
                          icon: switch (_flashMode) {
                            camera.FlashMode.off => AppIcons.flashlight,
                            camera.FlashMode.auto => AppIcons.lightning,
                            _ => AppIcons.flashlightFill,
                          },
                          onTap: _toggleFlash,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.attachSheetPadding,
              right: AppSpacing.attachSheetPadding,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacing.space16,
                    top: AppSpacing.space16,
                  ),
                  child: isReviewing
                      ? _ReviewActions(
                          onRetake: () => setState(() => _capturedPhoto = null),
                          onUsePhoto: () =>
                              Navigator.of(context).pop(_capturedPhoto),
                        )
                      : _LiveScannerActions(
                          hasMultipleCameras: widget.controller.cameraCount > 1,
                          isCapturing: _isCapturing,
                          onCapture: _capture,
                          onFlip: _flipCamera,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundScannerButton extends StatelessWidget {
  const _RoundScannerButton({
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
  });

  final String semanticLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AppPressable(
      semanticLabel: semanticLabel,
      onTap: onTap,
      minimumWidth: AppSizes.attachSheetScannerControlSize,
      minimumHeight: AppSizes.attachSheetScannerControlSize,
      child: Container(
        width: AppSizes.attachSheetScannerCloseSize,
        height: AppSizes.attachSheetScannerCloseSize,
        decoration: BoxDecoration(
          color: colors.overlayFill,
          shape: BoxShape.circle,
          border: Border.all(color: colors.overlayStroke),
        ),
        alignment: Alignment.center,
        child: AppIcon(icon, size: AppSizes.iconMenu, color: colors.card),
      ),
    );
  }
}

class _LiveScannerActions extends StatelessWidget {
  const _LiveScannerActions({
    required this.hasMultipleCameras,
    required this.isCapturing,
    required this.onCapture,
    required this.onFlip,
  });

  final bool hasMultipleCameras;
  final bool isCapturing;
  final VoidCallback onCapture;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: const SizedBox(
              width: AppSizes.attachSheetScannerControlSize,
              height: AppSizes.attachSheetScannerControlSize,
            ),
          ),
        ),
        AppPressable(
          semanticLabel: 'Take photo',
          onTap: isCapturing ? null : onCapture,
          enableHaptics: false,
          minimumWidth: AppSizes.attachSheetScannerShutterSize,
          minimumHeight: AppSizes.attachSheetScannerShutterSize,
          child: Container(
            width: AppSizes.attachSheetScannerShutterSize,
            height: AppSizes.attachSheetScannerShutterSize,
            padding: const EdgeInsets.all(
              AppSizes.attachSheetScannerShutterGap,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.of(context).card,
                width: AppSizes.attachSheetScannerShutterBorderWidth,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.of(context).card,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: AppSizes.attachSheetScannerShutterInnerSize,
                height: AppSizes.attachSheetScannerShutterInnerSize,
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: hasMultipleCameras
                ? _RoundScannerButton(
                    semanticLabel: 'Flip camera',
                    icon: AppIcons.cameraRotate,
                    onTap: onFlip,
                  )
                : const SizedBox(
                    width: AppSizes.attachSheetScannerControlSize,
                    height: AppSizes.attachSheetScannerControlSize,
                  ),
          ),
        ),
      ],
    );
  }
}

class _ReviewActions extends StatelessWidget {
  const _ReviewActions({required this.onRetake, required this.onUsePhoto});

  final VoidCallback onRetake;
  final VoidCallback onUsePhoto;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Expanded(
          child: AppPressable(
            semanticLabel: 'Retake photo',
            onTap: onRetake,
            minimumHeight: AppSizes.attachSheetScannerControlSize,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: AppSizes.attachSheetScannerControlSize,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: colors.card),
                borderRadius: AppRadii.attachSheetTile,
              ),
              alignment: Alignment.center,
              child: Text(
                'Retake',
                style: AppTextStyles.attachSheetScannerLabel.copyWith(
                  color: colors.card,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space12),
        Expanded(
          child: AppPressable(
            semanticLabel: 'Use captured photo',
            onTap: onUsePhoto,
            minimumHeight: AppSizes.attachSheetScannerControlSize,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: AppSizes.attachSheetScannerControlSize,
              ),
              decoration: BoxDecoration(
                color: colors.green,
                borderRadius: AppRadii.attachSheetTile,
              ),
              alignment: Alignment.center,
              child: Text(
                'Use photo',
                style: AppTextStyles.attachSheetScannerLabel.copyWith(
                  color: colors.card,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
