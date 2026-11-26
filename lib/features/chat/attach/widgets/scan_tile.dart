import 'package:camera/camera.dart' as camera;
import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_pressable.dart';
import '../services/camera_preview_controller.dart';

const attachScannerHeroTag = 'vide-attach-scanner-preview';

class ScanTile extends StatelessWidget {
  const ScanTile({
    super.key,
    required this.snapshot,
    required this.cameraController,
    required this.onTap,
  });

  final CameraPreviewSnapshot snapshot;
  final CameraPreviewController cameraController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isReady =
        snapshot.state == CameraPreviewState.ready &&
        cameraController.cameraController != null;
    final subtitle = switch (snapshot.state) {
      CameraPreviewState.needsPermission => 'Tap to allow camera',
      CameraPreviewState.initializing => 'Preparing camera…',
      _ => 'Tap to scan',
    };
    final semanticsLabel = isReady
        ? 'Scan notes. Live camera preview. Tap to open scanner.'
        : 'Scan notes. $subtitle.';

    return AppPressable(
      onTap: onTap,
      semanticLabel: semanticsLabel,
      minimumWidth: AppSizes.buttonMinTapTarget,
      minimumHeight: AppSizes.buttonMinTapTarget,
      child: ClipRRect(
        borderRadius: AppRadii.attachSheetTile,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: colors.green),
            if (isReady)
              _LiveTilePreview(controller: cameraController.cameraController!),
            if (!isReady)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.space16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: AppIcon(
                    AppIcons.camera,
                    size: AppSizes.attachSheetCameraIcon,
                    color: colors.card,
                  ),
                ),
              ),
            if (isReady)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.green.withValues(alpha: AppOpacity.transparent),
                      colors.green.withValues(
                        alpha: AppOpacity.attachSheetScannerScrim,
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              left: AppSpacing.space16,
              right: AppSpacing.space8,
              bottom: AppSpacing.space16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Scan notes',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.attachSheetCameraTitle.copyWith(
                      color: colors.card,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.attachSheetCameraSubtitle.copyWith(
                      color: colors.card.withValues(
                        alpha: AppOpacity.attachSheetScannerSubtitle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveTilePreview extends StatelessWidget {
  const _LiveTilePreview({required this.controller});

  final camera.CameraController controller;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: attachScannerHeroTag,
      createRectTween: (begin, end) => RectTween(begin: begin, end: end),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: AppOpacity.transparent, end: AppOpacity.opaque),
        duration: AppMotion.attachSheetPreviewFadeDuration,
        curve: Curves.easeOutCubic,
        builder: (context, opacity, child) =>
            Opacity(opacity: opacity, child: child),
        child: _CoverCameraPreview(controller: controller),
      ),
    );
  }
}

class CoverCameraPreview extends StatelessWidget {
  const CoverCameraPreview({super.key, required this.controller});

  final camera.CameraController controller;

  @override
  Widget build(BuildContext context) =>
      _CoverCameraPreview(controller: controller);
}

class _CoverCameraPreview extends StatelessWidget {
  const _CoverCameraPreview({required this.controller});

  final camera.CameraController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final screenAspect = width / height;
        final previewAspect = height >= width
            ? 1 / controller.value.aspectRatio
            : controller.value.aspectRatio;
        final previewWidth = previewAspect > screenAspect
            ? height * previewAspect
            : width;
        final previewHeight = previewWidth / previewAspect;

        return ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: previewWidth,
              height: previewHeight,
              child: camera.CameraPreview(controller),
            ),
          ),
        );
      },
    );
  }
}
