-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 038 : SOPs ultra-détaillés Chef de projet
--  Date : 2026-05-17
--
--  Catégorie : projets · Auteur : Next Gital · Idempotent
--  REMPLACE les blocks des 5 SOPs « Chef de projet » créés en migration 030
--  par une version ultra-détaillée (employé exécute dès le 1er jour
--  sans poser de question).
--
--  Slugs concernés :
--    1. ng-cdp-ouverture-projet
--    2. ng-cdp-suivi-hebdo
--    3. ng-cdp-communication-client
--    4. ng-cdp-livraison-finale
--    5. ng-cdp-kpis-rapport-mensuel
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  1. ng-cdp-ouverture-projet                                      ║
-- ╚══════════════════════════════════════════════════════════════════╝
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏰ Délai impératif","text":"Toutes les étapes ci-dessous doivent être terminées dans les 24h après la réception du virement d'acompte (notification du comptable ou email banque)."},
  {"type":"callout","variant":"info","title":"📡 Canal de travail","text":"GestiQ (gestiq.nextgital.tech) + Google Drive (compte info@nextgital.com) + WhatsApp Business Next Gital (+212 620 002 066)."},
  {"type":"callout","variant":"tip","title":"🎯 Objectif final","text":"À la fin de cette procédure : le client a reçu son lien Drive, sait quand est le 1er rendez-vous, et l'équipe (designer + dev) a vu apparaître ses cartes dans le Kanban GestiQ."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"Ne jamais démarrer le travail (design, dev) AVANT d'avoir reçu confirmation comptable du virement encaissé. Pas d'acompte = pas de projet ouvert."},

  {"type":"heading","text":"Étapes — dans l'ordre exact"},

  {"type":"heading2","text":"1. Vérifier la réception de l'acompte"},
  {"type":"paragraph","text":"🎯 Objectif : confirmer que l'argent est bien sur le compte Next Gital avant toute autre action. ⏱️ Temps : 3 min."},
  {"type":"paragraph","text":"📍 Point de départ : email/WhatsApp de notification d'encaissement du comptable OU email banque CIH/Attijari."},
  {"type":"paragraph","text":"🖥️ OÙ : Boîte mail Titan info@nextgital.com → dossier « Comptable » + GestiQ → CRM → fiche client."},
  {"type":"numbered","items":[
    "Ouvrir Gmail info@nextgital.com → chercher 'virement' ou 'acompte' + nom client",
    "Vérifier le montant reçu = montant acompte du devis signé (50% par défaut)",
    "Vérifier la référence du virement = nom du client OU numéro de devis",
    "Aller dans GestiQ → CRM → ouvrir la fiche client",
    "Si paiement OK → passer à l'étape 2. Si problème → appeler comptable +212 6XX XXX XXX"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu vois dans Gmail un email banque avec le montant exact attendu, et la référence contient le nom du client (ex : 'KARIM DENTAIRE OUJDA')."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Montant inférieur → le client a peut-être payé HT au lieu de TTC → appeler le commercial. Référence absente → demander au comptable de confirmer par WhatsApp. Aucun virement après 48h → relancer le client par WhatsApp avec le template 'Relance acompte' (voir SOP commercial)."},
  {"type":"paragraph","text":"➡️ Étape suivante : créer la fiche projet dans GestiQ."},

  {"type":"divider"},

  {"type":"heading2","text":"2. Créer la fiche projet dans GestiQ"},
  {"type":"paragraph","text":"🎯 Objectif : avoir le projet enregistré dans GestiQ avec tous les champs remplis pour que les autres modules (Kanban, Factures, Calendrier) se synchronisent. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : acompte confirmé (étape 1 validée)."},
  {"type":"paragraph","text":"🖥️ OÙ : gestiq.nextgital.tech → menu gauche → 'Projets' → bouton vert '+ Nouveau projet' (en haut à droite)."},
  {"type":"numbered","items":[
    "Cliquer sur '+ Nouveau projet'",
    "Remplir chaque champ (voir CONTENU EXACT ci-dessous)",
    "Sélectionner le client dans la liste déroulante (s'il n'existe pas : créer via CRM d'abord)",
    "Cliquer 'Enregistrer' en bas",
    "Vérifier que le projet apparaît dans la liste avec statut 'En cours'"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT des champs :"},
  {"type":"list","items":[
    "**Nom du projet** → format : [TYPE] — [NOM CLIENT] → exemple : Site Vitrine — Cabinet Dr. Karim → ne PAS écrire : Karim site",
    "**Client** → sélectionner dans la liste → exemple : Cabinet Dentaire Dr. Karim Oujda",
    "**Type** → choisir parmi : Site vitrine / E-commerce / Application / Refonte / SEO / Branding",
    "**Montant total TTC** → en MAD → exemple : 8000 (le devis signé fait foi)",
    "**Acompte reçu** → 50% par défaut → exemple : 4000",
    "**Date de début** → date du jour (aujourd'hui)",
    "**Date de livraison prévue** → +21 jours (3 semaines standard) → si autre : se référer au devis",
    "**Responsable** → toi (le chef de projet connecté)",
    "**Designer assigné** → choisir dans la liste équipe",
    "**Développeur assigné** → choisir dans la liste équipe",
    "**Statut** → 'En cours' (NE PAS laisser 'Brouillon')",
    "**Notes internes** → coller le résumé du brief commercial (3-5 lignes max)"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le projet apparaît dans la liste 'Projets > En cours' avec une pastille verte. La fiche client affiche maintenant '1 projet actif'."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Client introuvable dans la liste → aller dans CRM > Clients > Nouveau (créer la fiche avec téléphone + email + adresse Oujda). Date livraison < 14j → impossible à tenir → renégocier avec le client AVANT d'ouvrir. Le bouton Enregistrer reste grisé → un champ obligatoire est vide (regarder les * rouges)."},
  {"type":"paragraph","text":"➡️ Étape suivante : créer le dossier Google Drive partagé."},

  {"type":"divider"},

  {"type":"heading2","text":"3. Créer le dossier Google Drive avec les 5 sous-dossiers"},
  {"type":"paragraph","text":"🎯 Objectif : avoir un espace unique partagé avec le client pour tous les fichiers du projet. ⏱️ Temps : 7 min."},
  {"type":"paragraph","text":"📍 Point de départ : projet créé dans GestiQ (étape 2 validée)."},
  {"type":"paragraph","text":"🖥️ OÙ : drive.google.com (connecté avec info@nextgital.com) → dossier racine 'PROJETS CLIENTS 2026'."},
  {"type":"numbered","items":[
    "Ouvrir Drive → dossier 'PROJETS CLIENTS 2026' (créer si on est en début d'année)",
    "Clic droit dans le dossier → 'Nouveau dossier'",
    "Nommer le dossier selon la convention (voir CONTENU EXACT)",
    "Entrer dans le nouveau dossier → créer les 5 sous-dossiers ci-dessous",
    "Clic droit sur le dossier parent → 'Partager' → entrer email client",
    "Choisir le rôle 'Lecteur' (PAS Éditeur, sinon le client peut tout supprimer)",
    "Cocher 'Notifier' et écrire un mot d'accueil court",
    "Copier le lien partageable → le coller dans la fiche projet GestiQ (champ 'Lien Drive')"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Nom du dossier parent :"},
  {"type":"list","items":[
    "**Format** → [NOM CLIENT] — [TYPE PROJET] — [MOIS ANNÉE]",
    "**Exemple correct** → Cabinet Dr. Karim — Site Vitrine — Mai 2026",
    "**À ne PAS faire** → 'karim' ou 'projet1' ou 'nouveau'"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Les 5 sous-dossiers à créer DANS L'ORDRE :"},
  {"type":"numbered","items":[
    "01_Brief (devis signé, brief commercial, notes kickoff)",
    "02_Maquettes (wireframes, designs Figma exportés en PDF)",
    "03_Assets_Client (logo, photos, textes envoyés par le client)",
    "04_Developpement (captures staging, fichiers techniques)",
    "05_Livraison (dossier final, accès, vidéo tuto, guide PDF)"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Dans Drive, le dossier parent contient exactement 5 sous-dossiers numérotés 01 à 05. Le client a reçu un email Google '[Next Gital] a partagé un dossier avec vous'. Le lien est collé dans GestiQ."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Client n'a pas reçu l'email → vérifier que l'email n'est pas en spam, sinon partager via lien direct WhatsApp. Tu as donné 'Éditeur' par erreur → repartager en 'Lecteur', le client perd les droits d'écriture (heureusement). Dossier créé hors de 'PROJETS CLIENTS 2026' → déplacer (clic droit → Déplacer vers)."},
  {"type":"paragraph","text":"➡️ Étape suivante : envoyer le message kick-off WhatsApp."},

  {"type":"divider"},

  {"type":"heading2","text":"4. Envoyer le message kick-off au client via WhatsApp"},
  {"type":"paragraph","text":"🎯 Objectif : annoncer officiellement le démarrage et fournir au client tout ce dont il a besoin pour collaborer. ⏱️ Temps : 8 min."},
  {"type":"paragraph","text":"📍 Point de départ : dossier Drive créé et partagé (étape 3 validée)."},
  {"type":"paragraph","text":"🖥️ OÙ : WhatsApp Business Next Gital (compte +212 620 002 066) → chercher le contact client (numéro dans GestiQ → fiche client)."},
  {"type":"numbered","items":[
    "Ouvrir WhatsApp Business sur l'ordinateur (web.whatsapp.com)",
    "Chercher le contact client par nom OU numéro",
    "Copier le template de message ci-dessous",
    "Remplacer chaque [VARIABLE] par la vraie valeur (5 variables à remplacer)",
    "Relire 1 fois pour s'assurer qu'aucune variable n'est restée non remplacée",
    "Envoyer",
    "Attendre la double coche bleue (= message lu)",
    "Si pas lu après 2h → envoyer un mini message : 'Bonjour, message bien reçu ? 😊'"
  ]},
  {"type":"template","text":"Bonjour [PRÉNOM CLIENT] 🎉\n\nPaiement bien reçu — votre projet [NOM DU PROJET] démarre officiellement aujourd'hui !\n\nVoici votre dossier de démarrage :\n\n📁 Dossier projet partagé (Google Drive) :\n[LIEN GOOGLE DRIVE]\n\n📋 Éléments dont nous avons besoin de votre part (à déposer dans 03_Assets_Client) :\n— Logo en haute résolution (PNG transparent ou AI)\n— 5 à 10 photos professionnelles de votre activité\n— Textes de présentation (Word ou Google Doc)\n— Couleurs préférées (codes HEX si vous les avez)\n\n📅 Planning prévu :\n• J+5 : présentation des wireframes\n• J+10 : maquette finale à valider\n• J+18 : version test en ligne\n• J+21 : livraison finale\n\n📞 Règles de communication :\n• WhatsApp (+212 620 002 066) : questions rapides — réponse sous 1h en heures ouvrées\n• Email (info@nextgital.com) : validations officielles et fichiers lourds\n• Horaires : Lundi–Vendredi · 9h–17h\n\n📆 1er rendez-vous (présentation wireframes) — choisir un créneau ici :\nhttps://calendly.com/nextgital\n\nMerci pour votre confiance — l'équipe Next Gital est mobilisée pour vous 🙏\n\nNext Gital · 4ème étage Bureau N°7 Immeuble Kissi, Oujda\nnextgital.tech"},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Variables à remplacer :"},
  {"type":"list","items":[
    "**[PRÉNOM CLIENT]** → prénom uniquement → exemple : Karim → ne PAS écrire : Dr. Karim ou Monsieur",
    "**[NOM DU PROJET]** → nom exact GestiQ → exemple : Site Vitrine Cabinet Dentaire",
    "**[LIEN GOOGLE DRIVE]** → lien copié à l'étape 3 → vérifier qu'il commence par https://drive.google.com/",
    "**J+5, J+10...** → calculer les vraies dates à partir d'aujourd'hui (exemple : 17 mai → J+5 = 22 mai)",
    "**Le lien Calendly** → toujours https://calendly.com/nextgital (ne pas changer)"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Message envoyé avec double coche bleue. Aucun crochet [...] n'est resté dans le message. Le client a (idéalement) répondu un emoji ou un mot."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Crochet oublié dans le message → s'excuser et renvoyer avec un 'Pardon, version corrigée ci-dessous'. Lien Drive ne marche pas (ouverture refusée) → vérifier les droits de partage à l'étape 3. Client ne répond pas après 24h → l'appeler directement au téléphone."},
  {"type":"paragraph","text":"➡️ Étape suivante : créer les cartes Kanban et assigner l'équipe."},

  {"type":"divider"},

  {"type":"heading2","text":"5. Créer les cartes du Kanban projet et assigner l'équipe"},
  {"type":"paragraph","text":"🎯 Objectif : que le designer et le développeur voient apparaître automatiquement leurs tâches dans leur dashboard GestiQ. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : message kick-off envoyé (étape 4 validée)."},
  {"type":"paragraph","text":"🖥️ OÙ : gestiq.nextgital.tech → menu 'Projets' → ouvrir le projet créé → onglet 'Kanban'."},
  {"type":"numbered","items":[
    "Ouvrir le projet dans GestiQ → onglet 'Kanban'",
    "Cliquer '+ Ajouter une carte' dans la colonne 'À faire'",
    "Créer les 7 cartes une par une dans l'ordre ci-dessous",
    "Pour chaque carte : assigner la personne + mettre une deadline + ajouter une description courte",
    "Sauvegarder",
    "Vérifier dans le dashboard du designer/dev que les cartes apparaissent"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Les 7 cartes à créer (titre · assignation · deadline) :"},
  {"type":"numbered","items":[
    "Brief validé · Chef de projet · J+1",
    "Wireframes basse fidélité · Designer · J+4",
    "Maquette haute fidélité Figma · Designer · J+9",
    "Intégration front + back · Développeur · J+15",
    "QA complet (mobile + desktop) · Chef de projet · J+18",
    "Validation finale client · Chef de projet · J+20",
    "Mise en ligne + dossier livraison · Développeur + Chef de projet · J+21"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le Kanban affiche 7 cartes dans 'À faire', chacune avec un avatar coloré (= personne assignée) et une date deadline. Le designer reçoit une notif GestiQ ('Nouvelle carte assignée')."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Designer/dev pas dans la liste d'assignation → vérifier qu'ils sont bien membres de l'équipe (Paramètres > Équipe). Deadlines tombent un dimanche → décaler au lundi suivant. Carte créée dans la mauvaise colonne → drag-and-drop pour la replacer."},
  {"type":"paragraph","text":"➡️ Étape suivante : planifier la réunion wireframes via Calendly."},

  {"type":"divider"},

  {"type":"heading2","text":"6. Vérifier la réservation Calendly (réunion J+5)"},
  {"type":"paragraph","text":"🎯 Objectif : s'assurer que le client a réservé son créneau pour la présentation wireframes. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : 2h après l'envoi du message kick-off."},
  {"type":"paragraph","text":"🖥️ OÙ : calendly.com/event_types (connecté avec info@nextgital.com) → 'Réservations à venir'."},
  {"type":"numbered","items":[
    "Aller sur calendly.com → se connecter avec info@nextgital.com",
    "Cliquer 'Réservations à venir'",
    "Chercher le nom du client dans la liste",
    "Si trouvé → ajouter l'événement dans GestiQ → Calendrier (titre : 'Wireframes [CLIENT]')",
    "Si non trouvé après 4h → renvoyer un mini-message WhatsApp avec le lien Calendly seul",
    "Si non trouvé après 24h → l'appeler et fixer un créneau manuellement"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"L'événement Calendly apparaît dans le calendrier Next Gital avec le bon client et la bonne date. Le client a reçu un email de confirmation Calendly."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Le client a choisi un créneau en dehors des heures ouvrées → modifier la disponibilité Calendly. Aucun créneau libre proposé → ouvrir plus de créneaux dans Calendly > Availability."},
  {"type":"paragraph","text":"➡️ Étape suivante : programmer l'alerte J+7 pour les assets client."},

  {"type":"divider"},

  {"type":"heading2","text":"7. Programmer l'alerte automatique J+7 pour les assets client"},
  {"type":"paragraph","text":"🎯 Objectif : que GestiQ te rappelle automatiquement de relancer le client s'il n'a pas envoyé logo/photos/textes dans les 5 jours. ⏱️ Temps : 3 min."},
  {"type":"paragraph","text":"📍 Point de départ : Kanban créé, Calendly vérifié."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → projet → onglet 'Alertes & Rappels' → bouton '+ Nouvelle alerte'."},
  {"type":"numbered","items":[
    "Ouvrir le projet → onglet 'Alertes & Rappels'",
    "Cliquer '+ Nouvelle alerte'",
    "Titre : 'Relance assets client si non reçus'",
    "Date de déclenchement : aujourd'hui + 5 jours",
    "Type : Notification + Email",
    "Assigné à : moi (chef de projet)",
    "Action si déclenchée : envoyer le template 'Relance assets J+5' (voir ci-dessous)",
    "Sauvegarder",
    "Créer une 2ème alerte : 'Escalade fondateur — assets toujours absents' à J+7 — destinataire : fondateur"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Dans l'onglet 'Alertes & Rappels' du projet, 2 alertes apparaissent (J+5 chef de projet, J+7 fondateur) avec statut 'Programmée'."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Les alertes n'arrivent pas le jour J → vérifier dans Paramètres > Notifications que les emails sont activés. Date mal saisie → modifier l'alerte (icône crayon)."},
  {"type":"paragraph","text":"➡️ Toutes les étapes sont terminées. Passer à la checklist finale."},

  {"type":"divider"},

  {"type":"heading","text":"Templates de messages"},

  {"type":"heading2","text":"Template 1 — Relance assets client (J+5 si rien reçu)"},
  {"type":"template","text":"Bonjour [PRÉNOM] 👋\n\nPetit point sur votre projet [NOM PROJET] :\n\nPour respecter la date de livraison du [DATE LIVRAISON], nous avons besoin de recevoir les éléments suivants avant le [DATE J+7] :\n\n☐ Logo en haute résolution (PNG transparent)\n☐ 5 à 10 photos professionnelles\n☐ Textes / contenu à intégrer\n☐ Couleurs de votre marque (codes HEX si vous les avez)\n\nÀ déposer ici : [LIEN DOSSIER 03_Assets_Client]\n\nSans ces éléments, la date de livraison sera reportée d'autant.\n\nMerci beaucoup de votre réactivité 🙏\nNext Gital"},

  {"type":"heading2","text":"Template 2 — Escalade fondateur (J+7 si assets toujours absents)"},
  {"type":"template","text":"⚠️ Escalade — Assets client manquants\n\nProjet : [NOM PROJET]\nClient : [NOM CLIENT] · WhatsApp : [NUMÉRO]\nDate de relance précédente : [DATE J+5]\nÉtat : aucun fichier reçu dans le dossier Drive 03_Assets_Client\n\nImpact : la livraison du [DATE LIVRAISON INITIALE] est compromise.\n\nProposition : décaler la livraison de [X] jours et notifier le client par appel téléphonique du fondateur.\n\n[Votre prénom] — Chef de projet"},

  {"type":"divider"},

  {"type":"heading","text":"Checklist de validation finale"},
  {"type":"checklist","items":[
    "Acompte vérifié sur le compte bancaire Next Gital",
    "Fiche projet créée dans GestiQ avec tous les champs remplis (statut : En cours)",
    "Dossier Drive créé avec exactement 5 sous-dossiers numérotés",
    "Dossier Drive partagé avec le client (droits LECTEUR uniquement)",
    "Lien Drive collé dans la fiche projet GestiQ",
    "Message kick-off WhatsApp envoyé et lu (double coche bleue)",
    "7 cartes Kanban créées et assignées avec deadlines",
    "Designer et développeur ont reçu leurs notifications GestiQ",
    "Réunion Calendly J+5 réservée par le client (ou relance envoyée)",
    "Alerte J+5 'Relance assets' programmée dans GestiQ",
    "Alerte J+7 'Escalade fondateur' programmée dans GestiQ"
  ]},

  {"type":"divider"},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si tu es bloqué plus de 30 min sur une étape → WhatsApp fondateur +212 620 002 066 avec le message exact : 'BLOCAGE OUVERTURE PROJET [NOM CLIENT] — étape [N°] — problème : [description en 1 ligne] — j'ai déjà essayé : [action]'. NE PAS attendre pour escalader, un retard d'ouverture = retard de livraison."}
]$sop$::jsonb,
    read_min = 12,
    updated_at = now()
WHERE slug = 'ng-cdp-ouverture-projet';


-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  2. ng-cdp-suivi-hebdo                                           ║
-- ╚══════════════════════════════════════════════════════════════════╝
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"warning","title":"⏰ Délai impératif","text":"Chaque LUNDI MATIN à 9h00 pétantes — avant de répondre à n'importe quel message client ou de toucher à n'importe quel projet. Durée totale : 45 min maximum."},
  {"type":"callout","variant":"info","title":"📡 Canal de travail","text":"GestiQ (gestiq.nextgital.tech) + WhatsApp Business + Email Titan."},
  {"type":"callout","variant":"tip","title":"🎯 Objectif final","text":"À 9h45 : tous les projets ont leur statut à jour, tous les clients actifs ont reçu leur rapport hebdo, les 3 priorités de la semaine sont assignées avec deadline."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"Aucun lundi sans cette revue. Si tu es en déplacement ou malade : prévenir la veille (dimanche) et déléguer au fondateur. Sauter cette revue = perdre des clients."},

  {"type":"heading","text":"Étapes — dans l'ordre exact"},

  {"type":"heading2","text":"1. Consulter le Dashboard GestiQ et traiter les alertes critiques"},
  {"type":"paragraph","text":"🎯 Objectif : repérer en 5 min ce qui brûle (projets en retard, factures impayées, alertes). ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : ordinateur ouvert, café à côté, téléphone en mode 'Ne pas déranger' jusqu'à 9h45."},
  {"type":"paragraph","text":"🖥️ OÙ : gestiq.nextgital.tech → menu 'Dashboard' (page d'accueil après connexion)."},
  {"type":"numbered","items":[
    "Se connecter à GestiQ",
    "Regarder dans cet ORDRE STRICT les 4 widgets en haut : (1) Projets en retard (rouge) — (2) Factures impayées (orange) — (3) Alertes actives (jaune) — (4) Tâches échues (gris)",
    "Pour chaque alerte rouge : ouvrir la fiche concernée, lire, décider d'une action immédiate",
    "Si action immédiate impossible → noter dans la liste 'À traiter aujourd'hui' (post-it physique ou onglet)",
    "Marquer les alertes traitées comme 'Vue' (clic sur la cloche)"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Que faire selon l'alerte :"},
  {"type":"list","items":[
    "**Projet en retard rouge** → ouvrir le projet → identifier la cause (client / équipe / technique) → décider : relancer / réassigner / informer le client",
    "**Facture impayée > 7 jours** → relance email avec template 'Relance facture J+7' (SOP commercial)",
    "**Facture impayée > 14 jours** → ESCALADE FONDATEUR immédiate par WhatsApp",
    "**Alerte assets manquants** → relance WhatsApp avec template 'Relance assets'",
    "**Tâche échue d'un membre** → message WhatsApp privé au membre : 'Hello, tâche [X] dépassée — tu en es où ?'"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Toutes les alertes rouges/oranges ont été soit traitées (action faite), soit ajoutées à la liste 'À traiter aujourd'hui'. Le dashboard ne contient plus que des alertes 'Vues'."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Trop d'alertes (>10 rouges) → c'est qu'on a sauté un lundi → faire la revue projet par projet plus longuement (1h au lieu de 45 min). Dashboard ne charge pas → vider le cache navigateur (Ctrl+Shift+R)."},
  {"type":"paragraph","text":"➡️ Étape suivante : parcourir le Kanban projet par projet."},

  {"type":"divider"},

  {"type":"heading2","text":"2. Parcourir le Kanban — un projet après l'autre"},
  {"type":"paragraph","text":"🎯 Objectif : avoir une vision claire de l'état réel de chaque projet, pas seulement de ce que le Kanban affiche. ⏱️ Temps : 15 min (≈ 2 min par projet)."},
  {"type":"paragraph","text":"📍 Point de départ : alertes critiques traitées (étape 1 OK)."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → menu 'Projets' → filtrer par statut 'En cours' → trier par 'Date livraison croissante'."},
  {"type":"numbered","items":[
    "Filtrer : Projets > Statut 'En cours' > Trier par date de livraison la plus proche d'abord",
    "Pour chaque projet (du plus urgent au moins urgent), ouvrir l'onglet Kanban",
    "Se poser les 4 questions ci-dessous (voir CONTENU EXACT)",
    "Mettre à jour la position des cartes (drag-and-drop si avancement)",
    "Ajouter un commentaire dans la carte si blocage",
    "Mettre à jour la date de livraison si décalage (en informant le client à l'étape 3)"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Les 4 questions à se poser pour CHAQUE projet :"},
  {"type":"numbered","items":[
    "Où en est-on exactement par rapport au planning initial ? (en avance / pile / en retard de X jours)",
    "Y a-t-il un blocage technique ou humain ? (si oui : noter la cause)",
    "Le client a-t-il répondu à la dernière demande ? (si non depuis 3j+ : prévoir relance)",
    "La date de livraison initiale est-elle toujours réaliste ? (si non : décider nouvelle date AVANT le rapport hebdo)"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tous les projets 'En cours' ont leurs cartes Kanban à la bonne position. Tu as une liste mentale (ou écrite) des décisions prises par projet. Aucun projet n'a été 'oublié'."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Projet abandonné (aucune activité > 7j) → contacter immédiatement le membre assigné. Trop de projets en parallèle (>8) → escalader au fondateur pour répartir. Carte sans assignation → assigner immédiatement avant de continuer."},
  {"type":"paragraph","text":"➡️ Étape suivante : envoyer le rapport hebdo à chaque client actif."},

  {"type":"divider"},

  {"type":"heading2","text":"3. Envoyer le rapport hebdo à chaque client actif"},
  {"type":"paragraph","text":"🎯 Objectif : aucun client actif ne doit terminer la journée du lundi sans avoir reçu son point hebdo. ⏱️ Temps : 15 min (≈ 1 min 30 par client)."},
  {"type":"paragraph","text":"📍 Point de départ : revue Kanban terminée (étape 2 OK)."},
  {"type":"paragraph","text":"🖥️ OÙ : WhatsApp Business Next Gital + Email Titan (selon préférence du client notée dans GestiQ → fiche client → champ 'Canal préféré')."},
  {"type":"numbered","items":[
    "Lister tous les clients ayant un projet 'En cours'",
    "Pour chaque client, copier le template 'Rapport hebdo' ci-dessous",
    "Remplir les 4 zones : Fait / En cours / Prochaine étape / Action requise",
    "Si AUCUNE action client requise → supprimer cette section du template (ne pas laisser 'RAS')",
    "Envoyer via WhatsApp (par défaut) OU Email si client préfère",
    "Cocher dans GestiQ → fiche projet → 'Rapport hebdo envoyé' (date du jour)"
  ]},
  {"type":"template","text":"Bonjour [PRÉNOM] 👋\n\nVoici le point de la semaine sur votre projet [NOM PROJET] :\n\n✅ Ce qui est fait :\n— [RÉALISATION CONCRÈTE 1]\n— [RÉALISATION CONCRÈTE 2]\n\n🔄 En cours cette semaine :\n— [TÂCHE EN COURS PRÉCISE]\n\n📅 Prochaine étape :\n— [PROCHAINE ÉTAPE + DATE EXACTE]\n\n⚠️ Action requise de votre part :\n— [SI RIEN À FAIRE : supprimer cette section entière]\n\nDes questions ? Je suis dispo aujourd'hui de 9h à 17h 😊\n\nBonne semaine !\nNext Gital"},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Exemples de bonnes phrases pour chaque zone :"},
  {"type":"list","items":[
    "**Ce qui est fait** → 'Wireframes terminés et validés en interne' (PAS 'on a bossé sur le projet')",
    "**En cours** → 'Maquette haute fidélité Figma — page d'accueil + page contact' (PAS 'design en cours')",
    "**Prochaine étape** → 'Présentation de la maquette le vendredi 21 mai 14h' (PAS 'on vous montre bientôt')",
    "**Action requise** → 'Envoyer les 3 photos manquantes avant mercredi' (PAS 'attendre vos retours')"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tous les clients 'En cours' ont reçu leur message (double coche bleue WhatsApp ou email envoyé). Dans GestiQ, la case 'Rapport hebdo' est cochée pour chaque projet."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Tu n'as 'rien à dire' sur un projet (pas d'avancée) → c'est un signal d'alarme : le projet stagne → identifier la cause AVANT d'écrire au client. Client demande un appel urgent en retour → noter dans 'À traiter aujourd'hui' et l'appeler après la fin de la revue."},
  {"type":"paragraph","text":"➡️ Étape suivante : vérifier les devis en attente."},

  {"type":"divider"},

  {"type":"heading2","text":"4. Vérifier les devis en attente et relancer"},
  {"type":"paragraph","text":"🎯 Objectif : transformer en cash les devis envoyés sans laisser pourrir le pipeline. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : rapports hebdo envoyés (étape 3 OK)."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → menu 'CRM' → onglet 'Devis' → filtrer 'Statut : Envoyé'."},
  {"type":"numbered","items":[
    "Filtrer les devis avec statut 'Envoyé'",
    "Trier par date d'envoi (le plus ancien d'abord)",
    "Appliquer la règle ci-dessous selon l'ancienneté",
    "Documenter chaque action dans la fiche devis (commentaire)",
    "Informer le commercial des relances faites"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Règle d'or des relances :"},
  {"type":"list","items":[
    "**Devis < 3 jours** → ne rien faire (laisser respirer le client)",
    "**Devis 3 à 7 jours sans réponse** → 1 SEULE relance WhatsApp douce (voir template plus bas)",
    "**Devis > 7 jours sans réponse** → marquer 'Perdu' dans GestiQ + archiver + ne plus relancer"
  ]},
  {"type":"callout","variant":"warning","title":"⚠️ JAMAIS","text":"Relancer 2 fois le même devis. Ça donne une image de désespoir et nuit à la marque Next Gital. 1 relance = max."},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tous les devis 'Envoyé' ont soit été relancés une seule fois, soit archivés en 'Perdu'. Le pipeline CRM est propre."},
  {"type":"paragraph","text":"➡️ Étape suivante : planifier les 3 priorités de la semaine."},

  {"type":"divider"},

  {"type":"heading2","text":"5. Planifier les 3 actions prioritaires de la semaine"},
  {"type":"paragraph","text":"🎯 Objectif : la semaine ne sera réussie que si ces 3 actions précises sont faites. Le reste est secondaire. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : devis vérifiés (étape 4 OK)."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → menu 'Tâches' → onglet 'Cette semaine' → bouton '+ Nouvelle tâche'."},
  {"type":"numbered","items":[
    "Prendre une feuille (ou un Google Doc) et écrire en haut : 'Semaine du [LUNDI] — 3 priorités'",
    "Identifier les 3 actions qui auront le PLUS d'impact (gros projet, gros risque, gros client)",
    "Pour chaque priorité : créer une tâche GestiQ avec : titre clair + assignation + deadline précise (jour + heure)",
    "Annoncer les 3 priorités à l'équipe (groupe WhatsApp 'Next Gital Team') le lundi à 10h",
    "Ré-évaluer le vendredi : 3/3 fait = excellent · 2/3 = OK · 1 ou 0 = revoir la semaine prochaine"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Une bonne priorité ressemble à ça :"},
  {"type":"list","items":[
    "**Bon** → 'Livrer le site Dr. Karim le jeudi 20 mai avant 17h'",
    "**Mauvais** → 'Avancer le projet Karim'",
    "**Bon** → 'Obtenir validation maquette Cabinet Fedix avant mercredi 18h'",
    "**Mauvais** → 'Faire valider quelque chose'",
    "**Bon** → 'Relancer 5 prospects chauds du CRM avant vendredi'",
    "**Mauvais** → 'Faire de la commerciale'"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Dans GestiQ → Tâches > Cette semaine, exactement 3 tâches sont créées avec étiquette 'Priorité 1'. L'équipe a vu le message WhatsApp avec les 3 priorités."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Plus de 3 priorités → ce ne sont plus des priorités, c'est une to-do classique → réduire à 3. Priorité dépend d'une réponse client → ce n'est pas une priorité fiable → choisir une priorité 100% sous ton contrôle."},
  {"type":"paragraph","text":"➡️ La revue hebdo est terminée. Tu peux maintenant ouvrir tes autres canaux et répondre aux clients."},

  {"type":"divider"},

  {"type":"heading","text":"Templates de messages"},

  {"type":"heading2","text":"Template — Relance devis (J+3 à J+7)"},
  {"type":"template","text":"Bonjour [PRÉNOM] 😊\n\nJ'espère que vous allez bien !\n\nJe me permets de revenir vers vous concernant le devis envoyé le [DATE] pour [TYPE PROJET].\n\nAvez-vous eu l'occasion d'en prendre connaissance ? Je reste disponible si vous avez des questions ou si certains points méritent un ajustement.\n\nÀ votre écoute,\nNext Gital · +212 620 002 066"},

  {"type":"heading2","text":"Template — Message WhatsApp équipe (lundi 10h)"},
  {"type":"template","text":"Hello l'équipe 🚀\n\nLes 3 priorités de la semaine du [LUNDI DATE] :\n\n1. [PRIORITÉ 1 + RESPONSABLE + DEADLINE]\n2. [PRIORITÉ 2 + RESPONSABLE + DEADLINE]\n3. [PRIORITÉ 3 + RESPONSABLE + DEADLINE]\n\nOn fait le point vendredi 17h.\n\nBonne semaine à tous 💪"},

  {"type":"divider"},

  {"type":"heading","text":"Checklist de fin de revue (avant 9h45)"},
  {"type":"checklist","items":[
    "Dashboard GestiQ consulté — toutes les alertes rouges/oranges traitées",
    "Kanban parcouru — chaque projet 'En cours' a son statut à jour",
    "Rapport hebdo envoyé à 100% des clients actifs",
    "Devis en attente vérifiés — relances effectuées si J+3 à J+7",
    "Devis > 7 jours marqués 'Perdu' et archivés",
    "3 priorités semaine créées dans GestiQ avec étiquette 'Priorité 1'",
    "Message WhatsApp équipe envoyé avec les 3 priorités",
    "Projet sans activité depuis 7+ jours → investigation lancée",
    "Facture impayée 14+ jours → fondateur alerté par WhatsApp"
  ]},

  {"type":"divider"},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si la revue dépasse 1h sans être finie → STOPPER, envoyer un WhatsApp au fondateur (+212 620 002 066) avec : 'REVUE HEBDO BLOQUÉE — [N°] alertes critiques — [N°] projets en retard — j'ai besoin d'aide pour prioriser'. Reprendre la revue après son retour."}
]$sop$::jsonb,
    read_min = 10,
    updated_at = now()
WHERE slug = 'ng-cdp-suivi-hebdo';


-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  3. ng-cdp-communication-client                                  ║
-- ╚══════════════════════════════════════════════════════════════════╝
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏰ Quand utiliser ce SOP","text":"En PERMANENCE — c'est la bible de communication. À relire intégralement le 1er jour, puis 1 fois par mois en révision."},
  {"type":"callout","variant":"info","title":"📡 Canal de travail","text":"WhatsApp Business Next Gital (+212 620 002 066) pour les échanges rapides + Email Titan (info@nextgital.com) pour les validations officielles."},
  {"type":"callout","variant":"tip","title":"🎯 Objectif final","text":"Zéro client sans réponse en 1h ouvrée. Zéro mauvaise surprise (toujours informer avant qu'on demande). Relation de confiance qui dure 5+ ans."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"Une promesse faite à un client doit être tenue à 100%. Si tu n'es pas sûr de pouvoir tenir → NE PROMETS PAS, dis 'Je vérifie et je reviens vers vous'."},

  {"type":"heading","text":"Les 5 règles d'or de la communication Next Gital"},

  {"type":"heading2","text":"1. Répondre en moins de 1h en heures ouvrées (Lun-Ven 9h-17h)"},
  {"type":"paragraph","text":"🎯 Objectif : le client doit toujours se sentir écouté, jamais ignoré. ⏱️ Temps de réponse : < 1h."},
  {"type":"paragraph","text":"📍 Point de départ : notification WhatsApp ou email d'un client."},
  {"type":"paragraph","text":"🖥️ OÙ : WhatsApp Business ouvert en permanence sur ton ordi + email Titan en onglet."},
  {"type":"numbered","items":[
    "Voir le message → ouvrir IMMÉDIATEMENT (pas de 'je verrai plus tard')",
    "Si tu as la réponse → répondre directement",
    "Si tu n'as PAS la réponse → accuser réception + donner un délai PRÉCIS (heure exacte)",
    "Tenir ce délai à 100%",
    "Si jamais tu ne peux pas tenir le délai → re-prévenir le client avant l'échéance"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Phrases types d'accusé de réception :"},
  {"type":"list","items":[
    "**Si tu as la réponse dans la journée** → 'Bien noté [Prénom], je vous reviens avant 15h 😊'",
    "**Si réponse demain** → 'Bien reçu [Prénom], je creuse aujourd'hui et reviens demain matin avec une réponse complète.'",
    "**Si tu dois consulter l'équipe** → 'Bonne question [Prénom] — je valide avec l'équipe et reviens vers vous avant ce soir 18h.'"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le client ne dit JAMAIS 'Je n'ai pas eu de nouvelles depuis...'. Ton historique WhatsApp ne contient aucun message client sans réponse depuis > 1h en heures ouvrées."},
  {"type":"callout","variant":"warning","title":"⚠️ Hors heures ouvrées","text":"Soir / weekend / jours fériés : ne pas répondre (sauf urgence vie ou mort du projet). Le client sait que tu reprendras le lundi matin. Activer le message d'absence WhatsApp Business avec horaires."},
  {"type":"callout","variant":"danger","title":"🚫 Ne JAMAIS","text":"Laisser un client en 'vu' (double coche bleue) sans répondre. Si tu lis, tu réponds."},

  {"type":"divider"},

  {"type":"heading2","text":"2. WhatsApp pour les questions · Email pour les validations officielles"},
  {"type":"paragraph","text":"🎯 Objectif : avoir une trace écrite légale de chaque décision importante. ⏱️ Toujours."},
  {"type":"paragraph","text":"📍 Point de départ : étape clé du projet à valider (maquette, textes, mise en ligne, ajout fonctionnalité)."},
  {"type":"paragraph","text":"🖥️ OÙ : Email Titan info@nextgital.com (toujours en copie de toi-même pour archive)."},
  {"type":"numbered","items":[
    "Identifier qu'on est à une étape de validation (maquette finale, mise en ligne, contenu)",
    "ENVOYER UN EMAIL (PAS un WhatsApp) avec l'objet exact (voir CONTENU EXACT)",
    "Demander une réponse écrite courte ('Je valide')",
    "Attendre la réponse email AVANT de passer à l'étape suivante",
    "Archiver l'email de validation dans le dossier Drive du projet > 02_Maquettes ou 05_Livraison"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Objets d'emails de validation :"},
  {"type":"list","items":[
    "**Validation maquette** → 'Validation maquette [NOM PROJET] — Réponse attendue avant [DATE]'",
    "**Validation textes** → 'Validation textes site [NOM CLIENT] — Réponse avant [DATE]'",
    "**Validation mise en ligne** → 'Validation finale avant mise en ligne — [NOM PROJET]'"
  ]},
  {"type":"callout","variant":"danger","title":"🚫 INTERDIT","text":"Valider une étape clé sur la base d'un message vocal WhatsApp ('ok vas-y'), d'un emoji 👍, ou d'un appel téléphonique. En cas de litige, SEUL l'email écrit fait foi devant la justice marocaine."},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Pour chaque étape clé du projet, tu peux retrouver dans la boîte mail Titan un email 'Validation X' avec une réponse écrite du client."},

  {"type":"divider"},

  {"type":"heading2","text":"3. Annoncer les mauvaises nouvelles IMMÉDIATEMENT (avant que le client demande)"},
  {"type":"paragraph","text":"🎯 Objectif : le client doit apprendre les problèmes par TOI, pas en découvrant que rien n'avance. ⏱️ Le jour même."},
  {"type":"paragraph","text":"📍 Point de départ : tu identifies un retard, un blocage technique, un problème équipe, un imprévu."},
  {"type":"paragraph","text":"🖥️ OÙ : Email + WhatsApp (les deux pour être sûr d'être lu)."},
  {"type":"numbered","items":[
    "Détecter le problème (retard, bug, équipe absente, etc.)",
    "Ne PAS attendre le lundi suivant — agir LE JOUR MÊME",
    "Réfléchir 10 min : quelle est la solution proposée + nouvelle date réaliste ?",
    "Utiliser le template 'Annonce mauvaise nouvelle' (voir templates plus bas)",
    "TOUJOURS proposer une solution + un geste commercial si grosse erreur",
    "Envoyer email + doubler par WhatsApp",
    "Appeler le client par téléphone si retard > 7 jours"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — La structure 'mauvaise nouvelle bien annoncée' :"},
  {"type":"list","items":[
    "**1. Empathie** → 'Je dois vous informer d'un ajustement'",
    "**2. Fait honnête** → 'En raison de [CAUSE RÉELLE, courte]'",
    "**3. Conséquence** → 'la livraison est reportée du [DATE A] au [DATE B]'",
    "**4. Bénéfice** → 'Ce délai supplémentaire nous permettra de [BÉNÉFICE CONCRET pour le client]'",
    "**5. Geste commercial** (si grosse erreur de notre part) → 'En compensation, nous offrons [GESTE]'",
    "**6. Excuses sincères + disponibilité** → 'Je m'en excuse sincèrement et reste joignable'"
  ]},
  {"type":"callout","variant":"warning","title":"⚠️ Erreur fatale","text":"Cacher un retard en espérant 'rattraper' = perte du client garantie. La transparence sauve la relation, le mensonge la détruit."},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le client te répond 'merci de m'avoir prévenu' ou 'pas de souci, on s'adapte'. Personne n'aime les mauvaises nouvelles, mais tout le monde respecte l'honnêteté."},

  {"type":"divider"},

  {"type":"heading2","text":"4. Escalader au fondateur si demande hors scope (jamais dire non directement)"},
  {"type":"paragraph","text":"🎯 Objectif : ne jamais perdre une opportunité d'upsell + ne jamais dire 'non' à un client. ⏱️ Réponse client dans l'heure, escalade fondateur dans les 30 min."},
  {"type":"paragraph","text":"📍 Point de départ : le client demande une fonctionnalité, une modification ou un service qui n'est pas dans le devis signé."},
  {"type":"paragraph","text":"🖥️ OÙ : WhatsApp Business (réponse client) + WhatsApp privé fondateur (escalade)."},
  {"type":"numbered","items":[
    "Lire la demande du client",
    "Vérifier le devis signé (Drive > 01_Brief) — est-ce inclus ou non ?",
    "Si HORS SCOPE → répondre au client avec la phrase diplomate (voir ci-dessous)",
    "Dans les 30 min, escalader au fondateur par WhatsApp privé avec : nom client + demande exacte + ton estimation budget",
    "Attendre la décision du fondateur (devis additionnel OU geste commercial OU refus argumenté)",
    "Préparer le devis additionnel dans GestiQ si feu vert",
    "Envoyer au client dans les 24h avec le template 'Devis additionnel'"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Phrase à dire au client :"},
  {"type":"quote","text":"« Très bonne idée [Prénom] ! Laissez-moi vérifier avec l'équipe technique la faisabilité et le délai, et je reviens vers vous avec une proposition complète dans les 24h. »"},
  {"type":"callout","variant":"danger","title":"🚫 NE JAMAIS dire","text":"'Ce n'est pas dans le devis' ou 'Non, on ne fait pas ça'. Cela ferme la porte. Toujours laisser ouvert et escalader."},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le client n'a pas eu de 'non' direct. Le fondateur a une décision à prendre. Un devis additionnel est en préparation OU une réponse argumentée part dans les 24h."},

  {"type":"divider"},

  {"type":"heading2","text":"5. Demander la validation par email AVANT chaque étape clé"},
  {"type":"paragraph","text":"🎯 Objectif : ne jamais investir 10h de dev sur une maquette non validée par écrit. ⏱️ Email envoyé dès la fin d'une étape, validation attendue avant l'étape suivante."},
  {"type":"paragraph","text":"📍 Point de départ : fin d'une phase (maquette terminée, textes intégrés, mise en ligne staging prête)."},
  {"type":"paragraph","text":"🖥️ OÙ : Email Titan info@nextgital.com → en copie : adresse perso pour archive."},
  {"type":"numbered","items":[
    "Identifier la fin d'une phase clé",
    "Envoyer un email avec objet 'Validation [PHASE] — [NOM PROJET]'",
    "Lister précisément ce qui est à valider (avec lien direct vers le fichier/site)",
    "Demander une réponse 'Je valide' ou liste de modifications",
    "Fixer une deadline de réponse (48h max)",
    "Si pas de réponse à J+1 → relance WhatsApp douce",
    "Si pas de réponse à J+2 → appel téléphonique",
    "Si pas de réponse à J+3 → email d'alerte avec 'En l'absence de réponse, le planning sera décalé d'autant'"
  ]},
  {"type":"callout","variant":"warning","title":"⚠️ Conséquence de l'oubli","text":"Si tu lances le dev sans validation écrite et que le client revient en disant 'ce n'est pas ce que j'avais demandé', tu n'as AUCUN recours. Le client a légalement raison."},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Chaque phase clé du projet a son email de validation archivé. Le client connaît son rôle (valider activement) et joue le jeu."},

  {"type":"divider"},

  {"type":"heading","text":"Templates de messages"},

  {"type":"heading2","text":"Template 1 — Présentation maquette au client"},
  {"type":"template","text":"Bonjour [PRÉNOM] 😊\n\nVotre maquette est prête !\n\n🎨 Lien Figma : [LIEN FIGMA]\n(vous pouvez ajouter vos commentaires directement sur la maquette en cliquant à droite)\n\nVous pouvez :\n• La consulter librement\n• Annoter vos retours sur Figma\n• Me contacter pour en discuter (WhatsApp ou appel)\n\nVos retours sont attendus avant le [DATE + 48H].\n\nUne fois validée par EMAIL, le développement commencera immédiatement 🚀\n\nBelle journée !\nNext Gital"},

  {"type":"heading2","text":"Template 2 — Annonce de retard (mauvaise nouvelle)"},
  {"type":"template","text":"Bonjour [PRÉNOM],\n\nJe dois vous informer d'un ajustement dans le planning de votre projet [NOM PROJET].\n\nEn raison de [CAUSE RÉELLE COURTE — ex : 'un retard de livraison des photos par notre prestataire'], la livraison prévue le [DATE INITIALE] est reportée au [NOUVELLE DATE].\n\nCe délai supplémentaire de [X jours] nous permettra de [BÉNÉFICE CONCRET — ex : 'finaliser la version mobile avec une meilleure optimisation des images'].\n\nJe m'en excuse sincèrement et reste à votre disposition pour toute question.\n\n[SI ERREUR DE NOTRE PART : En compensation, nous offrons [GESTE — ex : '1 page supplémentaire gratuite' ou '1 mois de maintenance offerte'].]\n\nCordialement,\n[VOTRE PRÉNOM] — Next Gital\n+212 620 002 066"},

  {"type":"heading2","text":"Template 3 — Demande de validation officielle par email"},
  {"type":"template","text":"Bonjour [PRÉNOM],\n\nSuite à notre échange, pourriez-vous confirmer par retour d'email votre validation de :\n\n[ÉLÉMENT À VALIDER — ex : la maquette finale Figma envoyée le 18 mai]\n\nUn simple 'Je valide' suffira pour cette confirmation.\n\nCette validation me permettra de lancer immédiatement [PROCHAINE ÉTAPE — ex : le développement front-end].\n\nMerci d'avance !\nNext Gital — info@nextgital.com"},

  {"type":"heading2","text":"Template 4 — Demande hors scope (réponse diplomate)"},
  {"type":"template","text":"Bonjour [PRÉNOM],\n\nMerci pour cette nouvelle idée — elle est très pertinente pour votre projet 👏\n\nCette fonctionnalité ([FONCTIONNALITÉ DEMANDÉE]) n'est pas incluse dans le devis initial du [DATE DEVIS], mais je peux tout à fait vous préparer une proposition complète pour l'ajouter.\n\nJe reviens vers vous dans les 24h avec un devis complémentaire détaillé (délai + coût).\n\nEn attendant, n'hésitez pas si vous avez d'autres questions 🙏\n\nNext Gital"},

  {"type":"heading2","text":"Template 5 — Message d'absence WhatsApp Business (à activer en permanence)"},
  {"type":"template","text":"Bonjour 👋\n\nMerci pour votre message ! L'équipe Next Gital est disponible :\n📅 Lundi à vendredi · 9h00 à 17h00\n\nNous reviendrons vers vous au plus tard le prochain jour ouvré à 9h.\n\nPour les urgences : info@nextgital.com\nSite : nextgital.tech\n\nÀ très vite,\nNext Gital · Oujda"},

  {"type":"divider"},

  {"type":"heading","text":"Checklist permanente (à relire 1 fois par mois)"},
  {"type":"checklist","items":[
    "Aucun message client sans réponse depuis > 1h en heures ouvrées",
    "Toutes les validations clés obtenues par EMAIL (jamais par vocal)",
    "Mauvaises nouvelles annoncées le jour même, avec solution proposée",
    "Demandes hors scope escaladées au fondateur en < 30 min",
    "Chaque étape clé validée par écrit AVANT de continuer",
    "Message d'absence WhatsApp Business actif en permanence",
    "Aucune promesse non tenue ce mois-ci",
    "Aucun client ne dit 'pas de nouvelles depuis...'"
  ]},

  {"type":"divider"},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si tu te retrouves face à un client mécontent, agressif ou qui menace (avis Google négatif, justice, etc.) → STOPPER toute communication écrite immédiatement, NE RIEN RÉPONDRE, et appeler le fondateur au +212 620 002 066 dans les 15 min : 'CLIENT EN COLÈRE [NOM] — voici le dernier message [copier-coller] — j'ai besoin de toi pour répondre'."}
]$sop$::jsonb,
    read_min = 12,
    updated_at = now()
WHERE slug = 'ng-cdp-communication-client';


-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  4. ng-cdp-livraison-finale                                      ║
-- ╚══════════════════════════════════════════════════════════════════╝
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏰ Quand utiliser ce SOP","text":"Le dernier jour officiel du projet (J+21 par défaut). À démarrer dès le matin 9h pour boucler dans la journée."},
  {"type":"callout","variant":"info","title":"📡 Canal de travail","text":"GestiQ + Google Drive + WhatsApp Business + Email Titan + hébergement (cPanel/FTP/Vercel selon projet)."},
  {"type":"callout","variant":"tip","title":"🎯 Objectif final","text":"Site en ligne + zéro bug + client a reçu son dossier de livraison complet + 2 jours plus tard, avis Google 5★ obtenu."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"AUCUNE mise en ligne sans QUE TOUTES les 12 cases de la checklist QA soient cochées. SANS EXCEPTION. JAMAIS. Mettre en ligne avec un bug = remboursement du client + avis 1★ + temps perdu × 5."},

  {"type":"heading","text":"Étapes — dans l'ordre exact"},

  {"type":"heading2","text":"1. QA complet sur le site staging (cocher les 12 points)"},
  {"type":"paragraph","text":"🎯 Objectif : détecter et corriger tous les bugs AVANT que le client les voie. ⏱️ Temps : 1h30 à 2h."},
  {"type":"paragraph","text":"📍 Point de départ : le développeur a annoncé 'site staging prêt' avec l'URL de prévisualisation."},
  {"type":"paragraph","text":"🖥️ OÙ : navigateurs (Chrome, Firefox, Safari) + smartphone iPhone + Android + outils PageSpeed/GTmetrix."},
  {"type":"numbered","items":[
    "Récupérer l'URL staging du dev (ex : https://staging.nextgital.tech/karim-dentiste)",
    "Ouvrir l'URL sur Chrome desktop → parcourir TOUTES les pages (accueil, services, contact, mentions légales)",
    "Pour chaque page : cliquer TOUS les boutons, TOUS les liens, TOUS les formulaires",
    "Refaire la même chose sur Firefox + Safari desktop",
    "Tester sur iPhone (Safari + Chrome) → tester surtout : menu burger, formulaire, bouton WhatsApp",
    "Tester sur Android (Chrome) → idem",
    "Tester sur tablette si possible",
    "Lancer GTmetrix.com sur l'URL → noter le score (objectif < 2 secondes mobile)",
    "Lancer PageSpeed Insights de Google → noter le score (objectif > 85 mobile)",
    "Remplir le formulaire de contact avec une vraie adresse → vérifier réception email",
    "Vérifier le cadenas SSL/HTTPS (https:// vert)",
    "Cocher chaque point de la CHECKLIST QA (voir plus bas dans ce SOP)"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Bug détecté → quoi faire :"},
  {"type":"list","items":[
    "**Bug visuel mineur** (1 image décalée) → noter dans une liste 'Bugs QA' → demander correction au dev avant suite",
    "**Bug fonctionnel** (formulaire ne marche pas) → BLOQUER la mise en ligne → demander correction immédiate",
    "**Bug performance** (site > 5 sec mobile) → demander optimisation images au designer/dev avant suite",
    "**Faute d'orthographe** → corriger SOI-MÊME directement dans le CMS si possible"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Les 12 cases QA sont cochées (toutes vertes). Aucun bug bloquant n'est ouvert. GTmetrix affiche < 2s mobile. PageSpeed > 85 mobile."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"GTmetrix lent (> 3s) → images non optimisées → demander conversion en WebP. Bouton WhatsApp ne marche pas mobile → vérifier le numéro dans le lien wa.me/. Formulaire arrive en spam → vérifier SPF/DKIM avec le dev."},
  {"type":"paragraph","text":"➡️ Étape suivante : envoyer le lien staging au client pour pré-validation."},

  {"type":"divider"},

  {"type":"heading2","text":"2. Envoyer le lien staging au client pour validation finale écrite"},
  {"type":"paragraph","text":"🎯 Objectif : obtenir la validation écrite du client avant la mise en ligne définitive. ⏱️ Temps : 10 min + attente 24h max."},
  {"type":"paragraph","text":"📍 Point de départ : QA 100% validé (étape 1 OK, 12 cases cochées)."},
  {"type":"paragraph","text":"🖥️ OÙ : Email Titan info@nextgital.com (PAS WhatsApp seul — il faut une trace écrite)."},
  {"type":"numbered","items":[
    "Ouvrir Gmail Titan info@nextgital.com",
    "Nouveau message → destinataire : email client",
    "Objet exact : 'Validation finale avant mise en ligne — [NOM PROJET]'",
    "Coller le template 'Pré-livraison' (voir templates plus bas)",
    "Remplir les variables",
    "Joindre une capture d'écran de la page d'accueil mobile + desktop",
    "Envoyer + doubler par un mini message WhatsApp 'Email de validation envoyé, à votre disposition 😊'",
    "Attendre la réponse écrite. Si rien après 24h → relance WhatsApp + appel téléphonique"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Email envoyé avec l'URL staging visible. Le client a accusé réception (au moins WhatsApp 👍). Tu as une trace écrite de la demande de validation."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Client demande modifications mineures → faire ou faire faire dans la journée + relancer la validation. Client demande modifications majeures hors scope → appliquer la règle 'demande hors scope' (escalade fondateur + devis additionnel). Silence radio 48h+ → appel téléphonique direct."},
  {"type":"paragraph","text":"➡️ Étape suivante : mise en ligne SEULEMENT après validation écrite reçue."},

  {"type":"divider"},

  {"type":"heading2","text":"3. Mise en ligne sur le domaine définitif"},
  {"type":"paragraph","text":"🎯 Objectif : passer le site de staging au domaine définitif sans casser quoi que ce soit. ⏱️ Temps : 30 à 45 min."},
  {"type":"paragraph","text":"📍 Point de départ : email écrit de validation du client reçu et archivé."},
  {"type":"paragraph","text":"🖥️ OÙ : panel hébergeur (cPanel OVH / Vercel / Hostinger selon projet) + DNS du domaine."},
  {"type":"numbered","items":[
    "Vérifier UNE DERNIÈRE FOIS que l'email de validation client est bien reçu (PAS de mise en ligne sans cet email)",
    "Faire un BACKUP complet du site staging (ZIP du dossier + export DB)",
    "Demander au dev de déployer sur le domaine définitif (ou le faire si tu as l'accès)",
    "Configurer le DNS si nécessaire (A record vers IP serveur)",
    "Attendre la propagation DNS (max 1h)",
    "Activer SSL HTTPS (Let's Encrypt en général, gratuit)",
    "Tester immédiatement sur le domaine définitif : formulaire, liens, vitesse",
    "Refaire un mini-QA (5 pages clés) pour confirmer que rien n'a cassé en passant en prod"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Checks post-mise en ligne (5 min) :"},
  {"type":"list","items":[
    "**Cadenas SSL visible** dans la barre Chrome (https:// vert)",
    "**Formulaire de contact** → soumettre un test → vérifier réception email",
    "**Lien WhatsApp mobile** → ouvre bien WhatsApp avec le bon numéro",
    "**Vitesse page d'accueil** → < 3 secondes au max"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le site est accessible sur son URL définitive (ex : drkarim-dentiste-oujda.ma). HTTPS actif. Formulaire fonctionne. Aucun lien cassé."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"DNS pas propagé → attendre jusqu'à 24h max. SSL ne s'active pas → demander au dev de régénérer Let's Encrypt. Formulaire OK staging mais KO prod → vérifier configuration SMTP serveur prod."},
  {"type":"paragraph","text":"➡️ Étape suivante : préparer et envoyer le dossier de livraison."},

  {"type":"divider"},

  {"type":"heading2","text":"4. Préparer et envoyer le dossier de livraison complet"},
  {"type":"paragraph","text":"🎯 Objectif : que le client ait TOUT ce qu'il faut pour gérer son site en autonomie. ⏱️ Temps : 45 min."},
  {"type":"paragraph","text":"📍 Point de départ : site en ligne sur domaine définitif (étape 3 OK)."},
  {"type":"paragraph","text":"🖥️ OÙ : Google Drive → dossier 05_Livraison + Loom (loom.com) pour la vidéo tuto + Google Docs pour le guide PDF."},
  {"type":"numbered","items":[
    "Enregistrer une vidéo Loom de 3 à 5 min montrant comment se connecter et modifier le site",
    "Créer un Google Doc 'Guide utilisateur — [NOM CLIENT]' avec captures d'écran",
    "Exporter le Google Doc en PDF",
    "Créer un fichier sécurisé .txt 'Accès et mots de passe' avec : URL admin, login, mot de passe (à changer par le client à la 1ère connexion)",
    "Mettre tous ces fichiers dans le dossier Drive '05_Livraison'",
    "Envoyer le message officiel de livraison (template ci-dessous) par WhatsApp + email",
    "Joindre les liens directs vers la vidéo + PDF + dossier mots de passe"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Contenu du dossier 05_Livraison :"},
  {"type":"numbered","items":[
    "Video_Tutoriel_5min.mp4 (lien Loom)",
    "Guide_Utilisateur_[CLIENT].pdf",
    "Acces_et_Mots_de_passe.txt (admin site + email + hébergeur)",
    "Captures_Avant_Livraison.zip (preuves visuelles du site final)",
    "Backup_Site_[DATE].zip (sauvegarde complète à conserver 1 an)"
  ]},
  {"type":"template","text":"🎉 Bonjour [PRÉNOM] !\n\nVotre site est officiellement EN LIGNE :\n🔗 [URL DU SITE]\n\nNous avons vérifié chaque détail avant la mise en ligne :\n✅ Vitesse optimisée (< 2 secondes)\n✅ 100% responsive mobile / tablette / desktop\n✅ SEO de base configuré (titres, descriptions, mots-clés)\n✅ SSL actif et sécurisé (cadenas vert)\n✅ Formulaire de contact testé et fonctionnel\n✅ Bouton WhatsApp opérationnel\n✅ Google Analytics installé\n\nVotre dossier de livraison complet :\n\n🎥 Vidéo tutoriel (5 min) :\n[LIEN LOOM]\n\n📘 Guide PDF d'utilisation :\n[LIEN PDF DRIVE]\n\n🔐 Accès admin et mots de passe :\n[LIEN FICHIER SÉCURISÉ DRIVE]\n(Pensez à changer le mot de passe à votre 1ère connexion)\n\n💡 Vous avez droit à 3 révisions gratuites pendant 30 jours.\n\nMerci infiniment pour votre confiance [PRÉNOM] 🙏\nC'est un plaisir de vous avoir accompagné dans ce projet.\n\n[VOTRE PRÉNOM] — Chef de projet Next Gital\n+212 620 002 066 · info@nextgital.com\nnextgital.tech"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le client a confirmé la bonne réception du dossier (au moins un emoji 🙏 ou 'merci'). Tous les liens fonctionnent. Le dossier Drive '05_Livraison' contient les 5 fichiers attendus."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Le client ne sait pas se connecter → faire un appel visio de 15 min pour l'accompagner. Vidéo Loom trop longue (> 10 min) → la couper en 2 ou 3 vidéos courtes par sujet. Mot de passe par défaut faible → forcer changement immédiat."},
  {"type":"paragraph","text":"➡️ Étape suivante : programmer le rappel J+2 pour la demande d'avis Google."},

  {"type":"divider"},

  {"type":"heading2","text":"5. Programmer le rappel J+2 pour la demande d'avis Google"},
  {"type":"paragraph","text":"🎯 Objectif : ne pas oublier de demander l'avis Google 5★ — chaque avis vaut de l'or pour Next Gital. ⏱️ Temps : 2 min maintenant + 5 min dans 2 jours."},
  {"type":"paragraph","text":"📍 Point de départ : livraison envoyée (étape 4 OK)."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → projet → onglet 'Alertes & Rappels' + Google Maps (lien avis)."},
  {"type":"numbered","items":[
    "GestiQ → projet → onglet 'Alertes & Rappels' → '+ Nouvelle alerte'",
    "Titre : 'Demander avis Google — [NOM CLIENT]'",
    "Date : aujourd'hui + 2 jours",
    "Assigné : moi (chef de projet)",
    "Action : envoyer le template 'Demande avis Google' par WhatsApp",
    "Sauvegarder",
    "Dans 2 jours, à l'heure de l'alerte : ouvrir WhatsApp → copier template → envoyer"
  ]},
  {"type":"template","text":"Bonjour [PRÉNOM] 😊\n\nJ'espère que votre nouveau site vous plaît et que tout fonctionne bien pour vous !\n\nSi vous êtes satisfait du travail accompli par Next Gital, un avis Google nous aiderait énormément à faire grandir notre petite équipe à Oujda 🙏\n\nCela prend littéralement 1 minute :\n\n⭐ Laisser un avis ici :\n[LIEN GOOGLE REVIEW DIRECT — https://g.page/r/...]\n\nMême quelques mots font une énorme différence pour nous.\n\nMerci d'avance et belle continuation dans votre activité !\n\n[VOTRE PRÉNOM] — Next Gital\n+212 620 002 066"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"L'alerte J+2 apparaît dans GestiQ avec statut 'Programmée'. Le client recevra le message au bon moment. Objectif : 1 avis 5★ par projet livré."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Lien Google Review direct introuvable → aller sur Google My Business > Avis > Partager > copier le 'short URL'. Client refuse poliment → ne pas insister, remercier."},
  {"type":"paragraph","text":"➡️ Étape suivante : fermer le projet dans GestiQ."},

  {"type":"divider"},

  {"type":"heading2","text":"6. Fermer le projet dans GestiQ et archiver"},
  {"type":"paragraph","text":"🎯 Objectif : passer le projet en 'Livré', mettre à jour les KPIs, archiver proprement. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : livraison envoyée et alerte avis Google programmée."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → projet → onglet 'Informations générales'."},
  {"type":"numbered","items":[
    "Changer le statut du projet → 'Livré'",
    "Saisir la date de livraison RÉELLE (aujourd'hui)",
    "Saisir le nombre de révisions effectuées",
    "Saisir la note de satisfaction client (si déjà connue, sinon laisser vide et compléter après l'avis Google)",
    "Créer une alerte automatique J+30 : 'Message de suivi commercial — proposer maintenance / refonte / SEO'",
    "Archiver les fichiers Drive (déplacer dans 'PROJETS LIVRÉS 2026')",
    "Cocher dans GestiQ → 'Projet clôturé'"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le projet n'apparaît plus dans 'En cours' mais dans 'Livrés'. Les KPIs du mois sont à jour. L'alerte J+30 est programmée pour relance commerciale."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Oubli de la date de livraison réelle → fausse les statistiques mensuelles → toujours saisir. Drive non archivé → encombre l'espace partagé → toujours déplacer."},
  {"type":"paragraph","text":"➡️ Le projet est officiellement clôturé. Bravo. Passe à la checklist QA finale et à la check de validation."},

  {"type":"divider"},

  {"type":"heading","text":"Templates de messages"},

  {"type":"heading2","text":"Template — Pré-livraison (validation finale staging)"},
  {"type":"template","text":"Bonjour [PRÉNOM] 😊\n\nVotre site est presque prêt ! Voici le lien de prévisualisation pour votre validation FINALE avant mise en ligne :\n\n🔗 [LIEN STAGING]\n(merci de tester sur ordinateur + mobile)\n\nMerci de vérifier en priorité :\n— Vos coordonnées (téléphone, email, adresse)\n— Vos textes et photos\n— Les liens vers vos réseaux sociaux\n— Le formulaire de contact (faites un test)\n\nVos retours sont attendus avant le [DATE + 24H].\n\nUne fois votre accord reçu par EMAIL (pour la trace écrite officielle), nous procédons à la mise en ligne définitive sur votre domaine 🚀\n\nÀ très vite,\nNext Gital"},

  {"type":"heading2","text":"Template — Demande d'avis Google (J+2)"},
  {"type":"template","text":"Bonjour [PRÉNOM] 😊\n\nJ'espère que votre nouveau site vous plaît et que tout fonctionne bien !\n\nSi vous êtes satisfait du travail accompli, un avis Google nous aiderait énormément à faire grandir notre petite équipe à Oujda 🙏\n\nCela prend 1 minute :\n⭐ [LIEN GOOGLE REVIEW DIRECT]\n\nMême quelques mots font une énorme différence pour nous.\n\nMerci d'avance et belle continuation !\nNext Gital"},

  {"type":"divider"},

  {"type":"heading","text":"Checklist QA — les 12 points à valider AVANT mise en ligne (interdiction de mettre en ligne si une seule case manque)"},
  {"type":"checklist","items":[
    "Vitesse < 2 secondes sur mobile (GTmetrix ou PageSpeed Insights)",
    "Responsive testé : iPhone (Safari + Chrome), Android (Chrome), tablette, desktop",
    "Tous les liens internes et externes fonctionnent (cliqués un par un)",
    "Formulaire de contact : envoi testé + email de réception bien reçu",
    "Bouton WhatsApp fonctionne sur mobile (ouvre WhatsApp avec le bon numéro)",
    "SSL / HTTPS actif — cadenas vert visible dans la barre d'adresse",
    "Google Analytics installé et données reçues en temps réel (test live)",
    "Meta tags SEO (title + description uniques) sur toutes les pages",
    "Images optimisées (< 200 Ko chacune, format WebP si possible)",
    "Favicon visible dans l'onglet du navigateur",
    "Backup complet du site effectué AVANT la mise en ligne (ZIP + DB)",
    "Textes relus à voix haute — aucune faute d'orthographe ou info incorrecte"
  ]},

  {"type":"divider"},

  {"type":"heading","text":"Checklist finale de livraison"},
  {"type":"checklist","items":[
    "Les 12 cases QA cochées",
    "Email de validation finale écrit reçu du client",
    "Site mis en ligne sur le domaine définitif",
    "HTTPS / SSL actif et vérifié",
    "Backup post mise en ligne effectué",
    "Vidéo Loom tuto enregistrée",
    "Guide PDF utilisateur créé et envoyé",
    "Dossier accès et mots de passe partagé sécurisé",
    "Message de livraison officielle envoyé (WhatsApp + email)",
    "Alerte J+2 'Demande avis Google' programmée",
    "Statut GestiQ passé à 'Livré'",
    "Alerte J+30 'Suivi commercial' programmée",
    "Fichiers Drive archivés dans 'PROJETS LIVRÉS 2026'"
  ]},

  {"type":"divider"},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si un bug bloquant apparaît APRÈS la mise en ligne (site cassé, formulaire HS, virus, etc.) → STOPPER tout autre travail, WhatsApp fondateur immédiatement +212 620 002 066 : 'URGENCE PROD — site [URL] — bug [description] — durée actuelle : [X min]'. Objectif : remettre en ligne propre en < 1h."}
]$sop$::jsonb,
    read_min = 14,
    updated_at = now()
WHERE slug = 'ng-cdp-livraison-finale';


-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  5. ng-cdp-kpis-rapport-mensuel                                  ║
-- ╚══════════════════════════════════════════════════════════════════╝
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"warning","title":"⏰ Délai impératif","text":"Le 1er de CHAQUE MOIS — rapport envoyé au fondateur AVANT 10h00. Si le 1er tombe un week-end : faire le rapport le dernier jour ouvré du mois."},
  {"type":"callout","variant":"info","title":"📡 Canal de travail","text":"GestiQ (extraction données) + Google Doc (rédaction) + Email Titan (envoi au fondateur)."},
  {"type":"callout","variant":"tip","title":"🎯 Objectif final","text":"Le fondateur a en main, le 1er du mois à 10h, un bilan factuel + 3 actions d'amélioration concrètes à mettre en œuvre."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"Aucun chiffre inventé. Tous les KPIs doivent provenir directement de GestiQ (rapports exports). Si une donnée manque : écrire 'Non disponible' plutôt que d'estimer."},

  {"type":"heading","text":"KPIs officiels à suivre chaque mois"},
  {"type":"table","table":{
    "headers":["Indicateur","Objectif mensuel","Source GestiQ","Fréquence"],
    "rows":[
      ["Projets livrés","4+ par mois","Projets > Statut Livré","Mensuel"],
      ["Projets livrés dans les délais","100%","Comparer date prévue vs réelle","Par projet"],
      ["Satisfaction client moyenne","≥ 8/10","Champ saisi à la clôture","Par projet"],
      ["Révisions demandées par projet","≤ 2 en moyenne","Champ révisions","Par projet"],
      ["Avis Google obtenus","2+ par mois","Google My Business","Mensuel"],
      ["Projets en retard à fin de mois","0","Projets en cours avec date dépassée","Mensuel"],
      ["Délai moyen de livraison","≤ 21 jours","Calcul auto GestiQ","Mensuel"],
      ["Taux de relance client","< 30%","Nombre relances / nombre échanges","Mensuel"]
    ]
  }},

  {"type":"divider"},

  {"type":"heading","text":"Étapes — dans l'ordre exact"},

  {"type":"heading2","text":"1. Exporter les données brutes du mois depuis GestiQ"},
  {"type":"paragraph","text":"🎯 Objectif : récupérer en CSV / PDF tous les chiffres du mois écoulé pour pouvoir les analyser. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : le 1er du mois à 8h30, café en main, calme avant 9h."},
  {"type":"paragraph","text":"🖥️ OÙ : gestiq.nextgital.tech → menu 'Rapports & Export' → onglet 'Rapport mensuel'."},
  {"type":"numbered","items":[
    "Se connecter à GestiQ",
    "Aller dans 'Rapports & Export' → onglet 'Rapport mensuel'",
    "Sélectionner le mois précédent (ex : si on est le 1er juin → sélectionner Mai)",
    "Cliquer 'Générer rapport' → attendre 30 secondes",
    "Exporter en PDF + CSV (les deux)",
    "Sauvegarder dans Drive > 'RAPPORTS MENSUELS' > [ANNÉE] > [MOIS]",
    "Ouvrir le PDF et vérifier rapidement : nombre projets livrés, CA, satisfaction moyenne"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Données à extraire (à noter dans un Google Doc temporaire) :"},
  {"type":"list","items":[
    "**Nombre projets livrés** → ex : 5",
    "**CA TTC encaissé** → ex : 42 000 MAD",
    "**Projets livrés dans les délais** → ex : 4 sur 5 = 80%",
    "**Note satisfaction moyenne** → ex : 8.6 / 10",
    "**Nombre révisions moyennes par projet** → ex : 1.8",
    "**Avis Google obtenus ce mois** → ex : 3",
    "**Projets encore en cours** → ex : 7",
    "**Projets en retard à fin de mois** → ex : 1"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le PDF + CSV sont sauvegardés dans Drive avec le bon nom. Le Google Doc temporaire contient les 8 KPIs chiffrés."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Export ne se génère pas → vérifier la connexion + relancer. Données incohérentes (ex : 0 projet livré) → vérifier que les projets ont bien été passés à 'Livré' au moment de leur livraison."},
  {"type":"paragraph","text":"➡️ Étape suivante : remplir la fiche bilan projet par projet."},

  {"type":"divider"},

  {"type":"heading2","text":"2. Remplir la fiche bilan pour CHAQUE projet livré ce mois"},
  {"type":"paragraph","text":"🎯 Objectif : pour chaque projet livré, identifier ce qui a marché et ce qui a posé problème. ⏱️ Temps : 15 min (≈ 3 min par projet)."},
  {"type":"paragraph","text":"📍 Point de départ : données exportées (étape 1 OK)."},
  {"type":"paragraph","text":"🖥️ OÙ : Google Doc 'Rapport mensuel [MOIS] — bilan projets' (créer s'il n'existe pas)."},
  {"type":"numbered","items":[
    "Lister tous les projets livrés ce mois (avec leur nom client)",
    "Pour chaque projet, créer une section H2 dans le Google Doc",
    "Remplir les 5 informations ci-dessous (voir CONTENU EXACT)",
    "Identifier au moins 1 leçon apprise par projet (positive ou négative)",
    "Sauvegarder dans Drive > 'RAPPORTS MENSUELS'"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Pour chaque projet, noter :"},
  {"type":"list","items":[
    "**Livré dans les délais ?** → O / N — Si N : combien de jours de retard et pourquoi",
    "**Nombre de révisions effectuées** → chiffre exact",
    "**Note satisfaction client obtenue** → /10 (depuis GestiQ ou avis Google)",
    "**Problèmes rencontrés** → 1 à 3 phrases factuelles (technique / client / interne)",
    "**Leçons apprises** → 1 à 2 phrases concrètes pour la prochaine fois"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le Google Doc contient une section par projet livré. Toutes les sections ont les 5 informations remplies. Pas de section vide ou 'à compléter'."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Tu ne te souviens plus des détails → consulter les commentaires Kanban et l'historique WhatsApp du projet. Note satisfaction manquante → demander au client par un mini-WhatsApp ('vous mettriez quelle note sur 10 à notre travail ?')."},
  {"type":"paragraph","text":"➡️ Étape suivante : identifier les 3 améliorations du mois prochain."},

  {"type":"divider"},

  {"type":"heading2","text":"3. Identifier les 3 améliorations CONCRÈTES pour le mois prochain"},
  {"type":"paragraph","text":"🎯 Objectif : transformer les leçons du mois en actions précises et réalistes. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : bilans projet par projet remplis (étape 2 OK)."},
  {"type":"paragraph","text":"🖥️ OÙ : même Google Doc, nouvelle section '3 améliorations mois prochain'."},
  {"type":"numbered","items":[
    "Relire toutes les sections 'Problèmes rencontrés' et 'Leçons apprises'",
    "Identifier les patterns (problèmes répétés)",
    "Choisir les 3 améliorations qui auront LE PLUS d'impact",
    "Pour chaque amélioration : formuler une action CONCRÈTE et MESURABLE",
    "Affecter un responsable et une deadline (dans le mois)",
    "Noter dans le Google Doc"
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Une bonne amélioration ressemble à ça :"},
  {"type":"list","items":[
    "**Bon** → 'Créer un checklist 'Assets client' à envoyer dès la signature du devis — Responsable : moi — Deadline : 15 juin'",
    "**Mauvais** → 'Mieux gérer les assets clients'",
    "**Bon** → 'Mettre en place un QA mobile systématique avec test iPhone + Android avant chaque livraison — Responsable : dev — Deadline : prochaine livraison'",
    "**Mauvais** → 'Tester plus'",
    "**Bon** → 'Envoyer le devis additionnel sous 24h max après demande hors scope — Responsable : moi — Deadline : permanent'",
    "**Mauvais** → 'Être plus réactif sur les devis'"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu as exactement 3 améliorations (pas 5, pas 1). Chacune a un verbe d'action, un responsable, et une deadline."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Aucun problème identifié ce mois (mois 'parfait') → impossible, creuser : il y a toujours quelque chose à améliorer (vitesse de réponse, qualité onboarding, etc.). Améliorations trop vagues → reformuler en action concrète."},
  {"type":"paragraph","text":"➡️ Étape suivante : rédiger et envoyer le rapport au fondateur."},

  {"type":"divider"},

  {"type":"heading2","text":"4. Envoyer le rapport mensuel au fondateur (avant 10h le 1er)"},
  {"type":"paragraph","text":"🎯 Objectif : que le fondateur ait son rapport en main avant son 1er meeting de la journée. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Google Doc bilan + améliorations finalisé (étape 3 OK)."},
  {"type":"paragraph","text":"🖥️ OÙ : Email Titan info@nextgital.com → destinataire fondateur."},
  {"type":"numbered","items":[
    "Ouvrir Gmail Titan",
    "Nouveau message → destinataire : email fondateur",
    "Objet exact : 'Rapport mensuel Chef de projet — [MOIS ANNÉE]'",
    "Copier le template ci-dessous dans le corps du mail",
    "Remplir avec les vraies données du Google Doc",
    "Joindre le PDF d'export GestiQ + le Google Doc complet (lien Drive)",
    "Envoyer AVANT 10h00",
    "Confirmer par WhatsApp privé au fondateur : 'Rapport mensuel envoyé par mail, à votre dispo pour en discuter 🙏'"
  ]},
  {"type":"template","text":"📊 RAPPORT MENSUEL — CHEF DE PROJET\nPériode : [MOIS ANNÉE]\nEnvoyé le : [DATE] à [HEURE]\n\n━━━━━━━━━━ PROJETS ━━━━━━━━━━\n✅ Projets livrés : [X]\n⏰ Livrés dans les délais : [X / Y] ([POURCENT]%)\n🔄 Projets encore en cours : [X]\n⚠️ Projets en retard à fin de mois : [X]\n📅 Délai moyen de livraison : [X] jours\n\n━━━━━━━━━━ QUALITÉ ━━━━━━━━━━\n⭐ Satisfaction moyenne clients : [X] / 10\n✏️ Révisions moyennes par projet : [X]\n🌟 Avis Google obtenus ce mois : [X]\n📞 Taux de relance client : [X]%\n\n━━━━━━━━━━ FINANCIER (donné par comptable) ━━━━━━━━━━\n💰 CA TTC encaissé : [X] MAD\n📄 Factures impayées > 14j : [X]\n\n━━━━━━━━━━ TOP 3 PROBLÈMES RENCONTRÉS ━━━━━━━━━━\n1. [PROBLÈME 1 — CAUSE — PROJET CONCERNÉ]\n2. [PROBLÈME 2 — CAUSE — PROJET CONCERNÉ]\n3. [PROBLÈME 3 — CAUSE — PROJET CONCERNÉ]\n\n━━━━━━━━━━ 3 AMÉLIORATIONS POUR LE MOIS PROCHAIN ━━━━━━━━━━\n1. [ACTION CONCRÈTE 1 — RESPONSABLE — DEADLINE]\n2. [ACTION CONCRÈTE 2 — RESPONSABLE — DEADLINE]\n3. [ACTION CONCRÈTE 3 — RESPONSABLE — DEADLINE]\n\n━━━━━━━━━━ ALERTES À TRAITER ━━━━━━━━━━\n[LISTE DES POINTS NÉCESSITANT UNE DÉCISION DU FONDATEUR : ex 'Client X demande baisse 20%' / 'Recrutement dev urgent' / etc.]\n\n📎 Pièces jointes :\n— Export GestiQ PDF\n— Google Doc bilan détaillé : [LIEN DRIVE]\n\nDisponible pour échanger.\n\n[VOTRE PRÉNOM] — Chef de projet Next Gital"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Email envoyé AVANT 10h00 avec objet correct + pièces jointes attachées. Le fondateur a accusé réception (au moins 👍 WhatsApp). Le rapport est rangé dans Drive > RAPPORTS MENSUELS."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Tu n'arrives pas à remplir une section (donnée manquante) → écrire 'Non disponible — sera complété au prochain rapport' et noter l'action pour corriger la source. Rapport envoyé après 10h → s'excuser par WhatsApp et expliquer cause (impair occasionnel toléré, récurrent non)."},
  {"type":"paragraph","text":"➡️ Le rapport est envoyé. Tu peux maintenant reprendre les opérations normales du mois."},

  {"type":"divider"},

  {"type":"heading","text":"Templates de messages"},

  {"type":"heading2","text":"Template — Confirmation WhatsApp au fondateur"},
  {"type":"template","text":"Bonjour [PRÉNOM FONDATEUR] 👋\n\nLe rapport mensuel de [MOIS] vient d'être envoyé par mail.\n\nPoints clés :\n— [X] projets livrés ce mois\n— Satisfaction moyenne : [X]/10\n— [X] avis Google obtenus\n— [X] alertes nécessitant ta décision\n\nJe reste dispo pour en discuter quand tu veux 🙏\n\n[VOTRE PRÉNOM]"},

  {"type":"heading2","text":"Template — Mini-demande de note satisfaction au client (si manquante)"},
  {"type":"template","text":"Bonjour [PRÉNOM] 😊\n\nPetite question rapide pour notre suivi qualité interne :\n\nSur une note de 0 à 10, à combien évalueriez-vous notre travail sur votre projet [NOM PROJET] ?\n\nUne note + une phrase courte sur ce qu'on pourrait améliorer suffisent.\n\nMerci beaucoup ! 🙏\nNext Gital"},

  {"type":"divider"},

  {"type":"heading","text":"Checklist de fin de mois"},
  {"type":"checklist","items":[
    "Données du mois exportées depuis GestiQ (PDF + CSV)",
    "Fichiers sauvegardés dans Drive > RAPPORTS MENSUELS > [ANNÉE] > [MOIS]",
    "Fiche bilan remplie pour CHAQUE projet livré (5 infos par projet)",
    "8 KPIs calculés et comparés aux objectifs",
    "3 améliorations concrètes identifiées (verbe + responsable + deadline)",
    "Rapport email envoyé au fondateur AVANT 10h le 1er du mois",
    "Pièces jointes attachées (PDF + lien Google Doc)",
    "Confirmation WhatsApp envoyée au fondateur",
    "Note satisfaction obtenue pour chaque projet livré (sinon demande envoyée)"
  ]},

  {"type":"divider"},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si tu détectes une dérive grave (>2 projets en retard, satisfaction moyenne < 7/10, > 3 plaintes clients dans le mois) → ne pas attendre le rapport mensuel, alerter le fondateur IMMÉDIATEMENT par WhatsApp +212 620 002 066 : 'ALERTE QUALITÉ — [MOIS EN COURS] — [DÉRIVE OBSERVÉE EN 1 LIGNE] — je propose [SOLUTION]'."}
]$sop$::jsonb,
    read_min = 10,
    updated_at = now()
WHERE slug = 'ng-cdp-kpis-rapport-mensuel';


COMMIT;
