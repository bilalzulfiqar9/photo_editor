import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_editor/features/overlay/domain/usecases/save_overlay_usecase.dart';
import 'overlay_state.dart';

class OverlayCubit extends Cubit<OverlayState> {
  final SaveOverlayUseCase saveOverlayUseCase;
  final ImagePicker _picker = ImagePicker();

  OverlayCubit(this.saveOverlayUseCase) : super(OverlayInitial());

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        emit(OverlayReady(File(image.path)));
      } else {
        emit(const OverlayError("No image selected"));
      }
    } catch (e) {
      emit(OverlayError("Failed to pick image: $e"));
    }
  }

  void loadImage(File file) {
    emit(OverlayReady(file));
  }

  Future<void> save(Uint8List imageBytes) async {
    emit(OverlaySaving());
    try {
      final result = await saveOverlayUseCase(imageBytes);
      emit(OverlaySaved(result));
    } catch (e) {
      emit(OverlayError("Failed to save: $e"));
    }
  }
}
