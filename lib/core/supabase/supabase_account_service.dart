import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAccountService {
  SupabaseAccountService(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  Future<bool> signInWithGoogle({required String redirectTo}) => _client.auth
      .signInWithOAuth(OAuthProvider.google, redirectTo: redirectTo);

  Future<void> signOut() => _client.auth.signOut();
}
