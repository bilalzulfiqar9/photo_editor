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
  int maxWidth = 0;
  List<_ImageInfo> imageInfos = [];

  // 1. Pass 1: Decode to get dimensions only, then discard memory
  for (var path in input.paths) {
    final bytes = await File(path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      if (decoded.width > maxWidth) maxWidth = decoded.width;
      imageInfos.add(_ImageInfo(path, decoded.width, decoded.height));
    }
  }

  if (imageInfos.isEmpty) throw Exception("Could not decode images");

  // 2. Calculate Dimensions
  const int targetLimit = 1080;
  final int processingWidth = maxWidth > targetLimit ? targetLimit : maxWidth;

  int totalHeight = 0;
  for (var i = 0; i < imageInfos.length; i++) {
    final info = imageInfos[i];
    if (info.width != processingWidth) {
      final double resultHeight = info.height * (processingWidth / info.width);
      final int newHeight = resultHeight.round();
      imageInfos[i] = info.copyWith(
        targetHeight: newHeight,
      ); // Store calculated height
      totalHeight += newHeight;
    } else {
      imageInfos[i] = info.copyWith(targetHeight: info.height);
      totalHeight += info.height;
    }
  }

  // 3. Create Canvas
  final mergedImage = img.Image(width: processingWidth, height: totalHeight);

  // 4. Pass 2: Decode again, resize, and composite one by one
  int currentY = 0;
  for (var info in imageInfos) {
    final bytes = await File(info.path).readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image != null) {
      if (image.width != processingWidth) {
        image = img.copyResize(image, width: processingWidth);
      }

      img.compositeImage(mergedImage, image, dstY: currentY);
      currentY += image.height;
      // Release memory for this image in next iteration loop
    }
  }

  // 5. Save
  final fileName = "${const Uuid().v4()}.jpg";
  final targetFile = File("${input.tempPath}/$fileName");
  await targetFile.writeAsBytes(img.encodeJpg(mergedImage));

  return targetFile;
}

class _ImageInfo {
  final String path;
  final int width;
  final int height;
  final int? targetHeight;

  _ImageInfo(this.path, this.width, this.height, {this.targetHeight});

  _ImageInfo copyWith({int? targetHeight}) {
    return _ImageInfo(
      path,
      width,
      height,
      targetHeight: targetHeight ?? this.targetHeight,
    );
  }
}
