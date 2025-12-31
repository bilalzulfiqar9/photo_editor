import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photo_editor/features/resize/data/datasources/resize_data_source.dart';
import 'package:photo_editor/features/resize/domain/repositories/resize_repository.dart';

class ResizeRepositoryImpl implements ResizeRepository {
  final ResizeDataSource dataSource;

  ResizeRepositoryImpl(this.dataSource);

  @override
  Future<File?> compressImage(
    File file, {
    required int quality,
    required CompressFormat format,
    int? minWidth,
    int? minHeight,
  }) {
    return dataSource.compressImage(
      file,
      quality: quality,
      format: format,
      minWidth: minWidth,
      minHeight: minHeight,
    );
  }

  @override
  Future<Map<String, dynamic>> getExifData(File file) {
    return dataSource.getExifData(file);
  }
}
