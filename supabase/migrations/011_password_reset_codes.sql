-- ================================================================
--  GestiQ — Password reset codes (6-digit code, 10-min expiry)
-- ================================================================

CREATE TABLE IF NOT EXISTS password_reset_codes (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  email       TEXT        NOT NULL,
  code_hash   TEXT        NOT NULL,
  attempts    INT         NOT NULL DEFAULT 0,
  used        BOOLEAN     NOT NULL DEFAULT FALSE,
  expires_at  TIMESTAMPTZ NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ip_address  INET
);

CREATE INDEX IF NOT EXISTS idx_password_reset_user     ON password_reset_codes (user_id);
CREATE INDEX IF NOT EXISTS idx_password_reset_email    ON password_reset_codes (email);
CREATE INDEX IF NOT EXISTS idx_password_reset_expires  ON password_reset_codes (expires_at);
