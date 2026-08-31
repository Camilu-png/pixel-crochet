import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../../../../generated/app_localizations.dart';

Future<bool> openUrl(BuildContext context, String url) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    final result = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    return result;
  } catch (_) {
    if (!context.mounted) return false;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.openUrlMessage)));
    return false;
  }
}
