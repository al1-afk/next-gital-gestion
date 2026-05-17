-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 041 : SOPs ultra-détaillés Commercial
--  Date : 2026-05-17
--  Auteur : Next Gital (Oujda)
--  Objet : Remplace blocks des 6 SOPs Commercial par version détaillée
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ════════════════════════════════════════════════════════════════════
-- 1) ng-commercial-reunion-vente
-- ════════════════════════════════════════════════════════════════════
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"Pourquoi ce SOP","text":"La réunion de vente est LE moment où un prospect devient client. 80% du succès vient de la préparation + écoute. Pas de talk-show, pas de pitch agressif : on pose des questions, on écoute, on propose."},
  {"type":"callout","variant":"tip","title":"Durée totale","text":"60 min max : 15 min prépa + 45 min rendez-vous + 10 min post-RDV (notes GestiQ)."},
  {"type":"callout","variant":"success","title":"Résultat attendu","text":"Sortir du RDV avec : (1) fiche prospect complète dans GestiQ, (2) prochaine étape claire (devis, 2e RDV, signature), (3) date précise dans le calendrier."},
  {"type":"callout","variant":"warning","title":"Règle d'or","text":"Tu dois parler 30% du temps MAX. Le client parle 70%. Si tu parles plus, tu vends moins."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. PRÉPARATION 15 MIN AVANT LE RDV"},
  {"type":"paragraph","text":"🎯 Objectif : arriver avec toutes les infos en tête, sans hésitation. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : 15 min avant l'heure du RDV (alarme calendrier)."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ CRM → gestiq.nextgital.tech/crm/prospects + onglet nextgital.tech (réalisations)."},
  {"type":"numbered","items":[
    "Ouvre la fiche prospect dans GestiQ CRM (recherche par nom ou téléphone).",
    "Relis les 3 derniers échanges (WhatsApp, email, appel) — notés dans le timeline.",
    "Note sur papier : nom complet, secteur, ville, source (Facebook, parrainage, Google).",
    "Ouvre nextgital.tech dans un autre onglet et choisis 2 réalisations du MÊME secteur.",
    "Vérifie ton matos : Meet/Zoom OK, caméra OK, micro OK, fond propre, eau à portée.",
    "Imprime ou ouvre la fiche des 6 questions de qualification (2e onglet)."
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT À NOTER :"},
  {"type":"list","items":[
    "**Nom prospect** → ex : Dr. Karim Alaoui (cabinet dentaire Oujda)",
    "**Source** → ex : a vu une pub Facebook, a rempli formulaire Tally",
    "**Besoin déclaré** → ex : « refonte site + prise de RDV en ligne »",
    "**2 réalisations à montrer** → ex : dentiste-bennani.ma + cabinet-pluridiscip-oujda.com"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu connais le nom du prospect par cœur, tu sais quoi lui montrer, tu as bu de l'eau. Si oui : tu es prêt."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : fiche vide dans GestiQ → cause : prospect pas qualifié à l'entrée → solution : appelle 5 min avant pour reconfirmer + collecter base. Pb 2 : pas de réalisation du secteur → solution : montre 1 site générique + dis « on fait du sur-mesure pour votre métier »."},
  {"type":"paragraph","text":"➡️ Étape suivante : démarrer le RDV à l'heure pile."},

  {"type":"heading2","text":"2. PRÉSENTATION (2 MIN)"},
  {"type":"paragraph","text":"🎯 Objectif : créer le rapport, donner confiance, cadrer le RDV. ⏱️ Temps : 2 min MAX."},
  {"type":"paragraph","text":"📍 Point de départ : la caméra s'allume, le client est en face."},
  {"type":"paragraph","text":"🖥️ OÙ : Google Meet ou présentiel (bureau N°7 Immeuble Kissi, Oujda)."},
  {"type":"numbered","items":[
    "Sourire + bonjour + nom complet du prospect.",
    "Présente-toi en 1 phrase : prénom + rôle + Next Gital.",
    "Annonce le déroulé : « On va faire 45 min ensemble. D'abord je vais vous poser quelques questions pour bien comprendre, puis je vous montre ce qu'on peut faire pour vous. »",
    "Demande l'accord : « Ça vous va ? »",
    "Si oui → enchaîne directement sur l'écoute."
  ]},
  {"type":"template","text":"« Bonjour Dr Karim, ravi de vous rencontrer. Moi c'est [Prénom], commercial chez Next Gital à Oujda. On va passer 45 min ensemble : d'abord je vous pose quelques questions pour bien comprendre votre besoin, ensuite je vous montre concrètement ce qu'on peut faire. Ça vous convient ? »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le client a dit « oui » ou « OK ». Tu as souri. Tu n'as PAS pitché tes services."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu enchaînes sur ton pitch → STOP. Pose des questions d'abord. Pb 2 : client demande direct le prix → réponds : « Excellente question, je vous donne un prix précis dans 30 min après vos réponses. »"},
  {"type":"paragraph","text":"➡️ Étape suivante : laisser le client parler de lui (5 min)."},

  {"type":"heading2","text":"3. ÉCOUTE LIBRE (5 MIN)"},
  {"type":"paragraph","text":"🎯 Objectif : faire parler le client de SON business, créer la confiance. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : juste après ton intro de 2 min."},
  {"type":"paragraph","text":"🖥️ OÙ : RDV en cours (Meet ou présentiel)."},
  {"type":"numbered","items":[
    "Pose UNE question ouverte : « Avant qu'on rentre dans le détail, parlez-moi un peu de votre activité ? »",
    "ÉCOUTE. Note tout sur GestiQ (onglet « notes RDV »).",
    "Hoche la tête. Dis « d'accord », « je vois », « intéressant ».",
    "Si silence : relance « Et depuis combien de temps vous êtes installé ? »",
    "NE PARLE PAS de Next Gital. NE PROPOSE RIEN encore."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu as au moins 3 phrases dans tes notes. Le client est détendu. Tu n'as pas placé un seul mot sur tes services."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : client laconique → relance avec « Et qu'est-ce qui vous plaît dans votre métier ? ». Pb 2 : client part en monologue 15 min → recadre poliment : « C'est très intéressant, j'aimerais qu'on plonge dans votre projet maintenant. »"},
  {"type":"paragraph","text":"➡️ Étape suivante : les 6 questions de qualification."},

  {"type":"heading2","text":"4. LES 6 QUESTIONS DE QUALIFICATION (25 MIN)"},
  {"type":"paragraph","text":"🎯 Objectif : qualifier le besoin, le budget, la décision, le délai. ⏱️ Temps : 25 min (≈ 4 min/question)."},
  {"type":"paragraph","text":"📍 Point de départ : juste après l'écoute libre."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → fiche prospect → onglet « Qualification »."},
  {"type":"paragraph","text":"✏️ POSE LES 6 QUESTIONS DANS CET ORDRE EXACT :"},
  {"type":"list","items":[
    "**Q1 (Besoin)** → « Pour bien comprendre, qu'est-ce qui vous a fait nous contacter aujourd'hui ? » → écoute → note dans GestiQ champ besoin_principal.",
    "**Q2 (Situation actuelle)** → « Aujourd'hui, comment trouvez-vous vos nouveaux clients ? » → identifie le canal actuel (bouche-à-oreille, Facebook, rien).",
    "**Q3 (Vision)** → « Si on construit ensemble votre nouveau site, ça doit vous apporter quoi concrètement dans 6 mois ? » → laisse-le projeter le succès.",
    "**Q4 (Budget)** → « Quel est votre budget approximatif pour ce projet ? » → SILENCE. Attends la réponse. Si « je ne sais pas » → propose 3 fourchettes (5-10k MAD, 10-25k, 25k+).",
    "**Q5 (Délai)** → « Pour quelle date idéalement vous aimeriez avoir tout en place ? » → note la date précise.",
    "**Q6 (Décideur)** → « Y a-t-il d'autres personnes impliquées dans la décision ? » → CRUCIAL. Si oui → propose un 2e RDV avec tout le monde."
  ]},
  {"type":"template","text":"« Dr Karim, pour bien comprendre, qu'est-ce qui vous a fait nous contacter aujourd'hui ? » … (écoute) … « Et aujourd'hui, comment trouvez-vous vos nouveaux patients ? » … (écoute) … « Si on construit votre nouveau site ensemble, ça doit vous apporter quoi concrètement dans 6 mois ? » …"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Les 6 champs sont remplis dans GestiQ. Tu as une fourchette de budget. Tu connais le décideur final. Tu as une date cible."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : client esquive le budget → insiste poliment : « Même une fourchette m'aide à vous proposer la bonne solution. » Pb 2 : décideur absent → STOP la vente, planifie 2e RDV avec le décideur via Calendly (calendly.com/nextgital). Pb 3 : tu donnes un prix avant Q6 → ERREUR, tu vas devoir refaire."},
  {"type":"paragraph","text":"➡️ Étape suivante : pitch personnalisé basé sur les réponses."},

  {"type":"heading2","text":"5. PITCH PERSONNALISÉ (15 MIN)"},
  {"type":"paragraph","text":"🎯 Objectif : montrer comment Next Gital répond EXACTEMENT à son besoin. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : tu as les 6 réponses, c'est ton tour."},
  {"type":"paragraph","text":"🖥️ OÙ : partage écran nextgital.tech + ton bloc-notes des réponses."},
  {"type":"numbered","items":[
    "Reformule SON besoin : « Si je résume, vous voulez X pour obtenir Y avant Z. »",
    "Attends la confirmation : « C'est bien ça ? »",
    "Montre 2 réalisations du MÊME secteur (préparées en étape 1).",
    "Pour chaque réalisation, raconte une histoire : « Comme vous, le Dr Bennani voulait Z. On a fait X. Résultat : 40 nouveaux patients/mois après 3 mois. »",
    "Présente la solution Next Gital en 3 étapes max (brief, design, lancement).",
    "Annonce un délai réaliste (4-8 semaines selon scope).",
    "Demande : « Qu'est-ce que vous en pensez jusqu'ici ? »"
  ]},
  {"type":"template","text":"« Si je résume Dr Karim : vous voulez un nouveau site avec prise de RDV en ligne pour gagner 30 nouveaux patients/mois d'ici septembre. C'est bien ça ? … Parfait. Regardez, voici exactement ce qu'on a fait pour le Dr Bennani à Casablanca : [montre le site]. Aujourd'hui il a 50% de RDV en ligne et son agenda est plein 3 semaines à l'avance. Pour vous, on suivrait la même méthode en 3 étapes : 1) brief approfondi semaine 1, 2) design + dev 4 semaines, 3) lancement + formation semaine 6. Qu'est-ce que vous en pensez jusqu'ici ? »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le client hoche la tête, pose des questions techniques (signal d'achat). Tu n'as PAS encore donné le prix."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu montres 10 réalisations → STOP, 2 suffisent. Pb 2 : tu parles 15 min sans pause → check toutes les 3 min : « C'est clair jusqu'ici ? »"},
  {"type":"paragraph","text":"➡️ Étape suivante : closing + étape suivante."},

  {"type":"heading2","text":"6. CLOSING + ÉTAPE SUIVANTE (5 MIN)"},
  {"type":"paragraph","text":"🎯 Objectif : sortir avec un engagement précis (devis, 2e RDV, signature). ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : fin du pitch, le client est intéressé."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ → créer tâche « envoyer devis » + Calendly pour réserver 2e RDV."},
  {"type":"numbered","items":[
    "Annonce le prix avec une fourchette : « Pour votre projet, on est entre 15 000 et 25 000 MAD HT selon les options. »",
    "SILENCE. Attends sa réaction.",
    "Selon réaction → propose l'étape suivante : devis détaillé sous 48h OU signature directe OU 2e RDV avec associé.",
    "Bloque la date PRÉCISE du prochain contact (date + heure).",
    "Confirme par WhatsApp dans les 10 min suivant le RDV avec un récap + lien Calendly si 2e RDV.",
    "Mets à jour le statut GestiQ : « Devis envoyé », « 2e RDV planifié » ou « Signé »."
  ]},
  {"type":"template","text":"« Très bien Dr Karim. Pour un projet comme le vôtre, on est entre 15 000 et 25 000 MAD HT selon les options. Je vous propose qu'on fasse comme ça : je vous envoie un devis détaillé jeudi avant 18h, on se rappelle vendredi à 14h pour le valider ensemble. Ça vous va ? »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu as : (1) une date précise dans le calendrier, (2) une tâche dans GestiQ avec deadline, (3) le statut prospect mis à jour."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : « je vais réfléchir » → demande « réfléchir à quoi exactement ? » pour identifier l'objection cachée. Pb 2 : pas de prochaine date → tu n'as RIEN fait, recommence le closing. Pb 3 : prix trop bas annoncé → tu ne peux plus remonter, donne TOUJOURS une fourchette haute."},
  {"type":"paragraph","text":"➡️ Étape suivante : SOP « Suivi & Fidélisation » pour le post-RDV."},

  {"type":"heading2","text":"7. POST-RDV : NOTES + WHATSAPP RÉCAP (10 MIN)"},
  {"type":"paragraph","text":"🎯 Objectif : capitaliser sur le RDV à chaud (mémoire à 30 min = -50%). ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : 0-10 min après la fin du RDV."},
  {"type":"paragraph","text":"🖥️ OÙ : GestiQ (notes) + WhatsApp Business."},
  {"type":"numbered","items":[
    "Ouvre la fiche GestiQ du prospect.",
    "Complète les 6 champs de qualification s'il manque qqch.",
    "Écris un résumé de 3-5 lignes dans la timeline.",
    "Crée la tâche suivante avec deadline (ex : « envoyer devis le 19/05 avant 18h »).",
    "Change le statut : Nouveau → Qualifié → Devis envoyé → Négociation → Signé / Perdu.",
    "Envoie un WhatsApp de remerciement + récap."
  ]},
  {"type":"template","text":"« Bonjour Dr Karim, merci pour cet échange très enrichissant. Comme convenu, je vous envoie le devis détaillé jeudi avant 18h. On se rappelle vendredi à 14h pour le valider. Excellente fin de journée ! — [Prénom], Next Gital +212 620 002 066 »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Fiche GestiQ à jour, tâche créée avec deadline, WhatsApp envoyé, statut changé."},
  {"type":"paragraph","text":"➡️ Étape suivante : préparer le devis (SOP « Devis parfait »)."},

  {"type":"divider"},
  {"type":"heading","text":"Scripts / Templates"},

  {"type":"heading2","text":"Script intro de RDV (2 min)"},
  {"type":"template","text":"« Bonjour [Nom], ravi de vous rencontrer. Moi c'est [Prénom], commercial chez Next Gital à Oujda. On va passer 45 min ensemble : d'abord je vous pose quelques questions pour bien comprendre votre besoin, ensuite je vous montre concrètement ce qu'on peut faire pour vous. Ça vous convient ? »"},

  {"type":"heading2","text":"Les 6 questions (à imprimer)"},
  {"type":"template","text":"1. « Pour bien comprendre, qu'est-ce qui vous a fait nous contacter aujourd'hui ? »\n2. « Aujourd'hui, comment trouvez-vous vos nouveaux clients ? »\n3. « Si on construit ensemble votre nouveau site, ça doit vous apporter quoi concrètement dans 6 mois ? »\n4. « Quel est votre budget approximatif pour ce projet ? »\n5. « Pour quelle date idéalement vous aimeriez avoir tout en place ? »\n6. « Y a-t-il d'autres personnes impliquées dans la décision ? »"},

  {"type":"heading2","text":"Script closing avec fourchette de prix"},
  {"type":"template","text":"« Très bien [Nom]. Pour un projet comme le vôtre, on est entre [X] et [Y] MAD HT selon les options. Je vous propose qu'on fasse comme ça : je vous envoie un devis détaillé [jour] avant [heure], on se rappelle [jour+1] à [heure] pour le valider ensemble. Ça vous va ? »"},

  {"type":"heading2","text":"WhatsApp post-RDV"},
  {"type":"template","text":"« Bonjour [Nom], merci pour cet échange très enrichissant. Comme convenu, je vous envoie le devis détaillé [jour] avant [heure]. On se rappelle [jour+1] à [heure] pour le valider. Excellente fin de journée ! — [Prénom], Next Gital +212 620 002 066 »"},

  {"type":"heading2","text":"Recadrage si client demande le prix trop tôt"},
  {"type":"template","text":"« Excellente question. Je préfère vous donner un prix juste après avoir compris votre besoin précis, sinon je risque de vous proposer la mauvaise solution. On en parle dans 20 min, d'accord ? »"},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Fiche prospect ouverte 15 min avant + 2 réalisations choisies",
    "Présentation 2 min faite avec sourire + cadrage du RDV",
    "Écoute libre 5 min — tu as parlé 0 fois de Next Gital",
    "Les 6 questions posées DANS L'ORDRE + réponses notées dans GestiQ",
    "Pitch personnalisé 15 min avec 2 réalisations du même secteur",
    "Closing avec fourchette de prix + date précise du prochain contact",
    "WhatsApp récap envoyé dans les 10 min post-RDV",
    "Statut GestiQ mis à jour + tâche suivante créée avec deadline"
  ]},

  {"type":"callout","variant":"danger","title":"Escalade","text":"Si bloqué plus de 15 min sur une étape (client agressif, technique inconnue, décideur impossible à joindre) → WhatsApp +212 620 002 066 immédiatement."}
]$sop$::jsonb,
    read_min = 15,
    updated_at = now()
WHERE slug = 'ng-commercial-reunion-vente';


-- ════════════════════════════════════════════════════════════════════
-- 2) ng-commercial-objections
-- ════════════════════════════════════════════════════════════════════
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"Pourquoi ce SOP","text":"Une objection n'est PAS un refus, c'est une demande d'information. 90% des deals se signent après 2-3 objections traitées correctement. Ce SOP donne les 5 objections fréquentes + leur traitement mot pour mot."},
  {"type":"callout","variant":"tip","title":"Méthode universelle","text":"ARÉC : Accueillir + Reformuler + Explorer + Convaincre. JAMAIS contredire frontalement."},
  {"type":"callout","variant":"success","title":"Résultat attendu","text":"Le client passe de « non / je réfléchis » à « OK on continue ». Tu sors avec une avancée concrète (devis, signature, 2e RDV)."},
  {"type":"callout","variant":"warning","title":"Règle d'or","text":"Si une objection arrive AVANT que tu aies posé les 6 questions de qualif, c'est que tu as parlé trop vite. Reviens en arrière, écoute."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. IDENTIFIER LA VRAIE OBJECTION"},
  {"type":"paragraph","text":"🎯 Objectif : ne pas traiter la fausse objection (« c'est cher » cache souvent « je ne vois pas la valeur »). ⏱️ Temps : 2-3 min."},
  {"type":"paragraph","text":"📍 Point de départ : le client vient de dire NON ou « je vais réfléchir »."},
  {"type":"paragraph","text":"🖥️ OÙ : en RDV (Meet, présentiel, téléphone) — pas par écrit."},
  {"type":"numbered","items":[
    "Reste calme, ne te défends pas, ne contredis pas.",
    "Reformule l'objection avec ses mots exacts : « Si je comprends bien, vous trouvez que c'est trop cher, c'est ça ? »",
    "Attends la confirmation : oui / non / nuance.",
    "Pose la question d'exploration : « Trop cher par rapport à quoi exactement ? »",
    "Écoute la VRAIE raison (budget, valeur perçue, comparaison concurrent, timing)."
  ]},
  {"type":"paragraph","text":"✏️ EXEMPLES DE VRAIES VS FAUSSES OBJECTIONS :"},
  {"type":"list","items":[
    "**« C'est cher »** → vraie cause possible : pas de budget / ne voit pas la valeur / a un concurrent moins cher → traiter selon la cause",
    "**« Je dois réfléchir »** → vraie cause : pas convaincu / décideur absent / peur de se tromper → identifier laquelle",
    "**« Je vais voir avec mon associé »** → vraie cause : décideur réel = associé OU prétexte poli → proposer 2e RDV à 3",
    "**« On n'a pas le temps »** → vraie cause : pas prioritaire / pense qu'il doit travailler → expliquer qu'on s'occupe de tout"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu as identifié la VRAIE objection (pas celle prononcée). Tu sais quel traitement appliquer."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu traites direct sans explorer → tu perds le deal. Pb 2 : tu argumentes avant de reformuler → le client se braque."},
  {"type":"paragraph","text":"➡️ Étape suivante : appliquer le traitement adapté."},

  {"type":"heading2","text":"2. OBJECTION « C'EST TROP CHER »"},
  {"type":"paragraph","text":"🎯 Objectif : repositionner la valeur, montrer le ROI. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : le client vient de dire « c'est cher »."},
  {"type":"paragraph","text":"🖥️ OÙ : RDV en cours."},
  {"type":"numbered","items":[
    "Accueille : « Je comprends totalement votre réaction. »",
    "Reformule : « C'est plus que ce que vous imaginiez, c'est ça ? »",
    "Explore : « Trop cher par rapport à quoi exactement ? Votre budget ? Un autre devis ? »",
    "Recadre sur le ROI : « Sur 12 mois, ça représente combien par mois ? Et combien de nouveaux clients vous devez gagner pour rentabiliser ? »",
    "Propose une alternative SANS BAISSER LE PRIX : étalement de paiement, version starter, options retirables.",
    "Conclus : « Avec un étalement 50% maintenant + 50% à la livraison, est-ce que ça devient possible pour vous ? »"
  ]},
  {"type":"template","text":"« Je comprends Dr Karim. Mais regardons : 20 000 MAD pour un site qui va générer 30 nouveaux patients/mois pendant 3 ans, c'est environ 550 MAD/mois. Combien vous rapporte un nouveau patient sur 1 an ? … Donc dès le 2e patient vous êtes rentable. Si on étale en 2 paiements 50/50, est-ce que ça devient faisable ? »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le client passe de « c'est cher » à « OK ça peut le faire en étalant »."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu baisses le prix direct → tu détruis ta marge ET ta crédibilité. Pb 2 : tu compares à un concurrent → tu te dévalorises. JAMAIS de remise sans contrepartie (voir SOP Négociation)."},
  {"type":"paragraph","text":"➡️ Étape suivante : closing ou prochaine objection."},

  {"type":"heading2","text":"3. OBJECTION « JE DOIS RÉFLÉCHIR »"},
  {"type":"paragraph","text":"🎯 Objectif : faire émerger l'objection cachée. ⏱️ Temps : 3-5 min."},
  {"type":"paragraph","text":"📍 Point de départ : le client dit « laissez-moi réfléchir »."},
  {"type":"paragraph","text":"🖥️ OÙ : RDV en cours."},
  {"type":"numbered","items":[
    "Accueille : « Bien sûr, c'est normal de réfléchir. »",
    "Pose la question magique : « Réfléchir à quoi exactement ? Le prix ? Le délai ? Les fonctionnalités ? »",
    "Écoute la VRAIE raison qui sort.",
    "Traite la vraie objection (prix → ROI, délai → ajustement, fonctions → option).",
    "Cadre la suite : « OK donc si on règle [point], on peut avancer ensemble ? »",
    "Bloque la prochaine étape avec date : « Je vous rappelle vendredi à 14h, ça vous va ? »"
  ]},
  {"type":"template","text":"« Bien sûr, c'est normal. Juste pour bien vous aider : réfléchir à quoi exactement ? Le prix, le délai, les fonctionnalités, ou autre chose ? … D'accord, si on règle le délai en livrant 1 semaine plus tôt, on peut avancer ensemble ? »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu as identifié la vraie objection ET tu as posé une question fermée engageante."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu acceptes « je réfléchis » sans creuser → tu perds le deal dans 80% des cas. Pb 2 : tu ne bloques pas de date de rappel → le prospect disparaît."},
  {"type":"paragraph","text":"➡️ Étape suivante : traiter la vraie objection."},

  {"type":"heading2","text":"4. OBJECTION « J'AI DÉJÀ UN SITE »"},
  {"type":"paragraph","text":"🎯 Objectif : transformer la possession en insatisfaction productive. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : le client mentionne son site existant."},
  {"type":"paragraph","text":"🖥️ OÙ : RDV + ouvre son site dans un onglet."},
  {"type":"numbered","items":[
    "Demande l'URL : « Super, je peux le voir ? »",
    "Ouvre le site devant lui et observe 30 secondes.",
    "Pose 3 questions diagnostic : « Combien de visites/mois ? Combien de demandes via le site ? Mobile ou ordinateur en majorité ? »",
    "Si chiffres faibles → propose un audit gratuit : « On vous fait un audit complet gratuit, sans engagement. Vous voulez ? »",
    "Si client satisfait → repositionne sur AMÉLIORATION (SEO, vitesse, conversion, prise de RDV).",
    "Conclus : « On peut faire un site qui multiplie par 3 vos demandes, intéressé ? »"
  ]},
  {"type":"template","text":"« Super, je peux voir votre site ? … OK je le découvre. Dites-moi : combien de visites par mois ? Et combien de demandes de RDV vous recevez via le site ? … 5 par mois ? Si je vous dis qu'on peut passer à 30 par mois avec une refonte, ça vous intéresse ? »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le client a admis un manque (peu de visites, peu de demandes, pas mobile-friendly). Tu as proposé un audit gratuit."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu critiques son site frontalement → tu blesses son ego. Reste factuel. Pb 2 : tu n'as pas demandé l'URL → tu argumentes dans le vide."},
  {"type":"paragraph","text":"➡️ Étape suivante : envoyer audit dans les 48h."},

  {"type":"heading2","text":"5. OBJECTION « ON N'A PAS LE TEMPS »"},
  {"type":"paragraph","text":"🎯 Objectif : rassurer sur la charge de travail côté client. ⏱️ Temps : 3 min."},
  {"type":"paragraph","text":"📍 Point de départ : le client invoque le manque de temps."},
  {"type":"paragraph","text":"🖥️ OÙ : RDV en cours."},
  {"type":"numbered","items":[
    "Accueille : « Je comprends, vous êtes débordé. »",
    "Explique le process : « Justement, on s'occupe de TOUT. De votre côté c'est : 1 brief de 1h + 2 validations de 30 min. C'est tout. »",
    "Donne un chiffre : « Au total, vous passez 2-3h sur 6 semaines. »",
    "Rassure : « Si vous ne répondez pas vite, on attend, pas de stress. »",
    "Conclus : « 2h sur 6 semaines pour un site qui travaille pour vous 24/7, ça vaut le coup non ? »"
  ]},
  {"type":"template","text":"« Je comprends Dr Karim. Mais justement, on s'occupe de TOUT. De votre côté c'est : 1 brief d'1h, on revient avec une maquette que vous validez en 30 min, et 1 dernière validation avant lancement. Total 2-3h sur 6 semaines. Le reste c'est nous. Ça vous va comme charge ? »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le client comprend que la charge sur lui = 2-3h max. Objection désamorcée."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu listes 50 étapes → tu effraies. Sois bref. Pb 2 : tu dis « ça prend du temps » → tu confirmes son objection."},
  {"type":"paragraph","text":"➡️ Étape suivante : closing."},

  {"type":"heading2","text":"6. OBJECTION « JE VAIS VOIR AVEC MON ASSOCIÉ / MA FEMME »"},
  {"type":"paragraph","text":"🎯 Objectif : ne pas perdre le deal entre deux RDV. ⏱️ Temps : 3 min."},
  {"type":"paragraph","text":"📍 Point de départ : le client mentionne un autre décideur."},
  {"type":"paragraph","text":"🖥️ OÙ : RDV + Calendly ouvert."},
  {"type":"numbered","items":[
    "Accueille : « Bien sûr, c'est normal de décider à plusieurs. »",
    "Propose immédiatement un 2e RDV à 3 : « Plutôt que vous lui réexpliquiez seul, et si on faisait un RDV ensemble tous les 3 ? Comme ça il a les bonnes infos directement. »",
    "Sors Calendly : « Quel créneau cette semaine ou la prochaine ? »",
    "Bloque la date.",
    "Envoie invitation Google Meet + récap WhatsApp + lien Calendly au prospect.",
    "Mets à jour GestiQ : statut « 2e RDV planifié » + ajoute le 2e décideur en contact."
  ]},
  {"type":"template","text":"« Excellente idée ! Plutôt que vous deviez tout lui réexpliquer, et si on faisait un RDV à 3 ? Ça lui évite de douter et vous gagnez du temps. Voici mon Calendly : calendly.com/nextgital. Quel créneau cette semaine vous arrange ? »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"2e RDV bloqué avec le vrai décideur, invitation envoyée."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu laisses le prospect parler à l'associé seul → message déformé, tu perds 70% de ces deals. Pb 2 : tu ne bloques pas de date ferme → ghosting garanti."},
  {"type":"paragraph","text":"➡️ Étape suivante : préparer le 2e RDV avec l'associé (SOP Réunion de vente)."},

  {"type":"heading2","text":"7. APRÈS LE TRAITEMENT : CLOSING"},
  {"type":"paragraph","text":"🎯 Objectif : verrouiller un engagement précis. ⏱️ Temps : 2 min."},
  {"type":"paragraph","text":"📍 Point de départ : l'objection est désamorcée."},
  {"type":"paragraph","text":"🖥️ OÙ : RDV + GestiQ."},
  {"type":"numbered","items":[
    "Pose une question fermée : « Donc on est d'accord pour avancer ? »",
    "Définis la prochaine étape précise (devis, signature, 2e RDV).",
    "Bloque date + heure dans le calendrier devant lui.",
    "Confirme par WhatsApp dans les 10 min.",
    "Mets à jour GestiQ + tâche suivante."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu sors avec un engagement daté. Pas de « on se rappelle plus tard »."},

  {"type":"divider"},
  {"type":"heading","text":"Scripts / Templates"},

  {"type":"heading2","text":"Méthode ARÉC universelle"},
  {"type":"template","text":"Accueillir : « Je comprends totalement votre réaction. »\nReformuler : « Si je comprends bien, [objection]. C'est bien ça ? »\nExplorer : « [Objection] par rapport à quoi exactement ? »\nConvaincre : [argument adapté à la vraie cause]"},

  {"type":"heading2","text":"Réponse « C'est trop cher »"},
  {"type":"template","text":"« Je comprends. Regardons : [prix] sur 12 mois c'est [X] MAD/mois. Combien de nouveaux clients vous devez gagner pour rentabiliser ? … Donc dès le [N]ème client vous êtes rentable. Avec un étalement 50/50, ça devient possible ? »"},

  {"type":"heading2","text":"Réponse « Je dois réfléchir »"},
  {"type":"template","text":"« Bien sûr. Juste pour vous aider : réfléchir à quoi exactement ? Le prix, le délai, les fonctionnalités ? … OK donc si on règle [point], on peut avancer ? Je vous rappelle [date] à [heure]. »"},

  {"type":"heading2","text":"Réponse « J'ai déjà un site »"},
  {"type":"template","text":"« Super, je peux voir votre site ? … Combien de visites/mois ? Combien de demandes via le site ? … Si on peut tripler ce chiffre, ça vous intéresse ? On vous fait un audit gratuit sans engagement. »"},

  {"type":"heading2","text":"Réponse « Pas le temps »"},
  {"type":"template","text":"« Justement, on s'occupe de tout. De votre côté c'est : 1 brief 1h + 2 validations 30 min. Total 2-3h sur 6 semaines. Le reste c'est nous. Ça vous va ? »"},

  {"type":"heading2","text":"Réponse « Je vois avec mon associé »"},
  {"type":"template","text":"« Excellente idée ! Plutôt que vous deviez tout réexpliquer, et si on faisait un RDV à 3 ? Voici mon Calendly : calendly.com/nextgital. Quel créneau cette semaine ? »"},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Tu as ACCUEILLI l'objection (pas contre-attaqué)",
    "Tu as REFORMULÉ avec les mots du client",
    "Tu as EXPLORÉ la vraie cause cachée",
    "Tu as répondu avec un argument FACTUEL (chiffres, exemples)",
    "Tu n'as PAS baissé le prix sans contrepartie",
    "Tu as posé une question de closing fermée",
    "Tu as bloqué une prochaine étape avec date précise",
    "GestiQ mis à jour + WhatsApp récap envoyé"
  ]},

  {"type":"callout","variant":"danger","title":"Escalade","text":"Si objection inconnue ou client agressif, > 10 min bloqué → WhatsApp +212 620 002 066 avec contexte + objection exacte."}
]$sop$::jsonb,
    read_min = 12,
    updated_at = now()
WHERE slug = 'ng-commercial-objections';


-- ════════════════════════════════════════════════════════════════════
-- 3) ng-commercial-closing
-- ════════════════════════════════════════════════════════════════════
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"Pourquoi ce SOP","text":"Le closing, c'est le moment où le prospect devient client. 50% des commerciaux ne demandent JAMAIS la signature explicitement. Ce SOP donne 6 techniques de closing concrètes + le contrat type prêt à signer."},
  {"type":"callout","variant":"tip","title":"Règle de base","text":"Si tu n'as pas posé les 6 questions de qualif + traité les objections, NE CLÔTURE PAS. Tu vas brûler le deal."},
  {"type":"callout","variant":"success","title":"Résultat attendu","text":"Contrat signé (ContractBook / DocuSign), acompte 50% reçu, projet lancé en Slack/Notion."},
  {"type":"callout","variant":"warning","title":"Règle d'or","text":"Demande TOUJOURS la signature explicitement. Ne reste pas dans l'implicite : « Est-ce qu'on lance ? »"},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. DÉTECTER LES SIGNAUX D'ACHAT"},
  {"type":"paragraph","text":"🎯 Objectif : repérer le moment où le client est prêt à signer. ⏱️ Temps : continu pendant le RDV."},
  {"type":"paragraph","text":"📍 Point de départ : pendant le pitch / la démo."},
  {"type":"paragraph","text":"🖥️ OÙ : RDV en cours."},
  {"type":"paragraph","text":"✏️ SIGNAUX D'ACHAT À REPÉRER :"},
  {"type":"list","items":[
    "**Questions sur le délai** → « Et combien de temps ça prend ? » → il se projette",
    "**Questions sur le paiement** → « On peut payer en plusieurs fois ? » → il pense déjà à comment payer",
    "**Questions sur l'après** → « Et la maintenance ? » → il pense à long terme",
    "**Utilisation du « on » / « nous »** → « On commencerait quand alors ? »",
    "**Validation implicite** → « Ça me plaît », « C'est ce que je cherchais », hochements répétés",
    "**Demande de garantie** → « Et si ça ne marche pas ? » → il anticipe l'engagement"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu as repéré au moins 2 signaux d'achat → c'est le moment de clôturer."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu continues à pitcher après les signaux → tu lasses, le client reprend ses objections. Pb 2 : tu attends qu'il signe spontanément → ça n'arrive JAMAIS."},
  {"type":"paragraph","text":"➡️ Étape suivante : présenter les 3 options de tarif."},

  {"type":"heading2","text":"2. PRÉSENTER 3 OPTIONS (SMALL / MEDIUM / LARGE)"},
  {"type":"paragraph","text":"🎯 Objectif : créer du choix, ancrer une valeur premium, faire choisir le medium. ⏱️ Temps : 3-5 min."},
  {"type":"paragraph","text":"📍 Point de départ : après les signaux d'achat."},
  {"type":"paragraph","text":"🖥️ OÙ : partage écran sur tableau 3 colonnes (Notion ou PDF)."},
  {"type":"numbered","items":[
    "Annonce : « J'ai 3 formules pour vous, je vous les présente. »",
    "Présente SMALL : « 8 000 MAD — site vitrine 5 pages, basique. »",
    "Présente LARGE en 2e : « 35 000 MAD — site complet + e-commerce + SEO + maintenance 6 mois. »",
    "Présente MEDIUM en 3e (le préféré) : « 18 000 MAD — site complet 10 pages + prise de RDV + SEO de base + formation. »",
    "Reste silencieux, attends qu'il pointe une option.",
    "Confirme : « Le medium semble correspondre à votre besoin, c'est ça ? »"
  ]},
  {"type":"template","text":"« J'ai 3 formules adaptées à votre projet :\n\n• STARTER 8 000 MAD HT : site vitrine 5 pages, design simple, sans SEO.\n• PREMIUM 35 000 MAD HT : site complet 15 pages + e-commerce + SEO avancé + maintenance 6 mois + Ads.\n• ESSENTIEL 18 000 MAD HT : site complet 10 pages + prise de RDV en ligne + SEO de base + formation. C'est notre formule la plus choisie par les cabinets comme le vôtre.\n\nLaquelle correspond le mieux à ce que vous cherchez ? »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le client pointe une formule (généralement Essentiel) → tu peux closer."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu présentes 1 seule formule → pas de choix, plus dur à clôturer. Pb 2 : tu présentes 5 formules → paralysie, il dit « je vais réfléchir »."},
  {"type":"paragraph","text":"➡️ Étape suivante : demander l'engagement explicite."},

  {"type":"heading2","text":"3. DEMANDER L'ENGAGEMENT EXPLICITE"},
  {"type":"paragraph","text":"🎯 Objectif : sortir du flou, obtenir un OUI clair. ⏱️ Temps : 1 min."},
  {"type":"paragraph","text":"📍 Point de départ : le client a choisi une formule."},
  {"type":"paragraph","text":"🖥️ OÙ : RDV en cours."},
  {"type":"numbered","items":[
    "Reformule : « OK donc vous partez sur la formule Essentiel à 18 000 MAD HT. »",
    "Pose LA question : « Est-ce qu'on lance ? »",
    "SILENCE. Ne parle plus. Attends.",
    "Selon réponse → procéder à la signature OU traiter l'objection finale.",
    "Si « oui » → enchaîne avec le contrat (étape 4)."
  ]},
  {"type":"template","text":"« Parfait, donc on part sur la formule Essentiel à 18 000 MAD HT, livraison en 6 semaines, 50% à la commande et 50% à la livraison. Est-ce qu'on lance ? »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le client a dit « oui » de façon claire."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu meubles le silence en parlant → tu donnes une excuse de réfléchir. Le 1er qui parle perd. Pb 2 : tu ne demandes JAMAIS clairement → le client part sans s'engager."},
  {"type":"paragraph","text":"➡️ Étape suivante : envoyer le contrat."},

  {"type":"heading2","text":"4. ENVOYER LE CONTRAT (CONTRACTBOOK / DOCUSIGN)"},
  {"type":"paragraph","text":"🎯 Objectif : faire signer dans les 24-48h (sinon le deal refroidit). ⏱️ Temps : 10 min pour préparer + envoyer."},
  {"type":"paragraph","text":"📍 Point de départ : le client a dit OUI."},
  {"type":"paragraph","text":"🖥️ OÙ : ContractBook (contractbook.com) ou DocuSign + email Titan info@nextgital.com."},
  {"type":"numbered","items":[
    "Ouvre le template « Contrat Site Web Next Gital » dans ContractBook.",
    "Remplis les champs : nom client, raison sociale, ICE, adresse, formule, prix, conditions paiement.",
    "Vérifie 2 fois : nom complet + prix + délai + conditions paiement.",
    "Génère le PDF + envoie via ContractBook avec signature électronique.",
    "Envoie un email Titan parallèle avec récap + facture acompte 50%.",
    "Préviens par WhatsApp : « Le contrat vient d'être envoyé sur votre email, à signer avant [date]. »"
  ]},
  {"type":"template","text":"« Bonjour Dr Karim,\n\nComme convenu, voici le contrat Next Gital pour la formule Essentiel à 18 000 MAD HT.\n\n• Pièce jointe : contrat (à signer électroniquement via le lien ci-dessous)\n• Pièce jointe : facture acompte 50% = 9 000 MAD HT à régler par virement\n\nLien signature : [lien ContractBook]\n\nDès réception de la signature + acompte, on démarre le brief sous 48h.\n\nEn cas de question, je suis à votre disposition.\n\nCordialement,\n[Prénom] — Next Gital\ninfo@nextgital.com — +212 620 002 066 »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Contrat envoyé, email + WhatsApp confirmation envoyés, tâche GestiQ « relancer si pas signé J+2 » créée."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : faute de frappe sur le nom / prix → JAMAIS, c'est rédhibitoire. Pb 2 : pas de relance prévue → le contrat dort dans la boîte mail."},
  {"type":"paragraph","text":"➡️ Étape suivante : suivre la signature + recevoir l'acompte."},

  {"type":"heading2","text":"5. RELANCER SI PAS SIGNÉ APRÈS 48H"},
  {"type":"paragraph","text":"🎯 Objectif : ne pas laisser le deal refroidir. ⏱️ Temps : 2 min."},
  {"type":"paragraph","text":"📍 Point de départ : J+2 après envoi contrat, pas de signature."},
  {"type":"paragraph","text":"🖥️ OÙ : ContractBook (dashboard) + WhatsApp Business."},
  {"type":"numbered","items":[
    "Vérifie le statut du contrat dans ContractBook (envoyé / vu / signé).",
    "Si statut « vu » mais non signé → message WhatsApp doux : « Bonjour [Nom], avez-vous des questions sur le contrat ? »",
    "Si statut « pas vu » → email + WhatsApp avec relance + lien.",
    "Si toujours rien à J+5 → appel téléphonique direct.",
    "Si pas de réponse à J+7 → marque GestiQ « En pause » + suivi 30 jours plus tard."
  ]},
  {"type":"template","text":"« Bonjour Dr Karim, je voulais m'assurer que vous aviez bien reçu le contrat envoyé mardi. Avez-vous des questions ? Je suis dispo pour un appel rapide si besoin. — [Prénom], Next Gital »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu as au moins 1 relance par canal (email, WhatsApp, téléphone). Pas de ghosting accepté."},
  {"type":"paragraph","text":"➡️ Étape suivante : confirmer réception acompte."},

  {"type":"heading2","text":"6. RÉCEPTION ACOMPTE + LANCEMENT PROJET"},
  {"type":"paragraph","text":"🎯 Objectif : démarrer officiellement le projet. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"📍 Point de départ : contrat signé + acompte 50% reçu sur compte bancaire."},
  {"type":"paragraph","text":"🖥️ OÙ : compte bancaire + GestiQ + Slack/Notion (création projet)."},
  {"type":"numbered","items":[
    "Confirme la réception de l'acompte par WhatsApp + email au client.",
    "Émets le reçu officiel d'acompte + envoie par email.",
    "Change le statut GestiQ : « Prospect signé → Client actif ».",
    "Crée le projet dans Notion (template projet web) + assigne le chef de projet.",
    "Notifie l'équipe Next Gital sur Slack canal #nouveaux-projets.",
    "Envoie au client le kit bienvenue (SOP « Suivi & Fidélisation » étape 1)."
  ]},
  {"type":"template","text":"« Bonjour Dr Karim, je confirme la bonne réception de l'acompte de 9 000 MAD HT. Bienvenue dans la famille Next Gital ! Notre chef de projet [Nom] vous contacte demain pour caler le brief. À très vite ! — [Prénom] »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Acompte encaissé, reçu envoyé, projet créé dans Notion, équipe notifiée, kit bienvenue envoyé."},

  {"type":"divider"},
  {"type":"heading","text":"Scripts / Templates"},

  {"type":"heading2","text":"Présentation 3 formules"},
  {"type":"template","text":"« J'ai 3 formules pour vous :\n• STARTER [X] MAD HT : [scope minimal]\n• PREMIUM [Z] MAD HT : [scope max]\n• ESSENTIEL [Y] MAD HT : [scope idéal, le plus choisi par votre secteur]\n\nLaquelle correspond le mieux à ce que vous cherchez ? »"},

  {"type":"heading2","text":"Question de closing"},
  {"type":"template","text":"« Parfait, donc on part sur la formule [X] à [prix] MAD HT, livraison en [N] semaines, 50% à la commande et 50% à la livraison. Est-ce qu'on lance ? »"},

  {"type":"heading2","text":"Email envoi contrat"},
  {"type":"template","text":"Objet : Contrat Next Gital — [Nom client] — Formule [X]\n\nBonjour [Nom],\n\nComme convenu, voici le contrat pour la formule [X] à [prix] MAD HT.\n\n• Pièce jointe : contrat (signature électronique via le lien ContractBook ci-dessous)\n• Pièce jointe : facture acompte 50% = [montant] MAD HT à régler par virement\n\nRIB Next Gital : [IBAN]\n\nDès réception de la signature + acompte, on démarre le brief sous 48h.\n\nCordialement,\n[Prénom] — Next Gital\ninfo@nextgital.com — +212 620 002 066"},

  {"type":"heading2","text":"WhatsApp relance J+2"},
  {"type":"template","text":"« Bonjour [Nom], je voulais m'assurer que vous aviez bien reçu le contrat envoyé [jour]. Avez-vous des questions ? Je suis dispo pour un appel rapide si besoin. — [Prénom], Next Gital »"},

  {"type":"heading2","text":"Confirmation acompte"},
  {"type":"template","text":"« Bonjour [Nom], je confirme la bonne réception de l'acompte de [montant] MAD HT. Bienvenue dans la famille Next Gital ! Notre chef de projet [Nom CP] vous contacte demain pour caler le brief. À très vite ! — [Prénom] »"},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Au moins 2 signaux d'achat repérés avant de clôturer",
    "3 formules présentées (small / medium / large) avec ancrage premium",
    "Question de closing explicite posée (« Est-ce qu'on lance ? »)",
    "Silence respecté après la question (1er qui parle perd)",
    "Contrat envoyé via ContractBook ou DocuSign avec signature électronique",
    "Email + WhatsApp + facture acompte envoyés en parallèle",
    "Relance prévue à J+2 si non signé (tâche GestiQ)",
    "À la signature : acompte reçu, reçu émis, projet créé Notion, équipe notifiée"
  ]},

  {"type":"callout","variant":"danger","title":"Escalade","text":"Si client signé mais acompte non reçu après 7 jours, ou contrat avec clauses anormales demandées → WhatsApp +212 620 002 066 immédiatement."}
]$sop$::jsonb,
    read_min = 14,
    updated_at = now()
WHERE slug = 'ng-commercial-closing';


-- ════════════════════════════════════════════════════════════════════
-- 4) ng-commercial-negociation
-- ════════════════════════════════════════════════════════════════════
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"Pourquoi ce SOP","text":"La négociation, c'est l'art de défendre sa marge SANS perdre le client. Règle absolue Next Gital : JAMAIS de remise sans contrepartie équivalente. Ce SOP donne les techniques + contreparties acceptables."},
  {"type":"callout","variant":"tip","title":"Marge minimum","text":"Plancher Next Gital : -20% MAX du prix initial, et UNIQUEMENT avec contrepartie. En dessous : escalade obligatoire."},
  {"type":"callout","variant":"success","title":"Résultat attendu","text":"Deal signé avec marge préservée + contrepartie (paiement comptant, témoignage, parrainage, etc.)."},
  {"type":"callout","variant":"warning","title":"Règle d'or","text":"Si tu cèdes une remise sans contrepartie, tu apprends au client qu'il peut TOUJOURS négocier. Et tu perds 20% sur tous les futurs deals."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. ANCRAGE TARIF PREMIUM EN PREMIER"},
  {"type":"paragraph","text":"🎯 Objectif : poser un prix de référence élevé pour que la négo se fasse autour. ⏱️ Temps : intégré dans le pitch."},
  {"type":"paragraph","text":"📍 Point de départ : pendant la présentation des formules."},
  {"type":"paragraph","text":"🖥️ OÙ : RDV en cours."},
  {"type":"numbered","items":[
    "Présente TOUJOURS la formule la plus chère en premier visuellement.",
    "Annonce le prix premium avec assurance : « Notre formule complète c'est 35 000 MAD HT. »",
    "Laisse un silence de 2 secondes.",
    "Présente ensuite les 2 autres formules : « Mais on a aussi 18 000 et 8 000. »",
    "L'ancrage 35k rend le 18k « raisonnable ».",
    "Si client négocie sur le 18k → tu peux montrer que c'est DÉJÀ une remise vs le 35k."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu as annoncé le prix premium SANS hésiter. Tu n'as pas dit « ça commence à 8 000 ». Tu as fait l'inverse."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu commences par le prix bas → tu casses ton ancrage. Pb 2 : tu hésites en disant le prix premium → le client te sent fragile. Dis-le ferme."},
  {"type":"paragraph","text":"➡️ Étape suivante : utiliser le silence quand il négocie."},

  {"type":"heading2","text":"2. TECHNIQUE DU SILENCE APRÈS PRIX"},
  {"type":"paragraph","text":"🎯 Objectif : laisser le client se débattre seul avec son objection. ⏱️ Temps : 5-10 secondes (longues)."},
  {"type":"paragraph","text":"📍 Point de départ : tu viens d'annoncer ou de défendre un prix."},
  {"type":"paragraph","text":"🖥️ OÙ : RDV en cours."},
  {"type":"numbered","items":[
    "Annonce ton prix avec assurance.",
    "STOP. Ne parle plus.",
    "Compte mentalement 1-2-3-4-5-6-7-8.",
    "Le client va parler en premier (loi statistique).",
    "Écoute sa réaction (acceptation, négociation, objection).",
    "Réagis seulement APRÈS sa réaction."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu as respecté au moins 5 secondes de silence. Le client a parlé en premier."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu paniques et ajoutes « mais c'est négociable » → tu viens d'ouvrir la négo toi-même. Pb 2 : tu meubles « bien sûr c'est juste une indication » → tu déforces ton offre."},
  {"type":"paragraph","text":"➡️ Étape suivante : appliquer la règle des contreparties."},

  {"type":"heading2","text":"3. RÈGLE DES CONTREPARTIES (CRUCIAL)"},
  {"type":"paragraph","text":"🎯 Objectif : ne JAMAIS donner sans recevoir. ⏱️ Temps : 5 min de négo."},
  {"type":"paragraph","text":"📍 Point de départ : le client demande une remise."},
  {"type":"paragraph","text":"🖥️ OÙ : RDV en cours."},
  {"type":"paragraph","text":"✏️ CONTREPARTIES ACCEPTABLES (toujours en demander UNE) :"},
  {"type":"list","items":[
    "**Paiement comptant 100%** → remise 10% max (gain trésorerie + zéro relance)",
    "**Témoignage vidéo 2 min** → remise 5% (gain marketing énorme)",
    "**Parrainage 2 clients** → remise 10% (acquisition gratuite)",
    "**Allongement délai +4 semaines** → remise 5% (lisse la prod)",
    "**Réduction scope (pages -2)** → remise 10% (vraie économie de prod)",
    "**Mention « Site by Next Gital » en footer** → remise 5% (SEO + visibilité)",
    "**Cas d'étude publié + interview** → remise 15% (contenu marketing premium)"
  ]},
  {"type":"template","text":"« Je peux faire 18 000 → 16 200 MAD HT (-10%), MAIS uniquement si vous me confirmez : (1) paiement comptant à la signature ET (2) un témoignage vidéo de 2 min à la livraison. Ça vous va ? »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Toute remise accordée s'accompagne d'au moins UNE contrepartie écrite dans le contrat."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu dis « OK -10% » sans contrepartie → tu démontres que ton prix était surfait. Pb 2 : tu acceptes la contrepartie ORALEMENT mais elle n'est pas dans le contrat → elle ne sera jamais honorée."},
  {"type":"paragraph","text":"➡️ Étape suivante : technique des concessions décroissantes."},

  {"type":"heading2","text":"4. CONCESSIONS DÉCROISSANTES"},
  {"type":"paragraph","text":"🎯 Objectif : montrer que tu approches du plancher. ⏱️ Temps : 3-5 min."},
  {"type":"paragraph","text":"📍 Point de départ : le client demande une 2e remise après la 1ère."},
  {"type":"paragraph","text":"🖥️ OÙ : RDV en cours."},
  {"type":"numbered","items":[
    "1ère concession : -10% avec contrepartie A.",
    "2e concession (si insiste) : -5% supplémentaire avec contrepartie B.",
    "3e concession (rare) : -3% MAX avec contrepartie C.",
    "STOP. Plancher atteint à -18%.",
    "Énonce clairement : « Là, je suis vraiment au plancher, on ne peut pas aller plus loin. »",
    "Si insiste encore → escalade au manager (+212 620 002 066)."
  ]},
  {"type":"template","text":"« Dr Karim, je vous ai déjà fait -10% avec le paiement comptant, puis -5% avec le témoignage. Là je suis vraiment au plancher autorisé. Si vous voulez vraiment descendre plus, il faut qu'on réduise le scope : on enlève les 2 pages e-commerce et on tombe à 14 000 MAD HT. Ça vous convient ? »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tes concessions sont décroissantes (10% → 5% → 3%). Tu n'as pas dépassé -20% total."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : concessions croissantes (5% → 10% → 15%) → le client comprend que tu peux encore baisser. Pb 2 : tu cèdes au-delà de -20% sans escalade → ta marge devient négative."},
  {"type":"paragraph","text":"➡️ Étape suivante : verrouillage final."},

  {"type":"heading2","text":"5. VERROUILLAGE PAR RÉDUCTION DE SCOPE"},
  {"type":"paragraph","text":"🎯 Objectif : préserver la marge horaire en enlevant du livrable. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : le client insiste pour descendre encore."},
  {"type":"paragraph","text":"🖥️ OÙ : RDV + devis ouvert."},
  {"type":"numbered","items":[
    "Annonce : « Je ne peux plus baisser le prix, mais je peux ajuster le contenu. »",
    "Liste les éléments retirables : pages additionnelles, e-commerce, blog, formation longue, maintenance.",
    "Pour chaque élément retiré, annonce le gain en MAD : « On enlève les 5 pages produit → -3 000 MAD. »",
    "Laisse le client choisir ce qu'il veut retirer.",
    "Mets à jour le devis devant lui (nouveau prix + scope réduit).",
    "Confirme : « On part sur cette nouvelle version à [prix] avec [scope] ? »"
  ]},
  {"type":"template","text":"« Pour descendre de 16 200 à 13 000 MAD HT, on peut retirer : (1) les 5 pages produits e-commerce = -2 500 MAD, (2) la formation longue 4h → courte 1h = -700 MAD. Total -3 200 MAD. Ça vous convient comme version ajustée ? »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu as réduit le SCOPE pas la MARGE. Le devis ajusté est validé devant le client."},
  {"type":"paragraph","text":"➡️ Étape suivante : finaliser le contrat avec les contreparties écrites."},

  {"type":"heading2","text":"6. ÉCRIRE LES CONTREPARTIES DANS LE CONTRAT"},
  {"type":"paragraph","text":"🎯 Objectif : sécuriser les contreparties juridiquement. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : remise accordée + contrepartie convenue."},
  {"type":"paragraph","text":"🖥️ OÙ : ContractBook / DocuSign — section « Conditions particulières »."},
  {"type":"numbered","items":[
    "Ouvre le contrat dans ContractBook.",
    "Va dans la section « Conditions particulières » (à créer si absente).",
    "Écris en clair : « Le client bénéficie d'une remise de [X]% en contrepartie de : [liste]. »",
    "Précise les délais : témoignage vidéo à livrer dans les 30 jours post-livraison, parrainage dans les 90 jours, etc.",
    "Précise la pénalité si contrepartie non honorée : « En cas de non-respect, la remise sera facturée a posteriori. »",
    "Fais signer avec ces conditions visibles."
  ]},
  {"type":"template","text":"« CONDITIONS PARTICULIÈRES :\n\nLe Client bénéficie d'une remise commerciale de 10% (soit 1 800 MAD HT) sur le présent contrat, en contrepartie des engagements suivants :\n\n1. Paiement intégral de 100% à la signature du contrat (au lieu du 50/50 standard)\n2. Fourniture d'un témoignage vidéo de minimum 2 minutes, livré dans les 30 jours suivant la réception du site\n\nEn cas de non-respect de l'engagement n°2, la remise de 10% sera refacturée a posteriori. »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le contrat contient les contreparties écrites + pénalités. Tu peux récupérer la remise si non-respect."},

  {"type":"divider"},
  {"type":"heading","text":"Scripts / Templates"},

  {"type":"heading2","text":"Annonce remise + contrepartie"},
  {"type":"template","text":"« Je peux faire [prix initial] → [prix remisé] MAD HT (-[X]%), MAIS uniquement si vous me confirmez : (1) [contrepartie 1] ET (2) [contrepartie 2]. Ça vous va ? »"},

  {"type":"heading2","text":"Refus poli d'une remise sans contrepartie"},
  {"type":"template","text":"« Dr Karim, je comprends votre demande. Chez Next Gital, on n'accorde jamais de remise sans contrepartie, c'est une question d'équité avec tous nos clients. Qu'est-ce que vous pouvez nous offrir en échange : paiement comptant, témoignage vidéo, parrainage ? »"},

  {"type":"heading2","text":"Plancher atteint"},
  {"type":"template","text":"« Là je suis vraiment au plancher autorisé. Si vous voulez vraiment descendre plus, il faut qu'on réduise le scope. Quelles fonctionnalités vous êtes prêt à retirer ? »"},

  {"type":"heading2","text":"Réduction de scope"},
  {"type":"template","text":"« Pour descendre de [prix actuel] à [prix cible] MAD HT, on peut retirer : (1) [élément A] = -[X] MAD, (2) [élément B] = -[Y] MAD. Total -[Z] MAD. Ça vous convient comme version ajustée ? »"},

  {"type":"heading2","text":"Clause contrepartie dans contrat"},
  {"type":"template","text":"CONDITIONS PARTICULIÈRES :\n\nLe Client bénéficie d'une remise commerciale de [X]% (soit [montant] MAD HT) en contrepartie des engagements suivants :\n1. [Contrepartie 1 avec délai]\n2. [Contrepartie 2 avec délai]\n\nEn cas de non-respect, la remise sera refacturée a posteriori."},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Ancrage premium fait (formule la plus chère présentée en 1er)",
    "Silence respecté après annonce du prix (5-10 sec)",
    "AUCUNE remise accordée sans contrepartie écrite",
    "Concessions décroissantes (jamais croissantes)",
    "Plancher absolu -20% respecté (sinon escalade)",
    "Réduction de scope proposée avant remise supplémentaire",
    "Contreparties + pénalités écrites dans le contrat",
    "Contrat envoyé avec conditions particulières visibles"
  ]},

  {"type":"callout","variant":"danger","title":"Escalade","text":"Si le client demande >-20% de remise OU une contrepartie non listée OU veut renégocier après signature → WhatsApp +212 620 002 066 IMMÉDIATEMENT avant d'accepter quoi que ce soit."}
]$sop$::jsonb,
    read_min = 13,
    updated_at = now()
WHERE slug = 'ng-commercial-negociation';


-- ════════════════════════════════════════════════════════════════════
-- 5) ng-commercial-devis
-- ════════════════════════════════════════════════════════════════════
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"Pourquoi ce SOP","text":"Un devis Next Gital n'est pas une feuille de prix : c'est un OUTIL DE VENTE. Bien fait, il accélère le closing. Mal fait, il refroidit le prospect. Ce SOP donne le template exact + les pièges à éviter."},
  {"type":"callout","variant":"tip","title":"Délai d'envoi","text":"48h MAX après le RDV. Au-delà, le prospect a refroidi de 50%. Idéalement : 24h."},
  {"type":"callout","variant":"success","title":"Résultat attendu","text":"Devis PDF professionnel, en-tête Next Gital, scope clair, prix HT/TTC en MAD, validité 30j, lien signature électronique."},
  {"type":"callout","variant":"warning","title":"Règle d'or","text":"Le devis doit pouvoir être SIGNÉ DIRECTEMENT, sans 2e RDV. Sinon tu ralentis le cycle de vente."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. PRÉPARATION : OUVRIR LE TEMPLATE"},
  {"type":"paragraph","text":"🎯 Objectif : partir d'un template propre, ne pas réinventer. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : RDV terminé, retour bureau."},
  {"type":"paragraph","text":"🖥️ OÙ : Google Drive → dossier « Devis Next Gital » → fichier « TEMPLATE_DEVIS_2026.docx » (ou Notion équivalent)."},
  {"type":"numbered","items":[
    "Ouvre le template « TEMPLATE_DEVIS_2026 » dans Google Drive.",
    "Duplique-le : Fichier → Faire une copie → renomme « DEVIS_[NomClient]_[Date].docx ».",
    "Place la copie dans le dossier « Devis envoyés 2026 ».",
    "Ouvre la fiche GestiQ du prospect pour avoir toutes les infos.",
    "Vérifie que tu as : nom complet client, raison sociale, ICE, adresse, email, téléphone."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Template dupliqué, renommé, infos client prêtes."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu pars d'un ancien devis et oublies de tout modifier → catastrophe (ancien nom client visible). Pb 2 : ICE manquant → impossible de facturer après."},
  {"type":"paragraph","text":"➡️ Étape suivante : remplir l'en-tête."},

  {"type":"heading2","text":"2. EN-TÊTE NEXT GITAL + INFOS CLIENT"},
  {"type":"paragraph","text":"🎯 Objectif : devis légalement valide + professionnel. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : template ouvert."},
  {"type":"paragraph","text":"🖥️ OÙ : document Word/Google Docs."},
  {"type":"paragraph","text":"✏️ EN-TÊTE NEXT GITAL (à NE JAMAIS modifier) :"},
  {"type":"list","items":[
    "**Logo Next Gital** (haut gauche, 200px)",
    "**Raison sociale** : Next Gital",
    "**Adresse** : Bureau N°7, Immeuble Kissi, Oujda, Maroc",
    "**Site** : nextgital.tech",
    "**Email** : info@nextgital.com",
    "**Téléphone** : +212 620 002 066",
    "**ICE / RC / Patente** : [valeurs officielles]"
  ]},
  {"type":"paragraph","text":"✏️ INFOS CLIENT (haut droite) :"},
  {"type":"list","items":[
    "**À l'attention de** : Dr Karim Alaoui",
    "**Raison sociale** : Cabinet Dentaire Alaoui SARL",
    "**Adresse** : [adresse complète Oujda]",
    "**ICE** : [si entreprise]",
    "**Email** : [email client]",
    "**Téléphone** : [téléphone client]"
  ]},
  {"type":"paragraph","text":"✏️ MÉTADONNÉES DU DEVIS :"},
  {"type":"list","items":[
    "**N° Devis** : DEV-2026-[NNN] (incrémenter dans GestiQ)",
    "**Date d'émission** : [date du jour]",
    "**Date de validité** : 30 jours (date d'émission + 30)",
    "**Émis par** : [Prénom Commercial]"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"En-tête Next Gital intact, infos client correctes, n° devis unique, validité 30j affichée."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : faute sur le nom du client → impardonnable, refais. Pb 2 : pas de N° devis → impossible à tracker."},
  {"type":"paragraph","text":"➡️ Étape suivante : décrire le scope."},

  {"type":"heading2","text":"3. SCOPE DÉTAILLÉ (LIVRABLES PRÉCIS)"},
  {"type":"paragraph","text":"🎯 Objectif : éviter les malentendus + justifier le prix. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : tu connais la formule choisie + besoins exprimés."},
  {"type":"paragraph","text":"🖥️ OÙ : section « Description des prestations » du devis."},
  {"type":"numbered","items":[
    "Liste TOUS les livrables sous forme de tableau (Prestation / Détail / Qté / PU / Total).",
    "Sois SPÉCIFIQUE : « Site WordPress 10 pages » et non « site internet ».",
    "Précise les fonctionnalités : « Prise de RDV en ligne via Calendly intégré ».",
    "Précise le design : « 1 maquette présentée + 2 cycles de révisions ».",
    "Précise les exclusions : « Hors hébergement (à charge du client) ».",
    "Mentionne ce qui est inclus : « Formation 1h en visio incluse »."
  ]},
  {"type":"paragraph","text":"✏️ EXEMPLE DE LIGNES DE DEVIS :"},
  {"type":"list","items":[
    "**Design UX/UI** → 1 maquette + 2 cycles de révisions → 3 jours → 4 000 MAD HT",
    "**Développement WordPress** → 10 pages responsive → 10 jours → 8 000 MAD HT",
    "**Intégration prise de RDV** → Calendly + formulaire Tally → 1 jour → 1 500 MAD HT",
    "**SEO de base** → meta-tags, sitemap, indexation Google → 1 jour → 1 500 MAD HT",
    "**Formation** → 1h en visio (Google Meet) → 1h → 500 MAD HT",
    "**Hébergement année 1** → OFFERT → - → 0 MAD",
    "**TOTAL HT** → 15 500 MAD",
    "**TVA 20%** → 3 100 MAD",
    "**TOTAL TTC** → 18 600 MAD"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Chaque ligne est claire, quantifiée, prix unitaire visible. Total HT + TVA + TTC en bas."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : « Site internet — 15 000 MAD » sans détail → le client ne sait pas ce qu'il paye. Pb 2 : oubli de la TVA → différend juridique."},
  {"type":"paragraph","text":"➡️ Étape suivante : conditions de paiement."},

  {"type":"heading2","text":"4. CONDITIONS DE PAIEMENT (CLAIRES)"},
  {"type":"paragraph","text":"🎯 Objectif : éviter tout litige sur les paiements. ⏱️ Temps : 3 min."},
  {"type":"paragraph","text":"📍 Point de départ : prix total calculé."},
  {"type":"paragraph","text":"🖥️ OÙ : section « Conditions de paiement » du devis."},
  {"type":"paragraph","text":"✏️ CONDITIONS STANDARD NEXT GITAL :"},
  {"type":"list","items":[
    "**Acompte** : 50% à la signature du contrat",
    "**Solde** : 50% à la livraison du site (avant mise en ligne définitive)",
    "**Mode** : virement bancaire OU chèque OU espèces (sur RDV)",
    "**RIB** : [IBAN Next Gital complet]",
    "**Délai paiement solde** : 7 jours après livraison",
    "**Pénalité retard** : 1.5% par mois entamé"
  ]},
  {"type":"paragraph","text":"✏️ AUTRES MENTIONS OBLIGATOIRES :"},
  {"type":"list","items":[
    "**Validité du devis** : 30 jours à compter de la date d'émission",
    "**Délai de réalisation** : 6 semaines à compter de la réception de l'acompte",
    "**Propriété intellectuelle** : transfert au client à la réception du solde",
    "**Garantie** : 30 jours de corrections gratuites post-livraison"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Toutes les conditions sont écrites, sans ambigüité."},
  {"type":"paragraph","text":"➡️ Étape suivante : générer le PDF."},

  {"type":"heading2","text":"5. GÉNÉRER PDF + SIGNATURE ÉLECTRONIQUE"},
  {"type":"paragraph","text":"🎯 Objectif : devis PDF prêt à signer en 1 clic. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : Google Docs / Word terminé."},
  {"type":"paragraph","text":"🖥️ OÙ : Google Docs → Fichier → Télécharger PDF, puis ContractBook ou DocuSign."},
  {"type":"numbered","items":[
    "Relis le devis ENTIÈREMENT (orthographe, chiffres, nom client).",
    "Vérifie les totaux à la calculette (HT + TVA = TTC).",
    "Télécharge en PDF (Fichier → Télécharger → PDF).",
    "Renomme : « DEVIS_DEV-2026-[NNN]_[NomClient].pdf ».",
    "Upload dans ContractBook (ou DocuSign) → ajoute zone signature client + date.",
    "Génère le lien de signature électronique.",
    "Sauvegarde le PDF dans Google Drive → dossier « Devis 2026 envoyés »."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"PDF généré, signature électronique configurée, fichier sauvegardé dans Drive."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu envoies le .docx au lieu du PDF → image non-pro. Pb 2 : zone signature mal placée → client ne sait pas où signer."},
  {"type":"paragraph","text":"➡️ Étape suivante : envoyer au client."},

  {"type":"heading2","text":"6. ENVOI PAR EMAIL + WHATSAPP"},
  {"type":"paragraph","text":"🎯 Objectif : devis reçu + lu dans les 24h. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : PDF + lien signature prêts."},
  {"type":"paragraph","text":"🖥️ OÙ : Email Titan (info@nextgital.com) + WhatsApp Business."},
  {"type":"numbered","items":[
    "Compose l'email avec objet clair : « Devis Next Gital — [Nom] — [Formule] ».",
    "Joins le PDF + insère le lien de signature électronique.",
    "Rédige un message court qui rappelle les points clés.",
    "Envoie l'email.",
    "Envoie un WhatsApp dans la foulée : « Devis envoyé sur votre email, à valider avant [date+30j]. »",
    "Crée une tâche GestiQ : « Relancer devis DEV-2026-[NNN] à J+3 si non signé »."
  ]},
  {"type":"template","text":"Objet : Devis Next Gital — Cabinet Alaoui — Formule Essentiel\n\nBonjour Dr Karim,\n\nComme promis, voici le devis détaillé pour votre nouveau site cabinet dentaire :\n\n• Pièce jointe : devis DEV-2026-042.pdf\n• Lien signature électronique : [lien ContractBook]\n\nRécapitulatif :\n— Formule Essentiel : site 10 pages + prise de RDV + SEO + formation\n— Délai : 6 semaines après acompte\n— Total : 18 600 MAD TTC (50% acompte, 50% livraison)\n— Validité : 30 jours\n\nDès signature + réception acompte, on démarre le brief sous 48h.\n\nJe reste à votre disposition pour toute question.\n\nCordialement,\n[Prénom] — Next Gital\ninfo@nextgital.com — +212 620 002 066"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Email envoyé + WhatsApp envoyé + tâche relance créée + statut GestiQ « Devis envoyé »."},
  {"type":"paragraph","text":"➡️ Étape suivante : relancer si pas signé J+3."},

  {"type":"heading2","text":"7. RELANCE SI PAS SIGNÉ"},
  {"type":"paragraph","text":"🎯 Objectif : ne pas laisser le devis dormir. ⏱️ Temps : 5 min/relance."},
  {"type":"paragraph","text":"📍 Point de départ : tâche GestiQ J+3 déclenche."},
  {"type":"paragraph","text":"🖥️ OÙ : ContractBook (statut signature) + WhatsApp + Email."},
  {"type":"numbered","items":[
    "Vérifie statut dans ContractBook : envoyé / vu / signé.",
    "Si vu mais pas signé → WhatsApp doux : « Vous avez bien reçu le devis ? Des questions ? ».",
    "Si pas vu → email relance + appel téléphonique.",
    "À J+7 sans réponse → appel téléphonique obligatoire.",
    "À J+15 → email final « Sans réponse, je clôture le dossier ».",
    "À J+30 → statut GestiQ « Perdu » + retour en pipeline suivi 90 jours."
  ]},
  {"type":"template","text":"« Bonjour Dr Karim, je voulais m'assurer que vous aviez bien reçu le devis envoyé lundi. Avez-vous des questions ou souhaitez-vous qu'on en discute ? Je suis dispo pour un appel rapide. — [Prénom], Next Gital »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Toutes les relances ont été tracées dans GestiQ (timeline)."},

  {"type":"divider"},
  {"type":"heading","text":"Scripts / Templates"},

  {"type":"heading2","text":"En-tête Next Gital (à copier)"},
  {"type":"template","text":"NEXT GITAL\nBureau N°7, Immeuble Kissi — Oujda, Maroc\nwww.nextgital.tech — info@nextgital.com — +212 620 002 066\nICE : [valeur] — RC : [valeur] — Patente : [valeur]"},

  {"type":"heading2","text":"Tableau de prestations standard"},
  {"type":"template","text":"| Prestation | Détail | Qté | PU HT | Total HT |\n|---|---|---|---|---|\n| Design UX/UI | 1 maquette + 2 révisions | 3j | 1 333 | 4 000 |\n| Dev WordPress | 10 pages responsive | 10j | 800 | 8 000 |\n| Prise de RDV | Calendly + Tally | 1j | 1 500 | 1 500 |\n| SEO base | meta, sitemap, indexation | 1j | 1 500 | 1 500 |\n| Formation | 1h visio | 1h | 500 | 500 |\n| Hébergement an 1 | OFFERT | - | 0 | 0 |\n| **TOTAL HT** |  |  |  | **15 500** |\n| **TVA 20%** |  |  |  | **3 100** |\n| **TOTAL TTC** |  |  |  | **18 600** |"},

  {"type":"heading2","text":"Conditions de paiement (à copier)"},
  {"type":"template","text":"CONDITIONS DE PAIEMENT :\n• Acompte 50% à la signature du contrat\n• Solde 50% à la livraison (avant mise en ligne définitive)\n• Mode : virement bancaire / chèque / espèces\n• RIB : [IBAN Next Gital]\n• Délai paiement solde : 7 jours après livraison\n• Pénalité retard : 1.5% par mois entamé\n\nVALIDITÉ : 30 jours à compter de la date d'émission\nDÉLAI RÉALISATION : 6 semaines après réception acompte\nGARANTIE : 30 jours de corrections gratuites post-livraison"},

  {"type":"heading2","text":"Email envoi devis"},
  {"type":"template","text":"Objet : Devis Next Gital — [Nom client] — Formule [X]\n\nBonjour [Nom],\n\nComme promis, voici le devis détaillé pour votre projet :\n\n• Pièce jointe : devis DEV-2026-[NNN].pdf\n• Lien signature électronique : [lien ContractBook]\n\nRécapitulatif :\n— Formule [X] : [scope]\n— Délai : [N] semaines après acompte\n— Total : [montant] MAD TTC (50% acompte, 50% livraison)\n— Validité : 30 jours\n\nDès signature + réception acompte, on démarre sous 48h.\n\nJe reste à votre disposition pour toute question.\n\nCordialement,\n[Prénom] — Next Gital\ninfo@nextgital.com — +212 620 002 066"},

  {"type":"heading2","text":"WhatsApp relance J+3"},
  {"type":"template","text":"« Bonjour [Nom], je voulais m'assurer que vous aviez bien reçu le devis envoyé [jour]. Avez-vous des questions ou souhaitez-vous qu'on en discute ? Je suis dispo pour un appel rapide. — [Prénom], Next Gital »"},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Template dupliqué + renommé DEVIS_[NomClient]_[Date]",
    "En-tête Next Gital intact + ICE/RC/Patente présents",
    "Infos client correctes (nom, raison sociale, ICE, adresse)",
    "N° devis unique (DEV-2026-NNN)",
    "Scope détaillé en tableau (prestation / qté / PU / total)",
    "Totaux HT + TVA + TTC calculés correctement",
    "Conditions de paiement claires (50/50, RIB, pénalités)",
    "Validité 30 jours + délai réalisation + garantie écrits",
    "PDF généré + signature électronique configurée ContractBook",
    "Envoi email + WhatsApp + tâche relance J+3 créée"
  ]},

  {"type":"callout","variant":"danger","title":"Escalade","text":"Si client demande modifications scope/prix non standard, ou devis > 50 000 MAD HT, ou conditions paiement non standard → WhatsApp +212 620 002 066 AVANT d'envoyer."}
]$sop$::jsonb,
    read_min = 15,
    updated_at = now()
WHERE slug = 'ng-commercial-devis';


-- ════════════════════════════════════════════════════════════════════
-- 6) ng-commercial-suivi-fidelisation
-- ════════════════════════════════════════════════════════════════════
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"Pourquoi ce SOP","text":"Un client signé = 30% du chiffre d'affaires potentiel. Les 70% restants viennent du SUIVI : upsell, parrainage, maintenance, renouvellement. Ce SOP donne le calendrier exact J+1, J+30, J+60, J+90."},
  {"type":"callout","variant":"tip","title":"Métrique clé","text":"NPS (Net Promoter Score) > 8/10 = client fidèle. < 6 = client à risque. Mesure obligatoire à J+30."},
  {"type":"callout","variant":"success","title":"Résultat attendu","text":"Client satisfait + avis Google 5 étoiles + témoignage + 1 parrainage minimum + upsell signé."},
  {"type":"callout","variant":"warning","title":"Règle d'or","text":"Le suivi commence DÈS la signature, pas après la livraison. Le client doit sentir qu'il est important."},
  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. J+1 : KIT BIENVENUE (ONBOARDING)"},
  {"type":"paragraph","text":"🎯 Objectif : créer l'effet WOW dès le lendemain de la signature. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"📍 Point de départ : acompte reçu, projet créé dans Notion."},
  {"type":"paragraph","text":"🖥️ OÙ : Email Titan + WhatsApp Business + Notion (kit bienvenue partagé)."},
  {"type":"numbered","items":[
    "Envoie un email « Bienvenue chez Next Gital » avec : présentation équipe, calendrier projet, accès Notion partagé.",
    "Programme le 1er RDV de brief dans les 48h via Calendly.",
    "Ajoute le client sur le canal Slack #client-[nom] (si abonnement maintenance).",
    "Envoie un cadeau physique optionnel : cahier Next Gital + stylo (livré à son adresse Oujda).",
    "Présente le chef de projet dédié par email avec photo + bio.",
    "Mets à jour GestiQ : statut « Onboarding J+1 fait »."
  ]},
  {"type":"template","text":"Objet : Bienvenue chez Next Gital, Dr Karim !\n\nBonjour Dr Karim,\n\nBienvenue dans la famille Next Gital ! On est ravis de démarrer votre projet.\n\nVoici ce qui vous attend :\n\n• Brief de cadrage : [date+2] à [heure] — lien Meet : [lien]\n• Votre chef de projet : [Nom] ([email]) — il sera votre interlocuteur principal\n• Votre espace Notion (suivi en temps réel) : [lien]\n• Calendrier projet : 6 semaines, livraison prévue le [date+6sem]\n\nUn petit cadeau de bienvenue est en route vers votre cabinet.\n\nÀ très vite !\n[Prénom] — Next Gital\ninfo@nextgital.com — +212 620 002 066"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Email bienvenue envoyé, RDV brief calé, chef de projet présenté, Notion partagé."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : silence radio après signature → client doute. Pb 2 : tu présentes pas le CP → client garde le commercial comme interlocuteur (mauvais pour la prod)."},
  {"type":"paragraph","text":"➡️ Étape suivante : suivre la production jusqu'à la livraison."},

  {"type":"heading2","text":"2. PENDANT LE PROJET : POINT HEBDOMADAIRE"},
  {"type":"paragraph","text":"🎯 Objectif : éviter les surprises + maintenir la confiance. ⏱️ Temps : 15 min/semaine."},
  {"type":"paragraph","text":"📍 Point de départ : pendant les 6 semaines de production."},
  {"type":"paragraph","text":"🖥️ OÙ : WhatsApp Business + Notion (mise à jour publique)."},
  {"type":"numbered","items":[
    "Chaque vendredi à 15h : envoie un récap WhatsApp au client.",
    "Mets à jour le Notion partagé : tâches faites / en cours / à venir.",
    "Préviens immédiatement si retard ou question bloquante (pas le vendredi).",
    "Demande validation des étapes clés (maquette, intégration, contenu).",
    "Note dans GestiQ : timeline + sentiment client (positif / neutre / inquiet)."
  ]},
  {"type":"template","text":"« Bonjour Dr Karim, point hebdo Next Gital de la semaine [N] :\n\n✅ Cette semaine : maquette validée + dev des 5 premières pages\n⏳ Semaine prochaine : dev 5 pages restantes + intégration Calendly\n🎯 Livraison prévue : toujours le [date+6sem]\n\nDes questions ? Sinon excellent week-end ! — [Prénom] »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"6 points hebdo envoyés sur les 6 semaines + Notion à jour."},
  {"type":"paragraph","text":"➡️ Étape suivante : livraison + premier mois post-live."},

  {"type":"heading2","text":"3. J+1 POST-LIVRAISON : VÉRIFIER QUE TOUT VA BIEN"},
  {"type":"paragraph","text":"🎯 Objectif : capter et corriger les premiers retours à chaud. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"📍 Point de départ : 24h après mise en ligne du site."},
  {"type":"paragraph","text":"🖥️ OÙ : appel téléphonique + email."},
  {"type":"numbered","items":[
    "Appelle le client : « Comment vous trouvez le site après 24h ? »",
    "Note tous les retours (positifs et négatifs).",
    "Crée immédiatement des tickets pour les corrections demandées.",
    "Rassure sur la garantie 30 jours de corrections gratuites.",
    "Envoie un email récap des points soulevés + délais correction.",
    "Programme le call NPS à J+30 dans le calendrier."
  ]},
  {"type":"template","text":"« Bonjour Dr Karim, comment vous trouvez votre nouveau site depuis hier ? Des retours, des questions ? Je note tout et je m'occupe des ajustements dans la semaine. On se reparle dans 30 jours pour faire un vrai bilan. Excellente journée ! »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Appel passé, retours notés, tickets créés, RDV J+30 calé."},
  {"type":"paragraph","text":"➡️ Étape suivante : NPS à J+30."},

  {"type":"heading2","text":"4. J+30 : NPS + DEMANDE D'AVIS GOOGLE (OBLIGATOIRE)"},
  {"type":"paragraph","text":"🎯 Objectif : mesurer la satisfaction + obtenir avis Google + témoignage. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"📍 Point de départ : 30 jours après livraison."},
  {"type":"paragraph","text":"🖥️ OÙ : appel téléphonique + email avec liens Google Reviews + Tally NPS."},
  {"type":"numbered","items":[
    "Appelle le client : « Dr Karim, ça fait 1 mois. Sur 10, vous nous mettriez quelle note ? »",
    "Note le score NPS dans GestiQ.",
    "Si 9-10 : demande IMMÉDIATEMENT un avis Google + témoignage vidéo.",
    "Si 7-8 : demande ce qu'il manque pour passer à 10.",
    "Si ≤6 : alerte rouge — propose un RDV de récup avec le manager.",
    "Envoie le lien direct Google Reviews dans le WhatsApp : « Vous prendriez 2 min pour nous laisser un avis ici ? »",
    "Mets à jour GestiQ : champ NPS + date."
  ]},
  {"type":"template","text":"« Bonjour Dr Karim, ça fait 1 mois que votre site est en ligne. Sur 10, vous nous mettriez quelle note pour notre travail et votre expérience avec Next Gital ? »\n\n[Si 9-10] : « Merci, ça me touche ! Petite faveur : vous prendriez 2 min pour nous laisser un avis Google ? Voici le lien direct : [lien] »\n\n[Si 7-8] : « Merci pour votre franchise. Qu'est-ce qu'il aurait fallu pour que vous mettiez 10 ? »\n\n[Si ≤6] : « Merci d'être honnête. Je veux qu'on règle ça. Vous êtes dispo demain pour qu'on en discute ensemble avec mon manager ? »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Score NPS noté dans GestiQ, lien avis Google envoyé si NPS ≥9, action de récup engagée si NPS ≤6."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu n'oses pas demander l'avis → ZÉRO avis Google = ZÉRO crédibilité. Demande TOUJOURS. Pb 2 : NPS faible ignoré → client perdu silencieusement."},
  {"type":"paragraph","text":"➡️ Étape suivante : upsell à J+60."},

  {"type":"heading2","text":"5. J+60 : UPSELL (MAINTENANCE / SEO / ADS)"},
  {"type":"paragraph","text":"🎯 Objectif : transformer un projet ponctuel en revenus récurrents. ⏱️ Temps : 30 min de RDV."},
  {"type":"paragraph","text":"📍 Point de départ : 60 jours après livraison, NPS bon."},
  {"type":"paragraph","text":"🖥️ OÙ : RDV téléphonique ou Google Meet (15-30 min)."},
  {"type":"numbered","items":[
    "Appelle le client : « Ça fait 2 mois, comment ça performe ? »",
    "Présente les stats observables (visites Google Analytics, demandes via le site).",
    "Propose UNE option upsell adaptée :",
    "  → Maintenance mensuelle (500 MAD/mois) : sauvegardes + sécurité + petites updates",
    "  → SEO premium (1 500 MAD/mois) : meilleur classement Google",
    "  → Google Ads / Facebook Ads (2 000 MAD/mois + budget pub) : trafic immédiat",
    "Si intéressé → envoie devis dans la foulée.",
    "Sinon → reprogramme un check J+90."
  ]},
  {"type":"template","text":"« Bonjour Dr Karim, ça fait 2 mois que le site est en ligne. J'ai regardé : vous avez fait 240 visites ce mois, et 8 demandes de RDV via le site. C'est bien, mais on peut tripler ça !\n\nJe vous propose 1 option : Google Ads géolocalisé Oujda à 2 000 MAD/mois + 1 500 MAD de budget pub. Ça vous amène 30-50 nouveaux contacts/mois garanti. Vous voulez qu'on en discute 15 min en visio ? »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Une seule option upsell proposée (pas 3 d'un coup). Stats partagées. RDV ou devis envoyé."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu proposes 5 upsells d'un coup → paralysie. Une seule à la fois. Pb 2 : tu proposes sans stats → pas crédible."},
  {"type":"paragraph","text":"➡️ Étape suivante : parrainage à J+90."},

  {"type":"heading2","text":"6. J+90 : PROGRAMME PARRAINAGE (COMMISSION 10%)"},
  {"type":"paragraph","text":"🎯 Objectif : transformer le client en commercial gratuit. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : 90 jours après livraison, client satisfait."},
  {"type":"paragraph","text":"🖥️ OÙ : email + WhatsApp + flyer PDF du programme parrainage."},
  {"type":"numbered","items":[
    "Envoie l'offre parrainage par email : « Recommandez Next Gital, gagnez 10% du contrat signé. »",
    "Donne 3 exemples concrets : « Si vous nous présentez un confrère qui signe à 20 000 MAD, vous recevez 2 000 MAD en virement. »",
    "Demande à qui il peut penser : « Vous avez un confrère ou un ami commerçant qui aurait besoin d'un site ? »",
    "S'il donne des noms → demande les contacts + permission de l'utiliser comme référent.",
    "Envoie un email d'introduction au prospect avec le client en copie.",
    "Mets à jour GestiQ : champ « Parrainages donnés » + ajoute les nouveaux prospects."
  ]},
  {"type":"template","text":"« Bonjour Dr Karim, vous êtes client Next Gital depuis 3 mois et content (NPS 9/10 !).\n\nOn lance notre programme parrainage : pour chaque confrère/ami qui signe grâce à vous, vous recevez 10% du contrat en virement.\n\nExemples :\n• Confrère qui signe à 18 000 MAD → vous touchez 1 800 MAD\n• Restaurant qui signe à 25 000 MAD → vous touchez 2 500 MAD\n\nVous avez quelqu'un en tête qui pourrait avoir besoin d'un site ? Donnez-moi simplement son nom + WhatsApp, je m'occupe du reste (avec votre accord).\n\nMerci d'avance !\n[Prénom] — Next Gital »"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Au moins 1 nom de prospect parrainé obtenu + introduction faite."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pb 1 : tu demandes pas → tu n'as jamais de parrainage. Pb 2 : la commission n'est pas versée → tu perds toute crédibilité, JAMAIS de retard."},
  {"type":"paragraph","text":"➡️ Étape suivante : suivi long terme + renouvellement."},

  {"type":"heading2","text":"7. SUIVI LONG TERME : APPEL TRIMESTRIEL + RENOUVELLEMENT"},
  {"type":"paragraph","text":"🎯 Objectif : maintenir la relation pour upsells futurs + renouvellement an 2. ⏱️ Temps : 15 min/trimestre."},
  {"type":"paragraph","text":"📍 Point de départ : tous les 3 mois après J+90."},
  {"type":"paragraph","text":"🖥️ OÙ : appel téléphonique + GestiQ."},
  {"type":"numbered","items":[
    "Calendrier automatique GestiQ : tâche « Appel trimestriel [Nom] » créée tous les 90 jours.",
    "Appel court (5-10 min) : « Comment ça va ? Le site continue à bien tourner ? »",
    "Note les nouveaux besoins (refonte partielle, nouvelle fonctionnalité, nouvel établissement).",
    "Anticipe le renouvellement maintenance avant l'échéance (J-30).",
    "Note dans GestiQ : sentiment + opportunités futures.",
    "Envoie une carte de vœux Aïd / fin d'année."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"4 appels par an minimum, GestiQ à jour, renouvellements anticipés."},

  {"type":"divider"},
  {"type":"heading","text":"Scripts / Templates"},

  {"type":"heading2","text":"Email Kit bienvenue J+1"},
  {"type":"template","text":"Objet : Bienvenue chez Next Gital, [Nom] !\n\nBonjour [Nom],\n\nBienvenue dans la famille Next Gital !\n\n• Brief de cadrage : [date+2] à [heure] — Meet : [lien]\n• Chef de projet : [Nom CP] ([email])\n• Espace Notion : [lien]\n• Livraison prévue : [date+6sem]\n\nUn cadeau de bienvenue est en route vers votre adresse.\n\nÀ très vite !\n[Prénom] — Next Gital"},

  {"type":"heading2","text":"WhatsApp point hebdo"},
  {"type":"template","text":"« Bonjour [Nom], point hebdo Next Gital semaine [N] :\n✅ Cette semaine : [actions faites]\n⏳ Semaine prochaine : [actions prévues]\n🎯 Livraison toujours prévue : [date]\nDes questions ? Excellent week-end ! — [Prénom] »"},

  {"type":"heading2","text":"Script NPS J+30"},
  {"type":"template","text":"« Bonjour [Nom], ça fait 1 mois que votre site est en ligne. Sur 10, vous nous mettriez quelle note pour notre travail et votre expérience avec Next Gital ? »\n\n[9-10] → « Merci ! Vous prendriez 2 min pour un avis Google ? [lien] »\n[7-8] → « Qu'est-ce qu'il aurait fallu pour mettre 10 ? »\n[≤6] → « Je veux qu'on règle ça. Dispo demain pour en discuter avec mon manager ? »"},

  {"type":"heading2","text":"Pitch upsell J+60"},
  {"type":"template","text":"« Bonjour [Nom], 2 mois après lancement : vous avez fait [X] visites et [Y] demandes via le site. On peut tripler ça avec [option upsell] à [prix]/mois. Vous voulez qu'on en discute 15 min en visio ? »"},

  {"type":"heading2","text":"Email parrainage J+90"},
  {"type":"template","text":"Objet : Programme parrainage Next Gital — Gagnez 10% par client\n\nBonjour [Nom],\n\nClient Next Gital depuis 3 mois, vous êtes satisfait (NPS [score]/10 !).\n\nNotre programme parrainage : 10% du contrat reversé pour chaque ami/confrère qui signe.\n\nExemples :\n• 18 000 MAD signés → vous touchez 1 800 MAD\n• 25 000 MAD signés → vous touchez 2 500 MAD\n\nVous avez quelqu'un en tête ? Donnez-moi son nom + WhatsApp, je m'occupe du reste.\n\nMerci !\n[Prénom] — Next Gital"},

  {"type":"divider"},
  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "J+1 : Email bienvenue + chef de projet présenté + RDV brief calé",
    "Pendant projet : 6 points hebdo WhatsApp + Notion à jour",
    "J+1 post-livraison : appel retours + tickets corrections créés",
    "J+30 : NPS mesuré + avis Google demandé (si ≥9) + recovery (si ≤6)",
    "J+60 : RDV upsell avec stats à l'appui + UNE option proposée",
    "J+90 : programme parrainage envoyé + au moins 1 nom récolté",
    "Trimestriel : appel court + GestiQ à jour + carte vœux",
    "Tout est tracé dans GestiQ (NPS, upsells, parrainages, sentiment)"
  ]},

  {"type":"callout","variant":"danger","title":"Escalade","text":"Si NPS ≤6, ou client menace de partir, ou parrainage non payé après 7 jours → WhatsApp +212 620 002 066 IMMÉDIATEMENT."}
]$sop$::jsonb,
    read_min = 16,
    updated_at = now()
WHERE slug = 'ng-commercial-suivi-fidelisation';


COMMIT;
