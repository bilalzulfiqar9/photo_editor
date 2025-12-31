import 'dart:io';
import 'package:photo_editor/features/stitching/domain/repositories/stitching_repository.dart';

class StitchImagesUseCase {
  final StitchingRepository repository;

  StitchImagesUseCase(this.repository);

  Future<File> call(List<File> images) {
    return repository.stitchImages(images);
  }
}
