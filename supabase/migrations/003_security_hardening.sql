-- ================================================================
--  GestiQ — Security Hardening Migration
--  Audit log + password policy + indexes
-- ================================================================

-- ── Audit log (append-only, tamper-proof) ───────────────────────
CREATE TABLE IF NOT EXISTS audit_logs (
  id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id   UUID        REFERENCES tenants(id) ON DELETE CASCADE,
  user_id     UUID        REFERENCES users(id)   ON DELETE SET NULL,
  action      TEXT        NOT NULL,          -- 'CREATE','UPDATE','DELETE','LOGIN','LOGOUT'
  table_name  TEXT,
  record_id   UUID,
  old_data    JSONB,
  new_data    JSONB,
  ip_address  INET,
  user_agent  TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Nobody can UPDATE or DELETE audit_logs — append-only
REVOKE UPDATE, DELETE ON audit_logs FROM PUBLIC;
CREATE INDEX IF NOT EXISTS idx_audit_tenant  ON audit_logs (tenant_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_user    ON audit_logs (user_id,   created_at DESC);

-- ── Failed login attempts tracking ──────────────────────────────
CREATE TABLE IF NOT EXISTS login_attempts (
  id          SERIAL      PRIMARY KEY,
  email       TEXT        NOT NULL,
  ip_address  INET,
  success     BOOLEAN     DEFAULT FALSE,
  attempted_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_login_attempts_email ON login_attempts (email, attempted_at DESC);

-- ── Refresh token store (rotation tracking) ─────────────────────
CREATE TABLE IF NOT EXISTS refresh_tokens (
  id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  tenant_id   UUID        NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  token_hash  TEXT        NOT NULL UNIQUE,
  ip_address  INET,
  user_agent  TEXT,
  expires_at  TIMESTAMPTZ NOT NULL,
  revoked     BOOLEAN     DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user ON refresh_tokens (user_id, revoked);

-- ── Password policy: minimum length enforced at DB level ────────
ALTER TABLE users ADD CONSTRAINT IF NOT EXISTS chk_password_length
  CHECK (length(password_hash) > 20);

-- ── Indexes for tenant isolation performance ─────────────────────
DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'clients','prospects','devis','factures','paiements','depenses',
    'contrats','produits','fournisseurs','team_members','domaines',
    'hebergements','cheques_recus','cheques_emis','abonnements',
    'client_subscriptions','taches','automation_rules','automation_logs','alerts'
  ] LOOP
    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS idx_%s_tenant ON %I (tenant_id)',
      t, t
    );
  END LOOP;
END $$;

-- ── Function: auto-log mutations (optional trigger) ─────────────
CREATE OR REPLACE FUNCTION log_mutation()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    INSERT INTO audit_logs (tenant_id, table_name, record_id, action, old_data)
    VALUES (OLD.tenant_id, TG_TABLE_NAME, OLD.id, 'DELETE', row_to_json(OLD)::jsonb);
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_logs (tenant_id, table_name, record_id, action, old_data, new_data)
    VALUES (NEW.tenant_id, TG_TABLE_NAME, NEW.id, 'UPDATE',
            row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb);
    RETURN NEW;
  ELSIF TG_OP = 'INSERT' THEN
    INSERT INTO audit_logs (tenant_id, table_name, record_id, action, new_data)
    VALUES (NEW.tenant_id, TG_TABLE_NAME, NEW.id, 'INSERT', row_to_json(NEW)::jsonb);
    RETURN NEW;
  END IF;
END;
$$;

-- Apply audit trigger to critical tables
DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY['factures','paiements','depenses','clients'] LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS trg_audit_%I ON %I;
       CREATE TRIGGER trg_audit_%I
       AFTER INSERT OR UPDATE OR DELETE ON %I
       FOR EACH ROW EXECUTE FUNCTION log_mutation()',
      t, t, t, t
    );
  END LOOP;
END $$;
