import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../generated/app_localizations.dart';
import '../../core/theme/context_extensions.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset('assets/favicon/favicon-48x48.png', height: 48),
                const SizedBox(height: 8),
                Text(
                  'Pixel Crochet',
                  style: TextStyle(
                    color: context.colors.brandDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: Text(l10n.menuMyPatterns),
            selected: currentPath == '/',
            selectedTileColor: context.colors.brandLavender.withValues(
              alpha: 0.15,
            ),
            onTap: () {
              Navigator.pop(context);
              context.goNamed('home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: Text(l10n.menuMorePatterns),
            selected: currentPath == '/more-patterns',
            selectedTileColor: context.colors.brandLavender.withValues(
              alpha: 0.15,
            ),
            onTap: () {
              Navigator.pop(context);
              context.goNamed('more-patterns');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: Text(l10n.menuSupport),
            selected: currentPath == '/support',
            selectedTileColor: context.colors.brandLavender.withValues(
              alpha: 0.15,
            ),
            onTap: () {
              Navigator.pop(context);
              context.goNamed('support');
            },
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(l10n.menuSuggest),
            selected: currentPath == '/suggest',
            selectedTileColor: context.colors.brandLavender.withValues(
              alpha: 0.15,
            ),
            onTap: () {
              Navigator.pop(context);
              context.goNamed('suggest');
            },
          ),
        ],
      ),
    );
  }
}
