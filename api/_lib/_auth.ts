import { createHash, createHmac, randomBytes, timingSafeEqual } from 'node:crypto';
import { ApiError, errorResponse, methodNotAllowed } from './_errors.js';
import { requireSameOriginUrl, requireTrustedOrigin } from './_validation.js';

const OAUTH_COOKIE_TTL_SECONDS = 600;

export interface AuthConfig {
  publicOrigin: string;
  googleClientId: string;
  googleClientSecret: string;
  callbackUrl: string;
  secureCookies: boolean;
  sessionTtlSeconds: number;
}

export interface AuthStore {
  createOAuthAttempt(input: { stateHash: string; nonce: string; expiresAt: Date }): Promise<void>;
  consumeOAuthAttempt(stateHash: string): Promise<{ nonce: string } | null>;
  upsertGoogleUser(input: { subject: string }): Promise<{ id: string }>;
  createSession(input: { tokenHash: string; userId: string; expiresAt: Date }): Promise<void>;
  findSession(tokenHash: string): Promise<{ userId: string } | null>;
  revokeSession(tokenHash: string): Promise<void>;
  consumeRateLimit(input: {
    keyHash: string;
    windowStart: Date;
    limit: number;
  }): Promise<boolean>;
}

interface AuthDependencies {
  config: AuthConfig;
  store: AuthStore;
  exchangeCode: (
    code: string,
    callbackUrl: string,
    clientId: string,
    clientSecret: string,
  ) => Promise<{ idToken: string }>;
  verifyIdToken: (token: string, nonce: string, clientId: string) => Promise<{ subject: string }>;
}

function randomOpaqueToken(): string {
  return randomBytes(32).toString('base64url');
}

async function enforceRateLimit(
  request: Request,
  action: string,
  limit: number,
  config: AuthConfig,
  store: AuthStore,
): Promise<void> {
  // Vercel overwrites this header with the connecting client IP, preventing spoofed values.
  const clientIp = request.headers.get('x-vercel-forwarded-for');
  if (!clientIp) {
    if (process.env.VERCEL) throw new ApiError(503, 'rate_limit_unavailable');
    return; // Local tests and non-Vercel development have no trusted client IP.
  }
  if (clientIp.length > 128) throw new ApiError(429, 'rate_limit_exceeded');
  const keyHash = createHmac('sha256', config.googleClientSecret)
    .update(`${action}:${clientIp}`)
    .digest('hex');
  const windowMilliseconds = 10 * 60 * 1000;
  const windowStart = new Date(Math.floor(Date.now() / windowMilliseconds) * windowMilliseconds);
  if (!(await store.consumeRateLimit({ keyHash, windowStart, limit }))) {
    throw new ApiError(429, 'rate_limit_exceeded');
  }
}

export function hashOpaqueToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

function cookieName(config: AuthConfig, kind: 'session' | 'oauth_state'): string {
  const suffix = kind === 'session' ? 'session' : 'oauth_state';
  return config.secureCookies ? `__Host-pixel_${suffix}` : `pixel_${suffix}`;
}

function readCookie(request: Request, name: string): string | null {
  const cookie = request.headers.get('cookie');
  if (!cookie) return null;
  for (const part of cookie.split(';')) {
    const separator = part.indexOf('=');
    if (separator < 0 || part.slice(0, separator).trim() !== name) continue;
    return part.slice(separator + 1).trim() || null;
  }
  return null;
}

function constantTimeEquals(left: string, right: string): boolean {
  const leftBytes = Buffer.from(left);
  const rightBytes = Buffer.from(right);
  return leftBytes.length === rightBytes.length && timingSafeEqual(leftBytes, rightBytes);
}

function cookie(config: AuthConfig, kind: 'session' | 'oauth_state', value: string, maxAge: number): string {
  return [
    `${cookieName(config, kind)}=${value}`,
    'Path=/',
    `Max-Age=${maxAge}`,
    'HttpOnly',
    'SameSite=Lax',
    ...(config.secureCookies ? ['Secure'] : []),
  ].join('; ');
}

function json(body: unknown, status = 200): Response {
  return Response.json(body, {
    status,
    headers: { 'cache-control': 'no-store', 'x-content-type-options': 'nosniff' },
  });
}

function redirect(url: string, setCookie: string): Response {
  return new Response(null, {
    status: 302,
    headers: {
      location: url,
      'set-cookie': setCookie,
      'cache-control': 'no-store',
      'referrer-policy': 'no-referrer',
    },
  });
}

