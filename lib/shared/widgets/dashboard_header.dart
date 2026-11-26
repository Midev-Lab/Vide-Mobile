import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_icon.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timer,
    this.onMenuTap,
    this.onAddTap,
    this.timerIcon,
  });

  final String title;
  final String subtitle;
  final String timer;
  final VoidCallback? onMenuTap;
  final VoidCallback? onAddTap;
  final Widget? timerIcon;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HeaderIcon(icon: AppIcons.menu, onTap: onMenuTap),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.dashboardTitle.copyWith(
                      color: colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    subtitle,
                    style: AppTextStyles.uiCaption.copyWith(color: colors.gray),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space8,
                      vertical: AppSpacing.space4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: AppRadii.pill,
                      border: Border.all(color: colors.line),
                    ),
                    child: Row(
                      children: [
                        timerIcon ??
                            AppIcon(
                              AppIcons.clock,
                              size: AppSizes.iconSmall,
                              color: colors.green,
                            ),
                        const SizedBox(width: AppSpacing.space4),
                        Text(
                          timer,
                          style: AppTextStyles.uiLabel.copyWith(
                            color: colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space8),
                  HeaderIcon(icon: AppIcons.plus, onTap: onAddTap),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderIcon extends StatelessWidget {
  const HeaderIcon({super.key, required this.icon, this.color, this.onTap});

  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: AppSizes.headerIconTapTarget,
        height: AppSizes.headerIconTapTarget,
        child: Center(
          child: AppIcon(
            icon,
            size: AppSizes.navIcon,
            color: color ?? AppColors.of(context).green,
          ),
        ),
      ),
    );
  }
}
