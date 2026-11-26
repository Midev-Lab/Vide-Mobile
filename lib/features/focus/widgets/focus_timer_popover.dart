import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/app_pressable.dart';
import '../state/focus_timer_controller.dart';

class FocusTimerPopover extends StatelessWidget {
  const FocusTimerPopover({
    super.key,
    required this.controller,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onEnd,
  });

  static const _presets = [15, 25, 45, 60];

  final FocusTimerController controller;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Material(
        type: MaterialType.transparency,
        child: DefaultTextStyle(
          style: AppTextStyles.uiBody.copyWith(color: colors.green),
          child: Container(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: AppRadii.focusPopover,
              border: Border.all(
                color: colors.green.withValues(
                  alpha: AppOpacity.focusPopoverBorder,
                ),
                width: AppSizes.focusPopoverBorderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.green.withValues(
                    alpha: AppOpacity.focusPopoverShadow,
                  ),
                  blurRadius: AppSizes.focusPopoverShadowBlur,
                  offset: Offset(0, AppSizes.focusPopoverShadowOffset),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.focusPopoverPadding),
              child:
                  controller.state == FocusTimerState.running ||
                      controller.state == FocusTimerState.paused
                  ? _runningContent(context)
                  : _idleContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _idleContent(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Focus session',
          style: AppTextStyles.focusPopoverTitle.copyWith(color: colors.green),
        ),
        const SizedBox(height: AppSpacing.space8),
        Text(
          'Pick a length and start. The timer stays in the top bar while you study.',
          style: AppTextStyles.focusPopoverDescription.copyWith(
            color: colors.gray,
          ),
        ),
        const SizedBox(height: AppSpacing.space20),
        Row(
          children: [
            for (var index = 0; index < _presets.length; index++) ...[
              if (index > 0)
                const SizedBox(width: AppSizes.focusPopoverPresetGap),
              Expanded(child: _presetChip(context, _presets[index])),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.space20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _stepperButton(
              context,
              icon: AppIcons.minus,
              label: 'Decrease session length by 5 minutes',
              onTap: () => unawaited(
                controller.selectMinutes(
                  controller.selectedMinutes - FocusTimerController.minuteStep,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.focusPopoverStepperGap),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${controller.selectedMinutes} min',
                  maxLines: 1,
                  style: AppTextStyles.focusPopoverStepperValue.copyWith(
                    color: colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.focusPopoverStepperGap),
            _stepperButton(
              context,
              icon: AppIcons.plus,
              label: 'Increase session length by 5 minutes',
              onTap: () => unawaited(
                controller.selectMinutes(
                  controller.selectedMinutes + FocusTimerController.minuteStep,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space20),
        AppPressable(
          semanticLabel: 'Start focus session',
          onTap: onStart,
          minimumHeight: AppSizes.buttonMinTapTarget,
          child: Container(
            height: AppSizes.focusPopoverStartButtonHeight,
            decoration: BoxDecoration(
              color: colors.yellow,
              borderRadius: AppRadii.focusAction,
            ),
            alignment: Alignment.center,
            child: Text(
              'Start focus',
              style: AppTextStyles.focusPopoverAction.copyWith(
                color: colors.onYellow,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _presetChip(BuildContext context, int minutes) {
    final colors = AppColors.of(context);
    final isSelected = controller.selectedMinutes == minutes;

    return AppPressable(
      semanticLabel: 'Select $minutes minutes',
      onTap: () => unawaited(controller.selectMinutes(minutes)),
      minimumHeight: AppSizes.buttonMinTapTarget,
      child: Container(
        height: AppSizes.focusPopoverPresetHeight,
        decoration: BoxDecoration(
          color: isSelected ? colors.green : null,
          borderRadius: AppRadii.focusPreset,
          border: isSelected
              ? null
              : Border.all(
                  color: colors.line,
                  width: AppSizes.focusPopoverBorderWidth,
                ),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$minutes min',
            maxLines: 1,
            style: AppTextStyles.focusPopoverPreset.copyWith(
              color: isSelected ? colors.card : colors.green,
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepperButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colors = AppColors.of(context);

    return AppPressable(
      semanticLabel: label,
      onTap: onTap,
      child: Container(
        width: AppSizes.focusPopoverStepperButtonSize,
        height: AppSizes.focusPopoverStepperButtonSize,
        decoration: BoxDecoration(
          borderRadius: AppRadii.focusStepper,
          border: Border.all(
            color: colors.green.withValues(
              alpha: AppOpacity.focusPopoverBorder,
            ),
            width: AppSizes.focusPopoverBorderWidth,
          ),
        ),
        alignment: Alignment.center,
        child: AppIcon(icon, size: AppSizes.iconAction, color: colors.green),
      ),
    );
  }

  Widget _runningContent(BuildContext context) {
    final colors = AppColors.of(context);
    final isPaused = controller.state == FocusTimerState.paused;
    final spokenRemaining = describeFocusDuration(
      controller.accessibleRemaining,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Focus session',
          style: AppTextStyles.focusPopoverTitle.copyWith(color: colors.green),
        ),
        const SizedBox(height: AppSpacing.space20),
        Semantics(
          liveRegion: true,
          label: 'Focus timer, $spokenRemaining remaining.',
          child: ExcludeSemantics(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formatFocusDuration(controller.remaining),
                maxLines: 1,
                style: AppTextStyles.focusPopoverTimerValue.copyWith(
                  color: colors.green,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        Center(
          child: Text(
            'of ${controller.selectedMinutes} min',
            style: AppTextStyles.focusPopoverMeta.copyWith(color: colors.gray),
          ),
        ),
        const SizedBox(height: AppSpacing.space20),
        Row(
          children: [
            Expanded(
              child: _sessionButton(
                context,
                label: isPaused ? 'Resume' : 'Pause',
                icon: isPaused ? AppIcons.play : AppIcons.pause,
                filled: false,
                onTap: isPaused ? onResume : onPause,
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: _sessionButton(
                context,
                label: 'End session',
                filled: true,
                onTap: onEnd,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sessionButton(
    BuildContext context, {
    required String label,
    IconData? icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    final colors = AppColors.of(context);
    final foreground = filled ? colors.card : colors.green;

    return AppPressable(
      semanticLabel: label,
      onTap: onTap,
      minimumHeight: AppSizes.buttonMinTapTarget,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AppSizes.focusPopoverStartButtonHeight,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
        decoration: BoxDecoration(
          color: filled ? colors.green : null,
          borderRadius: AppRadii.focusAction,
          border: filled ? null : Border.all(color: colors.line),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              AppIcon(icon, size: AppSizes.iconAction, color: foreground),
              const SizedBox(width: AppSpacing.space8),
            ],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: AppTextStyles.focusPopoverAction.copyWith(
                    color: foreground,
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
