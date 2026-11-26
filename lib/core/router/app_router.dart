import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/debug_screen_gallery.dart';
import '../../features/attachments/screens/attach_menu/screen.dart';
import '../../features/blank/presentation/blank_screen.dart';
import '../../features/chat/screens/all_chats/screen.dart';
import '../../features/chat/screens/chat_home/screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/chat/presentation/sidebar_active_chat_screen.dart';
import '../../features/flashcards/screens/flashcards/screen.dart';
import '../../features/focus/screens/focus_session_popover/screen.dart';
import '../../features/focus/screens/focus_timer/screen.dart';
import '../../features/navigation/screens/app_drawer/screen.dart';
import '../../features/profile/screens/study_profile/screen.dart';
import '../../features/profile/screens/study_profile_edit/screen.dart';
import '../../features/study_mode/screens/study_mode_sheet/screen.dart';
import '../../shared/dashboard/app_shell.dart';

/// Application router configuration.
class AppRouter {
  AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/chat',
    routes: [
      GoRoute(
        path: '/',
        name: 'blank',
        builder: (context, state) => const BlankScreen(),
      ),
      GoRoute(
        path: '/app-drawer',
        name: 'app-drawer',
        builder: (context, state) => const AppDrawerScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(currentPath: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/sidebar-active-chat',
            name: 'sidebar-active-chat',
            builder: (context, state) => const SidebarActiveChatScreen(),
          ),
          GoRoute(
            path: '/chat-home',
            name: 'chat-home',
            builder: (context, state) => const ChatHomeScreen(),
          ),
          GoRoute(
            path: '/flashcards',
            name: 'flashcards',
            builder: (context, state) => const FlashcardsScreen(),
          ),
          GoRoute(
            path: '/focus-timer',
            name: 'focus-timer',
            builder: (context, state) => const FocusTimerScreen(),
          ),
          GoRoute(
            path: '/study-profile',
            name: 'study-profile',
            builder: (context, state) => const StudyProfileScreen(),
          ),
          GoRoute(
            path: '/study-profile-edit',
            name: 'study-profile-edit',
            builder: (context, state) => const StudyProfileEditScreen(),
          ),
          GoRoute(
            path: '/all-chats',
            name: 'all-chats',
            builder: (context, state) => const AllChatsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/study-mode-sheet',
        name: 'study-mode-sheet',
        builder: (context, state) => const StudyModeSheetScreen(),
      ),
      GoRoute(
        path: '/attach-menu',
        name: 'attach-menu',
        builder: (context, state) => const AttachMenuScreen(),
      ),
      GoRoute(
        path: '/focus-session-popover',
        name: 'focus-session-popover',
        builder: (context, state) => const FocusSessionPopoverScreen(),
      ),
      if (kDebugMode)
        GoRoute(
          path: '/__debug/screens',
          name: 'debug-screen-gallery',
          builder: (context, state) => DebugScreenGalleryScreen(
            routes: const [
              (title: 'Blank', routeName: 'blank'),
              (title: 'Chat', routeName: 'chat'),
              (title: 'Sidebar active chat', routeName: 'sidebar-active-chat'),
              (title: 'App drawer', routeName: 'app-drawer'),
              (title: 'Chat home', routeName: 'chat-home'),
              (title: 'Study mode sheet', routeName: 'study-mode-sheet'),
              (title: 'Attach menu', routeName: 'attach-menu'),
              (
                title: 'Focus session popover',
                routeName: 'focus-session-popover',
              ),
              (title: 'Flashcards', routeName: 'flashcards'),
              (title: 'Focus timer', routeName: 'focus-timer'),
              (title: 'Study profile', routeName: 'study-profile'),
              (title: 'Study profile edit', routeName: 'study-profile-edit'),
              (title: 'All chats', routeName: 'all-chats'),
            ],
          ),
        ),
    ],
  );
}
