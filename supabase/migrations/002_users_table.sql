-- ================================================================
--  GestiQ — Users table (pure PostgreSQL, no Supabase auth)
-- ================================================================

CREATE TABLE IF NOT EXISTS users (
  id            UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  email         TEXT        UNIQUE NOT NULL,
  password_hash TEXT        NOT NULL,
  name          TEXT,
  avatar_url    TEXT,
  is_active     BOOLEAN     DEFAULT TRUE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);

-- Mettre à jour la référence owner_id dans tenants
-- (déjà défini dans 001, mais ici on retire la dépendance auth.users)
ALTER TABLE tenants
  DROP CONSTRAINT IF EXISTS tenants_owner_id_fkey;

ALTER TABLE tenants
  ADD CONSTRAINT tenants_owner_id_fkey
  FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE SET NULL;

-- Mettre à jour tenant_users
ALTER TABLE tenant_users
  DROP CONSTRAINT IF EXISTS tenant_users_user_id_fkey;

ALTER TABLE tenant_users
  ADD CONSTRAINT tenant_users_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE tenant_users
  DROP CONSTRAINT IF EXISTS tenant_users_invited_by_fkey;

ALTER TABLE tenant_users
  ADD CONSTRAINT tenant_users_invited_by_fkey
  FOREIGN KEY (invited_by) REFERENCES users(id) ON DELETE SET NULL;

-- Seed : compte admin demo
INSERT INTO users (email, password_hash, name)
VALUES (
  'admin@demo.com',
  -- hash de 'demo1234' (bcrypt)
  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J4bCf1.Oa',
  'Admin Demo'
) ON CONFLICT (email) DO NOTHING;
