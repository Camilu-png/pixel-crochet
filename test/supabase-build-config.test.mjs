import test from 'node:test';
import assert from 'node:assert/strict';
import {
  isSecretSupabaseKey,
  validateSupabaseBuildEnvironment,
} from '../tools/supabase-build-config.mjs';

function jwtWithRole(role) {
  const payload = Buffer.from(JSON.stringify({ role })).toString('base64url');
  return `header.${payload}.signature`;
}

test('rejects Supabase secret and service-role keys before Flutter build', () => {
  assert.equal(isSecretSupabaseKey('sb_secret_example'), true);
  assert.equal(isSecretSupabaseKey(jwtWithRole('service_role')), true);
  assert.throws(
    () =>
      validateSupabaseBuildEnvironment({
        SUPABASE_URL: 'https://example.supabase.co',
        SUPABASE_PUBLISHABLE_KEY: jwtWithRole('service_role'),
      }),
    /Build stopped before Flutter could bundle it/,
  );
});

test('allows publishable keys and fully local builds', () => {
  assert.equal(isSecretSupabaseKey('sb_publishable_example'), false);
  assert.doesNotThrow(() =>
    validateSupabaseBuildEnvironment({
      SUPABASE_URL: 'https://example.supabase.co',
      SUPABASE_PUBLISHABLE_KEY: 'sb_publishable_example',
    }),
  );
  assert.doesNotThrow(() => validateSupabaseBuildEnvironment({}));
});

test('rejects a partially configured build', () => {
  assert.throws(
    () => validateSupabaseBuildEnvironment({ SUPABASE_URL: 'https://example.supabase.co' }),
    /Set both SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY/,
  );
});
