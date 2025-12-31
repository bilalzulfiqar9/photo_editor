import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class StitchState extends Equatable {
  const StitchState();

  @override
  List<Object?> get props => [];
}

class StitchInitial extends StitchState {}

class StitchLoading extends StitchState {}

class StitchLoaded extends StitchState {
  final File result;

  const StitchLoaded(this.result);

  @override
  List<Object> get props => [result];
}

class StitchError extends StitchState {
  final String message;

  const StitchError(this.message);

  @override
  List<Object> get props => [message];
}

class ImageSelectionUpdate extends StitchState {
  final List<File> selectedImages;

  const ImageSelectionUpdate(this.selectedImages);

  @override
  List<Object> get props => [selectedImages];
}
