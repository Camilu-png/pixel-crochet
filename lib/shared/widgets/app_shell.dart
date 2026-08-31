import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../generated/app_localizations.dart';
import 'app_drawer.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext contex) {
    final l10n = AppLocalizations.of(contex)!;
    final currentPath = GoRouterState.of(contex).uri.path;

    return Scaffold(
      appBar: AppBar(title: Text(_getTitle(currentPath, l10n))),
      drawer: const AppDrawer(),
      body: child,
    );
  }

  String _getTitle(String path, AppLocalizations l10n) {
    switch (path) {
      case '/more-patterns':
        return l10n.morePatternsTitle;
      case '/support':
        return l10n.supportTitle;
      case '/suggest':
        return l10n.suggestTitle;
      default:
        return l10n.appTitle;
    }
  }
}
