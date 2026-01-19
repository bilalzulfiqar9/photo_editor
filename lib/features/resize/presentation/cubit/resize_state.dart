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
  final bool isCompressing;
  final int? originalWidth;
  final int? originalHeight;

  const ResizeReady({
    required this.originalFile,
    this.compressedFile,
    this.exifData = const {},
    required this.originalSize,
    this.compressedSize,
    this.isCompressing = false,
    this.originalWidth,
    this.originalHeight,
  });

  ResizeReady copyWith({
    File? originalFile,
    File? compressedFile,
    Map<String, dynamic>? exifData,
    int? originalSize,
    int? compressedSize,
    bool? isCompressing,
    int? originalWidth,
    int? originalHeight,
  }) {
    return ResizeReady(
      originalFile: originalFile ?? this.originalFile,
      compressedFile: compressedFile ?? this.compressedFile,
      exifData: exifData ?? this.exifData,
      originalSize: originalSize ?? this.originalSize,
      compressedSize: compressedSize ?? this.compressedSize,
      isCompressing: isCompressing ?? this.isCompressing,
      originalWidth: originalWidth ?? this.originalWidth,
      originalHeight: originalHeight ?? this.originalHeight,
    );
  }

  @override
  List<Object?> get props => [
    originalFile,
    compressedFile,
    exifData,
    originalSize,
    compressedSize,
    isCompressing,
    originalWidth,
    originalHeight,
  ];
}

class ResizeError extends ResizeState {
  final String message;

  const ResizeError(this.message);

  @override
  List<Object> get props => [message];
}
