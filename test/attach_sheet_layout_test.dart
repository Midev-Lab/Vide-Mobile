import 'dart:async';

import 'package:camera/camera.dart' as camera;
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vide/core/theme/theme.dart';
import 'package:vide/features/chat/attach/attach_sheet.dart';
import 'package:vide/features/chat/attach/services/camera_preview_controller.dart';
import 'package:vide/features/chat/attach/services/recent_photos_service.dart';
import 'package:vide/features/quota/models/chat_quota.dart';
import 'package:vide/features/quota/services/chat_quota_repository.dart';
import 'package:vide/features/quota/state/chat_quota_providers.dart';

void main() {
  testWidgets('attach sheet fits at 320px with 1.3 text scale', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 812);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cameraController = _FakeCameraPreviewController();
    await _pumpAttachHarness(
      tester,
      cameraController: cameraController,
      textScale: 1.3,
    );
    await tester.tap(find.text('Open attach sheet'));
    await _settleAttachSheet(tester);

    expect(find.text('Bring something in'), findsOneWidget);
    expect(
      find.text('Allow photo access to see recent photos'),
      findsOneWidget,
    );
    expect(cameraController.initialChecks, 1);
    expect(cameraController.permissionRequests, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scan tile requests camera permission only after a tap', (
    tester,
  ) async {
    final cameraController = _FakeCameraPreviewController();
    await _pumpAttachHarness(tester, cameraController: cameraController);
    await tester.tap(find.text('Open attach sheet'));
    await _settleAttachSheet(tester);

    expect(cameraController.permissionRequests, 0);
    await tester.tap(find.text('Tap to allow camera'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(cameraController.permissionRequests, 1);
    expect(find.text('Camera access was not granted.'), findsOneWidget);
  });

  testWidgets('unknown quota hides the pill and zero quota shows limit state', (
    tester,
  ) async {
    await _pumpAttachHarness(
      tester,
      cameraController: _FakeCameraPreviewController(),
      quotaRepository: const _FixedQuotaRepository(ChatQuota(remaining: null)),
    );
    await tester.tap(find.text('Open attach sheet'));
    await _settleAttachSheet(tester);
    expect(find.text('Limit reached'), findsNothing);
    await tester.tap(find.text('Add chat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Bring something in'), findsNothing);

    await _pumpAttachHarness(
      tester,
      cameraController: _FakeCameraPreviewController(),
      quotaRepository: const _FixedQuotaRepository(ChatQuota(remaining: 0)),
    );
    await tester.tap(find.text('Open attach sheet').last);
    await _settleAttachSheet(tester);
    expect(find.text('Limit reached'), findsOneWidget);
    await tester.tap(find.text('Add chat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("You've used your chats for today"), findsOneWidget);
    expect(find.text('Bring something in'), findsOneWidget);
  });
}

Future<void> _settleAttachSheet(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pumpAndSettle();
}

Future<void> _pumpAttachHarness(
  WidgetTester tester, {
  required _FakeCameraPreviewController cameraController,
  double textScale = 1,
  ChatQuotaRepository quotaRepository = const UnknownChatQuotaRepository(),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cameraPreviewControllerFactoryProvider.overrideWithValue(
          () => cameraController,
        ),
        recentPhotosServiceProvider.overrideWithValue(
          const _NoRecentPhotosService(),
        ),
        chatQuotaRepositoryProvider.overrideWithValue(quotaRepository),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => unawaited(showAttachSheet(context: context)),
                child: const Text('Open attach sheet'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _FakeCameraPreviewController implements CameraPreviewController {
  final ValueNotifier<CameraPreviewSnapshot> _status = ValueNotifier(
    const CameraPreviewSnapshot(state: CameraPreviewState.needsPermission),
  );
  int initialChecks = 0;
  int permissionRequests = 0;

  @override
  ValueListenable<CameraPreviewSnapshot> get status => _status;

  @override
  camera.CameraController? get cameraController => null;

  @override
  int get cameraCount => 0;

  @override
  Future<void> checkPermissionAndInitialize({
    bool requestPermission = false,
  }) async {
    initialChecks++;
    if (requestPermission) permissionRequests++;
  }

  @override
  Future<void> setFlashMode(camera.FlashMode mode) async {}

  @override
  Future<void> flipCamera() async {}

  @override
  Future<XFile> capture() => throw StateError('No camera in test fake.');

  @override
  Future<void> focusAt(Offset normalizedPoint) async {}

  @override
  Future<void> handleLifecycle(AppLifecycleState state) async {}

  @override
  Future<void> openSettings() async {}

  @override
  Future<void> dispose() async => _status.dispose();
}

class _NoRecentPhotosService implements RecentPhotosService {
  const _NoRecentPhotosService();

  @override
  Future<PhotoLibraryAccess> checkAccess() async =>
      const PhotoLibraryAccess(isGranted: false, requiresSettings: false);

  @override
  Future<PhotoLibraryAccess> requestAccess() async =>
      const PhotoLibraryAccess(isGranted: false, requiresSettings: false);

  @override
  Future<List<RecentPhoto>> loadRecent({required int limit}) async => const [];

  @override
  Future<void> openSettings() async {}
}

class _FixedQuotaRepository implements ChatQuotaRepository {
  const _FixedQuotaRepository(this.quota);

  final ChatQuota quota;

  @override
  Future<ChatQuota> fetch() async => quota;

  @override
  Stream<ChatQuota> watch() => Stream<ChatQuota>.value(quota);
}
