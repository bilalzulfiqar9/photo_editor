import 'dart:io';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestStoragePermission() async {
    // Gal handles permissions for saving images effectively across platforms
    // including Android 13+ scoped storage and iOS Photos add-only access.
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        return await Gal.requestAccess();
      }
      return true;
    } catch (e) {
      // Fallback for reading images if Gal doesn't cover read permissions
      // or if we strictly need READ_MEDIA_IMAGES for picking.
      if (Platform.isAndroid) {
        // For picking images, we still might need standard permissions
        if (await Permission.storage.request().isGranted) return true;
        if (await Permission.photos.request().isGranted) return true;
      }
      return false;
    }
  }
}
