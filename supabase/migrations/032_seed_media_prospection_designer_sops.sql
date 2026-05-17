-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 032 : Seed SOPs Media Buyer + Prospection + Designer
--  Date : 2026-05-17
--
--  Catégories : media_buyer, prospection, designer
--  Auteur : Next Gital · Idempotent
--  Contexte : agence web Oujda, Maroc — WordPress, Hostinger, Titan Email
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ╔════════════════════════════════════════════════════════════════╗
-- ║  MEDIA BUYER                                                   ║
-- ╚════════════════════════════════════════════════════════════════╝

-- ── ng-mb-facebook-ads (media_buyer) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-mb-facebook-ads',
  'Lancement campagne Facebook Ads',
  'Setup d''une campagne Facebook/Instagram : objectif, audience, créa, budget, A/B test, KPIs.',
  'media_buyer',
  '["Facebook","Instagram","Ads","Meta","Performance"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Lancement en 24h après brief client validé."},
    {"type":"callout","variant":"info","title":"Canal","text":"Meta Business Manager + Canva + Claude Code."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"CPL (coût par lead) optimisé selon le secteur — < 50 MAD pour les services PME Maroc."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Préparation du Business Manager"},
    {"type":"list","items":[
      "Vérifier que le **Business Manager** du client existe (sinon le créer)",
      "Ajouter Next Gital comme **partenaire** (rôle : Advertiser)",
      "Vérifier que le **Pixel** est installé sur le site (Meta Pixel Helper)",
      "Vérifier que la **conversion API** est branchée (recommandé pour iOS 17+)"
    ]},

    {"type":"heading2","text":"2. Structure de la campagne"},
    {"type":"paragraph","text":"Architecture standard Next Gital :"},
    {"type":"table","table":{
      "headers":["Niveau","Contenu"],
      "rows":[
        ["Campagne","1 objectif (Leads / Trafic / Conversions)"],
        ["Ad Sets","2–3 audiences à tester en parallèle"],
        ["Ads","3 créas différentes par ad set (vidéo + 2 statiques)"]
      ]
    }},

    {"type":"heading2","text":"3. Définir l'audience"},
    {"type":"list","items":[
      "**Localisation** : Oujda + 25km (ou ville client)",
      "**Âge** : selon persona du brief",
      "**Intérêts** : 3–5 maximum, alignés au produit",
      "**Audience large** recommandée : Meta optimise mieux (1M+ personnes)",
      "**Exclure** : convertisseurs existants (depuis le Pixel)"
    ]},

    {"type":"heading2","text":"4. Créas — règles Next Gital"},
    {"type":"list","items":[
      "**Vidéo** ≤ 15 secondes, hook dans les **3 premières secondes**",
      "**Statique** : un seul message, visuel impactant, texte ≤ 20% de l'image",
      "Format **9:16** (Stories/Reels) ET **1:1** (Feed)",
      "**Sous-titres** obligatoires sur les vidéos (85% regardent sans son)",
      "Logo client visible mais discret"
    ]},

    {"type":"heading2","text":"5. Budget et durée"},
    {"type":"list","items":[
      "Budget de test : **150–300 MAD/jour** par ad set (~50€)",
      "Durée minimum **4 jours** avant analyse (sortir de la phase d'apprentissage)",
      "Si CPL > 2× cible après 4 jours → **arrêter** et changer la créa"
    ]},

    {"type":"heading2","text":"6. Tracking et KPIs"},
    {"type":"checklist","items":[
      "Pixel actif sur toutes les pages clés",
      "Conversion API configurée (CAPI)",
      "UTM tags sur tous les liens (utm_source=fb&utm_campaign=…)",
      "Événements personnalisés configurés (Lead, Purchase, AddToCart)"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Message — rapport hebdo client"},
    {"type":"template","text":"📊 Rapport Facebook Ads — [NOM CLIENT] — Semaine [N°]\n\n💰 Budget dépensé : [X] MAD / [Y] MAD\n🎯 Leads générés : [X]\n💸 Coût par lead : [X] MAD (objectif : [Y] MAD)\n👁️ Reach : [X] personnes\n📱 CTR : [X]%\n\n🏆 Meilleure créa : [DESCRIPTION]\n📉 Créa à arrêter : [DESCRIPTION]\n\n🎯 Action semaine prochaine :\n— [ACTION 1]\n— [ACTION 2]"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de lancement"},
    {"type":"checklist","items":[
      "Pixel Meta installé et événements validés",
      "Audience définie (intérêts + exclusions)",
      "3 créas minimum prêtes (vidéo + statiques)",
      "Sous-titres présents sur les vidéos",
      "UTM tags ajoutés sur tous les liens",
      "Budget quotidien et planning définis",
      "Rapport hebdo automatique programmé"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-mb-facebook-ads');


-- ── ng-mb-tiktok-ads (media_buyer) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-mb-tiktok-ads',
  'Lancement campagne TikTok Ads',
  'Setup TikTok Ads Manager : pixel, audiences, créas UGC, budget, optimisation pour le marché marocain.',
  'media_buyer',
  '["TikTok","Ads","Vidéo","UGC","Maroc"]'::jsonb,
  'Next Gital',
  4,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Lancement sous 48h après réception des créas vidéo."},
    {"type":"callout","variant":"info","title":"Canal","text":"TikTok Ads Manager + CapCut + Claude Code."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Construire de l'audience pour les marques B2C marocaines (mode, beauté, food, services locaux)."},
    {"type":"callout","variant":"warning","title":"Quand utiliser TikTok","text":"Cible 18–34 ans, B2C. Pour B2B ou services premium → préférer Meta + LinkedIn."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Setup TikTok Pixel"},
    {"type":"paragraph","text":"TikTok Ads Manager → Assets → Events → Web Events. Installer le pixel via :"},
    {"type":"list","items":[
      "**Plugin WordPress** : TikTok for Business",
      "**Manuel** : coller le script dans `header.php` du thème enfant",
      "Vérifier avec **TikTok Pixel Helper** (extension Chrome)"
    ]},

    {"type":"heading2","text":"2. Structure de campagne TikTok"},
    {"type":"paragraph","text":"Stratégie recommandée Next Gital :"},
    {"type":"list","items":[
      "**1 campagne** par objectif (Trafic / Lead / Conversion)",
      "**3 ad groups** : audience large / audience d'intérêts / audience lookalike",
      "**5 créas par ad group** (TikTok consomme vite la créa)"
    ]},

    {"type":"heading2","text":"3. Créas — règles spécifiques TikTok"},
    {"type":"callout","variant":"danger","title":"Règle d'or","text":"Une créa qui ressemble à une pub ne marche PAS sur TikTok. Format UGC obligatoire."},
    {"type":"list","items":[
      "Format **9:16** vertical uniquement",
      "Durée **9–15 secondes** (sweet spot)",
      "Tourner avec un **smartphone**, pas une caméra pro",
      "Hook dans la **première seconde** : question, chiffre choc, mouvement",
      "Musique tendance (TikTok Commercial Music Library)",
      "Texte à l'écran obligatoire (pour le son coupé)",
      "**Pas de logo** au début — TikTok pénalise"
    ]},

    {"type":"heading2","text":"4. Budget et A/B test"},
    {"type":"list","items":[
      "Budget de test : **100–200 MAD/jour** par ad group",
      "Renouveler les créas **toutes les 2 semaines** (TikTok fatigue rapidement)",
      "Si CTR < 1% après 3 jours → couper la créa",
      "Si CTR > 2% → augmenter le budget de +20% par jour"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Prompt Claude Code — scripts vidéo TikTok"},
    {"type":"template","text":"Écris 5 scripts vidéo TikTok de 12 secondes pour un client [SECTEUR] basé à [VILLE], Maroc.\n\nFormat de chaque script :\n- Hook (1 sec) : question/chiffre/mouvement\n- Problème (3 sec) : pain point du client cible\n- Solution (5 sec) : produit/service\n- CTA (3 sec) : action à faire\n\nTon : décontracté, marocain darija acceptable.\nObjectif : générer des leads WhatsApp.\nCible : [PERSONA]\n\nFormat de sortie : tableau script + indications de tournage."},

    {"type":"divider"},

    {"type":"heading","text":"Checklist TikTok Ads"},
    {"type":"checklist","items":[
      "Pixel TikTok installé et événements validés",
      "Compte TikTok pro du client connecté (créas natives possibles)",
      "5 créas UGC vidéo prêtes (format 9:16, ≤ 15s)",
      "Sous-titres et texte à l'écran sur toutes les vidéos",
      "Budget quotidien défini",
      "UTM tags configurés",
      "Plan de renouvellement créas (toutes les 2 semaines)"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-mb-tiktok-ads');


-- ── ng-mb-google-ads (media_buyer) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-mb-google-ads',
  'Google Ads — campagnes Search Maroc',
  'Configuration Google Ads : mots-clés, annonces, extensions, conversions, optimisation continue.',
  'media_buyer',
  '["GoogleAds","Search","SEM","Conversions","Maroc"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Lancement sous 3 jours après brief client."},
    {"type":"callout","variant":"info","title":"Canal","text":"Google Ads + Google Tag Manager + Google Analytics 4."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Atteindre les prospects en intention d'achat — CPL < 80 MAD pour les services locaux Oujda."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Recherche de mots-clés (3 listes)"},
    {"type":"table","table":{
      "headers":["Liste","Type","Exemple (dentiste Oujda)"],
      "rows":[
        ["Brand","Marque + concurrents","« cabinet dr karim »"],
        ["Intention forte","Problème + solution","« dentiste oujda urgent »"],
        ["Information","Recherche large","« blanchiment dents prix »"]
      ]
    }},
    {"type":"paragraph","text":"Utiliser **Google Keyword Planner** + **Ubersuggest**. Cibler les volumes 100–10 000 recherches/mois."},

    {"type":"heading2","text":"2. Structure des campagnes"},
    {"type":"list","items":[
      "**1 campagne** par type de mot-clé (Brand / Service / Information)",
      "**1 ad group** par thématique (max 15 mots-clés)",
      "**Match type** : exact + phrase (jamais broad sans surveillance)",
      "**Negative keywords** : ajouter immédiatement « gratuit », « emploi », « stage »"
    ]},

    {"type":"heading2","text":"3. Rédaction des annonces"},
    {"type":"paragraph","text":"Format RSA (Responsive Search Ads) :"},
    {"type":"list","items":[
      "**15 titres** différents (30 caractères chacun)",
      "**4 descriptions** (90 caractères chacune)",
      "Inclure le **mot-clé exact** dans 3 titres minimum",
      "Inclure **prix / chiffre / promesse** dans les titres",
      "**CTA clair** : « Réservez », « Devis gratuit », « WhatsApp »"
    ]},

    {"type":"heading2","text":"4. Extensions obligatoires"},
    {"type":"checklist","items":[
      "**Liens annexes** (4–6) : Services, Contact, Avis, Tarifs",
      "**Accroches** (4–6) : « Avis 4.9★ », « Devis 24h », « Oujda centre »",
      "**Extraits de site** : Services proposés",
      "**Appel** (numéro WhatsApp en click-to-call)",
      "**Lieu** (lié à Google My Business)",
      "**Promotion** si campagne saisonnière"
    ]},

    {"type":"heading2","text":"5. Tracking conversions"},
    {"type":"paragraph","text":"Google Tag Manager → configurer les conversions :"},
    {"type":"list","items":[
      "**Soumission de formulaire** (form_submit)",
      "**Clic WhatsApp** (whatsapp_click)",
      "**Appel téléphonique** (call_click)",
      "**Achat WooCommerce** (purchase) — pour les e-commerces"
    ]},
    {"type":"paragraph","text":"Lier Google Ads ↔ Google Analytics 4 pour importer les audiences GA4."},

    {"type":"heading2","text":"6. Optimisation continue"},
    {"type":"list","items":[
      "**Tous les jours (10 min)** : vérifier le budget consommé + les requêtes",
      "**Toutes les semaines** : ajouter des mots-clés négatifs, ajuster les enchères",
      "**Tous les mois** : tester de nouvelles annonces (toujours 3 actives par ad group)",
      "**Trimestriellement** : audit complet + restructuration si besoin"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Message — rapport mensuel client"},
    {"type":"template","text":"📊 Rapport Google Ads — [NOM CLIENT] — [MOIS]\n\n💰 Budget dépensé : [X] MAD / [Y] MAD\n🎯 Conversions : [X] (formulaires + WhatsApp + appels)\n💸 Coût par conversion : [X] MAD\n👁️ Impressions : [X]\n🖱️ Clics : [X] · CTR : [X]%\n📍 Position moyenne : [X]\n\n🏆 Top 3 mots-clés performants :\n1. [MOT-CLÉ] — [X] conversions\n2. [MOT-CLÉ] — [X] conversions\n3. [MOT-CLÉ] — [X] conversions\n\n🎯 Actions du mois prochain :\n— [ACTION 1]\n— [ACTION 2]\n— [ACTION 3]"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist Google Ads"},
    {"type":"checklist","items":[
      "Compte Google Ads créé et facturation activée",
      "Conversions configurées (formulaire, WhatsApp, appel)",
      "Lien Google Ads ↔ GA4 actif",
      "3 listes de mots-clés validées (Brand / Service / Info)",
      "Annonces RSA avec 15 titres + 4 descriptions",
      "Toutes les extensions activées (liens, accroches, appel, lieu)",
      "Mots-clés négatifs initiaux ajoutés",
      "Rapport mensuel programmé"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-mb-google-ads');


-- ── ng-mb-google-my-business (media_buyer) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-mb-google-my-business',
  'Google My Business — optimisation locale',
  'Création et optimisation GMB : fiche complète, photos, avis, posts hebdo, Q&A.',
  'media_buyer',
  '["GoogleMyBusiness","GMB","SEOLocal","Avis","Maps"]'::jsonb,
  'Next Gital',
  4,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Configuration initiale en 1 journée. Maintenance hebdo permanente."},
    {"type":"callout","variant":"info","title":"Canal","text":"Google Business Profile + Google Maps."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Apparaître dans le **3-pack local** Google pour les recherches « [service] [ville] »."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Création / réclamation de la fiche"},
    {"type":"list","items":[
      "Aller sur business.google.com",
      "Vérifier si la fiche existe déjà — sinon la créer",
      "**Vérification** : par courrier postal (5–7 jours) ou téléphone si éligible",
      "Renseigner : nom exact (sans mot-clé bourré), adresse, téléphone, site web"
    ]},
    {"type":"callout","variant":"warning","title":"Cohérence NAP","text":"Le **N**om, l'**A**dresse, le **P**hone doivent être STRICTEMENT identiques partout (site, Facebook, annuaires)."},

    {"type":"heading2","text":"2. Optimisation de la fiche (à 100%)"},
    {"type":"checklist","items":[
      "Catégorie principale + 3 catégories secondaires pertinentes",
      "Description (750 caractères) avec mots-clés naturels",
      "Horaires d'ouverture précis (jours fériés inclus)",
      "Zone de service (rayon kilométrique si applicable)",
      "Site web + lien vers réservation/devis",
      "Numéro WhatsApp dans la description (cliquable)"
    ]},

    {"type":"heading2","text":"3. Photos — règles Next Gital"},
    {"type":"list","items":[
      "Minimum **10 photos** au lancement",
      "**Logo** carré 250×250px",
      "**Couverture** 1080×608px",
      "**Intérieur** (3+), **extérieur** (3+), **équipe** (2+), **produits/services** (5+)",
      "Format **WebP** ou JPG, < 5 MB",
      "Ajouter **2 photos par semaine** minimum"
    ]},

    {"type":"heading2","text":"4. Stratégie avis Google"},
    {"type":"paragraph","text":"Objectif : **4.7★ minimum** avec 50+ avis dans les 6 premiers mois."},
    {"type":"list","items":[
      "Demander un avis à **chaque client satisfait** (SOP Livraison J+2)",
      "Lien direct vers le formulaire d'avis : `g.page/[nom-fiche]/review`",
      "Imprimer un **QR code** vers le lien d'avis (à mettre sur facture, vitrine)",
      "**Répondre à 100% des avis** sous 48h — positifs ET négatifs",
      "Avis négatif → répondre publiquement avec calme, proposer un échange privé"
    ]},

    {"type":"heading2","text":"5. Posts GMB hebdomadaires"},
    {"type":"paragraph","text":"1 post par semaine minimum, 7 jours d'affichage. Types :"},
    {"type":"list","items":[
      "**Mise à jour** : actualités de l'entreprise",
      "**Événement** : promotion limitée dans le temps",
      "**Offre** : code promo ou offre spéciale",
      "**Produit** : mise en avant d'un service"
    ]},
    {"type":"paragraph","text":"Format : image 1200×900, titre court, CTA clair (« Réserver », « Appeler »)."},

    {"type":"heading2","text":"6. Questions & Réponses (Q&A)"},
    {"type":"paragraph","text":"Pré-remplir les questions courantes pour contrôler la narrative :"},
    {"type":"list","items":[
      "« Quels sont vos horaires d'ouverture ? »",
      "« Acceptez-vous les paiements par carte ? »",
      "« Faites-vous des livraisons ? »",
      "« Avez-vous un parking ? »"
    ]},
    {"type":"paragraph","text":"Poser la question depuis un compte différent, répondre depuis la fiche."},

    {"type":"divider"},

    {"type":"heading","text":"Message — réponse type à un avis négatif"},
    {"type":"template","text":"Bonjour [Prénom],\n\nNous sommes sincèrement désolés que votre expérience n'ait pas été à la hauteur de vos attentes.\n\nVotre retour est précieux pour nous améliorer en continu.\n\nPourriez-vous nous contacter directement au [NUMÉRO] ou par WhatsApp ? Nous aimerions comprendre exactement ce qui s'est passé et trouver une solution.\n\nÀ très bientôt,\nL'équipe [NOM CLIENT]"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist GMB"},
    {"type":"checklist","items":[
      "Fiche vérifiée et 100% complète",
      "NAP cohérent partout (site, Facebook, annuaires)",
      "10 photos minimum au lancement",
      "QR code avis imprimé pour le client",
      "Réponse aux avis sous 48h activée",
      "Post hebdomadaire programmé",
      "Q&A pré-remplies",
      "Suivi mensuel des insights (Performance)"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-mb-google-my-business');


-- ── ng-mb-rapport-mensuel (media_buyer) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-mb-rapport-mensuel',
  'Rapport mensuel Media Buyer — KPIs',
  'Bilan mensuel multi-plateformes : CPL, ROAS, dépensé, leads, actions du mois suivant.',
  'media_buyer',
  '["KPIs","Rapport","Mensuel","ROAS","CPL"]'::jsonb,
  'Next Gital',
  3,
  false,
  $sop$[
    {"type":"callout","variant":"warning","title":"Délai","text":"Le 1er de chaque mois — avant midi."},
    {"type":"callout","variant":"info","title":"Canal","text":"GestiQ + Email client + Looker Studio (optionnel)."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Démontrer le ROI des campagnes et justifier la reconduction."},

    {"type":"heading","text":"KPIs à suivre par plateforme"},
    {"type":"table","table":{
      "headers":["KPI","Définition","Cible (PME Maroc)"],
      "rows":[
        ["CPL","Coût par lead","< 50 MAD (Meta) / < 80 MAD (Google)"],
        ["CTR","Taux de clic","> 1.5% (Meta) / > 3% (Google Search)"],
        ["ROAS","Retour sur ad spend","> 3× (e-commerce)"],
        ["CPM","Coût pour 1000 impressions","< 15 MAD (Meta MA)"],
        ["Taux de conversion","Visiteurs → Leads","> 2%"]
      ]
    }},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Extraction des données"},
    {"type":"list","items":[
      "Meta Ads Manager → Export CSV du mois",
      "Google Ads → Reports → Performance",
      "GA4 → Acquisition → Traffic acquisition",
      "GMB → Performance → Calls + Direction requests",
      "WhatsApp Business → nb de conversations entrantes"
    ]},

    {"type":"heading2","text":"2. Synthèse par plateforme"},
    {"type":"paragraph","text":"Pour chaque plateforme active : remplir le template ci-dessous."},

    {"type":"heading2","text":"3. Identifier les 3 actions du mois suivant"},
    {"type":"list","items":[
      "**1 optimisation** d'une campagne existante (créa, audience, enchères)",
      "**1 test** : nouvelle plateforme, nouvelle audience ou nouvel angle",
      "**1 levier** : action sur le funnel (landing page, formulaire, follow-up)"
    ]},

    {"type":"heading2","text":"4. Envoi au client"},
    {"type":"paragraph","text":"Email avec PDF ou lien Looker Studio. Garder le ton professionnel, transparent — montrer les échecs autant que les succès."},

    {"type":"divider"},

    {"type":"heading","text":"Template rapport client"},
    {"type":"template","text":"📊 RAPPORT MEDIA BUYER — [NOM CLIENT]\nPériode : [MOIS ANNÉE]\n\n━━ INVESTISSEMENT GLOBAL ━━\n💰 Budget total : [X] MAD\n📊 Plateformes : Facebook · Google · TikTok\n\n━━ RÉSULTATS GLOBAUX ━━\n🎯 Leads générés : [X]\n💸 Coût par lead moyen : [X] MAD\n📈 ROAS : [X]× (si e-commerce)\n📞 Appels reçus : [X]\n💬 Conversations WhatsApp : [X]\n\n━━ PAR PLATEFORME ━━\n\nFACEBOOK / INSTAGRAM :\n• Dépensé : [X] MAD\n• Leads : [X] · CPL : [X] MAD\n• Meilleure créa : [DESCRIPTION]\n\nGOOGLE ADS :\n• Dépensé : [X] MAD\n• Conversions : [X] · Coût : [X] MAD\n• Top mot-clé : [MOT-CLÉ]\n\nTIKTOK ADS (si actif) :\n• Dépensé : [X] MAD\n• Engagement : [X] vues / [X] clics\n\n━━ ACTIONS MOIS PROCHAIN ━━\n1. [OPTIMISATION]\n2. [TEST]\n3. [LEVIER FUNNEL]\n\n[Votre prénom] — Media Buyer Next Gital"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist rapport mensuel"},
    {"type":"checklist","items":[
      "Données extraites de toutes les plateformes actives",
      "KPIs calculés et comparés au mois précédent",
      "3 actions concrètes définies pour le mois suivant",
      "Rapport envoyé avant midi le 1er du mois",
      "Réunion mensuelle planifiée si client premium"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-mb-rapport-mensuel');


-- ╔════════════════════════════════════════════════════════════════╗
-- ║  PROSPECTION                                                   ║
-- ╚════════════════════════════════════════════════════════════════╝

-- ── ng-pr-linkedin (prospection) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-pr-linkedin',
  'Prospection LinkedIn',
  'Process LinkedIn : profil optimisé, recherche ciblée, séquence de messages, conversion en RDV.',
  'prospection',
  '["LinkedIn","B2B","Cold","Outreach","RDV"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"30 min/jour, 5 jours sur 7."},
    {"type":"callout","variant":"info","title":"Canal","text":"LinkedIn Sales Navigator + Calendly + GestiQ CRM."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Générer **5 RDV qualifiés par semaine** avec des dirigeants de PME marocaines."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Profil LinkedIn optimisé (à faire une seule fois)"},
    {"type":"checklist","items":[
      "Photo professionnelle (visage net, fond uni)",
      "Bannière personnalisée avec proposition de valeur",
      "Titre : « J'aide [CIBLE] à [BÉNÉFICE] »",
      "Section À propos : storytelling + preuves + CTA",
      "Sélection de 3 services à mettre en avant",
      "Lien vers site Next Gital + Calendly visibles"
    ]},

    {"type":"heading2","text":"2. Recherche de prospects (Sales Navigator)"},
    {"type":"paragraph","text":"Filtres recommandés pour le marché marocain :"},
    {"type":"list","items":[
      "**Géographie** : Maroc (ou région spécifique)",
      "**Secteur** : selon ICP (Ideal Customer Profile)",
      "**Taille entreprise** : 2–50 employés (PME)",
      "**Fonction** : Owner / CEO / Manager / Directeur",
      "**Ancienneté** : 1 an+ dans le poste"
    ]},
    {"type":"paragraph","text":"Sauvegarder la recherche → exporter 50 prospects/semaine."},

    {"type":"heading2","text":"3. Séquence de messages — 4 touches"},

    {"type":"heading3","text":"Touche 1 — Connexion (J0)"},
    {"type":"template","text":"Bonjour [Prénom],\n\nJ'ai vu votre profil et votre activité dans [SECTEUR] à [VILLE] — ça résonne avec ce qu'on fait chez Next Gital.\n\nJ'aimerais vous ajouter à mon réseau si vous êtes ouvert.\n\nBonne journée 🙏"},

    {"type":"heading3","text":"Touche 2 — Brise-glace (J+2)"},
    {"type":"template","text":"Merci d'avoir accepté [Prénom] ! 🙏\n\nJ'ai regardé rapidement votre [SITE / page Facebook / Instagram] — vraiment intéressant ce que vous faites.\n\nJuste par curiosité : c'est vous qui gérez la partie digital/communication, ou vous avez quelqu'un dédié ?\n\n(Aucune intention commerciale ici, je découvre votre activité)"},

    {"type":"heading3","text":"Touche 3 — Valeur (J+5)"},
    {"type":"template","text":"[Prénom], en regardant votre [SITE / présence digitale], j'ai noté 2–3 points qui pourraient facilement vous amener plus de clients à [VILLE] :\n\n1. [POINT SPÉCIFIQUE 1]\n2. [POINT SPÉCIFIQUE 2]\n\nSi ça vous intéresse, je peux vous envoyer une mini-vidéo Loom de 5 min pour expliquer concrètement. Aucune obligation, c'est gratuit.\n\nÇa vous parle ?"},

    {"type":"heading3","text":"Touche 4 — Appel à l'action (J+10)"},
    {"type":"template","text":"Bonjour [Prénom],\n\nDernier message de ma part — je ne veux pas vous spammer 🙏\n\nSi un jour vous voulez discuter de votre stratégie digitale (gratuitement, 20 min), voici mon lien :\n📅 [LIEN CALENDLY]\n\nSinon, je vous souhaite une excellente continuation et beaucoup de succès avec [ENTREPRISE].\n\nBonne journée !"},

    {"type":"heading2","text":"4. Suivi dans GestiQ"},
    {"type":"paragraph","text":"Pour chaque prospect ajouté :"},
    {"type":"list","items":[
      "Créer une fiche Prospect dans GestiQ → CRM",
      "Tag : `linkedin-cold`",
      "Statut : `Contact initial` → `Brise-glace` → `Valeur` → `RDV` ou `Perdu`",
      "Note la date de chaque touche",
      "Stopper après 4 touches sans réponse — passer en `Perdu`"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Checklist quotidienne (30 min)"},
    {"type":"checklist","items":[
      "10 nouvelles invitations envoyées",
      "Suivre les 4 touches en cours (jusqu'à 20 prospects actifs)",
      "Répondre aux messages reçus sous 1h",
      "Mettre à jour GestiQ pour chaque interaction",
      "Programmer 2 RDV via Calendly"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-pr-linkedin');


-- ── ng-pr-whatsapp-cold (prospection) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-pr-whatsapp-cold',
  'Prospection WhatsApp — messages à froid',
  'Cold outreach WhatsApp pour PME marocaines : sourcing, premier message, relance, conversion.',
  'prospection',
  '["WhatsApp","Cold","Outreach","PME","Maroc"]'::jsonb,
  'Next Gital',
  4,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"45 min/jour, du lundi au vendredi."},
    {"type":"callout","variant":"info","title":"Canal","text":"WhatsApp Business + GestiQ CRM."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Convertir **3% des messages froids en RDV**."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Jamais plus de 20 messages froids par jour depuis un seul numéro — WhatsApp bannit les comptes spammeurs."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Sourcing des numéros (sans spammer)"},
    {"type":"list","items":[
      "Google Maps → fiches d'entreprises locales → numéros affichés publiquement",
      "Pages Facebook / Instagram pro → bouton Contact",
      "Annuaires marocains : Telecontact, Pages Jaunes Maroc",
      "Salons et événements professionnels (cartes de visite)",
      "Recommandations clients existants (warm)"
    ]},
    {"type":"callout","variant":"warning","title":"Légal","text":"Ne pas acheter de bases de données. Ne contacter que les numéros affichés **publiquement** comme contact professionnel."},

    {"type":"heading2","text":"2. Premier message — règles d'or"},
    {"type":"numbered","items":[
      "**Court** : 4 lignes max",
      "**Personnalisé** : nom + référence spécifique à leur business",
      "**Pas de pitch commercial** dans le 1er message",
      "**Question ouverte** pour amorcer un échange",
      "**Pas d'emojis spam** (max 1–2)"
    ]},
    {"type":"template","text":"Bonjour [Prénom] 👋\n\nJ'ai découvert [NOM ENTREPRISE] via [SOURCE PRÉCISE : Google, recommandation, Instagram].\n\nJ'ai été marqué par [DÉTAIL SPÉCIFIQUE — un produit, un service, une photo].\n\nPetite question : est-ce vous qui gérez la partie communication/digital, ou quelqu'un d'autre dans l'équipe ?\n\n(Je vous demande car j'aurai peut-être une idée à vous partager — sans obligation)"},

    {"type":"heading2","text":"3. Si réponse positive → message #2"},
    {"type":"template","text":"Super 🙏\n\nDonc voilà : on est une agence digitale basée à Oujda (Next Gital). On aide les PME à avoir plus de clients via WhatsApp + Google + Facebook.\n\nEn regardant votre [SITE / FACEBOOK / INSTAGRAM], j'ai vu 2 petites choses simples qui pourraient vous amener +20-30% de demandes :\n\n• [POINT 1]\n• [POINT 2]\n\nSi ça vous intéresse, je peux vous expliquer concrètement en 15 min (gratuit, sans engagement).\n\nVous êtes dispo cette semaine ?"},

    {"type":"heading2","text":"4. Relance unique — J+3 si pas de réponse"},
    {"type":"template","text":"Bonjour [Prénom],\n\nJuste un petit rappel — pas de pression, c'était par rapport à mon message d'avant-hier sur votre activité.\n\nSi le moment n'est pas bon ou ce n'est pas votre priorité actuellement, aucun souci 🙏\n\nBonne continuation à vous et [ENTREPRISE] !"},

    {"type":"callout","variant":"danger","title":"Règle absolue","text":"**1 seule relance maximum**. Au-delà → marquer le prospect comme `Perdu` dans GestiQ et passer au suivant."},

    {"type":"heading2","text":"5. Tracking GestiQ"},
    {"type":"list","items":[
      "Créer une fiche Prospect dans GestiQ pour chaque numéro contacté",
      "Tag : `whatsapp-cold`",
      "Source : préciser (Google Maps, Facebook, etc.)",
      "Date de chaque message",
      "Statut : `Contacté` → `Échange` → `RDV pris` → `Perdu` ou `Client`"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Checklist quotidienne"},
    {"type":"checklist","items":[
      "20 prospects sourcés et notés dans GestiQ",
      "20 premiers messages personnalisés envoyés (max)",
      "Relances J+3 effectuées (1 seule par prospect)",
      "Réponses traitées sous 1h",
      "Tous les RDV pris programmés dans Calendly + GestiQ",
      "Aucun message identique copié-collé à 5+ prospects"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-pr-whatsapp-cold');


-- ── ng-pr-terrain-oujda (prospection) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-pr-terrain-oujda',
  'Prospection terrain — Oujda et région',
  'Visites en porte-à-porte ciblées : préparation, pitch, suivi, conversion.',
  'prospection',
  '["Terrain","Oujda","Local","B2B","Visite"]'::jsonb,
  'Next Gital',
  4,
  false,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"2 demi-journées par semaine — mardi et jeudi matins."},
    {"type":"callout","variant":"info","title":"Canal","text":"Visites en personne + Google Maps + GestiQ."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Visiter 15 entreprises par session, obtenir 3 RDV planifiés."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Préparation avant la sortie"},
    {"type":"checklist","items":[
      "Choisir une **zone précise** (rue, quartier, centre commercial)",
      "Pré-lister 20 commerces via Google Maps",
      "**Cartes de visite** Next Gital (minimum 30)",
      "**Plaquette commerciale** PDF imprimée (10 copies)",
      "Tablette / smartphone avec démo GestiQ",
      "Tenue professionnelle (chemise, pas de t-shirt)"
    ]},

    {"type":"heading2","text":"2. Approche au comptoir"},
    {"type":"paragraph","text":"Pitch de 30 secondes maximum :"},
    {"type":"quote","text":"« Bonjour, je suis [Prénom] de Next Gital, une agence digitale basée ici à Oujda. On aide les commerçants et professionnels à avoir plus de clients via Google et WhatsApp. Vous avez 2 minutes pour qu'on échange, ou je peux laisser ma carte au responsable ? »"},

    {"type":"heading2","text":"3. Si le décideur est présent"},
    {"type":"numbered","items":[
      "Se présenter + remettre la carte",
      "**Poser une question** : « Comment vous attirez vos nouveaux clients actuellement ? »",
      "Écouter — laisser parler 80% du temps",
      "Identifier UN problème spécifique évoqué",
      "**Ne pas vendre** : proposer un audit gratuit (15 min en visio ou sur place)",
      "Prendre rendez-vous **séance tenante** si possible"
    ]},

    {"type":"heading2","text":"4. Si le décideur est absent"},
    {"type":"list","items":[
      "Laisser la carte + plaquette au comptoir",
      "Demander : « Quel est le meilleur moment pour repasser et rencontrer [PRÉNOM DÉCIDEUR] ? »",
      "Noter dans GestiQ : nom commerce, adresse, jour/heure de retour idéal",
      "Repasser à la date convenue (max 1 semaine après)"
    ]},

    {"type":"heading2","text":"5. Suivi post-visite (le soir même)"},
    {"type":"list","items":[
      "Créer une fiche Prospect dans GestiQ pour **chaque visite**",
      "Tag : `terrain-oujda` + nom de la rue/zone",
      "Statut : `Contact initial` ou `Carte laissée` ou `RDV pris`",
      "Note : observation sur le commerce (atmosphère, niveau d'activité, besoins potentiels)",
      "Si RDV pris : confirmer par WhatsApp dans la journée"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Message — confirmation RDV par WhatsApp (le soir)"},
    {"type":"template","text":"Bonjour [Prénom],\n\nC'était un plaisir de vous rencontrer aujourd'hui à [NOM COMMERCE] 🙏\n\nJe vous confirme notre rendez-vous :\n📅 [JOUR] à [HEURE]\n📍 [LIEU : chez vous / nos bureaux / visio]\n\nDurée : 15–20 minutes.\nObjectif : vous donner 2–3 idées concrètes pour amener plus de clients.\n\nÀ très bientôt 👋\nNext Gital — Oujda"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist par session"},
    {"type":"checklist","items":[
      "Zone définie et 20 commerces pré-listés",
      "Matériel imprimé (cartes + plaquettes)",
      "15 visites effectuées dans la session",
      "Toutes les fiches Prospect créées le soir même",
      "Confirmations WhatsApp envoyées aux RDV pris",
      "Sortie de la journée évaluée (combien de RDV / combien de visites)"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-pr-terrain-oujda');


-- ── ng-pr-partenariats (prospection) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-pr-partenariats',
  'Stratégie partenariats — apporteurs d''affaires',
  'Identifier, démarcher et gérer des partenaires apporteurs d''affaires (comptables, designers, imprimeurs).',
  'prospection',
  '["Partenariats","Apporteurs","Réseau","Commission","Win-Win"]'::jsonb,
  'Next Gital',
  4,
  false,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Approche continue — viser 1 nouveau partenaire actif par mois."},
    {"type":"callout","variant":"info","title":"Canal","text":"LinkedIn + visites + Calendly."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Construire un réseau de **10 partenaires actifs** qui amènent 2 leads/mois chacun."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Identifier les partenaires complémentaires"},
    {"type":"paragraph","text":"Profils cibles à Oujda :"},
    {"type":"list","items":[
      "**Cabinets comptables** — conseillent les nouvelles PME",
      "**Imprimeurs / typographes** — clients ouvrent des commerces",
      "**Designers freelance** — n'ont pas la partie dev/marketing",
      "**Photographes pros** — collaborent sur les projets web",
      "**Avocats / notaires** — réseau de patrons-créateurs",
      "**Agences immobilières** — propriétaires lançant des activités"
    ]},

    {"type":"heading2","text":"2. Prendre contact"},
    {"type":"paragraph","text":"Ordre recommandé :"},
    {"type":"numbered","items":[
      "Connexion LinkedIn personnalisée",
      "Échange de quelques messages pour découvrir leur activité",
      "**Proposer un café** (pas un RDV commercial)",
      "Lors du café : trouver des **synergies concrètes**",
      "Conclure par un accord clair (verbal puis écrit)"
    ]},

    {"type":"heading2","text":"3. Modèles de commission"},
    {"type":"table","table":{
      "headers":["Type","Modèle","Avantage"],
      "rows":[
        ["Commission directe","10–15% du montant TTC du 1er projet","Simple, motivant"],
        ["Forfait fixe","500–1500 MAD par client converti","Prévisible pour le partenaire"],
        ["Échange croisé","Recommandations mutuelles","Aucun cash, juste de la valeur"],
        ["Programme affilié","5% sur 12 mois (récurrence)","Long terme, fidélise"]
      ]
    }},
    {"type":"callout","variant":"warning","title":"Choix conseillé","text":"**Échange croisé** au début pour valider la qualité. Si ça fonctionne → passer en commission directe."},

    {"type":"heading2","text":"4. Outiller le partenaire"},
    {"type":"list","items":[
      "Plaquette personnalisée avec son logo + le nôtre",
      "Lien de tracking unique (ex: `nextgital.com/?ref=partenaire1`)",
      "Tarifs simples et clairs à communiquer",
      "Argumentaire de présentation (1 page)",
      "Démo Loom de 5 min à partager facilement"
    ]},

    {"type":"heading2","text":"5. Maintenir la relation"},
    {"type":"list","items":[
      "**Mensuel** : café ou appel pour faire le point",
      "**Trimestriel** : envoyer un cadeau ou faire une attention (anniversaire, fête)",
      "**Annuel** : réunion bilan + projection (et payer les commissions à jour)",
      "**Toujours** : recommander **eux-mêmes** dans son réseau"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Message — première approche à un partenaire potentiel"},
    {"type":"template","text":"Bonjour [Prénom],\n\nJe vois qu'on partage probablement les mêmes clients à Oujda — vous côté [LEUR MÉTIER], nous côté digital/web.\n\nJe ne cherche rien de précis, juste à connecter avec des pros locaux complémentaires.\n\nUn café à l'occasion ? Je vous laisse choisir le moment 🙏\n\nNext Gital — Oujda"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist par partenaire"},
    {"type":"checklist","items":[
      "Identifié et qualifié (potentiel de leads)",
      "Premier contact pris (LinkedIn ou direct)",
      "Café/RDV réalisé",
      "Accord formalisé (verbal puis email récap)",
      "Outils remis (plaquette, lien tracking, argumentaire)",
      "Suivi mensuel programmé dans GestiQ"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-pr-partenariats');


-- ╔════════════════════════════════════════════════════════════════╗
-- ║  DESIGNER                                                      ║
-- ╚════════════════════════════════════════════════════════════════╝

-- ── ng-ds-charte-graphique (designer) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-ds-charte-graphique',
  'Création de charte graphique client',
  'Process complet : brief, recherche, palette, typographie, logo system, livraison.',
  'designer',
  '["Charte","Branding","Identité","Logo","Couleurs"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"7 à 10 jours selon complexité."},
    {"type":"callout","variant":"info","title":"Canal","text":"Figma + Adobe Illustrator + Google Drive."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Livrer une identité cohérente et utilisable sur tous les supports (web, print, réseaux)."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Brief créatif approfondi"},
    {"type":"paragraph","text":"Questionnaire à faire remplir au client :"},
    {"type":"list","items":[
      "**Activité** et public cible (persona)",
      "**Valeurs** de la marque (3 mots maximum)",
      "**Concurrents** : 3 à analyser",
      "**Inspirations** : 5 marques aimées (mood)",
      "**À éviter** : couleurs, styles ou symboles refusés",
      "**Usage prévu** : web, print, packaging, signalétique ?"
    ]},

    {"type":"heading2","text":"2. Mood board (J+2)"},
    {"type":"list","items":[
      "20–30 images sourcées (Pinterest, Behance, Dribbble)",
      "3 directions visuelles différentes proposées",
      "Présentation Figma partagée au client pour validation",
      "Délai client pour choisir 1 direction : 48h"
    ]},

    {"type":"heading2","text":"3. Palette de couleurs"},
    {"type":"paragraph","text":"Composition standard Next Gital :"},
    {"type":"table","table":{
      "headers":["Rôle","Quantité","Exemple"],
      "rows":[
        ["Primaire","1 couleur","Bleu marine #1E3A5F"],
        ["Secondaire","1 couleur","Or pâle #C9A961"],
        ["Accent","1 couleur","Corail #FF6B6B"],
        ["Neutres","3 nuances","Blanc cassé / Gris clair / Gris foncé"],
        ["Sémantiques","4 couleurs","Vert (succès) / Rouge (alerte) / Ambre (attention) / Bleu (info)"]
      ]
    }},
    {"type":"callout","variant":"warning","title":"Accessibilité","text":"Vérifier le contraste WCAG AA (4.5:1 pour le texte normal) sur webaim.org/resources/contrastchecker."},

    {"type":"heading2","text":"4. Typographie"},
    {"type":"list","items":[
      "**1 police titre** : avec personnalité (display, serif, custom)",
      "**1 police corps** : ultra lisible (sans-serif, optimisée écran)",
      "Préférer **Google Fonts** ou Adobe Fonts (licences libres)",
      "Définir l'échelle typographique (H1 → caption)",
      "Tester sur mobile (police corps ≥ 16px)"
    ]},

    {"type":"heading2","text":"5. Logo system"},
    {"type":"list","items":[
      "**Logo principal** : version horizontale avec baseline",
      "**Logo monogramme** : version carrée pour réseaux sociaux (avatar)",
      "**Logo vertical** : pour formats portrait",
      "**Logo monochrome** : noir et blanc",
      "**Logo inversé** : sur fond foncé",
      "Zone de protection définie (espace minimum autour du logo)",
      "Taille minimum d'utilisation (web : 80px / print : 25mm)"
    ]},

    {"type":"heading2","text":"6. Fichier de charte (PDF + Figma)"},
    {"type":"paragraph","text":"Document de charte minimum 15 pages :"},
    {"type":"numbered","items":[
      "Page de garde",
      "Histoire de la marque",
      "Logo (toutes les versions + usages interdits)",
      "Palette couleurs (HEX, RGB, CMYK, Pantone)",
      "Typographie (échelle + usages)",
      "Iconographie (style + bibliothèque)",
      "Photographie (style + exemples)",
      "Applications (cartes de visite, papeterie, réseaux)"
    ]},

    {"type":"heading2","text":"7. Livraison"},
    {"type":"paragraph","text":"Dossier Drive structuré :"},
    {"type":"list","items":[
      "`/01_Charte_PDF` — document final",
      "`/02_Logos_Vectoriels` — AI, EPS, SVG, PDF",
      "`/03_Logos_PNG` — toutes versions, fond transparent",
      "`/04_Polices` — fichiers de police (.ttf, .woff2)",
      "`/05_Templates` — réseaux sociaux, cartes, papeterie",
      "`/06_Source_Figma` — fichier Figma partagé"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Message — livraison de la charte"},
    {"type":"template","text":"🎨 Votre charte graphique est livrée [Prénom] !\n\nVoici votre dossier complet :\n📁 [LIEN GOOGLE DRIVE]\n\nIl contient :\n📘 Charte PDF (15 pages)\n🎨 Logos vectoriels (AI, EPS, SVG)\n🖼️ Logos PNG (toutes versions)\n✏️ Templates réseaux sociaux\n📐 Fichier Figma source\n\nVous avez maintenant tout ce qu'il faut pour communiquer de façon cohérente partout.\n\nProchaine étape : application sur votre site web ! 🚀"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist charte"},
    {"type":"checklist","items":[
      "Brief créatif rempli et validé",
      "Mood board présenté — direction choisie",
      "Palette couleurs avec contraste accessibilité validé",
      "Typographie testée mobile + desktop",
      "Logo decliné en 5 versions minimum",
      "Charte PDF rédigée et relue",
      "Dossier Drive structuré et partagé",
      "Templates de base livrés (carte de visite, post Instagram)"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-ds-charte-graphique');


-- ── ng-ds-visuels-reseaux (designer) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-ds-visuels-reseaux',
  'Visuels réseaux sociaux — Canva & Figma',
  'Production de posts Instagram/Facebook : formats, templates, calendrier, batching.',
  'designer',
  '["Canva","Figma","Instagram","Facebook","ContentDesign"]'::jsonb,
  'Next Gital',
  4,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"30 visuels par mois et par client (1h par lot de 5)."},
    {"type":"callout","variant":"info","title":"Canal","text":"Canva Pro + Figma + Google Drive."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Produire vite des visuels cohérents avec la charte client."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Formats standards à maîtriser"},
    {"type":"table","table":{
      "headers":["Plateforme","Format","Dimensions"],
      "rows":[
        ["Instagram Post","Carré","1080 × 1080"],
        ["Instagram Story","Vertical","1080 × 1920"],
        ["Instagram Reel cover","Vertical","1080 × 1920"],
        ["Facebook Post","Paysage","1200 × 630"],
        ["Facebook Cover","Bannière","1640 × 859"],
        ["LinkedIn Post","Carré ou paysage","1200 × 1200 ou 1200 × 627"],
        ["TikTok / Reels","Vertical","1080 × 1920"]
      ]
    }},

    {"type":"heading2","text":"2. Préparer un kit Canva par client"},
    {"type":"list","items":[
      "**Brand Kit** Canva avec : logo, couleurs, polices",
      "**5 templates** carrousels (Instagram)",
      "**5 templates** stories",
      "**3 templates** posts Facebook",
      "**1 template** cover réseaux",
      "Partager le brand kit avec le client (consultation seulement)"
    ]},

    {"type":"heading2","text":"3. Workflow de batching (1h pour 5 visuels)"},
    {"type":"numbered","items":[
      "Lister les 5 sujets en amont (calendrier éditorial mensuel)",
      "Choisir le template adéquat par sujet",
      "Importer les images sources (photos client / banques d'images)",
      "Remplir titre + description + CTA",
      "Vérifier la cohérence visuelle entre les 5",
      "Exporter en lot (PNG haute résolution)",
      "Uploader dans Drive client + planifier dans le calendrier éditorial"
    ]},

    {"type":"heading2","text":"4. Règles de design Next Gital"},
    {"type":"list","items":[
      "**Hiérarchie claire** : 1 titre principal + 1 sous-titre + 1 CTA",
      "**Espace blanc** : laisser respirer le visuel (marges de 60px minimum)",
      "**Texte lisible** : taille minimum 28px sur post carré",
      "**Maximum 2 polices** par visuel",
      "**Logo discret** mais toujours visible (coin)",
      "**Couleurs charte** uniquement — pas d'écart"
    ]},

    {"type":"heading2","text":"5. Banques d'images recommandées"},
    {"type":"list","items":[
      "**Unsplash** (gratuit, qualité pro)",
      "**Pexels** (gratuit, diversité)",
      "**Canva** (intégré, large bibliothèque)",
      "**Photos client** (toujours privilégier l'authentique)",
      "Éviter : photos clichées corporate type « équipe diverse souriante »"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Checklist par lot"},
    {"type":"checklist","items":[
      "Sujets définis dans le calendrier éditorial",
      "Templates Canva chargés avec la brand kit du client",
      "5 visuels exportés en PNG haute résolution",
      "Cohérence visuelle vérifiée entre les 5",
      "Posts planifiés dans le calendrier éditorial",
      "Drive client mis à jour"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-ds-visuels-reseaux');


-- ── ng-ds-figma-maquettes (designer) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-ds-figma-maquettes',
  'Figma — maquettes site web',
  'Process maquettage : wireframe, design, prototype, handoff au développeur.',
  'designer',
  '["Figma","Maquettes","Webdesign","Prototype","Handoff"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"3 à 7 jours selon nombre de pages."},
    {"type":"callout","variant":"info","title":"Canal","text":"Figma (compte Next Gital)."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Livrer des maquettes prêtes à coder par le développeur Elementor."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Wireframe basse-fidélité (J+1)"},
    {"type":"paragraph","text":"Structure uniquement, sans couleurs ni images. Objectif : valider la disposition et le parcours utilisateur."},
    {"type":"list","items":[
      "Frames mobile (375px) ET desktop (1440px)",
      "Boîtes grises + textes Lorem Ipsum",
      "Hiérarchie des blocs claire",
      "Présenter au client pour validation **avant** de passer au design"
    ]},

    {"type":"heading2","text":"2. Design haute-fidélité"},
    {"type":"paragraph","text":"Appliquer la charte graphique sur le wireframe validé :"},
    {"type":"list","items":[
      "Charger les styles (couleurs, polices) depuis la charte",
      "Créer des **composants** Figma pour les blocs récurrents (boutons, cards)",
      "Utiliser **Auto Layout** pour faciliter le responsive",
      "Insérer les vraies images / textes du client (jamais Lorem Ipsum en validation)",
      "Créer la version **mobile** ET **desktop** de chaque page"
    ]},

    {"type":"heading2","text":"3. Prototype cliquable"},
    {"type":"list","items":[
      "Connecter les pages entre elles (Prototype tab)",
      "Activer les **hover states** sur les boutons",
      "Ajouter les **transitions** (smart animate)",
      "Partager le lien de prototype au client pour validation finale"
    ]},

    {"type":"heading2","text":"4. Handoff au développeur (Elementor)"},
    {"type":"paragraph","text":"Préparer le fichier pour le dev :"},
    {"type":"list","items":[
      "**Nommer toutes les frames** clairement (`home`, `services`, `contact`, etc.)",
      "**Espacer** les frames de 200px pour éviter les overlaps",
      "Activer le mode **Dev Mode** (inspection CSS automatique)",
      "Exporter les **assets** : icônes en SVG, images en WebP/PNG 2x",
      "Documenter les **animations** demandées en commentaires Figma",
      "Partager le fichier en mode **viewer** (pas édition)"
    ]},

    {"type":"heading2","text":"5. Validation client — règles"},
    {"type":"list","items":[
      "**2 allers-retours** maximum inclus dans le devis",
      "Retours collectés via les **commentaires Figma** (jamais WhatsApp)",
      "Validation finale **par email** avant handoff au développeur",
      "Toute modification après validation → devis complémentaire"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Checklist maquettes"},
    {"type":"checklist","items":[
      "Wireframe basse-fidélité validé par le client",
      "Charte graphique appliquée correctement",
      "Versions mobile ET desktop de chaque page",
      "Composants Figma créés (boutons, cards, etc.)",
      "Prototype cliquable fonctionnel",
      "Validation client obtenue par email",
      "Fichier Dev Mode prêt pour le développeur",
      "Assets exportés (icônes SVG, images optimisées)"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-ds-figma-maquettes');


-- ── ng-ds-standards-nextgital (designer) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-ds-standards-nextgital',
  'Standards graphiques Next Gital',
  'Les règles internes Next Gital : grilles, espacements, accessibilité, qualité de livraison.',
  'designer',
  '["Standards","Qualité","Accessibilité","Grille","Livraison"]'::jsonb,
  'Next Gital',
  3,
  false,
  $sop$[
    {"type":"callout","variant":"info","title":"Usage","text":"Référence permanente pour tout designer chez Next Gital."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Garantir une qualité constante sur tous les projets."},

    {"type":"heading","text":"Système de grille"},
    {"type":"list","items":[
      "**Desktop** : 12 colonnes, gouttière 24px, marges latérales 80px",
      "**Tablette** (768px) : 8 colonnes, gouttière 16px",
      "**Mobile** (375px) : 4 colonnes, gouttière 16px, marges 20px",
      "Container max : **1200px** sur desktop"
    ]},

    {"type":"heading","text":"Espacements (système de 8)"},
    {"type":"paragraph","text":"Utiliser uniquement des multiples de 8 pour tous les espacements :"},
    {"type":"table","table":{
      "headers":["Taille","Valeur","Usage"],
      "rows":[
        ["XS","8px","Espace inter-éléments serré"],
        ["S","16px","Espace standard interne"],
        ["M","24px","Espace entre composants"],
        ["L","48px","Espace entre sections internes"],
        ["XL","80px","Espace entre sections majeures"],
        ["XXL","120px","Padding vertical de section"]
      ]
    }},

    {"type":"heading","text":"Accessibilité — règles obligatoires"},
    {"type":"checklist","items":[
      "Contraste texte/fond ≥ **4.5:1** (WCAG AA)",
      "Taille de police corps ≥ **16px**",
      "Bouton cible tactile ≥ **44×44px**",
      "**Alt text** sur toutes les images",
      "Hiérarchie H1 → H6 logique",
      "États focus visibles sur tous les éléments interactifs"
    ]},

    {"type":"heading","text":"Iconographie"},
    {"type":"list","items":[
      "Bibliothèque par défaut : **Lucide** (cohérence avec GestiQ)",
      "Style **outline** uniforme (jamais mixer outline et filled)",
      "Taille standard : 24px (peut varier 16/20/32 selon contexte)",
      "Stroke 2px",
      "Toujours en SVG vectoriel"
    ]},

    {"type":"heading","text":"Photographie"},
    {"type":"list","items":[
      "Format **WebP** ou JPG optimisé (< 200Ko après compression)",
      "Dimensions cohérentes par usage (héros : 1920×1080, card : 800×600, etc.)",
      "**Style cohérent** : luminosité, saturation, traitement",
      "Privilégier les photos **authentiques** du client",
      "Si banque d'images : éviter les clichés corporate"
    ]},

    {"type":"heading","text":"Naming des fichiers"},
    {"type":"paragraph","text":"Convention obligatoire :"},
    {"type":"code","text":"[client]_[type]_[detail]_[version].[ext]\n\nExemples :\n— durif_logo_principal_v3.svg\n— durif_post_instagram_promo_v1.png\n— durif_charte_v2_final.pdf"},

    {"type":"heading","text":"Qualité de livraison"},
    {"type":"checklist","items":[
      "Tous les fichiers dans un dossier Drive structuré",
      "PNG haute résolution + SVG vectoriel pour chaque logo",
      "Aperçu PDF de chaque livrable",
      "Naming respecté",
      "README.txt avec les usages recommandés (où utiliser quoi)",
      "Mots de passe Figma client partagés via Drive sécurisé"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Outils Next Gital — référence"},
    {"type":"table","table":{
      "headers":["Besoin","Outil principal","Alternative"],
      "rows":[
        ["Vector & logos","Adobe Illustrator","Figma"],
        ["Maquettes web","Figma","–"],
        ["Visuels réseaux","Canva Pro","Figma"],
        ["Compression image","Squoosh","TinyPNG"],
        ["Compression SVG","SVGOMG","–"],
        ["Mockups produits","Smart Mockups","Placeit"],
        ["Banque d'images","Unsplash","Pexels"]
      ]
    }}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-ds-standards-nextgital');

COMMIT;
