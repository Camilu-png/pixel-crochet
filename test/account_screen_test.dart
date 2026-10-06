import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/supabase/supabase_client_provider.dart';
import 'package:pixel_crochet/features/account/presentation/account_screen.dart';
import 'package:pixel_crochet/generated/app_localizations.dart';

void main() {
  testWidgets('shows local-only guidance when cloud configuration is absent', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [supabaseClientProvider.overrideWithValue(null)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AccountScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cloud backup unavailable'), findsOneWidget);
    expect(
      find.textContaining('Your projects are still saved on this device.'),
      findsOneWidget,
    );
    expect(find.text('Sign in with Google'), findsNothing);
  });
}
