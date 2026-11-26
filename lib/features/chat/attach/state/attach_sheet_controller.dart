import 'dart:async';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/theme/theme.dart';
import '../services/attach_picker_service.dart';
import '../services/camera_preview_controller.dart';
import '../services/recent_photos_service.dart';

class AttachSheetController extends ChangeNotifier {
  AttachSheetController({
    required this.cameraController,
    required this._recentPhotosService,
    required this._pickerService,
  });

  final CameraPreviewController cameraController;
  final RecentPhotosService _recentPhotosService;
  final AttachPickerService _pickerService;

  PhotoLibraryAccess? photoAccess;
  List<RecentPhoto> recentPhotos = const [];
  bool isLoadingPhotos = true;
  String? photoError;
  bool _cameraCheckStarted = false;
  bool _isDisposed = false;

  void initializePhotos() {
    unawaited(_loadPhotoAccess());
  }

  Future<void> _loadPhotoAccess() async {
    try {
      final access = await _recentPhotosService.checkAccess();
      if (_isDisposed) return;
      if (!access.isGranted) {
        photoAccess = access;
        isLoadingPhotos = false;
        photoError = null;
        _notify();
        return;
      }
      await _loadRecentPhotos(access);
    } on PlatformException catch (error, stackTrace) {
      _reportPhotoError(error, stackTrace);
      if (_isDisposed) return;
      photoError = 'Could not load recent photos. Try again.';
      isLoadingPhotos = false;
      _notify();
    } on FileSystemException catch (error, stackTrace) {
      _reportPhotoError(error, stackTrace);
      if (_isDisposed) return;
      photoError = 'Could not load recent photos. Try again.';
      isLoadingPhotos = false;
      _notify();
    }
  }

  Future<void> requestPhotoAccess() async {
    if (isLoadingPhotos) return;
    isLoadingPhotos = true;
    photoError = null;
    _notify();
    try {
      final access = await _recentPhotosService.requestAccess();
      if (_isDisposed) return;
      if (!access.isGranted) {
        photoAccess = access;
        isLoadingPhotos = false;
        _notify();
        return;
      }
      await _loadRecentPhotos(access);
    } on PlatformException catch (error, stackTrace) {
      _reportPhotoError(error, stackTrace);
      if (_isDisposed) return;
      photoError = 'Could not request photo access. Try again.';
      isLoadingPhotos = false;
      _notify();
    } on FileSystemException catch (error, stackTrace) {
      _reportPhotoError(error, stackTrace);
      if (_isDisposed) return;
      photoError = 'Could not request photo access. Try again.';
      isLoadingPhotos = false;
      _notify();
    }
  }

  Future<void> retryRecentPhotos() async {
    final access = photoAccess;
    if (access?.isGranted == true) {
      isLoadingPhotos = true;
      photoError = null;
      _notify();
      await _loadRecentPhotos(access!);
    } else {
      await requestPhotoAccess();
    }
  }

  Future<void> _loadRecentPhotos(PhotoLibraryAccess access) async {
    try {
      final photos = await _recentPhotosService.loadRecent(
        limit: AppSizes.attachSheetRecentPhotosCount,
      );
      if (_isDisposed) return;
      photoAccess = access;
      recentPhotos = photos;
      photoError = null;
      isLoadingPhotos = false;
      _notify();
    } on PlatformException catch (error, stackTrace) {
      _reportPhotoError(error, stackTrace);
      if (_isDisposed) return;
      photoAccess = access;
      photoError = 'Could not load recent photos. Try again.';
      isLoadingPhotos = false;
      _notify();
    } on FileSystemException catch (error, stackTrace) {
      _reportPhotoError(error, stackTrace);
      if (_isDisposed) return;
      photoAccess = access;
      photoError = 'Could not load recent photos. Try again.';
      isLoadingPhotos = false;
      _notify();
    }
  }

  Future<XFile?> loadPhotoFile(RecentPhoto photo) => photo.loadFile();

  Future<XFile?> pickGalleryPhoto() => _pickerService.pickGalleryPhoto();

  Future<XFile?> pickFile() => _pickerService.pickFile();

  Future<void> openPhotoSettings() => _recentPhotosService.openSettings();

  Future<void> openCameraSettings() => cameraController.openSettings();

  void prepareCameraAfterOpen() {
    if (_cameraCheckStarted || _isDisposed) return;
    _cameraCheckStarted = true;
    unawaited(cameraController.checkPermissionAndInitialize());
  }

  void handleLifecycle(AppLifecycleState state) {
    if (_isDisposed) return;
    unawaited(cameraController.handleLifecycle(state));
    if (state == AppLifecycleState.resumed &&
        cameraController.status.value.state ==
            CameraPreviewState.needsPermission) {
      unawaited(cameraController.checkPermissionAndInitialize());
    }
  }

  void _reportPhotoError(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'attach sheet photo library',
      ),
    );
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(cameraController.dispose());
    super.dispose();
  }
}
