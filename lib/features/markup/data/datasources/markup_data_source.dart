import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

abstract class MarkupDataSource {
  Future<File> saveImage(Uint8List imageBytes);
}

class MarkupDataSourceImpl implements MarkupDataSource {
  @override
  Future<File> saveImage(Uint8List imageBytes) async {
    final directory =
        await getApplicationDocumentsDirectory(); // Or generic storage for gallery
    // For now, save to doc dir, then maybe move to gallery in repo or use dedicated gallery saver.
    // The requirement says "gallery", usually means public gallery.
    // But for "clean architecture", the data source just saves to file.
    // "Gallery" sync can happen later or via a specific "GalleryRepository".

    final fileName = "${const Uuid().v4()}.jpg";
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(imageBytes);
    return file;
  }
}
