import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 33) {
        // Android 13+
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();

        // Grant if at least photos or videos are granted, as these are visual media
        // (audio typically separate)
        return statuses[Permission.photos]!.isGranted ||
            statuses[Permission.videos]!.isGranted;
      } else {
        // Android 12 and below
        var status = await Permission.storage.request();
        return status.isGranted;
      }
    } else {
      // iOS and others
      var status = await Permission.photos.request();
      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
      return status.isGranted || await Permission.storage.request().isGranted;
    }
  }
}
