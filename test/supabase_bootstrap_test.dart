import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/supabase/supabase_bootstrap.dart';
import 'package:pixel_crochet/core/supabase/supabase_config.dart';
import 'package:pixel_crochet/core/supabase/supabase_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('initializeSupabaseIfConfigured', () {
    test('keeps the app local when Supabase values are missing', () async {
      var initializationCount = 0;
      final initialized = await initializeSupabaseIfConfigured(
        SupabaseConfig.fromValues(url: '', publishableKey: ''),
        isWeb: true,
        initialize: (_) async => initializationCount++,
      );

      expect(initialized, isFalse);
      expect(initializationCount, 0);
    });

    test('initializes a configured web client exactly once', () async {
      var initializationCount = 0;
      SupabaseConfig? receivedConfig;
      final config = SupabaseConfig.fromValues(
        url: 'https://pixel-crochet.supabase.co',
        publishableKey: 'public-key',
      );

      final initialized = await initializeSupabaseIfConfigured(
        config,
        isWeb: true,
        initialize: (received) async {
          initializationCount++;
          receivedConfig = received;
        },
      );

      expect(initialized, isTrue);
      expect(initializationCount, 1);
      expect(receivedConfig?.url, config.url);
    });

    test('does not initialize cloud services outside web builds', () async {
      var initializationCount = 0;
      final initialized = await initializeSupabaseIfConfigured(
        SupabaseConfig.fromValues(
          url: 'https://pixel-crochet.supabase.co',
          publishableKey: 'public-key',
        ),
        isWeb: false,
        initialize: (_) async => initializationCount++,
      );

      expect(initialized, isFalse);
      expect(initializationCount, 0);
    });

    test(
      'keeps local mode available if Supabase initialization fails',
      () async {
        final initialized = await initializeSupabaseIfConfigured(
          SupabaseConfig.fromValues(
            url: 'https://pixel-crochet.supabase.co',
            publishableKey: 'public-key',
          ),
          isWeb: true,
          initialize: (_) async => throw StateError('unavailable'),
        );

        expect(initialized, isFalse);
      },
    );
  });

  test('the optional client provider stays null in local-only builds', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(supabaseClientProvider), isNull);
  });
}
