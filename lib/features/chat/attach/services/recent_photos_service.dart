import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoLibraryAccess {
  const PhotoLibraryAccess({
    required this.isGranted,
    required this.requiresSettings,
  });

  final bool isGranted;
  final bool requiresSettings;
}

class RecentPhoto {
  const RecentPhoto({
    required this.id,
    required this.loadThumbnail,
    required this.loadFile,
  });

  final String id;
  final Future<Uint8List?> Function() loadThumbnail;
  final Future<XFile?> Function() loadFile;
}

abstract interface class RecentPhotosService {
  Future<PhotoLibraryAccess> checkAccess();

  Future<PhotoLibraryAccess> requestAccess();

  Future<List<RecentPhoto>> loadRecent({required int limit});

  Future<void> openSettings();
}

class PhotoManagerRecentPhotosService implements RecentPhotosService {
  const PhotoManagerRecentPhotosService();

  @override
  Future<PhotoLibraryAccess> checkAccess() async {
    final permission = await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(),
    );
    return _accessFor(permission);
  }

  @override
  Future<PhotoLibraryAccess> requestAccess() async {
    final permission = await PhotoManager.requestPermissionExtend();
    return _accessFor(permission);
  }

  PhotoLibraryAccess _accessFor(PermissionState permission) {
    return PhotoLibraryAccess(
      isGranted: permission.hasAccess,
      requiresSettings:
          permission == PermissionState.denied ||
          permission == PermissionState.restricted,
    );
  }

  @override
  Future<List<RecentPhoto>> loadRecent({required int limit}) async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );
    if (albums.isEmpty) return const [];

    final assets = await albums.first.getAssetListRange(start: 0, end: limit);
    return assets
        .map(
          (asset) => RecentPhoto(
            id: asset.id,
            loadThumbnail: () => asset.thumbnailDataWithSize(
              const ThumbnailSize(152, 152),
              quality: 80,
            ),
            loadFile: () async {
              final file = await asset.file;
              return file == null ? null : XFile(file.path);
            },
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> openSettings() => PhotoManager.openSetting();
}

final recentPhotosServiceProvider = Provider<RecentPhotosService>(
  (ref) => const PhotoManagerRecentPhotosService(),
);
