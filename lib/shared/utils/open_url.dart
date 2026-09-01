import 'package:flutter/material.dart';
import 'open_url_native.dart'
    if (dart.library.js_interop) 'open_url_web.dart';

Future<bool> openUrl(BuildContext context, String url) {
  return openUrlImpl(context, url);
}
