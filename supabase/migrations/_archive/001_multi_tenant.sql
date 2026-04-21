-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Multi-Tenant Schema
--  URL pattern : gestiq.com/:tenant_slug/*
--  Isolation   : shared DB + Row Level Security per tenant_id
--  Auth        : Supabase Auth + custom JWT claim "tenant_id"
-- ════════════════════════════════════════════════════════════════════

-- ── Extensions ───────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";   -- for slug search

-- ════════════════════════════════════════════════════════════════════
--  1. TENANTS  (one row = one company / workspace)
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS tenants (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  slug            TEXT        UNIQUE NOT NULL,          -- 'hotel-atlas', 'pharmatech'
  name            TEXT        NOT NULL,
  plan            TEXT        NOT NULL DEFAULT 'starter' CHECK (plan IN ('starter','pro','enterprise')),
  logo_url        TEXT,
  primary_color   TEXT        DEFAULT '#2563EB',
  owner_id        UUID        REFERENCES auth.users(id) ON DELETE SET NULL,
  max_users       INT         NOT NULL DEFAULT 5,
  is_active       BOOLEAN     NOT NULL DEFAULT TRUE,
  trial_ends_at   TIMESTAMPTZ,
  settings        JSONB       NOT NULL DEFAULT '{}',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- slug must be lowercase letters, digits, hyphens only
ALTER TABLE tenants ADD CONSTRAINT tenants_slug_format
  CHECK (slug ~ '^[a-z0-9][a-z0-9\-]{1,62}[a-z0-9]$');

CREATE INDEX idx_tenants_slug ON tenants (slug);

-- ════════════════════════════════════════════════════════════════════
--  2. TENANT_USERS  (many-to-many: user ↔ tenant with role)
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS tenant_users (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   UUID        NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id     UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role        TEXT        NOT NULL DEFAULT 'viewer'
                          CHECK (role IN ('admin','manager','commercial','comptable','viewer')),
  invited_by  UUID        REFERENCES auth.users(id),
  invited_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  accepted_at TIMESTAMPTZ,
  status      TEXT        NOT NULL DEFAULT 'active'
                          CHECK (status IN ('pending','active','revoked')),
  UNIQUE (tenant_id, user_id)
);

CREATE INDEX idx_tenant_users_user    ON tenant_users (user_id);
CREATE INDEX idx_tenant_users_tenant  ON tenant_users (tenant_id);

-- ════════════════════════════════════════════════════════════════════
--  3. HELPER — current tenant from JWT claim
--     Every request must carry  Authorization: Bearer <jwt>
--     where jwt.app_metadata.tenant_id is set by the sign-in hook.
-- ════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION current_tenant_id()
RETURNS UUID
LANGUAGE sql STABLE
AS $$
  SELECT NULLIF(
    current_setting('request.jwt.claims', true)::jsonb
      -> 'app_metadata' ->> 'tenant_id',
    ''
  )::UUID
$$;

-- ════════════════════════════════════════════════════════════════════
--  4. SIGN-IN HOOK — embed tenant_id into JWT app_metadata
--     Called by Supabase auth.users trigger on every sign-in.
--     Picks the FIRST active tenant for simplicity; extend for
--     multi-workspace users by passing tenant_slug from the client.
-- ════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION auth.set_tenant_claim()
RETURNS TRIGGER
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  _tenant_id UUID;
BEGIN
  SELECT tenant_id INTO _tenant_id
  FROM   tenant_users
  WHERE  user_id = NEW.id AND status = 'active'
  ORDER  BY invited_at
  LIMIT  1;

  IF _tenant_id IS NOT NULL THEN
    NEW.raw_app_meta_data :=
      COALESCE(NEW.raw_app_meta_data, '{}'::jsonb)
      || jsonb_build_object('tenant_id', _tenant_id::text);
  END IF;

  RETURN NEW;
END;
$$;

-- Attach hook to Supabase auth.users
DROP TRIGGER IF EXISTS on_auth_user_sign_in ON auth.users;
CREATE TRIGGER on_auth_user_sign_in
  BEFORE UPDATE OF last_sign_in_at ON auth.users
  FOR EACH ROW EXECUTE FUNCTION auth.set_tenant_claim();

-- ════════════════════════════════════════════════════════════════════
--  5. MACRO — adds tenant_id column + RLS policy to any table
-- ════════════════════════════════════════════════════════════════════
CREATE OR REPLACE PROCEDURE add_tenant_isolation(p_table TEXT)
LANGUAGE plpgsql AS $$
BEGIN
  -- add column if missing
  EXECUTE format(
    'ALTER TABLE %I ADD COLUMN IF NOT EXISTS tenant_id UUID
       NOT NULL REFERENCES tenants(id) ON DELETE CASCADE', p_table);

  -- composite index for fast scans
  EXECUTE format(
    'CREATE INDEX IF NOT EXISTS idx_%s_tenant ON %I (tenant_id)', p_table, p_table);

  -- enable RLS
  EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', p_table);
  EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY',  p_table);

  -- SELECT / UPDATE / DELETE: own tenant only
  EXECUTE format(
    'CREATE POLICY tenant_read   ON %I FOR SELECT USING (tenant_id = current_tenant_id())', p_table);
  EXECUTE format(
    'CREATE POLICY tenant_insert ON %I FOR INSERT WITH CHECK (tenant_id = current_tenant_id())', p_table);
  EXECUTE format(
    'CREATE POLICY tenant_update ON %I FOR UPDATE USING (tenant_id = current_tenant_id())', p_table);
  EXECUTE format(
    'CREATE POLICY tenant_delete ON %I FOR DELETE USING (tenant_id = current_tenant_id())', p_table);
END;
$$;

-- ════════════════════════════════════════════════════════════════════
--  6. APPLY ISOLATION to every business table
-- ════════════════════════════════════════════════════════════════════
CALL add_tenant_isolation('clients');
CALL add_tenant_isolation('prospects');
CALL add_tenant_isolation('devis');
CALL add_tenant_isolation('factures');
CALL add_tenant_isolation('contrats');
CALL add_tenant_isolation('paiements');
CALL add_tenant_isolation('depenses');
CALL add_tenant_isolation('fournisseurs');
CALL add_tenant_isolation('domaines');
CALL add_tenant_isolation('hebergements');
CALL add_tenant_isolation('produits');
CALL add_tenant_isolation('team_members');
CALL add_tenant_isolation('automation_rules');
CALL add_tenant_isolation('automation_logs');
CALL add_tenant_isolation('alerts');
CALL add_tenant_isolation('client_subscriptions');
CALL add_tenant_isolation('personal_tasks');

-- ════════════════════════════════════════════════════════════════════
--  7. TENANTS TABLE — public read for slug resolution
--     (UI needs to resolve slug → tenant_id before login)
-- ════════════════════════════════════════════════════════════════════
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;

-- Anyone can read basic tenant info by slug (for login page branding)
CREATE POLICY tenant_public_read ON tenants
  FOR SELECT USING (is_active = TRUE);

-- Only owner or service_role can insert/update
CREATE POLICY tenant_owner_write ON tenants
  FOR ALL USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

-- ════════════════════════════════════════════════════════════════════
--  8. TENANT_USERS — members can read their own tenant's members
-- ════════════════════════════════════════════════════════════════════
ALTER TABLE tenant_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY tu_read ON tenant_users
  FOR SELECT USING (tenant_id = current_tenant_id());

CREATE POLICY tu_manage ON tenant_users
  FOR ALL USING (tenant_id = current_tenant_id());

-- ════════════════════════════════════════════════════════════════════
--  9. FUNCTION — resolve slug to tenant info (used by frontend)
-- ════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION resolve_tenant(p_slug TEXT)
RETURNS TABLE (
  id            UUID,
  slug          TEXT,
  name          TEXT,
  plan          TEXT,
  logo_url      TEXT,
  primary_color TEXT,
  is_active     BOOLEAN
)
LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT id, slug, name, plan, logo_url, primary_color, is_active
  FROM   tenants
  WHERE  slug = lower(p_slug) AND is_active = TRUE
  LIMIT  1;
$$;

-- ════════════════════════════════════════════════════════════════════
--  10. FUNCTION — get user role inside a tenant
-- ════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION get_my_tenant_role(p_tenant_id UUID)
RETURNS TEXT
LANGUAGE sql SECURITY DEFINER STABLE AS $$
  SELECT role FROM tenant_users
  WHERE  user_id   = auth.uid()
  AND    tenant_id = p_tenant_id
  AND    status    = 'active'
  LIMIT  1;
$$;

-- ════════════════════════════════════════════════════════════════════
--  11. FUNCTION — create tenant + owner in one transaction
--      Called when a new company registers on GestiQ
-- ════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION create_tenant_with_owner(
  p_slug    TEXT,
  p_name    TEXT,
  p_plan    TEXT DEFAULT 'starter',
  p_user_id UUID DEFAULT auth.uid()
)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  _tenant_id UUID;
BEGIN
  INSERT INTO tenants (slug, name, plan, owner_id)
  VALUES (lower(p_slug), p_name, p_plan, p_user_id)
  RETURNING id INTO _tenant_id;

  INSERT INTO tenant_users (tenant_id, user_id, role, status, accepted_at)
  VALUES (_tenant_id, p_user_id, 'admin', 'active', NOW());

  -- Embed tenant_id in user's JWT metadata immediately
  UPDATE auth.users
  SET raw_app_meta_data =
    COALESCE(raw_app_meta_data, '{}'::jsonb)
    || jsonb_build_object('tenant_id', _tenant_id::text)
  WHERE id = p_user_id;

  RETURN _tenant_id;
END;
$$;

-- ════════════════════════════════════════════════════════════════════
--  12. FUNCTION — invite member to tenant
-- ════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION invite_tenant_member(
  p_email     TEXT,
  p_role      TEXT DEFAULT 'viewer',
  p_tenant_id UUID DEFAULT current_tenant_id()
)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  _invitee_id UUID;
  _member_id  UUID;
BEGIN
  -- look up existing Supabase user
  SELECT id INTO _invitee_id FROM auth.users WHERE email = p_email LIMIT 1;

  INSERT INTO tenant_users (tenant_id, user_id, role, invited_by, status)
  VALUES (
    p_tenant_id,
    _invitee_id,       -- NULL if user doesn't exist yet (pending invite)
    p_role,
    auth.uid(),
    CASE WHEN _invitee_id IS NULL THEN 'pending' ELSE 'active' END
  )
  ON CONFLICT (tenant_id, user_id) DO UPDATE
    SET role   = EXCLUDED.role,
        status = 'active'
  RETURNING id INTO _member_id;

  RETURN _member_id;
END;
$$;

-- ════════════════════════════════════════════════════════════════════
--  13. UPDATED_AT trigger helper
-- ════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$;

CREATE TRIGGER tenants_updated_at
  BEFORE UPDATE ON tenants
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ════════════════════════════════════════════════════════════════════
--  14. SEED — demo tenant (safe to run multiple times)
-- ════════════════════════════════════════════════════════════════════
INSERT INTO tenants (slug, name, plan, is_active)
VALUES ('demo', 'GestiQ Demo', 'pro', TRUE)
ON CONFLICT (slug) DO NOTHING;
