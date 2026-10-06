import 'package:flutter/foundation.dart';

import 'supabase_config.dart';

typedef SupabaseInitializer = Future<void> Function(SupabaseConfig config);

Future<bool> initializeSupabaseIfConfigured(
  SupabaseConfig config, {
  required bool isWeb,
  required SupabaseInitializer initialize,
}) async {
  if (!isWeb || !config.isConfigured) return false;
  try {
    await initialize(config);
    return true;
  } catch (_) {
    debugPrint('Supabase could not initialize; continuing in local mode.');
    return false;
  }
}
