import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_editor/core/utils/gallery_saver_helper.dart';

part 'studio_state.dart';

class StudioCubit extends Cubit<StudioState> {
  final ImagePicker _picker = ImagePicker();

  StudioCubit() : super(StudioInitial());

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        emit(StudioReady(File(image.path)));
      } else {
        // User cancelled picker
        // emit(const StudioError("No image selected"));
        // Or just stay in initial/previous state?
        // If initial, maybe error so UI pops?
        if (state is StudioInitial) {
          emit(const StudioError("No image selected"));
        }
      }
    } catch (e) {
      emit(StudioError("Failed to pick image: $e"));
    }
  }

  void loadImage(File file) {
    emit(StudioReady(file));
  }

  Future<void> save(Uint8List bytes) async {
    emit(StudioSaving());
    try {
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(bytes);

      final success = await GallerySaverHelper.saveImage(tempFile.path);

      if (success) {
        emit(StudioSaved(tempFile));
      } else {
        emit(const StudioError("Failed to save image to gallery"));
      }
    } catch (e) {
      emit(StudioError("Failed to save: $e"));
    }
  }
}
