import 'dart:io';
import 'dart:typed_data';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_editor/features/watermark/domain/repositories/watermark_repository.dart';
import 'package:uuid/uuid.dart';

class WatermarkRepositoryImpl implements WatermarkRepository {
  @override
  Future<File> saveImage(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${const Uuid().v4()}.jpg';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);

    try {
      await Gal.putImage(file.path);
    } catch (e) {
      print("Watermark: Error saving to gallery: $e");
    }

    return file;
  }
}
