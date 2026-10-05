import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<bool> saveBackupFile(String contents) async {
  final blob = web.Blob(
    [contents.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json'),
  );
  final url = web.URL.createObjectURL(blob);
  try {
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = 'pixel-crochet-backup.json';
    anchor.click();
    return true;
  } finally {
    web.URL.revokeObjectURL(url);
  }
}
