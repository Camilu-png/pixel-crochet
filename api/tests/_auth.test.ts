import assert from 'node:assert/strict';
import test from 'node:test';
import { createAuthHandlers, hashOpaqueToken } from '../_lib/_auth.js';
import { ApiError } from '../_lib/_errors.js';

const config = {
  publicOrigin: 'https://pixelcrochet.example',
  googleClientId: 'client-id',
  googleClientSecret: 'client-secret',
  callbackUrl: 'https://pixelcrochet.example/api/auth/google/callback',
  secureCookies: true,
  sessionTtlSeconds: 60 * 60 * 24 * 30,
};

function setup() {
  const oauthAttempts = new Map<string, { nonce: string; expiresAt: Date }>();
  const sessions = new Map<string, { userId: string; expiresAt: Date }>();
  const users = new Map<string, { id: string; subject: string }>();
  const rateCounts = new Map<string, number>();
  const calls = { exchange: 0, verify: 0, createSession: 0, revoke: 0 };

  const store = {
    async createOAuthAttempt(input: { stateHash: string; nonce: string; expiresAt: Date }) {
      oauthAttempts.set(input.stateHash, { nonce: input.nonce, expiresAt: input.expiresAt });
    },
    async consumeOAuthAttempt(stateHash: string) {
      const attempt = oauthAttempts.get(stateHash);
      oauthAttempts.delete(stateHash);
      if (!attempt || attempt.expiresAt <= new Date()) return null;
      return { nonce: attempt.nonce };
    },
    async upsertGoogleUser(input: { subject: string }) {
      const user = users.get(input.subject) ?? { id: `user-${input.subject}`, subject: input.subject };
      users.set(input.subject, user);
      return user;
    },
    async createSession(input: { tokenHash: string; userId: string; expiresAt: Date }) {
      calls.createSession++;
      sessions.set(input.tokenHash, { userId: input.userId, expiresAt: input.expiresAt });
    },
    async findSession(tokenHash: string) {
      const session = sessions.get(tokenHash);
      if (!session || session.expiresAt <= new Date()) return null;
      return { userId: session.userId };
    },
    async findUser(userId: string) {
      return [...users.values()].find((user) => user.id === userId) ?? null;
    },
    async revokeSession(tokenHash: string) {
      calls.revoke++;
      sessions.delete(tokenHash);
    },
    async consumeRateLimit(input: { keyHash: string; windowStart: Date; limit: number }) {
      const key = `${input.keyHash}:${input.windowStart.toISOString()}`;
      const count = (rateCounts.get(key) ?? 0) + 1;
      rateCounts.set(key, count);
      return count <= input.limit;
    },
  };

  const handlers = createAuthHandlers({
    config,
    store,
    exchangeCode: async () => {
      calls.exchange++;
      return { idToken: 'google-id-token' };
    },
    verifyIdToken: async (_token, nonce) => {
      calls.verify++;
      if (nonce !== 'expected-nonce') throw new ApiError(401, 'google_login_failed');
      return { subject: 'google-subject' };
    },
  });

  return { handlers, oauthAttempts, sessions, calls };
}

test('GET /me rejects absent, forged, and expired sessions without exposing user data', async () => {
  const { handlers, calls, sessions } = setup();
  sessions.set(hashOpaqueToken('expired-token'), {
    userId: 'expired-user',
    expiresAt: new Date(Date.now() - 60_000),
  });
  for (const cookie of [
    undefined,
    '__Host-pixel_session=forged',
    '__Host-pixel_session=expired-token',
  ]) {
    const response = await handlers.me(
      new Request(`${config.publicOrigin}/api/auth/google/me`, {
        headers: cookie ? { cookie } : {},
      }),
    );
    assert.equal(response.status, 401);
    assert.deepEqual(await response.json(), { error: 'unauthenticated' });
  }
  assert.equal(calls.createSession, 0);
});

