import 'dart:io';
import 'dart:typed_data';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_editor/features/overlay/domain/repositories/overlay_repository.dart';
import 'package:uuid/uuid.dart';

class OverlayRepositoryImpl implements OverlayRepository {
  @override
  Future<File> saveImage(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${const Uuid().v4()}.jpg';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);

    // Save to System Gallery
    try {
      await Gal.putImage(file.path);
    } catch (e) {
      // Ignore gallery save errors, but file is saved locally
      print("Error saving to gallery: $e");
    }

    return file;
  }
}
