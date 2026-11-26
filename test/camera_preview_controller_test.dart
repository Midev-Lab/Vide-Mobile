import 'package:camera/camera.dart' as camera;
import 'package:flutter_test/flutter_test.dart';
import 'package:vide/features/chat/attach/services/camera_permission_gateway.dart';
import 'package:vide/features/chat/attach/services/camera_preview_controller.dart';

void main() {
  test(
    'an unavailable camera stays static without requesting permission',
    () async {
      final permission = _FakeCameraPermissionGateway(
        CameraPermissionStatus.notDetermined,
      );
      final controller = CameraPreviewControllerImpl(
        permissionGateway: permission,
        cameraLoader: () async => const [],
      );

      await controller.checkPermissionAndInitialize();

      expect(controller.status.value.state, CameraPreviewState.unavailable);
      expect(permission.prepareRequests, 0);
      await controller.dispose();
      await controller.dispose();
    },
  );

  test(
    'available cameras show the permission affordance without prompting',
    () async {
      final permission = _FakeCameraPermissionGateway(
        CameraPermissionStatus.notDetermined,
      );
      final controller = CameraPreviewControllerImpl(
        permissionGateway: permission,
        cameraLoader: () async => [_backCamera],
      );

      await controller.checkPermissionAndInitialize();

      expect(controller.status.value.state, CameraPreviewState.needsPermission);
      expect(permission.prepareRequests, 0);
      await controller.dispose();
    },
  );

  test('permanently denied camera permission exposes settings state', () async {
    final permission = _FakeCameraPermissionGateway(
      CameraPermissionStatus.permanentlyDenied,
    );
    final controller = CameraPreviewControllerImpl(
      permissionGateway: permission,
      cameraLoader: () async => [_backCamera],
    );

    await controller.checkPermissionAndInitialize();

    expect(controller.status.value.state, CameraPreviewState.needsPermission);
    expect(controller.status.value.permissionPermanentlyDenied, isTrue);
    expect(permission.prepareRequests, 0);
    await controller.dispose();
  });
}

const _backCamera = camera.CameraDescription(
  name: 'back',
  lensDirection: camera.CameraLensDirection.back,
  sensorOrientation: 90,
);

class _FakeCameraPermissionGateway implements CameraPermissionGateway {
  _FakeCameraPermissionGateway(this.permission);

  final CameraPermissionStatus permission;
  int prepareRequests = 0;

  @override
  Future<CameraPermissionStatus> status() async => permission;

  @override
  Future<void> preparePermissionRequest() async => prepareRequests++;

  @override
  Future<void> openSettings() async {}
}
