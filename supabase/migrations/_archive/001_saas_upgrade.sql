-- ============================================================
-- 001_saas_upgrade.sql
-- SaaS upgrade: automation engine, alerts, subscriptions, RBAC
-- Run in Supabase SQL editor or via `supabase db push`
-- ============================================================

-- ── Enable UUID extension (already enabled on Supabase) ──────
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ════════════════════════════════════════════════════════════
-- 1. AUTOMATION RULES
-- ════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.automation_rules (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  user_id          UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  label            TEXT        NOT NULL,
  description      TEXT,
  enabled          BOOLEAN     NOT NULL DEFAULT true,
  trigger_type     TEXT        NOT NULL,
  trigger_config   JSONB       NOT NULL DEFAULT '{}',
  conditions       JSONB       NOT NULL DEFAULT '[]',
  actions          JSONB       NOT NULL DEFAULT '[]',
  runs_total       INTEGER     NOT NULL DEFAULT 0,
  last_run_at      TIMESTAMPTZ
);

-- Trigger types: invoice_overdue | quote_accepted | subscription_expiring
--   | prospect_idle | domain_expiring | payment_received

ALTER TABLE public.automation_rules ENABLE ROW LEVEL SECURITY;
CREATE POLICY "automation_rules_owner" ON public.automation_rules
  USING (auth.uid() = user_id);

-- ════════════════════════════════════════════════════════════
-- 2. AUTOMATION LOGS
-- ════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.automation_logs (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  rule_id        UUID        REFERENCES public.automation_rules(id) ON DELETE SET NULL,
  user_id        UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  trigger_ref    TEXT,
  trigger_table  TEXT,
  action_type    TEXT        NOT NULL,
  action_result  JSONB,
  status         TEXT        NOT NULL DEFAULT 'pending'
                 CHECK (status IN ('pending','success','failed')),
  error_message  TEXT,
  executed_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.automation_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "automation_logs_owner" ON public.automation_logs
  USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS automation_logs_rule_id_idx ON public.automation_logs(rule_id);
CREATE INDEX IF NOT EXISTS automation_logs_executed_at_idx ON public.automation_logs(executed_at DESC);

-- ════════════════════════════════════════════════════════════
-- 3. ALERTS (smart warnings)
-- ════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.alerts (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  user_id      UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type         TEXT        NOT NULL,
  priority     TEXT        NOT NULL DEFAULT 'medium'
               CHECK (priority IN ('low','medium','critical')),
  title        TEXT        NOT NULL,
  message      TEXT,
  entity_id    TEXT,
  entity_type  TEXT,
  is_read      BOOLEAN     NOT NULL DEFAULT false,
  is_resolved  BOOLEAN     NOT NULL DEFAULT false
);

ALTER TABLE public.alerts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "alerts_owner" ON public.alerts
  USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS alerts_user_unread_idx ON public.alerts(user_id, is_read) WHERE NOT is_read;

-- ════════════════════════════════════════════════════════════
-- 4. CLIENT SUBSCRIPTIONS (recurring revenue engine)
-- ════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.client_subscriptions (
  id                          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),
  user_id                     UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  client_id                   UUID        REFERENCES public.clients(id) ON DELETE SET NULL,
  nom                         TEXT        NOT NULL,
  montant                     NUMERIC(12,2) NOT NULL DEFAULT 0,
  cycle                       TEXT        NOT NULL DEFAULT 'mensuel'
                              CHECK (cycle IN ('mensuel','trimestriel','annuel')),
  montant_mensuel             NUMERIC(12,2) GENERATED ALWAYS AS (
    CASE cycle
      WHEN 'mensuel'      THEN montant
      WHEN 'trimestriel'  THEN montant / 3
      WHEN 'annuel'       THEN montant / 12
    END
  ) STORED,
  date_debut                  DATE        NOT NULL,
  date_prochaine_facturation  DATE        NOT NULL,
  statut                      TEXT        NOT NULL DEFAULT 'actif'
                              CHECK (statut IN ('actif','pause','annule','impaye')),
  date_annulation             DATE,
  annulation_raison           TEXT,
  facture_auto                BOOLEAN     NOT NULL DEFAULT false
);

ALTER TABLE public.client_subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "subscriptions_owner" ON public.client_subscriptions
  USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS client_subscriptions_user_statut ON public.client_subscriptions(user_id, statut);
CREATE INDEX IF NOT EXISTS client_subscriptions_next_billing ON public.client_subscriptions(date_prochaine_facturation)
  WHERE statut = 'actif';

