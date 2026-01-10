import 'dart:io';
import 'dart:typed_data';

abstract class CropRepository {
  Future<File> saveImage(Uint8List bytes);
}
