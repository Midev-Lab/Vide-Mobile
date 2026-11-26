import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

class AttachMenuItem {
  const AttachMenuItem({
    required this.icon,
    required this.title,
    required this.description,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? badge;
}

class AttachMenu extends StatelessWidget {
  const AttachMenu({
    super.key,
    required this.remainingChats,
    this.onSelected,
  });

  final int remainingChats;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final items = <AttachMenuItem>[
      const AttachMenuItem(
        icon: AppIcons.file,
        title: 'Upload a file',
        description: 'PDF, Word, slides, text',
      ),
      const AttachMenuItem(
        icon: AppIcons.image,
        title: 'Add photos',
        description: 'PNG, JPG, up to 10 MB',
      ),
      AttachMenuItem(
        icon: AppIcons.plus,
        title: 'Add chat',
        description: 'Pick up a past conversation',
        badge: '$remainingChats left today',
      ),
    ];

    return Container(
      width: AppSizes.attachMenuWidth,
      padding: const EdgeInsets.all(AppSpacing.space20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadii.composer,
        border: Border.all(color: colors.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0) const SizedBox(height: AppSpacing.space8),
            _AttachRow(
              item: items[index],
              onTap: onSelected == null ? null : () => onSelected!(index),
            ),
          ],
        ],
      ),
    );
  }
}

class _AttachRow extends StatelessWidget {
  const _AttachRow({
    required this.item,
    this.onTap,
  });

  final AttachMenuItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              item.icon,
              size: AppSizes.iconMenu,
              color: colors.green,
            ),
            const SizedBox(width: AppSpacing.space24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.uiLabel.copyWith(color: colors.green),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.uiCaption.copyWith(color: colors.gray),
                  ),
                ],
              ),
            ),
            if (item.badge != null) ...[
              const SizedBox(width: AppSpacing.space8),
              _QuotaBadge(label: item.badge!),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuotaBadge extends StatelessWidget {
  const _QuotaBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      height: AppSizes.quotaBadgeHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space8),
      decoration: BoxDecoration(
        color: colors.hover,
        borderRadius: AppRadii.pill,
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.uiCaption.copyWith(color: colors.green),
        ),
      ),
    );
  }
}
