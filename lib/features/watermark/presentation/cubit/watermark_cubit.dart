import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_editor/features/watermark/domain/usecases/save_watermark_usecase.dart';
import 'watermark_state.dart';

class WatermarkCubit extends Cubit<WatermarkState> {
  final SaveWatermarkUseCase saveWatermarkUseCase;
  final ImagePicker _picker = ImagePicker();

  WatermarkCubit(this.saveWatermarkUseCase) : super(WatermarkInitial());

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        emit(WatermarkReady(File(image.path)));
      } else {
        emit(const WatermarkError("No image selected"));
      }
    } catch (e) {
      emit(WatermarkError("Failed to pick image: $e"));
    }
  }

  void loadImage(File file) {
    emit(WatermarkReady(file));
  }

  Future<void> save(Uint8List imageBytes) async {
    emit(WatermarkSaving());
    try {
      final result = await saveWatermarkUseCase(imageBytes);
      emit(WatermarkSaved(result));
    } catch (e) {
      emit(WatermarkError("Failed to save: $e"));
    }
  }
}
