import 'dart:io';
import 'dart:typed_data';
import 'package:photo_editor/core/usecases/usecase.dart';
import 'package:photo_editor/features/crop/domain/repositories/crop_repository.dart';

class SaveCropUseCase implements UseCase<File, Uint8List> {
  final CropRepository repository;

  SaveCropUseCase(this.repository);

  @override
  Future<File> call(Uint8List params) {
    return repository.saveImage(params);
  }
}
