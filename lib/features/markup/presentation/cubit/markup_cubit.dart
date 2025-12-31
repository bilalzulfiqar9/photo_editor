import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_editor/features/markup/domain/usecases/save_image_usecase.dart';
import 'markup_state.dart';

class MarkupCubit extends Cubit<MarkupState> {
  final SaveImageUseCase saveImageUseCase;
  final ImagePicker _picker = ImagePicker();

  MarkupCubit(this.saveImageUseCase) : super(MarkupInitial());

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        emit(MarkupReady(File(image.path)));
      } else {
        emit(const MarkupError("No image selected"));
      }
    } catch (e) {
      emit(MarkupError("Failed to pick image: $e"));
    }
  }

  void loadImage(File file) {
    emit(MarkupReady(file));
  }

  Future<void> save(Uint8List imageBytes) async {
    emit(MarkupSaving());
    try {
      final result = await saveImageUseCase(imageBytes);
      emit(MarkupSaved(result));
    } catch (e) {
      emit(MarkupError("Failed to save: $e"));
    }
  }
}
