import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class WatermarkState extends Equatable {
  const WatermarkState();

  @override
  List<Object> get props => [];
}

class WatermarkInitial extends WatermarkState {}

class WatermarkReady extends WatermarkState {
  final File file;

  const WatermarkReady(this.file);

  @override
  List<Object> get props => [file];
}

class WatermarkSaving extends WatermarkState {}

class WatermarkSaved extends WatermarkState {
  final File result;

  const WatermarkSaved(this.result);

  @override
  List<Object> get props => [result];
}

class WatermarkError extends WatermarkState {
  final String message;

  const WatermarkError(this.message);

  @override
  List<Object> get props => [message];
}
