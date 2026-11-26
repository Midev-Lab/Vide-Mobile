import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';

/// Pill-shaped button used throughout VIDE.
///
/// Supports [filled] (default) and outlined variants, plus loading, disabled
/// and press-feedback states. Full width by default so long labels stay stable
/// on narrow screens.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.filled = true,
    this.expand = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool filled;
  final bool expand;
  final IconData? icon;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  static const Duration _pressDuration = Duration(milliseconds: 120);
  static const Curve _pressCurve = Curves.easeOut;
  static const double _pressedScale = 0.97;

  bool _isPressed = false;

  bool get _isEnabled => !widget.isLoading && widget.onPressed != null;

  void _handleTapDown(TapDownDetails details) {
    if (_isEnabled) setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) => _release();

  void _handleTapCancel() => _release();

  void _release() {
    if (_isPressed) setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final foreground = widget.filled
        ? Theme.of(context).colorScheme.onPrimary
        : colors.green;
    final disabled = widget.onPressed == null && !widget.isLoading;

    final labelRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: AppSizes.iconAction, color: foreground),
          const SizedBox(width: AppSpacing.space8),
        ],
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.button.copyWith(color: foreground),
          ),
        ),
      ],
    );

    final content = Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: widget.isLoading ? 0 : 1, child: labelRow),
        if (widget.isLoading)
          SizedBox(
            width: AppSizes.buttonSpinnerSize,
            height: AppSizes.buttonSpinnerSize,
            child: CircularProgressIndicator(
              strokeWidth: AppSizes.buttonSpinnerStroke,
              color: foreground,
            ),
          ),
      ],
    );

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.label,
      child: AnimatedScale(
        scale: _isPressed ? _pressedScale : 1,
        duration: _pressDuration,
        curve: _pressCurve,
        child: AnimatedOpacity(
          opacity: disabled
              ? AppOpacity.muted
              : (_isPressed ? AppOpacity.secondary : 1),
          duration: _pressDuration,
          curve: _pressCurve,
          child: GestureDetector(
            onTapDown: _isEnabled ? _handleTapDown : null,
            onTapUp: _isEnabled ? _handleTapUp : null,
            onTapCancel: _isEnabled ? _handleTapCancel : null,
            onTap: _isEnabled ? _handleTap : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: AppSizes.buttonMinTapTarget,
                minHeight: AppSizes.buttonMinTapTarget,
              ),
              child: SizedBox(
                height: AppSizes.buttonHeight,
                width: widget.expand ? double.infinity : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space16,
                  ),
                  decoration: BoxDecoration(
                    color: widget.filled ? colors.green : Colors.transparent,
                    borderRadius: AppRadii.pill,
                    border: widget.filled
                        ? null
                        : Border.all(color: colors.line),
                  ),
                  child: Center(child: content),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
