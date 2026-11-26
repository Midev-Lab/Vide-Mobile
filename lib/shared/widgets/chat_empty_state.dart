import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key, this.title = "Let's use this window"});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final showLogo =
            availableHeight >= AppSizes.chatGreetingLogoHideThreshold;
        final logoScale =
            availableHeight < AppSizes.chatGreetingLogoScaleThreshold
            ? AppSizes.chatGreetingLogoCompactScale
            : AppSizes.chatGreetingLogoFullScale;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showLogo) ...[
              Image.asset(
                'assets/images/vide_wordmark_green.png',
                width: AppSizes.wordmarkWidth * logoScale,
                height: AppSizes.wordmarkHeight * logoScale,
              ),
              const SizedBox(height: AppSpacing.space12),
            ],
            Text(
              title,
              style: AppTextStyles.headingH2.copyWith(color: colors.green),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
