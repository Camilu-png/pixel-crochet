import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final l10n = AppLocalizations.of(context)!;
    final brand = context.brand;

    final destination = switch (currentPath) {
      '/more-patterns' => 1,
      '/support' => 2,
      '/suggest' => 3,
      _ => 0,
    };

    return NavigationDrawer(
      selectedIndex: destination,
      onDestinationSelected: (index) {
        Navigator.pop(context);
        switch (index) {
          case 1:
            context.goNamed('more-patterns');
          case 2:
            context.goNamed('support');
          case 3:
            context.goNamed('suggest');
          default:
            context.goNamed('home');
        }
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: brand.yarnGradient,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Image.asset(
                  'assets/favicon/favicon-48x48.png',
                  width: 28,
                  height: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pixel Crochet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      l10n.appTitleTagline,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.grid_view_outlined),
          selectedIcon: const Icon(Icons.grid_view_rounded),
          label: Text(l10n.menuMyPatterns),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.add_circle_outline),
          selectedIcon: const Icon(Icons.add_circle_rounded),
          label: Text(l10n.menuMorePatterns),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
          child: Divider(color: brand.outlineSoft),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.favorite_outline),
          selectedIcon: const Icon(Icons.favorite_rounded),
          label: Text(l10n.menuSupport),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.mail_outline_rounded),
          selectedIcon: const Icon(Icons.mail_rounded),
          label: Text(l10n.menuSuggest),
        ),
      ],
    );
  }
}
