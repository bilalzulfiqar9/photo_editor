import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ResizeState extends Equatable {
  const ResizeState();

  @override
  List<Object?> get props => [];
}

class ResizeInitial extends ResizeState {}

class ResizeLoading extends ResizeState {}

class ResizeReady extends ResizeState {
  final File originalFile;
  final File? compressedFile;
  final Map<String, dynamic> exifData;
  final int originalSize;
  final int? compressedSize;

  const ResizeReady({
    required this.originalFile,
    this.compressedFile,
    this.exifData = const {},
    required this.originalSize,
    this.compressedSize,
  });

  @override
  List<Object?> get props => [
    originalFile,
    compressedFile,
    exifData,
    originalSize,
    compressedSize,
  ];
}

class ResizeError extends ResizeState {
  final String message;

  const ResizeError(this.message);

  @override
  List<Object> get props => [message];
}
