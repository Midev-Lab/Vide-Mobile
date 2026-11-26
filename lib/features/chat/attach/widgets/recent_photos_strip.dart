import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_pressable.dart';
import '../services/recent_photos_service.dart';

class RecentPhotosStrip extends StatefulWidget {
  const RecentPhotosStrip({
    super.key,
    required this.isLoading,
    required this.photos,
    required this.access,
    required this.errorMessage,
    required this.onRequestAccess,
    required this.onOpenSettings,
    required this.onRetry,
    required this.onPhotoTap,
  });

  final bool isLoading;
  final List<RecentPhoto> photos;
  final PhotoLibraryAccess? access;
  final String? errorMessage;
  final VoidCallback onRequestAccess;
  final VoidCallback onOpenSettings;
  final VoidCallback onRetry;
  final ValueChanged<RecentPhoto> onPhotoTap;

  @override
  State<RecentPhotosStrip> createState() => _RecentPhotosStripState();
}

class _RecentPhotosStripState extends State<RecentPhotosStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: AppMotion.sheetShimmerDuration,
    );
    if (widget.isLoading) _shimmerController.repeat();
  }

  @override
  void didUpdateWidget(covariant RecentPhotosStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _shimmerController.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return SizedBox(
        height: AppSizes.attachSheetThumbnail,
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, _) => ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.attachSheetPadding,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: AppSizes.attachSheetRecentPhotosCount,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppSpacing.space8),
            itemBuilder: (context, index) =>
                _ShimmerThumbnail(progress: _shimmerController.value),
          ),
        ),
      );
    }

    final access = widget.access;
    if (widget.errorMessage != null) {
      return _PhotoAccessRow(
        label: widget.errorMessage!,
        actionLabel: 'Try again',
        onTap: widget.onRetry,
      );
    }
    if (access == null || !access.isGranted) {
      return _PhotoAccessRow(
        label: 'Allow photo access to see recent photos',
        actionLabel: access?.requiresSettings == true ? 'Open settings' : null,
        onTap: access?.requiresSettings == true
            ? widget.onOpenSettings
            : widget.onRequestAccess,
      );
    }
    if (widget.photos.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: AppSizes.attachSheetThumbnail,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.attachSheetPadding,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: widget.photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.space8),
        itemBuilder: (context, index) => _RecentPhotoThumbnail(
          photo: widget.photos[index],
          index: index,
          onTap: () => widget.onPhotoTap(widget.photos[index]),
        ),
      ),
    );
  }
}

class _PhotoAccessRow extends StatelessWidget {
  const _PhotoAccessRow({
    required this.label,
    required this.actionLabel,
    required this.onTap,
  });

  final String label;
  final String? actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AppPressable(
      semanticLabel: actionLabel == null ? label : '$label, $actionLabel',
      onTap: onTap,
      minimumHeight: AppSizes.buttonMinTapTarget,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AppSizes.buttonMinTapTarget,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space12,
          vertical: AppSpacing.space8,
        ),
        decoration: BoxDecoration(
          color: colors.hover,
          borderRadius: AppRadii.attachSheetTile,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.attachSheetCameraSubtitle.copyWith(
                  color: colors.gray,
                ),
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(width: AppSpacing.space8),
              Text(
                actionLabel!,
                style: AppTextStyles.uiBodyMedium.copyWith(color: colors.green),
              ),
            ],
            const SizedBox(width: AppSpacing.space4),
            AppIcon(
              AppIcons.caretRight,
              size: AppSizes.iconAction,
              color: colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentPhotoThumbnail extends StatefulWidget {
  const _RecentPhotoThumbnail({
    required this.photo,
    required this.index,
    required this.onTap,
  });

  final RecentPhoto photo;
  final int index;
  final VoidCallback onTap;

  @override
  State<_RecentPhotoThumbnail> createState() => _RecentPhotoThumbnailState();
}

class _RecentPhotoThumbnailState extends State<_RecentPhotoThumbnail> {
  late Future<Uint8List?> _thumbnail;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant _RecentPhotoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photo.id != widget.photo.id) _loadThumbnail();
  }

  void _loadThumbnail() {
    _thumbnail = _load();
  }

  Future<Uint8List?> _load() async {
    try {
      return await widget.photo.loadThumbnail();
    } on PlatformException catch (error, stackTrace) {
      _reportThumbnailError(error, stackTrace);
      rethrow;
    } on FileSystemException catch (error, stackTrace) {
      _reportThumbnailError(error, stackTrace);
      rethrow;
    }
  }

  void _reportThumbnailError(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'recent photo thumbnail',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AppPressable(
      semanticLabel: 'Recent photo ${widget.index + 1}, attach photo',
      onTap: widget.onTap,
      minimumWidth: AppSizes.attachSheetThumbnail,
      minimumHeight: AppSizes.attachSheetThumbnail,
      child: ClipRRect(
        borderRadius: AppRadii.attachSheetThumbnail,
        child: SizedBox(
          width: AppSizes.attachSheetThumbnail,
          height: AppSizes.attachSheetThumbnail,
          child: FutureBuilder<Uint8List?>(
            future: _thumbnail,
            builder: (context, snapshot) {
              if (snapshot.hasError || snapshot.data == null) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return ColoredBox(color: colors.hover);
                }
                return ColoredBox(
                  color: colors.hover,
                  child: Center(
                    child: AppIcon(
                      AppIcons.image,
                      size: AppSizes.iconAction,
                      color: colors.gray,
                    ),
                  ),
                );
              }
              return TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: AppOpacity.transparent,
                  end: AppOpacity.opaque,
                ),
                duration: AppMotion.attachSheetPreviewFadeDuration,
                curve: Curves.easeOutCubic,
                builder: (context, opacity, child) =>
                    Opacity(opacity: opacity, child: child),
                child: Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ShimmerThumbnail extends StatelessWidget {
  const _ShimmerThumbnail({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ClipRRect(
      borderRadius: AppRadii.attachSheetThumbnail,
      child: SizedBox(
        width: AppSizes.attachSheetThumbnail,
        height: AppSizes.attachSheetThumbnail,
        child: ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.lerp(
              Alignment.centerLeft,
              Alignment.center,
              progress,
            )!,
            end: Alignment.lerp(
              Alignment.center,
              Alignment.centerRight,
              progress,
            )!,
            colors: [
              colors.hover,
              colors.gray.withValues(alpha: AppOpacity.ripple),
              colors.hover,
            ],
          ).createShader(bounds),
          child: ColoredBox(color: colors.hover),
        ),
      ),
    );
  }
}
