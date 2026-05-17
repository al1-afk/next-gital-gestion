-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 045 : SOPs ultra-détaillés Community Manager
--  Date : 2026-05-17
--  Objectif : Remplacer les blocks des 6 SOPs CM (créés en 036)
--  par une version ultra-détaillée, opérationnelle, prête à l'emploi.
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ────────────────────────────────────────────────────────────────────
-- 1) ng-cm-routine-quotidienne
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"À qui s'adresse cette SOP","text":"Community Manager Next Gital qui gère les réseaux sociaux d'un ou plusieurs clients Oujda (Dr. Karim dentiste, Cabinet Fedix, Restaurant Al Baraka, Pharmacie Andalous, Boulangerie Atlas, etc.)."},
  {"type":"callout","variant":"tip","title":"Pourquoi 2 fois par jour","text":"L'algorithme Meta/Instagram valorise la réactivité < 2h sur les messages. Une routine matin (9h) + après-midi (15h) couvre 90% du trafic utile sans saturer le CM."},
  {"type":"callout","variant":"warning","title":"Règle d'or réactivité","text":"Aucun message privé client ne doit rester > 2h sans réponse en journée (9h-19h). Le soir/weekend → réponse automatique \"Nous reviendrons vers vous à 9h\"."},
  {"type":"callout","variant":"success","title":"Durée totale","text":"45 min le matin (9h-9h45) + 30 min l'après-midi (15h-15h30) = 1h15 par client par jour."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. Ouvrir Meta Business Suite et sélectionner le client"},
  {"type":"paragraph","text":"🎯 Objectif : centraliser Facebook + Instagram du client dans une seule interface. ⏱️ Temps : 2 min."},
  {"type":"paragraph","text":"📍 Point de départ : ordinateur allumé, café prêt, 9h00 du matin."},
  {"type":"paragraph","text":"🖥️ OÙ : business.facebook.com (connexion avec le compte Next Gital nextgital10@gmail.com)."},
  {"type":"numbered","items":["Ouvrir Chrome → business.facebook.com","Se connecter avec nextgital10@gmail.com","En haut à gauche, cliquer sur le sélecteur de compte → choisir le client (ex : Dr. Karim Dentiste)","Vérifier que Facebook + Instagram sont bien liés (icônes en haut)","Ouvrir GestiQ dans un 2e onglet → gestiq.nextgital.tech → Clients → fiche client"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le nom du client s'affiche en haut à gauche + tu vois 2 icônes (FB + IG) actives."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"\"Compte non trouvé\" → demander accès au gérant de compte Next Gital. \"Instagram non lié\" → aller Paramètres → Comptes → Lier Instagram (login + mdp client). \"Session expirée\" → reconnexion 2FA via téléphone bureau."},
  {"type":"paragraph","text":"➡️ Étape suivante : traiter les messages privés."},

  {"type":"heading2","text":"2. Traiter la boîte de messages privés (Inbox)"},
  {"type":"paragraph","text":"🎯 Objectif : 0 message non lu en fin de routine. ⏱️ Temps : 10-15 min selon volume."},
  {"type":"paragraph","text":"📍 Point de départ : Meta Business Suite ouvert sur le bon client."},
  {"type":"paragraph","text":"🖥️ OÙ : Menu gauche → Inbox (icône enveloppe)."},
  {"type":"numbered","items":["Cliquer sur Inbox dans le menu gauche","Filtre en haut → sélectionner \"Non lus\"","Trier par \"Plus ancien d'abord\" pour ne rien oublier","Lire chaque message → catégoriser mentalement (question prix, rdv, plainte, spam)","Répondre selon le template adapté (voir section Templates ci-dessous)","Une fois répondu → marquer avec un label : 🟢 Traité / 🟡 En attente client / 🔴 À escalader","Si demande commerciale/rdv → créer prospect dans GestiQ + tag le gérant en interne"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Salutation** → toujours commencer par \"Bonjour [Prénom]\" → ex : \"Bonjour Fatima\" → ne PAS écrire \"Salut\" ou \"Hey\"","**Ton** → professionnel chaleureux → vouvoiement par défaut → tutoiement uniquement si le client tutoie en premier","**Signature** → \"L'équipe [Nom Client]\" → ex : \"L'équipe Dr. Karim\" → ne PAS signer du nom du CM"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Filtre \"Non lus\" affiche 0 message. Tous les messages > 2h ont reçu une réponse."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Message en arabe darija → utiliser Google Translate + valider avec gérant. Message d'insulte → NE PAS répondre, capture d'écran, escalade WhatsApp. Spam évident (lien suspect) → marquer Spam + bloquer."},
  {"type":"paragraph","text":"➡️ Étape suivante : commentaires sur les posts récents."},

  {"type":"heading2","text":"3. Répondre aux commentaires des 7 derniers jours"},
  {"type":"paragraph","text":"🎯 Objectif : aucun commentaire client ignoré. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Meta Business Suite → onglet \"Contenu\" ou \"Posts\"."},
  {"type":"paragraph","text":"🖥️ OÙ : Menu gauche → Contenu → Posts → Filtre \"7 derniers jours\"."},
  {"type":"numbered","items":["Ouvrir l'onglet Contenu","Filtrer sur les 7 derniers jours","Pour chaque post, cliquer dessus → voir les commentaires","Identifier les commentaires non répondus (pas d'icône bleue Page)","Répondre à chaque commentaire pertinent (question, compliment, demande info)","Pour les emojis seuls → liker uniquement, pas besoin de répondre","Faire pareil sur Instagram → ouvrir instagram.com en parallèle → Activité → Commentaires"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Compliment** → \"Merci beaucoup [Prénom] ! 🙏 Votre soutien nous touche.\" → ne PAS copier-coller la même réponse 10 fois","**Question prix/dispo** → \"Bonjour [Prénom], je vous envoie les détails en message privé tout de suite 👌\" + envoyer le DM dans la foulée","**Plainte publique** → \"Bonjour [Prénom], nous sommes désolés de votre expérience. Pouvez-vous nous écrire en privé pour qu'on règle ça ensemble ?\" → JAMAIS de débat public"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tous les posts des 7 derniers jours ont reçu une réponse de la Page sur chaque commentaire utile."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Commentaire hors sujet (pub d'un autre business) → masquer (pas supprimer). Commentaire critique légitime → répondre publiquement avec empathie. Troll récurrent → bloquer après 2 avertissements."},
  {"type":"paragraph","text":"➡️ Étape suivante : publier le post du jour."},

  {"type":"heading2","text":"4. Publier le post du jour selon le calendrier éditorial"},
  {"type":"paragraph","text":"🎯 Objectif : 1 post publié à l'heure planifiée, sans faute de frappe. ⏱️ Temps : 8 min."},
  {"type":"paragraph","text":"📍 Point de départ : calendrier édito Notion ouvert."},
  {"type":"paragraph","text":"🖥️ OÙ : notion.so → workspace Next Gital → page \"Calendrier édito [Nom Client]\"."},
  {"type":"numbered","items":["Ouvrir Notion → calendrier édito du client","Trouver la carte du jour (filtre Date = aujourd'hui)","Vérifier statut = \"Visuel prêt\" (sinon → relancer Designer)","Télécharger le visuel depuis Notion ou Drive","Copier le texte du post depuis Notion","Retourner sur Meta Business Suite → bouton \"Créer un post\"","Coller le texte → uploader le visuel → cocher Facebook + Instagram","Programmer à l'heure planifiée (généralement 12h ou 18h) → cliquer Programmer","Mettre à jour Notion : statut → \"Publié\" + ajouter le lien du post"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Texte du post** → relire 2 fois → vérifier orthographe + emojis + hashtags → ne PAS publier sans relecture","**Heures de pic Oujda** → 12h-14h (pause déj) et 18h-21h (après travail) → ne PAS publier à 3h du matin","**Hashtags** → 15-20 max → ex : #oujda #maroc #dentiste #santé → ne PAS dépasser 30 (pénalisé)"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le post apparaît dans l'onglet \"Programmés\" avec la bonne date/heure. Notion mis à jour."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Visuel pas prêt → relancer Designer immédiatement + reporter d'1 jour. Faute de frappe détectée après publication → modifier le post (autorisé pendant 30 min sans perte de portée). Mauvais compte sélectionné → supprimer + republier."},
  {"type":"paragraph","text":"➡️ Étape suivante : engagement actif."},

  {"type":"heading2","text":"5. Engagement actif : liker, commenter, suivre"},
  {"type":"paragraph","text":"🎯 Objectif : augmenter la visibilité organique du client. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Instagram + Facebook ouverts, connecté en tant que la Page client."},
  {"type":"paragraph","text":"🖥️ OÙ : instagram.com (mode \"Compte professionnel\") + facebook.com (Page client active)."},
  {"type":"numbered","items":["Sur Instagram → barre de recherche → taper #oujda","Faire défiler les posts récents (< 24h)","Liker 20 posts pertinents (secteur du client + locaux Oujda)","Commenter 5 posts avec un message authentique (pas de spam type \"Joli !\")","Suivre 3 comptes pertinents (autres pros Oujda, clients potentiels)","Répéter avec #maroc et le hashtag secteur (ex : #dentisteoujda)","Sur Facebook → groupes Oujda Business → liker/commenter 3 posts"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Commentaire engageant** → \"Superbe initiative ! 👏 On adore ce que vous faites pour Oujda.\" → ne PAS écrire juste \"👍\"","**Question dans le commentaire** → \"Vous proposez aussi à domicile ?\" → crée une conversation","**À éviter absolument** → commentaires identiques en série (Meta détecte = shadowban)"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"20 likes + 5 commentaires + 3 follows réalisés. Aucun message générique copié-collé."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Compte limité par Instagram (\"Action bloquée\") → ralentir à 5 actions/heure pendant 48h. Commentaire mal interprété → supprimer + s'excuser en DM. Suivi par erreur d'un concurrent → unfollow discret."},
  {"type":"paragraph","text":"➡️ Étape suivante : passer au client suivant (matin terminé)."},

  {"type":"heading2","text":"6. Routine après-midi (15h) : version courte"},
  {"type":"paragraph","text":"🎯 Objectif : second contrôle de la journée. ⏱️ Temps : 30 min total."},
  {"type":"paragraph","text":"📍 Point de départ : retour de pause déj, 15h00."},
  {"type":"paragraph","text":"🖥️ OÙ : mêmes outils que le matin."},
  {"type":"numbered","items":["Refaire étape 2 (DM non lus) → temps : 10 min","Refaire étape 3 (commentaires nouveaux) → temps : 8 min","Vérifier que le post programmé du matin est bien publié (statut OK ?)","Si Story prévue (souvent l'après-midi) → publier la Story (24h durée)","Refaire engagement light : 10 likes + 2 commentaires","Clôturer la journée : envoyer un récap interne dans GestiQ → Activité du jour"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Récap GestiQ** → \"Client X : 1 post publié (lien), 5 DM traités, 3 commentaires répondus, 2 leads créés.\" → utile pour facturation et suivi"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Récap envoyé dans GestiQ. 0 message non lu. Story publiée si prévue."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Post programmé non publié (bug Meta) → republier manuellement immédiatement. Story refusée (musique copyrighted) → remplacer par musique libre Meta."},
  {"type":"paragraph","text":"➡️ Étape suivante : routine terminée pour ce client."},

  {"type":"divider"},
  {"type":"heading","text":"Templates de messages / posts"},

  {"type":"template","text":"📩 RÉPONSE DM — Demande de prix\n\nBonjour [Prénom] 👋\n\nMerci de votre intérêt pour [Nom Client] !\n\nVoici nos tarifs pour [service demandé] :\n• [Service 1] : à partir de [XXX] DH\n• [Service 2] : à partir de [XXX] DH\n\nSouhaitez-vous prendre rendez-vous ? Nous sommes disponibles [horaires].\n\nÀ très vite,\nL'équipe [Nom Client]"},

  {"type":"template","text":"📩 RÉPONSE DM — Demande de RDV\n\nBonjour [Prénom],\n\nAvec plaisir ! Voici nos créneaux disponibles cette semaine :\n• [Jour] à [Heure]\n• [Jour] à [Heure]\n• [Jour] à [Heure]\n\nLequel vous convient le mieux ?\n\nMerci de nous confirmer votre nom complet + numéro de téléphone pour valider.\n\nL'équipe [Nom Client]"},

  {"type":"template","text":"💬 RÉPONSE COMMENTAIRE — Compliment\n\nMerci infiniment [Prénom] 🙏\nVotre soutien nous touche énormément ! À très bientôt 💙\nL'équipe [Nom Client]"},

  {"type":"template","text":"💬 RÉPONSE COMMENTAIRE — Plainte publique\n\nBonjour [Prénom],\n\nNous sommes vraiment désolés de cette expérience. Votre satisfaction est notre priorité.\n\nPouvez-vous nous écrire en message privé pour que nous puissions vous aider personnellement ? 🙏\n\nL'équipe [Nom Client]"},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation (fin de journée)"},
  {"type":"checklist","items":["Inbox FB + IG vide (0 message non lu)","Tous commentaires des 7 derniers jours répondus","Post du jour publié à l'heure prévue","Story publiée si prévue","20 likes + 5 commentaires d'engagement effectués (matin)","Calendrier Notion mis à jour (statut = Publié)","Récap journée envoyé dans GestiQ","Aucun message client en attente > 2h"]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Bloqué > 15 minutes sur un message sensible (plainte juridique, menace, demande média) → WhatsApp gérant Next Gital +212 620 002 066 immédiatement avec capture d'écran. Ne réponds RIEN avant validation."}
]$sop$::jsonb,
    read_min = 12,
    updated_at = now()
WHERE slug = 'ng-cm-routine-quotidienne';


-- ────────────────────────────────────────────────────────────────────
-- 2) ng-cm-calendrier-editorial
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"À qui s'adresse cette SOP","text":"Community Manager qui doit planifier 30 jours de contenu pour un client Oujda (Restaurant Al Baraka, Pharmacie Andalous, École Al Massira, etc.)."},
  {"type":"callout","variant":"tip","title":"Pourquoi planifier 30 jours","text":"Permet d'aligner Designer + Copywriter + Client, d'éviter le \"je n'ai pas d'idée\", et de garantir une cohérence éditoriale mensuelle. Gain de temps : 70% en moins de stress quotidien."},
  {"type":"callout","variant":"warning","title":"Règle du mix 40/30/20/10","text":"40% éducatif (apprendre quelque chose) + 30% inspirationnel (témoignages, citations, coulisses) + 20% promo (offres, services) + 10% community (questions, sondages, UGC)."},
  {"type":"callout","variant":"success","title":"Fréquence cible","text":"4 à 7 posts par semaine selon budget client. Minimum viable = 4 posts/semaine pour rester dans l'algo."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. Préparer la base Notion calendrier édito"},
  {"type":"paragraph","text":"🎯 Objectif : avoir un tableau Notion clair et partagé pour le mois M+1. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : dernier jour du mois M (ex : 25 du mois pour préparer le mois suivant)."},
  {"type":"paragraph","text":"🖥️ OÙ : notion.so → workspace Next Gital → template \"Calendrier édito client\"."},
  {"type":"numbered","items":["Ouvrir Notion → workspace Next Gital","Dupliquer le template \"Calendrier édito - Template\"","Renommer : \"Calendrier édito [Nom Client] - [Mois Année]\" (ex : Calendrier édito Dr. Karim - Juin 2026)","Définir les colonnes : Date, Jour, Heure, Plateforme (FB/IG/TikTok), Type (Éducatif/Inspirationnel/Promo/Community), Sujet, Texte post, Brief visuel, Statut, Lien post publié","Partager avec : Designer + Gérant Next Gital + Client (en lecture)","Créer une vue Calendrier (filtre par date) et une vue Tableau (filtre par statut)"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Statuts possibles** → Idée → Texte validé → Visuel en cours → Visuel prêt → Programmé → Publié → ne PAS sauter d'étape","**Couleurs types** → Éducatif=bleu, Inspirationnel=vert, Promo=orange, Community=violet → uniformité visuelle"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tableau Notion créé, partagé avec les 3 personnes, 2 vues fonctionnelles."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Client ne reçoit pas l'invitation Notion → vérifier email + renvoyer. Template introuvable → demander accès workspace au gérant."},
  {"type":"paragraph","text":"➡️ Étape suivante : brainstorming des sujets."},

  {"type":"heading2","text":"2. Brainstormer 30 sujets pour le mois"},
  {"type":"paragraph","text":"🎯 Objectif : remplir 30 lignes avec un sujet + type pour chaque jour. ⏱️ Temps : 45 min."},
  {"type":"paragraph","text":"📍 Point de départ : Notion vide, fiche client GestiQ ouverte, analyse mois précédent en tête."},
  {"type":"paragraph","text":"🖥️ OÙ : Notion calendrier + GestiQ fiche client + Pinterest pour inspiration."},
  {"type":"numbered","items":["Relire fiche client GestiQ → services, cibles, ton, événements à venir","Lister 5 sujets ÉDUCATIFS (ex pour dentiste : Comment bien se brosser les dents, Les aliments à éviter, Quand consulter, Carie : signes, Détartrage utilité)","Lister 4 sujets INSPIRATIONNELS (témoignage patient, avant/après, équipe, valeurs, citations)","Lister 3 sujets PROMO (nouveau service, promo de la semaine, package famille)","Lister 2 sujets COMMUNITY (sondage, question ouverte, UGC client)","Répartir sur 30 jours en alternant les types (jamais 2 promos de suite)","Inclure dates spéciales du mois (Aïd, fête nationale, rentrée, etc.) dans le calendrier marocain"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Sujet éducatif** → \"3 erreurs fréquentes au brossage des dents\" → titre clair, promet une valeur","**Sujet inspirationnel** → \"Témoignage de Mme Aicha : son sourire retrouvé\" → humain, émotion","**Sujet promo** → \"-20% sur le blanchiment dentaire jusqu'au 30 juin\" → date butoir, chiffre","**Sujet community** → \"Quel sujet aimeriez-vous voir traité ?\" → question ouverte, réponse rapide"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"30 lignes remplies avec date + type + sujet. Répartition 40/30/20/10 respectée."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Manque d'idées → consulter Pinterest \"Instagram post ideas [secteur]\" + analyser top 5 posts concurrents Oujda. Trop de promo → recompter, max 20%. Sujet déjà fait le mois dernier → archiver mois M-1 visible."},
  {"type":"paragraph","text":"➡️ Étape suivante : rédiger les textes."},

  {"type":"heading2","text":"3. Rédiger les textes de posts (copywriting)"},
  {"type":"paragraph","text":"🎯 Objectif : 30 textes prêts à publier (accroche + corps + CTA + hashtags). ⏱️ Temps : 3-4 heures (lissé sur 2-3 jours)."},
  {"type":"paragraph","text":"📍 Point de départ : 30 sujets validés dans Notion."},
  {"type":"paragraph","text":"🖥️ OÙ : Notion (colonne Texte post)."},
  {"type":"numbered","items":["Pour chaque sujet, appliquer la structure : Accroche (1 ligne) + Développement (3-5 lignes) + CTA + Hashtags","Suivre la SOP Copywriting (ng-cm-copywriting) pour les formules","Adapter le ton à la charte client (sérieux médical / chaleureux resto / professionnel école)","Faire valider 5 textes par le gérant avant de continuer (éviter de tout refaire)","Une fois validé → continuer les 25 restants en autonomie","Mettre statut = \"Texte validé\""]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Longueur post Facebook** → 80-150 mots → engagement optimal","**Longueur post Instagram** → 50-100 mots → lecture mobile rapide","**CTA standard** → \"💬 Dites-nous en commentaire\", \"📩 Écrivez-nous en DM\", \"📞 Appelez le [tel]\" → ne PAS écrire \"Cliquez ici\""]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"30 textes en statut \"Texte validé\". Aucune faute d'orthographe. Hashtags présents partout."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Texte trop long → couper en 2 posts. Ton incohérent → relire charte. Refus client sur un sujet → remplacer dans les 24h."},
  {"type":"paragraph","text":"➡️ Étape suivante : brief Designer."},

  {"type":"heading2","text":"4. Rédiger le brief visuel pour le Designer"},
  {"type":"paragraph","text":"🎯 Objectif : Designer comprend exactement ce qu'il doit créer pour chaque post. ⏱️ Temps : 1h."},
  {"type":"paragraph","text":"📍 Point de départ : 30 textes validés."},
  {"type":"paragraph","text":"🖥️ OÙ : Notion (colonne Brief visuel)."},
  {"type":"numbered","items":["Pour chaque post, écrire un brief structuré : Format / Dimensions / Texte sur visuel / Ambiance / Référence","Indiquer dimensions : Post Insta = 1080x1080 (carré) ou 1080x1350 (portrait), Story = 1080x1920, Reel cover = 1080x1920","Préciser le texte EXACT à afficher sur le visuel (gros titre, sous-titre)","Joindre 1-2 références Pinterest si possible","Indiquer la palette : couleurs charte client (ex : Dr. Karim = bleu #1E88E5 + blanc)","Tag le Designer dans Notion (@designer)","Définir date de livraison : J-3 avant publication"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Brief modèle** → \"Format : Carré 1080x1080. Texte gros : '3 erreurs au brossage'. Sous-titre : 'À éviter absolument'. Ambiance : pro médical, fond bleu clair, icône dent. Réf : [lien Pinterest].\" → ne PAS écrire juste \"Fais un visuel sympa\""]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"30 briefs visuels écrits avec dimensions + texte + ambiance + référence."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Designer demande des précisions → répondre dans Notion (commentaires) pour traçabilité. Référence Pinterest introuvable → faire screenshot d'un post concurrent inspirant."},
  {"type":"paragraph","text":"➡️ Étape suivante : validation client."},

  {"type":"heading2","text":"5. Faire valider le calendrier par le client"},
  {"type":"paragraph","text":"🎯 Objectif : OK écrit du client sur les 30 sujets + textes. ⏱️ Temps : 30 min envoi + 48h attente."},
  {"type":"paragraph","text":"📍 Point de départ : 30 textes prêts dans Notion."},
  {"type":"paragraph","text":"🖥️ OÙ : Notion (lien partagé) + WhatsApp client."},
  {"type":"numbered","items":["Vérifier que le lien Notion est partagé en lecture avec le client","Envoyer WhatsApp client : message type \"Voici le calendrier édito de [Mois]. Merci de valider d'ici 48h. Lien : [url]\"","Demander les modifications via commentaires Notion directement","Apporter les corrections demandées sous 24h","Renvoyer pour validation finale","Une fois OK → statut global = \"Validé client\" → transmettre Designer"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Message WhatsApp** → \"Bonjour [Prénom], voici le calendrier édito de [Mois] : [lien Notion]. Merci de me retourner vos remarques d'ici [date+48h] pour qu'on lance la production des visuels. Bonne journée ! Said - Next Gital\""]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Validation écrite client reçue (WhatsApp ou Notion). Aucun sujet en attente."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Client silencieux > 48h → relance polie + appel téléphonique. Client veut tout refaire → réunion 30 min pour cadrer. Désaccord sur un sujet → proposer 2 alternatives."},
  {"type":"paragraph","text":"➡️ Étape suivante : transmettre au Designer."},

  {"type":"heading2","text":"6. Transmettre au Designer + suivre la production"},
  {"type":"paragraph","text":"🎯 Objectif : Designer livre les 30 visuels avant le 1er du mois. ⏱️ Temps : 15 min transmission + suivi quotidien."},
  {"type":"paragraph","text":"📍 Point de départ : calendrier validé client."},
  {"type":"paragraph","text":"🖥️ OÙ : Notion + WhatsApp Designer."},
  {"type":"numbered","items":["WhatsApp Designer : \"Calendrier [Client] [Mois] validé. 30 visuels à livrer avant le [date]. Lien : [Notion]\"","Suivi quotidien dans Notion : statut visuels (Visuel en cours / Visuel prêt)","Relance Designer si retard > 2 jours","Une fois visuel livré → vérifier qualité + cohérence brief → si OK statut \"Visuel prêt\"","Si NOK → demander correction (max 2 itérations)","Une fois 30 visuels prêts → programmer tous les posts dans Meta Business Suite (Voir SOP routine quotidienne étape 4)"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Relance Designer** → \"Hello, on en est où sur les visuels [Client] ? Reste X jours avant le 1er du mois 🙏\" → ne PAS être agressif"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"30 visuels en statut \"Visuel prêt\" avant le 1er du mois. Mois prêt à démarrer."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Designer en retard → escalade gérant. Visuel non conforme charte → renvoyer avec capture d'écran annotée. Client veut modifier après validation → impacter calendrier (J+3 minimum)."},
  {"type":"paragraph","text":"➡️ Étape suivante : démarrer la publication quotidienne (SOP routine)."},

  {"type":"divider"},
  {"type":"heading","text":"Templates de messages"},

  {"type":"template","text":"📱 WHATSAPP CLIENT — Demande validation calendrier\n\nBonjour [Prénom] 👋\n\nJ'espère que vous allez bien.\n\nVoici le calendrier éditorial de [Mois Année] pour [Nom Entreprise] :\n👉 [lien Notion]\n\nVous y trouverez :\n• Les 30 sujets prévus\n• Les textes complets\n• Le brief visuel pour chaque post\n\nMerci de me retourner vos remarques d'ici [date+48h] (en commentaires directement dans Notion ou par WhatsApp).\n\nUne fois validé, on lance la production des visuels 🎨\n\nBelle journée,\nL'équipe Next Gital"},

  {"type":"template","text":"💬 NOTION — Brief visuel type\n\n**Format** : Post Instagram carré 1080x1080\n**Texte sur visuel** :\n- Titre principal : \"3 ERREURS AU BROSSAGE\"\n- Sous-titre : \"À éviter absolument\"\n**Ambiance** : Pro médical, propre, rassurant\n**Palette** : Bleu charte (#1E88E5) + blanc + accent vert (#43A047)\n**Éléments** : Icône dent + numéros 1-2-3\n**Référence** : [lien Pinterest]\n**Logo** : En bas à droite, taille 80px\n**Livraison** : [date J-3]"},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation (avant le 1er du mois)"},
  {"type":"checklist","items":["30 sujets définis répartis 40/30/20/10","30 textes rédigés sans faute","30 briefs visuels écrits avec dimensions","Validation client écrite reçue","Calendrier partagé Designer + Gérant + Client","30 visuels livrés et validés","Tous les posts programmés dans Meta Business Suite","Vue Calendrier Notion à jour"]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Bloqué > 30 min sur validation client ou production Designer → WhatsApp gérant Next Gital +212 620 002 066. Risque de glissement du calendrier = impact direct sur facturation client."}
]$sop$::jsonb,
    read_min = 15,
    updated_at = now()
WHERE slug = 'ng-cm-calendrier-editorial';


-- ────────────────────────────────────────────────────────────────────
-- 3) ng-cm-copywriting
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"À qui s'adresse cette SOP","text":"Community Manager Next Gital qui doit rédiger des posts pour Facebook/Instagram d'un client Oujda. Méthode applicable aussi aux légendes de Reels et stories."},
  {"type":"callout","variant":"tip","title":"Structure universelle d'un post performant","text":"ACCROCHE (1ère ligne forte qui stoppe le scroll) + DÉVELOPPEMENT (3-5 lignes qui apportent de la valeur) + CTA (1 ligne d'action claire) + HASHTAGS (15-20 ciblés)."},
  {"type":"callout","variant":"warning","title":"Règle des 3 secondes","text":"L'utilisateur décide en 3 secondes s'il s'arrête ou scrolle. L'accroche est la seule chose qui compte pour la portée."},
  {"type":"callout","variant":"success","title":"Outils à disposition","text":"ChatGPT pour brainstorming, Hemingway Editor pour lisibilité, Antidote pour fautes, hashtagify.me pour hashtags."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. Définir l'objectif du post"},
  {"type":"paragraph","text":"🎯 Objectif : savoir AVANT d'écrire pourquoi ce post existe. ⏱️ Temps : 2 min."},
  {"type":"paragraph","text":"📍 Point de départ : sujet défini dans le calendrier éditorial Notion."},
  {"type":"paragraph","text":"🖥️ OÙ : Notion → carte du post → champ \"Objectif\"."},
  {"type":"numbered","items":["Ouvrir la carte du post dans Notion","Identifier le type : Éducatif / Inspirationnel / Promo / Community","Définir 1 seul objectif mesurable : Notoriété (vues) / Engagement (likes, commentaires) / Conversion (DM, appels, ventes)","Définir le persona ciblé : ex pour Restaurant Al Baraka = famille marocaine 25-45 ans Oujda","Définir l'action attendue : commenter / sauvegarder / partager / DM"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Objectif clair** → \"Générer 10 réservations weekend pour Al Baraka\" → mesurable","**Objectif flou** → \"Faire un post sympa\" → à éviter absolument"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Objectif écrit dans Notion. Tu sais en 1 phrase pourquoi ce post existe."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"2 objectifs différents → choisir le principal sinon le post sera flou. Pas de cible → revoir fiche client GestiQ."},
  {"type":"paragraph","text":"➡️ Étape suivante : rédiger l'accroche."},

  {"type":"heading2","text":"2. Rédiger l'accroche (la ligne la plus importante)"},
  {"type":"paragraph","text":"🎯 Objectif : 1 ligne qui stoppe le scroll en 3 secondes. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : objectif clair."},
  {"type":"paragraph","text":"🖥️ OÙ : Notion (colonne Texte post)."},
  {"type":"numbered","items":["Choisir une formule parmi les 5 ci-dessous","Écrire 3 variantes différentes","Lire à voix haute → garder celle qui frappe le plus","Vérifier qu'elle tient en 1 ligne sur mobile (max 60 caractères avec emoji)","Tester sur un collègue : \"Tu cliquerais pour lire la suite ?\""]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — 5 FORMULES D'ACCROCHE :"},
  {"type":"list","items":["**Formule chiffre choc** → \"7 patients sur 10 brossent mal leurs dents 😱\" → crédibilité + curiosité","**Formule question** → \"Saviez-vous qu'un détartrage évite 80% des caries ? 🦷\" → engage le lecteur","**Formule secret** → \"Le secret d'un sourire éclatant n'est PAS celui que vous pensez ✨\" → curiosité","**Formule erreur** → \"L'erreur que 90% des gens font après chaque repas 🍽️\" → peur de mal faire","**Formule transformation** → \"Avant/Après : Mme Aicha a retrouvé son sourire en 3 séances 😍\" → preuve sociale"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Accroche tient en 1 ligne mobile, contient un emoji pertinent, donne envie de cliquer \"voir plus\"."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Accroche fade (\"Bonjour, voici notre nouveau service\") → reformuler avec une formule. Accroche racoleuse (\"INCROYABLE !!!\") → professionnaliser. Trop d'emojis (>2) → réduire."},
  {"type":"paragraph","text":"➡️ Étape suivante : développer le corps du post."},

  {"type":"heading2","text":"3. Rédiger le développement (3-5 lignes de valeur)"},
  {"type":"paragraph","text":"🎯 Objectif : apporter une vraie valeur au lecteur en 3-5 lignes courtes. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : accroche validée."},
  {"type":"paragraph","text":"🖥️ OÙ : Notion (sous l'accroche)."},
  {"type":"numbered","items":["Sauter une ligne après l'accroche (aération visuelle)","Écrire 3-5 lignes courtes (max 12 mots par ligne)","Une idée par ligne","Utiliser des emojis bullets pour les listes (✅ ❌ 👉 1️⃣ 2️⃣)","Pas de jargon technique : niveau lecture 6e","Adopter le ton du client (sérieux / chaleureux / fun)"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — STRUCTURE TYPE :"},
  {"type":"list","items":["**Post éducatif** → 1 problème + 3 solutions concrètes → ex : \"❌ Erreur 1 : brosser trop fort\\n❌ Erreur 2 : moins de 2 min\\n❌ Erreur 3 : brosse usée\\n✅ La solution : brosse souple + 2 min + remplacer tous les 3 mois\"","**Post promo** → Bénéfice client + offre + date limite → ex : \"Un sourire éclatant pour l'été ☀️\\n👉 Blanchiment dentaire -20%\\n📅 Jusqu'au 30 juin uniquement\"","**Post inspirationnel** → Histoire courte + émotion + valeur du client → ex : \"Mme Aicha n'osait plus sourire depuis 5 ans.\\nEn 3 séances, sa confiance est revenue.\\nC'est pour ces moments qu'on fait ce métier 💙\""]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Corps de 3-5 lignes, aéré, sans jargon, ton cohérent. Test : un enfant de 12 ans comprendrait ?"},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Trop long (>150 mots) → couper en 2 posts. Trop technique → vulgariser. Ton off → relire charte client."},
  {"type":"paragraph","text":"➡️ Étape suivante : ajouter le CTA."},

  {"type":"heading2","text":"4. Ajouter un CTA (Call To Action) clair"},
  {"type":"paragraph","text":"🎯 Objectif : 1 action précise demandée au lecteur. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : développement écrit."},
  {"type":"paragraph","text":"🖥️ OÙ : Notion (dernière ligne avant hashtags)."},
  {"type":"numbered","items":["Sauter une ligne après le développement","Écrire 1 seule action (jamais 2)","Utiliser un verbe d'action à l'impératif","Ajouter un emoji directionnel (💬 📩 📞 ⬇️)","Vérifier que l'action est faisable en 1 clic"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — 8 CTA QUI FONCTIONNENT :"},
  {"type":"list","items":["**Engagement** → \"💬 Dites-nous en commentaire votre astuce préférée\" → conversation","**Sauvegarde** → \"📌 Sauvegardez ce post pour ne pas l'oublier\" → algorithme +","**Partage** → \"🔄 Partagez avec quelqu'un qui en a besoin\" → reach +","**DM** → \"📩 Écrivez-nous en privé pour un devis\" → conversion","**Appel** → \"📞 Appelez-nous au +212 6XX XXX XXX\" → conversion directe","**Lien bio** → \"⬇️ Tous les détails dans le lien en bio\" → trafic site","**Réservation** → \"📅 Réservez votre créneau ce weekend\" → urgence","**Question ouverte** → \"❓ Et vous, quelle est votre expérience ?\" → engagement"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"CTA = 1 ligne, 1 verbe d'action, 1 emoji directionnel, action faisable en 1 clic."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"\"Cliquez ici\" → interdit (Meta pénalise). 2 CTA = confusion → en choisir 1. CTA absent = post passif → toujours ajouter."},
  {"type":"paragraph","text":"➡️ Étape suivante : choisir les hashtags."},

  {"type":"heading2","text":"5. Choisir 15-20 hashtags optimisés"},
  {"type":"paragraph","text":"🎯 Objectif : mix équilibré de hashtags qui amplifie la portée. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : post rédigé."},
  {"type":"paragraph","text":"🖥️ OÙ : Notion + hashtagify.me + recherche Instagram."},
  {"type":"numbered","items":["Sauter 2 lignes après le CTA","Suivre la règle du mix : 5 populaires + 5 niches + 5 locaux + 5 secteur","Vérifier chaque hashtag sur Instagram → barre recherche → onglet Tags","Éviter les hashtags >10M (trop concurrentiels) et <1k (peu vus)","Ne JAMAIS dépasser 30 (pénalisation Meta)","Idéal : 15-20 hashtags"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — MIX TYPE POUR DR. KARIM DENTISTE OUJDA :"},
  {"type":"list","items":["**Populaires (5M+)** → #maroc #beauty #santé #wellness #morocco","**Niches secteur (50k-500k)** → #dentiste #sourire #blanchimentdentaire #orthodontie #santebuccodentaire","**Locaux Oujda (5k-50k)** → #oujda #oujdacity #oujdaentrepreneurs #oujdabusiness #orientalmaroc","**Secteur local précis (1k-10k)** → #dentisteoujda #dentisteoriental #santeoujda #cabinetdentaireoujda"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"15-20 hashtags, mix populaires/niches/locaux respecté, aucun en dehors de la fourchette 1k-10M."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Tous les hashtags trop populaires → invisible. Tous trop niches → 0 reach. Hashtags interdits (Meta bloque) → vérifier avant publication. Hashtags identiques tous les jours → algorithme dévalue, varier 50%."},
  {"type":"paragraph","text":"➡️ Étape suivante : relecture finale."},

  {"type":"heading2","text":"6. Relecture finale et validation"},
  {"type":"paragraph","text":"🎯 Objectif : post sans faute, sans coquille, prêt à publier. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : post complet (accroche + corps + CTA + hashtags)."},
  {"type":"paragraph","text":"🖥️ OÙ : Notion + Antidote (ou Word) pour orthographe."},
  {"type":"numbered","items":["Copier le post complet dans Antidote ou Word","Corriger toutes les fautes signalées","Lire à voix haute → repérer phrases bancales","Vérifier emojis → s'affichent bien sur mobile ?","Compter mots : entre 50-150 mots idéal","Compter hashtags : 15-20","Mettre statut Notion = \"Texte validé\""]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"0 faute. Lecture fluide. Longueur OK. Statut Notion = Texte validé."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Faute découverte après publication → modifier (autorisé 30 min sans perte de portée). Emoji invisible sur Android → remplacer par un emoji standard."},
  {"type":"paragraph","text":"➡️ Étape suivante : transmettre au Designer pour le visuel (voir SOP calendrier édito)."},

  {"type":"divider"},
  {"type":"heading","text":"Templates de posts complets prêts à adapter"},

  {"type":"template","text":"📚 POST ÉDUCATIF — Dentiste\n\n7 patients sur 10 brossent MAL leurs dents 😱\n\nVoici les 3 erreurs les plus fréquentes :\n\n❌ Brosser trop fort = abîme l'émail\n❌ Moins de 2 minutes = pas efficace\n❌ Garder sa brosse > 3 mois = bactéries\n\n✅ La solution ?\nBrosse souple + 2 min chrono + remplacer tous les 3 mois 🦷\n\n💬 Et vous, quelle est votre routine de brossage ?\n\n.\n.\n.\n#oujda #dentisteoujda #santé #santebuccodentaire #brossagedents #sourire #dentiste #maroc #orientalmaroc #cabinetdentaire #oujdacity #dentistemaroc #hygienedentaire #wellness #santeoral"},

  {"type":"template","text":"🎉 POST PROMO — Restaurant\n\nWeekend en famille ? On a CE qu'il vous faut 🍽️\n\nMenu Famille Spécial :\n👨‍👩‍👧‍👦 4 personnes\n🥘 Tajine + Couscous + Salades + Dessert\n☕ Thé à la menthe offert\n💰 380 DH seulement (au lieu de 480 DH)\n\n📅 Valable vendredi, samedi, dimanche uniquement\n📞 Réservez au +212 6XX XXX XXX\n\n.\n.\n.\n#oujda #restaurantoujda #couscous #tajine #cuisinemarocaine #weekend #famille #oujdafood #maroc #oujdacity #foodoujda #orientalmaroc #foodlover #marocfood #restomaroc"},

  {"type":"template","text":"💙 POST INSPIRATIONNEL — Témoignage\n\nMme Aicha n'osait plus sourire depuis 5 ans.\n\nElle est venue nous voir l'hiver dernier, le regard fuyant.\n\nEn 3 séances, sa confiance est revenue.\nSon sourire aussi 😊\n\nC'est pour ces moments qu'on aime ce métier 💙\n\nMerci à elle pour sa confiance.\n\n📩 Vous aussi, écrivez-nous en privé pour un premier RDV gratuit.\n\n.\n.\n.\n#oujda #dentisteoujda #temoignage #confiance #sourire #santé #dentiste #maroc #avantapres #orientalmaroc #cabinetdentaire #oujdacity #estimedesoi #wellness"},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation (avant publication)"},
  {"type":"checklist","items":["Objectif clair défini","Accroche en 1 ligne mobile avec formule (chiffre/question/secret/erreur/transformation)","Développement 3-5 lignes aérées, sans jargon","CTA unique avec verbe d'action et emoji directionnel","15-20 hashtags mix populaires/niches/locaux/secteur","Orthographe vérifiée (Antidote)","Lecture à voix haute fluide","Ton cohérent avec charte client","Statut Notion = Texte validé"]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Sujet sensible (santé sérieuse, juridique, politique, religieux) → NE PAS publier sans validation gérant. WhatsApp +212 620 002 066 avec brouillon avant toute publication."}
]$sop$::jsonb,
    read_min = 14,
    updated_at = now()
WHERE slug = 'ng-cm-copywriting';


-- ────────────────────────────────────────────────────────────────────
-- 4) ng-cm-reels-tiktok
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"À qui s'adresse cette SOP","text":"Community Manager Next Gital qui produit du contenu vidéo court (Reels Instagram, TikTok, Shorts YouTube) pour un client Oujda."},
  {"type":"callout","variant":"tip","title":"Pourquoi le format court","text":"En 2026, les Reels/TikToks génèrent 3 à 5x plus de portée que les posts statiques. C'est LE format roi pour la croissance organique."},
  {"type":"callout","variant":"warning","title":"Règle des 3 secondes","text":"Si le hook (0-3s) n'accroche pas, l'utilisateur scrolle. Toute la production doit être pensée autour de cette première seconde."},
  {"type":"callout","variant":"success","title":"Spécifications techniques","text":"Format vertical 9:16 - Résolution 1080x1920 - Reels Insta max 90s - TikTok max 60s (idéal 15-30s) - Toujours avec sous-titres."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. Choisir le sujet et le format viral"},
  {"type":"paragraph","text":"🎯 Objectif : identifier 1 sujet aligné business + tendance plateforme. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : calendrier édito Notion + veille TikTok du matin."},
  {"type":"paragraph","text":"🖥️ OÙ : TikTok (onglet Tendances) + Instagram (onglet Reels) + Notion calendrier."},
  {"type":"numbered","items":["Ouvrir TikTok → barre recherche → \"Tendances\" → noter 3 trends du moment","Ouvrir Instagram Reels → faire défiler 5 min → identifier formats récurrents","Croiser avec sujets du client (services, produits, expertise)","Choisir 1 sujet précis : ex \"3 erreurs à éviter chez le dentiste\"","Choisir le format : Tutoriel / Avant-Après / Liste / Behind-the-scenes / Storytelling","Vérifier que le sujet ne porte pas atteinte à la déontologie du client (médical surtout)"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — 6 FORMATS QUI FONCTIONNENT :"},
  {"type":"list","items":["**Tutoriel rapide** → \"Comment bien se brosser les dents en 30 secondes\" → valeur immédiate","**Avant/Après** → transformation visuelle (sourire, plat, coupe de cheveux) → impact émotionnel","**Liste type \"3 erreurs\"** → 3 points en 30s → contenu snackable","**Behind the scenes** → coulisses du cabinet, de la cuisine, de l'école → humanise","**Question/Réponse** → \"Vous m'avez demandé...\" → engagement direct","**Storytelling** → histoire d'un client en 30s → émotion forte"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"1 sujet + 1 format choisis, alignés calendrier édito et déontologie client."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Trend non adaptée au client (musique inappropriée) → choisir une autre. Sujet trop large → restreindre à 1 point précis. Format copié trop fidèlement → adapter au business."},
  {"type":"paragraph","text":"➡️ Étape suivante : écrire le script."},

  {"type":"heading2","text":"2. Écrire le script en 3 actes"},
  {"type":"paragraph","text":"🎯 Objectif : script structuré HOOK + VALEUR + CTA en 30s max. ⏱️ Temps : 20 min."},
  {"type":"paragraph","text":"📍 Point de départ : sujet et format choisis."},
  {"type":"paragraph","text":"🖥️ OÙ : Notion (template script Reel)."},
  {"type":"numbered","items":["Ouvrir Notion → créer une carte \"Script Reel [date]\"","Écrire le HOOK (0-3s) : phrase choc qui stoppe le scroll","Écrire la VALEUR (3-25s) : contenu utile, 3 points max","Écrire le CTA (25-30s) : action à faire","Compter les mots : règle 2 mots/seconde → 30s = 60 mots max","Lire à voix haute avec chronomètre → ajuster"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — STRUCTURE SCRIPT TYPE 30s :"},
  {"type":"list","items":["**HOOK (0-3s)** → \"Stop. Vous brossez MAL vos dents.\" → choc + interpellation directe","**VALEUR (3-25s)** → \"Voici les 3 erreurs : 1. Vous brossez trop fort. 2. Moins de 2 minutes. 3. Brosse usée. La bonne méthode : souple, 2 min, changée tous les 3 mois.\" → 3 points clairs","**CTA (25-30s)** → \"Sauvegardez ce Reel pour ne pas l'oublier 📌\" → action simple"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Script tient en 30s à voix haute. 3 actes identifiables. CTA clair."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Script trop long (>60 mots) → couper. Hook fade → reformuler avec choc/question. Pas de CTA → ajouter."},
  {"type":"paragraph","text":"➡️ Étape suivante : tournage."},

  {"type":"heading2","text":"3. Tourner la vidéo (iPhone vertical)"},
  {"type":"paragraph","text":"🎯 Objectif : rushes propres, bien éclairés, son clair. ⏱️ Temps : 30 min sur place."},
  {"type":"paragraph","text":"📍 Point de départ : script imprimé ou téléphone à côté."},
  {"type":"paragraph","text":"🖥️ OÙ : sur place chez le client (cabinet, resto, magasin)."},
  {"type":"numbered","items":["Vérifier matériel : iPhone chargé > 50%, micro-cravate Lavalier si disponible, mini-trépied","Régler iPhone : mode Vidéo, 1080p 30fps, FORMAT VERTICAL 9:16 obligatoire","Vérifier éclairage : face à la lumière naturelle (fenêtre) ou ring light","Vérifier décor : fond propre, marque/logo visible si possible, pas de désordre","Vérifier son : silence autour, micro à 20cm de la bouche, faire un test 5s","Tourner 3 prises minimum par séquence (garde la meilleure au montage)","Vérifier chaque prise sur place (replay) → si flou/mal cadré, refaire"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — RÈGLES TOURNAGE :"},
  {"type":"list","items":["**Cadrage** → règle des tiers, sujet dans le tiers gauche ou droit → ne PAS centrer parfaitement","**Distance** → plan moyen (visage + épaules) ou plan large pour décor → varier","**Mouvement** → bouger légèrement la caméra (slow zoom) pour dynamiser → mais pas tremblant","**Son** → silence absolu autour, micro le plus près possible → audio = 50% de la qualité perçue"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"3 prises minimum par séquence, format 9:16, son audible, éclairage correct."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Format horizontal par erreur → REFAIRE complètement, non rattrapable au montage. Son inaudible → tourner dans pièce plus calme + micro plus près. Flou → bien tenir l'iPhone, mode portrait stable."},
  {"type":"paragraph","text":"➡️ Étape suivante : montage CapCut."},

  {"type":"heading2","text":"4. Monter la vidéo sur CapCut"},
  {"type":"paragraph","text":"🎯 Objectif : vidéo finale 15-30s avec sous-titres, musique, transitions. ⏱️ Temps : 45 min."},
  {"type":"paragraph","text":"📍 Point de départ : rushes transférés sur smartphone."},
  {"type":"paragraph","text":"🖥️ OÙ : application CapCut (gratuite, iOS/Android)."},
  {"type":"numbered","items":["Ouvrir CapCut → Nouveau Projet → importer les rushes","Couper le gras : garder uniquement les meilleures prises","Ajouter transitions courtes entre clips (≤ 0,3s, type \"Cut\" ou \"Flash\")","Ajouter sous-titres AUTO : Texte → Sous-titres automatiques → corriger les erreurs","Styliser les sous-titres : police bold blanche + contour noir + en bas ou milieu","Ajouter musique tendance : Audio → Bibliothèque CapCut → choisir trending Maroc","Régler volume musique à 20-30% pour ne pas couvrir la voix","Ajouter effets si utile : zoom subtil sur moments clés","Vérifier durée finale : 15-30s idéal","Exporter en 1080p 30fps"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — STYLE SOUS-TITRES :"},
  {"type":"list","items":["**Police** → Bold, sans-serif (Helvetica, Montserrat) → lisibilité mobile","**Taille** → 60-80 px → bien visible","**Couleur** → Blanc + contour noir 2px → contraste tous fonds","**Position** → 1/3 inférieur (au-dessus de la barre TikTok) → pas caché par UI","**Animation** → mot-par-mot (CapCut → Animation \"Pop\") → engagement +30%"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Vidéo 15-30s, sous-titres présents et corrigés, musique trending, son équilibré, exportée 1080p."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Sous-titres avec fautes → relire mot par mot après auto. Musique copyrighted → choisir uniquement dans bibliothèque CapCut native. Export raté → vérifier stockage smartphone."},
  {"type":"paragraph","text":"➡️ Étape suivante : préparer la publication."},

  {"type":"heading2","text":"5. Publier sur Instagram Reels et TikTok"},
  {"type":"paragraph","text":"🎯 Objectif : publication sur les 2 plateformes aux heures de pic. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : vidéo finale dans la galerie smartphone."},
  {"type":"paragraph","text":"🖥️ OÙ : application Instagram + application TikTok."},
  {"type":"numbered","items":["Choisir l'heure de publication : 12h-14h (pause déj) OU 18h-21h (soirée)","INSTAGRAM : ouvrir Insta → + → Reel → sélectionner vidéo → Suivant","Ajouter cover : 1ère image attractive avec texte gros (CapCut → vignette personnalisée)","Écrire la légende : reprendre script + hashtags (15-20)","Activer \"Partager sur Facebook\" si client a Page FB liée","Publier","TIKTOK : ouvrir TikTok → + → Upload → sélectionner vidéo","Ajouter description courte + 5-10 hashtags TikTok (#fyp #pourtoi #oujda #maroc + secteur)","Choisir musique TikTok native si possible (au lieu de garder son CapCut)","Publier"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — LÉGENDE TYPE :"},
  {"type":"list","items":["**Instagram Reel** → \"Vous brossez MAL vos dents ? Voici les 3 erreurs à éviter 🦷 Sauvegardez ce Reel pour la routine parfaite 📌 #oujda #dentisteoujda #santé #maroc...\"","**TikTok** → \"Stop ! Vous brossez mal vos dents 😱 #dentiste #santé #oujda #maroc #fyp #pourtoi\" → plus court, plus direct"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Publié sur les 2 plateformes. Cover IG attractive. Description TikTok directe avec #fyp."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Reel refusé Instagram (musique copyright) → remplacer par audio Instagram natif. TikTok signale contenu médical → reformuler description sans claims médicaux. Cover non personnalisée → toujours créer une cover spécifique (sinon image floue auto)."},
  {"type":"paragraph","text":"➡️ Étape suivante : surveiller les performances."},

  {"type":"heading2","text":"6. Surveiller et booster les premières 24h"},
  {"type":"paragraph","text":"🎯 Objectif : maximiser la portée des 24 premières heures (algorithme critique). ⏱️ Temps : 15 min répartis sur 24h."},
  {"type":"paragraph","text":"📍 Point de départ : Reel/TikTok publié."},
  {"type":"paragraph","text":"🖥️ OÙ : Instagram Insights + TikTok Analytics."},
  {"type":"numbered","items":["Dans les 30 min : partager dans la Story Instagram avec sticker \"Voir Reel\"","Répondre à TOUS les commentaires dans les 2 premières heures (boost algo)","Liker tous les commentaires reçus","Inviter le client à liker + commenter avec ses comptes (boost initial)","À H+24 : noter vues + likes + commentaires + partages dans Notion","Si performance >5x moyenne du client → analyser pourquoi et reproduire format","Si performance <50% moyenne → analyser hook (souvent le coupable)"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — KPI À NOTER :"},
  {"type":"list","items":["**Vues** → objectif min : 3x nombre d'abonnés","**Watch time** → objectif min : 70% de la durée totale","**Engagement rate** → (likes+comm+partages+saves) / vues → objectif >5%","**Partages** → KPI numéro 1 de viralité","**Sauvegardes** → KPI numéro 2 (Insta valorise +++)"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Story de partage publiée. Tous commentaires répondus en <2h. KPI notés à H+24 dans Notion."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"0 vues après 1h → vérifier shadowban (compte limité). Engagement faible → hook probablement trop faible. Watch time bas → script trop long ou trop lent."},
  {"type":"paragraph","text":"➡️ Étape suivante : analyser pour le prochain Reel (apprentissage continu)."},

  {"type":"divider"},
  {"type":"heading","text":"Templates de scripts prêts à adapter"},

  {"type":"template","text":"🎬 SCRIPT REEL 30s — Format \"3 erreurs\"\n\n[0-3s HOOK — face caméra, gros plan]\n\"Stop ! Vous brossez MAL vos dents.\"\n\n[3-10s ERREUR 1 — plan rapproché brosse]\n\"Erreur 1 : vous brossez trop fort. L'émail s'use.\"\n\n[10-17s ERREUR 2 — chrono à l'écran]\n\"Erreur 2 : moins de 2 minutes. Pas efficace.\"\n\n[17-24s ERREUR 3 — vieille brosse en main]\n\"Erreur 3 : brosse de plus de 3 mois. Pleine de bactéries.\"\n\n[24-30s CTA — face caméra, sourire]\n\"La solution ? Souple, 2 min, changée tous les 3 mois. Sauvegardez 📌\""},

  {"type":"template","text":"🎬 SCRIPT REEL 20s — Format \"Avant/Après\"\n\n[0-2s HOOK — visage triste, fermé]\n\"Mme Aicha n'osait plus sourire.\"\n\n[2-12s AVANT — photos cabinet, traitement]\n\"Pendant 5 ans, elle cachait ses dents. Puis elle a poussé notre porte. 3 séances plus tard...\"\n\n[12-17s APRÈS — visage rayonnant]\n\"...elle a retrouvé son sourire 😊\"\n\n[17-20s CTA — logo cabinet]\n\"Et vous, qu'attendez-vous ? 📩 DM pour RDV\""},

  {"type":"template","text":"🎬 SCRIPT REEL 25s — Format \"Tutoriel rapide\"\n\n[0-3s HOOK — main qui tient un produit]\n\"Le SECRET pour blanchir vos dents naturellement.\"\n\n[3-20s TUTORIEL — démonstration]\n\"Étape 1 : bicarbonate sur brosse mouillée. Étape 2 : brossage doux 1 min. Étape 3 : rinçage. 2x par semaine MAX.\"\n\n[20-25s CTA — face caméra]\n\"Suivez @drkarim pour plus d'astuces santé 👇\""},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation (avant publication)"},
  {"type":"checklist","items":["Format vertical 9:16 - 1080x1920","Durée 15-30s (max 60s TikTok / 90s Insta)","Hook puissant dès la 1ère seconde","Sous-titres présents et corrigés","Musique tendance (libre de droits)","Volume voix audible / musique à 20-30%","Cover personnalisée créée pour Instagram","Légende avec 15-20 hashtags pertinents","Publié aux heures de pic (12h-14h ou 18h-21h)","Partagé en Story dans les 30 min","Notion mis à jour avec lien publication"]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si Reel publié contient erreur (faute orthographe sous-titre, claim médical risqué, image inappropriée) → supprimer IMMÉDIATEMENT + WhatsApp gérant Next Gital +212 620 002 066. Mieux vaut perdre 1 publication que dégrader image client."}
]$sop$::jsonb,
    read_min = 16,
    updated_at = now()
WHERE slug = 'ng-cm-reels-tiktok';


-- ────────────────────────────────────────────────────────────────────
-- 5) ng-cm-crise-commentaires
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"À qui s'adresse cette SOP","text":"Community Manager qui gère un commentaire négatif, une plainte publique, un bad buzz ou une crise sur les réseaux sociaux d'un client Oujda."},
  {"type":"callout","variant":"danger","title":"Règle absolue n°1","text":"NE JAMAIS supprimer un commentaire négatif (sauf insulte explicite ou spam). Suppression = aveu de culpabilité + scandale Streisand garanti."},
  {"type":"callout","variant":"warning","title":"Règle absolue n°2","text":"TOUJOURS faire une capture d'écran AVANT toute action (réponse, masquage, suppression). Preuve juridique + traçabilité."},
  {"type":"callout","variant":"tip","title":"Règle absolue n°3","text":"24h MAX pour répondre publiquement à toute critique. Au-delà, l'inaction devient le sujet et la crise s'amplifie."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. Détecter et capturer le commentaire"},
  {"type":"paragraph","text":"🎯 Objectif : preuve écrite + classification gravité. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : notification d'un commentaire critique reçue."},
  {"type":"paragraph","text":"🖥️ OÙ : Meta Business Suite (Inbox + Posts) + outil capture écran."},
  {"type":"numbered","items":["Localiser le commentaire dans Meta Business Suite","Faire IMMÉDIATEMENT une capture d'écran complète (commentaire + nom utilisateur + date)","Sauvegarder la capture dans Drive → dossier \"Crises [Nom Client]\" → date-heure dans le nom","NE PAS répondre tout de suite, NE PAS supprimer","Classer la gravité : 🟢 Mineur / 🟡 Modéré / 🔴 Grave","Mineur = malentendu / mécontentement léger","Modéré = plainte argumentée / mauvaise expérience client","Grave = accusation publique / risque juridique / appel au boycott / insulte"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — CLASSIFICATION :"},
  {"type":"list","items":["**🟢 Mineur** → \"Trop cher pour ce que c'est 😕\" → réponse standard rapide","**🟡 Modéré** → \"J'ai attendu 2h pour mon rendez-vous, c'est inadmissible\" → empathie + DM","**🔴 Grave** → \"Cabinet incompétent, je porte plainte\" / \"Restaurant qui empoisonne ses clients\" → STOP, escalade immédiate"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Capture d'écran sauvegardée Drive. Gravité classée. Pas d'action publique encore."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Capture mal cadrée (pas le nom utilisateur visible) → refaire. Drive plein → libérer espace ou demander accès au gérant."},
  {"type":"paragraph","text":"➡️ Étape suivante : décider de la stratégie selon gravité."},

  {"type":"heading2","text":"2. Décider de la stratégie de réponse"},
  {"type":"paragraph","text":"🎯 Objectif : choisir le bon angle (qui répond, ton, public/privé). ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : gravité classée."},
  {"type":"paragraph","text":"🖥️ OÙ : WhatsApp gérant si Modéré/Grave."},
  {"type":"numbered","items":["Si 🟢 Mineur → CM répond seul avec template standard","Si 🟡 Modéré → WhatsApp gérant Next Gital avec capture + proposition de réponse → attendre validation","Si 🔴 Grave → APPEL téléphonique au gérant immédiatement + alerter le client (gérant du business) → réponse uniquement après validation duale","Vérifier si la critique est légitime (chercher le contexte : facture, RDV, commande)","Si critique fondée → empathie obligatoire + solution","Si critique infondée → réponse factuelle, calme, jamais agressive","Toujours répondre publiquement (pour les lecteurs) MAIS proposer de basculer en DM pour résolution"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — TON OBLIGATOIRE :"},
  {"type":"list","items":["**Toujours** → empathie, calme, vouvoiement, signature collective \"L'équipe X\"","**Jamais** → ironie, sarcasme, débat public, accusation en retour, \"vous mentez\", \"c'est faux\"","**Toujours** → reconnaître la frustration même si critique infondée : \"Nous comprenons votre frustration\"","**Jamais** → répondre sous le coup de l'émotion → attendre 10 min minimum"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Stratégie validée par gérant (si modéré/grave). Brouillon de réponse prêt. Aucune réponse impulsive."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Gérant injoignable >30 min → si Grave, alerter client du business directement par téléphone. Critique virale (10+ partages/h) → réunion crise immédiate."},
  {"type":"paragraph","text":"➡️ Étape suivante : rédiger et publier la réponse."},

  {"type":"heading2","text":"3. Rédiger la réponse publique"},
  {"type":"paragraph","text":"🎯 Objectif : réponse calme, empathique, qui désamorce et invite au DM. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : stratégie validée."},
  {"type":"paragraph","text":"🖥️ OÙ : Notion (brouillon) puis Meta Business Suite (publication)."},
  {"type":"numbered","items":["Ouvrir Notion → carte \"Réponse crise [date]\"","Écrire le brouillon en suivant la structure : Salutation + Empathie + Reconnaissance + Action + DM","Faire relire par 1 autre CM ou le gérant (4 yeux)","Une fois validé → copier-coller dans Meta Business Suite","Cliquer Répondre sous le commentaire","Publier","NE PAS engager de débat ensuite : 1 réponse publique = suffisant"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — STRUCTURE :"},
  {"type":"list","items":["**Salutation** → \"Bonjour [Prénom],\" → personnalisation","**Empathie** → \"Nous sommes vraiment désolés de votre expérience\" → reconnaissance émotion","**Reconnaissance** → \"Votre retour est important pour nous\" → valorise le client","**Action** → \"Nous souhaitons comprendre ce qui s'est passé\" → engagement","**DM** → \"Pouvez-vous nous écrire en message privé pour qu'on règle cela ensemble ? 🙏\" → basculement privé","**Signature** → \"L'équipe [Nom Client]\" → collectif, pas individuel"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Réponse publiée publiquement, calme, invitant au DM. Aucune réponse impulsive sous le coup de l'émotion."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Le plaignant répond plus agressivement → NE PAS surenchérir, 1 seconde réponse \"Nous restons à votre écoute en DM\" et stop. Autres utilisateurs s'invitent dans le débat → ignorer, ne pas répondre à chaque commentaire."},
  {"type":"paragraph","text":"➡️ Étape suivante : tentative de résolution en DM."},

  {"type":"heading2","text":"4. Résoudre en message privé (DM)"},
  {"type":"paragraph","text":"🎯 Objectif : trouver une solution concrète et obtenir si possible la suppression/modification du commentaire. ⏱️ Temps : 30 min à plusieurs jours selon dossier."},
  {"type":"paragraph","text":"📍 Point de départ : client a basculé en DM."},
  {"type":"paragraph","text":"🖥️ OÙ : Inbox Meta Business Suite."},
  {"type":"numbered","items":["Vérifier que le client a écrit en DM (relancer doucement après 24h si pas de DM)","Lire ATTENTIVEMENT son message → ne pas répondre dans la précipitation","Confirmer les faits avec le gérant (vérifier facture, RDV, commande dans GestiQ)","Si plainte fondée → présenter excuses claires + proposition de solution concrète (geste commercial, rappel, remboursement)","Si plainte infondée → présenter la version des faits avec preuves (calmement)","Trouver un terrain d'entente : avoir gardé un client > être \"avoir raison\"","Une fois résolu → demander gentiment : \"Seriez-vous d'accord pour mettre à jour votre commentaire ?\"","Documenter la résolution dans GestiQ → fiche client → onglet Incidents"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — GESTES COMMERCIAUX TYPES :"},
  {"type":"list","items":["**Restaurant** → repas offert pour 2, bon réduction 30%","**Dentiste** → consultation gratuite, geste sur prochain soin","**Pharmacie** → bon d'achat, livraison gratuite","**École** → entretien avec direction, geste sur trimestre suivant","**Boulangerie** → café + viennoiserie offerts"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Solution proposée. Client a accusé réception. Si possible, commentaire public mis à jour ou supprimé par lui-même."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Client ne répond plus au DM → relance après 48h puis 7 jours puis abandon. Demande disproportionnée (remboursement énorme) → escalade gérant. Menace de procès → escalade IMMÉDIATE + arrêt total des échanges."},
  {"type":"paragraph","text":"➡️ Étape suivante : surveiller la propagation."},

  {"type":"heading2","text":"5. Surveiller la propagation pendant 7 jours"},
  {"type":"paragraph","text":"🎯 Objectif : détecter une éventuelle viralisation et y répondre tôt. ⏱️ Temps : 10 min/jour pendant 7 jours."},
  {"type":"paragraph","text":"📍 Point de départ : crise initiale traitée."},
  {"type":"paragraph","text":"🖥️ OÙ : Meta Business Suite + recherche Google + recherche réseaux."},
  {"type":"numbered","items":["Surveiller les commentaires du post concerné chaque jour","Surveiller les mentions du compte client (notifications + tag)","Faire une recherche Google : \"Nom Client + avis\" + \"Nom Client + plainte\"","Vérifier groupes Facebook Oujda Business (capture si discussion)","Surveiller Google Maps reviews → souvent point de fuite","Si nouvelle critique apparaît → recommencer SOP étape 1","Si silence total après 7 jours → crise désamorcée, documenter retour d'expérience"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Surveillance quotidienne effectuée pendant 7 jours. Aucune nouvelle viralisation. Crise close."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Avis Google Maps négatif → répondre publiquement aussi (même format). Reprise dans presse locale → escalade IMMÉDIATE gérant + client + communication coordonnée."},
  {"type":"paragraph","text":"➡️ Étape suivante : retour d'expérience."},

  {"type":"heading2","text":"6. Retour d'expérience et amélioration"},
  {"type":"paragraph","text":"🎯 Objectif : tirer des leçons pour éviter la prochaine crise. ⏱️ Temps : 20 min."},
  {"type":"paragraph","text":"📍 Point de départ : crise close (7 jours sans nouvelle activité)."},
  {"type":"paragraph","text":"🖥️ OÙ : Notion → page \"Retours crises\"."},
  {"type":"numbered","items":["Créer une fiche \"Retour d'expérience [date]\" dans Notion","Décrire les faits : nature de la critique, gravité initiale, viralité","Décrire les actions menées (chronologie)","Identifier la cause racine : faute opérationnelle du client ? Malentendu ? Concurrent ?","Identifier 1-3 actions d'amélioration : formation équipe client, modification process, nouvelle SOP","Partager le retour d'expérience avec le gérant + client","Mettre à jour cette SOP si nouvelle leçon importante"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Fiche retour d'expérience écrite, partagée, actions correctives identifiées."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Client refuse d'admettre faute opérationnelle → présenter données factuelles. Pas le temps de faire le retour d'expérience → l'imposer dans le forfait, c'est le plus important."},
  {"type":"paragraph","text":"➡️ Étape suivante : crise officiellement clôturée."},

  {"type":"divider"},
  {"type":"heading","text":"Templates de réponses publiques"},

  {"type":"template","text":"💬 RÉPONSE PUBLIQUE — Plainte mineure\n\nBonjour [Prénom],\n\nMerci pour votre retour, nous le prenons au sérieux 🙏\n\nVotre satisfaction est notre priorité. Pouvez-vous nous écrire en message privé afin que nous puissions mieux comprendre ce qui s'est passé et trouver une solution ensemble ?\n\nÀ très vite,\nL'équipe [Nom Client]"},

  {"type":"template","text":"💬 RÉPONSE PUBLIQUE — Plainte modérée\n\nBonjour [Prénom],\n\nNous sommes sincèrement désolés de cette expérience qui ne reflète pas du tout nos valeurs et nos engagements habituels.\n\nVotre retour est précieux et nous souhaitons comprendre exactement ce qui s'est passé pour vous apporter une réponse personnalisée.\n\nPouvez-vous nous écrire en message privé ? Nous prenons immédiatement le temps de traiter votre dossier 🙏\n\nMerci de votre patience,\nL'équipe [Nom Client]"},

  {"type":"template","text":"💬 RÉPONSE PUBLIQUE — Critique sur prix (mineur)\n\nBonjour [Prénom],\n\nMerci pour votre commentaire 🙏\n\nNos tarifs reflètent la qualité de nos produits/services et le travail de notre équipe. Nous restons toutefois à votre écoute pour vous proposer la formule la plus adaptée à votre besoin.\n\n📩 N'hésitez pas à nous écrire en privé pour qu'on en discute ensemble.\n\nL'équipe [Nom Client]"},

  {"type":"template","text":"💬 RÉPONSE PUBLIQUE — Critique infondée (grave)\n\n[À NE PUBLIER QU'APRÈS VALIDATION GÉRANT + CLIENT]\n\nBonjour [Prénom],\n\nNous prenons votre message très au sérieux. Cependant, les faits décrits ne correspondent pas à notre fonctionnement habituel et nous souhaitons éclaircir cette situation avec vous personnellement.\n\nPouvez-vous nous contacter en message privé ou au [téléphone] afin que nous puissions échanger et comprendre ?\n\nNous restons disponibles,\nL'équipe [Nom Client]"},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation (à chaque crise)"},
  {"type":"checklist","items":["Capture d'écran sauvegardée Drive AVANT toute action","Gravité classée (🟢/🟡/🔴)","Validation gérant obtenue si modéré/grave","Brouillon relu par 4 yeux","Réponse publique calme et empathique publiée < 24h","Tentative DM ouverte avec le plaignant","Documentation dans GestiQ (fiche incident)","Surveillance 7 jours assurée","Retour d'expérience écrit dans Notion"]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade IMMÉDIATE","text":"Toute crise 🔴 grave (menace juridique, mise en cause santé/sécurité, accusation diffamation, appel boycott, reprise presse) → APPEL téléphonique gérant Next Gital +212 620 002 066 dans les 30 minutes. NE RIEN publier sans validation duale. La discrétion et la rapidité sont vitales."}
]$sop$::jsonb,
    read_min = 15,
    updated_at = now()
WHERE slug = 'ng-cm-crise-commentaires';


-- ────────────────────────────────────────────────────────────────────
-- 6) ng-cm-rapport-mensuel
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"À qui s'adresse cette SOP","text":"Community Manager Next Gital qui doit produire le rapport mensuel de performance réseaux sociaux pour un client Oujda (entre le 1er et le 5 du mois M+1)."},
  {"type":"callout","variant":"tip","title":"Pourquoi un rapport mensuel","text":"1) Justifie la facturation. 2) Montre la valeur du travail. 3) Pilote la stratégie du mois suivant. 4) Fidélise le client. C'est l'outil n°1 de rétention."},
  {"type":"callout","variant":"warning","title":"Deadline absolue","text":"Le rapport DOIT être envoyé au client AVANT le 5 du mois M+1. Au-delà = sentiment d'amateurisme et risque de résiliation."},
  {"type":"callout","variant":"success","title":"Outils utilisés","text":"Meta Business Suite Insights (data) + Google Slides ou Canva (mise en forme) + GestiQ (archivage)."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. Extraire les données de Meta Business Suite Insights"},
  {"type":"paragraph","text":"🎯 Objectif : récupérer toutes les données chiffrées du mois M. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"📍 Point de départ : 1er du mois M+1, ordinateur."},
  {"type":"paragraph","text":"🖥️ OÙ : business.facebook.com → Insights → onglet du client."},
  {"type":"numbered","items":["Ouvrir Meta Business Suite → sélectionner le client","Cliquer sur Insights dans le menu gauche","Régler la période : mois écoulé complet (1er au 30/31)","Onglet \"Aperçu\" → noter : reach total FB+IG, impressions, visites de profil","Onglet \"Audience\" → noter : abonnés gagnés, abonnés perdus, total fin de mois","Onglet \"Contenu\" → identifier les 3 posts top performance (par reach, engagement)","Onglet \"Inbox\" → noter : nb messages reçus, temps moyen de réponse","Exporter en CSV si disponible (Insights → Export)","Faire la même chose pour Instagram (instagram.com → Pro Dashboard → Insights)"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — KPI À COLLECTER :"},
  {"type":"list","items":["**Reach** → personnes uniques touchées → KPI notoriété","**Impressions** → nb total d'affichages (peut être > reach) → KPI visibilité","**Engagement** → likes + commentaires + partages + sauvegardes → KPI interaction","**Engagement Rate** → engagement / reach → KPI qualité contenu (cible >3%)","**Abonnés gagnés / perdus** → croissance nette → KPI fidélisation","**Visites profil** → curiosité → KPI intention","**Clics lien bio** → trafic site → KPI conversion","**Messages reçus** → leads potentiels → KPI business","**Temps moyen de réponse** → réactivité CM → KPI service"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Toutes les KPI notées dans un tableau (Google Sheet ou Notion) pour FB et IG séparément + total."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Insights ne charge pas → vider cache navigateur. Données IG incomplètes → utiliser app mobile Insights complète. Export CSV indisponible → recopier manuellement."},
  {"type":"paragraph","text":"➡️ Étape suivante : comparer avec le mois précédent."},

  {"type":"heading2","text":"2. Comparer avec le mois M-1 (variation)"},
  {"type":"paragraph","text":"🎯 Objectif : montrer l'évolution claire +/- vs mois dernier. ⏱️ Temps : 20 min."},
  {"type":"paragraph","text":"📍 Point de départ : KPI mois M collectés."},
  {"type":"paragraph","text":"🖥️ OÙ : Google Sheet \"Reporting [Client]\" (1 onglet par mois)."},
  {"type":"numbered","items":["Ouvrir le Google Sheet de reporting du client","Aller chercher les KPI du mois M-1 (onglet précédent)","Calculer la variation pour chaque KPI : ((M - M-1) / M-1) × 100","Coder visuellement : 🟢 vert si > +10%, 🟡 jaune si entre -10% et +10%, 🔴 rouge si < -10%","Identifier la KPI la plus en progression (la mettre en avant dans le rapport)","Identifier la KPI la plus en régression (à expliquer dans le rapport)","Faire une moyenne mobile 3 mois pour lisser les variations"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — EXEMPLE DE COMPARAISON :"},
  {"type":"list","items":["**Reach** → 12 500 (M) vs 8 200 (M-1) = +52% 🟢 → effet de la stratégie Reels","**Abonnés gagnés** → +145 (M) vs +98 (M-1) = +48% 🟢 → effet posts viraux","**Engagement Rate** → 2.8% (M) vs 3.5% (M-1) = -20% 🔴 → audience plus large mais moins ciblée"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tableau comparatif rempli avec variations en % et codes couleur. 1 progression et 1 régression identifiées."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pas de données M-1 (1er mois mission) → mentionner \"mois de référence\" et faire les comparaisons à partir de M+1. Variation extrême (>200%) → vérifier données ou expliquer (ex : 1 post viral)."},
  {"type":"paragraph","text":"➡️ Étape suivante : analyser le top 3 contenus."},

  {"type":"heading2","text":"3. Analyser le top 3 et le flop 3 contenus"},
  {"type":"paragraph","text":"🎯 Objectif : comprendre ce qui a marché et pourquoi. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"📍 Point de départ : Insights Contenu ouvert."},
  {"type":"paragraph","text":"🖥️ OÙ : Meta Business Suite → Insights → Contenu → trier par engagement."},
  {"type":"numbered","items":["Trier les posts du mois par reach décroissant","Identifier le TOP 3 (les 3 meilleurs)","Capturer chaque post (screenshot)","Pour chaque top : noter format (post/Reel/Story), sujet, type (éducatif/promo/etc.), heure de publication, nb vues/likes/commentaires","Identifier le FLOP 3 (les 3 moins performants)","Pour chaque flop : noter les mêmes infos","Analyser les patterns : Quel format gagne ? Quel thème échoue ? Quel jour/heure ?","Tirer 3 insights actionnables pour le mois suivant"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — INSIGHTS TYPES :"},
  {"type":"list","items":["**Insight format** → \"Les Reels font 4x le reach des posts statiques\" → recommandation : +50% Reels mois prochain","**Insight thème** → \"Les contenus éducatifs convertissent 2x plus en DM que les promos\" → recommandation : +20% éducatif","**Insight timing** → \"Posts du jeudi 19h font +60% engagement\" → recommandation : créneau récurrent jeudi 19h"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Top 3 + Flop 3 capturés. 3 insights actionnables identifiés et rédigés."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pas assez de posts pour identifier patterns (< 8 posts/mois) → faire l'analyse en cumulé 2 mois. Tous les posts ont des perfs similaires → analyser sur engagement rate plutôt que reach."},
  {"type":"paragraph","text":"➡️ Étape suivante : rédiger les recommandations."},

  {"type":"heading2","text":"4. Rédiger 3 recommandations pour le mois suivant"},
  {"type":"paragraph","text":"🎯 Objectif : 3 axes d'amélioration concrets pour le mois M+1. ⏱️ Temps : 20 min."},
  {"type":"paragraph","text":"📍 Point de départ : insights identifiés."},
  {"type":"paragraph","text":"🖥️ OÙ : Notion (brouillon rapport)."},
  {"type":"numbered","items":["Définir 3 axes (pas 5, pas 10 — exactement 3 pour rester actionnable)","Pour chaque axe : Pourquoi (insight) + Quoi (action) + Comment (concrètement) + Quand (calendrier)","Formuler en langage simple, sans jargon technique","Quantifier l'objectif visé : ex \"viser +30% reach\"","Aligner les recommandations avec les objectifs business du client (RDV, ventes)","Ne pas être trop ambitieux : 3 actions réalisables > 10 actions abandonnées"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — 3 RECOMMANDATIONS TYPES :"},
  {"type":"list","items":["**Axe 1 — Doubler les Reels** → Pourquoi : Reels font 4x le reach. Quoi : passer de 2 à 4 Reels/semaine. Comment : tournage groupé 2x/mois au cabinet. Quand : démarrage 1er juin.","**Axe 2 — Tester un Live Instagram** → Pourquoi : 0 live fait, fort potentiel engagement. Quoi : 1 Live Q&A santé. Comment : annoncer 1 semaine avant, 30 min en direct. Quand : 15 juin 18h.","**Axe 3 — Optimiser les heures de publication** → Pourquoi : jeudi 19h = +60% engagement. Quoi : 2 posts/sem sur ce créneau. Comment : adapter calendrier édito. Quand : dès le 1er juin."]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"3 recommandations claires, chiffrées, actionnables, alignées objectifs business."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Recommandations trop génériques (\"poster plus\") → préciser combien, quoi, quand. Recommandations infaisables (\"campagne TV\") → rester dans le périmètre RS. Désaccord interne sur priorités → trancher avec gérant."},
  {"type":"paragraph","text":"➡️ Étape suivante : mise en page du rapport."},

  {"type":"heading2","text":"5. Mettre en page le rapport (Canva)"},
  {"type":"paragraph","text":"🎯 Objectif : rapport PDF 6-10 pages, designé, lisible. ⏱️ Temps : 1h30."},
  {"type":"paragraph","text":"📍 Point de départ : toutes les données collectées."},
  {"type":"paragraph","text":"🖥️ OÙ : canva.com → template \"Rapport mensuel social media\" (workspace Next Gital)."},
  {"type":"numbered","items":["Ouvrir Canva → dossier Next Gital → dupliquer template Rapport mensuel","Renommer : \"Rapport [Client] - [Mois Année]\"","Page 1 — Couverture : logo client + Next Gital + Mois Année + nom CM","Page 2 — Sommaire + résumé exécutif (3 chiffres clés en gros)","Page 3 — Vue d'ensemble KPI : tableau M vs M-1 avec variations colorées","Page 4 — Croissance audience : graphique abonnés + visites profil","Page 5 — Top 3 posts : 3 captures + KPI de chaque","Page 6 — Flop 3 + analyse : ce qui n'a pas marché et pourquoi","Page 7 — Insights : 3 enseignements en bullet points","Page 8 — Recommandations : les 3 axes pour M+1 détaillés","Page 9 — Calendrier édito M+1 : aperçu","Page 10 — Conclusion + contact Next Gital","Exporter en PDF haute qualité"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — STYLE :"},
  {"type":"list","items":["**Polices** → 2 polices max (1 titre, 1 corps), reprendre charte client si possible","**Couleurs** → palette client + 1 couleur accent Next Gital (bleu #1E88E5)","**Visuels** → screenshots de qualité, graphiques Canva (camemberts, barres)","**Lisibilité** → contraste fort, taille texte min 14pt, espacement aéré"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"PDF 6-10 pages designé, charte respectée, lisible mobile et desktop, exporté en HD."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Template Canva surchargé → simplifier. Graphiques illisibles → augmenter taille + contraste. PDF trop lourd (>10 MB) → exporter en \"PDF Standard\" plutôt que Print."},
  {"type":"paragraph","text":"➡️ Étape suivante : envoyer au client."},

  {"type":"heading2","text":"6. Envoyer le rapport au client + archiver dans GestiQ"},
  {"type":"paragraph","text":"🎯 Objectif : rapport reçu par le client + traçabilité interne. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : PDF final prêt."},
  {"type":"paragraph","text":"🖥️ OÙ : Gmail (envoi) + GestiQ (archivage) + WhatsApp (notification)."},
  {"type":"numbered","items":["Ouvrir Gmail → nouveau message au client","Objet : \"Rapport mensuel [Mois Année] — [Nom Entreprise]\"","Corps : message court + 3 chiffres clés + invitation à RDV de débrief","Joindre le PDF","Envoyer","Envoyer également WhatsApp client : \"Rapport envoyé par mail, dispo pour échanger 🙏\"","Uploader le PDF dans GestiQ → fiche client → onglet Documents → catégorie Rapports","Mettre à jour le suivi GestiQ → tâche \"Rapport M envoyé\" cochée","Programmer RDV de débrief si client engagé (15-30 min en visio ou téléphone)"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — EMAIL TYPE :"},
  {"type":"list","items":["**Objet** → \"Rapport mensuel Mai 2026 — Dr. Karim\" → clair","**Salutation** → \"Bonjour Dr. Karim,\"","**Accroche** → \"Voici le rapport de performance du mois de mai. Bilan très positif avec +52% de reach et +145 nouveaux abonnés 📈\"","**Invitation** → \"Je vous propose un point de 20 min cette semaine pour discuter des recommandations du mois prochain. Êtes-vous dispo jeudi à 14h ?\"","**Signature** → \"Cordialement, [Prénom CM] - Next Gital\""]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Mail envoyé. WhatsApp envoyé. PDF archivé GestiQ. Tâche cochée. RDV débrief proposé."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Client n'ouvre pas le mail → relance WhatsApp + appel. Client demande des modifs → faire dans les 48h. Client demande des KPI non collectées → ajouter pour le rapport suivant."},
  {"type":"paragraph","text":"➡️ Étape suivante : préparer le calendrier édito du mois suivant (voir SOP calendrier édito)."},

  {"type":"divider"},
  {"type":"heading","text":"Templates emails et messages"},

  {"type":"template","text":"📧 EMAIL — Envoi rapport mensuel\n\nObjet : Rapport mensuel [Mois Année] — [Nom Entreprise]\n\nBonjour [Prénom],\n\nJ'espère que vous allez bien.\n\nVoici en pièce jointe le rapport complet de performance de [Mois] pour [Nom Entreprise].\n\nLes 3 chiffres clés à retenir :\n📈 +X% de reach vs mois précédent\n👥 +X nouveaux abonnés\n💬 X messages reçus, X DM convertis en RDV\n\nLes recommandations détaillées pour [Mois M+1] sont en page 8.\n\nJe vous propose un point téléphonique de 20 minutes cette semaine pour échanger sur ces résultats et la stratégie du mois prochain.\n\nÊtes-vous disponible [jour] à [heure] ?\n\nBien cordialement,\n[Prénom CM]\nNext Gital - Oujda\n+212 620 002 066\nnextgital.tech"},

  {"type":"template","text":"📱 WHATSAPP — Notification envoi rapport\n\nBonjour [Prénom] 👋\n\nJe viens de vous envoyer par mail le rapport mensuel de [Mois] pour [Nom Entreprise] 📊\n\nBeau mois avec +X% de reach 🎉\n\nDispo pour un point de 20 min cette semaine si vous souhaitez qu'on échange sur la stratégie de [Mois M+1] 🙏\n\nBelle journée,\n[Prénom CM] - Next Gital"},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation (avant envoi)"},
  {"type":"checklist","items":["Toutes les KPI collectées (reach, abonnés, engagement, etc.)","Comparaison M vs M-1 calculée pour chaque KPI","Top 3 + Flop 3 posts identifiés et analysés","3 insights actionnables rédigés","3 recommandations claires et chiffrées","PDF 6-10 pages designé en charte client","Aucune faute d'orthographe (relecture 2x)","Email envoyé avant le 5 du mois","WhatsApp client envoyé","PDF archivé dans GestiQ","RDV débrief proposé au client"]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si rapport montre tendance négative grave (perte abonnés massive, engagement effondré) → APPEL gérant Next Gital +212 620 002 066 AVANT envoi au client. Préparer ensemble plan de redressement à présenter dans le même rapport. Ne jamais envoyer un rapport rouge sans solution."}
]$sop$::jsonb,
    read_min = 17,
    updated_at = now()
WHERE slug = 'ng-cm-rapport-mensuel';


COMMIT;

-- ════════════════════════════════════════════════════════════════════
--  FIN Migration 045 — 6 SOPs Community Manager ultra-détaillés
-- ════════════════════════════════════════════════════════════════════