test('OAuth start creates one-time state and nonce and redirects to Google', async () => {
  const { handlers, oauthAttempts } = setup();
  const response = await handlers.start(
    new Request(`${config.publicOrigin}/api/auth/google/start`),
  );
  assert.equal(response.status, 302);
  const redirect = new URL(response.headers.get('location')!);
  assert.equal(redirect.origin, 'https://accounts.google.com');
  assert.equal(redirect.searchParams.get('client_id'), config.googleClientId);
  assert.equal(redirect.searchParams.get('redirect_uri'), config.callbackUrl);
  assert.equal(redirect.searchParams.get('response_type'), 'code');
  assert.equal(redirect.searchParams.get('scope'), 'openid');
  assert.equal(oauthAttempts.size, 1);
  assert.match(response.headers.get('set-cookie')!, /HttpOnly/);
  assert.match(response.headers.get('set-cookie')!, /Secure/);
  assert.match(response.headers.get('set-cookie')!, /SameSite=Lax/);
});

test('OAuth start applies a per-client fixed-window request limit', async () => {
  const { handlers } = setup();
  const responses = await Promise.all(
    Array.from({ length: 11 }, () =>
      handlers.start(
        new Request(`${config.publicOrigin}/api/auth/google/start`, {
          headers: { 'x-vercel-forwarded-for': '203.0.113.10' },
        }),
      ),
    ),
  );
  assert.equal(responses.filter((response) => response.status === 302).length, 10);
  assert.equal(responses.filter((response) => response.status === 429).length, 1);
});

test('OAuth callback rejects missing or mismatched state before exchanging a code', async () => {
  const { handlers, calls } = setup();
  for (const request of [
    new Request(`${config.callbackUrl}?code=valid&state=present`),
    new Request(`${config.callbackUrl}?code=valid&state=query-state`, {
      headers: { cookie: '__Host-pixel_oauth_state=cookie-state' },
    }),
  ]) {
    const response = await handlers.callback(request);
    assert.equal(response.status, 400);
  }
  assert.equal(calls.exchange, 0);
  assert.equal(calls.createSession, 0);
});

test('OAuth callback consumes state once and rejects an invalid nonce without creating a session', async () => {
  const { handlers, oauthAttempts, calls } = setup();
  const state = 'state-from-cookie';
  const stateHash = hashOpaqueToken(state);
  oauthAttempts.set(stateHash, { nonce: 'wrong-nonce', expiresAt: new Date(Date.now() + 60_000) });

  const response = await handlers.callback(
    new Request(`${config.callbackUrl}?code=valid&state=${state}`, {
      headers: { cookie: `__Host-pixel_oauth_state=${state}` },
    }),
  );

  assert.equal(response.status, 401);
  assert.equal(calls.exchange, 1);
  assert.equal(calls.verify, 1);
  assert.equal(calls.createSession, 0);
  assert.equal(oauthAttempts.size, 0);
});

test('OAuth callback creates an opaque session after verification and cannot be replayed', async () => {
  const { handlers, oauthAttempts, calls, sessions } = setup();
  const state = 'single-use-state';
  oauthAttempts.set(hashOpaqueToken(state), {
    nonce: 'expected-nonce',
    expiresAt: new Date(Date.now() + 60_000),
  });
  const request = new Request(`${config.callbackUrl}?code=valid&state=${state}`, {
    headers: { cookie: `__Host-pixel_oauth_state=${state}` },
  });

  const response = await handlers.callback(request);
  assert.equal(response.status, 302);
  assert.equal(response.headers.get('location'), `${config.publicOrigin}/`);
  assert.equal(calls.createSession, 1);
  assert.equal(sessions.size, 1);
  assert.equal(response.headers.getSetCookie().length, 2);
  assert.match(response.headers.getSetCookie()[0], /__Host-pixel_session=/);
  assert.match(response.headers.getSetCookie()[0], /HttpOnly/);
  assert.match(response.headers.getSetCookie()[0], /Secure/);
  assert.match(response.headers.getSetCookie()[1], /Max-Age=0/);

  const replay = await handlers.callback(request);
  assert.equal(replay.status, 400);
  assert.equal(calls.exchange, 1);
  assert.equal(calls.createSession, 1);
});

test('logout rejects an untrusted origin before revoking a session', async () => {
  const { handlers, calls } = setup();
  const response = await handlers.logout(
    new Request(`${config.publicOrigin}/api/auth/google/logout`, {
      method: 'POST',
      headers: {
        origin: 'https://attacker.example',
        cookie: '__Host-pixel_session=forged',
      },
    }),
  );
  assert.equal(response.status, 403);
  assert.equal(calls.revoke, 0);
});
