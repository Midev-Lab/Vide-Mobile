import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../features/quota/models/chat_quota.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_pressable.dart';

class AddChatCard extends StatelessWidget {
  const AddChatCard({
    super.key,
    required this.quota,
    required this.onAddChat,
    required this.onLimitReached,
  });

  final ChatQuota? quota;
  final VoidCallback onAddChat;
  final VoidCallback onLimitReached;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final remaining = quota?.remaining;
    final isLimited = remaining == 0;
    final badgeLabel = remaining == null
        ? null
        : isLimited
        ? 'Limit reached'
        : '$remaining left today';
    final foreground = isLimited ? colors.gray : colors.green;
    final background = isLimited ? colors.hover : colors.yellow;

    return AppPressable(
      semanticLabel: badgeLabel == null
          ? 'Add chat. Pick up a past chat.'
          : 'Add chat, $badgeLabel. Pick up a past chat.',
      onTap: isLimited ? onLimitReached : onAddChat,
      minimumHeight: AppSizes.buttonMinTapTarget,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < AppSizes.attachSheetCompactLayoutWidth;
          final icon = Container(
            width: AppSizes.attachSheetAddChatIconCircle,
            height: AppSizes.attachSheetAddChatIconCircle,
            decoration: BoxDecoration(
              color: colors.card,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: AppIcon(
              AppIcons.chat,
              size: AppSizes.iconMenu,
              color: foreground,
            ),
          );
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add chat',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.attachSheetAddChatTitle.copyWith(
                  color: foreground,
                ),
              ),
              Text(
                'Pick up a past chat',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.attachSheetChatSubtitle.copyWith(
                  color: foreground.withValues(
                    alpha: AppOpacity.attachSheetAddChatSubtitle,
                  ),
                ),
              ),
            ],
          );

          return Container(
            constraints: const BoxConstraints(
              minHeight: AppSizes.attachSheetAddChatHeight,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space12,
              vertical: AppSpacing.space8,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: AppRadii.attachSheetTile,
            ),
            child: compact && badgeLabel != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          icon,
                          const SizedBox(width: AppSpacing.space8),
                          Expanded(child: details),
                          const SizedBox(width: AppSpacing.space8),
                          _Caret(color: foreground),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _QuotaPill(
                          label: badgeLabel,
                          isLimited: isLimited,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      icon,
                      const SizedBox(width: AppSpacing.space8),
                      Expanded(child: details),
                      if (badgeLabel != null) ...[
                        const SizedBox(width: AppSpacing.space4),
                        _QuotaPill(label: badgeLabel, isLimited: isLimited),
                      ],
                      const SizedBox(width: AppSpacing.space4),
                      _Caret(color: foreground),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _QuotaPill extends StatelessWidget {
  const _QuotaPill({required this.label, required this.isLimited});

  final String label;
  final bool isLimited;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      constraints: const BoxConstraints(
        minHeight: AppSizes.attachSheetQuotaPillHeight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadii.pill,
      ),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.uiCaption.copyWith(
            color: isLimited ? colors.gray : colors.green,
          ),
        ),
      ),
    );
  }
}

class _Caret extends StatelessWidget {
  const _Caret({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: AppSizes.attachSheetScannerControlSize,
    height: AppSizes.attachSheetScannerControlSize,
    child: Center(
      child: AppIcon(
        AppIcons.caretRight,
        size: AppSizes.iconAction,
        color: color,
      ),
    ),
  );
}
