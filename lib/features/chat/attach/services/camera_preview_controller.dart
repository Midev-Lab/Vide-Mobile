import 'package:camera/camera.dart' as camera;
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'camera_permission_gateway.dart';

const cameraResolution = camera.ResolutionPreset.high;

enum CameraPreviewState {
  unavailable,
  needsPermission,
  initializing,
  ready,
  error,
}

class CameraPreviewSnapshot {
  const CameraPreviewSnapshot({
    required this.state,
    this.permissionPermanentlyDenied = false,
    this.errorMessage,
  });

  final CameraPreviewState state;
  final bool permissionPermanentlyDenied;
  final String? errorMessage;
}

abstract interface class CameraPreviewController {
  ValueListenable<CameraPreviewSnapshot> get status;

  camera.CameraController? get cameraController;

  int get cameraCount;

  Future<void> checkPermissionAndInitialize({bool requestPermission = false});

  Future<void> setFlashMode(camera.FlashMode mode);

  Future<void> flipCamera();

  Future<XFile> capture();

  Future<void> focusAt(Offset normalizedPoint);

  Future<void> handleLifecycle(AppLifecycleState state);

  Future<void> openSettings();

  Future<void> dispose();
}

class CameraPreviewControllerImpl implements CameraPreviewController {
  CameraPreviewControllerImpl({
    required this.permissionGateway,
    Future<List<camera.CameraDescription>> Function()? cameraLoader,
  }) : _cameraLoader = cameraLoader ?? camera.availableCameras;

  final CameraPermissionGateway permissionGateway;
  final Future<List<camera.CameraDescription>> Function() _cameraLoader;
  final ValueNotifier<CameraPreviewSnapshot> _status = ValueNotifier(
    const CameraPreviewSnapshot(state: CameraPreviewState.unavailable),
  );
  List<camera.CameraDescription> _cameras = const [];
  camera.CameraController? _cameraController;
  bool _isDisposed = false;
  bool _isPaused = false;
  int _cameraIndex = 0;

  @override
  ValueListenable<CameraPreviewSnapshot> get status => _status;

  @override
  camera.CameraController? get cameraController => _cameraController;

  @override
  int get cameraCount => _cameras.length;

