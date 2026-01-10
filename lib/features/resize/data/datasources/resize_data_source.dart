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
      default:
        return '.jpg';
    }
  }
}
