import 'dart:io';

import 'image_processor.dart';

Future<ImageData> loadImageFromPath(String path) async {
  final bytes = await File(path).readAsBytes();
  return ImageProcessor().loadImageBytes(bytes);
}
