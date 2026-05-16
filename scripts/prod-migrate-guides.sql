-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Bundle migrations 023 + 024 (Module Guides) pour PROD
--  Date : 2026-05-16
--
--  Ce fichier combine les deux migrations en UNE seule exécution
--  idempotente. Safe à re-runner — aucun effet de bord, aucune perte
--  de données.
--
--  ── Comment l'appliquer ────────────────────────────────────────────
--
--  Option A — Console Postgres dans Dokploy :
--    1. Ouvrir le service Postgres → onglet Console (ou Terminal)
--    2. Lancer :  psql -U postgres -d gestiq
--    3. Coller TOUT le contenu de ce fichier, valider par Entrée
--    4. Vérifier la sortie : "COMMIT" puis "COMMIT" sans erreur
--
--  Option B — Depuis le VPS (SSH + docker exec) :
--    scp scripts/prod-migrate-guides.sql root@VOTRE-VPS:/tmp/
--    ssh root@VOTRE-VPS
--    docker exec -i NOM_CONTENEUR_POSTGRES \
--      psql -U postgres -d gestiq < /tmp/prod-migrate-guides.sql
--
--  Option C — Script automatisé :
--    bash scripts/apply-prod-migrations.sh
--
--  ── Vérification après application ─────────────────────────────────
--
--    SELECT count(*) FROM guide_steps;              -- attendu: nb tenants × 6
--    SELECT count(*) FROM guide_templates;          -- attendu: nb tenants × 7
--    SELECT count(*) FROM guide_checklists;         -- attendu: nb tenants × 12
--    SELECT count(*) FROM guide_discovery_questions;-- attendu: nb tenants × 8
--    SELECT count(*) FROM tenant_vision;            -- attendu: nb tenants × 1
--
-- ════════════════════════════════════════════════════════════════════

\echo '════════════════════════════════════════════════════════════════════'
\echo '  GestiQ — Migration Guides (023 + 024)'
\echo '════════════════════════════════════════════════════════════════════'

-- ─── PART 1 / 2 : SCHEMA (023_guides_module.sql) ───────────────────
BEGIN;

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

-- Triggers updated_at + tenant_id immutability
DO $$
DECLARE
  t text;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
    'guide_steps','guide_templates','guide_checklists','guide_checklist_state',
    'guide_template_renders','guide_discovery_questions','tenant_vision'
  ])
  LOOP
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = t AND column_name = 'updated_at'
    ) THEN
      EXECUTE format('DROP TRIGGER IF EXISTS trg_%I_updated_at ON public.%I', t, t);
      EXECUTE format(
        'CREATE TRIGGER trg_%I_updated_at BEFORE UPDATE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.set_updated_at()',
        t, t
      );
    END IF;
    EXECUTE format('DROP TRIGGER IF EXISTS trg_lock_tenant_%I ON public.%I', t, t);
    EXECUTE format(
      'CREATE TRIGGER trg_lock_tenant_%I BEFORE UPDATE OF tenant_id ON public.%I FOR EACH ROW EXECUTE FUNCTION public.prevent_tenant_id_change()',
      t, t
    );
  END LOOP;
END $$;

-- RLS + 4 policies + GRANT à gestiq_api (si le rôle existe)
DO $$
DECLARE
  t text;
  api_role_exists boolean;
BEGIN
  SELECT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'gestiq_api') INTO api_role_exists;
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

    IF api_role_exists THEN
      EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON public.%I TO gestiq_api', t);
    END IF;
  END LOOP;
  IF NOT api_role_exists THEN
    RAISE NOTICE 'Rôle gestiq_api absent — GRANT sauté (à exécuter manuellement quand le rôle existe)';
  END IF;
END $$;

COMMIT;
\echo '✓ Part 1/2 — Schéma Guides créé'

-- ─── PART 2 / 2 : SEED PLAYBOOK (024_seed_guides_playbook.sql) ─────
BEGIN;

DO $$
DECLARE
  t_id  uuid;
  s1_id uuid;
  s4_id uuid;
  s6_id uuid;
