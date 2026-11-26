import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/storage/storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/focus/state/focus_timer_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted theme preference.
  final themeProvider = ThemeProvider();
  await themeProvider.loadFromPrefs();
  final focusTimerController = FocusTimerController(storage: AppStorage());
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  runApp(
    ProviderScope(
      child: VideApp(
        themeProvider: themeProvider,
        focusTimerController: focusTimerController,
        scaffoldMessengerKey: scaffoldMessengerKey,
      ),
    ),
  );
}

class VideApp extends StatelessWidget {
  VideApp({
    super.key,
    required this.themeProvider,
    FocusTimerController? focusTimerController,
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey,
  }) : focusTimerController =
           focusTimerController ?? FocusTimerController(storage: AppStorage()),
       scaffoldMessengerKey =
           scaffoldMessengerKey ?? GlobalKey<ScaffoldMessengerState>();

  final ThemeProvider themeProvider;
  final FocusTimerController focusTimerController;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'VIDE',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          scaffoldMessengerKey: scaffoldMessengerKey,
          routerConfig: AppRouter.router,
          builder: (context, child) => FocusTimerHost(
            controller: focusTimerController,
            scaffoldMessengerKey: scaffoldMessengerKey,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
