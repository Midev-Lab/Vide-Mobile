import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/storage/storage.dart';
import '../../../core/theme/theme.dart';

enum FocusTimerState { idle, running, paused, finished }

String formatFocusDuration(Duration duration) {
  final totalSeconds = duration.inSeconds.clamp(0, 1 << 31);
  final seconds = totalSeconds % Duration.secondsPerMinute;
  final totalMinutes = totalSeconds ~/ Duration.secondsPerMinute;

  if (totalMinutes >= Duration.minutesPerHour) {
    final hours = totalMinutes ~/ Duration.minutesPerHour;
    final minutes = totalMinutes % Duration.minutesPerHour;
    return '$hours:${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  return '${totalMinutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

String describeFocusDuration(Duration duration) {
  final totalSeconds = duration.inSeconds.clamp(0, 1 << 31);
  final hours = totalSeconds ~/ Duration.secondsPerHour;
  final minutes =
      (totalSeconds ~/ Duration.secondsPerMinute) % Duration.minutesPerHour;
  final seconds = totalSeconds % Duration.secondsPerMinute;
  final parts = <String>[];

  if (hours > 0) parts.add('$hours ${hours == 1 ? 'hour' : 'hours'}');
  if (minutes > 0 || hours > 0) {
    parts.add('$minutes ${minutes == 1 ? 'minute' : 'minutes'}');
  }
  parts.add('$seconds ${seconds == 1 ? 'second' : 'seconds'}');
  return parts.join(' ');
}

class FocusTimerController extends ChangeNotifier with WidgetsBindingObserver {
  FocusTimerController({AppStorage? storage, DateTime Function()? clock})
    : _storage = storage ?? AppStorage(),
      _clock = clock ?? DateTime.now {
    WidgetsBinding.instance.addObserver(this);
  }

  static const int minimumMinutes = 5;
  static const int maximumMinutes = 180;
  static const int minuteStep = 5;
  static const String _storageKey = 'focus_timer.session.v1';

  final AppStorage _storage;
  final DateTime Function() _clock;

  FocusTimerState _state = FocusTimerState.idle;
  int _selectedMinutes = 25;
  DateTime? _endTime;
  Duration _remaining = Duration.zero;
  Duration? _pausedRemaining;
  Duration _accessibleRemaining = Duration.zero;
  int _accessibleMinuteBucket = 0;
  Timer? _ticker;
  Timer? _finishResetTimer;
  Future<void>? _restoreFuture;
  Future<void> _pendingWrite = Future<void>.value();

  VoidCallback? onSessionFinished;

  FocusTimerState get state => _state;
  int get selectedMinutes => _selectedMinutes;
  DateTime? get endTime => _endTime;
  Duration get remaining => _remaining;
  Duration? get pausedRemaining => _pausedRemaining;
  Duration get accessibleRemaining => _accessibleRemaining;

  String get semanticLabel => switch (_state) {
    FocusTimerState.idle => 'Focus timer. Idle. Open focus session controls.',
    FocusTimerState.running =>
      'Focus timer, ${describeFocusDuration(_accessibleRemaining)} remaining.',
    FocusTimerState.paused =>
      'Focus timer paused, ${describeFocusDuration(_accessibleRemaining)} remaining.',
    FocusTimerState.finished => 'Focus timer. Focus session complete.',
  };

  Future<void> restore() => _restoreFuture ??= _restore();

  Future<void> _restore() async {
    final storedValue = await _storage.getString(_storageKey);
    if (storedValue == null) return;

    final decoded = jsonDecode(storedValue);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid focus timer session data.');
    }

    final selected = decoded['selectedMinutes'];
    if (selected is! int ||
        selected < minimumMinutes ||
        selected > maximumMinutes ||
        selected % minuteStep != 0) {
      throw const FormatException('Invalid selected focus duration.');
    }

    final savedState = _parseState(decoded['state']);
    _selectedMinutes = selected;
    _state = savedState;

    switch (savedState) {
      case FocusTimerState.idle:
        _remaining = Duration.zero;
        _endTime = null;
        _pausedRemaining = null;
      case FocusTimerState.running:
        final timestamp = decoded['endTime'];
        if (timestamp is! int) {
          throw const FormatException('Missing focus timer end time.');
        }
        _endTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        _remaining = _endTime!.difference(_clock());
        if (_remaining <= Duration.zero) {
          _finish();
          return;
        }
        _setAccessibleRemaining(_remaining);
        _startTicker();
      case FocusTimerState.paused:
        final milliseconds = decoded['pausedRemainingMilliseconds'];
        if (milliseconds is! int || milliseconds <= 0) {
          throw const FormatException('Missing paused focus timer duration.');
        }
        _pausedRemaining = Duration(milliseconds: milliseconds);
        _remaining = _pausedRemaining!;
        _endTime = null;
        _setAccessibleRemaining(_remaining);
      case FocusTimerState.finished:
        _remaining = Duration.zero;
        _endTime = null;
        _pausedRemaining = null;
        _finish(force: true);
        return;
    }

    notifyListeners();
  }

  FocusTimerState _parseState(Object? value) {
    if (value is String) {
      for (final state in FocusTimerState.values) {
        if (state.name == value) return state;
      }
    }
    throw const FormatException('Invalid focus timer state.');
  }

  Future<void> selectMinutes(int minutes) async {
    if (_state != FocusTimerState.idle) return;
    final clamped = minutes.clamp(minimumMinutes, maximumMinutes);
    _selectedMinutes = ((clamped / minuteStep).round() * minuteStep).clamp(
      minimumMinutes,
      maximumMinutes,
    );
    notifyListeners();
    await _persist();
  }

  Future<void> start() async {
    await restore();
    if (_state != FocusTimerState.idle) return;

    _remaining = Duration(minutes: _selectedMinutes);
    _endTime = _clock().add(_remaining);
    _pausedRemaining = null;
    _state = FocusTimerState.running;
    _setAccessibleRemaining(_remaining);
    _startTicker();
    notifyListeners();
    await _persist();
  }

  Future<void> pause() async {
    if (_state != FocusTimerState.running) return;
    _updateFromClock();
    if (_state != FocusTimerState.running) return;

    _ticker?.cancel();
    _ticker = null;
    _pausedRemaining = _remaining;
    _endTime = null;
    _state = FocusTimerState.paused;
    _setAccessibleRemaining(_remaining);
    notifyListeners();
    await _persist();
  }

  Future<void> resume() async {
    if (_state != FocusTimerState.paused) return;
    final remaining = _pausedRemaining;
    if (remaining == null || remaining <= Duration.zero) {
      _finish();
      return;
    }

    _remaining = remaining;
    _endTime = _clock().add(remaining);
    _pausedRemaining = null;
    _state = FocusTimerState.running;
    _setAccessibleRemaining(_remaining);
    _startTicker();
    notifyListeners();
    await _persist();
  }

  Future<void> endSession() async {
    _ticker?.cancel();
    _ticker = null;
    _finishResetTimer?.cancel();
    _finishResetTimer = null;
    _state = FocusTimerState.idle;
    _endTime = null;
    _remaining = Duration.zero;
    _pausedRemaining = null;
    _setAccessibleRemaining(Duration.zero);
    notifyListeners();
    await _persist();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(
      AppMotion.focusTimerTickInterval,
      (_) => _updateFromClock(),
    );
  }

  void _updateFromClock() {
    if (_state != FocusTimerState.running || _endTime == null) return;

    final updatedRemaining = _endTime!.difference(_clock());
    if (updatedRemaining <= Duration.zero) {
      _finish();
      return;
    }

    _remaining = updatedRemaining;
    final minuteBucket =
        (updatedRemaining.inMilliseconds +
            Duration.millisecondsPerMinute -
            1) ~/
        Duration.millisecondsPerMinute;
    if (minuteBucket != _accessibleMinuteBucket) {
      _setAccessibleRemaining(updatedRemaining);
    }
    notifyListeners();
  }

  void _setAccessibleRemaining(Duration value) {
    _accessibleRemaining = value;
    _accessibleMinuteBucket =
        (value.inMilliseconds + Duration.millisecondsPerMinute - 1) ~/
        Duration.millisecondsPerMinute;
  }

  void _finish({bool force = false}) {
    if (_state == FocusTimerState.finished && !force) return;

    _ticker?.cancel();
    _ticker = null;
    _state = FocusTimerState.finished;
    _endTime = null;
    _remaining = Duration.zero;
    _pausedRemaining = null;
    _setAccessibleRemaining(Duration.zero);
    notifyListeners();
    unawaited(HapticFeedback.heavyImpact());
    unawaited(_persist());

    _finishResetTimer?.cancel();
    _finishResetTimer = Timer(AppMotion.focusFinishNoticeDuration, () {
      if (_state != FocusTimerState.finished) return;
      _state = FocusTimerState.idle;
      _setAccessibleRemaining(Duration.zero);
      notifyListeners();
      unawaited(_persist());
    });
    onSessionFinished?.call();
  }

  Future<void> _persist() {
    final serialized = jsonEncode({
      'state': _state.name,
      'selectedMinutes': _selectedMinutes,
      'endTime': _endTime?.millisecondsSinceEpoch,
      'pausedRemainingMilliseconds': _pausedRemaining?.inMilliseconds,
    });
    final write = _pendingWrite.then((_) async {
      final saved = await _storage.setString(_storageKey, serialized);
      if (!saved) throw StateError('Unable to persist focus timer state.');
    });
    _pendingWrite = write;
    return write;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _updateFromClock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _finishResetTimer?.cancel();
    super.dispose();
  }
}

class FocusTimerHost extends StatefulWidget {
  const FocusTimerHost({
    super.key,
    required this.controller,
    required this.scaffoldMessengerKey,
    required this.child,
  });

  final FocusTimerController controller;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final Widget child;

  @override
  State<FocusTimerHost> createState() => _FocusTimerHostState();
}

class _FocusTimerHostState extends State<FocusTimerHost> {
  @override
  void initState() {
    super.initState();
    widget.controller.onSessionFinished = _showCompletionNotice;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(widget.controller.restore());
    });
  }

  void _showCompletionNotice() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final colors = AppColors.of(context);
      final messenger = widget.scaffoldMessengerKey.currentState;
      if (messenger == null) {
        throw StateError('The focus timer snackbar host is unavailable.');
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Focus session complete',
            style: AppTextStyles.uiBody.copyWith(color: colors.card),
          ),
          duration: AppMotion.focusFinishNoticeDuration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.green,
        ),
      );
    });
  }

  @override
  void didUpdateWidget(covariant FocusTimerHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.onSessionFinished = null;
      oldWidget.controller.dispose();
      widget.controller.onSessionFinished = _showCompletionNotice;
      unawaited(widget.controller.restore());
    }
  }

  @override
  void dispose() {
    widget.controller.onSessionFinished = null;
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusTimerScope(controller: widget.controller, child: widget.child);
  }
}

class FocusTimerScope extends InheritedNotifier<FocusTimerController> {
  const FocusTimerScope({
    super.key,
    required FocusTimerController controller,
    required super.child,
  }) : super(notifier: controller);

  static FocusTimerController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FocusTimerScope>();
    assert(scope != null, 'FocusTimerScope is missing above this context.');
    return scope!.notifier!;
  }
}
