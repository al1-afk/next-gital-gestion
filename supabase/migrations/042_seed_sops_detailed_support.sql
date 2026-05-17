-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 042 : SOPs ultra-détaillés Support Client
--  Date : 2026-05-17
--  Cible : ng-sup-tickets, ng-sup-wordpress-fixes, ng-sup-scope-creep,
--          ng-sup-avis-google, ng-sup-formation-client, ng-sup-rapport-mensuel
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ────────────────────────────────────────────────────────────────────
-- 1) ng-sup-tickets — Système de tickets Support
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏱️ Délais SLA Next Gital","text":"🔴 Critique : 1ère réponse < 1h · résolution < 4h. 🟠 Urgent : < 2h / < 24h. 🟡 Normal : < 4h / < 48h. 🟢 Faible : < 24h / < 72h. ⚪ Info : < 1 semaine."},
  {"type":"callout","variant":"info","title":"📞 Canaux d'entrée","text":"WhatsApp Business +212 620 002 066 · Email info@nextgital.com · Formulaire site nextgital.tech/support. TOUT ticket doit être créé dans GestiQ (gestiq.nextgital.tech → Tickets)."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"AUCUN ticket ne reste sans accusé de réception > 30 min en heures ouvrables (9h-19h Lun-Sam). Si tu pars en pause, transfère sur WhatsApp +212 620 002 066."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. RÉCEPTION & QUALIFICATION DU TICKET"},
  {"type":"paragraph","text":"🎯 Objectif : capturer la demande et lui attribuer une priorité. ⏱️ Temps : 3 min."},
  {"type":"paragraph","text":"📍 Point de départ : message reçu (WhatsApp / email / formulaire)."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → gestiq.nextgital.tech → menu gauche → Tickets → bouton vert + Nouveau."},
  {"type":"numbered","items":["Lire le message en entier (ne jamais répondre après 1 ligne lue)","Identifier le client (chercher fiche dans Clients)","Cliquer + Nouveau ticket","Remplir les champs ci-dessous","Sauvegarder (Ctrl+S)"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Titre** → résumé en 1 phrase action+objet → « Site Cabinet Fedix : page contact 404 » → ne PAS écrire « problème site »","**Client** → lier la fiche existante (autocomplete) → Cabinet Fedix → ne PAS créer doublon","**Priorité** → cf. matrice intro → 🔴 si site DOWN, 🟠 si bug bloquant 1 page, 🟡 si demande modif","**Canal source** → WhatsApp / Email / Form","**Description** → copier-coller le message brut + capture si fournie"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le ticket apparaît dans la liste avec statut « Ouvert » et la priorité colorée."},

  {"type":"heading2","text":"2. ACCUSÉ DE RÉCEPTION IMMÉDIAT"},
  {"type":"paragraph","text":"🎯 Objectif : rassurer le client en < 15 min. ⏱️ Temps : 2 min."},
  {"type":"paragraph","text":"🖥️ OÙ : canal d'origine (WhatsApp ou Email)."},
  {"type":"numbered","items":["Copier le numéro de ticket (#NG-2026-XXXX)","Envoyer le template ACK ci-dessous","Coller le numéro dans le message","Côté GestiQ : changer statut → « En cours »"]},
  {"type":"template","text":"Bonjour Dr. Karim,\n\nBien reçu votre message. Votre demande est enregistrée sous le ticket #NG-2026-0142 (priorité 🟠 Urgent).\n\nJe regarde immédiatement et reviens vers vous sous 2h max avec un premier retour.\n\nMerci de votre patience.\nÉquipe Next Gital · +212 620 002 066"},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Client relance avant l'accusé → tu as dépassé 30 min, présente excuse + envoie ACK. Client envoie 2 demandes différentes → crée 2 tickets séparés."},

  {"type":"heading2","text":"3. INVESTIGATION TECHNIQUE"},
  {"type":"paragraph","text":"🎯 Objectif : comprendre la cause racine. ⏱️ Temps : 5-15 min."},
  {"type":"paragraph","text":"🖥️ OÙ : selon le type → wp-admin, hPanel Hostinger, Titan, GA4."},
  {"type":"numbered","items":["Reproduire le bug toi-même (URL exacte, navigateur, mobile/desktop)","Capture d'écran de l'erreur","Vérifier logs (hPanel → Avancé → Journaux d'erreurs)","Identifier : front / back / hébergement / DNS / plugin","Noter dans le ticket → onglet « Notes internes »"]},
  {"type":"callout","variant":"tip","title":"💡 Astuce","text":"Toujours tester en navigation privée pour exclure le cache navigateur du client."},

  {"type":"heading2","text":"4. COMMUNICATION ÉTAPE PAR ÉTAPE"},
  {"type":"paragraph","text":"🎯 Objectif : tenir le client informé sans le saouler. ⏱️ Temps : 2 min × N."},
  {"type":"paragraph","text":"📍 Règle : 1 message par étape clé (diagnostic posé, fix lancé, fix terminé)."},
  {"type":"template","text":"Bonjour Dr. Karim,\n\nMise à jour ticket #NG-2026-0142 :\n✅ Cause identifiée : un plugin SEO en conflit\n⏳ Correctif en cours, ETA 30 min\n\nJe vous reconfirme dès résolution.\nNext Gital"},

  {"type":"heading2","text":"5. RÉSOLUTION & TEST"},
  {"type":"paragraph","text":"🎯 Objectif : appliquer le fix et vérifier. ⏱️ Temps : variable."},
  {"type":"numbered","items":["Appliquer le correctif","Re-tester l'URL en navigation privée + mobile","Demander au client de tester de son côté","Attendre confirmation"]},

  {"type":"heading2","text":"6. CLÔTURE & TRAÇABILITÉ"},
  {"type":"paragraph","text":"🎯 Objectif : fermer proprement le ticket. ⏱️ Temps : 3 min."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → ticket → bouton « Clôturer »."},
  {"type":"list","items":["**Solution appliquée** → 2-3 phrases techniques","**Temps total** → auto-calculé","**Cause racine** → plugin / config / humain / hébergeur","**Action préventive** → ajouter au monitoring ? formation client ?"]},
  {"type":"template","text":"Bonjour Dr. Karim,\n\n✅ Ticket #NG-2026-0142 résolu.\nLa page contact est de nouveau opérationnelle.\n\nN'hésitez pas si vous constatez autre chose.\nBonne journée,\nNext Gital"},
  {"type":"paragraph","text":"➡️ Étape suivante : J+2 → demande d'avis Google (cf. SOP ng-sup-avis-google)."},

  {"type":"divider"},
  {"type":"heading","text":"Templates de messages"},
  {"type":"template","text":"[ACK] Bonjour {prénom}, bien reçu — ticket #{num} ({priorité}). Réponse sous {SLA}. Next Gital."},
  {"type":"template","text":"[UPDATE] Mise à jour ticket #{num} : {étape}. ETA {temps}. NG"},
  {"type":"template","text":"[CLOSE] Ticket #{num} ✅ résolu. {solution}. À votre dispo. NG"},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":["Ticket créé dans GestiQ avec n°","Priorité définie selon matrice","Accusé envoyé < 15 min","Investigation documentée en notes internes","Client tenu informé à chaque étape","Fix testé en privé + mobile","Confirmation client reçue","Cause racine + action préventive renseignées","Statut → Clôturé"]},
  {"type":"callout","variant":"danger","title":"🆘 Escalade","text":"Si > 30 min bloqué OU client mécontent OU site DOWN → WhatsApp fondateur +212 620 002 066 (24/7)."}
]$sop$::jsonb,
    read_min = 12,
    updated_at = now()
WHERE slug = 'ng-sup-tickets';

-- ────────────────────────────────────────────────────────────────────
-- 2) ng-sup-wordpress-fixes — Support WordPress
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏱️ Délai cible","text":"Diagnostic < 30 min · Fix simple < 1h · Rollback < 15 min. Au-delà → escalade dev."},
  {"type":"callout","variant":"info","title":"🛠️ Outils","text":"wp-admin du client · hPanel Hostinger · UpdraftPlus (backups) · phpMyAdmin · Query Monitor (debug)."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"AVANT toute modif → sauvegarde UpdraftPlus manuelle. JAMAIS modifier directement wp-config.php sans backup FTP."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. REPRODUCTION DU BUG"},
  {"type":"paragraph","text":"🎯 Objectif : voir le bug avec tes yeux. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"🖥️ OÙ : URL exacte communiquée par le client."},
  {"type":"numbered","items":["Ouvrir l'URL en navigation privée (Cmd+Shift+N)","Tester desktop ET mobile (DevTools → Responsive)","Capture d'écran horodatée","Noter le message d'erreur exact","Tester un autre navigateur si pas reproduit"]},
  {"type":"callout","variant":"warning","title":"⚠️ Si non reproduit","text":"Vide le cache CDN (Cloudflare → Purge) + demande au client une capture + navigateur + heure exacte."},

  {"type":"heading2","text":"2. SAUVEGARDE PRÉVENTIVE"},
  {"type":"paragraph","text":"🎯 Objectif : pouvoir revenir en arrière. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"🖥️ OÙ : wp-admin → UpdraftPlus → Sauvegarder maintenant."},
  {"type":"numbered","items":["Cocher : Fichiers + Base de données","Décocher : Envoi distant (gain de temps)","Lancer → attendre fin (3-10 min)","Vérifier dans « Sauvegardes existantes »"]},

  {"type":"heading2","text":"3. DIAGNOSTIC PAR ÉLIMINATION"},
  {"type":"paragraph","text":"🎯 Objectif : isoler la cause. ⏱️ Temps : 10-20 min."},
  {"type":"paragraph","text":"🖥️ OÙ : wp-admin → Extensions."},
  {"type":"numbered","items":["Activer mode debug : hPanel → Fichiers → wp-config.php → WP_DEBUG = true","Désactiver TOUS les plugins (sauf UpdraftPlus)","Tester → si bug parti : réactiver plugin par plugin","Identifier le plugin coupable","Vérifier logs : hPanel → Avancé → Journaux d'erreurs"]},
  {"type":"paragraph","text":"✏️ CAUSES FRÉQUENTES :"},
  {"type":"list","items":["**Conflit plugin** → désactiver + chercher alternative","**Thème obsolète** → mettre à jour ou switcher temporairement sur Twenty Twenty-Four","**PHP version** → hPanel → PHP → passer en 8.1+","**Permaliens cassés** → Réglages → Permaliens → Enregistrer (sans rien changer)","**Cache W3TC/WP Rocket** → vider tous les caches"]},

  {"type":"heading2","text":"4. APPLICATION DU FIX"},
  {"type":"paragraph","text":"🎯 Objectif : corriger proprement. ⏱️ Temps : variable."},
  {"type":"numbered","items":["Appliquer la modif minimum nécessaire","Désactiver WP_DEBUG (remettre false)","Vider cache serveur + CDN","Re-tester navigation privée"]},
  {"type":"callout","variant":"tip","title":"💡 Astuce","text":"Si fix dans functions.php → toujours via plugin Code Snippets, jamais en éditant le thème directement."},

  {"type":"heading2","text":"5. ROLLBACK D'URGENCE (si fix casse plus)"},
  {"type":"paragraph","text":"🎯 Objectif : revenir à l'état d'avant en 15 min. ⏱️ Temps : 10-15 min."},
  {"type":"paragraph","text":"🖥️ OÙ : wp-admin → UpdraftPlus → Sauvegardes existantes."},
  {"type":"numbered","items":["Trouver la sauvegarde de l'étape 2","Cliquer « Restaurer »","Cocher : Plugins + Thèmes + DB (selon besoin)","Confirmer → attendre 5-10 min","Vérifier que le site est OK"]},
  {"type":"callout","variant":"warning","title":"⚠️ Si UpdraftPlus échoue","text":"Backup hPanel : hPanel → Sauvegardes → Restaurer (dernière sauvegarde Hostinger auto)."},

  {"type":"heading2","text":"6. VALIDATION CLIENT & CLÔTURE"},
  {"type":"paragraph","text":"🎯 Objectif : confirmation client + ticket fermé. ⏱️ Temps : 5 min."},
  {"type":"template","text":"Bonjour Dr. Karim,\n\n✅ Bug corrigé sur {URL}.\nCause : conflit entre {plugin A} et {plugin B}. J'ai désactivé {plugin B} et installé {plugin alternatif} qui fait le même travail.\n\nMerci de tester de votre côté et me confirmer.\nNext Gital"},

  {"type":"divider"},
  {"type":"heading","text":"Templates de messages"},
  {"type":"template","text":"[DIAG] Bonjour {prénom}, je reproduis bien le bug — investigation en cours, retour sous 1h. NG"},
  {"type":"template","text":"[ROLLBACK] Bonjour {prénom}, restauration en cours via backup de {date}. Site OK dans 15 min. NG"},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":["Bug reproduit + capture","Backup UpdraftPlus créé","Cause identifiée (notes ticket)","Fix appliqué minimum nécessaire","WP_DEBUG remis false","Cache CDN purgé","Test navigation privée OK","Test mobile OK","Client a confirmé","Ticket clôturé avec cause racine"]},
  {"type":"callout","variant":"danger","title":"🆘 Escalade dev","text":"Si > 30 min sans diag clair OU besoin code custom → ping dev sur WhatsApp +212 620 002 066. Ne JAMAIS bricoler en aveugle."}
]$sop$::jsonb,
    read_min = 14,
    updated_at = now()
WHERE slug = 'ng-sup-wordpress-fixes';

-- ────────────────────────────────────────────────────────────────────
-- 3) ng-sup-scope-creep — Gestion du scope creep
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"📖 Définition","text":"Scope creep = le client demande des fonctionnalités/modifs NON prévues au devis initial. Si on accepte gratuitement, on perd marge ET on crée précédent."},
  {"type":"callout","variant":"info","title":"🎯 Posture Next Gital","text":"Toujours DIPLOMATE jamais sec. Reformuler en valeur (« je vais vous préparer ça correctement »). Devis additionnel sous 24h max."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"AUCUNE feature hors devis ne démarre sans : (1) devis additionnel signé OU (2) accord écrit WhatsApp + validation fondateur."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. DÉTECTION DU SCOPE CREEP"},
  {"type":"paragraph","text":"🎯 Objectif : repérer les phrases déclencheuses. ⏱️ Temps : continu."},
  {"type":"paragraph","text":"✏️ PHRASES À ÉCOUTE :"},
  {"type":"list","items":["« Vous pouvez ajouter aussi… ? »","« Pendant qu'on y est… »","« Petite modif rapide… »","« Ah j'ai oublié, il faudrait aussi… »","« Mon associé voudrait… »","« Sur l'autre site vous m'aviez fait… »"]},
  {"type":"callout","variant":"tip","title":"💡 Réflexe","text":"NE PAS répondre « ok je note » sans vérifier le devis. Ouvre GestiQ → Devis du client → vérifie le périmètre signé."},

  {"type":"heading2","text":"2. VÉRIFICATION DEVIS INITIAL"},
  {"type":"paragraph","text":"🎯 Objectif : confirmer si dans / hors périmètre. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → Clients → Cabinet Fedix → onglet Devis → ouvrir le devis signé."},
  {"type":"numbered","items":["Lire la section « Périmètre inclus »","Lire la section « Hors périmètre / Options »","Vérifier le nombre de révisions incluses","Statuer : IN scope / OUT of scope / GRIS (interprétable)"]},

  {"type":"heading2","text":"3. RÉPONSE DIPLOMATE AU CLIENT"},
  {"type":"paragraph","text":"🎯 Objectif : recadrer sans braquer. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Règle : JAMAIS dire « c'est pas prévu » sec. Toujours valoriser la demande."},
  {"type":"template","text":"Bonjour Dr. Karim,\n\nMerci pour votre demande — c'est une excellente idée d'ajouter {fonctionnalité}.\n\nAprès vérification, cette fonctionnalité n'était pas incluse dans le devis initial du {date} (qui couvre {périmètre}). Pour la réaliser proprement, je vous prépare une proposition complémentaire détaillée d'ici 24h.\n\nElle inclura :\n• Le détail technique\n• Le délai estimé\n• Le coût\n\nDès votre validation, on lance.\n\nMerci de votre confiance,\nNext Gital"},
  {"type":"callout","variant":"warning","title":"⚠️ Ne PAS écrire","text":"« C'est en plus » / « Vous n'avez pas payé pour ça » / « Le devis ne le prévoit pas » → trop sec, génère friction."},

  {"type":"heading2","text":"4. INFORMATION FONDATEUR < 30 MIN"},
  {"type":"paragraph","text":"🎯 Objectif : alerter pour validation tarif. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"🖥️ OÙ : WhatsApp fondateur +212 620 002 066."},
  {"type":"template","text":"🚨 SCOPE CREEP\nClient : Cabinet Fedix\nDevis : NG-2026-0042\nDemande : ajout module rendez-vous en ligne\nMon analyse : 2 jours dev, à 2500 DH HT\nValidation tarif ?"},

  {"type":"heading2","text":"5. RÉDACTION DEVIS ADDITIONNEL"},
  {"type":"paragraph","text":"🎯 Objectif : produire devis pro sous 24h. ⏱️ Temps : 30-60 min."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → Devis → Nouveau → lier au client."},
  {"type":"list","items":["**Titre** → « Avenant n°1 — {nom projet} »","**Référence** → « En complément du devis NG-2026-XXXX du {date} »","**Lignes** → description précise + temps + tarif unitaire","**Conditions** → délai démarrage = J+2 après signature, acompte 50%","**Validité** → 15 jours"]},
  {"type":"callout","variant":"tip","title":"💡 Astuce tarif","text":"Avenant = +10 à +20% du tarif normal (justifié par re-mobilisation équipe + planning serré)."},

  {"type":"heading2","text":"6. ENVOI & RELANCE"},
  {"type":"paragraph","text":"🎯 Objectif : signature sous 7 jours. ⏱️ Temps : 5 min + relances."},
  {"type":"numbered","items":["Envoyer devis PDF par email + WhatsApp","J+3 → relance amicale","J+7 → relance + appel téléphonique","Si pas de retour J+10 → archiver, ne rien démarrer"]},
  {"type":"template","text":"Bonjour Dr. Karim,\n\nComme convenu, voici la proposition pour {fonctionnalité} : devis ci-joint NG-2026-0142-AV1.\n\nValide 15 jours. Démarrage 48h après signature.\n\nÀ votre dispo pour en discuter.\nNext Gital"},

  {"type":"divider"},
  {"type":"heading","text":"Templates de messages"},
  {"type":"template","text":"[ACK SCOPE] Bonjour {prénom}, super idée. Je vérifie le périmètre initial et reviens vers vous d'ici 24h avec une proposition adaptée. NG"},
  {"type":"template","text":"[RELANCE 1] Bonjour {prénom}, avez-vous pu consulter le devis NG-XXXX ? À votre dispo pour toute question. NG"},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":["Devis initial relu","Périmètre IN/OUT statué","Réponse diplomate envoyée sous 1h","Fondateur informé via WhatsApp","Devis additionnel rédigé < 24h","Devis envoyé email + WA","Suivi relance J+3 / J+7 programmé","Aucun travail démarré sans signature"]},
  {"type":"callout","variant":"danger","title":"🆘 Escalade","text":"Si client refuse devis et menace de partir → WhatsApp fondateur +212 620 002 066 IMMÉDIATEMENT. Ne JAMAIS céder sans aval."}
]$sop$::jsonb,
    read_min = 11,
    updated_at = now()
WHERE slug = 'ng-sup-scope-creep';

-- ────────────────────────────────────────────────────────────────────
-- 4) ng-sup-avis-google — Stratégie avis Google 4.9★
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"🎯 Objectif KPI","text":"Maintenir note Google ≥ 4.9★ · 1 avis minimum par projet livré · 100% des avis répondus sous 24h."},
  {"type":"callout","variant":"info","title":"🛠️ Outils","text":"Google Business Profile (business.google.com) · lien court Google Review (g.page/r/...) · WhatsApp Business · GestiQ → Clients → onglet Avis."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"JAMAIS acheter d'avis · JAMAIS rédiger l'avis à la place du client · JAMAIS répondre sec à un avis négatif. Toujours empathie d'abord."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. PRÉPARATION DU LIEN DIRECT"},
  {"type":"paragraph","text":"🎯 Objectif : avoir un lien 1-clic vers la page d'avis. ⏱️ Temps : déjà fait, à vérifier."},
  {"type":"paragraph","text":"🖥️ OÙ : business.google.com → Accueil → bouton « Obtenir plus d'avis »."},
  {"type":"numbered","items":["Copier le lien court (format https://g.page/r/CXXXXXXXX/review)","Sauvegarder dans GestiQ → Paramètres → Liens utiles","Tester le lien en navigation privée → doit ouvrir directement la fenêtre 5★"]},

  {"type":"heading2","text":"2. TIMING DE LA DEMANDE (J+2 POST-LIVRAISON)"},
  {"type":"paragraph","text":"🎯 Objectif : demander au moment de satisfaction max. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Règle : surtout PAS le jour J (client encore en mode validation). J+2 = il a testé, il est content."},
  {"type":"numbered","items":["Vérifier que le projet est en statut « Livré » dans GestiQ","Vérifier qu'aucun ticket ouvert pour ce client","Vérifier la satisfaction (dernier échange WhatsApp positif)","Envoyer le message ci-dessous"]},
  {"type":"template","text":"Bonjour Dr. Karim 🌿\n\nJ'espère que vous prenez bien en main votre nouveau site. Si vous êtes satisfait du travail, un petit avis Google nous aiderait énormément à grandir 🙏\n\n👉 Lien direct (30 secondes) : https://g.page/r/CXXXXXXXX/review\n\nMerci infiniment pour votre confiance,\nÉquipe Next Gital"},
  {"type":"callout","variant":"warning","title":"⚠️ Ne PAS","text":"Insister · relancer plus d'1 fois · proposer un cadeau contre avis (interdit par Google)."},

  {"type":"heading2","text":"3. RELANCE UNIQUE À J+7"},
  {"type":"paragraph","text":"🎯 Objectif : 2e (et dernière) sollicitation. ⏱️ Temps : 3 min."},
  {"type":"template","text":"Bonjour Dr. Karim,\n\nPetit rappel amical 😊 — si vous avez 1 minute pour un avis Google, ce serait précieux pour nous :\nhttps://g.page/r/CXXXXXXXX/review\n\nSans aucune obligation bien sûr.\nNext Gital"},
  {"type":"callout","variant":"tip","title":"💡 Astuce","text":"Si pas de retour après J+7 → laisser tomber gracieusement. Ne pas insister abîme la relation."},

  {"type":"heading2","text":"4. RÉPONSE À UN AVIS POSITIF (4-5★)"},
  {"type":"paragraph","text":"🎯 Objectif : remercier de manière personnalisée. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"🖥️ OÙ : business.google.com → Avis → Répondre."},
  {"type":"paragraph","text":"📍 Délai : < 24h."},
  {"type":"list","items":["**Saluer par prénom** → « Merci Dr. Karim »","**Reprendre 1 élément spécifique** de son avis → ne PAS template générique","**Réaffirmer engagement** → « ravis de continuer à vous accompagner »","**Signer** → Équipe Next Gital"]},
  {"type":"template","text":"Merci infiniment Dr. Karim 🙏\nC'est un plaisir de vous accompagner dans la digitalisation du Cabinet Fedix. Votre confiance compte énormément pour nous.\n\nÀ très bientôt,\nÉquipe Next Gital"},

  {"type":"heading2","text":"5. RÉPONSE À UN AVIS NÉGATIF (1-3★)"},
  {"type":"paragraph","text":"🎯 Objectif : empathie publique + résolution privée. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Délai : < 4h (priorité maximum)."},
  {"type":"numbered","items":["NE PAS répondre à chaud (attendre 30 min, respirer)","Alerter fondateur WhatsApp +212 620 002 066","Rédiger réponse publique COURTE empathique","Contacter client EN PRIVÉ pour résoudre","Une fois résolu, demander gentiment update de l'avis"]},
  {"type":"template","text":"Bonjour {prénom},\n\nNous sommes sincèrement désolés de cette expérience qui ne reflète pas notre standard. Nous prenons votre retour très au sérieux.\n\nNotre fondateur vous contacte aujourd'hui en MP pour comprendre et trouver une solution rapide.\n\nMerci de nous avoir alertés,\nÉquipe Next Gital"},
  {"type":"callout","variant":"danger","title":"🚫 INTERDIT","text":"Se justifier publiquement · accuser le client · répondre en colère · ignorer."},

  {"type":"heading2","text":"6. TRAÇABILITÉ DANS GESTIQ"},
  {"type":"paragraph","text":"🎯 Objectif : suivre KPIs. ⏱️ Temps : 3 min."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → Clients → fiche client → onglet Avis."},
  {"type":"list","items":["**Date demande** → J+2","**Date relance** → J+7","**Date avis reçu** → si applicable","**Note** → 1-5★","**Date réponse** → < 24h"]},

  {"type":"divider"},
  {"type":"heading","text":"Templates de messages"},
  {"type":"template","text":"[J+2] Bonjour {prénom}, si content du travail, un avis Google nous aide : {lien}. Merci 🙏 NG"},
  {"type":"template","text":"[POSITIF] Merci {prénom} ! Ravis de vous accompagner. À bientôt — Équipe NG"},
  {"type":"template","text":"[NÉGATIF] Désolés {prénom}, notre fondateur vous contacte en privé aujourd'hui pour solution. Merci de votre retour. NG"},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":["Lien Google Review testé et fonctionnel","Demande envoyée J+2 post-livraison","Relance unique J+7 envoyée","Avis reçu enregistré dans GestiQ","Réponse publique sous 24h (positif) ou 4h (négatif)","Négatif → fondateur informé + résolution offline","KPIs mis à jour mensuellement"]},
  {"type":"callout","variant":"danger","title":"🆘 Escalade","text":"Avis < 4★ OU bad buzz réseaux sociaux → WhatsApp fondateur +212 620 002 066 IMMÉDIATEMENT."}
]$sop$::jsonb,
    read_min = 10,
    updated_at = now()
WHERE slug = 'ng-sup-avis-google';

-- ────────────────────────────────────────────────────────────────────
-- 5) ng-sup-formation-client — Formation client post-livraison
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"🎯 Objectif","text":"Rendre le client AUTONOME sur les modifs courantes en < 1h de formation. Réduit tickets support de ~40%."},
  {"type":"callout","variant":"info","title":"🛠️ Outils","text":"Loom (loom.com) · Canva (guide PDF) · Google Meet (session live) · Google Drive (kit livraison) · wp-admin du client."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"JAMAIS livrer un site sans kit formation. Sinon le client appelle pour chaque virgule = perte de marge."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. ENREGISTREMENT DU LOOM TUTO (5 MIN)"},
  {"type":"paragraph","text":"🎯 Objectif : vidéo réutilisable montrant les actions essentielles. ⏱️ Temps : 20 min (prep + record + edit)."},
  {"type":"paragraph","text":"🖥️ OÙ : loom.com → Nouvelle vidéo → Écran + Caméra."},
  {"type":"paragraph","text":"📍 Préparation : ouvrir wp-admin du client en navigation privée, fermer toutes notifs."},
  {"type":"numbered","items":["Intro 15 sec : « Bonjour {prénom}, voici 5 min pour maîtriser votre site »","Démo connexion : URL wp-admin + identifiants (rappeler de les changer)","Démo modifier un texte : Pages → Accueil → Modifier → enregistrer","Démo ajouter une image : Médiathèque → Téléverser → insérer","Démo publier un article (si blog) : Articles → Nouveau","Outro : « Pour toute question WhatsApp +212 620 002 066 »","Couper les hésitations dans Loom (ciseaux)","Renommer la vidéo : « Tuto {NomClient} — Modifier votre site »","Copier le lien partageable"]},
  {"type":"callout","variant":"tip","title":"💡 Astuce","text":"Active le mode « Drawing » dans Loom pour entourer les boutons importants en rouge à l'écran."},

  {"type":"heading2","text":"2. RÉDACTION GUIDE PDF 1 PAGE"},
  {"type":"paragraph","text":"🎯 Objectif : aide-mémoire visuel à imprimer. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"🖥️ OÙ : Canva → template « Guide utilisateur Next Gital » (préexistant)."},
  {"type":"list","items":["**Header** → logo client + URL site + URL wp-admin","**Section 1** → identifiants (laisser case vide à remplir main)","**Section 2** → 4 captures annotées : connexion / modifier texte / ajouter image / publier","**Section 3** → contacts support (email + WhatsApp + n° ticket si bug)","**Footer** → version + date + lien Loom (QR code)"]},
  {"type":"paragraph","text":"✏️ EXPORT : PDF haute résolution → nommer « GuideClient_{NomClient}_v1.pdf »."},

  {"type":"heading2","text":"3. CRÉATION KIT LIVRAISON DRIVE"},
  {"type":"paragraph","text":"🎯 Objectif : tout centraliser dans 1 dossier partagé. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"🖥️ OÙ : Google Drive → Mon Drive → Clients → créer dossier « {NomClient} — Livraison »."},
  {"type":"numbered","items":["Créer 4 sous-dossiers : 01_Identifiants / 02_Formations / 03_Assets / 04_Factures","Déposer guide PDF dans 02_Formations","Coller lien Loom dans un fichier texte « Lien_Tuto.txt »","Partager dossier avec email client en lecture","Coller lien partagé dans GestiQ → fiche client → onglet Documents"]},

  {"type":"heading2","text":"4. PLANIFICATION SESSION LIVE 30 MIN (OPTIONNELLE)"},
  {"type":"paragraph","text":"🎯 Objectif : répondre aux questions en live. ⏱️ Temps : 5 min planif + 30 min session."},
  {"type":"paragraph","text":"🖥️ OÙ : Calendly → lien « formation-client-30min »."},
  {"type":"numbered","items":["Proposer 3 créneaux dans message livraison","Client réserve via Calendly","Recevoir invitation Google Meet auto","La veille → ouvrir wp-admin du client + checklist questions","Pendant la session : partage d'écran, démos pratiques","Après : enregistrer un mini-Loom récap si questions spécifiques"]},
  {"type":"callout","variant":"tip","title":"💡 Astuce","text":"Toujours commencer par « Que voulez-vous savoir ? » plutôt que ton agenda. Le client se sent écouté."},

  {"type":"heading2","text":"5. MESSAGE DE LIVRAISON COMPLET"},
  {"type":"paragraph","text":"🎯 Objectif : remettre le kit formellement. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"🖥️ OÙ : email Titan (info@nextgital.com) + WhatsApp."},
  {"type":"template","text":"Objet : 🎉 Livraison de votre site — Kit complet\n\nBonjour Dr. Karim,\n\nVotre site {URL} est officiellement livré ! Voici tout ce dont vous avez besoin :\n\n📂 Kit complet (Drive) : {lien_drive}\n🎥 Tuto vidéo 5 min : {lien_loom}\n📄 Guide PDF imprimable : dans le Drive\n📅 Session live 30 min (optionnelle) : {lien_calendly}\n\n🔐 Vos identifiants admin sont dans le sous-dossier 01_Identifiants.\n\nN'hésitez pas pour toute question :\n📱 WhatsApp +212 620 002 066\n📧 info@nextgital.com\n\nMerci de votre confiance,\nÉquipe Next Gital"},

  {"type":"heading2","text":"6. SUIVI J+7 & MISE À JOUR DU TUTO"},
  {"type":"paragraph","text":"🎯 Objectif : check satisfaction + détecter questions récurrentes. ⏱️ Temps : 10 min."},
  {"type":"numbered","items":["J+7 → message check satisfaction (cf. template)","Si questions répétées → enregistrer Loom complémentaire","Mettre à jour le guide PDF version 2 si besoin","Re-déposer dans Drive"]},
  {"type":"template","text":"Bonjour Dr. Karim,\n\nUne semaine après la livraison — tout se passe bien ? Avez-vous des questions sur l'utilisation du site ?\n\nNext Gital"},

  {"type":"divider"},
  {"type":"heading","text":"Templates de messages"},
  {"type":"template","text":"[LIVRAISON] Site livré ! Kit complet ici : {drive} · Tuto 5 min : {loom} · Session live possible : {calendly}. NG"},
  {"type":"template","text":"[J+7] Bonjour {prénom}, tout va bien avec votre site ? Des questions ? NG"},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":["Loom tuto 5 min enregistré et nommé","Guide PDF 1 page créé sur Canva","Kit Drive structuré (4 sous-dossiers)","Identifiants déposés dans 01_Identifiants","Drive partagé en lecture avec email client","Email livraison envoyé avec tous les liens","Lien Calendly proposé","Suivi J+7 programmé dans GestiQ","Liens ajoutés dans fiche client GestiQ"]},
  {"type":"callout","variant":"danger","title":"🆘 Escalade","text":"Client demande formation > 1h ou en présentiel → devis additionnel (cf. SOP ng-sup-scope-creep)."}
]$sop$::jsonb,
    read_min = 12,
    updated_at = now()
WHERE slug = 'ng-sup-formation-client';

-- ────────────────────────────────────────────────────────────────────
-- 6) ng-sup-rapport-mensuel — Rapport mensuel Support
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"📅 Cadence","text":"Rapport envoyé au fondateur le 1er de chaque mois à 10h max, sur les données du mois écoulé. Format : PDF + résumé WhatsApp 5 lignes."},
  {"type":"callout","variant":"info","title":"🛠️ Outils","text":"GestiQ (export CSV) · Google Sheets (calculs) · Canva (template PDF Rapport Support) · WhatsApp Business."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"AUCUN rapport sans les 4 KPIs obligatoires : nb tickets · temps moyen 1ère réponse · taux résolution < 24h · top 3 problèmes."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. EXPORT DES DONNÉES GESTIQ"},
  {"type":"paragraph","text":"🎯 Objectif : récupérer la donnée brute. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → Tickets → filtre Période = mois écoulé → bouton Export CSV."},
  {"type":"numbered","items":["Filtrer par date : du 1er au dernier du mois écoulé","Export CSV → sauvegarder dans Drive → Rapports → {YYYY-MM}","Ouvrir dans Google Sheets","Vérifier qu'aucun ticket n'a de champ vide (sinon revenir compléter dans GestiQ)"]},

  {"type":"heading2","text":"2. CALCUL DES KPIs PRINCIPAUX"},
  {"type":"paragraph","text":"🎯 Objectif : sortir les 4 chiffres clés. ⏱️ Temps : 20 min."},
  {"type":"paragraph","text":"🖥️ OÙ : Google Sheets → onglet « KPIs »."},
  {"type":"list","items":["**Nombre total de tickets** → =NBVAL(A:A)-1","**Temps moyen 1ère réponse** → =MOYENNE(colonne « temps_ack »)","**Taux résolution < 24h** → =NB.SI(colonne « durée » ; \"<24\") / total","**Top 3 problèmes** → tableau croisé sur colonne « cause_racine »"]},
  {"type":"paragraph","text":"✏️ KPIs SECONDAIRES :"},
  {"type":"list","items":["Répartition par priorité (🔴/🟠/🟡/🟢/⚪)","Répartition par canal (WhatsApp / Email / Form)","Top 5 clients en nombre de tickets","NPS / satisfaction (si récolté)"]},
  {"type":"callout","variant":"tip","title":"💡 Astuce","text":"Crée un Sheets template « Rapport Support — Master » avec toutes les formules. Chaque mois, duplique et colle juste le CSV."},

  {"type":"heading2","text":"3. ANALYSE & RECOMMANDATIONS (3 AXES)"},
  {"type":"paragraph","text":"🎯 Objectif : transformer chiffres en décisions. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"📍 Règle : toujours 3 axes, ni 1 ni 5. Format : Constat → Cause → Action."},
  {"type":"list","items":["**Axe 1 (Performance)** → ex : temps réponse passé de 45 → 25 min → maintenir. Si dégradé → renforcer disponibilité.","**Axe 2 (Récurrence)** → ex : 40% des tickets concernent « modifier image » → créer Loom dédié + ajouter au kit formation","**Axe 3 (Prévention)** → ex : 3 incidents hébergeur → switcher offre Hostinger Business ou ajouter monitoring UptimeRobot"]},

  {"type":"heading2","text":"4. MISE EN PAGE PDF (CANVA)"},
  {"type":"paragraph","text":"🎯 Objectif : rapport visuel pro 3 pages max. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"🖥️ OÙ : Canva → template « Rapport Support Mensuel Next Gital »."},
  {"type":"numbered","items":["Page 1 → couverture (mois + logo + 4 KPIs en gros)","Page 2 → graphiques (camembert priorité + barres top problèmes)","Page 3 → 3 recommandations + roadmap mois suivant","Footer chaque page → version + date + contact"]},
  {"type":"paragraph","text":"✏️ EXPORT : PDF haute résolution → nommer « RapportSupport_{YYYY-MM}.pdf » → déposer dans Drive → Rapports."},

  {"type":"heading2","text":"5. ENVOI AU FONDATEUR"},
  {"type":"paragraph","text":"🎯 Objectif : remise formelle. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Délai : 1er du mois à 10h max."},
  {"type":"paragraph","text":"🖥️ OÙ : email info@nextgital.com → fondateur + WhatsApp +212 620 002 066."},
  {"type":"template","text":"Objet : 📊 Rapport Support — {Mois YYYY}\n\nBonjour,\n\nCi-joint le rapport Support du mois de {Mois}.\n\n📊 Chiffres clés :\n• {N} tickets traités\n• Temps moyen 1ère réponse : {X} min\n• Taux résolution < 24h : {Y}%\n• Top problème : {Z}\n\n🎯 Recommandations clés :\n1. {Axe 1}\n2. {Axe 2}\n3. {Axe 3}\n\nDisponible pour debrief si tu veux.\nÉquipe Support"},
  {"type":"template","text":"[WhatsApp] 📊 Rapport Support {Mois} envoyé par email. TL;DR : {N} tickets · {X} min · {Y}% < 24h · top pb = {Z}. 3 reco dans le PDF."},

  {"type":"heading2","text":"6. ARCHIVAGE & SUIVI ACTIONS"},
  {"type":"paragraph","text":"🎯 Objectif : capitaliser dans le temps. ⏱️ Temps : 10 min."},
  {"type":"numbered","items":["Archiver PDF dans Drive → Rapports → {YYYY-MM}","Reporter les 3 axes recommandations dans GestiQ → Tâches → Support","Affecter responsable + deadline pour chaque axe","Vérifier au rapport suivant si actions effectuées"]},

  {"type":"divider"},
  {"type":"heading","text":"Templates de messages"},
  {"type":"template","text":"[ENVOI] 📊 Rapport Support {Mois} ci-joint. KPIs + 3 reco. Dispo pour debrief. NG"},
  {"type":"template","text":"[ALERTE DÉGRADATION] Heads-up : temps réponse a doublé ce mois ({X} → {Y} min). Cause principale : {Z}. Plan d'action proposé en page 3 du rapport."},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":["Export GestiQ effectué le dernier jour du mois","CSV sauvegardé dans Drive","Les 4 KPIs obligatoires calculés","Top 3 problèmes identifiés","3 recommandations rédigées (Constat → Cause → Action)","PDF Canva exporté et nommé correctement","Email envoyé au fondateur avant 10h le 1er","Message WhatsApp TL;DR envoyé","3 actions reportées dans GestiQ → Tâches"]},
  {"type":"callout","variant":"danger","title":"🆘 Escalade","text":"Si dégradation KPI > 30% vs mois précédent → ne PAS attendre le 1er, alerter fondateur WhatsApp +212 620 002 066 immédiatement avec plan d'action."}
]$sop$::jsonb,
    read_min = 11,
    updated_at = now()
WHERE slug = 'ng-sup-rapport-mensuel';

COMMIT;
