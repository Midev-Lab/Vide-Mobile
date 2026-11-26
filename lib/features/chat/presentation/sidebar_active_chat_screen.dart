import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/dashboard/dashboard.dart';
import '../../../shared/widgets/widgets.dart';
import '../attach/attach_sheet.dart';

class SidebarActiveChatScreen extends StatefulWidget {
  const SidebarActiveChatScreen({super.key});

  @override
  State<SidebarActiveChatScreen> createState() =>
      _SidebarActiveChatScreenState();
}

class _SidebarActiveChatScreenState extends State<SidebarActiveChatScreen> {
  static const _plusAsset = 'assets/images/icons/plus_18.png';
  static const _waveAsset = 'assets/images/icons/wave_18.png';
  static const _chevronAsset = 'assets/images/icons/chevron_down_12.png';
  static const _arrowUpAsset = 'assets/images/icons/arrow_up_15.png';

  String _selectedMode = 'Tutor';

  Future<void> _openAttachSheet() async {
    FocusScope.of(context).unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    await showAttachSheet(
      context: context,
      onCameraPicked: () {},
      onPhotosPicked: () {},
      onFilesPicked: () {},
      onAddChat: () {},
      onLimitReached: () {},
      onRecentPhotoPicked: (_) {},
      onPhotoPicked: (_) {},
      onFilePicked: (_) {},
    );
  }

  Future<void> _openStudyModeSheet() async {
    final mode = await showStudyModeSheet(
      context: context,
      selectedMode: _selectedMode,
    );
    if (mode == null || !mounted) return;
    setState(() => _selectedMode = mode.title);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Column(
            children: [
              DashboardHeader(
                title: 'New study session',
                subtitle: '$_selectedMode Mode • Today',
                onMenuTap: () => AppShell.openDrawer(context),
              ),
              const SizedBox(height: AppSpacing.emptyStateTopGap),
              const Align(
                alignment: Alignment.topCenter,
                child: ChatEmptyState(),
              ),
              const Spacer(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSpacing.space14,
            child: ChatComposer(
              mode: _selectedMode,
              onModeTap: _openStudyModeSheet,
              onAttach: _openAttachSheet,
              bottomPadding: AppSpacing.space5,
              attachIcon: Image.asset(
                _plusAsset,
                width: AppSizes.iconAction,
                height: AppSizes.iconAction,
                fit: BoxFit.contain,
              ),
              voiceIcon: Image.asset(
                _waveAsset,
                width: AppSizes.iconAction,
                height: AppSizes.iconAction,
                fit: BoxFit.contain,
              ),
              modeIcon: Image.asset(
                _chevronAsset,
                width: AppSizes.iconSmall,
                height: AppSizes.iconSmall,
                fit: BoxFit.contain,
              ),
              sendIcon: Image.asset(
                _arrowUpAsset,
                width: AppSizes.iconSend,
                height: AppSizes.iconSend,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
