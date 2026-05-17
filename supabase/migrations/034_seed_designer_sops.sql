-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 034 : Seed des 6 SOPs « Designer / Graphiste »
--  Date : 2026-05-17
--
--  Catégorie : designer · Auteur : Next Gital · Idempotent
--  Outils : Canva Pro · Figma · Adobe Express · Unsplash · Freepik
--  Insère pour TOUS les tenants existants.
--
--  Conformité ARCHITECTURE_TENANT.md :
--    - tenant_id NOT NULL, contrôle d'existence par (tenant_id, slug)
--    - RLS déjà actif sur public.sops (migration 025)
--    - Pas de modification de la structure existante
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ── ng-design-brief-client (designer) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-design-brief-client',
  'Brief design client — collecter toutes les infos avant de commencer',
  'Charte couleurs + polices, moodboard, analyse concurrents et récupération des assets avant de toucher à Canva ou Figma.',
  'designer',
  '["Brief","Design","Client","Avant","Charte"]'::jsonb,
  'Next Gital',
  4,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Jour 1 du projet — avant tout travail visuel."},
    {"type":"callout","variant":"info","title":"Canal","text":"GestiQ + WhatsApp + Google Drive."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Avoir toutes les infos pour créer sans demander 10 fois au client."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"80% des retours clients viennent d'un brief mal fait. 10 minutes de brief = 3 heures de révisions économisées. Ne JAMAIS commencer à designer sans avoir rempli cette checklist à 100%."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Récupérer le brief du Chef de projet"},
    {"type":"paragraph","text":"Avant de commencer : ouvrir GestiQ → fiche projet → lire le brief complet. Vérifier que ces infos sont présentes :"},
    {"type":"list","items":[
      "Nom exact de l'entreprise",
      "Secteur d'activité · Ville",
      "Cible client (âge, sexe, catégorie sociale)",
      "Ton voulu (sérieux / moderne / chaleureux / luxueux / jeune)",
      "Sites concurrents à surveiller",
      "Sites que le client aime",
      "Couleurs si déjà définies"
    ]},
    {"type":"callout","variant":"warning","title":"Si info manquante","text":"Demander au Chef de projet, PAS directement au client."},
    {"type":"list","items":["Outil : **GestiQ**","Temps : ~10 min","Statut : requis"]},

    {"type":"heading2","text":"2. Récupérer les assets du client depuis Drive"},
    {"type":"paragraph","text":"Ouvrir le dossier Google Drive du projet → sous-dossier **03_Assets_Client**. Vérifier la présence de :"},
    {"type":"list","items":[
      "Logo (PNG transparent + SVG si disponible)",
      "Photos (minimum 5 pour un site vitrine)",
      "Couleurs de la marque (codes HEX si disponibles)",
      "Police utilisée actuellement si applicable"
    ]},
    {"type":"callout","variant":"danger","title":"Si assets manquants","text":"Informer le Chef de projet immédiatement. Ne JAMAIS commencer avec des assets incomplets."},
    {"type":"list","items":["Outil : **Google Drive**","Temps : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"3. Analyser les 3 meilleurs concurrents visuellement"},
    {"type":"paragraph","text":"Chercher sur Google les 3 meilleurs concurrents du client. Pour chaque concurrent, analyser sites et réseaux sociaux :"},
    {"type":"list","items":[
      "Quelles couleurs utilisent-ils ?",
      "Quel style graphique (minimal / coloré / photographique / illustratif) ?",
      "Quelles polices ?",
      "Qu'est-ce qui fonctionne ? Qu'est-ce qui est mauvais ?"
    ]},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Créer quelque chose de MIEUX que les concurrents, pas copier. Mettre les captures dans Drive → 01_Brief → Concurrents."},
    {"type":"list","items":["Outil : **Google + Drive**","Temps : ~20 min","Statut : requis"]},

    {"type":"heading2","text":"4. Créer le moodboard visuel"},
    {"type":"paragraph","text":"Dans Canva ou Figma : créer une planche de **6-9 images** qui représentent l'univers visuel du projet. Sources : Unsplash, Freepik, Pinterest. Inclure :"},
    {"type":"list","items":[
      "Exemples de palettes de couleurs",
      "Exemples de typographies",
      "Ambiance générale (moderne, chaleureuse, luxueuse...)"
    ]},
    {"type":"callout","variant":"success","title":"ROI","text":"20 min de moodboard = 2h de révisions économisées. Envoyer au Chef de projet pour validation AVANT de commencer le design."},
    {"type":"list","items":["Outil : **Canva / Figma + Unsplash**","Temps : ~20 min","Statut : requis"]},

    {"type":"heading2","text":"5. Définir la charte couleurs et polices du projet"},
    {"type":"paragraph","text":"Sur la base du brief et du moodboard validé, définir :"},
    {"type":"numbered","items":[
      "**Couleur principale** — la plus importante (généralement la couleur du logo ou une couleur forte du secteur)",
      "**Couleur secondaire** — complémentaire",
      "**Couleur neutre** — blanc, gris clair, ou beige selon le style",
      "**Couleur accent** — pour les boutons CTA, doit ressortir",
      "**Police titre** — 1 seule, impactante (Montserrat Bold, Playfair Display, Poppins SemiBold)",
      "**Police corps** — 1 seule, lisible (Poppins Regular, Inter, Roboto)"
    ]},
    {"type":"list","items":["Outil : **Canva / Figma**","Temps : ~15 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Checklist brief design — à remplir dans GestiQ avant de commencer"},
    {"type":"template","text":"BRIEF DESIGN — [NOM CLIENT] — [DATE]\n\n━━ INFOS PROJET ━━\nNom entreprise : [___________]\nSecteur : [___________]\nCible : [Age · Sexe · Catégorie sociale]\nTon voulu : ☐ Sérieux ☐ Moderne ☐ Chaleureux ☐ Luxueux ☐ Jeune\n\n━━ ASSETS REÇUS ━━\n☐ Logo PNG transparent\n☐ Logo SVG\n☐ Photos professionnelles (min 5)\n☐ Couleurs marque (codes HEX)\n☐ Police actuelle\n\n━━ RÉFÉRENCES ━━\nSites que le client aime : [URL 1] · [URL 2] · [URL 3]\nConcurrents analysés : [URL 1] · [URL 2] · [URL 3]\n\n━━ CHARTE DÉFINIE ━━\nCouleur principale : #[______]\nCouleur secondaire : #[______]\nCouleur neutre : #[______]\nCouleur accent (CTA) : #[______]\nPolice titre : [___________]\nPolice corps : [___________]\n\nMoodboard validé : ☐ Oui ☐ Non"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Brief lu dans GestiQ — toutes les infos présentes",
      "Assets récupérés depuis Drive — logo + photos + couleurs",
      "3 concurrents analysés — captures dans Drive",
      "Moodboard créé et validé par Chef de projet",
      "Charte couleurs (4 couleurs) définie",
      "Charte polices (2 polices) définie",
      "Brief design complet enregistré dans GestiQ"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-design-brief-client');


-- ── ng-design-maquette-figma (designer) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-design-maquette-figma',
  'Créer la maquette Figma — Site vitrine Next Gital',
  'Wireframe gris d''abord, design Desktop puis Mobile, présentation client, intégration des retours (max 2 rounds).',
  'designer',
  '["Figma","Maquette","Wireframe","Design","Vitrine"]'::jsonb,
  'Next Gital',
  6,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Jours 2-5 du projet (après brief validé)."},
    {"type":"callout","variant":"info","title":"Canal","text":"Figma."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Maquette complète validée par le client avant tout développement."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Le développeur ne commence PAS avant que le client ait validé la maquette par écrit (email). Une maquette bien faite = développement 2x plus rapide et 0 surprise à la livraison."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Créer le projet Figma et configurer les styles"},
    {"type":"list","items":[
      "Figma → Nouveau fichier → Nommer : **[NOM CLIENT] - Site Vitrine - [MOIS ANNÉE]**",
      "**Colors** : les 4 couleurs de la charte",
      "**Text Styles** : Titre H1, H2, H3, Body, Caption (polices + tailles)",
      "**Effects** : ombre standard si utilisée",
      "Frame **Desktop 1440px** et **Mobile 390px**",
      "Grille : **12 colonnes Desktop** (gutter 24px), **4 colonnes Mobile**"
    ]},
    {"type":"list","items":["Outil : **Figma**","Temps : ~20 min","Statut : requis"]},

    {"type":"heading2","text":"2. Wireframe d'abord — structure en niveaux de gris"},
    {"type":"paragraph","text":"Avant les couleurs et les images : créer le wireframe en gris uniquement. Objectif : valider la structure et l'organisation du contenu."},
    {"type":"paragraph","text":"Sections standard d'un site vitrine Next Gital :"},
    {"type":"numbered","items":[
      "Header (logo + menu + CTA)",
      "Hero (titre principal + sous-titre + CTA + image)",
      "Problème / Solution",
      "Services (3-4 cards)",
      "Chiffres clés / Preuves",
      "Portfolio / Réalisations",
      "Témoignages",
      "FAQ",
      "CTA final + Formulaire",
      "Footer"
    ]},
    {"type":"callout","variant":"warning","title":"Validation","text":"Envoyer le wireframe au Chef de projet pour validation avant d'ajouter les couleurs."},
    {"type":"list","items":["Outil : **Figma**","Temps : ~2h","Statut : requis"]},

    {"type":"heading2","text":"3. Design Desktop — appliquer la charte graphique"},
    {"type":"paragraph","text":"Après validation du wireframe : appliquer couleurs, polices, images et éléments visuels."},
    {"type":"paragraph","text":"**Ordre de travail :**"},
    {"type":"numbered","items":[
      "Header et Navigation",
      "Section Hero (la plus importante — y passer **30% du temps**)",
      "Sections de contenu",
      "Footer"
    ]},
    {"type":"paragraph","text":"**Règles de design Next Gital :**"},
    {"type":"list","items":[
      "Espacement minimum **16px** entre éléments",
      "Boutons CTA en couleur accent avec coins arrondis (**8px minimum**)",
      "Images de qualité uniquement (Unsplash si pas de photos client)",
      "Icônes cohérentes — **un seul style** (Phosphor Icons ou Heroicons)"
    ]},
    {"type":"list","items":["Outil : **Figma**","Temps : ~4-6h","Statut : requis"]},

    {"type":"heading2","text":"4. Design Mobile — adapter chaque section"},
    {"type":"paragraph","text":"Copier le frame Desktop → adapter en 390px. Règles Mobile obligatoires :"},
    {"type":"list","items":[
      "Menus → **hamburger menu**",
      "Colonnes side-by-side → **colonnes empilées**",
      "Textes réduits (H1 max **36px** sur mobile)",
      "Images réduites et recadrées",
      "Boutons **pleine largeur** sur mobile",
      "Espacement réduit mais toujours présent (min 8px)"
    ]},
    {"type":"callout","variant":"tip","title":"Test pouce","text":"Peut-on lire et cliquer facilement avec le pouce ? Si non → corriger."},
    {"type":"list","items":["Outil : **Figma**","Temps : ~2-3h","Statut : requis"]},

    {"type":"heading2","text":"5. Préparer la présentation au client"},
    {"type":"list","items":[
      "Regrouper les frames dans l'ordre logique (Desktop puis Mobile)",
      "Ajouter des annotations si nécessaire",
      "Configurer le lien de partage Figma en mode **Prototype (View only)** — le client ne peut pas modifier",
      "Tester le lien en mode navigation",
      "Envoyer le lien au Chef de projet (jamais directement au client)"
    ]},
    {"type":"list","items":["Outil : **Figma**","Temps : ~20 min","Statut : requis"]},

    {"type":"heading2","text":"6. Intégrer les retours client — maximum 2 rounds"},
    {"type":"paragraph","text":"Le client envoie ses retours (via commentaires Figma ou par email)."},
    {"type":"numbered","items":[
      "Lire **tous** les retours avant de modifier — certains se contredisent",
      "**Priorité 1** : corrections d'erreurs (contenu erroné, info manquante)",
      "**Priorité 2** : ajustements de style (couleur, police)",
      "Changements de structure importants → **en discuter avec le Chef de projet** avant d'appliquer"
    ]},
    {"type":"callout","variant":"danger","title":"Limite scope","text":"Après 2 rounds de révisions : tout changement supplémentaire est hors scope."},
    {"type":"list","items":["Outil : **Figma**","Temps : ~1-2h par round","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Message au Chef de projet — maquette prête pour validation"},
    {"type":"template","text":"✅ Maquette [NOM CLIENT] prête pour présentation\n\n🎨 Lien Figma (view only) : [URL FIGMA]\n📱 Desktop + Mobile inclus\n🎯 Sections : [LISTE DES SECTIONS]\n\nNotes importantes :\n— [CHOIX DE DESIGN À EXPLIQUER AU CLIENT]\n— [POINT QUI NÉCESSITE L'AVIS DU CLIENT]\n\nDélai de retours souhaité : 48h maximum\nUne fois validée → je démarre le développement assets."},

    {"type":"heading","text":"Message au client après révisions — demande de validation finale"},
    {"type":"template","text":"Bonjour [Prénom] 😊\n\nJ'ai intégré tous vos retours dans la maquette.\n\nVoici la version mise à jour :\n🎨 [LIEN FIGMA]\n\nModifications effectuées :\n✅ [MODIFICATION 1]\n✅ [MODIFICATION 2]\n✅ [MODIFICATION 3]\n\nSi cette version vous convient, pouvez-vous me confirmer par retour d'email : « Je valide la maquette » ?\n\nCette confirmation nous permettra de lancer le développement immédiatement. 🚀"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Projet Figma créé avec styles globaux (couleurs + polices)",
      "Wireframe Desktop créé en gris — validé par Chef de projet",
      "Design Desktop complet — toutes les sections",
      "Design Mobile adapté — testé avec le pouce",
      "Lien Figma View Only configuré et testé",
      "Retours client intégrés (max 2 rounds)",
      "Validation écrite du client reçue par email"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-design-maquette-figma');


-- ── ng-design-visuels-reseaux (designer) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-design-visuels-reseaux',
  'Créer les visuels réseaux sociaux — Canva Pro',
  'Kit mensuel de 12 visuels par client : Brand Kit Canva, 4 types de posts, templates réutilisables.',
  'designer',
  '["Canva","Réseaux","Instagram","Facebook","TikTok","Visuels"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Livrable mensuel — kit de 12 visuels par client."},
    {"type":"callout","variant":"info","title":"Canal","text":"Canva Pro."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"12 visuels par mois par client · Cohérence visuelle parfaite · Prêts à publier."},
    {"type":"callout","variant":"warning","title":"Règle de base","text":"Créer d'abord un Kit de marque Canva pour chaque client (couleurs + polices + logo). 20 min la première fois → des heures économisées sur tous les visuels suivants."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Créer le Kit de marque Canva pour le client"},
    {"type":"paragraph","text":"Canva Pro → Brand Kit → Créer un nouveau kit. Nommer : **[NOM CLIENT]**. Ajouter :"},
    {"type":"list","items":[
      "**Logo** : uploader PNG transparent",
      "**Couleurs** : les 4 couleurs HEX de la charte",
      "**Polices** : police titre + police corps (chercher les équivalents Canva si custom)"
    ]},
    {"type":"callout","variant":"success","title":"Réutilisation","text":"Ce kit sera disponible dans tous les designs pour ce client. Le créer une seule fois, l'utiliser pour tous les visuels."},
    {"type":"list","items":["Outil : **Canva Pro Brand Kit**","Temps : ~20 min","Statut : requis"]},

    {"type":"heading2","text":"2. Les formats à créer chaque mois — 12 visuels minimum"},
    {"type":"table","table":{
      "headers":["Format","Dimensions","Quantité","Usage"],
      "rows":[
        ["Carré Feed","1080x1080px","4","Posts Instagram + Facebook"],
        ["Story / Reels cover","1080x1920px","4","Stories et Reels (vertical)"],
        ["LinkedIn post","1200x627px","2","Si client sur LinkedIn"],
        ["Couverture Facebook","851x315px","1","Maj si promotion"],
        ["TikTok","1080x1920px","1","Si client sur TikTok"]
      ]
    }},
    {"type":"callout","variant":"info","title":"Total","text":"12 visuels minimum par client par mois."},
    {"type":"list","items":["Outil : **Canva Pro**","Temps : ~3-4h pour 12 visuels","Statut : requis"]},

    {"type":"heading2","text":"3. Règles de design pour les visuels Canva"},
    {"type":"numbered","items":[
      "**Logo client toujours visible** (coin bas droite ou haut gauche, 10-15% de la largeur)",
      "**Maximum 3 couleurs** par visuel (issues du Kit de marque)",
      "**Texte lisible** : contraste fort entre texte et fond",
      "**Pas plus de 2 polices** par visuel",
      "**Espacement généreux** — ne pas surcharger",
      "**Qualité HD uniquement** (Unsplash, Freepik Pro, photos du client)",
      "**Pas d'éléments décoratifs inutiles** — chaque élément a une raison d'être",
      "**Format mobile en priorité** (la majorité voit sur téléphone)"
    ]},

    {"type":"heading2","text":"4. Les 4 types de posts et comment les concevoir"},
    {"type":"list","items":[
      "**TYPE 1 — Conseil / Astuce** : fond de couleur + titre court (max 8 mots) + liste 3-5 points + logo",
      "**TYPE 2 — Avant / Après** : 2 colonnes ou slide → AVANT (photo neutre) + APRÈS (résultat)",
      "**TYPE 3 — Citation / Témoignage** : fond sobre + citation en grand + nom client + photo profil",
      "**TYPE 4 — Promotion / Offre** : fond coloré (couleur accent) + offre en grand + détails + CTA"
    ]},
    {"type":"callout","variant":"tip","title":"Templates","text":"Pour chaque type : créer un template réutilisable dans Canva pour ce client."},

    {"type":"heading2","text":"5. Organiser et livrer les visuels"},
    {"type":"list","items":[
      "Télécharger en **PNG haute qualité** (ou MP4 pour animations)",
      "Organiser dans Drive → client → **05_Livraison → Visuels_Réseaux → [MOIS_ANNÉE]**",
      "Nommer clairement : **[CLIENT]_Post_Conseil_Jan2026.png**",
      "Envoyer le lien Drive au Chef de projet (**jamais directement au client**)",
      "Inclure une note d'utilisation : quel visuel pour quel jour et quelle plateforme"
    ]},
    {"type":"list","items":["Outil : **Canva Pro + Google Drive**","Temps : ~20 min","Statut : requis"]},

    {"type":"heading2","text":"6. Créer les templates réutilisables"},
    {"type":"paragraph","text":"Pour chaque client, créer un fichier Canva avec 4-5 templates de base. Modifiables rapidement (texte + photo)."},
    {"type":"callout","variant":"success","title":"Gain","text":"12 visuels en 2h au lieu de 4h le mois suivant."},
    {"type":"list","items":[
      "Partager les templates avec le client via Canva s'il veut créer lui-même",
      "Mettre le lien Canva dans GestiQ → fiche client → onglet Accès"
    ]},
    {"type":"list","items":["Outil : **Canva Pro**","Temps : ~1h (une seule fois par client)","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Livraison visuels mensuels — message au Chef de projet"},
    {"type":"template","text":"✅ Visuels [NOM CLIENT] — [MOIS ANNÉE] prêts\n\n📁 Dossier Drive : [URL]\n\nContenu :\n— [X] posts carrés Instagram/Facebook\n— [X] stories/Reels\n— [X] posts LinkedIn\n— [X] couverture Facebook\n\nNote d'utilisation :\n— [VISUEL 1] → à publier [JOUR RECOMMANDÉ]\n— [VISUEL 2] → à utiliser pour [CONTEXTE]\n\nTous les visuels sont prêts à publier sans modification."},

    {"type":"divider"},

    {"type":"heading","text":"Checklist mensuelle"},
    {"type":"checklist","items":[
      "Kit de marque Canva créé pour ce client",
      "12 visuels minimum créés ce mois",
      "Logo client visible sur chaque visuel",
      "Respect des 3 couleurs maximum par visuel",
      "Images HD utilisées (pas de floues ou pixelisées)",
      "Fichiers nommés correctement et organisés dans Drive",
      "Templates réutilisables créés dans Canva"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-design-visuels-reseaux');


-- ── ng-design-identite-logo (designer) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-design-identite-logo',
  'Création identité visuelle — Logo + Charte graphique complète',
  'Logo en 3 propositions, 6 formats de livraison, PDF charte graphique 8-10 pages.',
  'designer',
  '["Logo","Identité","Charte","Marque","Branding"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Inclus dans tout nouveau projet (si le client n'a pas de logo)."},
    {"type":"callout","variant":"info","title":"Canal","text":"Canva Pro · Figma · Adobe Express."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Client a un logo professionnel + charte graphique complète en 3 jours."},
    {"type":"callout","variant":"success","title":"Positionnement","text":"Next Gital inclut la création de logo dans tous ses packages. La charte graphique complète est un livrable professionnel qui impressionne le client et justifie le prix."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Brief logo — 5 questions essentielles"},
    {"type":"paragraph","text":"Avant de toucher à Canva : poser ces 5 questions via le Chef de projet :"},
    {"type":"numbered","items":[
      "Quel est le **nom exact** de l'entreprise (et l'acronyme si existe) ?",
      "Y a-t-il un **slogan** à intégrer ?",
      "Quel **style** préférez-vous : moderne / classique / coloré / minimaliste / illustratif ?",
      "Quelles **couleurs** aimez-vous et lesquelles vous déplaisent ?",
      "Pouvez-vous partager **3-5 logos que vous aimez** (dans votre secteur ou non) ?"
    ]},
    {"type":"list","items":["Outil : **GestiQ + WhatsApp**","Temps : ~10 min","Statut : requis"]},

    {"type":"heading2","text":"2. Créer 3 propositions de logo différentes"},
    {"type":"paragraph","text":"Toujours proposer **3 directions différentes** — pas 1 seule :"},
    {"type":"list","items":[
      "**Direction A** : moderne et minimaliste (texte épuré + forme simple)",
      "**Direction B** : avec icône/pictogramme (logo + symbole)",
      "**Direction C** : typographique (le nom de l'entreprise travaillé graphiquement)"
    ]},
    {"type":"callout","variant":"warning","title":"Format","text":"Pour chaque direction : créer en **noir sur blanc ET en couleurs**. Les 3 propositions dans **1 seul PDF** de présentation."},
    {"type":"list","items":["Outil : **Canva Pro / Figma**","Temps : ~3-4h","Statut : requis"]},

    {"type":"heading2","text":"3. Livrer les logos dans tous les formats nécessaires"},
    {"type":"paragraph","text":"Une fois le logo choisi et validé, livrer en **6 formats** :"},
    {"type":"numbered","items":[
      "**PNG fond transparent** — pour tout usage digital",
      "**PNG fond blanc** — pour impression",
      "**SVG** — vectoriel, pour le développeur et l'imprimeur",
      "**JPG fond blanc** — pour les réseaux sociaux",
      "**Format carré** — pour profil Facebook/Instagram",
      "**Format horizontal** — pour le header du site"
    ]},
    {"type":"callout","variant":"tip","title":"Variations","text":"Créer aussi : version noir, version blanc, version monochrome."},
    {"type":"list","items":["Outil : **Canva Pro / Figma**","Temps : ~30 min","Statut : requis"]},

    {"type":"heading2","text":"4. Créer le document de charte graphique"},
    {"type":"paragraph","text":"Après validation du logo : créer un **PDF de charte graphique de 8-10 pages** avec :"},
    {"type":"numbered","items":[
      "**Présentation du logo** (espace de protection, taille minimum)",
      "**Versions autorisées** (fond clair, fond foncé, monochrome)",
      "**Versions interdites** (ne pas déformer, ne pas changer les couleurs, pas d'effets)",
      "**Palette de couleurs** (4 couleurs avec codes HEX, RGB, CMJN)",
      "**Typographie** (polices titre et corps avec exemples)",
      "**Exemples d'application** (carte de visite, entête email, post Instagram)"
    ]},
    {"type":"callout","variant":"success","title":"Livraison","text":"Ce document est remis au client à la livraison du projet."},
    {"type":"list","items":["Outil : **Canva Pro**","Temps : ~2-3h","Statut : requis"]},

    {"type":"heading2","text":"5. Livrer les fichiers organisés dans Drive"},
    {"type":"paragraph","text":"Créer le dossier : Drive → [NOM CLIENT] → **05_Livraison → Identité_Visuelle**. Sous-dossiers :"},
    {"type":"list","items":[
      "**Logo_Fichiers** (tous les formats)",
      "**Charte_Graphique** (PDF)",
      "**Assets_Réseaux** (photos de profil et couvertures)"
    ]},
    {"type":"paragraph","text":"Remettre le lien au Chef de projet avec note : « Le client peut partager ce dossier directement avec son imprimeur ou tout prestataire. »"},
    {"type":"list","items":["Outil : **Google Drive**","Temps : ~15 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Présentation des 3 propositions de logo — au Chef de projet"},
    {"type":"template","text":"✅ 3 propositions logo [NOM CLIENT] prêtes\n\n📄 PDF présentation : [URL DRIVE]\n\nDirection A : [DESCRIPTION EN 1 LIGNE]\nDirection B : [DESCRIPTION EN 1 LIGNE]\nDirection C : [DESCRIPTION EN 1 LIGNE]\n\nLe client choisit 1 direction → je finalise et livre tous les formats sous 24h.\n\nRévisions incluses : 2 retours sur la direction choisie."},

    {"type":"heading","text":"Livraison identité visuelle complète — au Chef de projet"},
    {"type":"template","text":"✅ Identité visuelle complète — [NOM CLIENT]\n\n📁 Dossier complet Drive : [URL]\n\nContenu livré :\n🎨 Logo en 6 formats (PNG · SVG · JPG · Carré · Horizontal · Monochrome)\n📘 Charte graphique PDF (10 pages)\n📱 Assets réseaux (profil + couverture FB/IG)\n\nLe client peut utiliser ces fichiers avec n'importe quel prestataire."},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de livraison identité visuelle"},
    {"type":"checklist","items":[
      "Brief logo complété — 5 questions répondues",
      "3 propositions différentes créées (A, B, C)",
      "Direction choisie et validée par email",
      "Logo livré en 6 formats (PNG, SVG, JPG, carré, horizontal, monochrome)",
      "Charte graphique PDF créée (8-10 pages)",
      "Assets réseaux sociaux créés (profil + couverture)",
      "Tout livré dans Drive avec dossier organisé"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-design-identite-logo');


-- ── ng-design-visuels-pub (designer) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-design-visuels-pub',
  'Créer les visuels publicitaires — Facebook · Instagram · TikTok Ads',
  '3 variantes A/B/C × 3 formats (carré, vertical, story), texte ≤ 5 mots, logo discret, contraste fort.',
  'designer',
  '["PubVisuels","FacebookAds","TikTok","Canva","Conversion"]'::jsonb,
  'Next Gital',
  5,
  false,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Avant tout lancement de campagne publicitaire."},
    {"type":"callout","variant":"info","title":"Canal","text":"Canva Pro · CapCut · Meta Ads Manager."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"3-5 visuels pub par campagne · Taux de clic CTR ≥ 1%."},
    {"type":"callout","variant":"danger","title":"Règle fondamentale","text":"Un visuel pub n'est pas un visuel organique. Il doit ARRÊTER le scroll dans les 2 premières secondes. Pas de logo en grand, pas de texte en petit. Toujours créer minimum 3 variantes pour les tests A/B."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Comprendre l'objectif de la campagne AVANT de designer"},
    {"type":"paragraph","text":"Demander au Media Buyer (ou au Chef de projet) :"},
    {"type":"numbered","items":[
      "Quel est l'**objectif exact** ? (messages WhatsApp, appels, visites site, ventes)",
      "Quelle est **l'offre** à mettre en avant ? (promotion, service, témoignage)",
      "Qui est la **cible précise** ? (âge, sexe, situation)",
      "Quel est le **message principal** ? (1 seule phrase)"
    ]},
    {"type":"callout","variant":"warning","title":"Pourquoi","text":"Cette info détermine TOUT le design. Un visuel pour « générer des appels » est différent d'un visuel pour « augmenter les ventes »."},
    {"type":"list","items":["Outil : **Discussion avec Media Buyer**","Temps : ~10 min","Statut : requis"]},

    {"type":"heading2","text":"2. Les formats à créer pour chaque campagne"},
    {"type":"table","table":{
      "headers":["Format","Dimensions","Usage"],
      "rows":[
        ["Carré","1080x1080px","Feed Facebook + Instagram"],
        ["Vertical Feed","1080x1350px","Feed Instagram (prend plus de place)"],
        ["Story / Reels","1080x1920px","Stories FB + IG + TikTok"],
        ["Paysage","1200x628px","Desktop ou LinkedIn"]
      ]
    }},
    {"type":"callout","variant":"info","title":"Minimum","text":"Créer les 3 premiers formats. Toujours **3 variantes par format** (3 visuels différents pour l'A/B test du Media Buyer)."},
    {"type":"list","items":["Outil : **Canva Pro**","Temps : ~2-3h pour 9 visuels","Statut : requis"]},

    {"type":"heading2","text":"3. Règles du visuel publicitaire efficace"},
    {"type":"numbered","items":[
      "**Le hook visuel** : image ou couleur frappante. Préférer : avant/après, personne qui regarde la caméra, image du problème reconnu",
      "**Texte minimal** : 5 mots maximum sur le visuel (Meta pénalise les images avec trop de texte)",
      "**CTA visible** : bouton ou texte CTA clair (Appelez maintenant · Envoyez un message · En savoir plus)",
      "**Logo discret** : en petit, pas en grand — la marque ne doit pas dominer",
      "**Couleurs vives** : couleurs contrastant avec le fond blanc de Facebook/Instagram"
    ]},

    {"type":"heading2","text":"4. Créer les 3 variantes pour l'A/B test"},
    {"type":"paragraph","text":"Pour la même campagne, créer 3 visuels avec des approches différentes :"},
    {"type":"list","items":[
      "**Variante A** — Visuel produit/service (montrer ce qu'on vend)",
      "**Variante B** — Visuel humain (personne souriante, relation client, résultat)",
      "**Variante C** — Visuel problème/solution (problème en rouge → solution en vert)"
    ]},
    {"type":"callout","variant":"tip","title":"Méthode","text":"Le Media Buyer teste les 3 et garde le gagnant après 3 jours."},
    {"type":"list","items":["Outil : **Canva Pro**","Temps : ~2h pour 3 variantes","Statut : requis"]},

    {"type":"heading2","text":"5. Livraison des visuels pub — format et nommage"},
    {"type":"list","items":[
      "Télécharger en **PNG 1080px** (ou MP4 si animation)",
      "Nommer : **[CLIENT]_Pub_[VARIANTE]_[FORMAT]_[MOIS].png**",
      "Exemple : **Fedix_Pub_A_Carré_Jan2026.png**",
      "Drive → [CLIENT] → **05_Livraison → Pubs_[MOIS]**",
      "Envoyer le lien au Media Buyer avec un récapitulatif"
    ]},
    {"type":"list","items":["Outil : **Canva Pro + Google Drive**","Temps : ~15 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Livraison visuels pub — message au Media Buyer"},
    {"type":"template","text":"✅ Visuels pub [NOM CLIENT] prêts — Campagne [NOM CAMPAGNE]\n\n📁 Dossier Drive : [URL]\n\nContenu :\n— Variante A : [DESCRIPTION APPROCHE] (carré + vertical + story)\n— Variante B : [DESCRIPTION APPROCHE] (carré + vertical + story)\n— Variante C : [DESCRIPTION APPROCHE] (carré + vertical + story)\n\nTotal : [X] visuels prêts à uploader dans Ads Manager.\n\nNote : les variantes B et C ont des couleurs plus vives — à tester en premier selon moi."},

    {"type":"divider"},

    {"type":"heading","text":"Checklist par campagne"},
    {"type":"checklist","items":[
      "Objectif campagne compris — briefé par Media Buyer",
      "3 formats créés (carré + vertical + story)",
      "3 variantes différentes pour A/B test",
      "Texte ≤ 5 mots sur chaque visuel",
      "Logo discret — pas dominant",
      "Couleurs contrastées avec fond blanc Meta",
      "Fichiers nommés correctement et dans Drive"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-design-visuels-pub');


-- ── ng-design-standards-qualite (designer) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-design-standards-qualite',
  'Standards qualité design + organisation des fichiers Next Gital',
  'Structure Drive obligatoire, convention de nommage, checklist qualité avant livraison, rapport quotidien.',
  'designer',
  '["Qualité","Standards","Fichiers","Organisation","Drive"]'::jsonb,
  'Next Gital',
  4,
  false,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Règles permanentes — à appliquer sur chaque projet."},
    {"type":"callout","variant":"info","title":"Canal","text":"Google Drive · Canva Pro · Figma."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Zéro fichier perdu · Retrouver n'importe quel visuel en moins de 30 secondes."},
    {"type":"callout","variant":"warning","title":"À retenir","text":"L'organisation est aussi importante que le talent de design. Un designer désorganisé perd 1h par jour à chercher ses fichiers."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Structure de dossiers Drive — identique pour chaque client"},
    {"type":"paragraph","text":"Chaque projet dans Drive doit avoir **EXACTEMENT** cette structure :"},
    {"type":"numbered","items":[
      "**01_Brief** — brief client, moodboard, analyse concurrents",
      "**02_Maquettes** — wireframes et designs Figma en PDF",
      "**03_Assets_Client** — logo, photos, contenus reçus du client",
      "**04_En_cours** — fichiers de travail, versions intermédiaires",
      "**05_Livraison** — fichiers finaux prêts à utiliser"
    ]},
    {"type":"callout","variant":"danger","title":"Interdit","text":"Ne jamais mettre des fichiers à la racine ou dans le mauvais dossier."},
    {"type":"list","items":["Outil : **Google Drive**","Temps : ~5 min par projet","Statut : requis"]},

    {"type":"heading2","text":"2. Nommage des fichiers — convention obligatoire"},
    {"type":"paragraph","text":"Format obligatoire pour tous les fichiers : **[CLIENT]_[TYPE]_[VERSION]_[DATE]**"},
    {"type":"list","items":[
      "✅ **Fedix_Logo_Final_Jan2026.png**",
      "✅ **DrKarim_Maquette_v2_Feb2026.fig**",
      "✅ **Medimarket_Post_Carré_Mar2026.png**"
    ]},
    {"type":"paragraph","text":"**Règles :**"},
    {"type":"list","items":[
      "Underscores (**pas d'espaces ni de tirets**)",
      "Versions : v1, v2, v3, Final",
      "Date format **MoisAnnée** (Jan2026)",
      "❌ Jamais : « sans titre », « copie de », « nouveau document », « 2 », « final final »"
    ]},

    {"type":"heading2","text":"3. Checklist qualité avant chaque livraison"},
    {"type":"paragraph","text":"Avant d'envoyer tout fichier au Chef de projet :"},
    {"type":"checklist","items":[
      "**Orthographe** vérifiée sur chaque texte de chaque visuel",
      "**Cohérence des couleurs** (exactement celles de la charte ?)",
      "**Lisibilité sur petit écran** (zoom out à 50% et vérifier)",
      "**Qualité des images** (pas de pixels, pas de flou)",
      "**Logo présent** sur les visuels concernés",
      "**Format correspond** à la demande"
    ]},
    {"type":"callout","variant":"danger","title":"Règle","text":"Si **1 seul point** n'est pas validé → corriger avant de livrer. Ne jamais livrer un fichier « pour voir »."},

    {"type":"heading2","text":"4. Temps de travail estimé par type de livrable"},
    {"type":"table","table":{
      "headers":["Livrable","Temps estimé"],
      "rows":[
        ["Brief + moodboard","~45 min"],
        ["Wireframe (1 page)","~30 min"],
        ["Design 1 page Figma (Desktop + Mobile)","~1h30"],
        ["Maquette site complet (8-10 pages)","2 jours"],
        ["Logo (3 propositions)","3-4h"],
        ["Charte graphique PDF","2-3h"],
        ["1 visuel Canva simple","~20 min"],
        ["Kit 12 visuels Canva","3-4h"],
        ["3 visuels pub (A/B/C) + 3 formats","~2h"]
      ]
    }},
    {"type":"callout","variant":"info","title":"Inclus","text":"Ces temps incluent les vérifications qualité."},

    {"type":"heading2","text":"5. Rapport quotidien designer — au Chef de projet"},
    {"type":"paragraph","text":"**Chaque soir avant 18h** : envoyer un message WhatsApp au Chef de projet avec :"},
    {"type":"list","items":[
      "Ce qui a été **terminé** aujourd'hui",
      "Ce qui est **en cours**",
      "Ce qui sera fait **demain**",
      "Tout **blocage**"
    ]},
    {"type":"callout","variant":"warning","title":"Sans exception","text":"Même si la journée a été courte. Ce rapport permet au Chef de projet de mettre à jour le Kanban et de rassurer le client."},
    {"type":"list","items":["Outil : **WhatsApp**","Temps : ~3 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Rapport quotidien designer — au Chef de projet (chaque soir)"},
    {"type":"template","text":"📊 Point design — [NOM CLIENT] — [DATE]\n\n✅ Terminé aujourd'hui :\n— [LIVRABLE 1 TERMINÉ]\n— [LIVRABLE 2 TERMINÉ]\n\n🔄 En cours :\n— [CE QUI EST EN COURS + % d'avancement]\n\n📅 Demain :\n— [CE QUI SERA FAIT DEMAIN]\n\n⚠️ Blocage (si applicable) :\n— [PROBLÈME + CE QUI EST NÉCESSAIRE POUR DÉBLOQUER]\n\n📁 Fichiers du jour dans Drive : [URL DOSSIER]"},

    {"type":"heading","text":"Message si un asset client est manquant et bloque le travail"},
    {"type":"template","text":"Bonjour [Chef de projet],\n\nJe suis bloqué sur le projet [NOM CLIENT] car il me manque :\n\n❌ [ASSET MANQUANT 1]\n❌ [ASSET MANQUANT 2]\n\nSans ces éléments, je ne peux pas avancer sur [CE QUI EST BLOQUÉ].\n\nSi ces assets ne sont pas reçus avant [DATE + HEURE], la livraison prévue le [DATE] sera décalée.\n\nPeux-tu relancer le client ? Merci 🙏"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist permanente du designer"},
    {"type":"checklist","items":[
      "Structure de dossiers Drive respectée sur chaque projet",
      "Nommage des fichiers selon la convention obligatoire",
      "Checklist qualité validée avant chaque livraison",
      "Temps de travail estimé et noté dans GestiQ Tâches",
      "Rapport quotidien envoyé au Chef de projet avant 18h"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-design-standards-qualite');


-- ── ng-design-regles-outils (designer) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-design-regles-outils',
  'Outils designer + Règles absolues Next Gital',
  'Checklist d''accès aux outils (Canva, Figma, Drive, Freepik, CapCut) + 8 règles non négociables.',
  'designer',
  '["Outils","Règles","Onboarding","Designer"]'::jsonb,
  'Next Gital',
  2,
  false,
  $sop$[
    {"type":"callout","variant":"info","title":"Quand l'utiliser","text":"Le 1er jour d'arrivée du designer — checklist d'accès à compléter avant tout travail."},
    {"type":"callout","variant":"warning","title":"Règle des 20 min","text":"Si bloqué plus de 20 min sur un point → stopper et appeler le fondateur (+212 620 002 066). Ne pas modifier l'existant. Ne pas perdre 2h sur un détail."},

    {"type":"heading","text":"Outils à installer avant le 1er jour"},
    {"type":"checklist","items":[
      "**Canva Pro Next Gital** — inviter avec son email",
      "**Figma Next Gital** — inviter en tant que Editor",
      "**Google Drive Next Gital** — accès dossier Projets",
      "**GestiQ** — compte créé avec rôle Designer",
      "**Unsplash** — gratuit, pas de compte nécessaire",
      "**Freepik Pro** — partager l'accès Next Gital",
      "**Google Fonts** — gratuit, pas de compte nécessaire",
      "**CapCut** — gratuit pour les vidéos TikTok/Reels",
      "**Loom** — pour les vidéos tuto (compte Next Gital)"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Les 8 règles absolues du designer Next Gital"},
    {"type":"numbered","items":[
      "**JAMAIS** livrer un fichier sans vérifier l'orthographe",
      "**JAMAIS** commencer sans brief complet validé",
      "**JAMAIS** modifier les fichiers du client sans backup",
      "**TOUJOURS** livrer dans Drive — jamais par WhatsApp direct",
      "**TOUJOURS** envoyer le rapport quotidien avant 18h",
      "**TOUJOURS** demander au Chef de projet avant de contacter le client directement",
      "Révisions : **maximum 2 rounds** inclus — après c'est hors scope",
      "Si le client demande quelque chose d'**impossible visuellement** → expliquer au Chef de projet, pas au client"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Contact référent"},
    {"type":"list","items":[
      "📞 **+212 620 002 066** — Fondateur Next Gital",
      "✉️ **info@nextgital.com** — Email général",
      "🏢 **4ème étage, Bureau N°7, Immeuble Kissi, Oujda**"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Checklist du nouvel arrivant designer"},
    {"type":"checklist","items":[
      "Tous les accès outils créés et fonctionnels",
      "Les 8 règles absolues lues et comprises",
      "Numéro du fondateur enregistré",
      "Structure Drive Next Gital explorée",
      "Premier brief design lu en compagnie du Chef de projet",
      "Templates Canva Next Gital explorés"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-design-regles-outils');

COMMIT;
