import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class MarkupState extends Equatable {
  const MarkupState();

  @override
  List<Object?> get props => [];
}

class MarkupInitial extends MarkupState {}

class MarkupReady extends MarkupState {
  final File file;
  const MarkupReady(this.file);

  @override
  List<Object> get props => [file];
}

class MarkupSaving extends MarkupState {}

class MarkupSaved extends MarkupState {
  final File result;
  const MarkupSaved(this.result);
  @override
  List<Object> get props => [result];
}

class MarkupError extends MarkupState {
  final String message;
  const MarkupError(this.message);
  @override
  List<Object> get props => [message];
}

// Simple class to hold stroke data
class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double width;

  DrawingStroke(this.points, this.color, this.width);
}

// Simple class for text overlay
class TextOverlay {
  String text;
  Offset position;
  Color color;
  double fontSize;

  TextOverlay(this.text, this.position, this.color, this.fontSize);
}
