import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_pressable.dart';
import '../models/attach_action.dart';

class UtilityTile extends StatelessWidget {
  const UtilityTile({super.key, required this.action});

  final AttachAction action;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AppPressable(
      onTap: action.onTap,
      semanticLabel: '${action.label}, attach ${action.label.toLowerCase()}',
      minimumWidth: AppSizes.buttonMinTapTarget,
      minimumHeight: AppSizes.buttonMinTapTarget,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space8,
          vertical: AppSpacing.space8,
        ),
        decoration: BoxDecoration(
          color: colors.hover,
          borderRadius: AppRadii.attachSheetTile,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              action.icon,
              size: AppSizes.attachSheetTileIcon,
              color: colors.green,
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              action.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.attachSheetActionLabel.copyWith(
                color: colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
