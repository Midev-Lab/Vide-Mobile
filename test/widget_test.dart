import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vide/core/router/app_router.dart';
import 'package:vide/core/theme/app_theme.dart';
import 'package:vide/core/theme/theme_provider.dart';
import 'package:vide/features/blank/presentation/blank_screen.dart';
import 'package:vide/main.dart';

void main() {
  testWidgets('App boots on the blank screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    final themeProvider = ThemeProvider();
    await themeProvider.loadFromPrefs();

    await tester.pumpWidget(VideApp(themeProvider: themeProvider));

    await tester.pumpAndSettle();

    expect(find.byType(BlankScreen), findsOneWidget);
    expect(AppRouter.router.routeInformationProvider.value.uri.path, '/');

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppTheme.light.scaffoldBackgroundColor);
    expect(scaffold.body, isNull);
  });
}
