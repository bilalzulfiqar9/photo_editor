import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

abstract class ResizeDataSource {
  Future<File?> compressImage(
    File file, {
    required int quality,
    required CompressFormat format,
    int? minWidth,
    int? minHeight,
  });

  Future<Map<String, dynamic>> getExifData(File file);
  Future<void> writeExifData(File file, Map<String, dynamic> data);
}

class ResizeDataSourceImpl implements ResizeDataSource {
  @override
  Future<File?> compressImage(
    File file, {
    required int quality,
    required CompressFormat format,
    int? minWidth,
    int? minHeight,
  }) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/${const Uuid().v4()}${_getExtension(format)}';

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: minWidth ?? 1920,
      minHeight: minHeight ?? 1080,
      format: format,
    );

    return result != null ? File(result.path) : null;
  }

  @override
  Future<Map<String, dynamic>> getExifData(File file) async {
    final exif = await Exif.fromPath(file.path);
    final attributes = await exif.getAttributes();
    await exif.close();
    return attributes ?? {};
  }

  @override
  Future<void> writeExifData(File file, Map<String, dynamic> data) async {
    final exif = await Exif.fromPath(file.path);
    // native_exif expects Map<String, Object> or compatible values.
    // Casting manually to be safe or just creating a new map.
    final Map<String, Object> compatibleData = {};
    data.forEach((key, value) {
      if (value != null) {
        compatibleData[key] = value as Object;
      }
    });
    await exif.writeAttributes(compatibleData);
    await exif.close();
  }

  String _getExtension(CompressFormat format) {
    switch (format) {
      case CompressFormat.jpeg:
        return '.jpg';
      case CompressFormat.png:
        return '.png';
      case CompressFormat.webp:
        return '.webp';
      case CompressFormat.heic:
        return '.heic';
    }
  }
}
