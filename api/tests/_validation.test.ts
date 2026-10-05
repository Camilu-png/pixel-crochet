import assert from 'node:assert/strict';
import test from 'node:test';
import { ApiError } from '../_lib/_errors.js';
import { getAuthConfig } from '../_lib/_auth.js';
import { readJsonBody, requireTrustedOrigin } from '../_lib/_validation.js';

test('request JSON parsing enforces the byte limit even without Content-Length', async () => {
  const request = new Request('https://pixelcrochet.example/api/patterns', {
    method: 'POST',
    body: JSON.stringify({ value: 'a'.repeat(40) }),
  });
  await assert.rejects(readJsonBody(request, 16), (error: unknown) => {
    assert.ok(error instanceof ApiError);
    assert.equal(error.status, 413);
    assert.equal(error.code, 'payload_too_large');
    return true;
  });
});

test('request JSON parsing rejects malformed input with a stable client error', async () => {
  const request = new Request('https://pixelcrochet.example/api/patterns', {
    method: 'POST',
    body: '{broken',
  });
  await assert.rejects(readJsonBody(request, 100), (error: unknown) => {
    assert.ok(error instanceof ApiError);
    assert.equal(error.status, 400);
    assert.equal(error.code, 'invalid_json');
    return true;
  });
});

test('mutating requests require the one configured origin and reject missing Origin', () => {
  assert.throws(
    () => requireTrustedOrigin(new Request('https://pixelcrochet.example'), 'https://pixelcrochet.example'),
    (error: unknown) => error instanceof ApiError && error.status === 403,
  );
  assert.throws(
    () => requireTrustedOrigin(
      new Request('https://pixelcrochet.example', { headers: { origin: 'https://attacker.example' } }),
      'https://pixelcrochet.example',
    ),
    (error: unknown) => error instanceof ApiError && error.status === 403,
  );
});

test('OAuth config fails closed for absent secrets and non-HTTPS production origins', () => {
  assert.throws(() => getAuthConfig({}), (error: unknown) => error instanceof ApiError && error.status === 503);
  assert.throws(
    () => getAuthConfig({
      PUBLIC_ORIGIN: 'http://pixelcrochet.example',
      GOOGLE_CLIENT_ID: 'id',
      GOOGLE_CLIENT_SECRET: 'secret',
    }),
    (error: unknown) => error instanceof ApiError && error.status === 503,
  );
  const config = getAuthConfig({
    PUBLIC_ORIGIN: 'https://pixelcrochet.example',
    GOOGLE_CLIENT_ID: 'id',
    GOOGLE_CLIENT_SECRET: 'secret',
  });
  assert.equal(config.secureCookies, true);
  assert.equal(config.callbackUrl, 'https://pixelcrochet.example/api/auth/google/callback');
});
