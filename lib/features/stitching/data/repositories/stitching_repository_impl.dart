import 'dart:io';
import 'package:photo_editor/features/stitching/data/datasources/stitching_data_source.dart';
import 'package:photo_editor/features/stitching/domain/repositories/stitching_repository.dart';

class StitchingRepositoryImpl implements StitchingRepository {
  final StitchingDataSource dataSource;

  StitchingRepositoryImpl(this.dataSource);

  @override
  Future<File> stitchImages(List<File> images) {
    return dataSource.stitchImages(images);
  }
}
