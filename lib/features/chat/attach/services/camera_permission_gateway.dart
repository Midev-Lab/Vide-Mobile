import 'package:flutter/services.dart';

enum CameraPermissionStatus {
  granted,
  notDetermined,
  denied,
  permanentlyDenied,
  restricted,
}

abstract interface class CameraPermissionGateway {
  Future<CameraPermissionStatus> status();

  Future<void> preparePermissionRequest();

  Future<void> openSettings();
}

class MethodChannelCameraPermissionGateway implements CameraPermissionGateway {
  const MethodChannelCameraPermissionGateway();

  static const _channel = MethodChannel('vide/camera_permissions');

  @override
  Future<CameraPermissionStatus> status() async {
    final value = await _channel.invokeMethod<String>('status');
    return switch (value) {
      'granted' => CameraPermissionStatus.granted,
      'notDetermined' => CameraPermissionStatus.notDetermined,
      'denied' => CameraPermissionStatus.denied,
      'permanentlyDenied' => CameraPermissionStatus.permanentlyDenied,
      'restricted' => CameraPermissionStatus.restricted,
      _ => throw PlatformException(
        code: 'CameraPermissionStatusUnavailable',
        message: 'The platform returned an unknown camera permission state.',
      ),
    };
  }

  @override
  Future<void> preparePermissionRequest() =>
      _channel.invokeMethod<void>('preparePermissionRequest');

  @override
  Future<void> openSettings() => _channel.invokeMethod<void>('openSettings');
}
