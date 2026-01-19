import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

abstract class ResizeRepository {
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
