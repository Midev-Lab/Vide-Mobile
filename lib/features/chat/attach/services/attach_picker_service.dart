import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

abstract interface class AttachPickerService {
  Future<XFile?> pickGalleryPhoto();

  Future<XFile?> pickFile();
}

class PlatformAttachPickerService implements AttachPickerService {
  PlatformAttachPickerService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<XFile?> pickGalleryPhoto() =>
      _imagePicker.pickImage(source: ImageSource.gallery);

  @override
  Future<XFile?> pickFile() => openFile();
}

final attachPickerServiceProvider = Provider<AttachPickerService>(
  (ref) => PlatformAttachPickerService(),
);
