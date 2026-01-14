import 'dart:io';
import 'package:gal/gal.dart';
import 'package:photo_editor/core/utils/permission_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class GallerySaverHelper {
  /// Notifier to trigger gallery refresh. Listened to by GalleryScreen.
  static final ValueNotifier<int> shouldReloadGallery = ValueNotifier(0);

  static Future<bool> saveImage(String filePath, {String? albumName}) async {
    bool gallerySuccess = false;
    bool appDocSuccess = false;

    // 1. Save to Device Gallery
    try {
      if (await PermissionHelper.requestStoragePermission()) {
        await Gal.putImage(filePath, album: albumName);
        gallerySuccess = true;
      }
    } catch (e) {
      debugPrint("Gallery save failed: $e");
    }

    // 2. Save to App Documents
    try {
      final appDir = await getApplicationDocumentsDirectory();
      await _copyToAppDocs(filePath, appDir);
      appDocSuccess = true;
    } catch (e) {
      debugPrint("App Doc save failed: $e");
    }

    if (appDocSuccess) {
      shouldReloadGallery.value++;
    }

    return gallerySuccess || appDocSuccess;
  }

  static Future<bool> saveVideo(String filePath, {String? albumName}) async {
    bool gallerySuccess = false;
    bool appDocSuccess = false;

    try {
      if (await PermissionHelper.requestStoragePermission()) {
        await Gal.putVideo(filePath, album: albumName);
        gallerySuccess = true;
      }
    } catch (e) {
      debugPrint("Gallery save failed: $e");
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      await _copyToAppDocs(filePath, appDir);
      appDocSuccess = true;
    } catch (e) {
      debugPrint("App Doc save failed: $e");
    }

    if (appDocSuccess) {
      shouldReloadGallery.value++;
    }

    return gallerySuccess || appDocSuccess;
  }

  static Future<void> _copyToAppDocs(
    String sourcePath,
    Directory appDir,
  ) async {
    final fileName = path.basename(sourcePath);
    String uniqueName = fileName;
    int i = 1;

    while (File(path.join(appDir.path, uniqueName)).existsSync()) {
      final name = path.basenameWithoutExtension(fileName);
      final ext = path.extension(fileName);
      uniqueName = '$name($i)$ext';
      i++;
    }

    await File(sourcePath).copy(path.join(appDir.path, uniqueName));
  }
}
