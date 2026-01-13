import 'dart:io';
import 'package:gal/gal.dart';
import 'package:photo_editor/core/utils/permission_helper.dart';

class GallerySaverHelper {
  static Future<bool> saveImage(String filePath, {String? albumName}) async {
    try {
      if (await PermissionHelper.requestStoragePermission()) {
        await Gal.putImage(filePath, album: albumName);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> saveVideo(String filePath, {String? albumName}) async {
    try {
      if (await PermissionHelper.requestStoragePermission()) {
        await Gal.putVideo(filePath, album: albumName);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
