import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';

class ChatCodeBlock extends StatelessWidget {
  const ChatCodeBlock({
    super.key,
    required this.code,
    this.language = 'PYTHON',
  });

  final String code;
  final String language;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadii.cards,
        border: Border.all(color: colors.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space12,
              AppSpacing.space10,
              AppSpacing.space8,
              AppSpacing.space8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    language.toUpperCase(),
                    style: AppTextStyles.uiLabel.copyWith(color: colors.gray),
                  ),
                ),
                InkWell(
                  onTap: () => Clipboard.setData(ClipboardData(text: code)),
                  borderRadius: AppRadii.option,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space8,
                      vertical: AppSpacing.space4,
                    ),
                    child: Text(
                      'Copy',
                      style: AppTextStyles.uiLabel.copyWith(
                        color: colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.space12,
              right: AppSpacing.space12,
              bottom: AppSpacing.space12,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                code,
                style: AppTextStyles.code.copyWith(color: colors.ink),
                softWrap: false,
                maxLines: null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