  @override
  Future<void> checkPermissionAndInitialize({
    bool requestPermission = false,
  }) async {
    if (_isDisposed ||
        _status.value.state == CameraPreviewState.initializing ||
        _status.value.state == CameraPreviewState.ready) {
      return;
    }

    try {
      final permission = await permissionGateway.status();
      if (_isDisposed) return;

      if (permission != CameraPermissionStatus.granted) {
        if (!requestPermission &&
            permission != CameraPermissionStatus.permanentlyDenied &&
            permission != CameraPermissionStatus.restricted) {
          _cameras = await _cameraLoader();
          if (_isDisposed) return;
          if (_cameras.isEmpty) {
            _setStatus(
              CameraPreviewState.unavailable,
              errorMessage: 'A camera is not available on this device.',
            );
            return;
          }
        }
        if (!requestPermission ||
            permission == CameraPermissionStatus.permanentlyDenied ||
            permission == CameraPermissionStatus.restricted) {
          _setStatus(
            CameraPreviewState.needsPermission,
            permissionPermanentlyDenied:
                permission == CameraPermissionStatus.permanentlyDenied ||
                permission == CameraPermissionStatus.restricted,
          );
          return;
        }
        await permissionGateway.preparePermissionRequest();
        if (_isDisposed) return;
      }

      await _initializeCamera();
    } on camera.CameraException catch (error, stackTrace) {
      await _handleCameraException(error, stackTrace);
    } on PlatformException catch (error, stackTrace) {
      _setError('Camera is temporarily unavailable.');
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'attach sheet camera',
        ),
      );
    }
  }

  Future<void> _initializeCamera({
    camera.CameraDescription? description,
  }) async {
    _setStatus(CameraPreviewState.initializing);
    _cameras = await _cameraLoader();
    if (_isDisposed) return;
    if (_cameras.isEmpty) {
      _setStatus(
        CameraPreviewState.unavailable,
        errorMessage: 'A camera is not available on this device.',
      );
      return;
    }

    final selectedDescription =
        description ??
        _cameras.firstWhere(
          (item) => item.lensDirection == camera.CameraLensDirection.back,
          orElse: () => _cameras.first,
        );
    _cameraIndex = _cameras.indexOf(selectedDescription);
    final controller = camera.CameraController(
      selectedDescription,
      cameraResolution,
      enableAudio: false,
    );
    _cameraController = controller;

    try {
      await controller.initialize();
      if (_isDisposed || !identical(controller, _cameraController)) {
        await controller.dispose();
        return;
      }
      _isPaused = false;
      _setStatus(CameraPreviewState.ready);
    } on camera.CameraException {
      if (identical(controller, _cameraController)) {
        _cameraController = null;
      }
      await controller.dispose();
      rethrow;
    }
  }

  Future<void> _handleCameraException(
    camera.CameraException error,
    StackTrace stackTrace,
  ) async {
    final code = error.code.toLowerCase();
    if (code.contains('accessdenied') || code.contains('permission')) {
      var permission = CameraPermissionStatus.denied;
      try {
        permission = await permissionGateway.status();
      } on PlatformException catch (permissionError, permissionStackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: permissionError,
            stack: permissionStackTrace,
            library: 'attach sheet camera permission',
          ),
        );
      }
      _setStatus(
        CameraPreviewState.needsPermission,
        permissionPermanentlyDenied:
            code.contains('withoutprompt') ||
            code.contains('restricted') ||
            permission == CameraPermissionStatus.permanentlyDenied ||
            permission == CameraPermissionStatus.restricted,
      );
      return;
    }
    if (code.contains('cameraunavailable') || code.contains('notavailable')) {
      _setStatus(
        CameraPreviewState.unavailable,
        errorMessage: 'A camera is not available on this device.',
      );
      return;
    }
    _setError('Camera is temporarily unavailable.');
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'attach sheet camera',
      ),
    );
  }

  void _setStatus(
    CameraPreviewState state, {
    bool permissionPermanentlyDenied = false,
    String? errorMessage,
  }) {
    if (_isDisposed) return;
    _status.value = CameraPreviewSnapshot(
      state: state,
      permissionPermanentlyDenied: permissionPermanentlyDenied,
      errorMessage: errorMessage,
    );
  }

  void _setError(String message) =>
      _setStatus(CameraPreviewState.error, errorMessage: message);

  @override
  Future<void> setFlashMode(camera.FlashMode mode) async {
    final controller = _cameraController;
    if (_isDisposed || controller == null || !controller.value.isInitialized) {
      return;
    }
    await controller.setFlashMode(mode);
  }

  @override
  Future<void> flipCamera() async {
    if (_isDisposed || _cameras.length < 2) return;
    final current = _cameraController;
    if (current != null) {
      _cameraController = null;
      await current.dispose();
    }
    if (_isDisposed) return;
    final nextCameraIndex = (_cameraIndex + 1) % _cameras.length;
    try {
      await _initializeCamera(description: _cameras[nextCameraIndex]);
    } on camera.CameraException catch (error, stackTrace) {
      await _handleCameraException(error, stackTrace);
    }
  }

  @override
  Future<XFile> capture() async {
    final controller = _cameraController;
    if (_isDisposed || controller == null || !controller.value.isInitialized) {
      throw StateError('The camera is not ready to capture an image.');
    }
    return controller.takePicture();
  }

  @override
  Future<void> focusAt(Offset normalizedPoint) async {
    final controller = _cameraController;
    if (_isDisposed || controller == null || !controller.value.isInitialized) {
      return;
    }
    await controller.setFocusPoint(normalizedPoint);
    await controller.setExposurePoint(normalizedPoint);
  }

  @override
  Future<void> handleLifecycle(AppLifecycleState state) async {
    final controller = _cameraController;
    if (_isDisposed || controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (_isPaused) return;
      _isPaused = true;
      try {
        await controller.pausePreview();
      } on camera.CameraException catch (error, stackTrace) {
        await _handleCameraException(error, stackTrace);
      }
    } else if (state == AppLifecycleState.resumed && _isPaused) {
      _isPaused = false;
      try {
        await controller.resumePreview();
      } on camera.CameraException catch (error, stackTrace) {
        await _handleCameraException(error, stackTrace);
      }
    }
  }

  @override
  Future<void> openSettings() => permissionGateway.openSettings();

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    final controller = _cameraController;
    _cameraController = null;
    try {
      if (controller != null) await controller.dispose();
    } on camera.CameraException catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'attach sheet camera disposal',
        ),
      );
    } on PlatformException catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'attach sheet camera disposal',
        ),
      );
    } finally {
      _status.dispose();
    }
  }
}

final cameraPermissionGatewayProvider = Provider<CameraPermissionGateway>(
  (ref) => const MethodChannelCameraPermissionGateway(),
);

final cameraPreviewControllerFactoryProvider =
    Provider<CameraPreviewController Function()>((ref) {
      final permissionGateway = ref.watch(cameraPermissionGatewayProvider);
      return () =>
          CameraPreviewControllerImpl(permissionGateway: permissionGateway);
    });
