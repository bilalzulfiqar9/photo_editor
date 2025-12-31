import 'dart:io';
import 'dart:typed_data';

abstract class MarkupRepository {
  Future<File> saveImage(Uint8List imageBytes);
}