BEGIN
  FOR t_id IN SELECT id FROM public.tenants LOOP

    INSERT INTO public.guide_steps (tenant_id, step_number, step_key, title, subtitle, icon, timer_label, color_hex)
    VALUES
      (t_id, 1, 'contact',     'Premier contact',          'Répondre en moins d''une heure', 'MessageCircle', 'Délai : < 1h',       '#2563EB'),
      (t_id, 2, 'formulaire',  'Formulaire de découverte', '8 questions essentielles',       'ClipboardList', '~3 minutes',         '#7C3AED'),
      (t_id, 3, 'reunion',     'Réunion de découverte',    'Visio 30 minutes',               'Video',         '30 minutes',         '#0EA5E9'),
      (t_id, 4, 'devis',       'Devis professionnel',      'Envoyé sous 48h',                'FileText',      'Délai : 48h',        '#10B981'),
      (t_id, 5, 'contrat',     'Contrat et paiement',      'Acompte 50% avant tout travail', 'FileSignature', 'Avant tout travail', '#F59E0B'),
      (t_id, 6, 'kickoff',     'Kick-off projet',          'Démarrage dans 24h après acompte','Rocket',        'Délai : 24h',        '#EF4444')
    ON CONFLICT (tenant_id, step_key) DO NOTHING;

    SELECT id INTO s1_id FROM public.guide_steps WHERE tenant_id = t_id AND step_key = 'contact';
    SELECT id INTO s4_id FROM public.guide_steps WHERE tenant_id = t_id AND step_key = 'devis';
    SELECT id INTO s6_id FROM public.guide_steps WHERE tenant_id = t_id AND step_key = 'kickoff';

    -- TEMPLATES
    INSERT INTO public.guide_templates (tenant_id, step_id, template_key, channel, label, content, variables, ordre)
    SELECT t_id, s1_id, 'wa_welcome', 'whatsapp', 'Message WhatsApp de bienvenue',
E'Bonjour [Prénom] 👋\nMerci de contacter Next Gital.\nPour vous préparer une analyse personnalisée et gratuite, merci de remplir ce formulaire rapide (3 min) :\n🔗 [lien formulaire]\nNotre équipe vous revient sous 1h. ✅',
      '["Prénom","lien formulaire"]'::jsonb, 1
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_templates WHERE tenant_id = t_id AND template_key = 'wa_welcome');

    INSERT INTO public.guide_templates (tenant_id, step_id, template_key, channel, label, content, variables, ordre)
    SELECT t_id, s1_id, 'email_b2b', 'email', 'Email B2B de bienvenue',
E'Objet : Votre projet digital — Next Gital · Analyse gratuite\n\nBonjour [Prénom],\n\nMerci de l''intérêt que vous portez à Next Gital.\n\nMerci de remplir ce formulaire (3 min) :\n🔗 [lien formulaire]\n\nNous revenons vers vous sous 24h.\n\nCordialement,\n[Votre prénom] · Next Gital · +212 620 002 066',
      '["Prénom","lien formulaire","Votre prénom"]'::jsonb, 2
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_templates WHERE tenant_id = t_id AND template_key = 'email_b2b');

    INSERT INTO public.guide_templates (tenant_id, step_id, template_key, channel, label, content, variables, ordre)
    SELECT t_id, s4_id, 'devis_send', 'general', 'Envoi du devis',
E'Bonjour [Prénom],\n\nMerci pour notre échange de [jour]. Comme promis, voici votre devis :\n📄 [lien devis]\n\nCe devis est valable 7 jours.\n\nÀ bientôt,\nNext Gital · +212 620 002 066',
      '["Prénom","jour","lien devis"]'::jsonb, 1
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_templates WHERE tenant_id = t_id AND template_key = 'devis_send');

    INSERT INTO public.guide_templates (tenant_id, step_id, template_key, channel, label, content, variables, ordre)
    SELECT t_id, s4_id, 'devis_relance', 'whatsapp', 'Relance devis (J+3, une seule fois)',
E'Bonjour [Prénom],\n\nJe voulais m''assurer que le devis vous est bien parvenu. Des questions ?\n\nJe reste disponible 👍 +212 620 002 066',
      '["Prénom"]'::jsonb, 2
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_templates WHERE tenant_id = t_id AND template_key = 'devis_relance');

    INSERT INTO public.guide_templates (tenant_id, step_id, template_key, channel, label, content, variables, ordre)
    SELECT t_id, s6_id, 'kickoff_welcome', 'general', 'Message de bienvenue Kick-off',
E'Bonjour [Prénom] 🎉\nPaiement reçu — votre projet [Nom] démarre officiellement !\n\n📁 Dossier projet : [lien Drive]\n📋 Éléments requis : [lien liste]\n📅 Planning : [lien]\n📞 Communication : WhatsApp questions rapides / Email validations officielles\n\nProchain point : [date] pour la 1ère maquette. Bienvenue ! 🙏',
      '["Prénom","Nom","lien Drive","lien liste","lien","date"]'::jsonb, 1
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_templates WHERE tenant_id = t_id AND template_key = 'kickoff_welcome');

    INSERT INTO public.guide_templates (tenant_id, step_id, template_key, channel, label, content, variables, ordre)
    SELECT t_id, s6_id, 'kickoff_charte', 'general', 'Charte de communication',
