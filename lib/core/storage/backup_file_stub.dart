import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<bool> saveBackupFile(String contents) async {
  final path = await FilePicker.platform.saveFile(
    fileName: 'pixel-crochet-backup.json',
    type: FileType.custom,
    allowedExtensions: const ['json'],
    bytes: Uint8List.fromList(utf8.encode(contents)),
  );
  return path != null;
}
