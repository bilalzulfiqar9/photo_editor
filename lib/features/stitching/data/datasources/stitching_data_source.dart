import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

abstract class StitchingDataSource {
  Future<File> stitchImages(List<File> images);
}

class StitchingDataSourceImpl implements StitchingDataSource {
  @override
  Future<File> stitchImages(List<File> images) async {
    if (images.isEmpty) throw Exception("No images selected");

    // 1. Decode all images
    List<img.Image> decodedImages = [];
    int maxWidth = 0;
    int totalHeight = 0;

    for (var file in images) {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        decodedImages.add(decoded);
        if (decoded.width > maxWidth) maxWidth = decoded.width;
        totalHeight += decoded.height;
      }
    }

    if (decodedImages.isEmpty) throw Exception("Could not decode images");

    // 2. Create a new blank image
    final mergedImage = img.Image(width: maxWidth, height: totalHeight);

    // 3. Draw images onto the merged image
    int currentY = 0;
    for (var image in decodedImages) {
      // Resize if width doesn't match (optional, but good for consistency)
      // For now, let's just center or stretch?
      // Simple strategy: Just draw securely. Best is to resize to maxWidth.

      img.Image imageToDraw = image;
      if (image.width != maxWidth) {
        imageToDraw = img.copyResize(image, width: maxWidth);
      }

      img.compositeImage(mergedImage, imageToDraw, dstY: currentY);
      currentY += imageToDraw.height;
    }

    // 4. Save to temporary file
    final tempDir = await getTemporaryDirectory();
    final fileName = "${const Uuid().v4()}.jpg";
    final targetFile = File("${tempDir.path}/$fileName");

    await targetFile.writeAsBytes(img.encodeJpg(mergedImage));

    return targetFile;
  }
}
