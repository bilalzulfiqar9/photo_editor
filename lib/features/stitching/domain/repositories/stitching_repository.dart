import 'dart:io';

abstract class StitchingRepository {
  Future<File> stitchImages(List<File> images);
}
