import { neon } from '@neondatabase/serverless';
import { ApiError } from './_errors.js';
import type { AuthStore } from './_auth.js';

type NeonSql = ReturnType<typeof neon>;
let sqlClient: NeonSql | undefined;

type DbRow = Record<string, unknown>;

async function queryRows(sql: NeonSql, statement: string, parameters: unknown[] = []): Promise<DbRow[]> {
  const result: unknown = await sql.query(statement, parameters);
  if (Array.isArray(result)) return result as DbRow[];
  if (result && typeof result === 'object' && 'rows' in result && Array.isArray(result.rows)) {
    return result.rows as DbRow[];
  }
  return [];
}

export function getSql(): NeonSql {
  if (sqlClient) return sqlClient;
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) throw new ApiError(503, 'database_unavailable');
  sqlClient = neon(connectionString);
  return sqlClient;
}

export function createAuthStore(sql = getSql()): AuthStore {
  return {
    async createOAuthAttempt(input) {
      await sql.query('DELETE FROM oauth_states WHERE expires_at <= now()');
      await sql.query(
        'INSERT INTO oauth_states (state_hash, nonce, expires_at) VALUES ($1, $2, $3)',
        [input.stateHash, input.nonce, input.expiresAt.toISOString()],
      );
    },
    async consumeOAuthAttempt(stateHash) {
      const result = await queryRows(sql,
        'DELETE FROM oauth_states WHERE state_hash = $1 AND expires_at > now() RETURNING nonce',
        [stateHash],
      );
      return result.length === 0 ? null : { nonce: String(result[0].nonce) };
    },
    async upsertGoogleUser(input) {
      const result = await queryRows(sql,
        `INSERT INTO users (google_sub) VALUES ($1)
         ON CONFLICT (google_sub) DO UPDATE SET google_sub = EXCLUDED.google_sub
         RETURNING id`,
        [input.subject],
      );
      return { id: String(result[0].id) };
    },
    async createSession(input) {
      await sql.query(
        'INSERT INTO sessions (token_hash, user_id, expires_at) VALUES ($1, $2, $3)',
        [input.tokenHash, input.userId, input.expiresAt.toISOString()],
      );
    },
    async findSession(tokenHash) {
      const result = await queryRows(sql,
        'SELECT user_id FROM sessions WHERE token_hash = $1 AND expires_at > now()',
        [tokenHash],
      );
      return result.length === 0 ? null : { userId: String(result[0].user_id) };
    },
    async revokeSession(tokenHash) {
      await sql.query('DELETE FROM sessions WHERE token_hash = $1', [tokenHash]);
    },
    async consumeRateLimit(input) {
      const result = await queryRows(
        sql,
        `INSERT INTO request_rate_limits (key_hash, window_start, request_count)
         VALUES ($1, $2, 1)
         ON CONFLICT (key_hash, window_start)
         DO UPDATE SET request_count = request_rate_limits.request_count + 1
         RETURNING request_count`,
        [input.keyHash, input.windowStart.toISOString()],
      );
      await sql.query(
        'DELETE FROM request_rate_limits WHERE window_start < now() - interval \'1 day\'',
      );
      return Number(result[0]?.request_count ?? input.limit + 1) <= input.limit;
    },
  };
}
