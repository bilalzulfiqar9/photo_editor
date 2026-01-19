import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

abstract class StitchingDataSource {
  Future<File> stitchImages(List<File> images);
}

class StitchingDataSourceImpl implements StitchingDataSource {
  @override
  Future<File> stitchImages(List<File> images) async {
    if (images.isEmpty) throw Exception("No images selected");

    // Pass paths instead of File objects to Isolate to avoid issues
    final List<String> imagePaths = images.map((e) => e.path).toList();
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;

    return await compute(_stitchIsolate, IsolateInput(imagePaths, tempPath));
  }
}

class IsolateInput {
  final List<String> paths;
  final String tempPath;
  IsolateInput(this.paths, this.tempPath);
}

Future<File> _stitchIsolate(IsolateInput input) async {
  List<img.Image> decodedImages = [];
  int maxWidth = 0;

  // 1. Decode and find Max Width
  for (var path in input.paths) {
    final bytes = await File(path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      decodedImages.add(decoded);
      if (decoded.width > maxWidth) maxWidth = decoded.width;
    }
  }

  if (decodedImages.isEmpty) throw Exception("Could not decode images");

  // 2. Calculate Total Height based on Resized Dimensions
  // Limit max width to avoid OOM and long processing
  const int targetLimit = 1080;
  final int processingWidth = maxWidth > targetLimit ? targetLimit : maxWidth;

  // 2. Calculate Total Height based on Resized Dimensions
  int totalHeight = 0;
  for (var image in decodedImages) {
    if (image.width != processingWidth) {
      // Calculate scaled height: h2 = h1 * (w2 / w1)
      final double resultHeight =
          image.height * (processingWidth / image.width);
      totalHeight += resultHeight.round();
    } else {
      totalHeight += image.height;
    }
  }

  // 3. Create Canvas
  final mergedImage = img.Image(width: processingWidth, height: totalHeight);

  // 4. Composite
  int currentY = 0;
  for (var image in decodedImages) {
    img.Image imageToDraw = image;
    if (image.width != processingWidth) {
      imageToDraw = img.copyResize(image, width: processingWidth);
    }

    img.compositeImage(mergedImage, imageToDraw, dstY: currentY);
    currentY += imageToDraw.height;
  }

  // 5. Save
  final fileName = "${const Uuid().v4()}.jpg";
  final targetFile = File("${input.tempPath}/$fileName");
  await targetFile.writeAsBytes(img.encodeJpg(mergedImage));

  return targetFile;
}
