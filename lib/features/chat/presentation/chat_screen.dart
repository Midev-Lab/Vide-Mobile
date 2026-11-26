import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/dashboard/dashboard.dart';
import '../../../shared/widgets/widgets.dart';
import '../attach/attach_sheet.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String _selectedMode = 'Tutor';

  void _openDrawer() {
    AppShell.openDrawer(context);
  }

  Future<void> _openAttachSheet() async {
    // Dismiss keyboard before opening the sheet.
    FocusScope.of(context).unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    await showAttachSheet(
      context: context,
      onCameraPicked: () {
        // TODO: Existing camera → photo attach handler.
      },
      onPhotosPicked: () {
        // TODO: Existing "Add photos" handler.
      },
      onFilesPicked: () {
        // TODO: Existing "Upload a file" handler.
      },
      onAddChat: () {
        // TODO: Existing "Add chat" handler.
      },
      onLimitReached: () {
        // TODO: Existing limit-state UI handler.
      },
      onRecentPhotoPicked: (xFile) {
        // TODO: Attach the picked photo through existing photo flow.
      },
      onPhotoPicked: (xFile) {
        // TODO: Attach the selected photo through existing photo flow.
      },
      onFilePicked: (file) {
        // TODO: Upload the selected file through the existing upload flow.
      },
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
            ChatComposer(
              mode: _selectedMode,
              onAttach: _openAttachSheet,
              onModeTap: _openStudyModeSheet,
            ),
          ],
        ),
      ),
    );
  }
}
