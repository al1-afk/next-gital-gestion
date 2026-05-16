-- ================================================================
--  GestiQ — Migration 023: Module Guides (Playbook onboarding client)
--  Date: 2026-05-16
--
--  Crée le module "Guides" — système d'onboarding client en 6 étapes
--  pour Next Gital (et tout autre tenant). Inclut la table tenant_vision
--  pour le Primary Aim (page /vision admin-only).
--
--  Tables créées :
--    - guide_steps              (6 étapes par tenant)
--    - guide_templates          (messages copiables : WA / Email)
--    - guide_checklists         (items à cocher par étape)
--    - guide_checklist_state    (état coché par utilisateur)
--    - guide_template_renders   (historique d'usage des templates)
--    - guide_discovery_questions (formulaire de découverte 8Q)
--    - tenant_vision            (Primary Aim + objectif stratégique)
--
--  Conformité ARCHITECTURE_TENANT.md :
--    - tenant_id NOT NULL FK ON DELETE CASCADE
--    - index (tenant_id) + (tenant_id, created_at DESC) si pertinent
--    - trigger prevent_tenant_id_change
--    - ENABLE + FORCE ROW LEVEL SECURITY
--    - 4 policies (SELECT/INSERT/UPDATE/DELETE) sur tenant_id
--    - GRANT au rôle gestiq_api
--
--  Idempotent. Safe to re-run.
-- ================================================================

BEGIN;

-- ────────────────────────────────────────────────────────────────
-- 1. guide_steps — les 6 étapes du playbook (par tenant)
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.guide_steps (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  step_number   int         NOT NULL CHECK (step_number BETWEEN 1 AND 12),
  step_key      text        NOT NULL,
  title         text        NOT NULL,
  subtitle      text,
  icon          text,
  timer_label   text,
  color_hex     text        NOT NULL DEFAULT '#2563EB',
  content_md    text,
  created_at    timestamptz NOT NULL DEFAULT NOW(),
  updated_at    timestamptz NOT NULL DEFAULT NOW(),
  UNIQUE (tenant_id, step_key)
);
CREATE INDEX IF NOT EXISTS idx_guide_steps_tenant ON public.guide_steps (tenant_id, step_number);

-- ────────────────────────────────────────────────────────────────
-- 2. guide_templates — messages copiables (WhatsApp / Email)
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.guide_templates (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  step_id       uuid        REFERENCES public.guide_steps(id) ON DELETE CASCADE,
  template_key  text        NOT NULL,
  channel       text        NOT NULL DEFAULT 'general'
                              CHECK (channel IN ('whatsapp','email','sms','general','instagram')),
  label         text        NOT NULL,
  content       text        NOT NULL,
  variables     jsonb       NOT NULL DEFAULT '[]'::jsonb,
  ordre         int         NOT NULL DEFAULT 0,
  created_at    timestamptz NOT NULL DEFAULT NOW(),
  updated_at    timestamptz NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_guide_templates_tenant ON public.guide_templates (tenant_id, step_id, ordre);

-- ────────────────────────────────────────────────────────────────
-- 3. guide_checklists — items à cocher (config one-time ou récurrent)
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.guide_checklists (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  step_id       uuid        REFERENCES public.guide_steps(id) ON DELETE CASCADE,
  item_order    int         NOT NULL,
  item_text     text        NOT NULL,
  is_one_time   boolean     NOT NULL DEFAULT false,
  created_at    timestamptz NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_guide_checklists_tenant ON public.guide_checklists (tenant_id, step_id, item_order);

-- ────────────────────────────────────────────────────────────────
-- 4. guide_checklist_state — état coché par utilisateur
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.guide_checklist_state (
  id                 uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id          uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  user_id            uuid        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  checklist_item_id  uuid        NOT NULL REFERENCES public.guide_checklists(id) ON DELETE CASCADE,
  is_checked         boolean     NOT NULL DEFAULT false,
  checked_at         timestamptz,
  UNIQUE (user_id, checklist_item_id)
);
CREATE INDEX IF NOT EXISTS idx_guide_checklist_state_tenant ON public.guide_checklist_state (tenant_id, user_id);

-- ────────────────────────────────────────────────────────────────
-- 5. guide_template_renders — historique d'usage des templates
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.guide_template_renders (
  id                uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  user_id           uuid        REFERENCES public.users(id) ON DELETE SET NULL,
  client_id         uuid        REFERENCES public.clients(id) ON DELETE SET NULL,
  prospect_id       uuid        REFERENCES public.prospects(id) ON DELETE SET NULL,
  template_id       uuid        REFERENCES public.guide_templates(id) ON DELETE SET NULL,
  channel           text,
  rendered_content  text        NOT NULL,
  created_at        timestamptz NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_guide_template_renders_tenant ON public.guide_template_renders (tenant_id, created_at DESC);

-- ────────────────────────────────────────────────────────────────
-- 6. guide_discovery_questions — formulaire de découverte (8Q)
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.guide_discovery_questions (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  question_order  int         NOT NULL,
  question_text   text        NOT NULL,
  question_why    text,
  input_type      text        NOT NULL DEFAULT 'text'
                                CHECK (input_type IN ('text','select','textarea','budget_range','multi','number','date')),
  options         jsonb       NOT NULL DEFAULT '[]'::jsonb,
  is_required     boolean     NOT NULL DEFAULT true,
  created_at      timestamptz NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_guide_discovery_questions_tenant
  ON public.guide_discovery_questions (tenant_id, question_order);

-- ────────────────────────────────────────────────────────────────
-- 7. tenant_vision — Primary Aim + objectif stratégique (page /vision)
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.tenant_vision (
  id                      uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id               uuid          NOT NULL UNIQUE REFERENCES public.tenants(id) ON DELETE CASCADE,
  primary_aim             text,
  lifestyle_target        text,
  why_statement           text,
  monthly_revenue_cap     numeric(12,2),
  max_hours_week          int,
  strategic_objective     text,
  monthly_target          numeric(12,2),
  monthly_target_projets  int,
  target_conversion_rate  numeric(5,2),
  target_workspaces       int,
  target_avis_google      int,
  created_at              timestamptz   NOT NULL DEFAULT NOW(),
  updated_at              timestamptz   NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_tenant_vision_tenant ON public.tenant_vision (tenant_id);

-- ────────────────────────────────────────────────────────────────
-- TRIGGERS : updated_at + tenant_id immutability
-- ────────────────────────────────────────────────────────────────
DO $$
DECLARE
  t text;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
    'guide_steps','guide_templates','guide_checklists','guide_checklist_state',
    'guide_template_renders','guide_discovery_questions','tenant_vision'
  ])
  LOOP
    -- updated_at (uniquement sur tables avec colonne updated_at)
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = t AND column_name = 'updated_at'
    ) THEN
      EXECUTE format(
        'DROP TRIGGER IF EXISTS trg_%I_updated_at ON public.%I', t, t
      );
      EXECUTE format(
        'CREATE TRIGGER trg_%I_updated_at BEFORE UPDATE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.set_updated_at()',
        t, t
      );
    END IF;
    -- tenant_id immutability
    EXECUTE format(
      'DROP TRIGGER IF EXISTS trg_lock_tenant_%I ON public.%I', t, t
    );
    EXECUTE format(
      'CREATE TRIGGER trg_lock_tenant_%I BEFORE UPDATE OF tenant_id ON public.%I FOR EACH ROW EXECUTE FUNCTION public.prevent_tenant_id_change()',
      t, t
    );
  END LOOP;
END $$;

-- ────────────────────────────────────────────────────────────────
-- RLS : enable + force + 4 policies + GRANT (gestiq_api)
-- ────────────────────────────────────────────────────────────────
DO $$
DECLARE
  t text;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
    'guide_steps','guide_templates','guide_checklists','guide_checklist_state',
    'guide_template_renders','guide_discovery_questions','tenant_vision'
  ])
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('ALTER TABLE public.%I FORCE  ROW LEVEL SECURITY', t);

    EXECUTE format('DROP POLICY IF EXISTS rls_select_%I ON public.%I', t, t);
    EXECUTE format('DROP POLICY IF EXISTS rls_insert_%I ON public.%I', t, t);
    EXECUTE format('DROP POLICY IF EXISTS rls_update_%I ON public.%I', t, t);
    EXECUTE format('DROP POLICY IF EXISTS rls_delete_%I ON public.%I', t, t);

    EXECUTE format(
      'CREATE POLICY rls_select_%I ON public.%I FOR SELECT USING (tenant_id = current_tenant_id())', t, t
    );
    EXECUTE format(
      'CREATE POLICY rls_insert_%I ON public.%I FOR INSERT WITH CHECK (tenant_id = current_tenant_id())', t, t
    );
    EXECUTE format(
      'CREATE POLICY rls_update_%I ON public.%I FOR UPDATE USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id())', t, t
    );
    EXECUTE format(
      'CREATE POLICY rls_delete_%I ON public.%I FOR DELETE USING (tenant_id = current_tenant_id())', t, t
    );

    EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON public.%I TO gestiq_api', t);
  END LOOP;
END $$;

COMMIT;