E'📱 WhatsApp +212 620 002 066 → questions rapides, réponse < 1h\n📧 info@nextgital.com → validations officielles, réponse < 24h\n🕐 Horaires : Lundi-Vendredi 9h-17h\n📍 Bureau sur RDV : 4ème étage, Bureau N°7, Immeuble Kissi — Oujda',
      '[]'::jsonb, 2
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_templates WHERE tenant_id = t_id AND template_key = 'kickoff_charte');

    INSERT INTO public.guide_templates (tenant_id, step_id, template_key, channel, label, content, variables, ordre)
    SELECT t_id, s6_id, 'j30_followup', 'general', 'Suivi J+30 après livraison',
E'Bonjour [Prénom],\n\nUn mois depuis le lancement ! 🎉 Comment se passe-t-il ?\n\nLe moment venu : gestion publicités Meta/Google · maintenance · évolution.\n\nNext Gital · +212 620 002 066',
      '["Prénom"]'::jsonb, 3
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_templates WHERE tenant_id = t_id AND template_key = 'j30_followup');

    -- CHECKLISTS — étape 1 (one-time setup)
    INSERT INTO public.guide_checklists (tenant_id, step_id, item_order, item_text, is_one_time)
    SELECT t_id, s1_id, 1, 'Créer formulaire Tally.so + sauvegarder le lien', true
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_checklists WHERE tenant_id = t_id AND step_id = s1_id AND item_order = 1);
    INSERT INTO public.guide_checklists (tenant_id, step_id, item_order, item_text, is_one_time)
    SELECT t_id, s1_id, 2, 'Quick Reply WhatsApp Business "bienvenue"', true
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_checklists WHERE tenant_id = t_id AND step_id = s1_id AND item_order = 2);
    INSERT INTO public.guide_checklists (tenant_id, step_id, item_order, item_text, is_one_time)
    SELECT t_id, s1_id, 3, 'Réponse automatique Instagram', true
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_checklists WHERE tenant_id = t_id AND step_id = s1_id AND item_order = 3);
    INSERT INTO public.guide_checklists (tenant_id, step_id, item_order, item_text, is_one_time)
    SELECT t_id, s1_id, 4, 'Modèle Gmail "Bienvenue Next Gital"', true
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_checklists WHERE tenant_id = t_id AND step_id = s1_id AND item_order = 4);
    INSERT INTO public.guide_checklists (tenant_id, step_id, item_order, item_text, is_one_time)
    SELECT t_id, s1_id, 5, 'Notification mobile < 1h activée', true
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_checklists WHERE tenant_id = t_id AND step_id = s1_id AND item_order = 5);

    -- CHECKLISTS — étape 6 (par projet)
    INSERT INTO public.guide_checklists (tenant_id, step_id, item_order, item_text, is_one_time)
    SELECT t_id, s6_id, 1, 'Logo PNG transparent + SVG', false
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_checklists WHERE tenant_id = t_id AND step_id = s6_id AND item_order = 1);
    INSERT INTO public.guide_checklists (tenant_id, step_id, item_order, item_text, is_one_time)
    SELECT t_id, s6_id, 2, 'Photos professionnelles (équipe, locaux, produits)', false
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_checklists WHERE tenant_id = t_id AND step_id = s6_id AND item_order = 2);
    INSERT INTO public.guide_checklists (tenant_id, step_id, item_order, item_text, is_one_time)
    SELECT t_id, s6_id, 3, 'Textes / contenu (ou accord rédaction Next Gital)', false
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_checklists WHERE tenant_id = t_id AND step_id = s6_id AND item_order = 3);
    INSERT INTO public.guide_checklists (tenant_id, step_id, item_order, item_text, is_one_time)
    SELECT t_id, s6_id, 4, 'Coordonnées officielles complètes', false
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_checklists WHERE tenant_id = t_id AND step_id = s6_id AND item_order = 4);
    INSERT INTO public.guide_checklists (tenant_id, step_id, item_order, item_text, is_one_time)
    SELECT t_id, s6_id, 5, 'Liens réseaux sociaux', false
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_checklists WHERE tenant_id = t_id AND step_id = s6_id AND item_order = 5);
    INSERT INTO public.guide_checklists (tenant_id, step_id, item_order, item_text, is_one_time)
    SELECT t_id, s6_id, 6, 'Couleurs de la marque (codes HEX)', false
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_checklists WHERE tenant_id = t_id AND step_id = s6_id AND item_order = 6);
    INSERT INTO public.guide_checklists (tenant_id, step_id, item_order, item_text, is_one_time)
    SELECT t_id, s6_id, 7, 'Accès hébergement/domaine existant (si refonte)', false
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_checklists WHERE tenant_id = t_id AND step_id = s6_id AND item_order = 7);

    -- QUESTIONS DÉCOUVERTE
    INSERT INTO public.guide_discovery_questions (tenant_id, question_order, question_text, question_why, input_type, options, is_required)
    SELECT t_id, 1, 'Nom et secteur d''activité de votre entreprise ?', 'Identifier le contexte business', 'text', '[]'::jsonb, true
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_discovery_questions WHERE tenant_id = t_id AND question_order = 1);
    INSERT INTO public.guide_discovery_questions (tenant_id, question_order, question_text, question_why, input_type, options, is_required)
    SELECT t_id, 2, 'Quel type de projet ?', 'Catégoriser pour pricing', 'select',
      '["Site vitrine","E-commerce","Plateforme","Application mobile","Refonte","Autre"]'::jsonb, true
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_discovery_questions WHERE tenant_id = t_id AND question_order = 2);
    INSERT INTO public.guide_discovery_questions (tenant_id, question_order, question_text, question_why, input_type, options, is_required)
    SELECT t_id, 3, 'Avez-vous un site actuel ? Si oui, quel est le problème ?', 'Identifier la douleur', 'textarea', '[]'::jsonb, false
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_discovery_questions WHERE tenant_id = t_id AND question_order = 3);
    INSERT INTO public.guide_discovery_questions (tenant_id, question_order, question_text, question_why, input_type, options, is_required)
    SELECT t_id, 4, 'Quel est votre objectif principal ?', 'Aligner la proposition sur le besoin', 'select',
      '["Visibilité","Ventes","Gestion","Crédibilité","Lead generation","Autre"]'::jsonb, true
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_discovery_questions WHERE tenant_id = t_id AND question_order = 4);
    INSERT INTO public.guide_discovery_questions (tenant_id, question_order, question_text, question_why, input_type, options, is_required)
    SELECT t_id, 5, 'Qui est votre client idéal ? (âge, secteur, localisation)', 'Comprendre la cible pour positionner', 'textarea', '[]'::jsonb, true
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_discovery_questions WHERE tenant_id = t_id AND question_order = 5);
    INSERT INTO public.guide_discovery_questions (tenant_id, question_order, question_text, question_why, input_type, options, is_required)
    SELECT t_id, 6, 'Citez 2-3 sites qui vous plaisent et ce que vous aimez dedans', 'Calibrer le design attendu', 'textarea', '[]'::jsonb, false
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_discovery_questions WHERE tenant_id = t_id AND question_order = 6);
    INSERT INTO public.guide_discovery_questions (tenant_id, question_order, question_text, question_why, input_type, options, is_required)
    SELECT t_id, 7, 'Quel est votre budget approximatif ?', 'Qualifier (si vide → relance : > ou < 5 000 DH ?)', 'budget_range',
      '["< 5 000 DH","5 000 — 15 000 DH","15 000 — 30 000 DH","30 000 — 60 000 DH","> 60 000 DH"]'::jsonb, false
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_discovery_questions WHERE tenant_id = t_id AND question_order = 7);
    INSERT INTO public.guide_discovery_questions (tenant_id, question_order, question_text, question_why, input_type, options, is_required)
    SELECT t_id, 8, 'Quelle est votre deadline souhaitée ?', 'Évaluer urgence + capacité', 'select',
      '["< 2 semaines","2 — 4 semaines","1 — 2 mois","2 — 3 mois","Flexible"]'::jsonb, true
    WHERE NOT EXISTS (SELECT 1 FROM public.guide_discovery_questions WHERE tenant_id = t_id AND question_order = 8);

    -- VISION placeholder
    INSERT INTO public.tenant_vision (tenant_id) VALUES (t_id)
    ON CONFLICT (tenant_id) DO NOTHING;

  END LOOP;
END $$;

COMMIT;
\echo '✓ Part 2/2 — Seed playbook appliqué pour tous les tenants'

-- ─── VÉRIFICATIONS ─────────────────────────────────────────────────
\echo ''
\echo '════════════════ Vérification ═══════════════════════════════════════'
SELECT 'guide_steps'              AS table_name, COUNT(*) AS rows FROM public.guide_steps
UNION ALL SELECT 'guide_templates',          COUNT(*) FROM public.guide_templates
UNION ALL SELECT 'guide_checklists',         COUNT(*) FROM public.guide_checklists
UNION ALL SELECT 'guide_discovery_questions',COUNT(*) FROM public.guide_discovery_questions
UNION ALL SELECT 'tenant_vision',            COUNT(*) FROM public.tenant_vision;
\echo '════════════════════════════════════════════════════════════════════'
\echo '  ✅ Migration terminée — réactiver le serveur API si besoin'
\echo '════════════════════════════════════════════════════════════════════'
