import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import '../../../../generated/app_localizations.dart';

Future<bool> openUrlImpl(BuildContext context, String url) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    web.window.open(url, '_blank', 'noopener,noreferrer');
    return true;
  } catch (_) {
    if (!context.mounted) return false;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.openUrlMessage)));
    return false;
  }
}
