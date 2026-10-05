CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  google_sub text NOT NULL UNIQUE,
  public_alias text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE oauth_states (
  state_hash char(64) PRIMARY KEY,
  nonce text NOT NULL,
  expires_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX oauth_states_expires_at_idx ON oauth_states (expires_at);

CREATE TABLE sessions (
  token_hash char(64) PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  expires_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX sessions_user_id_idx ON sessions (user_id);
CREATE INDEX sessions_expires_at_idx ON sessions (expires_at);

CREATE TABLE request_rate_limits (
  key_hash char(64) NOT NULL,
  window_start timestamptz NOT NULL,
  request_count integer NOT NULL CHECK (request_count > 0),
  PRIMARY KEY (key_hash, window_start)
);

CREATE INDEX request_rate_limits_window_start_idx ON request_rate_limits (window_start);
