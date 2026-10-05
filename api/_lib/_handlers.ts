import { createAuthHandlers, getAuthConfig } from './_auth.js';
import { createAuthStore, getSql } from './_db.js';
import { exchangeGoogleCode, verifyGoogleIdToken } from './_google_oidc.js';

export function getAuthHandlers() {
  return createAuthHandlers({
    config: getAuthConfig(),
    store: createAuthStore(),
    exchangeCode: async (code, callbackUrl, clientId, clientSecret) => ({
      idToken: await exchangeGoogleCode(code, callbackUrl, clientId, clientSecret),
    }),
    verifyIdToken: verifyGoogleIdToken,
  });
}

export async function checkDatabaseHealth(): Promise<void> {
  await getSql().query('SELECT 1');
}
