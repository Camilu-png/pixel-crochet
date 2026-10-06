import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/sync/sync_providers.dart';
import 'core/sync/sync_state.dart';
import 'features/account/providers/account_provider.dart';
import 'generated/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class PixelApp extends ConsumerWidget {
  const PixelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    ref.listen(supabaseUserProvider, (previous, next) {
      final previousUser = previous?.asData?.value;
      final currentUser = next.asData?.value;
      if (currentUser != null && previousUser?.id != currentUser.id) {
        final repository = ref.read(syncRepositoryProvider);
        if (repository != null) unawaited(repository.syncPending());
      }
      if (currentUser == null && previousUser != null) {
        ref.read(syncStateProvider.notifier).state = SyncState.localOnly;
      }
    });

    return MaterialApp.router(
      title: 'Pixel Crochet',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es')],
    );
  }
}
