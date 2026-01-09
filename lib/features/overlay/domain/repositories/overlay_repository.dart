import 'dart:io';
import 'dart:typed_data';

abstract class OverlayRepository {
  Future<File> saveImage(Uint8List bytes);
}
