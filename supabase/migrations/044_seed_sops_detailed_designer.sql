-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 044 : SOPs ultra-détaillés Designer
--  Date : 2026-05-17
--  Périmètre : 7 contenus distincts couvrant 11 slugs Designer
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ────────────────────────────────────────────────────────────────────
-- 1) BRIEF CLIENT  →  ng-design-brief-client
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"Pour qui ?","text":"Designer Next Gital recevant un nouveau projet (site, identité visuelle, visuels réseaux). À lire AVANT toute création."},
  {"type":"callout","variant":"tip","title":"Pourquoi un brief solide ?","text":"80% des allers-retours client viennent d'un brief mal cadré. 30 min de brief = 5h gagnées en révisions."},
  {"type":"callout","variant":"warning","title":"Règle d'or","text":"Pas de Canva, pas de Figma, pas de Photoshop AVANT d'avoir validé le brief avec le chef de projet."},

  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. LIRE LA FICHE PROJET DANS GESTIQ"},
  {"type":"paragraph","text":"🎯 Objectif : récupérer toutes les infos collectées par le commercial. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : tu reçois une notification GestiQ « Nouveau projet assigné »."},
  {"type":"paragraph","text":"🖥️ OÙ : gestiq.nextgital.tech → Menu Projets → ton nom de client (ex : Dr. Karim - Site dentaire)."},
  {"type":"numbered","items":[
    "Ouvre gestiq.nextgital.tech et connecte-toi avec design@nextgital.com.",
    "Va dans Projets → clique sur le projet assigné.",
    "Ouvre l'onglet « Brief » (à droite de « Vue d'ensemble »).",
    "Lis intégralement : secteur, cible, ton, exemples aimés, budget.",
    "Note dans un brouillon Notion les points flous à clarifier."
  ]},
  {"type":"paragraph","text":"✏️ INFOS À EXTRAIRE OBLIGATOIREMENT :"},
  {"type":"list","items":[
    "**Nom du client** → ex : Dr. Karim, Cabinet Fedix, Pharmacie Andalous",
    "**Secteur d'activité** → dentaire, juridique, restauration, pharmacie",
    "**Type de livrable** → site web / logo / pack réseaux / flyer",
    "**Deadline** → date butoir absolue (jamais dépasser)",
    "**Cible** → âge, sexe, CSP, ville (ex : femmes 25-45 Oujda, CSP B)",
    "**Ton souhaité** → moderne / classique / luxe / fun / médical",
    "**Couleurs imposées** → si client a déjà une charte ou des préférences",
    "**Concurrents cités** → noms de marques que le client aime ou déteste"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu peux répondre en 1 phrase à : Pour qui ? Quoi ? Pour quand ? Avec quel style ?"},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Brief vide → contacter le commercial WhatsApp. Brief contradictoire (« moderne mais classique ») → demander la priorité au chef de projet. Pas de deadline → bloquer le projet jusqu'à validation."},
  {"type":"paragraph","text":"➡️ Étape suivante : ouvrir le dossier Drive du client."},

  {"type":"heading2","text":"2. OUVRIR LE DOSSIER DRIVE 01_BRIEF"},
  {"type":"paragraph","text":"🎯 Objectif : récupérer les pièces fournies par le client (logos existants, photos, exemples). ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : brief GestiQ lu."},
  {"type":"paragraph","text":"🖥️ OÙ : drive.google.com → Drive partagé Next Gital → Clients → [Nom client] → 01_Brief."},
  {"type":"numbered","items":[
    "Ouvre drive.google.com avec ton compte design@nextgital.com.",
    "Va dans Drive partagés → Next Gital - Clients.",
    "Trouve le dossier au nom EXACT du client (ex : Dr-Karim-Cabinet-Dentaire).",
    "Ouvre le sous-dossier 01_Brief.",
    "Télécharge tous les fichiers dans un dossier local : ~/Designs/[client]/brief/."
  ]},
  {"type":"paragraph","text":"✏️ FICHIERS TYPIQUES À CHERCHER :"},
  {"type":"list","items":[
    "**logo-existant.png/.ai/.svg** → si refonte",
    "**photos-locaux.jpg** → vraies photos du cabinet/boutique",
    "**exemples-aimés.pdf** → screenshots de sites/posts que le client adore",
    "**charte-existante.pdf** → si déjà une charte (à respecter ou refondre)"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tous les fichiers téléchargés localement, dossier 01_Brief consulté de A à Z."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Dossier vide → le commercial n'a pas uploadé, le relancer WhatsApp. Fichiers en .heic (iPhone) → convertir en .jpg via cloudconvert.com. Photos floues/pixelisées → redemander au client en HD."},
  {"type":"paragraph","text":"➡️ Étape suivante : recherche concurrentielle."},

  {"type":"heading2","text":"3. RECHERCHE CONCURRENTIELLE (3-5 CONCURRENTS)"},
  {"type":"paragraph","text":"🎯 Objectif : comprendre les codes visuels du secteur et se différencier. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"📍 Point de départ : brief lu, dossier Drive consulté."},
  {"type":"paragraph","text":"🖥️ OÙ : google.com + instagram.com."},
  {"type":"numbered","items":[
    "Tape sur Google : « [secteur] [ville] » (ex : « dentiste Oujda »).",
    "Note 3 concurrents locaux + 2 références internationales.",
    "Pour chacun : screenshot du site (cmd+shift+4 sur Mac) et de leur Insta.",
    "Range les screenshots dans ~/Designs/[client]/concurrents/.",
    "Identifie les codes récurrents : couleurs, typos, ton, mise en page.",
    "Note 3 choses à faire AUTREMENT pour se démarquer."
  ]},
  {"type":"paragraph","text":"✏️ GRILLE D'ANALYSE PAR CONCURRENT :"},
  {"type":"list","items":[
    "**Nom + lien** → ex : Cabinet Dr. Berrada / cabinet-berrada.ma",
    "**Couleurs dominantes** → ex : bleu marine #1E3A8A + blanc",
    "**Typo principale** → ex : Montserrat Bold pour titres",
    "**Ton** → ex : rassurant, professionnel, peu d'émotions",
    "**Point fort visuel** → ex : photos d'équipe en blouse",
    "**Point faible** → ex : trop chargé, lecture difficile"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu as un dossier concurrents avec 3-5 PDF/screenshots et une synthèse écrite."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Secteur de niche sans concurrents locaux → élargir à Casablanca/Rabat. Tous les concurrents se ressemblent → c'est un signal pour innover. Trop de temps perdu → max 30 min, on n'écrit pas une thèse."},
  {"type":"paragraph","text":"➡️ Étape suivante : créer le moodboard Canva."},

  {"type":"heading2","text":"4. CRÉER LE MOODBOARD CANVA (1920x1080)"},
  {"type":"paragraph","text":"🎯 Objectif : visualiser la direction artistique avant de designer. ⏱️ Temps : 45 min."},
  {"type":"paragraph","text":"📍 Point de départ : concurrents analysés, ton défini."},
  {"type":"paragraph","text":"🖥️ OÙ : canva.com → compte design@nextgital.com → Créer un design → Taille personnalisée 1920x1080 px."},
  {"type":"numbered","items":[
    "Connecte-toi à canva.com avec design@nextgital.com.",
    "Clique Créer un design → Taille personnalisée → 1920x1080 px → Créer.",
    "Renomme le fichier : Moodboard - [Client] - v1.",
    "Place 6 à 8 photos d'ambiance (Unsplash via Canva : onglet Photos).",
    "Ajoute un bloc avec 3 couleurs HEX (rectangles + code couleur).",
    "Ajoute un bloc avec 2 typographies (titre + paragraphe, exemples de texte).",
    "Ajoute un bloc « Mots-clés » : 5 adjectifs (ex : moderne, rassurant, lumineux).",
    "Télécharge en PNG haute qualité dans 01_Brief/Moodboard-v1.png."
  ]},
  {"type":"paragraph","text":"✏️ STRUCTURE EXACTE DU MOODBOARD (8 zones) :"},
  {"type":"list","items":[
    "**Zone 1 (haut-gauche)** → Titre : « Moodboard - Dr. Karim - Cabinet Dentaire »",
    "**Zone 2 (haut-droite)** → 5 mots-clés : « Moderne · Rassurant · Lumineux · Clean · Pro »",
    "**Zone 3 (centre-gauche)** → 4 photos d'ambiance (cabinet, dentiste, sourire, équipement)",
    "**Zone 4 (centre-droite)** → 4 photos de référence design (sites concurrents)",
    "**Zone 5 (bas-gauche)** → 3 carrés couleurs HEX (#1E3A8A bleu + #FFFFFF blanc + #06B6D4 cyan)",
    "**Zone 6 (bas-centre)** → Typo Titre : Montserrat Bold 48px (exemple : « Votre sourire »)",
    "**Zone 7 (bas-centre)** → Typo Paragraphe : Inter Regular 16px (exemple : « Lorem ipsum… »)",
    "**Zone 8 (bas-droite)** → Logo Next Gital + version v1 + date"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le moodboard fait 1920x1080, contient toutes les 8 zones, et tient sur 1 seule page."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Trop de couleurs (>4) → choix difficile, le client va paniquer. Photos non libres de droits → toujours via Canva Photos ou Unsplash. Moodboard sur 3 pages → on doit voir TOUT en un coup d'œil."},
  {"type":"paragraph","text":"➡️ Étape suivante : validation client."},

  {"type":"heading2","text":"5. ENVOYER LE MOODBOARD POUR VALIDATION"},
  {"type":"paragraph","text":"🎯 Objectif : obtenir un GO écrit du client avant de designer. ⏱️ Temps : 10 min + 24-48h d'attente."},
  {"type":"paragraph","text":"📍 Point de départ : moodboard fini et exporté."},
  {"type":"paragraph","text":"🖥️ OÙ : Canva (bouton Partager) + GestiQ (commentaire projet) + WhatsApp client."},
  {"type":"numbered","items":[
    "Dans Canva, clique Partager (en haut à droite) → Copier le lien (mode visualisation).",
    "Upload aussi le PNG dans Drive : Clients/[client]/01_Brief/Moodboard-v1.png.",
    "Va sur gestiq.nextgital.tech → projet → onglet Commentaires.",
    "Ajoute commentaire : « Moodboard v1 envoyé au client le [date], en attente validation. » + lien Canva.",
    "Change le statut du projet en « En attente validation client ».",
    "Envoie un message WhatsApp au client avec le lien Canva (template ci-dessous)."
  ]},
  {"type":"paragraph","text":"✏️ MESSAGE WHATSAPP EXACT :"},
  {"type":"template","text":"Bonjour [Prénom], j'espère que vous allez bien.\\n\\nVoici le moodboard de votre projet [type] : [lien Canva].\\n\\nIl présente l'univers visuel proposé : couleurs, photos d'ambiance, typographies.\\n\\nMerci de me dire :\\n1) Si la direction vous plaît (oui/non)\\n2) S'il y a des éléments à modifier\\n\\nDès votre validation, je passe à la création des maquettes.\\n\\nBelle journée,\\nL'équipe Next Gital"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Lien Canva envoyé + statut GestiQ à jour + WhatsApp envoyé avec accusé de lecture."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Client ne répond pas en 48h → relance polie WhatsApp. Client demande tout changer → on refait UN moodboard v2, pas 5. Client valide oralement → demander « OK validé » écrit (preuve)."},
  {"type":"paragraph","text":"➡️ Étape suivante : démarrer la création (maquette / logo / visuels selon brief)."},

  {"type":"heading2","text":"6. ARCHIVER LE BRIEF VALIDÉ"},
  {"type":"paragraph","text":"🎯 Objectif : tracer la validation pour éviter les litiges. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : client a écrit « OK validé »."},
  {"type":"paragraph","text":"🖥️ OÙ : Drive + GestiQ."},
  {"type":"numbered","items":[
    "Screenshot du message WhatsApp de validation (cmd+shift+4).",
    "Upload dans Drive : Clients/[client]/01_Brief/Validation-moodboard.png.",
    "Sur GestiQ, ajoute commentaire : « Moodboard validé le [date] par [nom client]. »",
    "Change statut projet en « En production ».",
    "Crée le sous-dossier 02_Maquettes (ou 02_Logo selon livrable)."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Preuve de validation archivée + statut GestiQ mis à jour + dossier production créé."},

  {"type":"divider"},

  {"type":"heading2","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Brief GestiQ lu intégralement",
    "Dossier Drive 01_Brief consulté et téléchargé",
    "3-5 concurrents analysés (screenshots + synthèse)",
    "Moodboard Canva 1920x1080 créé (8 zones)",
    "Moodboard uploadé Drive + lien Canva partagé",
    "WhatsApp envoyé au client avec template officiel",
    "Statut GestiQ : En attente validation client",
    "Validation écrite reçue et archivée"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Bloqué plus de 30 min sur une étape ? Appelle Next Gital : WhatsApp +212 620 002 066 (info@nextgital.com)."}
]$sop$::jsonb,
    read_min = 12,
    updated_at = now()
WHERE slug = 'ng-design-brief-client';


-- ────────────────────────────────────────────────────────────────────
-- 2) MAQUETTE FIGMA  →  ng-design-maquette-figma + ng-ds-figma-maquettes
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"Pour qui ?","text":"Designer Next Gital qui crée une maquette de site web ou d'app dans Figma."},
  {"type":"callout","variant":"tip","title":"Pourquoi Figma ?","text":"Standard de l'industrie. Collaboratif en temps réel. Handoff dev intégré. Gratuit jusqu'à 3 fichiers."},
  {"type":"callout","variant":"warning","title":"Pré-requis","text":"Brief validé + moodboard approuvé par le client. Sans ça, on ne commence pas."},
  {"type":"callout","variant":"info","title":"Compte à utiliser","text":"design@nextgital.com (plan Pro mutualisé)."},

  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. CRÉER LE FICHIER FIGMA DU PROJET"},
  {"type":"paragraph","text":"🎯 Objectif : avoir un fichier Figma propre, nommé, rangé. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : brief validé, dossier client Drive prêt."},
  {"type":"paragraph","text":"🖥️ OÙ : figma.com → connecté à design@nextgital.com."},
  {"type":"numbered","items":[
    "Va sur figma.com et connecte-toi avec design@nextgital.com.",
    "Sidebar gauche → équipe « Next Gital » → projet « Clients 2026 ».",
    "Bouton + Nouveau → Design file.",
    "Renomme le fichier : [Client] - [Type] - v1 (ex : Dr-Karim - Site - v1).",
    "Clique sur l'icône cadenas → vérifier que les permissions sont « Éditable par l'équipe »."
  ]},
  {"type":"paragraph","text":"✏️ CONVENTION DE NOMMAGE :"},
  {"type":"list","items":[
    "**Format** → [Client]-[Type]-[Version] (sans espaces, tirets uniquement)",
    "**Exemple OK** → Dr-Karim-Site-v1, Cabinet-Fedix-App-v2, Pharmacie-Andalous-Landing-v1",
    "**Exemple PAS OK** → Dr Karim site (espaces), karim_site (snake_case), DesignFinal (pas de version)"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le fichier apparaît dans l'équipe Next Gital, projet Clients 2026, avec le bon nom."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Fichier créé dans Drafts → invisible pour l'équipe, le DÉPLACER dans le projet. Mauvais nom → renommer tout de suite, pas plus tard. Compte perso utilisé → switcher vers design@nextgital.com."},
  {"type":"paragraph","text":"➡️ Étape suivante : créer les frames responsives."},

  {"type":"heading2","text":"2. CRÉER LES FRAMES DESKTOP + TABLET + MOBILE"},
  {"type":"paragraph","text":"🎯 Objectif : poser les 3 tailles d'écran cible. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : fichier Figma vide ouvert."},
  {"type":"paragraph","text":"🖥️ OÙ : canvas Figma."},
  {"type":"numbered","items":[
    "Appuie sur la touche F (raccourci Frame).",
    "Dans la sidebar droite, sélectionne le preset « Desktop » → 1440 x 900.",
    "Renomme la frame : 01-Desktop-Accueil.",
    "Crée une 2e frame : preset « Tablet » → 768 x 1024 → nommer 02-Tablet-Accueil.",
    "Crée une 3e frame : preset « Mobile » → 375 x 812 (iPhone X) → nommer 03-Mobile-Accueil.",
    "Aligne les 3 frames horizontalement avec 200px d'espacement."
  ]},
  {"type":"paragraph","text":"✏️ TAILLES EXACTES À RESPECTER :"},
  {"type":"list","items":[
    "**Desktop** → 1440 x 900 px (Macbook 13'' standard)",
    "**Tablet** → 768 x 1024 px (iPad portrait)",
    "**Mobile** → 375 x 812 px (iPhone X/11/12/13)",
    "**Ne PAS utiliser** → 1920 (trop large), 1366 (vieux), 360 (Android obsolète)"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"3 frames côte à côte, nommées correctement, dans les bonnes tailles."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Frame trop large/étroite → utiliser uniquement les presets. Frames empilées verticalement → les aligner horizontalement avec auto-layout. Pas de mobile → 70% du trafic est mobile, INTERDIT de zapper."},
  {"type":"paragraph","text":"➡️ Étape suivante : wireframe basse fidélité."},

  {"type":"heading2","text":"3. WIREFRAME BASSE FIDÉLITÉ (GRIS/NOIR)"},
  {"type":"paragraph","text":"🎯 Objectif : valider la structure AVANT le design. ⏱️ Temps : 1h30."},
  {"type":"paragraph","text":"📍 Point de départ : frames créées, brief en tête."},
  {"type":"paragraph","text":"🖥️ OÙ : Figma, frame Desktop."},
  {"type":"numbered","items":[
    "Duplique la frame Desktop → renomme « 01-Wireframe-Desktop ».",
    "Dessine des rectangles gris (#E5E5E5) pour les blocs (header, hero, services, footer).",
    "Ajoute du texte Lorem ipsum en gris foncé (#666) pour matérialiser titres et paragraphes.",
    "Pas de couleurs, pas de photos, pas de typo finale — JUSTE la structure.",
    "Envoie un screenshot au chef de projet pour validation rapide (15 min).",
    "Si OK → passer en haute fidélité. Si NON → ajuster avant de continuer."
  ]},
  {"type":"paragraph","text":"✏️ BLOCS STANDARDS D'UN SITE :"},
  {"type":"list","items":[
    "**Header** → logo gauche + menu droite + bouton CTA (60-80px de haut)",
    "**Hero** → titre principal + sous-titre + bouton + visuel (500-700px de haut)",
    "**Services/Produits** → grille 3 ou 4 colonnes (400px de haut)",
    "**À propos** → texte + image côte à côte (400px de haut)",
    "**Témoignages** → carrousel ou grille (300px de haut)",
    "**CTA final** → fond coloré + titre + bouton (300px de haut)",
    "**Footer** → 3-4 colonnes + copyright (200-300px de haut)"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Wireframe complet sur Desktop, validé par le chef de projet par écrit."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Designer qui saute le wireframe → 50% de refonte à l'arrivée. Wireframe avec couleurs → on ne valide plus la STRUCTURE, on valide le style. Trop de blocs (>8) → site lourd, simplifier."},
  {"type":"paragraph","text":"➡️ Étape suivante : design haute fidélité."},

  {"type":"heading2","text":"4. DESIGN HAUTE FIDÉLITÉ (COULEURS + PHOTOS + TYPO)"},
  {"type":"paragraph","text":"🎯 Objectif : créer la maquette finale. ⏱️ Temps : 4-6h."},
  {"type":"paragraph","text":"📍 Point de départ : wireframe validé."},
  {"type":"paragraph","text":"🖥️ OÙ : Figma, frame Desktop."},
  {"type":"numbered","items":[
    "Duplique le wireframe → renomme « 02-Design-Desktop-v1 ».",
    "Crée les styles partagés : Menu Assets → Styles → + → ajouter couleurs et typos du moodboard.",
    "Applique la couleur primaire au header et CTA.",
    "Remplace les rectangles gris par les vrais visuels (photos client ou Unsplash).",
    "Remplace Lorem ipsum par les vrais textes (fournis par le client ou rédigés).",
    "Ajoute les icônes (Feather Icons via plugin Figma « Iconify »).",
    "Vérifie le contraste texte/fond (plugin « Contrast » → min AA = 4.5:1).",
    "Décline en Tablet et Mobile (adaptation responsive)."
  ]},
  {"type":"paragraph","text":"✏️ STYLES PARTAGÉS À CRÉER (OBLIGATOIRE) :"},
  {"type":"list","items":[
    "**Color/Primary** → couleur principale (ex : #1E3A8A)",
    "**Color/Secondary** → couleur secondaire (ex : #06B6D4)",
    "**Color/Neutral-100** → fond clair (#F9FAFB)",
    "**Color/Neutral-900** → texte foncé (#111827)",
    "**Text/H1** → 48px / Montserrat Bold / line-height 1.2",
    "**Text/H2** → 32px / Montserrat Semibold / line-height 1.3",
    "**Text/Body** → 16px / Inter Regular / line-height 1.6",
    "**Text/Caption** → 14px / Inter Regular / opacity 0.7"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Design Desktop + Tablet + Mobile finis, styles partagés appliqués, contraste AA validé."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Couleurs hardcodées (pas de styles) → impossible de changer en masse, REFAIRE avec styles. Photos basse résolution → utiliser Unsplash en HD ou photos client retouchées. Mobile bâclé → 70% du trafic, le SOIGNER autant que Desktop."},
  {"type":"paragraph","text":"➡️ Étape suivante : prototype interactif."},

  {"type":"heading2","text":"5. CRÉER LE PROTOTYPE INTERACTIF"},
  {"type":"paragraph","text":"🎯 Objectif : permettre au client de cliquer comme sur un vrai site. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"📍 Point de départ : maquette haute fidélité finie."},
  {"type":"paragraph","text":"🖥️ OÙ : Figma → onglet Prototype (en haut à droite)."},
  {"type":"numbered","items":[
    "Bascule sur l'onglet Prototype (à côté de Design).",
    "Clique sur le bouton CTA du Hero → glisse une flèche vers la frame Contact.",
    "Choisis le trigger « On click » et l'animation « Smart animate » ou « Instant ».",
    "Répète pour chaque lien du menu (Accueil, Services, À propos, Contact).",
    "Définis la frame de départ (Flow starting point) sur 01-Accueil.",
    "Clique Présenter (icône play en haut droite) pour tester."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tous les liens du menu fonctionnent en mode Présentation, animations fluides."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Liens cassés → revérifier dans l'onglet Prototype. Animations trop lentes → passer en Instant. Frame de départ non définie → le client tombe sur une page random."},
  {"type":"paragraph","text":"➡️ Étape suivante : partage au client."},

  {"type":"heading2","text":"6. PARTAGER LE LIEN AU CLIENT"},
  {"type":"paragraph","text":"🎯 Objectif : obtenir une validation écrite de la maquette. ⏱️ Temps : 10 min + 48h d'attente."},
  {"type":"paragraph","text":"📍 Point de départ : prototype fonctionnel."},
  {"type":"paragraph","text":"🖥️ OÙ : Figma + WhatsApp + GestiQ."},
  {"type":"numbered","items":[
    "En haut à droite, clique Share.",
    "Change « Anyone with the link » → mode « can view » (PAS edit).",
    "Copie le lien.",
    "Envoie au client via WhatsApp avec le template ci-dessous.",
    "Sur GestiQ → commentaire « Maquette v1 envoyée le [date] » + lien.",
    "Statut projet → En attente validation client."
  ]},
  {"type":"paragraph","text":"✏️ MESSAGE WHATSAPP :"},
  {"type":"template","text":"Bonjour [Prénom],\\n\\nVoici votre maquette interactive : [lien Figma].\\n\\n🖱️ Cliquez sur Présenter (en haut à droite) pour naviguer comme sur un vrai site.\\n\\nMerci de me retourner :\\n1) Validation globale (oui/non)\\n2) Liste des modifications (max 10)\\n\\nDélai de retour souhaité : 48h.\\n\\nBelle journée,\\nÉquipe Next Gital"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Lien envoyé en mode visualisation, message envoyé, GestiQ à jour."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Lien en mode Edit → le client peut tout casser, TOUJOURS view. Pas de version v1 dans le nom → impossible de tracer les changements. Client demande 30 modifs → grouper en v2 plutôt que les faire à la volée."},
  {"type":"paragraph","text":"➡️ Étape suivante : handoff dev (si validé)."},

  {"type":"heading2","text":"7. HANDOFF DEV (REMISE AU DÉVELOPPEUR)"},
  {"type":"paragraph","text":"🎯 Objectif : donner au dev tout ce qu'il faut pour intégrer. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"📍 Point de départ : maquette validée par le client."},
  {"type":"paragraph","text":"🖥️ OÙ : Figma + GestiQ."},
  {"type":"numbered","items":[
    "Vérifie que tous les styles (couleurs + typos) sont nommés proprement.",
    "Ajoute une page « Specs » au fichier Figma avec : palette couleurs, typos, espacements standards.",
    "Exporte les assets : sélectionne icônes/logos → onglet Export → SVG ou PNG @2x.",
    "Range dans Drive : Clients/[client]/03_Assets/.",
    "Sur GestiQ → assigne le projet au développeur avec commentaire « Maquette validée, handoff prêt ».",
    "Partage le lien Figma au dev en mode « can view »."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Page Specs créée, assets exportés dans Drive, dev assigné sur GestiQ."},

  {"type":"divider"},

  {"type":"heading2","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Fichier Figma nommé correctement (Client-Type-vX)",
    "Frames Desktop 1440x900 + Tablet 768x1024 + Mobile 375x812",
    "Wireframe basse fidélité validé chef de projet",
    "Design haute fidélité avec styles partagés",
    "Contraste AA vérifié (plugin Contrast)",
    "Prototype interactif fonctionnel",
    "Lien partagé en mode view (jamais edit)",
    "Message WhatsApp envoyé au client",
    "Statut GestiQ : En attente validation",
    "Handoff dev préparé après validation"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Bloqué plus de 30 min ? WhatsApp Next Gital +212 620 002 066 / info@nextgital.com."}
]$sop$::jsonb,
    read_min = 15,
    updated_at = now()
WHERE slug IN ('ng-design-maquette-figma','ng-ds-figma-maquettes');


-- ────────────────────────────────────────────────────────────────────
-- 3) VISUELS RÉSEAUX SOCIAUX  →  ng-design-visuels-reseaux + ng-ds-visuels-reseaux
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"Pour qui ?","text":"Designer Next Gital en charge des visuels Instagram / Facebook / TikTok / LinkedIn d'un client."},
  {"type":"callout","variant":"tip","title":"Pourquoi batcher ?","text":"Créer 10-15 posts d'un coup = 3h. Créer 1 post à la fois = 15h pour le même résultat."},
  {"type":"callout","variant":"warning","title":"Pré-requis","text":"Charte graphique du client uploadée en Kit de marque Canva. Sans charte, pas de cohérence."},

  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. CONFIGURER LE KIT DE MARQUE CLIENT DANS CANVA"},
  {"type":"paragraph","text":"🎯 Objectif : avoir un accès 1-clic aux couleurs/logos/typos du client. ⏱️ Temps : 20 min (1 seule fois)."},
  {"type":"paragraph","text":"📍 Point de départ : charte client validée."},
  {"type":"paragraph","text":"🖥️ OÙ : canva.com → Brand Hub → Brand Kit."},
  {"type":"numbered","items":[
    "Connecte-toi sur canva.com avec design@nextgital.com.",
    "Sidebar gauche → Brand → Brand Kits → + Créer un kit.",
    "Nomme-le : [Client] - Brand Kit (ex : Dr-Karim - Brand Kit).",
    "Section Couleurs → ajouter les 4 couleurs HEX de la charte.",
    "Section Logos → upload le logo principal + variantes (blanc/noir/horizontal).",
    "Section Fonts → ajouter les 2 typos (titre + body) depuis Google Fonts.",
    "Section Photos → upload les photos signature du client."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Kit visible dans la sidebar Canva avec couleurs, logos, typos, photos."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Couleurs en RGB → toujours HEX dans Canva. Logo en JPG avec fond blanc → utiliser PNG transparent. Polices non disponibles dans Canva Free → vérifier accès Pro."},
  {"type":"paragraph","text":"➡️ Étape suivante : planifier les visuels du mois."},

  {"type":"heading2","text":"2. PLANIFIER LES POSTS DU MOIS (CONTENT PLAN)"},
  {"type":"paragraph","text":"🎯 Objectif : savoir QUOI poster et QUAND avant de designer. ⏱️ Temps : 1h."},
  {"type":"paragraph","text":"📍 Point de départ : brief client + objectifs marketing."},
  {"type":"paragraph","text":"🖥️ OÙ : Google Sheets dans Drive client / 04_Social-Media/."},
  {"type":"numbered","items":[
    "Ouvre le template Sheets « Content Plan Mensuel » (Drive / Templates).",
    "Duplique-le dans Drive/Clients/[client]/04_Social-Media/Content-Plan-[Mois].",
    "Remplis 12-15 lignes : date, plateforme, format, sujet, CTA, statut.",
    "Catégorise : 40% éducatif / 30% promo / 20% témoignages / 10% behind-the-scenes.",
    "Fais valider par le chef de projet et le client AVANT de designer."
  ]},
  {"type":"paragraph","text":"✏️ STRUCTURE DU CONTENT PLAN :"},
  {"type":"table","content":{"headers":["Date","Plateforme","Format","Sujet","CTA"],"rows":[["05/06","Instagram","Carrousel 1080x1080","5 conseils blanchiment dentaire","Prendre RDV"],["07/06","Instagram","Story 1080x1920","Avant/Après patient","Voir +"],["10/06","Facebook","Post 1200x630","Promo détartrage -20%","Réserver"]]}},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Sheets rempli avec 12-15 posts validés par client et chef de projet."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Trop de promo (>30%) → l'audience décroche. Pas de CTA → le post ne convertit pas. Tous les posts identiques → varier les formats."},
  {"type":"paragraph","text":"➡️ Étape suivante : créer les templates Canva."},

  {"type":"heading2","text":"3. CRÉER LES TEMPLATES CANVA AUX BONNES TAILLES"},
  {"type":"paragraph","text":"🎯 Objectif : avoir 3 templates réutilisables par format. ⏱️ Temps : 1h."},
  {"type":"paragraph","text":"📍 Point de départ : Brand Kit configuré, content plan validé."},
  {"type":"paragraph","text":"🖥️ OÙ : canva.com."},
  {"type":"numbered","items":[
    "Crée un nouveau design → Taille personnalisée 1080 x 1080 px (post Insta carré).",
    "Applique le Brand Kit (sidebar gauche → Brand → ton kit).",
    "Crée 3 layouts : Citation, Conseil chiffré, Promo.",
    "Enregistre comme Template (clic droit sur le design → Save as template).",
    "Répète pour 1080 x 1350 (portrait Insta), 1080 x 1920 (story), 1200 x 630 (Facebook)."
  ]},
  {"type":"paragraph","text":"✏️ TAILLES OFFICIELLES À MÉMORISER :"},
  {"type":"list","items":[
    "**Instagram post carré** → 1080 x 1080 px",
    "**Instagram post portrait** → 1080 x 1350 px (ratio 4:5, prend + de place dans le feed)",
    "**Instagram Story/Reel** → 1080 x 1920 px (ratio 9:16)",
    "**Facebook post** → 1200 x 630 px",
    "**LinkedIn post** → 1200 x 1200 px (carré) ou 1200 x 627 px (paysage)",
    "**TikTok cover** → 1080 x 1920 px",
    "**YouTube thumbnail** → 1280 x 720 px"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"4 tailles de templates créées et taggées « Template - [Client] »."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Tailles obsolètes (800x800) → Instagram crop, image floue. Pas de safe zone story → texte coupé par la barre Insta. Format vidéo TikTok en 1:1 → l'algorithme défavorise."},
  {"type":"paragraph","text":"➡️ Étape suivante : batcher la création."},

  {"type":"heading2","text":"4. BATCHING : CRÉER 10-15 POSTS D'AFFILÉE"},
  {"type":"paragraph","text":"🎯 Objectif : produire en masse sans changer de contexte. ⏱️ Temps : 3-4h pour 15 posts."},
  {"type":"paragraph","text":"📍 Point de départ : templates prêts, content plan validé."},
  {"type":"paragraph","text":"🖥️ OÙ : Canva."},
  {"type":"numbered","items":[
    "Mode plein écran Canva (touche F).",
    "Duplique le template Citation 10 fois (Page Manager en bas).",
    "Remplis chaque page avec un sujet du content plan.",
    "Vérifie : logo client en bas à droite, couleurs du Brand Kit, typos cohérentes.",
    "Mute notifications WhatsApp/Slack pendant 2h.",
    "Pause 5 min toutes les 25 min (Pomodoro)."
  ]},
  {"type":"paragraph","text":"✏️ CHECKLIST PAR POST :"},
  {"type":"list","items":[
    "**Logo client** → présent, lisible, ne masque pas le visuel",
    "**Couleur de fond** → issue du Brand Kit (pas une couleur random)",
    "**Hiérarchie texte** → 1 gros titre + 1 sous-titre max (lisible mobile)",
    "**CTA visible** → ex : « Prendre RDV », « Lien en bio »",
    "**Photo** → HD, droits OK (Canva Photos ou client)",
    "**Marges** → 80px de safe zone par bord (pour Insta crop)"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"10-15 posts créés en un seul shot, tous cohérents avec le Brand Kit."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Texte trop petit (<24pt) → illisible sur mobile, augmenter. Logo absent → règle d'or, TOUJOURS le logo. Couleurs hors charte → re-vérifier Brand Kit."},
  {"type":"paragraph","text":"➡️ Étape suivante : export et livraison."},

  {"type":"heading2","text":"5. EXPORTER EN PNG HAUTE QUALITÉ"},
  {"type":"paragraph","text":"🎯 Objectif : avoir les fichiers prêts à publier. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : posts validés."},
  {"type":"paragraph","text":"🖥️ OÙ : Canva → bouton Partager → Télécharger."},
  {"type":"numbered","items":[
    "Bouton Partager (haut droite) → Télécharger.",
    "Type de fichier : PNG (JPG si fond plein, pas de transparence).",
    "Sélection : Toutes les pages.",
    "Coche « Taille » : x1 (HD suffit pour Insta).",
    "Coche « Compresser » si poids > 5 Mo.",
    "Clique Télécharger → fichier ZIP de toutes les pages."
  ]},
  {"type":"paragraph","text":"✏️ NOMMAGE DES FICHIERS EXPORTÉS :"},
  {"type":"list","items":[
    "**Format** → [client]-[date]-[format]-[numéro].png",
    "**Exemple** → drkarim-2026-06-05-insta-carre-01.png",
    "**Ne PAS** → IMG_001.png, Sans titre.png, image (1).png"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tous les PNG nommés, rangés dans Drive / 04_Social-Media/Exports-[Mois]/."},

  {"type":"heading2","text":"6. LIVRAISON AU COMMUNITY MANAGER"},
  {"type":"paragraph","text":"🎯 Objectif : passer le relais au CM pour publication. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : exports prêts dans Drive."},
  {"type":"paragraph","text":"🖥️ OÙ : Drive + GestiQ + WhatsApp."},
  {"type":"numbered","items":[
    "Vérifie que tous les visuels sont dans Drive / Clients/[client]/04_Social-Media/Exports-[Mois]/.",
    "Sur GestiQ → tâche « Visuels [mois] livrés » → assigner au CM (community manager).",
    "WhatsApp au CM : « Visuels juin prêts dans Drive, à toi pour la programmation. »",
    "Statut du projet → Livré au CM."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"CM notifié, statut GestiQ à jour, dossier Drive organisé."},

  {"type":"divider"},

  {"type":"heading2","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Brand Kit Canva configuré (couleurs + logos + typos)",
    "Content plan validé par client",
    "Templates créés aux 4 tailles standards",
    "10-15 posts batchés en un seul créneau",
    "Logo client présent sur chaque visuel",
    "Couleurs et typos issues du Brand Kit",
    "Textes lisibles sur mobile (>24pt)",
    "Export PNG haute qualité",
    "Nommage [client]-[date]-[format]-[num].png",
    "Livraison au CM via Drive + WhatsApp + GestiQ"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Bloqué plus de 30 min ? WhatsApp Next Gital +212 620 002 066 / info@nextgital.com."}
]$sop$::jsonb,
    read_min = 12,
    updated_at = now()
WHERE slug IN ('ng-design-visuels-reseaux','ng-ds-visuels-reseaux');


-- ────────────────────────────────────────────────────────────────────
-- 4) LOGO + CHARTE GRAPHIQUE  →  ng-design-identite-logo + ng-ds-charte-graphique
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"Pour qui ?","text":"Designer Next Gital chargé de créer un logo + une charte graphique complète pour un nouveau client."},
  {"type":"callout","variant":"tip","title":"Pourquoi une charte ?","text":"Le logo seul = 20% du travail. La charte = 80%. Sans charte, le client (et le dev, et le CM) feront n'importe quoi en 6 mois."},
  {"type":"callout","variant":"warning","title":"Pré-requis","text":"Brief validé + moodboard approuvé. Le logo s'inspire du moodboard."},

  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. EXPLORATION : 5 PISTES DE LOGO"},
  {"type":"paragraph","text":"🎯 Objectif : proposer 5 directions différentes au client (pas 1, pas 30). ⏱️ Temps : 3h."},
  {"type":"paragraph","text":"📍 Point de départ : moodboard validé."},
  {"type":"paragraph","text":"🖥️ OÙ : Figma → nouveau fichier « [Client] - Logo - Exploration »."},
  {"type":"numbered","items":[
    "Crée un nouveau fichier Figma → équipe Next Gital → projet Clients 2026.",
    "Frame 1920x1080, fond #F9FAFB.",
    "Dessine 5 pistes côte à côte, chacune dans un carré de 400x400.",
    "Varie les approches : 1 typo seule, 1 typo + symbole, 1 monogramme, 1 abstrait, 1 illustré.",
    "Travaille en NOIR ET BLANC d'abord (test du dessin pur).",
    "Ajoute un titre à chaque piste : « Piste 1 - Typographique », « Piste 2 - Symbole », etc."
  ]},
  {"type":"paragraph","text":"✏️ LES 5 APPROCHES STANDARDS :"},
  {"type":"list","items":[
    "**Typographique** → juste le nom dans une typo travaillée (ex : Google, Coca-Cola)",
    "**Symbole + nom** → pictogramme à côté ou au-dessus du nom (ex : Adidas)",
    "**Monogramme** → 1-2 lettres stylisées (ex : Louis Vuitton LV)",
    "**Abstrait** → forme géométrique sans signification directe (ex : Nike swoosh)",
    "**Illustré** → dessin figuratif (ex : Lacoste crocodile, Starbucks sirène)"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"5 pistes visibles, en noir et blanc, suffisamment différentes les unes des autres."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"5 pistes identiques → on n'aide pas le client à choisir. Couleurs dès le départ → on triche, le client choisit la couleur pas le dessin. Logo générique téléchargé → INTERDIT, on crée from scratch."},
  {"type":"paragraph","text":"➡️ Étape suivante : envoi pour pré-sélection."},

  {"type":"heading2","text":"2. PRÉ-SÉLECTION CLIENT (CHOIX D'1 PISTE)"},
  {"type":"paragraph","text":"🎯 Objectif : laisser le client choisir 1 direction. ⏱️ Temps : 30 min + 24-48h d'attente."},
  {"type":"paragraph","text":"📍 Point de départ : 5 pistes prêtes."},
  {"type":"paragraph","text":"🖥️ OÙ : Figma → bouton Share + WhatsApp."},
  {"type":"numbered","items":[
    "Export du fichier en PDF (Fichier → Export → PDF).",
    "Upload dans Drive / Clients/[client]/02_Logo/Exploration-v1.pdf.",
    "Partage le lien Figma en mode view.",
    "WhatsApp au client avec le template ci-dessous."
  ]},
  {"type":"paragraph","text":"✏️ MESSAGE WHATSAPP :"},
  {"type":"template","text":"Bonjour [Prénom],\\n\\nVoici 5 pistes de logo pour [marque] : [lien Figma].\\n\\nElles sont volontairement en noir et blanc pour évaluer le DESSIN avant la couleur.\\n\\nMerci de me dire :\\n- Quelle piste vous parle le plus (1, 2, 3, 4 ou 5)\\n- 2 mots pour décrire ce qui vous plaît\\n\\nUne seule à choisir — nous la déclinerons ensuite en couleur.\\n\\nÉquipe Next Gital"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Client a choisi UNE piste par écrit."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Client veut mélanger 2 pistes → refuser poliment, on travaille 1 direction à la fois. Client ne choisit pas → relancer en 48h. Client veut tout refaire → moodboard pas assez précis, revoir l'étape 0."},
  {"type":"paragraph","text":"➡️ Étape suivante : raffinage."},

  {"type":"heading2","text":"3. RAFFINAGE + DÉCLINAISONS COULEUR"},
  {"type":"paragraph","text":"🎯 Objectif : finaliser le logo + créer toutes ses variantes. ⏱️ Temps : 4h."},
  {"type":"paragraph","text":"📍 Point de départ : piste choisie par le client."},
  {"type":"paragraph","text":"🖥️ OÙ : Figma → nouveau fichier « [Client] - Logo - Final »."},
  {"type":"numbered","items":[
    "Nouveau fichier Figma → frame 1920x1080.",
    "Place le logo principal au centre (version horizontale couleur).",
    "Décline en 6 variantes : horizontal couleur, horizontal noir, horizontal blanc, vertical couleur, monogramme, favicon.",
    "Vérifie la lisibilité à 16px (taille favicon).",
    "Teste sur fond clair + fond foncé + fond photo.",
    "Définis la zone d'exclusion (espace minimal autour du logo)."
  ]},
  {"type":"paragraph","text":"✏️ VARIANTES OBLIGATOIRES :"},
  {"type":"list","items":[
    "**Principal horizontal couleur** → usage par défaut",
    "**Horizontal noir** → fond clair, impression N&B",
    "**Horizontal blanc** → fond foncé ou photo",
    "**Vertical/Empilé** → formats carrés (avatar Insta)",
    "**Monogramme** → 1-2 lettres pour favicon ou icône app",
    "**Favicon 32x32** → onglet navigateur",
    "**Avatar 1080x1080** → pour réseaux sociaux"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"6 variantes créées, testées sur 3 fonds, lisibles à toutes les tailles."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Logo illisible à 32px → simplifier les détails. Pas de version blanche → impossible à utiliser sur fond foncé. Logo en .jpg → INTERDIT, toujours vectoriel SVG."},
  {"type":"paragraph","text":"➡️ Étape suivante : créer la charte graphique."},

  {"type":"heading2","text":"4. CRÉER LA CHARTE GRAPHIQUE (FIGMA, 12 PAGES)"},
  {"type":"paragraph","text":"🎯 Objectif : document de référence pour tout l'écosystème visuel. ⏱️ Temps : 6h."},
  {"type":"paragraph","text":"📍 Point de départ : logo finalisé."},
  {"type":"paragraph","text":"🖥️ OÙ : Figma → nouveau fichier « [Client] - Charte Graphique »."},
  {"type":"numbered","items":[
    "Nouveau fichier Figma → 12 frames de 1920x1080 alignées horizontalement.",
    "Remplis chaque frame selon la structure ci-dessous.",
    "Utilise les styles partagés (couleurs + typos) du logo.",
    "Ajoute le logo Next Gital en pied de page de chaque slide.",
    "Numéroter les pages (Page 1/12, Page 2/12, etc.).",
    "Exporter en PDF haute qualité."
  ]},
  {"type":"paragraph","text":"✏️ STRUCTURE DES 12 PAGES :"},
  {"type":"list","items":[
    "**Page 1** → Couverture (logo + nom marque + « Charte Graphique » + date)",
    "**Page 2** → Sommaire",
    "**Page 3** → Histoire / valeurs de la marque (1 paragraphe)",
    "**Page 4** → Logo principal + variantes (6 versions)",
    "**Page 5** → Zones d'exclusion + tailles minimales",
    "**Page 6** → INTERDITS (déformer, recolorier, rotation, etc.)",
    "**Page 7** → Palette couleurs (4 couleurs : HEX + RGB + CMJN + Pantone)",
    "**Page 8** → Typographies (titre + sous-titre + body + tailles)",
    "**Page 9** → Iconographie (style + exemples)",
    "**Page 10** → Photographie (style + traitement)",
    "**Page 11** → Exemples d'application (carte de visite, post Insta, header site)",
    "**Page 12** → Contacts Next Gital + crédits"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"12 pages remplies, exportées en PDF, lisibles et cohérentes."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Charte de 50 pages → personne ne la lit, RESTER à 12. Pas d'exemples d'usage → le client ne sait pas appliquer. Couleurs sans RGB/CMJN → impossible pour l'imprimeur."},
  {"type":"paragraph","text":"➡️ Étape suivante : exports finaux."},

  {"type":"heading2","text":"5. EXPORT DES FICHIERS LOGO (PACK COMPLET)"},
  {"type":"paragraph","text":"🎯 Objectif : livrer un pack utilisable partout. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"📍 Point de départ : logo et charte finis."},
  {"type":"paragraph","text":"🖥️ OÙ : Figma → Export + Drive."},
  {"type":"numbered","items":[
    "Sélectionne chaque variante du logo dans Figma.",
    "Panneau Export → ajouter 3 formats : SVG, PNG @2x, PDF.",
    "Clique Export → enregistre dans ~/Designs/[client]/logo-final/.",
    "Organise les fichiers selon la structure ci-dessous.",
    "Upload tout dans Drive / Clients/[client]/05_Livraison/Logo-Final/."
  ]},
  {"type":"paragraph","text":"✏️ STRUCTURE DU PACK LIVRÉ :"},
  {"type":"list","items":[
    "**01_Logo-Principal/** → horizontal-couleur.svg + .png + .pdf",
    "**02_Variantes/** → horizontal-noir, horizontal-blanc, vertical-couleur, etc.",
    "**03_Monogramme/** → favicon-32.png + monogramme.svg",
    "**04_Avatar-Reseaux/** → avatar-1080.png",
    "**05_Charte-Graphique.pdf** → le PDF 12 pages",
    "**README.txt** → mode d'emploi en français (« utilisez le SVG pour le web, PDF pour impression »)"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Pack complet dans Drive avec arborescence claire et README."},

  {"type":"heading2","text":"6. PRÉSENTATION LIVE AU CLIENT"},
  {"type":"paragraph","text":"🎯 Objectif : présenter la charte en visio pour ancrer l'usage. ⏱️ Temps : 1h."},
  {"type":"paragraph","text":"📍 Point de départ : pack livré dans Drive."},
  {"type":"paragraph","text":"🖥️ OÙ : Google Meet ou présentiel bureau Next Gital."},
  {"type":"numbered","items":[
    "Planifie une visio 1h avec le client (via GestiQ → calendrier).",
    "Partage l'écran avec le PDF de la charte.",
    "Présente page par page, en expliquant les choix.",
    "Insiste sur les INTERDITS (page 6) et les exemples d'usage (page 11).",
    "Réponds aux questions, note les éventuels ajustements.",
    "Envoie le pack final par WhatsApp après la visio."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Visio faite, client a accusé réception du pack, projet clôturé sur GestiQ."},

  {"type":"divider"},

  {"type":"heading2","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "5 pistes de logo en noir et blanc présentées",
    "1 piste choisie par client par écrit",
    "6 variantes du logo créées (couleur + noir + blanc + vertical + mono + favicon)",
    "Logo testé sur fond clair, foncé, photo",
    "Zone d'exclusion définie",
    "Charte 12 pages en PDF",
    "Couleurs en HEX + RGB + CMJN",
    "Pack final structuré dans Drive (Logo-Principal, Variantes, Charte, README)",
    "Présentation visio au client"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Bloqué plus de 30 min ? WhatsApp Next Gital +212 620 002 066 / info@nextgital.com."}
]$sop$::jsonb,
    read_min = 18,
    updated_at = now()
WHERE slug IN ('ng-design-identite-logo','ng-ds-charte-graphique');


-- ────────────────────────────────────────────────────────────────────
-- 5) VISUELS PUBLICITAIRES  →  ng-design-visuels-pub
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"Pour qui ?","text":"Designer Next Gital qui crée des visuels payants pour Facebook Ads, Instagram Ads, Google Display."},
  {"type":"callout","variant":"tip","title":"Pourquoi des visuels dédiés ?","text":"Un visuel organique et un visuel pub n'ont pas les mêmes règles. CTA gigantesque, marque visible, max 20% de texte, A/B testing."},
  {"type":"callout","variant":"warning","title":"Pré-requis","text":"Brief du Media Buyer : objectif (conversion / trafic / awareness), audience, message-clé, CTA, deadline."},

  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. LIRE LE BRIEF DU MEDIA BUYER"},
  {"type":"paragraph","text":"🎯 Objectif : aligner visuel et stratégie ads. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : tâche assignée par le Media Buyer dans GestiQ."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → projet → onglet Ads."},
  {"type":"numbered","items":[
    "Ouvre la tâche « Visuels Ads » sur GestiQ.",
    "Lis le brief du Media Buyer.",
    "Identifie : campagne, objectif (CPL, CPM, ROAS), audience, message, CTA, USP.",
    "Note les formats demandés (Feed 1080x1080, Story 1080x1920, Carrousel).",
    "Note le nombre de variantes à produire (typiquement 3 pour A/B test)."
  ]},
  {"type":"paragraph","text":"✏️ INFOS À EXTRAIRE :"},
  {"type":"list","items":[
    "**Objectif** → conversion / trafic / lead / awareness",
    "**Audience cible** → ex : femmes 25-45 Oujda intéressées par esthétique",
    "**Message principal** → ex : « Blanchiment dentaire à -30% »",
    "**CTA exact** → ex : « Prendre RDV », « En savoir + », « Acheter »",
    "**USP** → unique selling point (ex : « 1ère consultation gratuite »)",
    "**Formats** → liste exacte avec dimensions",
    "**Nombre de variantes** → généralement 3 pour A/B test"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Toutes les infos brief sont notées dans un doc avant de designer."},
  {"type":"paragraph","text":"➡️ Étape suivante : créer les visuels Feed."},

  {"type":"heading2","text":"2. CRÉER LES VISUELS FACEBOOK FEED (1200x628 + 1080x1080)"},
  {"type":"paragraph","text":"🎯 Objectif : 3 variantes optimisées feed Facebook. ⏱️ Temps : 1h30."},
  {"type":"paragraph","text":"📍 Point de départ : brief Media Buyer lu."},
  {"type":"paragraph","text":"🖥️ OÙ : canva.com → taille personnalisée."},
  {"type":"numbered","items":[
    "Crée un design 1200 x 628 px (format paysage Facebook).",
    "Applique le Brand Kit du client.",
    "Place le visuel principal (produit / photo / illustration).",
    "Ajoute le message court (max 6 mots, gros : 60-80pt).",
    "Place le CTA dans un bouton coloré contrasté (coin bas-droit).",
    "Logo client en coin haut-gauche, petite taille (max 100px).",
    "Vérifie la règle des 20% de texte (outil Facebook Text Overlay Check).",
    "Duplique en 2 variantes (changer photo OU message OU couleur)."
  ]},
  {"type":"paragraph","text":"✏️ RÈGLES PUB FACEBOOK :"},
  {"type":"list","items":[
    "**Max 20% de texte** sur l'image (sinon FB limite la diffusion)",
    "**Message ultra-court** → 6 mots max",
    "**CTA visible** → bouton contrasté, action verbale",
    "**Marque visible** → logo dans un coin (non envahissant)",
    "**Contraste fort** → texte parfaitement lisible (test sur mobile)",
    "**Visage humain** → +30% d'engagement vs visuels sans humain",
    "**Bordure colorée** → optionnel, attire l'œil dans le feed"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"3 variantes Feed créées, règle 20% respectée, CTA et logo visibles."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Trop de texte → FB limite la portée, refaire. CTA absent → personne ne clique. Photo générique stock → utiliser photos réelles client si possible."},
  {"type":"paragraph","text":"➡️ Étape suivante : visuels Story."},

  {"type":"heading2","text":"3. CRÉER LES VISUELS STORY (1080x1920)"},
  {"type":"paragraph","text":"🎯 Objectif : 3 variantes verticales pour Story Insta/FB. ⏱️ Temps : 1h."},
  {"type":"paragraph","text":"📍 Point de départ : visuels Feed validés."},
  {"type":"paragraph","text":"🖥️ OÙ : Canva → 1080 x 1920 px."},
  {"type":"numbered","items":[
    "Nouveau design 1080 x 1920 px.",
    "Définis la safe zone : 250px en haut (barre Insta) + 250px en bas (barre profil + swipe up).",
    "Place le message dans le tiers central (600 à 1200px vertical).",
    "Ajoute un sticker CTA en bas : « Swipe up », « Voir plus », « Réserver ».",
    "Logo client en haut, petit (max 80px).",
    "Décline en 3 variantes."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Story 9:16, safe zone respectée, CTA dans la zone visible."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Texte dans la safe zone → coupé. CTA en bas dans la zone profil → masqué. Visuel 1:1 redimensionné en 9:16 → image étirée."},
  {"type":"paragraph","text":"➡️ Étape suivante : carrousels."},

  {"type":"heading2","text":"4. CARROUSEL (1080x1080 x 5-10 SLIDES)"},
  {"type":"paragraph","text":"🎯 Objectif : storytelling en plusieurs slides. ⏱️ Temps : 2h."},
  {"type":"paragraph","text":"📍 Point de départ : message en plusieurs étapes (problème, solution, preuve, offre, CTA)."},
  {"type":"paragraph","text":"🖥️ OÙ : Canva → 1080 x 1080 px x 5-10 pages."},
  {"type":"numbered","items":[
    "Crée un design 1080 x 1080 avec 5 à 10 pages.",
    "Slide 1 : Hook (titre choc qui interpelle).",
    "Slides 2-4 : Développement (problème, conséquences, solution).",
    "Slides 5-7 : Preuves (témoignage, avant/après, chiffres).",
    "Slide 8 : Offre (promo, USP).",
    "Slide 9-10 : CTA (« Prendre RDV », « Lien en bio »).",
    "Cohérence visuelle : même fond, même typo, même palette."
  ]},
  {"type":"paragraph","text":"✏️ STRUCTURE EXEMPLE CARROUSEL DENTISTE :"},
  {"type":"list","items":[
    "**Slide 1** → « Vous avez peur du dentiste ? » (visage femme inquiète)",
    "**Slide 2** → « 80% des Marocains repoussent leur RDV par peur » (chiffre)",
    "**Slide 3** → « Résultat : caries, infections, coûts qui explosent »",
    "**Slide 4** → « Chez Dr. Karim, on a la solution »",
    "**Slide 5** → « Sédation consciente sans douleur »",
    "**Slide 6** → « +1200 patients satisfaits depuis 2018 »",
    "**Slide 7** → « Avant/Après détartrage »",
    "**Slide 8** → « 1ère consultation OFFERTE en juin »",
    "**Slide 9** → « Prendre RDV → lien en bio »"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Carrousel cohérent, slide 1 accrocheuse, dernière slide avec CTA clair."},
  {"type":"paragraph","text":"➡️ Étape suivante : export et nommage."},

  {"type":"heading2","text":"5. EXPORT + NOMMAGE POUR A/B TESTING"},
  {"type":"paragraph","text":"🎯 Objectif : fichiers prêts à uploader dans Ads Manager. ⏱️ Temps : 20 min."},
  {"type":"paragraph","text":"📍 Point de départ : tous les visuels validés."},
  {"type":"paragraph","text":"🖥️ OÙ : Canva → Download + Drive."},
  {"type":"numbered","items":[
    "Export chaque visuel en PNG haute qualité.",
    "Nommage strict : [client]-[campagne]-[format]-[variante].png.",
    "Range dans Drive / Clients/[client]/06_Ads/[Campagne]/.",
    "Crée un sous-dossier par format (Feed, Story, Carrousel).",
    "Notifie le Media Buyer sur GestiQ + WhatsApp."
  ]},
  {"type":"paragraph","text":"✏️ NOMMAGE OBLIGATOIRE :"},
  {"type":"list","items":[
    "**Format** → [client]-[campagne]-[format]-[variante].png",
    "**Exemple** → drkarim-blanchiment-juin-feed1200x628-v1.png",
    "**Variantes** → toujours v1, v2, v3 (pour le A/B test)"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tous les fichiers nommés et rangés, Media Buyer notifié."},

  {"type":"heading2","text":"6. SUIVI APRÈS LANCEMENT DES ADS"},
  {"type":"paragraph","text":"🎯 Objectif : analyser quel visuel performe le mieux. ⏱️ Temps : 30 min après 7 jours de campagne."},
  {"type":"paragraph","text":"📍 Point de départ : Media Buyer a lancé les ads."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → onglet Ads → reporting Media Buyer."},
  {"type":"numbered","items":[
    "Après 7 jours, demande au Media Buyer le rapport CTR/CPC par visuel.",
    "Identifie le visuel gagnant (meilleur CTR ou meilleur CPL).",
    "Note ce qui a fonctionné : couleur, message, format.",
    "Reproduis le pattern pour la prochaine campagne (= itération).",
    "Archive les apprentissages dans Drive / Templates/Learnings-Ads.md."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Analyse faite, apprentissages documentés."},

  {"type":"divider"},

  {"type":"heading2","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Brief Media Buyer lu (objectif, audience, CTA, format, variantes)",
    "Visuels Feed 1200x628 + 1080x1080 (3 variantes)",
    "Visuels Story 1080x1920 (3 variantes, safe zone respectée)",
    "Carrousel 5-10 slides avec hook + CTA",
    "Règle des 20% texte respectée (Facebook)",
    "Logo client visible mais non envahissant",
    "Nommage [client]-[campagne]-[format]-[variante].png",
    "Fichiers livrés au Media Buyer via Drive + GestiQ",
    "Analyse post-campagne après 7 jours"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Bloqué plus de 30 min ? WhatsApp Next Gital +212 620 002 066 / info@nextgital.com."}
]$sop$::jsonb,
    read_min = 14,
    updated_at = now()
WHERE slug = 'ng-design-visuels-pub';


-- ────────────────────────────────────────────────────────────────────
-- 6) STANDARDS QUALITÉ  →  ng-design-standards-qualite + ng-ds-standards-nextgital
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"Pour qui ?","text":"Tout designer Next Gital, à appliquer SYSTÉMATIQUEMENT avant chaque livraison client."},
  {"type":"callout","variant":"tip","title":"Pourquoi des standards ?","text":"Cohérence Next Gital = qualité perçue. Un livrable mal nommé ou mal exporté = client qui doute de notre pro."},
  {"type":"callout","variant":"warning","title":"Règle d'or","text":"Aucun fichier ne sort de Next Gital sans avoir passé cette checklist en intégralité."},

  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. NOMMAGE DES FICHIERS (CONVENTION OBLIGATOIRE)"},
  {"type":"paragraph","text":"🎯 Objectif : tout fichier doit être identifiable en 2 secondes. ⏱️ Temps : 5 min par projet."},
  {"type":"paragraph","text":"📍 Point de départ : fichier prêt à être exporté."},
  {"type":"paragraph","text":"🖥️ OÙ : Finder Mac / Explorer Windows / Drive."},
  {"type":"numbered","items":[
    "Format strict : [client]-[type]-[detail]-[version].[ext].",
    "Tout en minuscules, sans accents, sans espaces.",
    "Séparateur = tiret (jamais underscore, jamais espace).",
    "Version toujours v1, v2, v3 (jamais final, jamais FINAL2).",
    "Date optionnelle : YYYY-MM-DD si pertinent."
  ]},
  {"type":"paragraph","text":"✏️ EXEMPLES OK / PAS OK :"},
  {"type":"list","items":[
    "**OK** → drkarim-logo-horizontal-v1.svg",
    "**OK** → cabinetfedix-site-maquette-desktop-v2.fig",
    "**OK** → pharmandalous-insta-promo-2026-06-15-v1.png",
    "**PAS OK** → Logo Final.png (espaces, majuscules, pas de client)",
    "**PAS OK** → DESIGN FINAL FINAL2.jpg (majuscules, FINAL2)",
    "**PAS OK** → image (1).png (nom auto système)",
    "**PAS OK** → karim_logo.png (underscore au lieu de tiret)"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tous les fichiers du projet respectent la convention, vérifiable visuellement dans Finder."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Fichiers téléchargés du navigateur avec noms auto → TOUJOURS renommer avant de ranger. Trop de versions (v1, v2, v3, v4 final, v5 final corrigé) → archiver v1-v3 dans un sous-dossier _archive."},
  {"type":"paragraph","text":"➡️ Étape suivante : arborescence Drive."},

  {"type":"heading2","text":"2. ARBORESCENCE DRIVE CLIENT (STRUCTURE FIXE)"},
  {"type":"paragraph","text":"🎯 Objectif : tous les projets ont la même structure pour qu'on s'y retrouve. ⏱️ Temps : 10 min à la création."},
  {"type":"paragraph","text":"📍 Point de départ : nouveau client, dossier vide."},
  {"type":"paragraph","text":"🖥️ OÙ : drive.google.com → Drive partagés → Next Gital - Clients."},
  {"type":"numbered","items":[
    "Crée le dossier client avec le nommage : [Nom-Client] (ex : Dr-Karim-Cabinet-Dentaire).",
    "À l'intérieur, crée les 6 sous-dossiers suivants (TOUJOURS les mêmes).",
    "Si un sous-dossier n'est pas utilisé, le créer quand même vide."
  ]},
  {"type":"paragraph","text":"✏️ STRUCTURE TYPE D'UN DOSSIER CLIENT :"},
  {"type":"list","items":[
    "**01_Brief/** → moodboard, photos client, charte existante, recherches concurrents",
    "**02_Logo-Charte/** → fichiers source + exports logo + charte PDF",
    "**03_Maquettes/** → fichiers Figma + screenshots de validation",
    "**04_Social-Media/** → content plan + visuels Insta/FB/TikTok",
    "**05_Livraison/** → version FINALE remise au client (read-only)",
    "**06_Ads/** → visuels publicitaires par campagne (sous-dossiers par campagne)",
    "**99_Archive/** → vieilles versions, brouillons abandonnés"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Les 7 sous-dossiers existent, identiques pour TOUS les clients."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Designer qui crée ses propres dossiers (« Mon dossier ») → INTERDIT. Mélange brouillons et finaux → utiliser 99_Archive pour ce qui n'est plus à jour."},
  {"type":"paragraph","text":"➡️ Étape suivante : choix des formats d'export."},

  {"type":"heading2","text":"3. FORMATS D'EXPORT SELON USAGE"},
  {"type":"paragraph","text":"🎯 Objectif : livrer le bon format au bon usage. ⏱️ Temps : 5 min par export."},
  {"type":"paragraph","text":"📍 Point de départ : livrable à exporter."},
  {"type":"paragraph","text":"🖥️ OÙ : Figma/Canva/Photoshop → menu Export."},
  {"type":"numbered","items":[
    "Identifie l'usage : web, impression, réseau social, ads, app.",
    "Choisis le format selon la règle ci-dessous.",
    "Exporte en HD minimum (jamais en basse qualité)."
  ]},
  {"type":"paragraph","text":"✏️ TABLEAU DES FORMATS :"},
  {"type":"table","content":{"headers":["Usage","Format","Note"],"rows":[["Logo web","SVG","Vectoriel, infini scalable"],["Logo impression","PDF / SVG","Vectoriel, CMJN"],["Logo avec transparence","PNG","Fond transparent OK"],["Photos","JPG","Compression efficace"],["Visuels réseaux","PNG haute qualité","Pas de compression"],["Documents print","PDF 300 DPI","CMJN, marges 3mm"],["Animations / vidéos","MP4 H.264","Compatible tout"],["Icônes web","SVG","Léger et scalable"],["Mockups écran","PNG @2x ou @3x","Retina ready"]]}},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le format choisi correspond à l'usage final (pas un JPG pour un logo, pas un SVG pour une photo)."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Logo en JPG → fond blanc forcé, INTERDIT, utiliser PNG ou SVG. Print en RGB → couleurs ternes, utiliser CMJN. Visuels Insta en 72 DPI → flous, exporter en HD."},
  {"type":"paragraph","text":"➡️ Étape suivante : checklist qualité avant livraison."},

  {"type":"heading2","text":"4. CHECKLIST QUALITÉ AVANT LIVRAISON"},
  {"type":"paragraph","text":"🎯 Objectif : 0 retour client sur des fautes de base. ⏱️ Temps : 20 min par livraison."},
  {"type":"paragraph","text":"📍 Point de départ : design fini, prêt à exporter."},
  {"type":"paragraph","text":"🖥️ OÙ : ton outil + relecture sur écran + impression test si print."},
  {"type":"numbered","items":[
    "Relis tous les textes 2 fois (orthographe, ponctuation, accents).",
    "Fais relire par UNE autre personne (collègue ou chef de projet).",
    "Zoom à 200% pour vérifier les alignements pixel-perfect.",
    "Vérifie les marges (8px multiples : 8, 16, 24, 32, 48).",
    "Vérifie le contraste texte/fond (plugin Contrast Figma > AA 4.5:1).",
    "Teste sur mobile (DevTools navigateur ou téléphone direct).",
    "Vérifie que le logo est présent et bien positionné.",
    "Vérifie les couleurs (HEX du Brand Kit, pas du random)."
  ]},
  {"type":"paragraph","text":"✏️ POINTS DE CONTRÔLE :"},
  {"type":"list","items":[
    "**Orthographe** → 0 faute (Antidote ou Bon Patron pour vérifier)",
    "**Accents marocains** → café / médecin / pharmacie (jamais sans accent)",
    "**Numéro téléphone** → format +212 6XX XX XX XX (avec espaces)",
    "**Email** → minuscules uniquement, vérifier qu'il fonctionne",
    "**Lien URL** → testé dans le navigateur",
    "**Logo client** → version actuelle (pas une vieille version)",
    "**Photos** → HD (min 1920px de large), libres de droits",
    "**Couleurs** → issues du Brand Kit, pas de couleur random"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Checklist 8 points cochée intégralement avant export."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Faute d'orthographe découverte par le client → honte + retravail. Photo floue en print → coût supplémentaire de réimpression. Logo ancienne version → confusion identité."},
  {"type":"paragraph","text":"➡️ Étape suivante : livraison officielle."},

  {"type":"heading2","text":"5. PROCÉDURE DE LIVRAISON OFFICIELLE"},
  {"type":"paragraph","text":"🎯 Objectif : passer du design au livrable client de façon traçable. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : checklist qualité OK."},
  {"type":"paragraph","text":"🖥️ OÙ : Drive + GestiQ + WhatsApp."},
  {"type":"numbered","items":[
    "Crée un sous-dossier dans 05_Livraison/ : nom = type de livrable + date (ex : Logo-Final-2026-06-15).",
    "Range tous les fichiers finaux (avec README.txt explicatif).",
    "Mets ce sous-dossier en read-only (clic droit Drive → Restrict editing).",
    "Sur GestiQ → tâche → statut LIVRÉ + commentaire avec lien Drive.",
    "WhatsApp client avec le template ci-dessous.",
    "Demande accusé de réception écrit (« Bien reçu, merci »)."
  ]},
  {"type":"paragraph","text":"✏️ MESSAGE WHATSAPP LIVRAISON :"},
  {"type":"template","text":"Bonjour [Prénom],\\n\\nLes [livrables] sont prêts. Vous les trouverez ici : [lien Drive].\\n\\n📂 Le dossier contient :\\n- [Liste des fichiers]\\n- Un README.txt qui explique chaque fichier\\n\\n📌 Important :\\n- Utilisez le SVG pour le web\\n- Utilisez le PDF pour l'impression\\n- Le PNG si vous avez besoin de transparence\\n\\nMerci de me confirmer bonne réception.\\n\\nÉquipe Next Gital - nextgital.com"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Dossier 05_Livraison rempli + READ ONLY + GestiQ à jour + accusé client reçu."},

  {"type":"heading2","text":"6. ARCHIVAGE POST-PROJET"},
  {"type":"paragraph","text":"🎯 Objectif : garder une trace propre pour réutilisation future. ⏱️ Temps : 30 min en fin de projet."},
  {"type":"paragraph","text":"📍 Point de départ : projet clôturé par le client."},
  {"type":"paragraph","text":"🖥️ OÙ : Drive."},
  {"type":"numbered","items":[
    "Déplace les brouillons inutiles dans 99_Archive/.",
    "Vérifie que 05_Livraison contient bien les versions finales.",
    "Ajoute un fichier RECAP.md à la racine du dossier client avec : dates clés, livrables, contacts.",
    "Sur GestiQ → projet → statut Archivé.",
    "Si le client est important, garde le dossier dans « Clients-Actifs ». Sinon, déplace dans « Clients-Archivés-2026 »."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Projet rangé, RECAP.md à jour, statut GestiQ Archivé."},

  {"type":"divider"},

  {"type":"heading2","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Nommage [client]-[type]-[detail]-[version] respecté",
    "Arborescence Drive en 7 sous-dossiers fixes",
    "Format d'export adapté à l'usage (SVG/PNG/JPG/PDF)",
    "Relecture orthographe par 2 personnes",
    "Marges multiples de 8px",
    "Contraste AA validé",
    "Logo client version actuelle",
    "Dossier 05_Livraison en read-only",
    "GestiQ statut LIVRÉ",
    "Accusé de réception client reçu par écrit",
    "Archivage post-projet (99_Archive + RECAP.md)"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Bloqué plus de 30 min ? WhatsApp Next Gital +212 620 002 066 / info@nextgital.com."}
]$sop$::jsonb,
    read_min = 12,
    updated_at = now()
WHERE slug IN ('ng-design-standards-qualite','ng-ds-standards-nextgital');


-- ────────────────────────────────────────────────────────────────────
-- 7) RÈGLES OUTILS DESIGNER  →  ng-design-regles-outils
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"Pour qui ?","text":"Tout nouveau designer rejoignant Next Gital. À lire le 1er jour, à appliquer chaque jour."},
  {"type":"callout","variant":"tip","title":"Pourquoi ces règles ?","text":"Un outil mal utilisé = des heures perdues. Une mauvaise organisation = des fichiers perdus. Suivre ces règles = zéro friction."},
  {"type":"callout","variant":"warning","title":"Comptes officiels","text":"design@nextgital.com pour Canva Pro, Figma, Drive. Mot de passe disponible auprès du chef de projet."},

  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. CANVA PRO (COMPTE MUTUALISÉ design@nextgital.com)"},
  {"type":"paragraph","text":"🎯 Objectif : utiliser Canva sans casser le travail des collègues. ⏱️ Temps : 15 min de setup."},
  {"type":"paragraph","text":"📍 Point de départ : tu rejoins Next Gital, on te donne accès."},
  {"type":"paragraph","text":"🖥️ OÙ : canva.com."},
  {"type":"numbered","items":[
    "Connecte-toi sur canva.com avec design@nextgital.com (mot de passe via chef de projet).",
    "Vérifie que tu vois bien l'icône Pro (couronne) à côté de ton avatar.",
    "Va dans Brand Hub → tu dois voir tous les Brand Kits clients.",
    "Va dans Projets → tu dois voir les dossiers par client.",
    "Ne crée JAMAIS un design dans tes Drafts perso → toujours dans le bon dossier client.",
    "Ne supprime JAMAIS un fichier qui n'est pas le tien."
  ]},
  {"type":"paragraph","text":"✏️ RÈGLES STRICTES CANVA :"},
  {"type":"list","items":[
    "**Compte unique** → toujours design@nextgital.com, jamais ton compte perso",
    "**Dossier par client** → Projets → [Nom-Client] → ton design",
    "**Nommage** → [client]-[type]-[version] (cf. SOP standards qualité)",
    "**Suppression** → INTERDIT sans validation chef de projet",
    "**Partage externe** → toujours en mode View, jamais Edit",
    "**Brand Kit** → utiliser celui du client, jamais créer des couleurs random"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu peux te connecter, voir les Brand Kits et les dossiers projets de toute l'équipe."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Connexion avec compte perso → tu ne vois pas les fichiers équipe. Design dans Drafts → invisible pour les collègues. Suppression accidentelle → demander à un autre designer de récupérer en 30 jours max."},
  {"type":"paragraph","text":"➡️ Étape suivante : Figma."},

  {"type":"heading2","text":"2. FIGMA (PROJETS SÉPARÉS PAR CLIENT)"},
  {"type":"paragraph","text":"🎯 Objectif : organiser Figma pour que chaque client ait son espace. ⏱️ Temps : 10 min de setup."},
  {"type":"paragraph","text":"📍 Point de départ : accès Figma envoyé par invitation email."},
  {"type":"paragraph","text":"🖥️ OÙ : figma.com."},
  {"type":"numbered","items":[
    "Accepte l'invitation Figma reçue sur design@nextgital.com.",
    "Sidebar gauche → équipe « Next Gital ».",
    "Tu dois voir 2 projets : « Clients 2026 » et « Templates Next Gital ».",
    "Pour chaque nouveau client → créer un fichier (PAS un projet entier) dans « Clients 2026 ».",
    "Nommage du fichier : [Client]-[Type]-[Version] (ex : Dr-Karim-Site-v1).",
    "Ne crée JAMAIS un fichier dans tes Drafts perso."
  ]},
  {"type":"paragraph","text":"✏️ STRUCTURE FIGMA NEXT GITAL :"},
  {"type":"list","items":[
    "**Équipe** → Next Gital (1 seule)",
    "**Projet Clients 2026** → 1 fichier par projet client",
    "**Projet Templates Next Gital** → templates réutilisables (header, footer, composants)",
    "**Projet Archives** → projets clôturés des années précédentes"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu vois bien les 3 projets dans Next Gital et tu peux créer un fichier dedans."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Fichier créé dans Drafts → DÉPLACER tout de suite vers le bon projet. Fichier sans version → renommer en v1. Partage en Edit aux clients → DANGER, toujours View."},
  {"type":"paragraph","text":"➡️ Étape suivante : Google Drive."},

  {"type":"heading2","text":"3. GOOGLE DRIVE (ARBORESCENCE FIXE)"},
  {"type":"paragraph","text":"🎯 Objectif : tout le monde trouve les fichiers en 30 secondes. ⏱️ Temps : 5 min par nouveau projet."},
  {"type":"paragraph","text":"📍 Point de départ : compte design@nextgital.com avec accès Drive partagé."},
  {"type":"paragraph","text":"🖥️ OÙ : drive.google.com → Drive partagés → Next Gital."},
  {"type":"numbered","items":[
    "Connecte-toi sur drive.google.com avec design@nextgital.com.",
    "Va dans Drive partagés (sidebar gauche).",
    "Tu dois voir « Next Gital - Clients » et « Next Gital - Templates ».",
    "Pour un nouveau client : crée un dossier au nom du client.",
    "Crée immédiatement les 7 sous-dossiers standards (cf. SOP standards qualité).",
    "Vérifie les permissions : éditeur pour l'équipe Next Gital, viewer pour le client."
  ]},
  {"type":"paragraph","text":"✏️ ARBORESCENCE PAR CLIENT :"},
  {"type":"list","items":[
    "**01_Brief/**",
    "**02_Logo-Charte/**",
    "**03_Maquettes/**",
    "**04_Social-Media/**",
    "**05_Livraison/** (read-only après livraison)",
    "**06_Ads/**",
    "**99_Archive/**"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu peux créer un dossier client et les 7 sous-dossiers en moins de 5 min."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Fichiers dans Mon Drive perso → INVISIBLES pour l'équipe, toujours Drive partagé. Permissions Editeur au client → il peut tout casser, toujours Viewer. Pas de sous-dossier → bordel."},
  {"type":"paragraph","text":"➡️ Étape suivante : outils complémentaires."},

  {"type":"heading2","text":"4. OUTILS COMPLÉMENTAIRES (COOLORS, FONTS, REMOVE.BG, CAPCUT)"},
  {"type":"paragraph","text":"🎯 Objectif : connaître les outils annexes pour gagner du temps. ⏱️ Temps : 10 min de découverte."},
  {"type":"paragraph","text":"📍 Point de départ : Canva + Figma + Drive maîtrisés."},
  {"type":"paragraph","text":"🖥️ OÙ : sites listés ci-dessous."},
  {"type":"list","items":[
    "**coolors.co** → générer une palette de couleurs (appuyer Espace pour shuffle)",
    "**fonts.google.com** → bibliothèque gratuite de typos web (filtrer par catégorie)",
    "**remove.bg** → enlever le fond d'une photo en 1 clic (gratuit jusqu'à 5/jour)",
    "**capcut.com** → montage vidéo simple pour TikTok/Reels (alternative gratuite à Premiere)",
    "**unsplash.com** → photos HD libres de droits (intégré à Canva)",
    "**pexels.com** → photos + vidéos libres de droits",
    "**flaticon.com** → icônes vectorielles (créditer l'auteur en free)",
    "**cloudconvert.com** → convertir tout format (HEIC → JPG, etc.)"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu connais au moins 1 outil pour : palette, typo, détourage, montage vidéo."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Photo Google Images → DROITS D'AUTEUR, INTERDIT. Toujours Unsplash/Pexels. Icône sans crédit → respecter les licences. Police téléchargée pirate → utiliser Google Fonts."},
  {"type":"paragraph","text":"➡️ Étape suivante : versioning."},

  {"type":"heading2","text":"5. VERSIONING (v1, v2, v3)"},
  {"type":"paragraph","text":"🎯 Objectif : garder une trace de chaque révision. ⏱️ Temps : 2 min par version."},
  {"type":"paragraph","text":"📍 Point de départ : client demande une modification."},
  {"type":"paragraph","text":"🖥️ OÙ : Figma/Canva/Drive."},
  {"type":"numbered","items":[
    "À chaque revision client, duplique le fichier au lieu d'écraser.",
    "Incrémente la version : v1 → v2 → v3.",
    "Garde toutes les versions dans le dossier (pas dans Archive).",
    "Une fois validé par le client : copie la version finale dans 05_Livraison/.",
    "Archive les versions intermédiaires (v1, v2) dans 99_Archive/."
  ]},
  {"type":"paragraph","text":"✏️ EXEMPLE DE WORKFLOW :"},
  {"type":"list","items":[
    "**v1** → première proposition au client",
    "**v2** → après retour client (modifs mineures)",
    "**v3** → après retour client (couleur changée)",
    "**v3-FINAL** → version validée et livrée (à éviter, préférer juste v3)",
    "**Le pack livré reste en 05_Livraison/v3/ avec tous les exports**"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu peux retrouver chaque version du projet et expliquer ce qui a changé entre v1 et v3."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Écraser v1 sans backup → impossible de revenir en arrière. Versions « final-final-corrigé » → utiliser juste v1, v2, v3. Pas de versioning → on ne sait plus quelle est la dernière version."},
  {"type":"paragraph","text":"➡️ Étape suivante : raccourcis productivité."},

  {"type":"heading2","text":"6. RACCOURCIS CLAVIER À MÉMORISER"},
  {"type":"paragraph","text":"🎯 Objectif : doubler ta vitesse de production. ⏱️ Temps : 1 semaine d'entraînement."},
  {"type":"paragraph","text":"📍 Point de départ : tu utilises les outils tous les jours."},
  {"type":"paragraph","text":"🖥️ OÙ : Figma + Canva + macOS."},
  {"type":"paragraph","text":"✏️ RACCOURCIS FIGMA :"},
  {"type":"list","items":[
    "**F** → créer une Frame",
    "**R** → créer un Rectangle",
    "**T** → créer du Texte",
    "**O** → créer un cercle (Oval)",
    "**Cmd+D** → dupliquer",
    "**Cmd+G** → grouper",
    "**Cmd+Shift+G** → dégrouper",
    "**Cmd+/** → recherche commande",
    "**Cmd+Alt+C** → copier styles",
    "**Cmd+Alt+V** → coller styles"
  ]},
  {"type":"paragraph","text":"✏️ RACCOURCIS macOS UTILES :"},
  {"type":"list","items":[
    "**Cmd+Shift+4** → screenshot sélection",
    "**Cmd+Shift+5** → enregistrement vidéo écran",
    "**Cmd+Espace** → Spotlight (recherche)",
    "**Cmd+Tab** → switcher entre apps",
    "**Cmd+~** → switcher entre fenêtres d'une même app"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu utilises au moins 5 raccourcis Figma sans réfléchir."},

  {"type":"divider"},

  {"type":"heading2","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Canva Pro connecté avec design@nextgital.com",
    "Brand Kits clients visibles dans Canva",
    "Figma équipe Next Gital visible",
    "Drive partagé Next Gital - Clients accessible",
    "Arborescence 7 sous-dossiers connue",
    "Versioning v1/v2/v3 appliqué",
    "Sources photos libres de droits utilisées (Unsplash/Pexels)",
    "Au moins 5 raccourcis Figma maîtrisés"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Bloqué plus de 30 min ? WhatsApp Next Gital +212 620 002 066 / info@nextgital.com."}
]$sop$::jsonb,
    read_min = 10,
    updated_at = now()
WHERE slug = 'ng-design-regles-outils';


COMMIT;
