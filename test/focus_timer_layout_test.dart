import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vide/core/theme/theme.dart';
import 'package:vide/features/focus/state/focus_timer_controller.dart';
import 'package:vide/features/focus/widgets/focus_timer_header_control.dart';
import 'package:vide/shared/widgets/dashboard_header.dart';

void main() {
  testWidgets('focus timer popover fits 320px at 1.3 text scale', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 812);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    final controller = FocusTimerController();
    final messengerKey = GlobalKey<ScaffoldMessengerState>();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        scaffoldMessengerKey: messengerKey,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: FocusTimerHost(
            controller: controller,
            scaffoldMessengerKey: messengerKey,
            child: child!,
          ),
        ),
        home: const Scaffold(
          body: Column(
            children: [
              DashboardHeader(title: 'New study session', subtitle: 'Today'),
              Expanded(child: SizedBox.expand()),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byType(FocusTimerHeaderControl));
    await tester.pump();
    await tester.pump(AppMotion.focusPopoverOpenDuration);

    expect(find.bySemanticsLabel('Add to chat'), findsNothing);
    expect(find.text('Focus session'), findsOneWidget);
    expect(find.text('Start focus'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Focus session'),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Material && widget.type == MaterialType.transparency,
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: find.text('Focus session'),
        matching: find.byType(DefaultTextStyle),
      ),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Start focus'));
    await tester.pump();
    await tester.pump(AppMotion.focusPopoverOpenDuration);

    expect(find.text('25:00'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(FocusTimerHeaderControl));
    await tester.pump();
    await tester.pump(AppMotion.focusPopoverOpenDuration);
    expect(
      find.ancestor(
        of: find.text('Focus session'),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Material && widget.type == MaterialType.transparency,
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('End session'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('expired focus session shows a completion snackbar', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    var now = DateTime(2026, 11, 26, 10);
    final controller = FocusTimerController(clock: () => now);
    final messengerKey = GlobalKey<ScaffoldMessengerState>();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        scaffoldMessengerKey: messengerKey,
        builder: (context, child) => FocusTimerHost(
          controller: controller,
          scaffoldMessengerKey: messengerKey,
          child: child!,
        ),
        home: Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => unawaited(controller.start()),
              child: const Text('Start timer for completion test'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Start timer for completion test'));
    await tester.pump();
    await tester.pump();

    now = now.add(const Duration(minutes: 26));
    controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();

    expect(controller.state, FocusTimerState.finished);
    expect(find.text('Focus session complete'), findsOneWidget);

    await tester.pump(AppMotion.focusFinishNoticeDuration);
    expect(controller.state, FocusTimerState.idle);
  });
}
