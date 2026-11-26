import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vide/core/storage/app_storage.dart';
import 'package:vide/features/focus/state/focus_timer_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('running and paused focus sessions restore from storage', () async {
    SharedPreferences.setMockInitialValues({});
    final clock = _MutableClock(DateTime(2026, 11, 26, 10));
    final controller = FocusTimerController(
      storage: AppStorage(),
      clock: clock.call,
    );
    await controller.restore();
    await controller.selectMinutes(45);
    await controller.start();

    final runningRestore = FocusTimerController(
      storage: AppStorage(),
      clock: clock.call,
    );
    await runningRestore.restore();

    expect(runningRestore.state, FocusTimerState.running);
    expect(runningRestore.selectedMinutes, 45);
    expect(runningRestore.endTime, controller.endTime);

    clock.advance(const Duration(minutes: 1));
    controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(controller.remaining, const Duration(minutes: 44));
    await controller.pause();

    final pausedRestore = FocusTimerController(
      storage: AppStorage(),
      clock: clock.call,
    );
    await pausedRestore.restore();

    expect(pausedRestore.state, FocusTimerState.paused);
    expect(pausedRestore.pausedRemaining, const Duration(minutes: 44));

    await pausedRestore.resume();
    expect(pausedRestore.state, FocusTimerState.running);
    expect(pausedRestore.endTime, clock.value.add(const Duration(minutes: 44)));

    await pausedRestore.endSession();
    expect(pausedRestore.state, FocusTimerState.idle);

    controller.dispose();
    runningRestore.dispose();
    pausedRestore.dispose();
  });

  test('focus durations format as mm:ss or h:mm:ss', () {
    expect(formatFocusDuration(const Duration(minutes: 25)), '25:00');
    expect(
      formatFocusDuration(const Duration(hours: 1, seconds: 2)),
      '1:00:02',
    );
  });

  test(
    'an expired session enters finished and emits one completion event',
    () async {
      SharedPreferences.setMockInitialValues({});
      final clock = _MutableClock(DateTime(2026, 11, 26, 10));
      final controller = FocusTimerController(
        storage: AppStorage(),
        clock: clock.call,
      );
      var completionEvents = 0;
      controller.onSessionFinished = () => completionEvents++;

      await controller.restore();
      await controller.start();
      clock.advance(const Duration(minutes: 26));
      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(controller.state, FocusTimerState.finished);
      expect(completionEvents, 1);
      expect(controller.endTime, isNull);

      await controller.endSession();
      controller.dispose();
    },
  );

  test(
    'a running session that expired while closed restores as finished',
    () async {
      SharedPreferences.setMockInitialValues({});
      final startTime = DateTime(2026, 11, 26, 10);
      final controller = FocusTimerController(
        storage: AppStorage(),
        clock: () => startTime,
      );
      await controller.restore();
      await controller.start();
      controller.dispose();

      final restored = FocusTimerController(
        storage: AppStorage(),
        clock: () => startTime.add(const Duration(minutes: 26)),
      );
      var completionEvents = 0;
      restored.onSessionFinished = () => completionEvents++;
      await restored.restore();

      expect(restored.state, FocusTimerState.finished);
      expect(completionEvents, 1);
      await restored.endSession();
      restored.dispose();
    },
  );
}

class _MutableClock {
  _MutableClock(this.value);

  DateTime value;

  DateTime call() => value;

  void advance(Duration duration) {
    value = value.add(duration);
  }
}
