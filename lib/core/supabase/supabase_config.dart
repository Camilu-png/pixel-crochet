import 'dart:convert';

/// Public client configuration for Supabase.
///
/// The anonymous/publishable key is intended to be present in a Flutter Web
/// build. Database access must therefore be protected by Supabase RLS. Secret
/// and service-role keys are rejected so they cannot be accidentally bundled.
class SupabaseConfig {
  const SupabaseConfig._({required this.url, required this.publishableKey});

  factory SupabaseConfig.fromValues({
    required String url,
    required String publishableKey,
  }) {
    return SupabaseConfig._(
      url: url.trim(),
      publishableKey: publishableKey.trim(),
    );
  }

  factory SupabaseConfig.fromEnvironment() {
    return SupabaseConfig.fromValues(
      url: const String.fromEnvironment('SUPABASE_URL'),
      publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    );
  }

  final String url;
  final String publishableKey;

  bool get isConfigured {
    if (url.isEmpty || publishableKey.isEmpty || _isSecretKey(publishableKey)) {
      return false;
    }
    final parsed = Uri.tryParse(url);
    if (parsed == null || !parsed.hasAuthority || parsed.userInfo.isNotEmpty) {
      return false;
    }

    final isHttps = parsed.scheme == 'https';
    final isLocalHttp =
        parsed.scheme == 'http' &&
        const {'localhost', '127.0.0.1', '::1'}.contains(parsed.host);
    return (isHttps || isLocalHttp) &&
        parsed.query.isEmpty &&
        parsed.fragment.isEmpty;
  }

  static bool _isSecretKey(String key) {
    if (key.startsWith('sb_secret_')) return true;

    final parts = key.split('.');
    if (parts.length != 3) return false;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      return payload is Map && payload['role'] == 'service_role';
    } on FormatException {
      return false;
    }
  }
}
