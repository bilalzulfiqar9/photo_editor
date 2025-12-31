import 'dart:io';
import 'dart:typed_data';
import 'package:photo_editor/core/usecases/usecase.dart';
import 'package:photo_editor/features/markup/domain/repositories/markup_repository.dart';

class SaveImageUseCase implements UseCase<File, Uint8List> {
  final MarkupRepository repository;

  SaveImageUseCase(this.repository);

  @override
  Future<File> call(Uint8List params) {
    return repository.saveImage(params);
  }
}
