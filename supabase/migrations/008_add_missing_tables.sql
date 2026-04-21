-- ─────────────────────────────────────────────────────────────
-- 008_add_missing_tables.sql
-- Adds tache_actions + calendrier_events that the frontend
-- references but which never existed in the live DB.
-- Idempotent: safe to re-run.
-- ─────────────────────────────────────────────────────────────

BEGIN;

-- ─── tache_actions ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.tache_actions (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id        uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  titre            text NOT NULL,
  description      text,
  statut           text NOT NULL DEFAULT 'todo'
                     CHECK (statut IN ('todo','en_cours','done')),
  client           text NOT NULL,
  client_avatar    text,
  deal_value       numeric(14,2) NOT NULL DEFAULT 0,
  revenue_at_risk  numeric(14,2) NOT NULL DEFAULT 0,
  deadline         date,
  categorie        text NOT NULL DEFAULT 'suivi'
                     CHECK (categorie IN ('suivi','proposition','livraison','support','admin','relance')),
  stage            text NOT NULL DEFAULT 'actif'
                     CHECK (stage IN ('prospect','actif','a_risque','gagne','perdu')),
  churn_risk       smallint NOT NULL DEFAULT 0 CHECK (churn_risk BETWEEN 0 AND 100),
  overdue_days     integer,
  notes            jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS tache_actions_tenant_idx   ON public.tache_actions (tenant_id);
CREATE INDEX IF NOT EXISTS tache_actions_created_idx  ON public.tache_actions (tenant_id, created_at DESC);
CREATE INDEX IF NOT EXISTS tache_actions_deadline_idx ON public.tache_actions (tenant_id, deadline);

-- ─── calendrier_events ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.calendrier_events (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  titre       text NOT NULL,
  date        date NOT NULL,
  heure       text NOT NULL DEFAULT '09:00',
  type        text NOT NULL DEFAULT 'rdv'
                CHECK (type IN ('rdv','demo','appel','interne','echeance','relance','autre')),
  client      text,
  notes       text,
  done        boolean NOT NULL DEFAULT false,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS calendrier_events_tenant_idx ON public.calendrier_events (tenant_id);
CREATE INDEX IF NOT EXISTS calendrier_events_date_idx   ON public.calendrier_events (tenant_id, date);

-- ─── updated_at + tenant immutability triggers ─────────────
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_tache_actions_updated_at') THEN
    CREATE TRIGGER trg_tache_actions_updated_at
      BEFORE UPDATE ON public.tache_actions
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_lock_tenant_tache_actions') THEN
    CREATE TRIGGER trg_lock_tenant_tache_actions
      BEFORE UPDATE OF tenant_id ON public.tache_actions
      FOR EACH ROW EXECUTE FUNCTION public.prevent_tenant_id_change();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_calendrier_events_updated_at') THEN
    CREATE TRIGGER trg_calendrier_events_updated_at
      BEFORE UPDATE ON public.calendrier_events
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_lock_tenant_calendrier_events') THEN
    CREATE TRIGGER trg_lock_tenant_calendrier_events
      BEFORE UPDATE OF tenant_id ON public.calendrier_events
      FOR EACH ROW EXECUTE FUNCTION public.prevent_tenant_id_change();
  END IF;
END$$;

-- ─── RLS ────────────────────────────────────────────────────
ALTER TABLE public.tache_actions     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tache_actions     FORCE  ROW LEVEL SECURITY;
ALTER TABLE public.calendrier_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calendrier_events FORCE  ROW LEVEL SECURITY;

-- Drop/recreate policies so shape is canonical even if partial ones exist.
DROP POLICY IF EXISTS rls_select_tache_actions ON public.tache_actions;
DROP POLICY IF EXISTS rls_insert_tache_actions ON public.tache_actions;
DROP POLICY IF EXISTS rls_update_tache_actions ON public.tache_actions;
DROP POLICY IF EXISTS rls_delete_tache_actions ON public.tache_actions;

CREATE POLICY rls_select_tache_actions ON public.tache_actions
  FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY rls_insert_tache_actions ON public.tache_actions
  FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_update_tache_actions ON public.tache_actions
  FOR UPDATE USING (tenant_id = current_tenant_id())
  WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_delete_tache_actions ON public.tache_actions
  FOR DELETE USING (tenant_id = current_tenant_id());

DROP POLICY IF EXISTS rls_select_calendrier_events ON public.calendrier_events;
DROP POLICY IF EXISTS rls_insert_calendrier_events ON public.calendrier_events;
DROP POLICY IF EXISTS rls_update_calendrier_events ON public.calendrier_events;
DROP POLICY IF EXISTS rls_delete_calendrier_events ON public.calendrier_events;

CREATE POLICY rls_select_calendrier_events ON public.calendrier_events
  FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY rls_insert_calendrier_events ON public.calendrier_events
  FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_update_calendrier_events ON public.calendrier_events
  FOR UPDATE USING (tenant_id = current_tenant_id())
  WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_delete_calendrier_events ON public.calendrier_events
  FOR DELETE USING (tenant_id = current_tenant_id());

-- ─── Grants for the API role ───────────────────────────────
GRANT SELECT, INSERT, UPDATE, DELETE ON public.tache_actions     TO gestiq_api;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.calendrier_events TO gestiq_api;

COMMIT;
