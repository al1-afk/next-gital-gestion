-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 040 : SOPs ultra-détaillés Prospection
--  Date : 2026-05-17
--  Objectif : remplacer les blocks des 11 SOPs Prospection par une
--  version ULTRA-DÉTAILLÉE (employé exécute dès J1 sans question)
--  7 contenus distincts couvrant 11 slugs
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ────────────────────────────────────────────────────────────────────
--  1/7  WHATSAPP COLD  (ng-pr-whatsapp-cold + ng-prospect-whatsapp)
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏱️ Délai d'exécution","text":"Cette SOP couvre 1 journée type de prospection WhatsApp froide. Durée : 2h30 (préparation + envois + suivi). À faire entre 9h00 et 12h00 (taux de réponse +40 % vs après-midi)."},
  {"type":"callout","variant":"info","title":"📱 Canal","text":"WhatsApp Business uniquement (jamais WhatsApp personnel). Numéro Next Gital : +212 620 002 066."},
  {"type":"callout","variant":"tip","title":"🎯 Objectif quotidien","text":"30 messages envoyés → 6 à 9 réponses (taux 20-30 %) → 2 à 3 RDV pris sur Calendly."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"JAMAIS plus de 30 messages/jour depuis le même numéro. JAMAIS copier-coller identique : personnalise chaque message (sinon ban WhatsApp à vie)."},

  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. PRÉPARER LA LISTE DE 30 PROSPECTS"},
  {"type":"paragraph","text":"🎯 Objectif : avoir 30 prospects qualifiés avec numéro WhatsApp + observation personnalisée. ⏱️ Temps : 45 min."},
  {"type":"paragraph","text":"📍 Point de départ : ordinateur ouvert, GestiQ connecté."},
  {"type":"paragraph","text":"🖥️ OÙ : https://gestiq.nextgital.tech/prospects?statut=a-contacter"},
  {"type":"numbered","items":[
    "Ouvre GestiQ → onglet Prospects → filtre statut = 'À contacter'.",
    "Si moins de 30 prospects dispo : va sur Google Maps (https://maps.google.com), tape '[secteur] Oujda' (ex : 'dentiste Oujda', 'restaurant Oujda', 'avocat Oujda').",
    "Pour chaque résultat : note nom, adresse, téléphone, note Google (4★ et + = priorité).",
    "Vérifie site web : s'il n'a PAS de site OU site cassé/vieux = score 5/5 (cible parfaite).",
    "Ajoute le prospect dans GestiQ : bouton + Nouveau prospect → remplis nom, téléphone, secteur, source = 'Google Maps', score 1-5.",
    "Dans le champ Observation : écris UNE phrase concrète (ex : 'Pas de site web - vu sur Google Maps', 'Site lent qui plante sur mobile', 'Très bonnes avis Google mais aucune photo récente sur Facebook')."
  ]},
  {"type":"paragraph","text":"✏️ CRITÈRES DE QUALIFICATION (score 1-5) :"},
  {"type":"list","items":[
    "**Score 5/5** → Pas de site OU site cassé + business visible (boutique physique, avis Google) → cible parfaite",
    "**Score 4/5** → Site obsolète (> 5 ans, pas mobile) + activité confirmée",
    "**Score 3/5** → Site correct mais pas optimisé conversion",
    "**Score 2/5** → Site OK mais business questionnable",
    "**Score 1/5** → Site moderne + agence déjà active → SKIP"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu dois avoir 30 lignes dans le filtre 'À contacter' avec score ≥ 3, numéro WhatsApp valide (format +212 6XX XXX XXX) et observation personnalisée."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Numéro invalide → vérifie format international +212 6XX XXX XXX (pas 06XX). Pas de WhatsApp sur ce numéro → marque 'No WhatsApp' dans Observation et passe au suivant. Doublon GestiQ → barre rouge apparaît → fusionne ou skip."},
  {"type":"paragraph","text":"➡️ Étape suivante : Ouvrir WhatsApp Business et préparer le pitch."},

  {"type":"heading2","text":"2. OUVRIR WHATSAPP BUSINESS"},
  {"type":"paragraph","text":"🎯 Objectif : être prêt à envoyer 30 messages depuis le compte pro. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"🖥️ OÙ : WhatsApp Web (https://web.whatsapp.com) connecté au compte Business Next Gital (+212 620 002 066)."},
  {"type":"numbered","items":[
    "Ouvre https://web.whatsapp.com dans Chrome.",
    "Scanne le QR code avec le téléphone pro Next Gital.",
    "Vérifie en haut à gauche : nom 'Next Gital' + photo de profil logo Next Gital.",
    "Si tu vois ton WhatsApp personnel → DÉCONNECTE immédiatement (Menu → Déconnexion) et reconnecte avec le téléphone pro.",
    "Ouvre un onglet supplémentaire GestiQ pour mettre à jour les statuts en parallèle."
  ]},
  {"type":"callout","variant":"danger","title":"🚫 Erreur fatale","text":"Si tu envoies depuis ton numéro personnel : ton numéro sera ban WhatsApp en 24h + impossibilité de retracer dans GestiQ. Vérifie 2 fois."},

  {"type":"heading2","text":"3. RÉDIGER LE MESSAGE D'OUVERTURE PERSONNALISÉ"},
  {"type":"paragraph","text":"🎯 Objectif : message court (3-4 lignes), personnalisé, qui montre une observation concrète et propose un appel de 15 min. ⏱️ Temps : 1 min par message."},
  {"type":"paragraph","text":"✏️ STRUCTURE OBLIGATOIRE (4 parties) :"},
  {"type":"list","items":[
    "**Salutation + nom** → 'Bonjour Dr. Karim,' (jamais 'Bonjour Monsieur' tout court)",
    "**Observation concrète** → 'J'ai vu sur Google que votre cabinet n'a pas de site web' (preuve que tu as regardé)",
    "**Proposition de valeur** → 'On aide les dentistes d'Oujda à avoir +10 RDV/mois via un site qui convertit'",
    "**Call-to-action soft** → 'Vous auriez 15 min cette semaine pour un échange rapide ?' (jamais 'achetez', jamais 'devis')"
  ]},
  {"type":"template","text":"Bonjour Dr. Karim 👋\n\nJe suis Saïd de Next Gital (agence digitale Oujda). J'ai vu sur Google que votre cabinet dentaire n'a pas encore de site web — pourtant vous avez 4,7★ et 80+ avis, c'est dommage de ne pas capter ces patients qui cherchent un dentiste en ligne.\n\nOn aide les cabinets dentaires d'Oujda à avoir +10 nouveaux patients/mois via un site simple qui convertit. Vous auriez 15 min cette semaine pour un échange rapide ?\n\nSaïd · Next Gital · nextgital.tech"},
  {"type":"template","text":"Bonjour 👋\n\nJe suis Saïd de Next Gital (Oujda). En passant Bd Mohammed V hier j'ai vu votre restaurant Al Baraka — la déco est magnifique mais en cherchant en ligne je n'ai trouvé ni site ni menu Instagram à jour.\n\nOn aide les restos d'Oujda à doubler leurs réservations grâce à un site + menu en ligne. 15 min d'échange cette semaine ?\n\nSaïd · nextgital.tech"},
  {"type":"template","text":"Bonjour Maître 👋\n\nSaïd de Next Gital, agence digitale à Oujda. En recherchant 'avocat Oujda' sur Google, votre cabinet n'apparaît qu'en 8e position — vos confrères en première page captent 80% des appels.\n\nOn aide les cabinets d'avocats d'Oujda à passer top 3 Google en 90 jours. Auriez-vous 15 min cette semaine ?\n\nSaïd · nextgital.tech"},
  {"type":"callout","variant":"warning","title":"⚠️ INTERDICTIONS ABSOLUES","text":"NE JAMAIS écrire : 'Nous proposons des sites web pas chers' (banal), 'Devis gratuit' (spam), 'PROMO -50%' (cheap), messages > 6 lignes (personne ne lit), emojis partout (max 2)."},

  {"type":"heading2","text":"4. ENVOYER LES 30 MESSAGES (RYTHME CONTRÔLÉ)"},
  {"type":"paragraph","text":"🎯 Objectif : envoyer 30 messages personnalisés avec rythme anti-spam. ⏱️ Temps : 1h30 (3 min par message en moyenne)."},
  {"type":"paragraph","text":"📍 Point de départ : liste 30 prospects ouverte dans GestiQ, WhatsApp Web prêt."},
  {"type":"numbered","items":[
    "Prends le prospect n°1 de ta liste (clique sur la ligne dans GestiQ).",
    "Copie son numéro (format +212 6XX XXX XXX).",
    "Dans WhatsApp Web : clique 'Nouveau message' (icône crayon), colle le numéro, clique 'Démarrer une discussion'.",
    "Rédige le message en suivant la structure (salutation + observation + valeur + CTA).",
    "Relis 2 fois : nom correct ? observation juste ? pas de faute ?",
    "Envoie.",
    "Reviens sur GestiQ → change statut prospect = 'Contacté' → ajoute date + heure dans Notes.",
    "ATTENDS 2-3 minutes avant le suivant (mets un timer).",
    "Répète pour les 30 prospects."
  ]},
  {"type":"callout","variant":"danger","title":"🚫 ANTI-BAN WHATSAPP","text":"NE JAMAIS envoyer 30 messages d'affilée en 5 min → WhatsApp détecte le spam et ban le numéro. Respecte 2-3 min entre chaque message. Si tu sens que tu envoies trop vite : pause 15 min toutes les 10 messages."},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Après 1h30 : 30 messages envoyés, 30 prospects en statut 'Contacté' dans GestiQ avec horodatage."},

  {"type":"heading2","text":"5. GÉRER LES RÉPONSES POSITIVES"},
  {"type":"paragraph","text":"🎯 Objectif : convertir une réponse 'OK intéressé' en RDV Calendly confirmé. ⏱️ Temps : 5 min par réponse positive."},
  {"type":"paragraph","text":"📍 Point de départ : notification WhatsApp d'une réponse."},
  {"type":"numbered","items":[
    "Réponds dans les 15 minutes (au-delà : taux de conversion divisé par 2).",
    "Remercie + propose 2 créneaux précis OU lien Calendly.",
    "Si le prospect propose un créneau → confirme + ajoute dans Calendly.",
    "Envoie immédiatement le lien Calendly : https://calendly.com/nextgital/15min",
    "Dans GestiQ : passe le prospect en statut 'RDV pris' + saisis date/heure RDV."
  ]},
  {"type":"template","text":"Super, merci pour votre retour 🙏\n\nVoici mon agenda direct : https://calendly.com/nextgital/15min\nRéservez le créneau qui vous arrange, c'est 100% gratuit et sans engagement.\n\nÀ très vite,\nSaïd"},

  {"type":"heading2","text":"6. GÉRER LES RÉPONSES NÉGATIVES / SILENCE"},
  {"type":"paragraph","text":"🎯 Objectif : ne JAMAIS insister mais garder la porte ouverte. ⏱️ Temps : 1 min."},
  {"type":"numbered","items":[
    "Réponse 'Pas intéressé' → réponds 'Pas de souci, merci de votre retour. Bonne continuation à vous 🙏' → statut GestiQ = 'Perdu'.",
    "Réponse 'Plus tard' → 'Parfait, je vous recontacte dans 1 mois si vous le voulez bien' → statut = 'À relancer' + date relance J+30.",
    "Silence après 3 jours → relance J+3 (étape 7).",
    "Silence après J+7 → relance finale (étape 7), puis statut 'Perdu'."
  ]},
  {"type":"callout","variant":"danger","title":"🚫 INTERDIT","text":"JAMAIS insister 'mais juste 10 min ?', JAMAIS de message culpabilisant. La réputation Next Gital est plus précieuse qu'un client."},

  {"type":"heading2","text":"7. RELANCES J+3 ET J+7"},
  {"type":"paragraph","text":"🎯 Objectif : récupérer les 50 % de prospects qui n'ont pas répondu au 1er message. ⏱️ Temps : 30 min/jour pour les relances."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → filtre 'Contacté' + date contact = J-3 ou J-7."},
  {"type":"numbered","items":[
    "Chaque matin, filtre les prospects 'Contacté' il y a 3 jours.",
    "Envoie message relance J+3 (court, valeur ajoutée, pas de pression).",
    "Si toujours pas de réponse à J+7 : message final.",
    "Si silence à J+7 : statut = 'Perdu' et passe au prochain."
  ]},
  {"type":"template","text":"Bonjour Dr. Karim,\n\nJe me permets de revenir vers vous suite à mon message de mardi. Si vous voulez voir concrètement ce qu'on peut faire pour votre cabinet, voici un exemple d'un de nos clients (cabinet dentaire de Casa) qui a doublé ses RDV en 4 mois : https://nextgital.tech/cas-dentiste\n\n15 min cette semaine si ça vous parle ? 🙏\n\nSaïd"},
  {"type":"template","text":"Bonjour Dr. Karim,\n\nDernier message de ma part promis 😊 Si jamais vous changez d'avis ou avez besoin d'un conseil web, mon numéro reste ouvert.\n\nBonne continuation à votre cabinet !\nSaïd · Next Gital"},

  {"type":"heading2","text":"8. CLÔTURE DE JOURNÉE"},
  {"type":"paragraph","text":"🎯 Objectif : tracking complet pour analyse du taux conversion. ⏱️ Temps : 10 min en fin de journée."},
  {"type":"numbered","items":[
    "Ouvre GestiQ → Tableau de bord Prospection.",
    "Note dans ton rapport quotidien (canal Slack #prospection) : messages envoyés, réponses reçues, RDV pris.",
    "Format : '17/05 — 30 msg envoyés / 8 réponses (27%) / 3 RDV pris'.",
    "Identifie le secteur qui marche le mieux aujourd'hui pour ajuster demain."
  ]},

  {"type":"divider"},
  {"type":"heading2","text":"Templates de messages prêts à l'emploi"},
  {"type":"template","text":"OUVERTURE — Commerce local sans site\n\nBonjour [Prénom] 👋\n\nSaïd de Next Gital, agence digitale Oujda. J'ai remarqué que [nom commerce] n'a pas de site web alors que vous avez [X] avis Google 4★+. Vos concurrents qui ont un site captent les clients qui cherchent en ligne.\n\nOn aide les [secteur] d'Oujda à avoir +X clients/mois via un site simple. 15 min cette semaine pour vous montrer ?\n\nSaïd · nextgital.tech"},
  {"type":"template","text":"OUVERTURE — Site existant mais dépassé\n\nBonjour [Prénom] 👋\n\nSaïd de Next Gital. J'ai testé votre site [nom-site.ma] — il met 8 secondes à charger sur mobile (norme : 2 sec), du coup vous perdez 70% des visiteurs avant qu'ils voient votre offre.\n\nOn refait des sites rapides + SEO en 21 jours. 15 min pour en discuter ?\n\nSaïd · nextgital.tech"},
  {"type":"template","text":"RELANCE — J+3 (preuve sociale)\n\nBonjour [Prénom],\n\nPour info, on vient de livrer le site de [client référence local] — +40% de RDV en 2 mois. Si vous voulez voir le cas concret : [lien].\n\n15 min cette semaine ? 🙏\n\nSaïd"},

  {"type":"divider"},
  {"type":"heading2","text":"Checklist de validation fin de journée"},
  {"type":"checklist","items":[
    "30 messages envoyés depuis WhatsApp Business pro (+212 620 002 066)",
    "Chaque message personnalisé (nom + observation concrète)",
    "Rythme respecté (2-3 min entre messages, pause toutes les 10)",
    "30 prospects passés en statut 'Contacté' dans GestiQ",
    "Relances J+3 et J+7 envoyées pour les anciens 'Contacté'",
    "Toutes les réponses traitées dans les 15 min",
    "RDV pris ajoutés dans Calendly + statut 'RDV pris'",
    "Rapport quotidien posté dans Slack #prospection"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si bloqué > 15 min sur un point (ban WhatsApp, prospect agressif, demande tarifaire complexe, doute sur message à envoyer) → WhatsApp Saïd directement : +212 620 002 066. NE PAS improviser."}
]$sop$::jsonb,
    read_min = 12,
    updated_at = now()
WHERE slug IN ('ng-pr-whatsapp-cold','ng-prospect-whatsapp');


-- ────────────────────────────────────────────────────────────────────
--  2/7  LINKEDIN  (ng-pr-linkedin + ng-prospect-linkedin)
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏱️ Délai d'exécution","text":"Cette SOP couvre 1 journée type LinkedIn. Durée : 2h (recherche + connexions + messages + suivi). À faire entre 10h et 12h ou 17h-19h (pics d'activité LinkedIn)."},
  {"type":"callout","variant":"info","title":"💼 Canal","text":"LinkedIn (linkedin.com) — compte pro Next Gital : linkedin.com/company/next-gital. Compte personnel commercial : profil optimisé Saïd Next Gital."},
  {"type":"callout","variant":"tip","title":"🎯 Objectif quotidien","text":"20 demandes de connexion envoyées → 10 acceptations → 3 conversations engagées → 1 RDV pris."},
  {"type":"callout","variant":"danger","title":"🚫 Limite LinkedIn","text":"MAX 20 invitations/jour (au-delà : restrictions compte). MAX 100 messages/jour. JAMAIS de copier-coller détecté par LinkedIn."},

  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. VÉRIFIER L'OPTIMISATION DU PROFIL (1ère utilisation)"},
  {"type":"paragraph","text":"🎯 Objectif : profil 100% crédible avant de prospecter. ⏱️ Temps : 30 min (1 fois, puis vérif mensuelle)."},
  {"type":"paragraph","text":"🖥️ OÙ : https://www.linkedin.com/in/[ton-pseudo] (mode édition)."},
  {"type":"paragraph","text":"✏️ ÉLÉMENTS OBLIGATOIRES :"},
  {"type":"list","items":[
    "**Photo de profil** → portrait pro, fond neutre, sourire, format carré 400x400px minimum",
    "**Bannière** → bannière Next Gital (à demander à Saïd) avec URL nextgital.tech visible",
    "**Titre (headline)** → 'Agence digitale Oujda — Sites web qui convertissent | +212 620 002 066' (max 220 caractères)",
    "**Section À propos** → 3 paragraphes : qui tu es, ce que Next Gital fait, comment prendre RDV (lien Calendly)",
    "**Expérience** → Poste actuel : 'Business Developer chez Next Gital — Agence digitale (Oujda, Maroc)' avec description",
    "**Coordonnées** → email info@nextgital.com + site nextgital.tech + WhatsApp +212 620 002 066"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Demande à 2 collègues : 'En 5 secondes sur mon profil, tu comprends ce que je fais ?' → si non, retravaille le titre + À propos."},

  {"type":"heading2","text":"2. RECHERCHE CIBLÉE DE PROSPECTS"},
  {"type":"paragraph","text":"🎯 Objectif : identifier 20 prospects qualifiés par secteur + zone géographique. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"🖥️ OÙ : https://www.linkedin.com/search/results/people/"},
  {"type":"numbered","items":[
    "Va sur LinkedIn → barre de recherche en haut → tape un mot-clé secteur (ex : 'restaurant', 'avocat', 'dentiste', 'pharmacie', 'directeur école').",
    "Clique sur l'onglet 'Personnes'.",
    "Filtre 'Lieu' → tape 'Oujda' puis sélectionne 'Oujda, Maroc'.",
    "Filtre 'Relations' → coche '2e' et '3e+' (1er = déjà connecté).",
    "Filtre 'Secteur' si pertinent (ex : 'Restauration', 'Cabinets médicaux').",
    "Tu obtiens une liste de 50-200 résultats → ouvre les 20 premiers profils dans des onglets séparés.",
    "Pour chaque profil : vérifie poste (décideur ? gérant ? directeur ?), activité récente (post < 30 jours = compte actif), photo (compte réel ?).",
    "Ajoute les 20 prospects qualifiés dans GestiQ → source = 'LinkedIn' + lien profil dans Notes."
  ]},
  {"type":"paragraph","text":"✏️ PROFILS À CIBLER EN PRIORITÉ :"},
  {"type":"list","items":[
    "**Gérant / Propriétaire** d'un commerce local Oujda (décideur direct)",
    "**Directeur marketing** d'une PME (budget + besoin)",
    "**CEO / Founder** d'une startup Oujda (cible parfaite)",
    "**Médecin / Avocat / Architecte** indépendant (libéral = décideur)",
    "**Directeur école / formation** (besoin site + visibilité)"
  ]},
  {"type":"callout","variant":"warning","title":"⚠️ À ÉVITER","text":"Profils sans photo (souvent faux), profils inactifs > 6 mois (perte de temps), salariés simples sans pouvoir de décision."},

  {"type":"heading2","text":"3. ENVOYER LA DEMANDE DE CONNEXION (MESSAGE 1)"},
  {"type":"paragraph","text":"🎯 Objectif : demande personnalisée acceptée par le prospect. ⏱️ Temps : 2 min par demande."},
  {"type":"paragraph","text":"📍 Point de départ : profil du prospect ouvert."},
  {"type":"numbered","items":[
    "Sur le profil prospect → clique 'Se connecter' (bouton bleu en haut).",
    "POPUP : choisis 'Ajouter une note' (PAS 'Envoyer sans note' = -70% acceptation).",
    "Rédige la note (max 300 caractères) en suivant la structure ci-dessous.",
    "Envoie.",
    "Note dans GestiQ : statut prospect = 'Invitation envoyée' + date."
  ]},
  {"type":"paragraph","text":"✏️ STRUCTURE NOTE DE CONNEXION (300 caractères max) :"},
  {"type":"list","items":[
    "**Bonjour [Prénom]** → toujours le prénom",
    "**Raison personnalisée** → 'Je vois qu'on est tous les deux dans le digital à Oujda' / 'J'ai vu votre poste sur [sujet]'",
    "**Demande légère** → 'Je serais ravi d'échanger avec vous'",
    "**Signature courte** → 'Saïd, Next Gital'"
  ]},
  {"type":"template","text":"Bonjour Dr. Karim 👋\n\nJe vois qu'on partage l'écosystème santé/digital à Oujda. Chez Next Gital on accompagne plusieurs cabinets de la ville sur leur visibilité en ligne.\n\nRavi d'échanger avec vous !\n\nSaïd"},
  {"type":"template","text":"Bonjour [Prénom],\n\nJe suis Saïd, agence digitale à Oujda (Next Gital). Votre profil de [poste] m'a interpellé — j'aimerais beaucoup étendre mon réseau aux décideurs locaux.\n\nAu plaisir d'échanger,\nSaïd"},
  {"type":"callout","variant":"danger","title":"🚫 INTERDIT DANS LA NOTE","text":"JAMAIS de pitch commercial dans la note de connexion ('Je vous propose un site web' = refus garanti). JAMAIS de liens. JAMAIS 'merci d'accepter'."},

  {"type":"heading2","text":"4. ATTENDRE 24-48H + ENVOYER MESSAGE 2 (INTRO)"},
  {"type":"paragraph","text":"🎯 Objectif : briser la glace SANS vendre, créer le contexte. ⏱️ Temps : 3 min par message."},
  {"type":"paragraph","text":"📍 Point de départ : notification 'X a accepté votre invitation'."},
  {"type":"numbered","items":[
    "Attends MINIMUM 24h après acceptation (ne JAMAIS envoyer immédiatement = robotique).",
    "Idéal : 48h après acceptation.",
    "Ouvre la conversation LinkedIn avec le prospect.",
    "Envoie le message 2 : remercie + question ouverte sur SON activité.",
    "Note dans GestiQ : statut = 'Connecté + Msg 2 envoyé'."
  ]},
  {"type":"template","text":"Merci pour la connexion [Prénom] 🙏\n\nJ'ai parcouru votre profil — [observation concrète sur leur activité, ex : 'votre clinique a une super réputation sur Google'].\n\nUne question : qu'est-ce qui marche le mieux aujourd'hui pour attirer de nouveaux clients dans votre activité ? Le bouche-à-oreille, le digital, autre ?\n\nCurieux d'avoir votre vision 😊\n\nSaïd"},
  {"type":"callout","variant":"tip","title":"💡 Pourquoi cette approche","text":"Une question ouverte sur LEUR business génère 60% de réponses. Un pitch direct : 5%."},

  {"type":"heading2","text":"5. MESSAGE 3 (PROPOSITION DE RDV)"},
  {"type":"paragraph","text":"🎯 Objectif : transformer la conversation en RDV Calendly. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : le prospect a répondu au message 2."},
  {"type":"numbered","items":[
    "Réponds dans les 2h à sa réponse (montre engagement).",
    "Rebondis sur ce qu'il a dit (preuve d'écoute).",
    "Apporte une mini-valeur (conseil, stat, exemple).",
    "Propose le RDV (lien Calendly).",
    "Statut GestiQ = 'En négociation' ou 'RDV pris' selon réponse."
  ]},
  {"type":"template","text":"Très intéressant [Prénom] !\n\nVous avez raison, le bouche-à-oreille fonctionne bien à Oujda mais ça plafonne — c'est exactement le constat qu'on fait avec nos clients. Le digital permet justement de DÉMULTIPLIER ce bouche-à-oreille (avis Google, visibilité locale, etc).\n\nÇa vous dirait qu'on en discute 15 min ? Je peux vous montrer 2-3 leviers concrets pour votre activité. Voici mon agenda : https://calendly.com/nextgital/15min\n\nSaïd"},

  {"type":"heading2","text":"6. PUBLIER 1 POST LINKEDIN (TOUS LES 2 JOURS)"},
  {"type":"paragraph","text":"🎯 Objectif : crédibilité + génération inbound. ⏱️ Temps : 20 min."},
  {"type":"paragraph","text":"🖥️ OÙ : https://www.linkedin.com/feed/ → bouton 'Commencer un post'."},
  {"type":"numbered","items":[
    "Choisis un sujet (résultat client anonymisé, tip web, observation marché Oujda).",
    "Rédige 5-8 lignes maximum (pas de pavé).",
    "Phrase d'accroche en 1ère ligne (hook).",
    "Ajoute 1 image OU 1 carrousel (pas que du texte).",
    "Termine par une question (engagement).",
    "Publie aux heures de pic : 11h ou 18h.",
    "Réponds à TOUS les commentaires dans les 2h."
  ]},
  {"type":"template","text":"📊 Cas client : un cabinet dentaire d'Oujda a doublé ses nouveaux patients en 4 mois.\n\nCe qu'on a changé :\n→ Site mobile rapide (2 sec de chargement)\n→ Fiche Google My Business optimisée\n→ Système de rappel par SMS\n\nRésultat : 18 → 42 nouveaux patients/mois.\n\nVous diriez quoi de plus impactant pour un cabinet médical aujourd'hui ?\n\n#Oujda #DigitalSanté #SiteWeb"},

  {"type":"heading2","text":"7. CLÔTURE DE JOURNÉE + REPORTING"},
  {"type":"paragraph","text":"🎯 Objectif : suivi des KPI LinkedIn. ⏱️ Temps : 10 min."},
  {"type":"numbered","items":[
    "Compte les invitations envoyées (max 20).",
    "Compte les acceptations reçues (objectif 50% = 10).",
    "Compte les messages 2 envoyés aux nouveaux connectés.",
    "Compte les RDV obtenus.",
    "Note dans Slack #prospection : '17/05 LinkedIn — 20 inv / 11 accept / 5 msg2 / 1 RDV'."
  ]},

  {"type":"divider"},
  {"type":"heading2","text":"Templates de messages prêts à l'emploi"},
  {"type":"template","text":"NOTE CONNEXION — Décideur Oujda\n\nBonjour [Prénom],\n\nNos parcours se croisent dans l'écosystème business d'Oujda — je serais ravi d'étendre mon réseau aux entrepreneurs de la ville. Au plaisir d'échanger !\n\nSaïd, Next Gital"},
  {"type":"template","text":"MESSAGE 2 — Brise-glace\n\nMerci pour la connexion [Prénom] !\n\nJ'ai jeté un œil à votre profil — [observation]. Une question qui m'intéresse : comment vous attirez vos clients aujourd'hui ?\n\nSaïd"},
  {"type":"template","text":"MESSAGE 3 — RDV\n\n[Réaction à sa réponse]. Ça me parle.\n\nOn pourrait en discuter 15 min ? Je vous partage notre approche pour [secteur] à Oujda. Mon agenda : https://calendly.com/nextgital/15min\n\nSaïd"},

  {"type":"divider"},
  {"type":"heading2","text":"Checklist de validation fin de journée"},
  {"type":"checklist","items":[
    "Profil LinkedIn vérifié optimisé (titre + bannière + À propos)",
    "20 invitations envoyées (toutes avec note personnalisée)",
    "Messages 2 envoyés aux nouvelles acceptations (J+2)",
    "Messages 3 (RDV) envoyés aux conversations engagées",
    "Tous les prospects ajoutés dans GestiQ avec lien profil + statut",
    "Réponses traitées dans les 2h",
    "Post LinkedIn publié (si jour pair)",
    "Rapport posté dans Slack #prospection"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Restriction LinkedIn (compte limité) → STOP immédiat + WhatsApp Saïd +212 620 002 066. Prospect très intéressé demande tarif → ne pas improviser, demande à Saïd avant de répondre."}
]$sop$::jsonb,
    read_min = 11,
    updated_at = now()
WHERE slug IN ('ng-pr-linkedin','ng-prospect-linkedin');


-- ────────────────────────────────────────────────────────────────────
--  3/7  TERRAIN OUJDA  (ng-pr-terrain-oujda + ng-prospect-terrain)
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏱️ Délai d'exécution","text":"Cette SOP couvre 1 demi-journée de prospection terrain. Durée : 4h (préparation 1h + terrain 3h). À faire entre 9h-12h ou 14h-17h (commerces ouverts, décideurs présents)."},
  {"type":"callout","variant":"info","title":"📍 Zone","text":"Oujda — axes prioritaires : Bd Mohammed V, Bd Allal Ben Abdallah, Quartier Sidi Maâfa, Place du 16 août. Bureau Next Gital : Bureau N°7 Immeuble Kissi."},
  {"type":"callout","variant":"tip","title":"🎯 Objectif demi-journée","text":"10 visites en porte-à-porte → 3 décideurs rencontrés → 2 cartes de visite échangées → 1 RDV pris."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"JAMAIS de tenue débraillée (chemise propre minimum). JAMAIS de pitch > 90 sec. JAMAIS insister si refus clair."},

  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. PRÉPARATION VEILLE (LISTE 10 PROSPECTS + ITINÉRAIRE)"},
  {"type":"paragraph","text":"🎯 Objectif : avoir 10 prospects géolocalisés dans un rayon de 1 km. ⏱️ Temps : 45 min."},
  {"type":"paragraph","text":"🖥️ OÙ : Google Maps (https://maps.google.com) + GestiQ + Google My Maps."},
  {"type":"numbered","items":[
    "Choisis 1 axe prioritaire (Bd Mohammed V OU Bd Allal Ben Abdallah).",
    "Sur Google Maps : tape '[secteur] [axe choisi] Oujda' (ex : 'restaurant Boulevard Mohammed V Oujda').",
    "Liste 10 commerces visibles, varie les secteurs (3 restos, 2 cabinets médicaux, 2 boutiques mode, 1 pharmacie, 1 école, 1 garage).",
    "Pour chacun : vérifie horaires d'ouverture aujourd'hui + site web (oui/non).",
    "Crée un itinéraire optimisé sur Google My Maps (gain de temps : 2h de marche au lieu de 4h).",
    "Ajoute les 10 prospects dans GestiQ avec statut 'À visiter' + adresse exacte.",
    "Imprime la liste papier OU charge-la sur ton téléphone (mode hors-ligne)."
  ]},
  {"type":"paragraph","text":"✏️ INFOS À NOTER PAR PROSPECT :"},
  {"type":"list","items":[
    "**Nom commerce + adresse exacte** (numéro + boulevard)",
    "**Secteur** (restaurant / médical / mode / etc.)",
    "**Note Google** (★) et nombre d'avis",
    "**Site web** (oui/non + URL si oui)",
    "**Heures d'ouverture aujourd'hui**",
    "**Observation** (ex : 'Vitrine refaite récemment', 'File d'attente le midi = business actif')"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"10 prospects géolocalisés sur Google My Maps, fiche imprimée ou sur téléphone, itinéraire de 2-3 km maximum."},

  {"type":"heading2","text":"2. ÉQUIPEMENT À EMPORTER"},
  {"type":"paragraph","text":"🎯 Objectif : être 100% pro et autonome sur le terrain. ⏱️ Temps : 10 min de préparation."},
  {"type":"paragraph","text":"✏️ CHECKLIST MATÉRIEL :"},
  {"type":"checklist","items":[
    "30 cartes de visite Next Gital (à demander à Saïd si vide)",
    "5 plaquettes A5 Next Gital (offre + QR code calendly)",
    "Téléphone chargé 100% avec GestiQ + Google Maps + WhatsApp",
    "Batterie externe (10 000 mAh minimum)",
    "Tablette OU smartphone pour démo rapide (site nextgital.tech)",
    "Bloc-notes + stylo (pour prendre notes sans dégainer le tel)",
    "Bouteille d'eau",
    "Tenue : chemise + pantalon propre + chaussures cirées (PAS de jean troué, PAS de t-shirt)",
    "Badge Next Gital (si dispo)"
  ]},

  {"type":"heading2","text":"3. ARRIVER DEVANT LE PROSPECT — OBSERVATION 2 MIN"},
  {"type":"paragraph","text":"🎯 Objectif : repérer 1 détail concret à mentionner dans le pitch. ⏱️ Temps : 2 min."},
  {"type":"numbered","items":[
    "Arrive devant le commerce, NE RENTRE PAS TOUT DE SUITE.",
    "Reste 2 min à observer : déco vitrine, affluence, présence patron, type de clientèle.",
    "Note 1 détail concret à utiliser (ex : 'Vitrine refaite, mais aucun QR code menu', 'Patron visible derrière la caisse', 'Affiche promo manuscrite = pas de support pro').",
    "Vérifie : commerce ouvert ? affluence faible (le patron a 2 min) ? Si bondé → reviens dans 30 min."
  ]},
  {"type":"callout","variant":"warning","title":"⚠️ Timing important","text":"NE JAMAIS déranger pendant rush déjeuner (12h-14h restau), pendant consultation (cabinet médical), pendant prière. Reviens plus tard."},

  {"type":"heading2","text":"4. ENTRER + DEMANDER LE DÉCIDEUR (15 SEC)"},
  {"type":"paragraph","text":"🎯 Objectif : parler au patron, pas au caissier. ⏱️ Temps : 15 sec."},
  {"type":"numbered","items":[
    "Entre, souris, salue (Bonjour / Salam aleikoum selon contexte).",
    "Vers la première personne accueillante : 'Bonjour, est-ce que le responsable est disponible 2 minutes ?'",
    "Si on demande pourquoi : 'C'est pour [nom commerce], je passe en voisin présenter Next Gital — 2 minutes pas plus, c'est promis 😊'",
    "Si le patron est absent : demande son prénom + meilleur horaire pour le joindre + laisse une carte de visite + note dans GestiQ 'Repasser [date/heure]'."
  ]},
  {"type":"callout","variant":"tip","title":"💡 Astuce","text":"Si la personne en face est intriguée mais pas décideuse, transmets ton pitch en lui demandant si elle peut en parler au patron — souvent, le patron rappelle dans les 24h."},

  {"type":"heading2","text":"5. PITCH PORTE-À-PORTE — 90 SECONDES CHRONO"},
  {"type":"paragraph","text":"🎯 Objectif : présenter Next Gital + accrocher avec l'observation + proposer RDV. ⏱️ Temps : 90 sec MAX."},
  {"type":"paragraph","text":"✏️ STRUCTURE PITCH 90 SEC (4 parties) :"},
  {"type":"list","items":[
    "**0-15 sec : Présentation** → 'Bonjour, je suis Saïd de Next Gital, agence digitale à Oujda — Bureau N°7 Immeuble Kissi'",
    "**15-45 sec : Observation + valeur** → 'En passant devant chez vous, j'ai remarqué [détail concret]. On accompagne plusieurs [secteur] d'Oujda à [résultat précis, ex : doubler les RDV, capter +30% de clients en ligne]'",
    "**45-75 sec : Mini-preuve** → 'Par exemple, on a refait le site de [client référence locale anonyme] — il fait maintenant +X RDV/mois'",
    "**75-90 sec : Demande douce** → 'Est-ce que ça pourrait vous intéresser qu'on en discute 15 min cette semaine ? Sans engagement.'"
  ]},
  {"type":"template","text":"PITCH RESTAURANT (90 sec)\n\n[0-15s] Bonjour, Saïd de Next Gital, agence digitale d'Oujda — on est juste à côté Bureau N°7 Immeuble Kissi.\n\n[15-45s] J'ai vu votre devanture, c'est superbe — par contre quand on cherche votre menu en ligne on tombe sur rien. Vos voisins concurrents qui ont un site captent les clients qui décident en cherchant 'meilleur resto Oujda' sur Google le soir.\n\n[45-75s] On a refait il y a 3 mois le digital d'un resto sur la même avenue — ils sont passés de 80 à 140 couverts/jour grâce au site + Google + WhatsApp réservation.\n\n[75-90s] Si ça vous parle, on pourrait se voir 15 minutes cette semaine ? Je vous montre concrètement ce qu'on ferait. Sans engagement."},
  {"type":"callout","variant":"danger","title":"🚫 INTERDIT","text":"JAMAIS sortir un tarif au porte-à-porte ('combien ça coûte ?' → 'Je préfère vous montrer d'abord, le tarif dépend de vos besoins, on en parle en RDV'). JAMAIS parler de concurrents nominativement."},

  {"type":"heading2","text":"6. GÉRER LES 3 RÉACTIONS POSSIBLES"},
  {"type":"paragraph","text":"🎯 Objectif : transformer toutes les situations en next step. ⏱️ Temps : 2-3 min."},
  {"type":"paragraph","text":"✏️ RÉACTION 1 — INTÉRÊT :"},
  {"type":"numbered","items":[
    "Sors immédiatement ton téléphone → ouvre Calendly.",
    "Propose 2-3 créneaux cette semaine.",
    "Confirme par WhatsApp dès la sortie : 'Ravi de notre échange [Prénom], je vous confirme notre RDV du [date]'.",
    "Dans GestiQ → statut 'RDV pris'."
  ]},
  {"type":"paragraph","text":"✏️ RÉACTION 2 — INTÉRÊT MAIS PAS MAINTENANT :"},
  {"type":"numbered","items":[
    "'Pas de souci, je vous laisse ma carte. Je peux vous WhatsApper dans 2 semaines pour faire le point ?'",
    "Note WhatsApp + date relance dans GestiQ → statut 'À relancer'."
  ]},
  {"type":"paragraph","text":"✏️ RÉACTION 3 — REFUS CLAIR :"},
  {"type":"numbered","items":[
    "'Pas de souci, merci pour votre temps. Bonne continuation !'",
    "Laisse la carte SANS insister.",
    "Dans GestiQ → statut 'Perdu' + motif (ex : 'a déjà une agence', 'pas de budget')."
  ]},

  {"type":"heading2","text":"7. NOTER IMMÉDIATEMENT EN SORTANT"},
  {"type":"paragraph","text":"🎯 Objectif : tout traçer avant d'oublier (mémoire = 50% perdue après 1h). ⏱️ Temps : 3 min par visite."},
  {"type":"numbered","items":[
    "Sors du commerce, va à 50m.",
    "Ouvre GestiQ sur téléphone.",
    "Mets à jour le prospect : statut + notes complètes (nom décideur, ce qu'il a dit, prochaine action).",
    "Si RDV pris → bloque ton agenda immédiatement.",
    "Passe au prospect suivant."
  ]},

  {"type":"heading2","text":"8. CLÔTURE DE JOURNÉE + DEBRIEF"},
  {"type":"paragraph","text":"🎯 Objectif : analyser ce qui marche pour ajuster. ⏱️ Temps : 15 min."},
  {"type":"numbered","items":[
    "Retour au bureau (ou à la maison).",
    "Compte : 10 visites tentées / X décideurs vus / X cartes laissées / X RDV pris.",
    "Note dans Slack #prospection : '17/05 Terrain Bd Mohammed V — 10 visites / 4 décideurs / 1 RDV'.",
    "Note 1 phrase d'apprentissage : ce qui a marché / ce qui a bloqué.",
    "Recharge les cartes de visite pour demain."
  ]},

  {"type":"divider"},
  {"type":"heading2","text":"Templates de messages prêts à l'emploi"},
  {"type":"template","text":"WHATSAPP CONFIRMATION RDV (après terrain)\n\nBonjour [Prénom] 👋\n\nRavi de notre échange tout à l'heure dans votre [type commerce]. Je vous confirme notre RDV de [jour] à [heure] dans vos locaux.\n\nJe vous apporte 2-3 exemples concrets de ce qu'on a fait pour d'autres [secteur] d'Oujda.\n\nÀ très vite,\nSaïd · Next Gital · +212 620 002 066"},
  {"type":"template","text":"WHATSAPP RELANCE (prospect 'plus tard')\n\nBonjour [Prénom],\n\nSaïd de Next Gital — on s'était croisés il y a 2 semaines dans votre [commerce]. Vous m'aviez dit qu'on pourrait se reparler.\n\nÇa vous va si on cale 15 min cette semaine ? Voici mon agenda : https://calendly.com/nextgital/15min\n\nSaïd"},
  {"type":"template","text":"PITCH MÉDICAL (90 sec)\n\n[0-15s] Bonjour Docteur, Saïd de Next Gital, agence digitale Oujda.\n\n[15-45s] Je sais que vous êtes pris — 2 minutes promis. J'ai cherché votre cabinet sur Google : vous êtes en page 3, vos confrères en page 1 captent 80% des nouveaux patients.\n\n[45-75s] On a accompagné le Dr [client] qui est passé de 15 à 35 nouveaux patients/mois en 3 mois.\n\n[75-90s] Vous auriez 15 min cette semaine pour voir comment on pourrait faire pareil ?"},

  {"type":"divider"},
  {"type":"heading2","text":"Checklist de validation fin de demi-journée"},
  {"type":"checklist","items":[
    "10 prospects géolocalisés visités (ou tentés)",
    "Pitch 90 sec respecté à chaque fois (chrono mental)",
    "Toutes les visites tracées dans GestiQ (statut + notes)",
    "RDV pris bloqués dans Calendly + WhatsApp confirmation envoyé",
    "Cartes de visite laissées chez tous les prospects rencontrés",
    "Relances WhatsApp programmées pour 'À relancer'",
    "Rapport posté dans Slack #prospection"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Prospect demande tarif précis sur place → 'Ça dépend, on calcule en RDV' + WhatsApp Saïd +212 620 002 066. Incident terrain (agression verbale, refus brutal multiple) → STOP + appel Saïd. Si bloqué > 30 min sans avancer → recale ton itinéraire et appelle Saïd."}
]$sop$::jsonb,
    read_min = 12,
    updated_at = now()
WHERE slug IN ('ng-pr-terrain-oujda','ng-prospect-terrain');


-- ────────────────────────────────────────────────────────────────────
--  4/7  PARTENARIATS  (ng-pr-partenariats + ng-prospect-partenariats)
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏱️ Délai d'exécution","text":"Cette SOP couvre 1 cycle complet de mise en place d'un partenaire apporteur d'affaires. Durée : 2 semaines (identification → RDV → contrat → premier deal)."},
  {"type":"callout","variant":"info","title":"🤝 Cibles partenaires","text":"Professions qui rencontrent des décideurs sans concurrencer Next Gital : comptables, designers graphiques freelance, imprimeurs, agences immobilières, courtiers en assurance, photographes pro, consultants RH."},
  {"type":"callout","variant":"tip","title":"🎯 Objectif mensuel","text":"5 partenaires actifs → 10 leads qualifiés/mois → 3 signatures/mois. Commission : 10-15% du contrat signé (selon volume)."},
  {"type":"callout","variant":"danger","title":"🚫 Règle","text":"JAMAIS de commission > 15% sans validation Saïd. JAMAIS de contrat verbal — toujours signé."},

  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. IDENTIFIER 10 PARTENAIRES POTENTIELS"},
  {"type":"paragraph","text":"🎯 Objectif : liste de 10 professionnels Oujda qui rencontrent quotidiennement des décideurs PME. ⏱️ Temps : 1h."},
  {"type":"paragraph","text":"🖥️ OÙ : Google Maps + LinkedIn + Pages Jaunes Maroc."},
  {"type":"numbered","items":[
    "Sur Google Maps : tape successivement 'comptable Oujda', 'imprimeur Oujda', 'designer graphique Oujda', 'agence immobilière Oujda', 'photographe pro Oujda'.",
    "Note les 2-3 premiers résultats de chaque secteur (note ★ ≥ 4).",
    "Pour chacun : récupère nom dirigeant via LinkedIn (search '[nom entreprise] Oujda').",
    "Vérifie qu'ils ne sont PAS déjà partenaires (GestiQ → onglet Partenaires).",
    "Ajoute dans GestiQ → onglet Partenaires → statut 'Identifié' avec : nom entreprise + nom dirigeant + téléphone + secteur + raison du choix."
  ]},
  {"type":"paragraph","text":"✏️ TOP 7 SECTEURS PARTENAIRES :"},
  {"type":"list","items":[
    "**Comptables / Experts-comptables** → voient tous leurs clients qui se digitalisent",
    "**Imprimeurs** → clients qui font cartes/flyers ont souvent besoin de site",
    "**Designers graphiques freelance** → font logo/branding mais pas dev web",
    "**Agences immobilières** → réseau de commerçants/promoteurs",
    "**Photographes pro** → font photos produits, leurs clients vendent en ligne",
    "**Courtiers assurance** → portefeuille PME à digitaliser",
    "**Architectes / Bureaux d'études** → projets pro qui finissent en site vitrine"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"10 partenaires potentiels dans GestiQ, tous avec contact direct du dirigeant (pas standard)."},

  {"type":"heading2","text":"2. PRENDRE RDV (APPROCHE PARTENAIRE = DIFFÉRENTE)"},
  {"type":"paragraph","text":"🎯 Objectif : RDV de 30 min en présentiel ou visio. ⏱️ Temps : 5 min par contact."},
  {"type":"paragraph","text":"📍 Différence majeure : ce n'est PAS un pitch commercial, c'est une proposition gagnant-gagnant."},
  {"type":"numbered","items":[
    "Appelle directement (LinkedIn message si pas de tél direct).",
    "Présente-toi en mentionnant la COMPLÉMENTARITÉ (pas la vente).",
    "Demande 30 min en présentiel (de préférence dans leur bureau).",
    "Note RDV dans Calendly + GestiQ → statut 'RDV partenaire pris'."
  ]},
  {"type":"template","text":"APPEL TÉLÉPHONIQUE\n\nBonjour [Prénom], Saïd de Next Gital — agence digitale à Oujda Bureau N°7 Immeuble Kissi.\n\nJe vous appelle pour une raison simple : nos métiers sont complémentaires (vous faites [comptabilité/impression/etc.], on fait du web). Plusieurs de nos clients pourraient avoir besoin de vous, et inversement.\n\nJe vous propose qu'on se voit 30 min cette semaine pour voir comment on pourrait s'apporter des clients mutuellement. Ça vous parle ?"},
  {"type":"template","text":"MESSAGE LINKEDIN PARTENAIRE\n\nBonjour [Prénom],\n\nNos métiers se croisent souvent à Oujda : vous accompagnez les PME en [domaine], nous on les digitalise (sites web, SEO, contenu).\n\nJe propose qu'on échange 30 min pour structurer un apport d'affaires mutuel — gagnant pour tout le monde. Vous êtes dispo cette semaine ?\n\nSaïd · Next Gital · +212 620 002 066"},

  {"type":"heading2","text":"3. RDV PARTENAIRE — DÉROULÉ 30 MIN"},
  {"type":"paragraph","text":"🎯 Objectif : signer un accord d'apporteur d'affaires structuré. ⏱️ Temps : 30 min RDV."},
  {"type":"paragraph","text":"✏️ STRUCTURE RDV (5 phases) :"},
  {"type":"list","items":[
    "**0-5 min : Brise-glace + présentation Next Gital** → 1 minute speech : qui on est, ce qu'on fait, références locales Oujda",
    "**5-15 min : Découverte de leur business** → écoute : combien de clients/mois ? quels secteurs ? quels besoins digitaux ils expriment ?",
    "**15-22 min : Proposition gagnant-gagnant** → 'On vous rémunère 10% du contrat signé pour tout client que vous nous présentez. Inversement, dès qu'un de nos clients a besoin de [leur service], on vous présente'",
    "**22-27 min : Modalités** → contrat simple 1 page, commission payée à l'encaissement client, tracking partagé via GestiQ partenaires",
    "**27-30 min : Closing** → 'On démarre ? Je vous envoie le contrat ce soir, signature électronique demain'"
  ]},
  {"type":"callout","variant":"warning","title":"⚠️ Erreurs à éviter en RDV","text":"NE PAS parler que de Next Gital pendant 25 min (mauvais). NE PAS promettre commission > 15% (validé case par case avec Saïd). NE PAS partir sans next step concret."},

  {"type":"heading2","text":"4. ENVOYER LE CONTRAT D'APPORTEUR (J+0)"},
  {"type":"paragraph","text":"🎯 Objectif : contrat signé dans les 48h après RDV. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"🖥️ OÙ : modèle contrat dans Google Drive Next Gital → /Partenariats/Modeles/Contrat-Apporteur-v3.docx"},
  {"type":"numbered","items":[
    "Ouvre le template contrat (Google Drive).",
    "Remplis les champs : nom partenaire, raison sociale, % commission, modalités de paiement, durée (1 an renouvelable).",
    "Vérifie 2 fois : nom correct, % correct (10% par défaut, 15% si gros volume validé par Saïd).",
    "Exporte en PDF.",
    "Envoie via mail (info@nextgital.com en copie) avec WhatsApp en rappel.",
    "Statut GestiQ → 'Contrat envoyé'."
  ]},
  {"type":"template","text":"MAIL ENVOI CONTRAT\n\nObjet : Notre partenariat — contrat à signer\n\nBonjour [Prénom],\n\nRavi de notre échange de ce matin. Comme convenu, voici le contrat d'apporteur d'affaires en pièce jointe.\n\nLes points clés :\n→ Commission 10% du contrat signé\n→ Paiement à 30 jours après encaissement client\n→ Tracking transparent via espace partenaire GestiQ\n→ Durée 12 mois, reconduction tacite\n\nSi tout vous convient : signature électronique en 2 clics via le lien ci-dessous.\nDès signature, on vous envoie vos accès à l'espace partenaire.\n\nÀ très vite,\nSaïd · Next Gital · +212 620 002 066"},

  {"type":"heading2","text":"5. ONBOARDING PARTENAIRE (APRÈS SIGNATURE)"},
  {"type":"paragraph","text":"🎯 Objectif : partenaire opérationnel + lui faciliter l'envoi de leads. ⏱️ Temps : 1h."},
  {"type":"numbered","items":[
    "Créer compte partenaire dans GestiQ → onglet Partenaires → 'Activer accès'.",
    "Envoyer ses identifiants par mail sécurisé.",
    "Lui envoyer le kit partenaire (pack PDF dans /Partenariats/Kit/) : présentation Next Gital, brochure tarifs publics, formulaire d'envoi de lead, FAQ.",
    "Programmer un call de 15 min de formation à GestiQ (comment envoyer un lead).",
    "L'ajouter sur WhatsApp groupe 'Partenaires Next Gital'.",
    "Lui envoyer 1er cadeau de bienvenue (mug Next Gital ou bon café Bd Mohammed V)."
  ]},

  {"type":"heading2","text":"6. SUIVI MENSUEL DES PARTENAIRES"},
  {"type":"paragraph","text":"🎯 Objectif : maintenir la relation + relancer les inactifs. ⏱️ Temps : 30 min/semaine."},
  {"type":"numbered","items":[
    "Chaque lundi : ouvre GestiQ → Partenaires → tri par 'Dernier lead envoyé'.",
    "Partenaire sans lead depuis > 30 jours → WhatsApp léger : 'Bonjour [Prénom], comment vous allez ? Pas de news ces dernières semaines, tout va bien ?'",
    "Partenaire actif → message de remerciement + bilan commissions versées : 'Vous avez généré 8 leads ce mois, 2 signatures, soit X MAD de commission versée. Merci !'",
    "Une fois par trimestre : déjeuner partenaire (budget 200 MAD).",
    "Une fois par an : événement partenaires Next Gital (afterwork)."
  ]},

  {"type":"heading2","text":"7. PAIEMENT DES COMMISSIONS"},
  {"type":"paragraph","text":"🎯 Objectif : aucun retard de paiement = confiance maximale. ⏱️ Temps : 1h/mois."},
  {"type":"numbered","items":[
    "Le 1er de chaque mois : ouvre GestiQ → Rapport commissions du mois précédent.",
    "Liste des partenaires + montants dus (basé sur encaissements clients).",
    "Génère factures commissions (template Drive).",
    "Demande validation Saïd avant virement.",
    "Effectue les virements bancaires.",
    "Envoie WhatsApp à chaque partenaire : 'Commission [montant] virée aujourd'hui, voici le justificatif'."
  ]},
  {"type":"callout","variant":"danger","title":"🚫 JAMAIS","text":"JAMAIS de retard > 5 jours sur paiement commission = perte partenaire immédiate + bad buzz Oujda (petit milieu)."},

  {"type":"divider"},
  {"type":"heading2","text":"Templates de messages prêts à l'emploi"},
  {"type":"template","text":"WHATSAPP FÉLICITATIONS LEAD\n\nMerci [Prénom] pour le lead 🙏\n\nOn rencontre [client lead] cette semaine. Je vous tiens au courant de l'avancée. Si on signe, commission [10%] créditée fin de mois.\n\nSaïd"},
  {"type":"template","text":"WHATSAPP RELANCE PARTENAIRE INACTIF (30j)\n\nBonjour [Prénom] 👋\n\nÇa fait un mois qu'on a pas échangé — tout va bien de votre côté ?\n\nQuelques nouvelles Next Gital : on a lancé une nouvelle offre [SEO local Oujda] qui pourrait intéresser vos clients commerçants. Je peux vous passer la plaquette si vous voulez.\n\nSaïd"},
  {"type":"template","text":"BILAN TRIMESTRIEL PARTENAIRE\n\nBonjour [Prénom],\n\nPetit bilan de notre partenariat T1 2026 :\n→ Leads envoyés : X\n→ Signatures : Y\n→ Commissions versées : Z MAD\n\nMerci pour votre confiance ! Un café cette semaine pour faire le point ?\n\nSaïd"},

  {"type":"divider"},
  {"type":"heading2","text":"Checklist de validation fin de cycle (2 semaines)"},
  {"type":"checklist","items":[
    "10 partenaires identifiés et ajoutés dans GestiQ",
    "RDV pris avec minimum 5 partenaires",
    "RDV réalisés (30 min, structure 5 phases)",
    "Contrats envoyés dans les 24h post-RDV",
    "Minimum 2 contrats signés en 2 semaines",
    "Onboarding complet réalisé (accès + kit + formation)",
    "Partenaires ajoutés sur WhatsApp groupe + suivi mensuel calé"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Partenaire demande commission > 15% → STOP, valide avec Saïd avant de répondre. Litige paiement → STOP, transfère à Saïd. Partenaire qui se plaint d'un délai > 7 jours → réponds vite + WhatsApp Saïd +212 620 002 066."}
]$sop$::jsonb,
    read_min = 11,
    updated_at = now()
WHERE slug IN ('ng-pr-partenariats','ng-prospect-partenariats');


-- ────────────────────────────────────────────────────────────────────
--  5/7  IDENTIFIER LES PROSPECTS  (ng-prospect-identifier)
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏱️ Délai d'exécution","text":"Cette SOP détaille comment identifier 30 prospects qualifiés en 1h chrono. À répéter chaque matin avant les sessions de prospection (WhatsApp / LinkedIn / Terrain)."},
  {"type":"callout","variant":"info","title":"🔍 Source principale","text":"Google Maps (https://maps.google.com) + Facebook Business + Pages Jaunes Maroc (pj.ma). Zone : Oujda + périphérie (Ahfir, Berkane si demandé)."},
  {"type":"callout","variant":"tip","title":"🎯 Objectif","text":"30 prospects qualifiés/jour, tous notés 3/5 minimum (idéal 5/5 = pas de site OU site cassé)."},
  {"type":"callout","variant":"danger","title":"🚫 Règle","text":"JAMAIS qualifier un prospect sans avoir vérifié : présence Google, site web (ou absence), numéro WhatsApp valide. Sinon perte de temps en aval."},

  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. CHOISIR LE SECTEUR DU JOUR"},
  {"type":"paragraph","text":"🎯 Objectif : focaliser sur 1 secteur = pitch ultra-affûté. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Roulement hebdomadaire suggéré :"},
  {"type":"list","items":[
    "**Lundi** → Restaurants + cafés Oujda",
    "**Mardi** → Cabinets médicaux (dentistes, médecins généralistes, kinés)",
    "**Mercredi** → Commerces mode + beauté (salons, boutiques)",
    "**Jeudi** → Services pro (avocats, comptables, architectes)",
    "**Vendredi** → Éducation + formation (écoles privées, centres de formation)"
  ]},
  {"type":"paragraph","text":"✏️ POURQUOI 1 SECTEUR/JOUR :"},
  {"type":"list","items":[
    "Pitch identique = répétition = maîtrise",
    "Bench rapide entre concurrents = arguments précis",
    "Cas client référence du jour = preuve sociale ciblée",
    "Taux de conversion +30% vs prospection mixte"
  ]},

  {"type":"heading2","text":"2. RECHERCHE GOOGLE MAPS — EXTRACTION 10 RÉSULTATS"},
  {"type":"paragraph","text":"🎯 Objectif : extraire 10 résultats par secteur dans Oujda. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"🖥️ OÙ : https://maps.google.com"},
  {"type":"numbered","items":[
    "Tape '[secteur du jour] Oujda' (ex : 'dentiste Oujda').",
    "Maps affiche la liste à gauche + carte à droite.",
    "Pour les 10 premiers résultats : clique sur chaque fiche.",
    "Sur chaque fiche, note : nom, adresse, téléphone, note Google (★), nombre d'avis, site web (s'il y en a un, clique pour vérifier qu'il fonctionne).",
    "Capture d'écran ou note dans un tableur Google Sheets éphémère : nom | tél | site | note | nbr avis."
  ]},
  {"type":"callout","variant":"tip","title":"💡 Astuce de recherche","text":"Varie les requêtes pour ne pas tomber toujours sur les mêmes : 'dentiste Oujda' / 'cabinet dentaire Oujda' / 'orthodontiste Oujda' / 'dentiste Bd Mohammed V' / 'dentiste Sidi Maâfa'."},

  {"type":"heading2","text":"3. SCORING DES PROSPECTS (1-5)"},
  {"type":"paragraph","text":"🎯 Objectif : prioriser les cibles à fort potentiel. ⏱️ Temps : 10 min pour les 10."},
  {"type":"paragraph","text":"✏️ GRILLE DE SCORING :"},
  {"type":"table","text":"Score | Critères | Action\n5/5 | Pas de site OU site cassé + ★ ≥ 4 + ≥ 30 avis Google | Top priorité, contacter aujourd'hui\n4/5 | Site obsolète (vieux design, pas mobile) + business actif | Priorité haute, cette semaine\n3/5 | Site correct mais pas optimisé conversion / SEO faible | Priorité moyenne, ce mois-ci\n2/5 | Site OK + activité moyenne | Bas de pile\n1/5 | Site moderne récent + agence déjà active | À éliminer"},
  {"type":"paragraph","text":"✏️ COMMENT DÉTECTER UN SITE 'CASSÉ' :"},
  {"type":"list","items":[
    "Site qui met > 5 sec à charger",
    "Affichage cassé sur mobile (test depuis ton téléphone)",
    "Erreur 404 ou page blanche",
    "Design clairement < 2018 (Flash, sliders datés)",
    "Pas de HTTPS (avertissement de sécurité Chrome)",
    "Numéro / horaires obsolètes ou incohérents"
  ]},

  {"type":"heading2","text":"4. VÉRIFIER LA PRÉSENCE FACEBOOK / INSTAGRAM"},
  {"type":"paragraph","text":"🎯 Objectif : enrichir la qualification avec le digital social. ⏱️ Temps : 10 min."},
  {"type":"numbered","items":[
    "Sur Facebook → barre de recherche → tape le nom du commerce.",
    "Vérifie : page existe ? Dernière publication < 30 jours ? Nombre d'abonnés ?",
    "Pareil sur Instagram (instagram.com).",
    "Note dans tableur : FB oui/non + activité, IG oui/non + activité.",
    "Si pas de FB/IG + pas de site = score 5/5 boosté = PROSPECT EN OR."
  ]},
  {"type":"callout","variant":"tip","title":"💡 Argument-clé","text":"Si tu trouves un commerce avec 0 présence digitale + 50 avis Google 4★+ : c'est un commerce qui CARTONNE en offline mais qui rate ÉNORMÉMENT de clients online. Pitch parfait."},

  {"type":"heading2","text":"5. AJOUTER LES 10 DANS GESTIQ"},
  {"type":"paragraph","text":"🎯 Objectif : tous les prospects centralisés et trackables. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"🖥️ OÙ : https://gestiq.nextgital.tech/prospects/new"},
  {"type":"numbered","items":[
    "Pour chaque prospect : clique '+ Nouveau prospect'.",
    "Remplis tous les champs obligatoires : nom commerce, nom décideur (si trouvé), téléphone WhatsApp (format +212 6XX XXX XXX), email (si trouvé), adresse.",
    "Champ Secteur → sélectionne dans la liste déroulante.",
    "Champ Source → 'Google Maps' (ou 'Facebook', 'Recommandation', etc.).",
    "Champ Score → 1 à 5.",
    "Champ Observation → 1 phrase concrète qui justifie le score (ex : 'Pas de site, 80 avis Google 4.7★, vitrine premium').",
    "Champ Statut → 'À contacter' par défaut.",
    "Enregistre."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"10 prospects ajoutés en 15 min. Tous avec téléphone valide + observation. Filtre GestiQ 'À contacter' → 10 nouvelles lignes du jour."},

  {"type":"heading2","text":"6. RÉPÉTER POUR ATTEINDRE 30"},
  {"type":"paragraph","text":"🎯 Objectif : 30 prospects qualifiés en pipeline pour la journée. ⏱️ Temps : 30 min (2x étape 2-5)."},
  {"type":"numbered","items":[
    "Répète les étapes 2 à 5 avec des requêtes Google Maps complémentaires.",
    "Si tu épuises le secteur principal : élargis géographiquement (Bd Mohammed V → Bd Allal Ben Abdallah → Sidi Maâfa → Ahfir si manque).",
    "Vérifie pas de doublon avec GestiQ existant (la barre rouge t'avertit)."
  ]},

  {"type":"heading2","text":"7. EXPORTER LA LISTE DU JOUR"},
  {"type":"paragraph","text":"🎯 Objectif : avoir une vue claire pour les sessions WhatsApp/LinkedIn/Terrain. ⏱️ Temps : 5 min."},
  {"type":"numbered","items":[
    "Dans GestiQ : filtre 'Date ajout = aujourd'hui' + 'Statut = À contacter'.",
    "Bouton 'Exporter CSV' → télécharge la liste.",
    "Imprime ou garde ouverte pendant la session de prospection."
  ]},

  {"type":"divider"},
  {"type":"heading2","text":"Sources complémentaires"},
  {"type":"list","items":[
    "**Pages Jaunes Maroc** (pj.ma) → annuaire complet professionnels par ville",
    "**Annonces Avito / Marketplace Facebook** → commerçants qui vendent en ligne mais sans site pro",
    "**Pages 'Suivis' des concurrents** sur Facebook → cibles potentielles déjà digitalement actives",
    "**LinkedIn Sales Navigator** (si abonnement) → filtres ultra-précis par taille entreprise + poste",
    "**Salons / Forums Oujda** → fichier exposants téléchargeable souvent en PDF"
  ]},

  {"type":"divider"},
  {"type":"heading2","text":"Templates d'observations qualifiantes"},
  {"type":"template","text":"OBS 1 : 'Pas de site web — 4,7★ / 120 avis Google. Vitrine refaite récemment Bd Mohammed V. Prospect 5/5.'"},
  {"type":"template","text":"OBS 2 : 'Site existant mais pas mobile (test iPhone : illisible), pas HTTPS. Facebook actif 3500 abonnés. Prospect 4/5.'"},
  {"type":"template","text":"OBS 3 : 'Page Facebook 1200 abonnés, dernière publication il y a 8 mois. Pas de site. Numéro WhatsApp visible sur photo de profil. Prospect 5/5.'"},

  {"type":"divider"},
  {"type":"heading2","text":"Checklist de validation fin de session"},
  {"type":"checklist","items":[
    "Secteur du jour choisi et focus respecté",
    "30 prospects qualifiés en pipeline (score ≥ 3)",
    "Toutes les fiches GestiQ remplies (nom + tél + obs + score)",
    "Pas de doublon avec base existante",
    "Liste exportée et prête pour session WhatsApp / LinkedIn / Terrain",
    "Top 3 prospects 5/5 mis en évidence pour traitement prioritaire"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Manque de prospects qualifiés > 20 (secteur saturé Oujda) → demande à Saïd de valider un nouveau secteur OU une nouvelle ville (Berkane, Ahfir). Doute sur scoring → fais valider par Saïd avant de prospecter. Bloqué > 15 min sur GestiQ → WhatsApp Saïd +212 620 002 066."}
]$sop$::jsonb,
    read_min = 10,
    updated_at = now()
WHERE slug = 'ng-prospect-identifier';


-- ────────────────────────────────────────────────────────────────────
--  6/7  PIPELINE  (ng-prospect-pipeline)
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏱️ Délai d'exécution","text":"Cette SOP couvre la gestion quotidienne + hebdomadaire du pipeline de prospects dans GestiQ. Temps quotidien : 30 min (matin + soir). Temps hebdo : 1h le vendredi."},
  {"type":"callout","variant":"info","title":"🛠️ Outil","text":"GestiQ → onglet Prospects → vue Kanban (https://gestiq.nextgital.tech/prospects/kanban)."},
  {"type":"callout","variant":"tip","title":"🎯 Objectif","text":"Aucun prospect 'oublié' > 7 jours. Conversion globale ≥ 10% (sur 100 prospects contactés → 10 RDV → 3 devis → 1 signature)."},
  {"type":"callout","variant":"danger","title":"🚫 Règle","text":"JAMAIS de prospect dans un statut > 14 jours sans action (sinon = pipeline pollué). Statut 'Perdu' = définitif (sauf demande client de relance)."},

  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. COMPRENDRE LES 6 STATUTS DU PIPELINE"},
  {"type":"paragraph","text":"🎯 Objectif : savoir quel statut appliquer à chaque prospect. ⏱️ Temps : 5 min (à mémoriser une fois pour toutes)."},
  {"type":"paragraph","text":"✏️ LES 6 STATUTS :"},
  {"type":"table","text":"Statut | Définition | Durée max | Action attendue\nÀ contacter | Prospect identifié + qualifié, pas encore approché | 3 jours | Lancer 1er contact (WhatsApp / LinkedIn / Terrain)\nContacté | 1er message envoyé, en attente de réponse | 7 jours | Relance J+3 puis J+7\nRDV pris | Créneau Calendly réservé | jusqu'au RDV | Préparer RDV (recherche prospect)\nDevis envoyé | Proposition commerciale envoyée | 7 jours | Relance J+3 puis call J+7\nSigné | Contrat signé + acompte versé | — | Passer au statut Client + onboarding\nPerdu | Refus clair OU silence > 14 jours OU contrat non signé | définitif | Aucune action sauf demande spontanée"},

  {"type":"heading2","text":"2. ROUTINE MATINALE (15 MIN À 9H)"},
  {"type":"paragraph","text":"🎯 Objectif : démarrer la journée avec un plan d'attaque clair. ⏱️ Temps : 15 min."},
  {"type":"numbered","items":[
    "Ouvre GestiQ → vue Kanban Prospects.",
    "Colonne 'À contacter' → vérifie qu'il y a au moins 30 prospects prêts (sinon : déclencher SOP Identifier).",
    "Colonne 'Contacté' → filtre 'Date contact = J-3' → prépare les relances WhatsApp/LinkedIn de la matinée.",
    "Colonne 'RDV pris' → vérifie les RDV du jour → prépare les briefs (5 min par RDV).",
    "Colonne 'Devis envoyé' → filtre 'Date devis = J-3 ou J-7' → prépare les relances.",
    "Note dans ton agenda les 3 priorités du jour."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"À 9h15, tu sais exactement : combien de premiers contacts à envoyer, combien de relances, combien de RDV à préparer."},

  {"type":"heading2","text":"3. MISE À JOUR EN TEMPS RÉEL"},
  {"type":"paragraph","text":"🎯 Objectif : statut toujours à jour = pipeline fiable. ⏱️ Temps : 1 min par changement."},
  {"type":"paragraph","text":"📍 Règle : chaque action commerciale = changement de statut immédiat dans GestiQ."},
  {"type":"numbered","items":[
    "WhatsApp envoyé → statut 'Contacté' + notes (date + heure + canal).",
    "Réponse reçue → notes mise à jour (résumé réponse).",
    "RDV Calendly réservé → statut 'RDV pris' + date/heure dans Notes.",
    "Devis envoyé → statut 'Devis envoyé' + montant + lien PDF.",
    "Contrat signé → statut 'Signé' + montant final + déclencher onboarding.",
    "Refus définitif → statut 'Perdu' + motif (a déjà agence / pas budget / pas intéressé / silence)."
  ]},
  {"type":"callout","variant":"warning","title":"⚠️ NE PAS","text":"Cumuler les MAJ en fin de journée : tu oublies 30% des détails. À chaud = précis."},

  {"type":"heading2","text":"4. ROUTINE SOIR (15 MIN À 18H)"},
  {"type":"paragraph","text":"🎯 Objectif : nettoyage + reporting. ⏱️ Temps : 15 min."},
  {"type":"numbered","items":[
    "Vérifie qu'aucun prospect du jour n'est resté en 'À contacter' (sinon : reporte au lendemain matin).",
    "Vérifie que chaque interaction du jour est tracée (notes complètes).",
    "Identifie les statuts > 7 jours sans action (alerte rouge GestiQ) → planifie action ou passe en 'Perdu'.",
    "Note dans Slack #prospection le bilan du jour (msg envoyés / RDV pris / devis envoyés / signatures).",
    "Note la prochaine action prioritaire du lendemain matin."
  ]},

  {"type":"heading2","text":"5. RITUEL HEBDOMADAIRE (VENDREDI 17H — 1H)"},
  {"type":"paragraph","text":"🎯 Objectif : analyse hebdo + planning semaine suivante. ⏱️ Temps : 1h."},
  {"type":"numbered","items":[
    "Ouvre GestiQ → Rapport Hebdo Prospection.",
    "Compte par statut : À contacter / Contacté / RDV pris / Devis / Signé / Perdu.",
    "Calcule les ratios de conversion : Contacté → RDV pris (%), RDV → Devis (%), Devis → Signé (%).",
    "Identifie LE secteur qui a le mieux converti cette semaine.",
    "Identifie LA source qui a apporté le plus (Google Maps / LinkedIn / Partenaire / Terrain).",
    "Note dans le document 'Bilan hebdo Prospection' (Google Drive Next Gital).",
    "Planifie les priorités semaine suivante.",
    "Envoie le bilan à Saïd par mail le vendredi 18h max."
  ]},

  {"type":"heading2","text":"6. KPI HEBDOMADAIRES À TRACKER"},
  {"type":"paragraph","text":"🎯 Objectif : suivre les chiffres-clés qui pilotent le pipeline. ⏱️ Temps : intégré au rituel hebdo."},
  {"type":"paragraph","text":"✏️ LES 8 KPI :"},
  {"type":"table","text":"KPI | Objectif/sem | Comment calculer\nMessages WhatsApp envoyés | 150 (30/jour x 5j) | Filtre 'Contacté' + date sur la semaine\nTaux de réponse WhatsApp | ≥ 20% | Réponses reçues / messages envoyés\nInvitations LinkedIn envoyées | 100 (20/jour x 5j) | Suivi GestiQ + LinkedIn Sales\nTaux acceptation LinkedIn | ≥ 40% | Acceptations / invitations\nVisites terrain | 20 (4 par demi-journée terrain) | Suivi GestiQ\nRDV obtenus | ≥ 5 | Statut 'RDV pris' créés cette semaine\nDevis envoyés | ≥ 2 | Statut 'Devis envoyé' créés cette semaine\nSignatures | ≥ 1 | Statut 'Signé' créés cette semaine"},

  {"type":"heading2","text":"7. ALERTES À NE JAMAIS IGNORER"},
  {"type":"paragraph","text":"🎯 Objectif : détecter les blocages avant qu'ils plombent le mois. ⏱️ Temps : automatique (notifications GestiQ)."},
  {"type":"paragraph","text":"✏️ 5 ALERTES :"},
  {"type":"list","items":[
    "**Pipeline vide** (À contacter < 20) → urgence : SOP Identifier dès demain matin",
    "**Taux conversion en chute** (RDV/Contacté < 5%) → revoir pitch ou ciblage",
    "**Aucune signature 14 jours** → audit avec Saïd urgent",
    "**Devis sans réponse > 10 jours** → call direct au prospect (pas WhatsApp)",
    "**Partenaire inactif > 30 jours** → relance ou retrait du partenariat"
  ]},

  {"type":"heading2","text":"8. NETTOYAGE MENSUEL (1er DE CHAQUE MOIS — 1H)"},
  {"type":"paragraph","text":"🎯 Objectif : pipeline propre + données fiables. ⏱️ Temps : 1h."},
  {"type":"numbered","items":[
    "Ouvre GestiQ → tous les prospects 'Contacté' depuis > 14 jours sans réponse.",
    "Bascule ces prospects en 'Perdu' avec motif 'Silence > 14j'.",
    "Vérifie les doublons (même téléphone) → fusionner.",
    "Vérifie les fiches incomplètes (pas de téléphone / pas d'observation) → compléter ou supprimer.",
    "Archive les Perdus > 6 mois (action 'Archiver' GestiQ).",
    "Génère le rapport mensuel pour Saïd."
  ]},

  {"type":"divider"},
  {"type":"heading2","text":"Templates de rapports"},
  {"type":"template","text":"RAPPORT QUOTIDIEN SLACK #prospection\n\n📊 [Date] — Bilan Prospection\n\n→ Identif jour : X nouveaux prospects qualifiés ajoutés\n→ WhatsApp : X msg envoyés / Y réponses / Z RDV\n→ LinkedIn : X inv / Y accept / Z conversations\n→ Terrain : X visites / Y décideurs / Z RDV\n→ Devis envoyés : X\n→ Signatures : X\n\n💪 Demain : [priorité 1] / [priorité 2]"},
  {"type":"template","text":"RAPPORT HEBDO MAIL À SAÏD\n\nObjet : Bilan Prospection Semaine [X]\n\nBonjour Saïd,\n\nBilan semaine [X] :\n→ Nouveaux prospects : X\n→ Messages envoyés (tous canaux) : X\n→ RDV pris : X (objectif 5)\n→ Devis envoyés : X (objectif 2)\n→ Signatures : X (objectif 1)\n→ CA généré : X MAD\n\n🏆 Meilleur secteur : [secteur]\n🏆 Meilleure source : [source]\n⚠️ Point bloquant : [si y'en a]\n\nObjectifs semaine prochaine :\n→ ...\n\nSaïd"},

  {"type":"divider"},
  {"type":"heading2","text":"Checklist de validation pipeline (quotidienne)"},
  {"type":"checklist","items":[
    "Routine matinale 9h00 effectuée",
    "Toutes les actions du jour tracées en temps réel",
    "Aucun prospect du jour resté en 'À contacter' (sauf transferts pipeline demain)",
    "Routine soir 18h00 effectuée",
    "Bilan quotidien posté dans Slack #prospection",
    "Aucune alerte rouge GestiQ ignorée",
    "Le vendredi : rapport hebdo envoyé à Saïd"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Pipeline 'À contacter' à 0 → urgence immédiate, prévient Saïd. Conversion RDV → Signé < 20% pendant 2 semaines → audit avec Saïd. Prospect en colère sur GestiQ (mauvaise saisie révélée) → transfère immédiatement à Saïd +212 620 002 066."}
]$sop$::jsonb,
    read_min = 10,
    updated_at = now()
WHERE slug = 'ng-prospect-pipeline';


-- ────────────────────────────────────────────────────────────────────
--  7/7  RÈGLES & OBJECTIFS  (ng-prospect-regles-objectifs)
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"📌 Document de référence","text":"Cette SOP fixe les règles non négociables et les objectifs chiffrés du rôle Prospection chez Next Gital. À lire J1 + relire chaque lundi matin."},
  {"type":"callout","variant":"info","title":"🎯 Mission du rôle","text":"Alimenter le pipeline commercial Next Gital avec un flux constant de prospects qualifiés Oujda, et convertir 1 nouveau client par semaine minimum."},
  {"type":"callout","variant":"tip","title":"💡 Philosophie","text":"Qualité > Quantité. Mieux vaut 20 prospects 5/5 que 100 prospects 2/5. La rigueur quotidienne fait le résultat mensuel."},
  {"type":"callout","variant":"danger","title":"🚫 Les 5 règles d'or","text":"1) Pas plus de 30 WhatsApp/jour. 2) Pas plus de 20 invitations LinkedIn/jour. 3) Toujours WhatsApp pro (+212 620 002 066). 4) Toujours statut GestiQ à jour temps réel. 5) Toujours bilan quotidien Slack #prospection."},

  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. OBJECTIFS QUANTITATIFS — VOLUME"},
  {"type":"paragraph","text":"🎯 Objectif : connaître par cœur les chiffres à produire. ⏱️ Temps : 5 min à mémoriser."},
  {"type":"paragraph","text":"✏️ OBJECTIFS QUOTIDIENS :"},
  {"type":"table","text":"Action | Objectif/jour | Pourquoi\nNouveaux prospects qualifiés | 30 | Alimenter pipeline\nMessages WhatsApp envoyés | 30 | Cycle WhatsApp + GestiQ tracking\nInvitations LinkedIn | 20 | Limite anti-restriction\nMessages LinkedIn (msg 2 + msg 3) | 10-15 | Conversion warm leads\nVisites terrain (sur jours dédiés) | 10 | Présence Oujda + relation directe\nBilan Slack | 1 | Reporting Saïd"},
  {"type":"paragraph","text":"✏️ OBJECTIFS HEBDOMADAIRES :"},
  {"type":"table","text":"Action | Objectif/sem | Comment l'atteindre\nRDV pris | 5 | Conversion moyenne 3-5% des contacts cumulés\nDevis envoyés | 2 | 40% des RDV qualifiés\nSignatures clients | 1 | 50% des devis envoyés\nPartenaires nouveaux signés | 0,5 (= 2/mois) | RDV partenaire toutes les 2 semaines\nCA généré | ≥ 8 000 MAD | Panier moyen Next Gital"},
  {"type":"paragraph","text":"✏️ OBJECTIFS MENSUELS :"},
  {"type":"table","text":"Action | Objectif/mois\nNouveaux clients signés | 4\nCA généré | ≥ 32 000 MAD\nPartenaires actifs total | 5\nNPS prospects approchés | ≥ 50"},

  {"type":"heading2","text":"2. OBJECTIFS QUALITATIFS — STANDARDS"},
  {"type":"paragraph","text":"🎯 Objectif : maintenir l'image Next Gital irréprochable. ⏱️ Temps : à intégrer dans chaque action."},
  {"type":"list","items":[
    "**Message personnalisé à 100%** (nom + observation concrète) — JAMAIS de copier-coller détectable",
    "**Réponse < 15 min** aux prospects qui répondent (hors nuit / weekend)",
    "**Tenue impeccable** sur le terrain (chemise + chaussures cirées + badge)",
    "**GestiQ à jour temps réel** — pas de retard de saisie",
    "**Aucune promesse non-tenue** au prospect (si tu dis 'je vous envoie demain' → tu envoies)",
    "**Ton bienveillant** même en cas de refus (Oujda = petit milieu, ta réputation circule)"
  ]},

  {"type":"heading2","text":"3. HORAIRES & DISCIPLINE"},
  {"type":"paragraph","text":"🎯 Objectif : régularité = résultat. ⏱️ Temps : structure de journée."},
  {"type":"paragraph","text":"✏️ JOURNÉE TYPE :"},
  {"type":"table","text":"Heure | Activité\n08h30 | Arrivée bureau / connexion (si remote)\n09h00 - 09h15 | Routine matinale GestiQ (étape 2 SOP Pipeline)\n09h15 - 10h00 | Identification 30 prospects du jour (SOP Identifier)\n10h00 - 12h00 | Session WhatsApp (30 msg) OU LinkedIn (20 inv)\n12h00 - 14h00 | Pause / RDV éventuels\n14h00 - 17h00 | Terrain (selon planning) OU relances + traitement réponses + RDV visio\n17h00 - 17h45 | Devis / propositions / suivi commercial\n17h45 - 18h00 | Routine soir + bilan Slack\n18h00 | Fin de journée"},
  {"type":"callout","variant":"warning","title":"⚠️ Discipline","text":"Pas de prospection après 19h (sauf RDV demandé par le prospect). Pas de WhatsApp le vendredi après 17h (week-end). Pas de prospection le dimanche."},

  {"type":"heading2","text":"4. INTERDITS ABSOLUS"},
  {"type":"paragraph","text":"🎯 Objectif : éviter les fautes graves qui coûteraient l'emploi et la réputation Next Gital. ⏱️ Temps : à intégrer."},
  {"type":"list","items":[
    "**Spam massif** (> 30 WhatsApp/jour, copier-coller) → ban + bad buzz Oujda",
    "**Mensonge sur les références** (inventer un cas client) → perte confiance immédiate",
    "**Promettre un tarif sans valider Saïd** → engagement contractuel piégeux",
    "**Critiquer un concurrent nominativement** → diffamation possible",
    "**Donner des chiffres internes Next Gital** (CA, marges, salaires) → confidentialité",
    "**Partager un fichier prospects** avec un tiers → vol de données",
    "**Utiliser WhatsApp personnel** pour prospection pro → ban + perte traçabilité",
    "**Mauvais traitement d'un prospect** (insulte, ton agressif) → perte image + sanction",
    "**Ignorer un prospect 7 jours sans raison** → laisser sortir d'un pipeline qualifié",
    "**Ne pas saisir dans GestiQ** → pipeline aveugle = catastrophe"
  ]},

  {"type":"heading2","text":"5. RÉMUNÉRATION & COMMISSIONS"},
  {"type":"paragraph","text":"🎯 Objectif : transparence sur ce qui motive (à valider précisément avec Saïd à l'embauche). ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"✏️ STRUCTURE TYPE (cadre indicatif, à confirmer dans le contrat) :"},
  {"type":"list","items":[
    "**Salaire fixe mensuel** → selon profil et expérience",
    "**Commission signature** → 5% du contrat HT signé grâce à toi (versée à l'encaissement)",
    "**Bonus mensuel** → 1500 MAD si objectif mensuel atteint (4 signatures)",
    "**Bonus trimestriel** → 5000 MAD si dépassement 120% objectif",
    "**Bonus partenariat** → 500 MAD par partenaire signé"
  ]},
  {"type":"callout","variant":"info","title":"💰 Vérification contrat","text":"Tous les détails sont dans ton contrat de travail signé. Toute question : voir Saïd directement."},

  {"type":"heading2","text":"6. ÉVALUATION DE PERFORMANCE"},
  {"type":"paragraph","text":"🎯 Objectif : savoir comment tu seras évalué pour progresser. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"✏️ POINTS HEBDO (vendredi 17h) :"},
  {"type":"list","items":[
    "Bilan chiffré objectifs (vert / orange / rouge)",
    "Top 1 réussite de la semaine",
    "Top 1 difficulté + plan d'action",
    "Validation des priorités semaine suivante"
  ]},
  {"type":"paragraph","text":"✏️ POINTS MENSUELS (1er du mois) :"},
  {"type":"list","items":[
    "Bilan complet objectifs mois (CA, signatures, ratios)",
    "Analyse pipeline (taille, qualité, conversion)",
    "Discussion qualitative (motivation, blocages, formation)",
    "Calcul commissions et bonus du mois"
  ]},
  {"type":"paragraph","text":"✏️ ÉVALUATION TRIMESTRIELLE :"},
  {"type":"list","items":[
    "Bilan formel 1h avec Saïd",
    "Notation 1-5 sur 8 critères (volume, qualité, discipline, attitude, ratios, autonomie, image, esprit d'équipe)",
    "Plan de développement (formations, montée en compétence)",
    "Ajustement objectifs si nécessaire"
  ]},

  {"type":"heading2","text":"7. ESCALADE & SUPPORT"},
  {"type":"paragraph","text":"🎯 Objectif : savoir à qui demander quoi. ⏱️ Temps : 5 min à mémoriser."},
  {"type":"paragraph","text":"✏️ QUI CONTACTER :"},
  {"type":"table","text":"Sujet | Contact | Canal\nQuestion commerciale (tarif, offre) | Saïd | WhatsApp +212 620 002 066\nProblème technique GestiQ | Tech Next Gital | Slack #tech-support\nQuestion contrat / paie | Saïd | Mail info@nextgital.com\nProspect agressif / litige | Saïd | WhatsApp urgent\nPartenaire qui demande > 15% | Saïd | WhatsApp\nIdées d'amélioration | Tous | Slack #idees\nFormation / Outils | Saïd | Mail"},
  {"type":"paragraph","text":"✏️ DÉLAI DE RÉPONSE GARANTI :"},
  {"type":"list","items":[
    "**Urgence (prospect en attente)** → Saïd répond < 30 min sur WhatsApp",
    "**Tech bloquant** → support tech < 2h sur Slack",
    "**Standard** → < 24h sur tous les canaux"
  ]},

  {"type":"heading2","text":"8. OUTILS À MAÎTRISER (FORMATION CONTINUE)"},
  {"type":"paragraph","text":"🎯 Objectif : monter en compétence sur les outils utilisés au quotidien. ⏱️ Temps : 1h/semaine de formation."},
  {"type":"list","items":[
    "**GestiQ** → CRM principal (gestiq.nextgital.tech)",
    "**WhatsApp Business** → app pro",
    "**Google Maps + My Maps** → identification + itinéraires",
    "**LinkedIn + Sales Navigator** (si dispo) → prospection BtoB",
    "**Calendly** (calendly.com/nextgital) → prise de RDV",
    "**Google Drive** → templates contrats, plaquettes, kits",
    "**Slack** → communication équipe Next Gital",
    "**Canva** → personnalisation visuels rapide",
    "**Loom** → vidéos courtes pour prospects warm",
    "**Notion** → SOPs + documentation interne"
  ]},

  {"type":"divider"},
  {"type":"heading2","text":"Récapitulatif des 7 SOPs liées au rôle Prospection"},
  {"type":"list","items":[
    "ng-prospect-identifier → Identifier les prospects (30/jour)",
    "ng-prospect-whatsapp / ng-pr-whatsapp-cold → Prospection WhatsApp froide",
    "ng-prospect-linkedin / ng-pr-linkedin → Prospection LinkedIn",
    "ng-prospect-terrain / ng-pr-terrain-oujda → Prospection terrain Oujda",
    "ng-prospect-partenariats / ng-pr-partenariats → Partenariats apporteurs",
    "ng-prospect-pipeline → Gestion pipeline GestiQ",
    "ng-prospect-regles-objectifs → Ce document (règles + objectifs)"
  ]},

  {"type":"divider"},
  {"type":"heading2","text":"Checklist de validation hebdomadaire (vendredi)"},
  {"type":"checklist","items":[
    "30 prospects/jour identifiés en moyenne (150/semaine)",
    "150 WhatsApp envoyés sur la semaine",
    "100 invitations LinkedIn envoyées",
    "5 RDV pris minimum",
    "2 devis envoyés minimum",
    "1 signature minimum",
    "Pipeline GestiQ à jour, aucun statut > 14 jours sans action",
    "Bilan hebdo envoyé à Saïd vendredi 18h max"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Objectifs hebdo manqués 2 semaines de suite → demande de point d'urgence avec Saïd. Démotivation / surcharge → en parler avant que ça dégrade les résultats. Question éthique sur une pratique → toujours valider avec Saïd avant d'agir. WhatsApp d'urgence Saïd : +212 620 002 066."}
]$sop$::jsonb,
    read_min = 10,
    updated_at = now()
WHERE slug = 'ng-prospect-regles-objectifs';


COMMIT;
