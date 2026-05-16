-- ================================================================
--  GestiQ — Migration 024 : Seed Playbook Next Gital (6 étapes)
--  Date: 2026-05-16
--
--  Insère le contenu du playbook d'onboarding pour TOUS les tenants
--  existants. Idempotent (ON CONFLICT DO NOTHING sur clés uniques).
--
--  Inclut :
--    - 6 guide_steps
--    - 7 guide_templates (WhatsApp, Email, Devis, Relance, Kickoff, J+30…)
--    - 12 guide_checklists
--    - 8 guide_discovery_questions
--    - 1 tenant_vision par tenant (placeholder vide, à remplir par Admin)
-- ================================================================

BEGIN;

DO $$
DECLARE
  t_id  uuid;
  s1_id uuid;
  s2_id uuid;
  s3_id uuid;
  s4_id uuid;
  s5_id uuid;
  s6_id uuid;
BEGIN
  FOR t_id IN SELECT id FROM public.tenants LOOP

    -- ── 1. 6 ÉTAPES ─────────────────────────────────────────────
    INSERT INTO public.guide_steps (tenant_id, step_number, step_key, title, subtitle, icon, timer_label, color_hex)
    VALUES
      (t_id, 1, 'contact',     'Premier contact',          'Répondre en moins d''une heure', 'MessageCircle', 'Délai : < 1h',       '#2563EB'),
      (t_id, 2, 'formulaire',  'Formulaire de découverte', '8 questions essentielles',       'ClipboardList', '~3 minutes',         '#7C3AED'),
      (t_id, 3, 'reunion',     'Réunion de découverte',    'Visio 30 minutes',               'Video',         '30 minutes',         '#0EA5E9'),
      (t_id, 4, 'devis',       'Devis professionnel',      'Envoyé sous 48h',                'FileText',      'Délai : 48h',        '#10B981'),
      (t_id, 5, 'contrat',     'Contrat et paiement',      'Acompte 50% avant tout travail', 'FileSignature', 'Avant tout travail', '#F59E0B'),
      (t_id, 6, 'kickoff',     'Kick-off projet',          'Démarrage dans 24h après acompte','Rocket',        'Délai : 24h',        '#EF4444')
    ON CONFLICT (tenant_id, step_key) DO NOTHING;

    -- Récupérer les IDs des étapes
    SELECT id INTO s1_id FROM public.guide_steps WHERE tenant_id = t_id AND step_key = 'contact';
    SELECT id INTO s2_id FROM public.guide_steps WHERE tenant_id = t_id AND step_key = 'formulaire';
    SELECT id INTO s3_id FROM public.guide_steps WHERE tenant_id = t_id AND step_key = 'reunion';
    SELECT id INTO s4_id FROM public.guide_steps WHERE tenant_id = t_id AND step_key = 'devis';
    SELECT id INTO s5_id FROM public.guide_steps WHERE tenant_id = t_id AND step_key = 'contrat';
    SELECT id INTO s6_id FROM public.guide_steps WHERE tenant_id = t_id AND step_key = 'kickoff';

    -- ── 2. TEMPLATES MESSAGES ─────────────────────────────────────
    -- Étape 1 : WhatsApp + Email B2B
    INSERT INTO public.guide_templates (tenant_id, step_id, template_key, channel, label, content, variables, ordre)
    SELECT t_id, s1_id, 'wa_welcome', 'whatsapp', 'Message WhatsApp de bienvenue',
E'Bonjour [Prénom] 👋\nMerci de contacter Next Gital.\nPour vous préparer une analyse personnalisée et gratuite, merci de remplir ce formulaire rapide (3 min) :\n🔗 [lien formulaire]\nNotre équipe vous revient sous 1h. ✅',
      '["Prénom","lien formulaire"]'::jsonb, 1
    WHERE NOT EXISTS (
      SELECT 1 FROM public.guide_templates WHERE tenant_id = t_id AND template_key = 'wa_welcome'
    );

    INSERT INTO public.guide_templates (tenant_id, step_id, template_key, channel, label, content, variables, ordre)
    SELECT t_id, s1_id, 'email_b2b', 'email', 'Email B2B de bienvenue',
