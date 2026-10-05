import { timingSafeEqual } from 'node:crypto';
import { createRemoteJWKSet, jwtVerify } from 'jose';
import { ApiError } from './_errors.js';

const googleJwks = createRemoteJWKSet(
  new URL('https://www.googleapis.com/oauth2/v3/certs'),
);
const GOOGLE_ISSUERS = ['https://accounts.google.com', 'accounts.google.com'];

export async function exchangeGoogleCode(
  code: string,
  callbackUrl: string,
  clientId: string,
  clientSecret: string,
): Promise<string> {
  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      code,
      client_id: clientId,
      client_secret: clientSecret,
      redirect_uri: callbackUrl,
      grant_type: 'authorization_code',
    }),
    signal: AbortSignal.timeout(10_000),
  });
  if (!response.ok) throw new ApiError(401, 'google_login_failed');
  const result: unknown = await response.json();
  if (
    !result ||
    typeof result !== 'object' ||
    !('id_token' in result) ||
    typeof result.id_token !== 'string'
  ) {
    throw new ApiError(401, 'google_login_failed');
  }
  return result.id_token;
}

export function createGoogleIdTokenVerifier(jwks = googleJwks) {
  return async function verifyGoogleIdToken(
    token: string,
    expectedNonce: string,
    clientId: string,
  ): Promise<{ subject: string }> {
    try {
      const { payload } = await jwtVerify(token, jwks, {
        issuer: GOOGLE_ISSUERS,
        audience: clientId,
        algorithms: ['RS256'],
        requiredClaims: ['sub', 'iss', 'aud', 'exp', 'iat', 'nonce'],
      });
      if (typeof payload.sub !== 'string' || typeof payload.nonce !== 'string') {
        throw new ApiError(401, 'google_login_failed');
      }
      const actualNonce = Buffer.from(payload.nonce);
      const nonce = Buffer.from(expectedNonce);
      if (actualNonce.length !== nonce.length || !timingSafeEqual(actualNonce, nonce)) {
        throw new ApiError(401, 'google_login_failed');
      }
      return { subject: payload.sub };
    } catch {
      throw new ApiError(401, 'google_login_failed');
    }
  };
}

export const verifyGoogleIdToken = createGoogleIdTokenVerifier();
