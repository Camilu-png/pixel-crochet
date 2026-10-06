import { Buffer } from 'node:buffer';

export function isSecretSupabaseKey(value) {
  const key = value.trim();
  if (key.startsWith('sb_secret_')) return true;

  const parts = key.split('.');
  if (parts.length !== 3) return false;

  try {
    const payload = JSON.parse(Buffer.from(parts[1], 'base64url').toString());
    return payload?.role === 'service_role';
  } catch {
    return false;
  }
}

export function validateSupabaseBuildEnvironment(environment) {
  const key = environment.SUPABASE_PUBLISHABLE_KEY ?? '';
  if (isSecretSupabaseKey(key)) {
    throw new Error(
      'SUPABASE_PUBLISHABLE_KEY contains a secret/service-role key. Build stopped before Flutter could bundle it.',
    );
  }

  const url = environment.SUPABASE_URL ?? '';
  if (Boolean(url.trim()) !== Boolean(key.trim())) {
    throw new Error(
      'Set both SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY, or leave both empty for local-only mode.',
    );
  }
}