-- ════════════════════════════════════════════════════════════
-- 5. WORKSPACE MEMBERS (multi-user / RBAC)
-- ════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.workspace_members (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  workspace_id UUID        NOT NULL,   -- owner's user_id acting as workspace
  member_email TEXT        NOT NULL,
  member_id    UUID        REFERENCES auth.users(id) ON DELETE SET NULL,
  role         TEXT        NOT NULL DEFAULT 'viewer'
               CHECK (role IN ('admin','manager','commercial','comptable','viewer')),
  permissions  JSONB       NOT NULL DEFAULT '{}',
  invited_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  accepted_at  TIMESTAMPTZ,
  status       TEXT        NOT NULL DEFAULT 'pending'
               CHECK (status IN ('pending','active','revoked')),
  UNIQUE(workspace_id, member_email)
);

ALTER TABLE public.workspace_members ENABLE ROW LEVEL SECURITY;

-- Workspace owner can manage their own workspace
CREATE POLICY "workspace_owner_manage" ON public.workspace_members
  USING (auth.uid() = workspace_id);

-- Invited member can see their own invitation
CREATE POLICY "workspace_member_self" ON public.workspace_members
  FOR SELECT USING (auth.uid() = member_id);

CREATE INDEX IF NOT EXISTS workspace_members_email_idx ON public.workspace_members(member_email);
CREATE INDEX IF NOT EXISTS workspace_members_workspace_idx ON public.workspace_members(workspace_id);

-- ════════════════════════════════════════════════════════════
-- 6. HELPER VIEWS
-- ════════════════════════════════════════════════════════════

-- MRR summary per user
CREATE OR REPLACE VIEW public.v_mrr_summary AS
SELECT
  user_id,
  SUM(montant_mensuel)                                                      AS mrr,
  COUNT(*) FILTER (WHERE statut = 'actif')                                  AS active_count,
  COUNT(*) FILTER (WHERE statut = 'annule')                                 AS churned_count,
  COUNT(*) FILTER (WHERE statut = 'impaye')                                 AS unpaid_count,
  COUNT(*) FILTER (WHERE statut = 'pause')                                  AS paused_count,
  ROUND(
    COUNT(*) FILTER (WHERE statut = 'annule')::NUMERIC
    / NULLIF(COUNT(*), 0) * 100, 1
  )                                                                          AS churn_rate_pct
FROM public.client_subscriptions
GROUP BY user_id;

-- Subscriptions due in the next 30 days
CREATE OR REPLACE VIEW public.v_subscriptions_due AS
SELECT cs.*, c.nom AS client_nom
FROM public.client_subscriptions cs
LEFT JOIN public.clients c ON c.id = cs.client_id
WHERE cs.statut = 'actif'
  AND cs.date_prochaine_facturation <= (CURRENT_DATE + INTERVAL '30 days');

-- ════════════════════════════════════════════════════════════
-- 7. AUTO-ALERT FUNCTION (called by cron Edge Function)
-- ════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.generate_system_alerts(p_user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  inserted INTEGER := 0;
  rec      RECORD;
BEGIN
  -- Overdue invoices (>7 days)
  FOR rec IN
    SELECT id, numero, (montant_ttc - montant_paye) AS remaining,
           CURRENT_DATE - date_echeance::DATE         AS days_overdue
    FROM public.factures
    WHERE user_id = p_user_id
      AND statut IN ('impayee','partielle')
      AND date_echeance IS NOT NULL
      AND date_echeance::DATE < CURRENT_DATE - INTERVAL '7 days'
  LOOP
    INSERT INTO public.alerts (user_id, type, priority, title, message, entity_id, entity_type)
    SELECT p_user_id,
           'invoice_overdue',
           CASE WHEN rec.days_overdue > 30 THEN 'critical' ELSE 'medium' END,
           'Facture impayée — ' || rec.numero,
           rec.remaining || ' MAD · ' || rec.days_overdue || 'j de retard',
           rec.id::TEXT,
           'facture'
    WHERE NOT EXISTS (
      SELECT 1 FROM public.alerts
      WHERE user_id = p_user_id AND entity_id = rec.id::TEXT AND type = 'invoice_overdue'
        AND NOT is_resolved
    );
    inserted := inserted + 1;
  END LOOP;

  -- Subscriptions expiring in 7 days
  FOR rec IN
    SELECT id, nom, date_prochaine_facturation
    FROM public.client_subscriptions
    WHERE user_id = p_user_id
      AND statut = 'actif'
      AND date_prochaine_facturation <= CURRENT_DATE + INTERVAL '7 days'
      AND date_prochaine_facturation >= CURRENT_DATE
  LOOP
    INSERT INTO public.alerts (user_id, type, priority, title, message, entity_id, entity_type)
    SELECT p_user_id,
           'subscription_renewal',
           'medium',
           'Renouvellement dans 7j — ' || rec.nom,
           'Échéance le ' || rec.date_prochaine_facturation,
           rec.id::TEXT,
           'subscription'
    WHERE NOT EXISTS (
      SELECT 1 FROM public.alerts
      WHERE user_id = p_user_id AND entity_id = rec.id::TEXT AND type = 'subscription_renewal'
        AND NOT is_resolved
    );
    inserted := inserted + 1;
  END LOOP;

  RETURN inserted;
END;
$$;
