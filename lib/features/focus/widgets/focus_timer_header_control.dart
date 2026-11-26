import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_pressable.dart';
import '../state/focus_timer_controller.dart';
import 'focus_timer_popover.dart';

class FocusTimerHeaderControl extends StatefulWidget {
  const FocusTimerHeaderControl({super.key});

  @override
  State<FocusTimerHeaderControl> createState() =>
      _FocusTimerHeaderControlState();
}

class _FocusTimerHeaderControlState extends State<FocusTimerHeaderControl>
    with SingleTickerProviderStateMixin {
  final _anchorKey = GlobalKey();
  late final AnimationController _popoverController;
  late final CurvedAnimation _popoverFade;
  late final Animation<double> _popoverScale;
  FocusTimerController? _focusTimerController;
  OverlayEntry? _popoverEntry;

  @override
  void initState() {
    super.initState();
    _popoverController = AnimationController(
      vsync: this,
      duration: AppMotion.focusPopoverOpenDuration,
    );
    _popoverFade = CurvedAnimation(
      parent: _popoverController,
      curve: Curves.easeOutCubic,
    );
    _popoverScale = Tween<double>(
      begin: AppMotion.focusPopoverStartScale,
      end: AppMotion.buttonRestScale,
    ).animate(_popoverFade);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = FocusTimerScope.of(context);
    if (identical(controller, _focusTimerController)) return;
    _focusTimerController?.removeListener(_handleTimerChanged);
    _focusTimerController = controller;
    controller.addListener(_handleTimerChanged);
  }

  void _handleTimerChanged() {
    if (_focusTimerController?.state == FocusTimerState.finished) {
      _dismissPopover();
    }
  }

  void _togglePopover() {
    if (_popoverEntry == null) {
      _showPopover();
    } else {
      _dismissPopover();
    }
  }

  void _showPopover() {
    final renderObject = _anchorKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      throw StateError('Focus timer anchor is not available.');
    }

    final controller = _focusTimerController!;
    final isIdle =
        controller.state == FocusTimerState.idle ||
        controller.state == FocusTimerState.finished;
    final visualHeight = isIdle
        ? AppSizes.focusTimerButtonSize
        : AppSizes.focusTimerPillHeight;
    final anchorTop = renderObject.localToGlobal(Offset.zero).dy;
    final anchorBottom =
        anchorTop +
        (renderObject.size.height - visualHeight) / 2 +
        visualHeight;
    final screenSize = MediaQuery.sizeOf(context);
    final horizontalMargin = AppSizes.focusPopoverHorizontalMargin;
    final width = math
        .min(
          screenSize.width - horizontalMargin * 2,
          AppSizes.focusPopoverMaxWidth,
        )
        .toDouble();
    final top = anchorBottom + AppSizes.focusPopoverAnchorGap;
    final maxHeight = math
        .max(0, screenSize.height - top - AppSizes.focusPopoverBottomMargin)
        .toDouble();
    final entry = OverlayEntry(
      builder: (_) {
        return Positioned.fill(
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _dismissPopover,
                child: const SizedBox.expand(),
              ),
              Positioned(
                top: top,
                right: horizontalMargin,
                child: FadeTransition(
                  opacity: _popoverFade,
                  child: ScaleTransition(
                    scale: _popoverScale,
                    alignment: Alignment.topRight,
                    child: SizedBox(
                      width: width,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxHeight),
                        child: FocusTimerPopover(
                          controller: controller,
                          onStart: () {
                            unawaited(controller.start());
                            _dismissPopover();
                          },
                          onPause: () => unawaited(controller.pause()),
                          onResume: () => unawaited(controller.resume()),
                          onEnd: () => unawaited(controller.endSession()),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    _popoverEntry = entry;
    Overlay.of(context, rootOverlay: true).insert(entry);
    _popoverController.forward(from: 0);
  }

  void _dismissPopover() {
    final entry = _popoverEntry;
    if (entry == null) return;
    _popoverEntry = null;
    _popoverController.stop();
    entry.remove();
    entry.dispose();
  }

  Widget _timerContents(BuildContext context, FocusTimerController controller) {
    final colors = AppColors.of(context);
    final isIdle =
        controller.state == FocusTimerState.idle ||
        controller.state == FocusTimerState.finished;

    if (isIdle) {
      return SizedBox(
        key: const ValueKey(FocusTimerState.idle),
        width: AppSizes.buttonMinTapTarget,
        height: AppSizes.buttonMinTapTarget,
        child: Center(
          child: Container(
            width: AppSizes.focusTimerButtonSize,
            height: AppSizes.focusTimerButtonSize,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            alignment: Alignment.center,
            child: AppIcon(
              AppIcons.timer,
              size: AppSizes.navIcon,
              color: colors.green,
            ),
          ),
        ),
      );
    }

    final isPaused = controller.state == FocusTimerState.paused;
    final fill = isPaused
        ? colors.yellow.withValues(alpha: AppOpacity.focusTimerPausedFill)
        : colors.yellow;

    return SizedBox(
      key: ValueKey(controller.state),
      height: AppSizes.buttonMinTapTarget,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSizes.focusTimerPillMaxWidth,
          ),
          child: Container(
            height: AppSizes.focusTimerPillHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.focusTimerPillHorizontalPadding,
            ),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: AppRadii.focusTimerPill,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(
                    isPaused ? AppIcons.pause : AppIcons.timer,
                    size: AppSizes.focusTimerPillIconSize,
                    color: colors.onYellow,
                  ),
                  const SizedBox(width: AppSpacing.focusTimerPillIconGap),
                  Text(
                    formatFocusDuration(controller.remaining),
                    maxLines: 1,
                    style: AppTextStyles.focusTimerPill.copyWith(
                      color: colors.onYellow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _focusTimerController!;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Semantics(
        button: true,
        liveRegion: true,
        label: controller.semanticLabel,
        child: ExcludeSemantics(
          child: AppPressable(
            key: _anchorKey,
            onTap: _togglePopover,
            minimumWidth: AppSizes.buttonMinTapTarget,
            minimumHeight: AppSizes.buttonMinTapTarget,
            child: AnimatedSwitcher(
              duration: AppMotion.focusTimerSwitcherDuration,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: _timerContents(context, controller),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusTimerController?.removeListener(_handleTimerChanged);
    final entry = _popoverEntry;
    if (entry != null) {
      entry.remove();
      entry.dispose();
    }
    _popoverFade.dispose();
    _popoverController.dispose();
    super.dispose();
  }
}
