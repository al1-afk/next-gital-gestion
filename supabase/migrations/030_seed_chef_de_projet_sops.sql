-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 030 : Seed des 5 SOPs « Chef de projet »
--  Date : 2026-05-17
--
--  Catégorie : projets · Auteur : Next Gital · Idempotent
--  Insère pour TOUS les tenants existants.
--
--  Conformité ARCHITECTURE_TENANT.md :
--    - tenant_id NOT NULL, contrôle d'existence par (tenant_id, slug)
--    - RLS déjà actif sur public.sops (migration 025)
--    - Pas de modification de la structure existante
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ── ng-cdp-ouverture-projet (projets) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-cdp-ouverture-projet',
  'Ouverture de projet',
  'Procédure d''ouverture projet : fiche GestiQ, dossier Drive, kick-off client, Kanban, rappels.',
  'projets',
  '["KickOff","Projet","Chef","Démarrage"]'::jsonb,
  'Next Gital',
  4,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Dans les 24h après réception de l'acompte."},
    {"type":"callout","variant":"info","title":"Canal","text":"GestiQ + Google Drive + WhatsApp."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Ouvrir le projet correctement dès le premier jour."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Créer la fiche projet dans GestiQ"},
    {"type":"paragraph","text":"CRM → Nouveau projet. Renseigner : nom, client, type, montant total, date début, date livraison, responsable. Changer le statut à « En cours »."},
    {"type":"list","items":["Outil : **GestiQ**","Temps estimé : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"2. Créer le dossier Google Drive"},
    {"type":"paragraph","text":"Nom du dossier : **[NOM CLIENT] — [TYPE PROJET] — [MOIS ANNÉE]**. Créer les 5 sous-dossiers :"},
    {"type":"numbered","items":["01_Brief","02_Maquettes","03_Assets_Client","04_Développement","05_Livraison"]},
    {"type":"list","items":["Outil : **Google Drive**","Temps estimé : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"3. Envoyer le message de kick-off au client"},
    {"type":"paragraph","text":"Utiliser le template ci-dessous. Inclure : lien Drive, liste des éléments requis, planning, règles de communication."},
    {"type":"template","text":"Bonjour [Prénom] 🎉\n\nPaiement reçu — votre projet [NOM DU PROJET] démarre officiellement !\n\nVoici votre dossier de démarrage :\n\n📁 Dossier projet partagé : [LIEN GOOGLE DRIVE]\n📋 Éléments requis de votre part : [LIEN LISTE]\n📅 Planning détaillé : [LIEN PLANNING]\n\n📞 Règles de communication :\n• WhatsApp : questions rapides (réponse < 1h)\n• Email : validations officielles et fichiers\n\nHoraires : Lun–Ven · 9h–17h\n\nNotre 1er point : [DATE] pour la maquette initiale.\n\nBienvenue dans l'équipe Next Gital ! 🙏"},
    {"type":"list","items":["Outil : **WhatsApp**","Temps estimé : ~10 min","Statut : requis"]},

    {"type":"heading2","text":"4. Créer les tâches dans le Kanban"},
    {"type":"paragraph","text":"GestiQ → Kanban → Nouveau projet. Créer les cartes dans cet ordre et assigner développeur + designer :"},
    {"type":"steps","items":["Brief validé","Wireframe","Design","Développement","QA","Mise en ligne","Livraison"]},
    {"type":"list","items":["Outil : **GestiQ Kanban**","Temps estimé : ~10 min","Statut : requis"]},

    {"type":"heading2","text":"5. Planifier la 1ère réunion de suivi (J+5)"},
    {"type":"paragraph","text":"Envoyer le lien Calendly au client pour réserver la réunion de présentation wireframe à J+5. Durée : 30 min."},
    {"type":"list","items":["Outil : **Calendly**","Temps estimé : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"6. Programmer le rappel assets client"},
    {"type":"paragraph","text":"Délai accordé : 5 jours pour envoyer logo, photos, textes. Si pas reçus à J+5 → relance. Si pas reçus à J+7 → escalade fondateur. Le planning se décale automatiquement."},
    {"type":"list","items":["Outil : **GestiQ Alertes**","Temps estimé : ~2 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Message de relance assets — si pas reçus à J+5"},
    {"type":"template","text":"Bonjour [Prénom] 👋\n\nPour respecter votre planning de livraison du [DATE LIVRAISON], nous avons besoin de recevoir les éléments suivants avant le [DATE J+7] :\n\n☐ Logo (PNG transparent)\n☐ Photos professionnelles\n☐ Textes / contenu\n☐ Couleurs de la marque (codes HEX si disponibles)\n\nSans ces éléments, la date de livraison sera reportée d'autant.\n\nMerci de votre réactivité 🙏\nNext Gital"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Fiche projet créée dans GestiQ (statut : En cours)",
      "Dossier Drive créé avec les 5 sous-dossiers",
      "Message kick-off envoyé au client",
      "Tâches Kanban créées et assignées",
      "Réunion J+5 planifiée dans Calendly",
      "Rappel J+7 assets client programmé dans GestiQ"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-cdp-ouverture-projet');


-- ── ng-cdp-suivi-hebdo (projets) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-cdp-suivi-hebdo',
  'Suivi hebdomadaire des projets',
  'Revue hebdo chaque lundi 9h : dashboard, Kanban, rapports clients, devis, priorités.',
  'projets',
  '["Suivi","Hebdo","Kanban","Lundi"]'::jsonb,
  'Next Gital',
  3,
  true,
  $sop$[
    {"type":"callout","variant":"warning","title":"Délai","text":"Chaque lundi matin à 9h — avant tout autre travail. Durée max : 30 min."},
    {"type":"callout","variant":"info","title":"Canal","text":"GestiQ + WhatsApp."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Aucun projet ne tombe dans l'oubli — 100% des clients informés chaque semaine."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Chaque lundi à 9h, avant tout message ou projet, passer la revue complète."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Dashboard GestiQ — alertes en premier"},
    {"type":"paragraph","text":"Vérifier dans cet ordre : projets en retard (rouge), factures impayées, alertes actives, tâches échues. Traiter les alertes critiques **avant** toute autre chose."},
    {"type":"list","items":["Outil : **GestiQ Dashboard**","Temps : ~5 min"]},

    {"type":"heading2","text":"2. Parcourir le Kanban — projet par projet"},
    {"type":"paragraph","text":"Pour chaque projet « En cours », poser ces 4 questions et mettre à jour le statut de la carte :"},
    {"type":"numbered","items":[
      "Où en est-on exactement ?",
      "Y a-t-il un blocage ?",
      "Le client a-t-il répondu à la dernière demande ?",
      "La date de livraison est-elle toujours réaliste ?"
    ]},
    {"type":"list","items":["Outil : **GestiQ Kanban**","Temps : ~10 min"]},

    {"type":"heading2","text":"3. Envoyer le rapport hebdo à chaque client actif"},
    {"type":"paragraph","text":"Utiliser le template de rapport hebdo ci-dessous. Personnaliser avec le nom du projet et l'avancement réel. 1 message par projet actif (WhatsApp ou email selon préférence)."},
    {"type":"template","text":"Bonjour [Prénom] 👋\n\nVoici le point de cette semaine sur votre projet [NOM PROJET] :\n\n✅ Ce qui est fait :\n— [RÉALISATION 1]\n— [RÉALISATION 2]\n\n🔄 En cours cette semaine :\n— [TÂCHE EN COURS]\n\n📅 Prochaine étape :\n— [PROCHAINE ÉTAPE + DATE PRÉCISE]\n\n⚠️ Action requise de votre part :\n— [SI RIEN À FAIRE : supprimer cette section]\n\nBonne semaine ! 🙏\nNext Gital"},
    {"type":"list","items":["Outil : **WhatsApp / Email**","Temps : ~10 min"]},

    {"type":"heading2","text":"4. Vérifier les devis en attente"},
    {"type":"paragraph","text":"GestiQ → CRM → Filtrer « Devis envoyé ». Règle :"},
    {"type":"list","items":[
      "> 3 jours sans réponse → **relancer 1 seule fois**",
      "> 7 jours sans réponse → marquer « Perdu » et archiver"
    ]},
    {"type":"callout","variant":"warning","title":"Ne jamais","text":"Relancer plus d'une fois. Cela nuit à l'image de Next Gital."},
    {"type":"list","items":["Outil : **GestiQ CRM**","Temps : ~5 min"]},

    {"type":"heading2","text":"5. Planifier les 3 actions prioritaires de la semaine"},
    {"type":"paragraph","text":"Pour chaque projet actif, noter dans GestiQ les 3 actions les plus importantes. Assigner à chaque membre avec une deadline précise. **Aucune tâche sans deadline.**"},
    {"type":"list","items":["Outil : **GestiQ Tâches**","Temps : ~5 min"]},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de fin de revue"},
    {"type":"checklist","items":[
      "Dashboard GestiQ consulté — alertes critiques traitées",
      "Kanban parcouru — tous les statuts à jour",
      "Rapport hebdo envoyé à chaque client actif",
      "Devis en attente vérifiés — relances effectuées si nécessaire",
      "Tâches de la semaine assignées avec deadlines",
      "Projet sans activité 3+ jours → investigué",
      "Facture impayée 7+ jours → fondateur alerté"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-cdp-suivi-hebdo');


-- ── ng-cdp-communication-client (projets) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-cdp-communication-client',
  'Communication client — règles et messages',
  'Règles de communication, validation par email, annonce de retard, demandes hors scope.',
  'projets',
  '["Communication","Client","Messages","Règles"]'::jsonb,
  'Next Gital',
  4,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Usage","text":"Quotidien — référence permanente."},
    {"type":"callout","variant":"info","title":"Canal","text":"WhatsApp + Email."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Zéro client sans réponse · Zéro mauvaise surprise · Relation de confiance durable."},

    {"type":"heading","text":"Les 5 règles d'or"},

    {"type":"heading2","text":"1. Répondre en moins de 1h en heures ouvrées"},
    {"type":"paragraph","text":"Si tu n'as pas la réponse immédiate : confirmer la réception et donner un délai précis."},
    {"type":"quote","text":"« Je vérifie et je reviens vers vous avant 15h. »"},
    {"type":"callout","variant":"danger","title":"Ne jamais","text":"Laisser un client sans réponse plus de 1h en heures ouvrées."},

    {"type":"heading2","text":"2. WhatsApp = questions · Email = validations officielles"},
    {"type":"paragraph","text":"Toute validation officielle (maquette, textes, mise en ligne) doit être confirmée par email avec trace écrite. Ne jamais valider par vocal. En cas de litige, seul l'email fait foi."},

    {"type":"heading2","text":"3. Annoncer les mauvaises nouvelles immédiatement"},
    {"type":"paragraph","text":"Retard, problème technique, blocage → informer le client **le jour même, avant qu'il demande**. Toujours proposer une solution en même temps que le problème."},

    {"type":"heading2","text":"4. Escalader au fondateur si demande hors scope"},
    {"type":"paragraph","text":"Si le client demande quelque chose qui n'est pas dans le devis signé : ne pas dire non directement. Dire :"},
    {"type":"quote","text":"« Laissez-moi vérifier avec l'équipe et je reviens vers vous avec une proposition. »"},
    {"type":"paragraph","text":"Puis informer le fondateur dans les 30 minutes."},

    {"type":"heading2","text":"5. Demander la validation par email avant chaque étape clé"},
    {"type":"paragraph","text":"Avant de passer d'une phase à la suivante (maquette → dev, dev → mise en ligne), obtenir une confirmation **écrite** du client."},

    {"type":"divider"},

    {"type":"heading","text":"Templates de messages"},

    {"type":"heading2","text":"Présentation de la maquette au client"},
    {"type":"template","text":"Bonjour [Prénom] 😊\n\nVotre maquette est prête ! Voici le lien pour la consulter :\n\n🎨 [LIEN FIGMA ou LIEN STAGING]\n\nVous pouvez :\n• Consulter la maquette librement\n• Ajouter vos commentaires directement sur Figma\n• Me contacter pour en discuter\n\nVos retours sont attendus avant le [DATE + 48H] pour respecter le planning.\n\nUne fois validée par email, le développement commencera immédiatement. 🚀"},

    {"type":"heading2","text":"Annonce d'un retard — mauvaise nouvelle"},
    {"type":"template","text":"Bonjour [Prénom],\n\nJe dois vous informer d'un ajustement dans le planning de votre projet.\n\nEn raison de [RAISON COURTE ET HONNÊTE], la livraison prévue le [DATE INITIALE] est reportée au [NOUVELLE DATE].\n\nCe délai supplémentaire de [X jours] nous permettra de [BÉNÉFICE CONCRET POUR LE CLIENT].\n\nJe m'en excuse sincèrement et reste disponible pour toute question.\n\n[SI COMPENSATION : En compensation, nous [GESTE COMMERCIAL].]\n\nCordialement,\n[Votre prénom] · Next Gital"},

    {"type":"heading2","text":"Demande de validation officielle par email"},
    {"type":"template","text":"Bonjour [Prénom],\n\nSuite à notre échange, pouvez-vous confirmer par retour d'email votre validation de [ÉLÉMENT À VALIDER : maquette / textes / mise en ligne] ?\n\nUn simple « Je valide » suffira.\n\nCette confirmation me permettra de lancer immédiatement [PROCHAINE ÉTAPE].\n\nMerci ! 🙏"},

    {"type":"heading2","text":"Réponse si demande hors scope — message diplomate"},
    {"type":"template","text":"Bonjour [Prénom],\n\nMerci pour cette nouvelle idée — elle est très pertinente pour votre projet !\n\nCette fonctionnalité n'est pas incluse dans le devis initial du [DATE], mais je peux tout à fait vous préparer une proposition pour l'ajouter.\n\nJe reviens vers vous dans les 24h avec un devis complémentaire.\n\nEn attendant, n'hésitez pas si vous avez d'autres questions 🙏"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist permanente"},
    {"type":"checklist","items":[
      "Aucun message client sans réponse depuis plus de 1h (heures ouvrées)",
      "Toutes les validations obtenues par email — jamais par vocal",
      "Mauvaises nouvelles annoncées le jour même",
      "Demandes hors scope escaladées au fondateur < 30 min",
      "Chaque étape clé validée par écrit avant de continuer"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-cdp-communication-client');


-- ── ng-cdp-livraison-finale (projets) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-cdp-livraison-finale',
  'Livraison finale — QA et mise en ligne',
  'Process de livraison : QA complet, validation client, mise en ligne, dossier de livraison, avis Google.',
  'projets',
  '["Livraison","QA","MiseEnLigne","Qualité"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Dernier jour du projet."},
    {"type":"callout","variant":"info","title":"Canal","text":"GestiQ + Google Drive + WhatsApp."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Zéro bug en production · Client 100% satisfait · Avis Google obtenu."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Aucune mise en ligne sans que TOUTES les cases QA soient cochées. Sans exception, jamais."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. QA complet sur le site staging"},
    {"type":"paragraph","text":"Parcourir toute la checklist QA ci-dessous. Tester sur : iPhone (Safari + Chrome), Android (Chrome), tablette, desktop (Chrome, Firefox, Safari). Chaque point doit être coché avant l'étape suivante."},
    {"type":"list","items":["Outil : **Navigateur + GTmetrix**","Temps : 1–2h"]},

    {"type":"heading2","text":"2. Envoyer le lien staging au client pour pré-validation"},
    {"type":"paragraph","text":"Envoyer le message « Pré-livraison » ci-dessous. Délai de retour : 24h. Attendre la validation écrite par email avant toute mise en ligne."},
    {"type":"template","text":"Bonjour [Prénom] 😊\n\nVotre site est presque prêt ! Voici le lien de prévisualisation pour votre validation finale :\n\n🔗 [LIEN STAGING]\n\nVos retours sont attendus avant le [DATE + 24H].\n\nUne fois votre accord reçu par email, nous procédons à la mise en ligne définitive. 🚀"},
    {"type":"list","items":["Outil : **WhatsApp + Email**","Temps : ~5 min"]},

    {"type":"heading2","text":"3. Mise en ligne après validation écrite"},
    {"type":"paragraph","text":"Uniquement après réception de l'email de validation. Procéder à la mise en ligne sur le domaine définitif. Vérifier immédiatement après : SSL actif, formulaire fonctionne, site accessible."},
    {"type":"list","items":["Outil : **Hébergement + FTP/cPanel**","Temps : ~30 min"]},

    {"type":"heading2","text":"4. Envoyer le dossier de livraison complet"},
    {"type":"paragraph","text":"Partager via Drive : accès admin complet, vidéo tutoriel (3–5 min, Loom), guide PDF d'utilisation, liste de tous les mots de passe dans un fichier sécurisé. Envoyer le message de livraison officielle."},
    {"type":"template","text":"🎉 Bonjour [Prénom] !\n\nVotre site est maintenant en ligne : 🔗 [URL DU SITE]\n\nNous avons vérifié chaque détail avant la mise en ligne :\n✅ Vitesse optimisée (< 2 secondes)\n✅ 100% responsive mobile\n✅ SEO configuré\n✅ SSL actif et sécurisé\n✅ Formulaire de contact testé\n\nVotre dossier de livraison :\n🎥 Vidéo tutoriel (5 min) : [LIEN VIDÉO LOOM]\n📘 Guide PDF : [LIEN PDF]\n🔐 Vos accès : voir le dossier Drive partagé\n\nVos 3 révisions gratuites sont disponibles pendant 30 jours.\n\nMerci pour votre confiance [Prénom] 🙏\nNext Gital"},
    {"type":"list","items":["Outil : **Drive + WhatsApp**","Temps : ~30 min"]},

    {"type":"heading2","text":"5. Demander l'avis Google à J+2"},
    {"type":"paragraph","text":"2 jours après la livraison, envoyer le message de demande d'avis avec le lien Google Review direct."},
    {"type":"callout","variant":"warning","title":"Ne jamais oublier","text":"Cette étape est directement liée à la note 4.9★ de Next Gital."},
    {"type":"template","text":"Bonjour [Prénom] 😊\n\nJ'espère que votre site vous plaît et que tout fonctionne bien !\n\nSi vous êtes satisfait de notre travail, un avis Google nous aiderait énormément. Cela prend 1 minute :\n\n⭐ Laisser un avis : [LIEN GOOGLE REVIEW DIRECT]\n\nMerci d'avance — chaque avis compte beaucoup pour notre équipe 🙏\nNext Gital"},
    {"type":"list","items":["Outil : **WhatsApp**","Temps : ~2 min"]},

    {"type":"heading2","text":"6. Fermer le projet dans GestiQ"},
    {"type":"paragraph","text":"Statut → « Livré ». Saisir la date de livraison réelle. Créer un rappel automatique J+30 pour le message de suivi commercial. Archiver les fichiers Drive. Saisir la note de satisfaction client si connue."},
    {"type":"list","items":["Outil : **GestiQ**","Temps : ~5 min"]},

    {"type":"divider"},

    {"type":"heading","text":"Checklist QA — à valider intégralement avant mise en ligne"},
    {"type":"checklist","items":[
      "Vitesse < 2 secondes sur mobile (GTmetrix ou PageSpeed Insights)",
      "Responsive : iPhone, Android, tablette, desktop — tous testés",
      "Tous les liens internes et externes fonctionnent",
      "Formulaire de contact : envoi testé + email de réception vérifié",
      "Bouton WhatsApp fonctionne sur mobile",
      "SSL / HTTPS actif — cadenas visible dans la barre d'adresse",
      "Google Analytics installé et données reçues en temps réel",
      "Meta tags SEO (title, description) sur toutes les pages",
      "Images optimisées (< 200Ko chacune, format WebP si possible)",
      "Favicon visible dans l'onglet du navigateur",
      "Backup complet du site effectué avant mise en ligne",
      "Textes relus — aucune faute d'orthographe ou d'information incorrecte"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-cdp-livraison-finale');


-- ── ng-cdp-kpis-rapport-mensuel (projets) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-cdp-kpis-rapport-mensuel',
  'KPIs & Rapport mensuel Chef de projet',
  'Bilan mensuel : KPIs, fiche projet par projet, 3 améliorations, rapport au fondateur.',
  'projets',
  '["KPIs","Rapport","Mensuel","Performance","Qualité"]'::jsonb,
  'Next Gital',
  3,
  false,
  $sop$[
    {"type":"callout","variant":"warning","title":"Délai","text":"Le 1er de chaque mois — avant 10h."},
    {"type":"callout","variant":"info","title":"Canal","text":"GestiQ + Email fondateur."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Mesurer la performance · Identifier les problèmes · Améliorer chaque mois."},

    {"type":"heading","text":"KPIs à suivre"},
    {"type":"table","table":{
      "headers":["Indicateur","Objectif","Fréquence"],
      "rows":[
        ["Projets livrés","4+ / mois","Mensuel"],
        ["Projets livrés dans les délais","100%","Mensuel"],
        ["Satisfaction client moyenne","8+/10","Par projet"],
        ["Révisions demandées par projet","≤ 2","Par projet"],
        ["Avis Google obtenus","2+ / mois","Mensuel"],
        ["Projets en retard","0","Mensuel"]
      ]
    }},

    {"type":"divider"},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Exporter les données du mois depuis GestiQ"},
    {"type":"paragraph","text":"GestiQ → Rapports & Export → Rapport mensuel [MOIS]. Exporter en PDF ou CSV. Vérifier : projets livrés, CA, délais respectés, satisfaction moyenne."},
    {"type":"list","items":["Outil : **GestiQ Rapports**","Temps : ~10 min"]},

    {"type":"heading2","text":"2. Remplir la fiche de bilan projet par projet"},
    {"type":"paragraph","text":"Pour chaque projet livré ce mois :"},
    {"type":"list","items":[
      "Livré dans les délais ? (O/N)",
      "Nombre de révisions effectuées",
      "Note de satisfaction client obtenue",
      "Problèmes rencontrés",
      "Leçons apprises pour la prochaine fois"
    ]},
    {"type":"list","items":["Outil : **GestiQ / Google Doc**","Temps : ~15 min"]},

    {"type":"heading2","text":"3. Identifier les 3 améliorations du mois prochain"},
    {"type":"paragraph","text":"Analyser :"},
    {"type":"numbered","items":[
      "Qu'est-ce qui a causé des retards ce mois ?",
      "Quelles révisions auraient pu être évitées avec un meilleur brief ?",
      "Quel process a besoin d'être amélioré ?"
    ]},
    {"type":"paragraph","text":"Proposer 3 actions **concrètes et réalistes**."},
    {"type":"list","items":["Outil : **Réflexion personnelle**","Temps : ~10 min"]},

    {"type":"heading2","text":"4. Envoyer le rapport au fondateur"},
    {"type":"paragraph","text":"Copier le template de rapport mensuel ci-dessous. Compléter avec les vraies données. Envoyer par email ou via GestiQ **avant 10h le 1er du mois**."},
    {"type":"template","text":"📊 RAPPORT MENSUEL — CHEF DE PROJET\nPériode : [MOIS ANNÉE]\n\n━━ PROJETS ━━\n✅ Projets livrés : [X]\n⏰ Livrés dans les délais : [X/X] ([%]%)\n🔄 Projets encore en cours : [X]\n⚠️  Projets en retard : [X]\n\n━━ QUALITÉ ━━\n⭐ Satisfaction moyenne clients : [X]/10\n✏️  Révisions moyennes par projet : [X]\n🌟 Avis Google obtenus ce mois : [X]\n\n━━ PROBLÈMES RENCONTRÉS ━━\n— [PROBLÈME 1 + CAUSE]\n— [PROBLÈME 2 + CAUSE]\n\n━━ 3 AMÉLIORATIONS POUR LE MOIS PROCHAIN ━━\n1. [ACTION CONCRÈTE 1]\n2. [ACTION CONCRÈTE 2]\n3. [ACTION CONCRÈTE 3]\n\n[Votre prénom] — Chef de projet Next Gital"},
    {"type":"list","items":["Outil : **Email / GestiQ**","Temps : ~5 min"]},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de fin de mois"},
    {"type":"checklist","items":[
      "Données du mois exportées depuis GestiQ",
      "Fiche de bilan remplie pour chaque projet livré",
      "KPIs calculés et comparés aux objectifs",
      "3 améliorations identifiées et documentées",
      "Rapport envoyé au fondateur avant 10h"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-cdp-kpis-rapport-mensuel');

COMMIT;
