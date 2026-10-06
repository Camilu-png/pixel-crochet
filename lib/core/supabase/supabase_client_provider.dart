import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The app overrides this only after Supabase initializes successfully.
/// Tests, native builds, and local-only web deployments use the null default.
final supabaseClientProvider = Provider<SupabaseClient?>((ref) => null);