export function createAuthHandlers(dependencies: AuthDependencies) {
  const { config, store } = dependencies;
  return {
    start: async (request: Request): Promise<Response> => {
      try {
        if (request.method !== 'GET') return methodNotAllowed('GET');
        requireSameOriginUrl(request, config.publicOrigin);
        await enforceRateLimit(request, 'oauth_start', 10, config, store);
        const state = randomOpaqueToken();
        const nonce = randomOpaqueToken();
        await store.createOAuthAttempt({
          stateHash: hashOpaqueToken(state),
          nonce,
          expiresAt: new Date(Date.now() + OAUTH_COOKIE_TTL_SECONDS * 1000),
        });

        const authorizationUrl = new URL('https://accounts.google.com/o/oauth2/v2/auth');
        authorizationUrl.search = new URLSearchParams({
          client_id: config.googleClientId,
          redirect_uri: config.callbackUrl,
          response_type: 'code',
          scope: 'openid',
          state,
          nonce,
        }).toString();
        return redirect(
          authorizationUrl.toString(),
          cookie(config, 'oauth_state', state, OAUTH_COOKIE_TTL_SECONDS),
        );
      } catch (error) {
        return errorResponse(error);
      }
    },

    callback: async (request: Request): Promise<Response> => {
      try {
        if (request.method !== 'GET') return methodNotAllowed('GET');
        requireSameOriginUrl(request, config.publicOrigin);
        await enforceRateLimit(request, 'oauth_callback', 10, config, store);
        const url = new URL(request.url);
        const code = url.searchParams.get('code');
        const queryState = url.searchParams.get('state');
        const stateCookie = readCookie(request, cookieName(config, 'oauth_state'));
        if (
          !code ||
          !queryState ||
          !stateCookie ||
          !constantTimeEquals(queryState, stateCookie)
        ) {
          throw new ApiError(400, 'invalid_oauth_state');
        }

        const attempt = await store.consumeOAuthAttempt(hashOpaqueToken(stateCookie));
        if (!attempt) throw new ApiError(400, 'invalid_oauth_state');
        const token = await dependencies.exchangeCode(
          code,
          config.callbackUrl,
          config.googleClientId,
          config.googleClientSecret,
        );
        const identity = await dependencies.verifyIdToken(
          token.idToken,
          attempt.nonce,
          config.googleClientId,
        );
        const user = await store.upsertGoogleUser({ subject: identity.subject });
        const sessionToken = randomOpaqueToken();
        const expiresAt = new Date(Date.now() + config.sessionTtlSeconds * 1000);
        await store.createSession({
          tokenHash: hashOpaqueToken(sessionToken),
          userId: user.id,
          expiresAt,
        });

        const response = redirect(
          `${config.publicOrigin}/`,
          cookie(config, 'session', sessionToken, config.sessionTtlSeconds),
        );
        response.headers.append('set-cookie', cookie(config, 'oauth_state', '', 0));
        return response;
      } catch (error) {
        return errorResponse(error);
      }
    },

    me: async (request: Request): Promise<Response> => {
      try {
        if (request.method !== 'GET') return methodNotAllowed('GET');
        requireSameOriginUrl(request, config.publicOrigin);
        const token = readCookie(request, cookieName(config, 'session'));
        if (!token) throw new ApiError(401, 'unauthenticated');
        const session = await store.findSession(hashOpaqueToken(token));
        if (!session) throw new ApiError(401, 'unauthenticated');
        return json({ authenticated: true });
      } catch (error) {
        return errorResponse(error);
      }
    },

    logout: async (request: Request): Promise<Response> => {
      try {
        if (request.method !== 'POST') return methodNotAllowed('POST');
        requireTrustedOrigin(request, config.publicOrigin);
        requireSameOriginUrl(request, config.publicOrigin);
        await enforceRateLimit(request, 'logout', 30, config, store);
        const token = readCookie(request, cookieName(config, 'session'));
        if (token) await store.revokeSession(hashOpaqueToken(token));
        return new Response(null, {
          status: 204,
          headers: {
            'set-cookie': cookie(config, 'session', '', 0),
            'cache-control': 'no-store',
          },
        });
      } catch (error) {
        return errorResponse(error);
      }
    },
  };
}

export function getAuthConfig(environment: NodeJS.ProcessEnv = process.env): AuthConfig {
  const publicOrigin = environment.PUBLIC_ORIGIN;
  const googleClientId = environment.GOOGLE_CLIENT_ID;
  const googleClientSecret = environment.GOOGLE_CLIENT_SECRET;
  if (!publicOrigin || !googleClientId || !googleClientSecret) {
    throw new ApiError(503, 'auth_not_configured');
  }
  let parsedOrigin: URL;
  try {
    parsedOrigin = new URL(publicOrigin);
  } catch {
    throw new ApiError(503, 'auth_not_configured');
  }
  if (
    parsedOrigin.origin !== publicOrigin ||
    (parsedOrigin.protocol !== 'https:' && parsedOrigin.hostname !== 'localhost')
  ) {
    throw new ApiError(503, 'auth_not_configured');
  }
  const sessionTtlSeconds = Number(environment.SESSION_TTL_SECONDS ?? 2_592_000);
  if (!Number.isInteger(sessionTtlSeconds) || sessionTtlSeconds < 300 || sessionTtlSeconds > 2_592_000) {
    throw new ApiError(503, 'auth_not_configured');
  }
  return {
    publicOrigin,
    googleClientId,
    googleClientSecret,
    callbackUrl: `${publicOrigin}/api/auth/google/callback`,
    secureCookies: parsedOrigin.protocol === 'https:',
    sessionTtlSeconds,
  };
}
