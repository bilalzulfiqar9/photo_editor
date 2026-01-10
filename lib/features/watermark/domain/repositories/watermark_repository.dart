import 'dart:io';
import 'dart:typed_data';

abstract class WatermarkRepository {
  Future<File> saveImage(Uint8List bytes);
}
