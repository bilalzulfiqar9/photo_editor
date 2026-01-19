import 'dart:io';
import 'dart:ui' as ui;
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

        // Get dimensions
        int? width;
        int? height;
        try {
          final bytes = await file.readAsBytes();
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          width = frame.image.width;
          height = frame.image.height;
        } catch (_) {
          // Fallback
        }

        emit(
          ResizeReady(
            originalFile: file,
            originalSize: size,
            exifData: exif,
            originalWidth: width,
            originalHeight: height,
          ),
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
      emit(currentState.copyWith(isCompressing: true));
      try {
        final compressed = await repository.compressImage(
          currentState.originalFile,
          quality: quality,
          format: format,
          minWidth: width,
          minHeight: height,
        );

        if (compressed != null) {
          // Write updated EXIF data to the compressed file
          // We use the current state's exifData which might have been edited by the user.
          try {
            await repository.writeExifData(compressed, currentState.exifData);
          } catch (e) {
            print("Failed to write EXIF: $e");
            // Non-critical? Maybe showsnackbar.
          }

          final compressedSize = await compressed.length();
          emit(
            currentState.copyWith(
              compressedFile: compressed,
              compressedSize: compressedSize,
              isCompressing: false,
            ),
          );
        } else {
          // If compression fails, keep old state but stop compressing, or emit error?
          // Emitting Error replaces state, losing the image.
          // Better to just show snackbar via listener but keep state?
          // For now, let's just turn off compressing and maybe toast.
          emit(currentState.copyWith(isCompressing: false));
          // emit(ResizeError("Compression failed")); // Optional: if we want to reset
        }
      } catch (e) {
        emit(currentState.copyWith(isCompressing: false));
        // emit(ResizeError(e.toString()));
      }
    }
  }

  void updateExif(Map<String, dynamic> newExif) {
    if (state is ResizeReady) {
      final current = (state as ResizeReady);
      final updatedExif = Map<String, dynamic>.from(current.exifData);
      updatedExif.addAll(newExif);
      emit(current.copyWith(exifData: updatedExif));
    }
  }
}
