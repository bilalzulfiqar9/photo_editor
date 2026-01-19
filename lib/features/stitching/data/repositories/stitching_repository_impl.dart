import 'dart:io';
import 'package:gal/gal.dart';
import 'package:photo_editor/features/stitching/data/datasources/stitching_data_source.dart';
import 'package:photo_editor/features/stitching/domain/repositories/stitching_repository.dart';

class StitchingRepositoryImpl implements StitchingRepository {
  final StitchingDataSource dataSource;

  StitchingRepositoryImpl(this.dataSource);

  @override
  Future<File> stitchImages(List<File> images) async {
    final file = await dataSource.stitchImages(images);
    try {
      await Gal.putImage(file.path);
    } catch (e) {
      print("Stitch: Error saving to gallery: $e");
    }
    return file;
  }
}
