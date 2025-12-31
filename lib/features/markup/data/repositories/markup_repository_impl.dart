import 'dart:io';
import 'dart:typed_data';
import 'package:photo_editor/features/markup/data/datasources/markup_data_source.dart';
import 'package:photo_editor/features/markup/domain/repositories/markup_repository.dart';

class MarkupRepositoryImpl implements MarkupRepository {
  final MarkupDataSource dataSource;

  MarkupRepositoryImpl(this.dataSource);

  @override
  Future<File> saveImage(Uint8List imageBytes) {
    return dataSource.saveImage(imageBytes);
  }
}
