import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vide/core/theme/theme.dart';
import 'package:vide/shared/dashboard/app_shell.dart';
import 'package:vide/shared/widgets/chat_composer.dart';
import 'package:vide/shared/widgets/chat_empty_state.dart';

void main() {
  testWidgets('chat composer fits at 320px with keyboard and five lines', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(child: Center(child: ChatEmptyState())),
                ChatComposer(),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);
    await tester.tap(textField);
    await tester.enterText(
      textField,
      'First line\nSecond line\nThird line\nFourth line\nFifth line',
    );
    await tester.pumpAndSettle();

    expect(find.byType(ChatComposer), findsOneWidget);
    expect(
      tester.widget<TextField>(textField).maxLines,
      AppSizes.chatComposerMaxLines,
    );
    expect(
      tester.widget<TextField>(textField).textInputAction,
      TextInputAction.newline,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('drawer opening waits for the keyboard to dismiss', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const AppShell(currentPath: '/chat', child: _KeyboardTestPage()),
      ),
    );
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);
    await tester.tap(textField);
    await tester.pump();
    await tester.tap(find.text('Open drawer'));
    await tester.pump();

    final focusNode = tester
        .widget<EditableText>(find.byType(EditableText))
        .focusNode;
    final pageAbsorber = find.descendant(
      of: find.byType(ClipRRect),
      matching: find.byType(AbsorbPointer),
    );
    expect(focusNode.hasFocus, isFalse);
    expect(tester.widget<AbsorbPointer>(pageAbsorber).absorbing, isFalse);

    tester.view.viewInsets = const FakeViewPadding();
    await tester.pumpAndSettle();

    expect(tester.widget<AbsorbPointer>(pageAbsorber).absorbing, isTrue);
    expect(tester.takeException(), isNull);
  });
}

class _KeyboardTestPage extends StatelessWidget {
  const _KeyboardTestPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          TextField(),
          Builder(
            builder: (context) => TextButton(
              onPressed: () => AppShell.openDrawer(context),
              child: const Text('Open drawer'),
            ),
          ),
        ],
      ),
    );
  }
}
