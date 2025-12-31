import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_editor/features/stitching/domain/usecases/stitch_images_usecase.dart';
import 'stitch_state.dart';

class StitchCubit extends Cubit<StitchState> {
  final StitchImagesUseCase stitchImagesUseCase;
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];

  StitchCubit(this.stitchImagesUseCase) : super(StitchInitial());

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        _selectedImages.addAll(images.map((e) => File(e.path)));
        emit(ImageSelectionUpdate(List.from(_selectedImages)));
      }
    } catch (e) {
      emit(StitchError("Failed to pick images: $e"));
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      emit(ImageSelectionUpdate(List.from(_selectedImages)));
    }
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final File item = _selectedImages.removeAt(oldIndex);
    _selectedImages.insert(newIndex, item);
    emit(ImageSelectionUpdate(List.from(_selectedImages)));
  }

  Future<void> stitch() async {
    if (_selectedImages.length < 2) {
      emit(const StitchError("Please select at least 2 images"));
      // Re-emit selection so UI doesn't get stuck in error state
      emit(ImageSelectionUpdate(List.from(_selectedImages)));
      return;
    }

    emit(StitchLoading());
    try {
      final File result = await stitchImagesUseCase(_selectedImages);
      emit(StitchLoaded(result));
    } catch (e) {
      emit(StitchError(e.toString()));
      emit(ImageSelectionUpdate(List.from(_selectedImages)));
    }
  }

  void reset() {
    _selectedImages.clear();
    emit(StitchInitial());
  }
}
