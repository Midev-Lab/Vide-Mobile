import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';

class AppPressable extends StatefulWidget {
  const AppPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.semanticLabel,
    this.minimumWidth = AppSizes.buttonMinTapTarget,
    this.minimumHeight = AppSizes.buttonMinTapTarget,
    this.enableHaptics = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double minimumWidth;
  final double minimumHeight;
  final bool enableHaptics;

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  bool _isPressed = false;

  void _release() {
    if (_isPressed) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;
    final content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => _release() : null,
      onTapCancel: _release,
      onTap: isEnabled
          ? () {
              if (widget.enableHaptics) HapticFeedback.lightImpact();
              widget.onTap?.call();
            }
          : null,
      child: AnimatedScale(
        scale: _isPressed
            ? AppMotion.buttonPressedScale
            : AppMotion.buttonRestScale,
        duration: AppMotion.buttonPressDuration,
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: isEnabled
              ? (_isPressed ? AppOpacity.secondary : AppOpacity.opaque)
              : AppOpacity.muted,
          duration: AppMotion.buttonPressDuration,
          curve: Curves.easeOut,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.minimumWidth,
              minHeight: widget.minimumHeight,
            ),
            child: widget.child,
          ),
        ),
      ),
    );

    final label = widget.semanticLabel;
    if (label == null) return content;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      child: content,
    );
  }
}
