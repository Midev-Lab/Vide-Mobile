import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vide/core/theme/app_theme.dart';
import 'package:vide/shared/dashboard/app_shell.dart';

void main() {
  testWidgets('drawer layout stays valid while opening, open, and closing', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/other',
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              AppShell(currentPath: state.uri.path, child: child),
          routes: [
            GoRoute(
              path: '/chat',
              name: 'chat',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Chat destination'))),
            ),
            GoRoute(
              path: '/other',
              name: 'other',
              builder: (context, state) => const _DrawerTestScreen(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final shellSize = tester.getSize(find.byType(AppShell));
    await tester.tap(find.text('Open drawer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 140));
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(find.text('Recents'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('M'));
    await tester.pumpAndSettle();
    expect(find.text('Sign out'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tapAt(Offset(shellSize.width * 0.9, shellSize.height * 0.5));
    await tester.pump(const Duration(milliseconds: 140));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();

    await tester.dragFrom(
      Offset(shellSize.width * 0.1, shellSize.height * 0.5),
      Offset(shellSize.width * 0.7, 0),
    );
    await tester.pump(const Duration(milliseconds: 140));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('New study'));
    await tester.pumpAndSettle();
    expect(find.text('Chat destination'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/chat');
    expect(tester.takeException(), isNull);
  });
}

class _DrawerTestScreen extends StatelessWidget {
  const _DrawerTestScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => AppShell.openDrawer(context),
            child: const Text('Open drawer'),
          ),
        ),
      ),
    );
  }
}
