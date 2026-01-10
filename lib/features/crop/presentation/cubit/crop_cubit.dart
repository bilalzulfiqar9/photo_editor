import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_editor/features/crop/domain/usecases/save_crop_usecase.dart';
import 'crop_state.dart';

class CropCubit extends Cubit<CropState> {
  final SaveCropUseCase saveCropUseCase;
  final ImagePicker _picker = ImagePicker();

  CropCubit(this.saveCropUseCase) : super(CropInitial());

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        emit(CropReady(File(image.path)));
      } else {
        emit(const CropError("No image selected"));
      }
    } catch (e) {
      emit(CropError("Failed to pick image: $e"));
    }
  }

  void loadImage(File file) {
    emit(CropReady(file));
  }

  Future<void> save(Uint8List imageBytes) async {
    emit(CropSaving());
    try {
      final result = await saveCropUseCase(imageBytes);
      emit(CropSaved(result));
    } catch (e) {
      emit(CropError("Failed to save: $e"));
    }
  }
}
