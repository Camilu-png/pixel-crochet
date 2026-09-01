import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../generated/app_localizations.dart';

Future<bool> openUrlImpl(BuildContext context, String url) async {
  final l10n = AppLocalizations.of(context)!;
  var launched = false;
  try {
    launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    launched = false;
  }
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.openUrlMessage)));
  }
  return launched;
}
