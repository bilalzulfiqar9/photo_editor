import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class CropState extends Equatable {
  const CropState();

  @override
  List<Object> get props => [];
}

class CropInitial extends CropState {}

class CropReady extends CropState {
  final File file;

  const CropReady(this.file);

  @override
  List<Object> get props => [file];
}

class CropSaving extends CropState {}

class CropSaved extends CropState {
  final File result;

  const CropSaved(this.result);

  @override
  List<Object> get props => [result];
}

class CropError extends CropState {
  final String message;

  const CropError(this.message);

  @override
  List<Object> get props => [message];
}
