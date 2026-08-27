import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../../../../generated/app_localizations.dart';

Future<void> openUrl(BuildContext context, String url) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    await launchUrl(Uri.parse(url));
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.openUrlMessage)));
  }
}
