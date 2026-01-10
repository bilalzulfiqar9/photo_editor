import 'dart:io';
import 'dart:typed_data';
import 'package:photo_editor/core/usecases/usecase.dart';
import 'package:photo_editor/features/overlay/domain/repositories/overlay_repository.dart';

class SaveOverlayUseCase implements UseCase<File, Uint8List> {
  final OverlayRepository repository;

  SaveOverlayUseCase(this.repository);

  @override
  Future<File> call(Uint8List params) {
    return repository.saveImage(params);
  }
}
