import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import 'app_icon.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    this.mode = 'Tutor',
    this.placeholder = 'Ask anything, or add a screenshot',
    this.controller,
    this.onSend,
    this.onAttach,
    this.onVoice,
    this.onModeTap,
    this.attachIcon,
    this.voiceIcon,
    this.modeIcon,
    this.sendIcon,
    this.bottomPadding,
  });

  final String mode;
  final String placeholder;
  final TextEditingController? controller;
  final VoidCallback? onSend;
  final VoidCallback? onAttach;
  final VoidCallback? onVoice;
  final VoidCallback? onModeTap;
  final Widget? attachIcon;
  final Widget? voiceIcon;
  final Widget? modeIcon;
  final Widget? sendIcon;
  final double? bottomPadding;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  late final TextEditingController _ownedController;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _textFieldKey = GlobalKey();

  bool get _isExpanded => _focusNode.hasFocus || _controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _ownedController = TextEditingController();
    _controller = widget.controller ?? _ownedController;
    _controller.addListener(_handleControllerChanged);
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant ChatComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleControllerChanged);
      _controller = widget.controller ?? _ownedController;
      _controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _ownedController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() => setState(() {});

  void _handleFocusChanged() => setState(() {});

  Widget _buildTextField({required bool expanded, required AppColors colors}) {
    final textField = TextField(
      key: _textFieldKey,
      controller: _controller,
      focusNode: _focusNode,
      minLines: AppSizes.chatComposerMinLines,
      maxLines: expanded
          ? AppSizes.chatComposerMaxLines
          : AppSizes.chatComposerMinLines,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      textAlignVertical: expanded
          ? TextAlignVertical.top
          : TextAlignVertical.center,
      style: AppTextStyles.composerText.copyWith(color: colors.ink),
      cursorColor: colors.green,
      decoration: InputDecoration(
        isDense: true,
        isCollapsed: true,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        hintText: expanded ? widget.placeholder : null,
        hintMaxLines: AppSizes.chatComposerMaxLines,
        hintStyle: AppTextStyles.composerText.copyWith(color: colors.gray),
        contentPadding: EdgeInsets.zero,
      ),
    );

    if (expanded || _controller.text.isNotEmpty) return textField;

    return Stack(
      fit: StackFit.expand,
      children: [
        textField,
        IgnorePointer(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.placeholder,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.composerText.copyWith(color: colors.gray),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(AppColors colors) {
    final hasText = _controller.text.isNotEmpty;
    final canSend = _controller.text.trim().isNotEmpty;
    final icon = hasText ? AppIcons.arrowUp : AppIcons.waveform;
    final customIcon = hasText ? widget.sendIcon : widget.voiceIcon;
    final onTap = hasText ? (canSend ? widget.onSend : null) : widget.onVoice;

    return Opacity(
      opacity: hasText && !canSend ? AppOpacity.muted : AppOpacity.opaque,
      child: _ComposerIconButton(
        icon: icon,
        customIcon: customIcon,
        fillColor: colors.green,
        iconColor: colors.white,
        enabled: !hasText || canSend,
        onTap: onTap,
      ),
    );
  }

  Widget _buildModeChip(AppColors colors) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onModeTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space10,
          vertical: AppSpacing.space5,
        ),
        decoration: BoxDecoration(
          color: colors.hover,
          borderRadius: AppRadii.pill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.mode,
              style: AppTextStyles.uiLabel.copyWith(color: colors.green),
            ),
            const SizedBox(width: AppSpacing.space4),
            widget.modeIcon ??
                AppIcon(
                  AppIcons.caretDown,
                  size: AppSizes.iconSmall,
                  color: colors.green,
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final defaultBottomPadding = keyboardOpen
        ? AppSpacing.space8
        : MediaQuery.paddingOf(context).bottom + AppSpacing.space8;
    final bottomPadding = widget.bottomPadding ?? defaultBottomPadding;
    final expanded = _isExpanded;
    final showDisclaimer = !keyboardOpen && !_focusNode.hasFocus;

    return ColoredBox(
      color: colors.background,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.space12,
          0,
          AppSpacing.space12,
          bottomPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: AppMotion.chatComposerDuration,
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: AnimatedContainer(
                duration: AppMotion.chatComposerDuration,
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: colors.card,
                  border: Border.all(color: colors.line),
                  borderRadius: expanded
                      ? AppRadii.chatComposerExpanded
                      : AppRadii.pill,
                ),
                child: expanded
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.space16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTextField(expanded: true, colors: colors),
                            const SizedBox(height: AppSpacing.space12),
                            Row(
                              children: [
                                _ComposerIconButton(
                                  icon: AppIcons.plus,
                                  customIcon: widget.attachIcon,
                                  fillColor: colors.hover,
                                  iconColor: colors.green,
                                  onTap: widget.onAttach,
                                ),
                                const SizedBox(width: AppSpacing.space8),
                                _buildModeChip(colors),
                                const Spacer(),
                                _buildActionButton(colors),
                              ],
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: AppSizes.chatComposerHeight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space8,
                          ),
                          child: Row(
                            children: [
                              _ComposerIconButton(
                                icon: AppIcons.plus,
                                customIcon: widget.attachIcon,
                                fillColor: colors.hover,
                                iconColor: colors.green,
                                onTap: widget.onAttach,
                              ),
                              const SizedBox(width: AppSpacing.space8),
                              Expanded(
                                child: _buildTextField(
                                  expanded: false,
                                  colors: colors,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.space8),
                              _buildActionButton(colors),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            if (showDisclaimer) ...[
              const SizedBox(height: AppSpacing.space8),
              Text(
                'VIDE can make mistakes. Check important information.',
                style: AppTextStyles.disclaimer.copyWith(color: colors.gray),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ComposerIconButton extends StatefulWidget {
  const _ComposerIconButton({
    required this.icon,
    required this.fillColor,
    required this.iconColor,
    this.enabled = true,
    this.customIcon,
    this.onTap,
  });

  final IconData icon;
  final Color fillColor;
  final Color iconColor;
  final bool enabled;
  final Widget? customIcon;
  final VoidCallback? onTap;

  @override
  State<_ComposerIconButton> createState() => _ComposerIconButtonState();
}

class _ComposerIconButtonState extends State<_ComposerIconButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
    unawaited(HapticFeedback.lightImpact());
  }

  void _handleTapUp(TapUpDetails _) {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (_isPressed) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? _handleTapDown : null,
      onTapUp: widget.enabled ? _handleTapUp : null,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed
            ? AppMotion.chatComposerButtonPressedScale
            : AppMotion.buttonRestScale,
        duration: AppMotion.buttonPressDuration,
        curve: Curves.easeOut,
        child: Container(
          width: AppSizes.chatComposerButtonSize,
          height: AppSizes.chatComposerButtonSize,
          decoration: BoxDecoration(
            color: widget.fillColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: AppMotion.chatComposerIconDuration,
            child: SizedBox(
              key: ValueKey(widget.icon),
              width: AppSizes.chatComposerIconSize,
              height: AppSizes.chatComposerIconSize,
              child:
                  widget.customIcon ??
                  AppIcon(
                    widget.icon,
                    size: AppSizes.chatComposerIconSize,
                    color: widget.iconColor,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
