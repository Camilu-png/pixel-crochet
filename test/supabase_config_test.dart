import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_crochet/core/supabase/supabase_config.dart';

void main() {
  group('SupabaseConfig', () {
    test('leaves cloud services disabled when values are missing', () {
      final config = SupabaseConfig.fromValues(url: '', publishableKey: '');

      expect(config.isConfigured, isFalse);
    });

    test('rejects an incomplete or unsafe endpoint', () {
      expect(
        SupabaseConfig.fromValues(
          url: 'https://project.supabase.co',
          publishableKey: '',
        ).isConfigured,
        isFalse,
      );
      expect(
        SupabaseConfig.fromValues(
          url: 'http://project.supabase.co',
          publishableKey: 'public-key',
        ).isConfigured,
        isFalse,
      );
      expect(
        SupabaseConfig.fromValues(
          url: 'not a url',
          publishableKey: 'public-key',
        ).isConfigured,
        isFalse,
      );
    });

    test('accepts an HTTPS Supabase URL and public key', () {
      final config = SupabaseConfig.fromValues(
        url: 'https://pixel-crochet.supabase.co',
        publishableKey: 'public-key',
      );

      expect(config.isConfigured, isTrue);
      expect(config.url, 'https://pixel-crochet.supabase.co');
      expect(config.publishableKey, 'public-key');
    });

    test('allows localhost for local Supabase development', () {
      expect(
        SupabaseConfig.fromValues(
          url: 'http://127.0.0.1:54321',
          publishableKey: 'public-key',
        ).isConfigured,
        isTrue,
      );
    });

    test('rejects secret and service-role keys from client configuration', () {
      expect(
        SupabaseConfig.fromValues(
          url: 'https://pixel-crochet.supabase.co',
          publishableKey: 'sb_secret_do_not_bundle',
        ).isConfigured,
        isFalse,
      );
      expect(
        SupabaseConfig.fromValues(
          url: 'https://pixel-crochet.supabase.co',
          publishableKey:
              'eyJhbGciOiJub25lIn0.eyJyb2xlIjoic2VydmljZV9yb2xlIn0.signature',
        ).isConfigured,
        isFalse,
      );
    });
  });
}
