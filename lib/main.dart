import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/supabase/supabase_bootstrap.dart';
import 'core/supabase/supabase_client_provider.dart';
import 'core/supabase/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(PathUrlStrategy());
  final config = SupabaseConfig.fromEnvironment();
  SupabaseClient? supabaseClient;
  await initializeSupabaseIfConfigured(
    config,
    isWeb: kIsWeb,
    initialize: (config) async {
      await Supabase.initialize(
        url: config.url,
        publishableKey: config.publishableKey,
      );
      supabaseClient = Supabase.instance.client;
    },
  );
  runApp(
    ProviderScope(
      overrides: [supabaseClientProvider.overrideWithValue(supabaseClient)],
      child: const PixelApp(),
    ),
  );
}
