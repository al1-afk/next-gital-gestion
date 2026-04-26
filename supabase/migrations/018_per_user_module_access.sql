-- ================================================================
--  GestiQ — Migration 018: Per-user module access override
--  Date: 2026-04-26
--
--  Adds an `allowed_modules` array on `tenant_users` so each member
--  can have a fine-grained list of accessible modules — overriding
--  the role default. NULL means "fall back to role permissions"
--  (backwards compatible).
-- ================================================================

BEGIN;

ALTER TABLE public.tenant_users
  ADD COLUMN IF NOT EXISTS allowed_modules text[] DEFAULT NULL;

COMMENT ON COLUMN public.tenant_users.allowed_modules IS
  'When NULL: use the role''s default permission map. When set: '
  'this is the exhaustive list of modules the user can access in '
  'the sidebar (e.g. {clients,factures,vehicules}). Admins always '
  'have full access regardless.';

COMMIT;
