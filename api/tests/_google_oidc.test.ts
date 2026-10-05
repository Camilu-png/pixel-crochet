import assert from 'node:assert/strict';
import test from 'node:test';
import {
  createRemoteJWKSet,
  customFetch,
  exportJWK,
  generateKeyPair,
  SignJWT,
} from 'jose';
import { createGoogleIdTokenVerifier } from '../_lib/_google_oidc.js';

test('Google ID token verification checks signature, issuer, audience, and nonce', async () => {
  const { privateKey, publicKey } = await generateKeyPair('RS256');
  const publicJwk = await exportJWK(publicKey);
  const jwks = createRemoteJWKSet(new URL('https://www.googleapis.com/oauth2/v3/certs'), {
    [customFetch]: async () =>
      Response.json({ keys: [{ ...publicJwk, kid: 'local-test-key', use: 'sig', alg: 'RS256' }] }),
  });
  const verify = createGoogleIdTokenVerifier(jwks);

  async function token(options: { nonce?: string; audience?: string; issuer?: string } = {}) {
    return new SignJWT({ nonce: options.nonce ?? 'expected-nonce' })
      .setProtectedHeader({ alg: 'RS256', kid: 'local-test-key' })
      .setIssuer(options.issuer ?? 'https://accounts.google.com')
      .setAudience(options.audience ?? 'web-client-id')
      .setSubject('google-subject')
      .setIssuedAt()
      .setExpirationTime('5m')
      .sign(privateKey);
  }

  assert.deepEqual(await verify(await token(), 'expected-nonce', 'web-client-id'), {
    subject: 'google-subject',
  });
  await assert.rejects(verify(await token({ nonce: 'wrong' }), 'expected-nonce', 'web-client-id'));
  await assert.rejects(verify(await token({ audience: 'other-client' }), 'expected-nonce', 'web-client-id'));
  await assert.rejects(verify(await token({ issuer: 'https://attacker.example' }), 'expected-nonce', 'web-client-id'));
});
