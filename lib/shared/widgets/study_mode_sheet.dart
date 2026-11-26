import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'bottom_sheet_helper.dart';

class StudyModeOption {
  const StudyModeOption({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

const List<StudyModeOption> studyModes = [
  StudyModeOption(
    title: 'Casual',
    description: 'Normal academic banter & quick guidance',
  ),
  StudyModeOption(
    title: 'Tutor',
    description: 'Clear, step-by-step explanations with examples',
  ),
  StudyModeOption(
    title: 'Socratic',
    description: 'Guides you to answers via structured hints',
  ),
  StudyModeOption(
    title: 'Quiz master',
    description: 'Drills you with MCQs & theory checks',
  ),
  StudyModeOption(
    title: 'Exam coach',
    description: 'Strict university grading & mark scheme focus',
  ),
  StudyModeOption(
    title: 'Simplify',
    description: 'Plain-language breakdown with analogies',
  ),
];

Future<StudyModeOption?> showStudyModeSheet({
  required BuildContext context,
  required String selectedMode,
}) {
  final colors = AppColors.of(context);
  return showAppBottomSheet<StudyModeOption>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    barrierColor: colors.scrim,
    backgroundColor: colors.card,
    builder: (context) => StudyModeSheet(
      selectedMode: selectedMode,
      onSelected: (mode) => Navigator.of(context).pop(mode),
    ),
  );
}

class StudyModeSheet extends StatelessWidget {
  const StudyModeSheet({
    super.key,
    required this.selectedMode,
    required this.onSelected,
  });

  final String selectedMode;
  final ValueChanged<StudyModeOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.sizeOf(context).height *
            AppSizes.studyModeSheetMaxHeightFactor,
      ),
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Material(
          color: colors.card,
          borderRadius: AppRadii.sheetsTopLarge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.space8),
              Center(
                child: Container(
                  width: AppSizes.sheetHandleWidth,
                  height: AppSizes.sheetHandleHeight,
                  decoration: BoxDecoration(
                    color: colors.gray.withValues(alpha: AppOpacity.subtle),
                    borderRadius: AppRadii.pill,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space20),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space20,
                ),
                child: Text(
                  'Select Study Mode',
                  style: AppTextStyles.headingH2.copyWith(color: colors.green),
                ),
              ),
              const SizedBox(height: AppSpacing.space10),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var index = 0; index < studyModes.length; index++) ...[
                        if (index > 0) const SizedBox(height: AppSpacing.space4),
                        _StudyModeRow(
                          option: studyModes[index],
                          isSelected: studyModes[index].title == selectedMode,
                          onTap: () => onSelected(studyModes[index]),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.space8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudyModeRow extends StatelessWidget {
  const _StudyModeRow({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final StudyModeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.row,
      splashColor: colors.green.withValues(alpha: AppOpacity.ripple),
      highlightColor: colors.green.withValues(alpha: AppOpacity.ripple),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.hover : null,
          borderRadius: AppRadii.row,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: AppTextStyles.uiButton.copyWith(color: colors.green),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    option.description,
                    style: AppTextStyles.uiCaption.copyWith(color: colors.gray),
                  ),
                ],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.space10),
              Icon(
                AppIcons.checkActive,
                size: AppSizes.iconMenu,
                color: colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
