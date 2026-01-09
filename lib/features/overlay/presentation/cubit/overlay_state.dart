import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class OverlayState extends Equatable {
  const OverlayState();

  @override
  List<Object> get props => [];
}

class OverlayInitial extends OverlayState {}

class OverlayReady extends OverlayState {
  final File file;

  const OverlayReady(this.file);

  @override
  List<Object> get props => [file];
}

class OverlaySaving extends OverlayState {}

class OverlaySaved extends OverlayState {
  final File result;

  const OverlaySaved(this.result);

  @override
  List<Object> get props => [result];
}

class OverlayError extends OverlayState {
  final String message;

  const OverlayError(this.message);

  @override
  List<Object> get props => [message];
}
