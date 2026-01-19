import 'dart:io';
import 'dart:typed_data';
import 'package:photo_editor/core/usecases/usecase.dart';
import 'package:photo_editor/features/watermark/domain/repositories/watermark_repository.dart';

class SaveWatermarkUseCase implements UseCase<File, Uint8List> {
  final WatermarkRepository repository;

  SaveWatermarkUseCase(this.repository);

  @override
  Future<File> call(Uint8List params) {
    return repository.saveImage(params);
  }
}
