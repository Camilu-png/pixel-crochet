import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_account_service.dart';
import '../../../core/supabase/supabase_client_provider.dart';

final supabaseAccountServiceProvider = Provider<SupabaseAccountService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseAccountService(client);
});

final supabaseUserProvider = StreamProvider<User?>((ref) {
  final service = ref.watch(supabaseAccountServiceProvider);
  if (service == null) return Stream<User?>.value(null);

  return (() async* {
    yield service.currentUser;
    await for (final event in service.authChanges) {
      yield event.session?.user;
    }
  })();
});
