-- ================================================================
--  GestiQ — Login verification codes (2FA-on-login, 6-digit, 10-min)
--  Issued after password validates; required before access token
--  is granted.
-- ================================================================

CREATE TABLE IF NOT EXISTS login_verification_codes (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  tenant_id   UUID        NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  email       TEXT        NOT NULL,
  code_hash   TEXT        NOT NULL,
  attempts    INT         NOT NULL DEFAULT 0,
  used        BOOLEAN     NOT NULL DEFAULT FALSE,
  expires_at  TIMESTAMPTZ NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ip_address  INET,
  user_agent  TEXT
);

CREATE INDEX IF NOT EXISTS idx_login_verif_user    ON login_verification_codes (user_id);
CREATE INDEX IF NOT EXISTS idx_login_verif_email   ON login_verification_codes (email);
CREATE INDEX IF NOT EXISTS idx_login_verif_expires ON login_verification_codes (expires_at);
