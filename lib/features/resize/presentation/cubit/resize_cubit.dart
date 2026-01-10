import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_editor/features/resize/domain/repositories/resize_repository.dart';
import 'package:photo_editor/features/resize/presentation/cubit/resize_state.dart';

class ResizeCubit extends Cubit<ResizeState> {
  final ResizeRepository repository;

  ResizeCubit(this.repository) : super(ResizeInitial());

  Future<void> pickImage() async {
    emit(ResizeLoading());
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final file = File(image.path);
        final size = await file.length();
        final exif = await repository.getExifData(file);

        emit(
          ResizeReady(originalFile: file, originalSize: size, exifData: exif),
        );
      } else {
        emit(ResizeInitial()); // Cancelled
      }
    } catch (e) {
      emit(ResizeError(e.toString()));
    }
  }

  Future<void> compressImage({
    required int quality,
    required CompressFormat format,
    required int width,
    required int height,
  }) async {
    final currentState = state;
    if (currentState is ResizeReady) {
      emit(ResizeLoading());
      try {
        final compressed = await repository.compressImage(
          currentState.originalFile,
          quality: quality,
          format: format,
          minWidth: width,
          minHeight: height,
        );

        if (compressed != null) {
          final compressedSize = await compressed.length();
          emit(
            ResizeReady(
              originalFile: currentState.originalFile,
              compressedFile: compressed,
              exifData: currentState.exifData,
              originalSize: currentState.originalSize,
              compressedSize: compressedSize,
            ),
          );
        } else {
          emit(ResizeError("Compression failed to return a file."));
        }
      } catch (e) {
        emit(ResizeError(e.toString()));
      }
    }
  }
}
