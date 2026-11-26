import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/dashboard/dashboard.dart';
import '../../../shared/widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isAttachMenuOpen = false;
  String _selectedMode = 'Tutor';

  void _openDrawer() {
    if (_isAttachMenuOpen) {
      setState(() => _isAttachMenuOpen = false);
    }
    AppShell.openDrawer(context);
  }

  void _toggleAttachMenu() {
    final opening = !_isAttachMenuOpen;
    setState(() => _isAttachMenuOpen = opening);
  }

  void _closeAttachMenu() {
    setState(() => _isAttachMenuOpen = false);
  }

  Future<void> _openStudyModeSheet() async {
    _closeAttachMenu();
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: true,
        left: true,
        right: true,
        bottom: false,
        child: Column(
          children: [
            DashboardHeader(
              title: 'New study session',
              subtitle: 'Osogbo (UNIOSUN): 29°C',
              timer: '25:00',
              onMenuTap: _openDrawer,
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: FocusScope.of(context).unfocus,
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0) {
                    FocusScope.of(context).unfocus();
                  }
                },
                child: const Center(child: ChatEmptyState()),
              ),
            ),
            if (_isAttachMenuOpen)
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.space16,
                  bottom: AppSpacing.space20,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AttachMenu(
                    remainingChats: 1,
                    onSelected: (_) => _closeAttachMenu(),
                  ),
                ),
              ),
            ChatComposer(
              mode: _selectedMode,
              onAttach: _toggleAttachMenu,
              onModeTap: _openStudyModeSheet,
            ),
          ],
        ),
      ),
    );
  }
}
