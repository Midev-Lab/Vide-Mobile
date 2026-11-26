import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../features/focus/widgets/focus_timer_header_control.dart';
import 'app_icon.dart';
import 'app_pressable.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onMenuTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: AppSizes.headerHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: Row(
            children: [
              SizedBox(
                width: AppSizes.focusTimerHeaderSlotWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: HeaderIcon(
                    icon: AppIcons.menu,
                    semanticLabel: 'Open menu',
                    onTap: onMenuTap,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.dashboardTitle.copyWith(
                        color: colors.green,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.uiCaption.copyWith(
                        color: colors.gray,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: AppSizes.focusTimerHeaderSlotWidth,
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: FocusTimerHeaderControl(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderIcon extends StatelessWidget {
  const HeaderIcon({
    super.key,
    required this.icon,
    this.color,
    this.onTap,
    this.semanticLabel,
  });

  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: AppSizes.buttonMinTapTarget,
      height: AppSizes.buttonMinTapTarget,
      child: Center(
        child: AppIcon(
          icon,
          size: AppSizes.navIcon,
          color: color ?? AppColors.of(context).green,
        ),
      ),
    );
    if (onTap == null) return content;

    return AppPressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: content,
    );
  }
}