E'Objet : Votre projet digital — Next Gital · Analyse gratuite\n\nBonjour [Prénom],\n\nMerci de l''intérêt que vous portez à Next Gital.\n\nMerci de remplir ce formulaire (3 min) :\n🔗 [lien formulaire]\n\nNous revenons vers vous sous 24h.\n\nCordialement,\n[Votre prénom] · Next Gital · +212 620 002 066',
      '["Prénom","lien formulaire","Votre prénom"]'::jsonb, 2
    WHERE NOT EXISTS (
      SELECT 1 FROM public.guide_templates WHERE tenant_id = t_id AND template_key = 'email_b2b'
    );

    -- Étape 4 : Envoi du devis + Relance J+3
    INSERT INTO public.guide_templates (tenant_id, step_id, template_key, channel, label, content, variables, ordre)
    SELECT t_id, s4_id, 'devis_send', 'general', 'Envoi du devis',
E'Bonjour [Prénom],\n\nMerci pour notre échange de [jour]. Comme promis, voici votre devis :\n📄 [lien devis]\n\nCe devis est valable 7 jours.\n\nÀ bientôt,\nNext Gital · +212 620 002 066',
      '["Prénom","jour","lien devis"]'::jsonb, 1
    WHERE NOT EXISTS (
      SELECT 1 FROM public.guide_templates WHERE tenant_id = t_id AND template_key = 'devis_send'
    );

    INSERT INTO public.guide_templates (tenant_id, step_id, template_key, channel, label, content, variables, ordre)
    SELECT t_id, s4_id, 'devis_relance', 'whatsapp', 'Relance devis (J+3, une seule fois)',
E'Bonjour [Prénom],\n\nJe voulais m''assurer que le devis vous est bien parvenu. Des questions ?\n\nJe reste disponible 👍 +212 620 002 066',
      '["Prénom"]'::jsonb, 2
    WHERE NOT EXISTS (
      SELECT 1 FROM public.guide_templates WHERE tenant_id = t_id AND template_key = 'devis_relance'
    );

    -- Étape 6 : Kick-off + Message J+30
    INSERT INTO public.guide_templates (tenant_id, step_id, template_key, channel, label, content, variables, ordre)
    SELECT t_id, s6_id, 'kickoff_welcome', 'general', 'Message de bienvenue Kick-off',
E'Bonjour [Prénom] 🎉\nPaiement reçu — votre projet [Nom] démarre officiellement !\n\n📁 Dossier projet : [lien Drive]\n📋 Éléments requis : [lien liste]\n📅 Planning : [lien]\n📞 Communication : WhatsApp questions rapides / Email validations officielles\n\nProchain point : [date] pour la 1ère maquette. Bienvenue ! 🙏',
      '["Prénom","Nom","lien Drive","lien liste","lien","date"]'::jsonb, 1
    WHERE NOT EXISTS (
      SELECT 1 FROM public.guide_templates WHERE tenant_id = t_id AND template_key = 'kickoff_welcome'
    );

    INSERT INTO public.guide_templates (tenant_id, step_id, template_key, channel, label, content, variables, ordre)
    SELECT t_id, s6_id, 'kickoff_charte', 'general', 'Charte de communication',
E'📱 WhatsApp +212 620 002 066 → questions rapides, réponse < 1h\n📧 info@nextgital.com → validations officielles, réponse < 24h\n🕐 Horaires : Lundi-Vendredi 9h-17h\n📍 Bureau sur RDV : 4ème étage, Bureau N°7, Immeuble Kissi — Oujda',
      '[]'::jsonb, 2
    WHERE NOT EXISTS (
      SELECT 1 FROM public.guide_templates WHERE tenant_id = t_id AND template_key = 'kickoff_charte'
    );

    INSERT INTO public.guide_templates (tenant_id, step_id, template_key, channel, label, content, variables, ordre)
    SELECT t_id, s6_id, 'j30_followup', 'general', 'Suivi J+30 après livraison',
E'Bonjour [Prénom],\n\nUn mois depuis le lancement ! 🎉 Comment se passe-t-il ?\n\nLe moment venu : gestion publicités Meta/Google · maintenance · évolution.\n\nNext Gital · +212 620 002 066',
      '["Prénom"]'::jsonb, 3
    WHERE NOT EXISTS (
      SELECT 1 FROM public.guide_templates WHERE tenant_id = t_id AND template_key = 'j30_followup'
    );

    -- ── 3. CHECKLISTS ─────────────────────────────────────────────
    -- Étape 1 : configuration one-time
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

    -- Étape 6 : éléments à recevoir du client (par projet)
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

    -- ── 4. QUESTIONS FORMULAIRE DÉCOUVERTE (8Q) ───────────────────
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

    -- ── 5. TENANT_VISION (placeholder vide) ───────────────────────
    INSERT INTO public.tenant_vision (tenant_id) VALUES (t_id)
    ON CONFLICT (tenant_id) DO NOTHING;

  END LOOP;
END $$;

COMMIT;
