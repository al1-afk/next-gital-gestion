-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 035 : Seed des 6 SOPs « Commercial »
--  Date : 2026-05-17
--
--  Catégorie : commercial · Auteur : Next Gital · Idempotent
--  Périmètre : Réunion de vente · Objections · Closing · Négociation
--              Devis · Suivi & Fidélisation
--  Insère pour TOUS les tenants existants.
--
--  Conformité ARCHITECTURE_TENANT.md :
--    - tenant_id NOT NULL, contrôle d'existence par (tenant_id, slug)
--    - RLS déjà actif sur public.sops (migration 025)
--    - Pas de modification de la structure existante
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ── ng-commercial-reunion-vente (commercial) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-commercial-reunion-vente',
  'Réunion de vente — préparer et conduire pour signer',
  'Préparation 20 min, règle 70/30, 6 questions de découverte, présentation Next Gital et clôture avec prochaine étape claire.',
  'commercial',
  '["Vente","Réunion","Closing","Commercial","Script"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Avant chaque réunion avec un prospect."},
    {"type":"callout","variant":"info","title":"Canal","text":"Google Meet · Bureau Next Gital · Terrain."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Transformer 40%+ des réunions en devis envoyé · 25%+ en contrat signé."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"La réunion de vente n'est pas une présentation — c'est une conversation. Celui qui parle le moins vend le plus. Règle des 70/30 : le prospect parle 70% du temps, vous 30%. Poser des questions, écouter, puis proposer la solution."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Préparer la réunion — 20 min avant"},
    {"type":"paragraph","text":"Ouvrir GestiQ → fiche prospect. Relire : secteur, problème identifié, budget estimé, historique des contacts."},
    {"type":"paragraph","text":"Faire une recherche rapide sur l'entreprise (site web, réseaux, Google Maps — avis, photos). Préparer :"},
    {"type":"list","items":[
      "1 exemple de projet similaire du portfolio Next Gital à montrer",
      "3 questions de profondeur à poser",
      "La fourchette de prix adaptée au budget estimé",
      "Ouvrir **nextgital.tech** sur le téléphone — prêt à montrer"
    ]},
    {"type":"list","items":["Outil : **GestiQ + Google + nextgital.tech**","Temps : ~20 min","Statut : requis"]},

    {"type":"heading2","text":"2. Les 5 premières minutes — créer la confiance"},
    {"type":"paragraph","text":"Dès le début : sourire, regard direct, poignée de main ferme si en personne. Ne PAS parler de vente pendant les 5 premières minutes."},
    {"type":"paragraph","text":"Briser la glace : « Comment s'est passée votre semaine ? » ou « J'ai vu que vous avez ouvert [X] — félicitations ! »"},
    {"type":"paragraph","text":"Puis : « Pour qu'on se parle de la meilleure façon possible, vous pouvez me parler de votre activité en 2-3 minutes ? »"},
    {"type":"callout","variant":"tip","title":"Pendant qu'il parle","text":"Noter, hocher la tête, ne pas interrompre."},
    {"type":"list","items":["Outil : **Présence et écoute**","Temps : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"3. Les 6 questions de découverte — comprendre la vraie douleur"},
    {"type":"paragraph","text":"Ces 6 questions dans cet ordre, une à la fois :"},
    {"type":"numbered","items":[
      "« Comment vos clients vous trouvent-ils aujourd'hui ? » (diagnostic de la situation actuelle)",
      "« Qu'est-ce qui vous manque le plus en ce moment pour attirer plus de clients ? » (identifier la douleur)",
      "« Si vous aviez un site web professionnel demain matin, qu'est-ce que ça changerait concrètement ? » (faire visualiser le résultat)",
      "« Avez-vous déjà travaillé avec une agence web avant ? » Si oui : « Qu'est-ce qui n'a pas fonctionné ? » (comprendre les peurs)",
      "« Quel est votre objectif principal sur les 6 prochains mois ? » (aligner sur les ambitions)",
      "« Y a-t-il quelque chose qui pourrait vous empêcher d'avancer sur ce projet ? » (détecter les blocages en avance)"
    ]},
    {"type":"list","items":["Outil : **Écoute active + prise de notes**","Temps : ~10-15 min","Statut : requis"]},

    {"type":"heading2","text":"4. Présenter Next Gital — après avoir écouté"},
    {"type":"paragraph","text":"Uniquement après avoir posé les questions. Commencer par : « Sur la base de ce que vous m'avez dit... » — puis reformuler le problème du prospect avec SES propres mots."},
    {"type":"paragraph","text":"Ensuite présenter Next Gital en 3 minutes max :"},
    {"type":"list","items":[
      "Qui on est : 6 ans à Oujda, 100+ projets, 4.9★",
      "Ce qu'on fait de différent : garantie 0 retard, bureau réel, suivi complet",
      "Un projet similaire (montrer sur le téléphone)"
    ]},
    {"type":"callout","variant":"warning","title":"Ne jamais","text":"Lire une présentation — parler naturellement."},
    {"type":"list","items":["Outil : **nextgital.tech + portfolio**","Temps : ~5-7 min","Statut : requis"]},

    {"type":"heading2","text":"5. Proposer la solution et tester l'intérêt"},
    {"type":"paragraph","text":"Après la présentation : « Sur la base de ce qu'on vient de discuter, je pense que la meilleure solution pour vous c'est [SOLUTION PRÉCISE] — qu'est-ce que vous en pensez ? »"},
    {"type":"paragraph","text":"Cette question ouvre la porte aux objections ou à la confirmation."},
    {"type":"list","items":[
      "Si **positif** : « Parfait. Je vous prépare un devis personnalisé et je vous l'envoie dans 48h — est-ce que l'email [EMAIL] est correct ? »",
      "Si **hésitant** : passer à la gestion des objections (SOP « Gérer les objections »)"
    ]},
    {"type":"list","items":["Outil : **Écoute + GestiQ**","Temps : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"6. Conclure la réunion — toujours avec une prochaine étape"},
    {"type":"paragraph","text":"Ne jamais terminer une réunion sans une prochaine étape claire."},
    {"type":"list","items":[
      "**Si devis à envoyer** : « Je vous envoie le devis dans 48h. On se rappelle [JOUR] à [HEURE] pour en discuter ? »",
      "**Si pas convaincu** : « Qu'est-ce qui vous manque comme information pour pouvoir décider ? »",
      "**Si refus** : « Je comprends tout à fait. Est-ce que je peux vous rappeler dans 3 mois si jamais la situation évolue ? »"
    ]},
    {"type":"callout","variant":"danger","title":"Immédiatement après","text":"Mettre à jour GestiQ avec : statut, prochaine étape, date, notes."},
    {"type":"list","items":["Outil : **GestiQ + Calendly**","Temps : ~3 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Message de confirmation réunion — J-1 (WhatsApp)"},
    {"type":"template","text":"Bonjour [Prénom] 👋\n\nJe vous rappelle notre rendez-vous de demain :\n📅 [JOUR] à [HEURE]\n📍 [LIEU : bureau Next Gital / votre bureau / Google Meet]\n\n[Si Meet → ] Voici le lien : [URL Google Meet]\n\nN'hésitez pas si vous avez des questions avant.\nÀ demain ! 🙏"},

    {"type":"heading","text":"Message après réunion — récapitulatif et prochaine étape"},
    {"type":"template","text":"Bonjour [Prénom],\n\nMerci pour notre échange de ce matin — c'était très enrichissant.\n\nPour résumer ce qu'on a discuté :\n• Votre besoin principal : [BESOIN EN 1 PHRASE]\n• Notre solution proposée : [SOLUTION EN 1 PHRASE]\n• Prochaine étape : je vous envoie le devis personnalisé avant [DATE]\n\nN'hésitez pas si vous avez des questions d'ici là.\n\nBonne journée ! 🙏\n[Votre prénom] · Next Gital · +212 620 002 066"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Fiche prospect GestiQ relue — 20 min avant la réunion",
      "Projet similaire du portfolio prêt à montrer",
      "Règle 70/30 respectée — prospect a parlé le plus",
      "6 questions de découverte posées dans l'ordre",
      "Solution proposée après écoute — pas avant",
      "Prochaine étape définie et confirmée (devis, rappel, date)",
      "GestiQ mis à jour immédiatement après la réunion"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-commercial-reunion-vente');


-- ── ng-commercial-objections (commercial) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-commercial-objections',
  'Gérer les objections — les 8 réponses qui font signer',
  'Trop cher · Je réfléchis · Cousin moins cher · Pas le temps · Voir exemples · Bouche à oreille · 2ème décideur · Concurrent moins cher.',
  'commercial',
  '["Objections","Commercial","Réponses","Vente","Closing"]'::jsonb,
  'Next Gital',
  6,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Usage quotidien — pendant et après les réunions."},
    {"type":"callout","variant":"info","title":"Canal","text":"Réunion · WhatsApp · Téléphone."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Transformer 50%+ des objections en signature."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Une objection n'est pas un refus — c'est une demande d'information. Quelqu'un qui objecte est encore intéressé. Quelqu'un qui refuse ne dit rien. Règle : accueillir l'objection sans se défendre, comprendre la vraie raison, puis répondre avec une preuve ou une question."},

    {"type":"heading","text":"Les 8 objections les plus fréquentes"},

    {"type":"heading2","text":"OBJECTION 1 — « C'est trop cher »"},
    {"type":"paragraph","text":"Ne JAMAIS baisser le prix immédiatement. Répondre :"},
    {"type":"quote","text":"« Je comprends. Permettez-moi de vous poser une question : par rapport à quoi vous semble-t-il cher ? »"},
    {"type":"paragraph","text":"Écouter la réponse :"},
    {"type":"list","items":[
      "**Si par rapport à un concurrent** : « Il est important de comparer ce qui est comparable. Notre offre inclut logo, hébergement 1 an, domaine, email pro, SSL, support 1 an et garantie 0 retard. Est-ce que l'offre que vous avez vue inclut tout ça ? »",
      "**Si par rapport au budget** : « On a aussi une solution à [PRIX INFÉRIEUR] qui comprend [ÉLÉMENTS DE BASE]. Est-ce que ça pourrait correspondre à vos priorités du moment ? »"
    ]},
    {"type":"list","items":["Outil : **Écoute + Question de clarification**","Temps : ~3 min","Statut : requis"]},

    {"type":"heading2","text":"OBJECTION 2 — « Je dois réfléchir »"},
    {"type":"paragraph","text":"C'est souvent une façon polie de dire non sans expliquer pourquoi. Répondre :"},
    {"type":"quote","text":"« Bien sûr, c'est une décision importante. Pour que votre réflexion soit bien éclairée — qu'est-ce qui vous fait hésiter exactement ? »"},
    {"type":"paragraph","text":"Attendre la réponse. Selon ce qui est dit, adresser la vraie objection cachée."},
    {"type":"paragraph","text":"Si vraiment besoin de temps : « Pas de problème. Je vous propose qu'on se rappelle [JOUR + 2] — ça vous laisse le temps de réfléchir et moi je reste disponible pour répondre à vos questions. »"},
    {"type":"callout","variant":"warning","title":"Important","text":"Fixer une date précise — ne JAMAIS laisser « je vous rappelle »."},
    {"type":"list","items":["Outil : **Question + Calendly**","Temps : ~3 min","Statut : requis"]},

    {"type":"heading2","text":"OBJECTION 3 — « J'ai un ami/cousin qui fait ça moins cher »"},
    {"type":"paragraph","text":"Ne pas dénigrer l'ami ou le cousin. Répondre :"},
    {"type":"quote","text":"« C'est une chance d'avoir quelqu'un dans l'entourage. Permettez-moi juste de partager notre différence : avec Next Gital, vous avez un contrat signé, une garantie écrite de résultat, un bureau physique à Oujda, et 6 ans d'expérience avec 100+ entreprises. Si le projet ne se passe pas bien avec un proche, ça peut aussi compliquer la relation. C'est à vous de peser les deux options. »"},
    {"type":"callout","variant":"tip","title":"Après la réponse","text":"Ne plus insister — laisser le prospect réfléchir."},
    {"type":"list","items":["Outil : **Réponse calme et posée**","Temps : ~2 min","Statut : requis"]},

    {"type":"heading2","text":"OBJECTION 4 — « Je n'ai pas le temps de m'en occuper »"},
    {"type":"paragraph","text":"C'est une opportunité — montrer que Next Gital gère tout."},
    {"type":"quote","text":"« C'est exactement pour ça qu'on existe. Votre rôle se limite à nous donner votre logo, vos photos et valider la maquette — 2-3 heures de votre temps maximum. Tout le reste : on s'en occupe. Et notre Chef de projet vous tient informé par WhatsApp chaque semaine sans que vous ayez à demander. Ça vous parle comme ça ? »"},
    {"type":"list","items":["Outil : **Réassurance + Exemple**","Temps : ~2 min","Statut : requis"]},

    {"type":"heading2","text":"OBJECTION 5 — « Je veux voir des exemples de votre travail d'abord »"},
    {"type":"paragraph","text":"Ce n'est pas une vraie objection — c'est une bonne demande. Répondre immédiatement : « Avec plaisir ! »"},
    {"type":"list","items":[
      "Ouvrir **nextgital.tech** → montrer les réalisations",
      "Choisir **2-3 projets similaires** au secteur du prospect",
      "Pour chaque projet : expliquer le problème, la solution, et le résultat",
      "Puis demander : « Est-ce que vous aimez ce style ou vous préférez quelque chose de différent ? »"
    ]},
    {"type":"callout","variant":"success","title":"Astuce","text":"Transformer ça en discussion créative."},
    {"type":"list","items":["Outil : **nextgital.tech + portfolio**","Temps : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"OBJECTION 6 — « J'ai pas besoin d'un site, mes clients me trouvent par le bouche à oreille »"},
    {"type":"paragraph","text":"Répondre avec une question :"},
    {"type":"quote","text":"« C'est super — ça veut dire que vous faites un excellent travail. Et si je vous disais que chaque nouveau client qui entend parler de vous via bouche à oreille va sur Google pour vérifier avant de vous appeler — et là il ne vous trouve pas ? Combien de clients estimez-vous perdre comme ça chaque mois ? »"},
    {"type":"paragraph","text":"Laisser la question s'installer. Puis :"},
    {"type":"quote","text":"« Un site ne remplace pas le bouche à oreille — il le renforce. Il transforme une recommandation en décision. »"},
    {"type":"list","items":["Outil : **Question rhétorique**","Temps : ~3 min","Statut : requis"]},

    {"type":"heading2","text":"OBJECTION 7 — « Je vais en parler à mon associé / ma femme / mon père »"},
    {"type":"paragraph","text":"Identifier le vrai décideur. Répondre :"},
    {"type":"quote","text":"« Bien sûr — c'est une décision d'équipe. Pour faciliter votre discussion, est-ce que vous pouvez me dire ce qui sera le point le plus important pour lui/elle ? »"},
    {"type":"paragraph","text":"Comprendre ce qui préoccupe l'autre décideur. Puis :"},
    {"type":"quote","text":"« Est-ce qu'il serait possible de l'inclure dans notre prochain échange, même 15 minutes ? Comme ça je peux répondre directement à ses questions. »"},
    {"type":"paragraph","text":"Si impossible : préparer un document récapitulatif simple que le prospect peut montrer."},
    {"type":"list","items":["Outil : **Question + Document récap**","Temps : ~3 min","Statut : requis"]},

    {"type":"heading2","text":"OBJECTION 8 — « Vous avez un concurrent à X MAD moins cher »"},
    {"type":"paragraph","text":"Répondre calmement :"},
    {"type":"quote","text":"« Je connais [Nom du concurrent]. On travaille différemment — nous on ne vend pas un template, on crée un site unique pour votre activité spécifique. Mais je comprends que le budget compte. Est-ce que la différence de budget est ce qui vous bloque vraiment, ou il y a autre chose ? »"},
    {"type":"callout","variant":"tip","title":"Souvent","text":"Il y a une autre raison cachée. Adresser la vraie raison, pas le prix."},
    {"type":"list","items":["Outil : **Écoute + Question**","Temps : ~3 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Message WhatsApp après objection « je réfléchis » — J+2"},
    {"type":"template","text":"Bonjour [Prénom] 👋\n\nComme convenu, je reviens vers vous.\n\nAvez-vous eu le temps de réfléchir ? Y a-t-il des questions ou des points à éclaircir ?\n\nJe reste disponible pour un rapide appel de 10 minutes si ça peut aider à décider. 🙏\n\nNext Gital · +212 620 002 066"},

    {"type":"heading","text":"Document récapitulatif — pour le 2ème décideur"},
    {"type":"template","text":"RÉSUMÉ PROJET — [NOM CLIENT]\nPréparé par Next Gital · Oujda\n\n━━ VOTRE PROJET ━━\nType : [Site vitrine / E-commerce / ...]\nObjectif : [OBJECTIF EN 1 PHRASE]\nDélai de livraison : [X jours]\n\n━━ CE QU'ON LIVRE ━━\n✅ Design 100% personnalisé\n✅ [X] pages professionnelles\n✅ Logo + hébergement + domaine + email pro + SSL\n✅ Responsive mobile\n✅ SEO intégré\n✅ Support 1 an\n\n━━ NOS GARANTIES ÉCRITES ━━\n🛡️ Satisfaction garantie (on refait si non conforme)\n⏰ 0 retard garanti (6 ans d'expérience)\n🔧 Support sous 24h toute l'année\n\n━━ INVESTISSEMENT ━━\nMontant total : [X] MAD\nAcompte démarrage (50%) : [X] MAD\nModes : Virement · CIB · Cash · Wafacash\n\n━━ NEXT GITAL EN CHIFFRES ━━\n📊 100+ projets livrés · 4.9★ Google · 6 ans · Bureau Oujda\n\nQuestions : +212 620 002 066 · info@nextgital.com"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Objection accueillie sans défense ni justification immédiate",
      "Question de clarification posée avant de répondre",
      "Vraie raison derrière l'objection identifiée",
      "Réponse adaptée donnée avec preuve ou exemple",
      "Prochaine étape fixée après la réponse",
      "GestiQ mis à jour avec l'objection et la réponse"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-commercial-objections');


-- ── ng-commercial-closing (commercial) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-commercial-closing',
  'Closing — les 6 techniques pour faire signer',
  'Résumé-accord, urgence légitime, alternative, preuve sociale, silence, suivi téléphonique après devis — sans forcer ni supplier.',
  'commercial',
  '["Closing","Signature","Technique","Commercial","Contrat"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"En fin de réunion ou après envoi du devis."},
    {"type":"callout","variant":"info","title":"Canal","text":"Réunion · WhatsApp · Téléphone."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Fermer la vente de façon naturelle sans forcer ni supplier."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Le closing ne commence pas à la fin de la réunion — il commence dès le début. Chaque question posée, chaque preuve donnée, chaque objection traitée rapproche du closing. Quand tout est bien fait, le closing est naturel. Ne JAMAIS forcer, ne JAMAIS supplier — ça détruit la crédibilité."},

    {"type":"heading","text":"Les 6 techniques de closing"},

    {"type":"heading2","text":"TECHNIQUE 1 — Le résumé-accord (la plus simple et la plus efficace)"},
    {"type":"paragraph","text":"En fin de réunion, après avoir traité toutes les questions : résumer en 3 phrases ce dont le prospect a besoin, ce que Next Gital propose, et ce que ça va changer pour lui."},
    {"type":"paragraph","text":"Puis demander :"},
    {"type":"quote","text":"« Est-ce que ça vous semble correspondre à ce que vous cherchez ? »"},
    {"type":"paragraph","text":"Si **OUI** : « Parfait — alors la prochaine étape c'est que je vous prépare le devis. Je vous l'envoie demain avant midi. On se rappelle [JOUR] pour en discuter ? »"},
    {"type":"callout","variant":"warning","title":"Important","text":"Prendre la date tout de suite — ne JAMAIS laisser « je vous contacterai »."},
    {"type":"list","items":["Outil : **Écoute + Question directe**","Temps : ~3 min","Statut : requis"]},

    {"type":"heading2","text":"TECHNIQUE 2 — L'urgence légitime (sans pression artificielle)"},
    {"type":"paragraph","text":"Si le prospect hésite depuis plusieurs jours : créer une vraie urgence sans mentir. Options légitimes chez Next Gital :"},
    {"type":"list","items":[
      "« Notre agenda se remplit rapidement — on a 3 projets qui démarrent ce mois. Si vous souhaitez qu'on puisse commencer le [DATE SOUHAITÉE], il faudrait qu'on confirme avant le [DATE LIMITE]. »",
      "« Le prix actuel est valable jusqu'au [DATE D'EXPIRATION DU DEVIS]. Après, je devrai peut-être ajuster selon notre charge. »"
    ]},
    {"type":"callout","variant":"danger","title":"Règle","text":"Ces urgences sont réelles — utiliser UNIQUEMENT si elles sont vraies."},
    {"type":"list","items":["Outil : **Calendrier GestiQ**","Temps : ~1 min","Statut : requis"]},

    {"type":"heading2","text":"TECHNIQUE 3 — L'alternative (pas « si » mais « lequel »)"},
    {"type":"paragraph","text":"Au lieu de demander « Vous voulez qu'on travaille ensemble ? » (oui ou non) → proposer une alternative entre deux options positives."},
    {"type":"paragraph","text":"Exemples :"},
    {"type":"list","items":[
      "« On peut démarrer la semaine prochaine ou plutôt dans 2 semaines — qu'est-ce qui vous convient le mieux ? »",
      "« Vous préférez commencer par le site vitrine seul, ou inclure directement la gestion des publicités ? »"
    ]},
    {"type":"callout","variant":"tip","title":"Pourquoi ça marche","text":"Cette technique amène le prospect à choisir COMMENT travailler ensemble, pas SI."},
    {"type":"list","items":["Outil : **Question alternative**","Temps : ~1 min","Statut : requis"]},

    {"type":"heading2","text":"TECHNIQUE 4 — La preuve sociale de dernière minute"},
    {"type":"paragraph","text":"Si le prospect hésite encore après toutes les objections traitées : partager une preuve sociale puissante."},
    {"type":"list","items":[
      "« Je vais vous montrer quelque chose rapidement. » → Ouvrir **Google Maps** → montrer les avis 4.9★",
      "Montrer un témoignage WhatsApp d'un client satisfait du même secteur",
      "« On a aidé [NOM D'UN CLIENT CONNU DANS SON SECTEUR] — je peux vous mettre en contact avec lui si vous voulez avoir son retour direct. »"
    ]},
    {"type":"callout","variant":"success","title":"ROI","text":"Un prospect satisfait qui parle vaut 10 présentations."},
    {"type":"list","items":["Outil : **Google Maps + portfolio**","Temps : ~2 min","Statut : requis"]},

    {"type":"heading2","text":"TECHNIQUE 5 — Le silence (la plus puissante et la plus difficile)"},
    {"type":"paragraph","text":"Après une question de closing ou une réponse à une objection : se taire. Complètement. Ne PAS remplir le silence."},
    {"type":"paragraph","text":"La personne qui parle en premier après une question de closing perd la position. Le prospect est en train de réfléchir — le laisser réfléchir."},
    {"type":"list","items":[
      "Si le silence dure 30 secondes : normal",
      "Si il dure 1 minute : toujours attendre",
      "Souvent le prospect dit : « Bon... comment on fait ? » — et c'est le closing naturel"
    ]},
    {"type":"callout","variant":"warning","title":"Pratiquer","text":"Cette technique est contre-naturelle — il faut s'entraîner pour la maîtriser."},
    {"type":"list","items":["Outil : **Patience**","Temps : variable","Statut : requis"]},

    {"type":"heading2","text":"TECHNIQUE 6 — Le closing après envoi du devis"},
    {"type":"paragraph","text":"**48h après envoi du devis sans réponse** : appeler (pas WhatsApp — appeler)."},
    {"type":"quote","text":"« Bonjour [Prénom], je vous appelais pour m'assurer que le devis est clair et voir si vous avez des questions. »"},
    {"type":"paragraph","text":"Écouter. Si intéressé mais hésite : « Qu'est-ce qui vous manque pour prendre la décision ? »"},
    {"type":"paragraph","text":"Si besoin de temps : fixer une date précise."},
    {"type":"callout","variant":"danger","title":"Règle","text":"Maximum 2 appels de suivi sur un devis. Après ça → fermer dans GestiQ et passer au suivant."},
    {"type":"list","items":["Outil : **Téléphone + GestiQ**","Temps : ~5-10 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Appel de suivi devis — script téléphone"},
    {"type":"template","text":"SCRIPT APPEL SUIVI DEVIS :\n\n« Bonjour [Prénom], c'est [Votre prénom] de Next Gital.\nJe vous appelais concernant le devis que je vous ai envoyé [JOUR].\nVous avez eu le temps de le regarder ? »\n\n→ Si oui et intéressé : « Super — est-ce qu'il y a des points à clarifier ou ajuster ? »\n\n→ Si pas regardé : « Pas de problème. Quand pensez-vous pouvoir y jeter un œil ? Je peux rappeler [JOUR] à [HEURE] si ça vous convient. »\n\n→ Si hésitant : « Qu'est-ce qui vous fait hésiter exactement ? » (écouter sans interrompre)\n\n→ Si refus : « Je comprends tout à fait. Est-ce que je peux vous rappeler dans 3 mois — les besoins évoluent parfois. Bonne journée ! »"},

    {"type":"heading","text":"Message WhatsApp — relance devis J+3 (si pas de réponse à l'appel)"},
    {"type":"template","text":"Bonjour [Prénom],\n\nJ'ai essayé de vous joindre — j'espère que tout va bien.\n\nLe devis pour [NOM PROJET] est valable jusqu'au [DATE EXPIRATION].\n\nSi vous avez des questions ou souhaitez ajuster quelque chose, je suis disponible.\n\nBonne journée 🙏\n+212 620 002 066"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Technique de closing choisie selon la situation du prospect",
      "Question de closing posée clairement — puis silence gardé",
      "Urgence légitime utilisée uniquement si vraie",
      "Preuve sociale montrée si le prospect hésite encore",
      "Appel de suivi effectué 48h après le devis (pas WhatsApp)",
      "Résultat noté dans GestiQ — signé / refus / en attente + date"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-commercial-closing');


-- ── ng-commercial-negociation (commercial) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-commercial-negociation',
  'Négocier sans baisser le prix — protéger la valeur Next Gital',
  'Règle give & get, plan de paiement étalé, réduction du scope ou valeur ajoutée — et quand dire non.',
  'commercial',
  '["Négociation","Prix","Valeur","Commercial","Discount"]'::jsonb,
  'Next Gital',
  4,
  false,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Quand le prospect demande une réduction ou un ajustement de prix."},
    {"type":"callout","variant":"info","title":"Canal","text":"Réunion · WhatsApp · Téléphone."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Signer sans baisser le prix · Si concession nécessaire → toujours en échange de quelque chose."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Baisser le prix sans raison envoie 2 messages dangereux : (1) que le premier prix était gonflé (perte de confiance) et (2) que Next Gital cède facilement (invite à négocier encore plus). Règle : on ne baisse JAMAIS le prix — on ajuste le scope ou on offre de la valeur ajoutée."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Répondre à « Vous pouvez faire un effort sur le prix ? »"},
    {"type":"paragraph","text":"Ne pas répondre immédiatement oui ou non. Répondre :"},
    {"type":"quote","text":"« Notre prix reflète exactement la qualité et le service qu'on délivre — et on n'a jamais eu de client insatisfait sur 6 ans. Mais dites-moi : c'est une question de budget total, ou c'est par rapport à ce qui est inclus dans l'offre ? »"},
    {"type":"paragraph","text":"Selon la réponse :"},
    {"type":"list","items":[
      "**Si budget total** → proposer un plan de paiement étalé",
      "**Si inclus** → proposer de retirer des éléments pour baisser le prix (JAMAIS baisser sans retirer quelque chose)"
    ]},
    {"type":"list","items":["Outil : **Question de clarification**","Temps : ~3 min","Statut : requis"]},

    {"type":"heading2","text":"2. La règle du « give & get » — si on donne, on reçoit"},
    {"type":"paragraph","text":"Si concession nécessaire, toujours en échange d'un avantage pour Next Gital. Exemples :"},
    {"type":"list","items":[
      "« Si vous pouvez payer 70% à l'avance au lieu de 50%, je peux vous offrir [ÉLÉMENT ADDITIONNEL]. »",
      "« Si vous nous signez avant vendredi, je peux inclure [BONUS] sans supplément. »",
      "« Si vous nous donnez l'autorisation de montrer votre site en portfolio, je peux vous faire -[X]%. »"
    ]},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Ne JAMAIS donner sans recevoir — même symboliquement."},
    {"type":"list","items":["Outil : **Négociation gagnant-gagnant**","Temps : ~2 min","Statut : requis"]},

    {"type":"heading2","text":"3. Option 1 — Proposer un plan de paiement étalé"},
    {"type":"paragraph","text":"Si le problème est le cash disponible, pas la valeur :"},
    {"type":"quote","text":"« Je comprends que sortir [X] MAD d'un coup c'est conséquent. Je peux ajuster le plan de paiement : 40% maintenant, 30% à la maquette, 30% à la livraison — ça vous convient ? »"},
    {"type":"callout","variant":"success","title":"Avantage","text":"Le total ne change pas — juste l'étalement. Cela aide beaucoup les petites entreprises sans toucher à la valeur perçue."},
    {"type":"list","items":["Outil : **GestiQ Finance**","Temps : ~2 min","Statut : requis"]},

    {"type":"heading2","text":"4. Option 2 — Réduire le scope plutôt que le prix"},
    {"type":"paragraph","text":"Si le prospect veut vraiment moins cher :"},
    {"type":"quote","text":"« D'accord — voyons comment adapter l'offre à votre budget. On peut démarrer avec 5 pages au lieu de 10, et on peut ajouter les autres pages dans 3 mois si vous êtes satisfait. Ça fait passer le projet à [PRIX INFÉRIEUR]. Ça vous convient ? »"},
    {"type":"callout","variant":"tip","title":"Stratégie long terme","text":"Partir sur un projet plus petit = client satisfait qui revient pour plus = meilleur revenus sur le long terme."},
    {"type":"list","items":["Outil : **GestiQ Devis**","Temps : ~3 min","Statut : requis"]},

    {"type":"heading2","text":"5. Option 3 — Offrir de la valeur au lieu de baisser le prix"},
    {"type":"paragraph","text":"Au lieu de baisser de 500 MAD : offrir quelque chose qui coûte peu à Next Gital mais a une valeur perçue élevée."},
    {"type":"list","items":[
      "**1 mois de maintenance gratuit** (valeur 500 MAD — coûte peu si le site est bien fait)",
      "**Formation de 30 min** à la gestion du site (coût : 30 min de votre temps)",
      "**1 post mensuel gratuit pendant 3 mois** (valeur 300 MAD)"
    ]},
    {"type":"callout","variant":"success","title":"Gagnant-gagnant","text":"Le prospect reçoit plus de valeur et Next Gital ne perd pas de marge."},
    {"type":"list","items":["Outil : **Créativité commerciale**","Temps : ~2 min","Statut : requis"]},

    {"type":"heading2","text":"6. Quand dire non à la négociation"},
    {"type":"paragraph","text":"Si le prospect demande une réduction de plus de 20% sans justification valable : tenir bon."},
    {"type":"quote","text":"« Je comprends votre souhait, mais à ce prix-là je ne peux pas garantir la même qualité — et chez Next Gital on ne fait pas les choses à moitié. Je préfère être honnête avec vous plutôt que de vous promettre quelque chose qu'on ne peut pas tenir. »"},
    {"type":"callout","variant":"warning","title":"Détecter les difficultés","text":"Un client qui vous respecte accepte ça. Un client qui insiste à ce stade sera difficile tout au long du projet."},
    {"type":"list","items":["Outil : **Fermeté respectueuse**","Temps : ~2 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Réponse à une demande de réduction — WhatsApp"},
    {"type":"template","text":"Bonjour [Prénom],\n\nJe comprends votre souhait d'optimiser le budget.\n\nPlutôt que de baisser la qualité de ce qu'on vous livre, voici ce que je peux proposer :\n\nOption A — Même projet, paiement étalé :\n40% maintenant + 30% à la maquette + 30% à la livraison\nTotal identique : [X] MAD\n\nOption B — Projet ajusté au budget :\n[DESCRIPTION SCOPE RÉDUIT] pour [PRIX INFÉRIEUR] MAD\nAvec possibilité d'évoluer dans 3 mois\n\nOption C — Même prix avec bonus inclus :\n[PRIX IDENTIQUE] MAD + 1 mois de maintenance offert (valeur 500 MAD)\n\nLaquelle vous convient le mieux ? 🙏"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Question de clarification posée avant toute réponse sur le prix",
      "Prix jamais baissé sans contrepartie (give & get respecté)",
      "Plan de paiement étalé proposé si problème de cash",
      "Scope réduit proposé si vraie contrainte budget",
      "Valeur ajoutée offerte plutôt que réduction directe",
      "Résultat noté dans GestiQ"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-commercial-negociation');


-- ── ng-commercial-devis (commercial) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-commercial-devis',
  'Créer le devis parfait — structure en 7 sections qui fait signer',
  'Compréhension + solution + scope inclus/exclu + prix + planning + garanties + CTA. Envoi en 48h avec taux de conversion ≥ 40%.',
  'commercial',
  '["Devis","PDF","Commercial","GestiQ","Proposition"]'::jsonb,
  'Next Gital',
  6,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Dans les 48h après la réunion de découverte — sans exception."},
    {"type":"callout","variant":"info","title":"Canal","text":"GestiQ PDF · WhatsApp · Email."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Devis envoyé en 48h · Taux de conversion ≥ 40%."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Un devis qui parle du client avant de parler du prix convertit 2x mieux qu'un devis qui commence par la liste des services. La structure est aussi importante que le contenu. Toujours commencer par « Vous nous avez dit que... » — le client se sent compris."},

    {"type":"heading","text":"Les 7 sections du devis Next Gital"},

    {"type":"heading2","text":"1. Section « Ce que nous avons compris de votre projet » (COMMENCER ICI)"},
    {"type":"paragraph","text":"Première section du devis — AVANT tout prix ou liste de services."},
    {"type":"paragraph","text":"Contenu : reformuler avec les mots du client : son activité, son problème actuel, son objectif, sa cible."},
    {"type":"paragraph","text":"**Exemple :** « Suite à notre échange du [DATE], nous avons compris que [NOM ENTREPRISE] est un [SECTEUR] basé à [VILLE]. Votre défi principal est [PROBLÈME EN 1 PHRASE]. Votre objectif avec ce projet est [OBJECTIF EN 1 PHRASE]. »"},
    {"type":"callout","variant":"success","title":"Pourquoi","text":"Cette section montre que vous avez écouté — et ça rassure."},
    {"type":"list","items":["Outil : **GestiQ Devis**","Temps : ~10 min","Statut : requis"]},

    {"type":"heading2","text":"2. Section « La solution proposée »"},
    {"type":"paragraph","text":"Expliquer **POURQUOI** cette solution pour **CE** client. Pas une liste générique — une solution personnalisée."},
    {"type":"paragraph","text":"**Exemple :** « Pour répondre à vos besoins spécifiques, nous proposons de créer un site vitrine professionnel optimisé pour les recherches locales à [VILLE]. Nous mettrons en avant [ÉLÉMENT CLÉ DU CLIENT] car c'est ce qui vous différencie de vos concurrents. »"},
    {"type":"callout","variant":"warning","title":"Longueur","text":"3-5 lignes maximum — pas un roman."},
    {"type":"list","items":["Outil : **GestiQ Devis**","Temps : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"3. Section « Ce qui est inclus » (scope précis)"},
    {"type":"paragraph","text":"Liste exhaustive de tout ce qui est inclus. Pour chaque élément : être précis (pas « beau design » → « 5 pages avec design 100% personnalisé »)."},
    {"type":"paragraph","text":"**Toujours inclure :**"},
    {"type":"list","items":[
      "Nombre de pages exact",
      "Logo, hébergement 1 an, domaine .ma ou .com",
      "Email professionnel, SSL à vie",
      "Responsive mobile, SEO de base",
      "WhatsApp intégré, 3 révisions, support 1 an"
    ]},
    {"type":"callout","variant":"tip","title":"Astuce","text":"Ces éléments inclus doivent être perçus comme des bonus — les mettre en valeur."},
    {"type":"list","items":["Outil : **GestiQ Devis**","Temps : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"4. Section « Ce qui n'est PAS inclus »"},
    {"type":"paragraph","text":"Toujours inclure cette section — elle protège contre les litiges et montre la transparence."},
    {"type":"paragraph","text":"**Exemples :**"},
    {"type":"list","items":[
      "Rédaction des textes si non demandée",
      "Photos professionnelles si non fournies",
      "Publicités payantes",
      "Maintenance mensuelle (proposer comme option)"
    ]},
    {"type":"callout","variant":"tip","title":"Formulation","text":"Formuler positivement : « Ces éléments peuvent être ajoutés sur demande » — pas « nous ne faisons pas ça »."},
    {"type":"list","items":["Outil : **GestiQ Devis**","Temps : ~3 min","Statut : requis"]},

    {"type":"heading2","text":"5. Section « Prix et plan de paiement »"},
    {"type":"paragraph","text":"Présenter le prix clairement et sans excuse."},
    {"type":"callout","variant":"danger","title":"Ne JAMAIS écrire","text":"« Le prix est de seulement... » ou « Pour ce budget... » — ça affaiblit la position."},
    {"type":"paragraph","text":"**Écrire simplement :**"},
    {"type":"list","items":[
      "Montant total : **[X] MAD TTC**",
      "Versement 1 (50%) — [X] MAD — À la signature",
      "Versement 2 (25%) — [X] MAD — À la livraison version 1",
      "Versement 3 (25%) — [X] MAD — À la réception finale",
      "Modes : Virement · CIB/Visa · Cash · Wafacash · Cashplus"
    ]},
    {"type":"list","items":["Outil : **GestiQ Devis**","Temps : ~3 min","Statut : requis"]},

    {"type":"heading2","text":"6. Section « Planning avec dates précises »"},
    {"type":"paragraph","text":"Calculer les dates réelles selon le calendrier actuel."},
    {"type":"paragraph","text":"**Exemple :**"},
    {"type":"list","items":[
      "Signature et acompte : [DATE AUJOURD'HUI + 2J]",
      "Kick-off et brief design : [DATE + 3J]",
      "Maquette (wireframe) : [DATE + 7J]",
      "Validation maquette client : [DATE + 9J]",
      "Développement : [DATE + 10 à 14J]",
      "Tests et QA : [DATE + 15J]",
      "Mise en ligne : [DATE + 16J]"
    ]},
    {"type":"callout","variant":"success","title":"Avantage concurrentiel","text":"Ce planning montre que Next Gital est organisé. C'est un avantage majeur."},
    {"type":"list","items":["Outil : **GestiQ Devis + Calendrier**","Temps : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"7. Section « Garanties + CTA »"},
    {"type":"paragraph","text":"Terminer par les 4 garanties écrites et un appel à l'action clair."},
    {"type":"list","items":[
      "🛡️ **Satisfaction garantie** (résultat non conforme → on refait)",
      "⏰ **0 retard garanti** (6 ans, 0 retard)",
      "🔧 **Support sous 24h** toute l'année",
      "🔒 **Sécurité avancée**"
    ]},
    {"type":"paragraph","text":"**Puis le CTA :**"},
    {"type":"quote","text":"« Pour démarrer votre projet, validez ce devis en répondant 'Je valide' à cet email, ou contactez-nous directement. Ce devis est valable jusqu'au [DATE + 7J]. »"},
    {"type":"list","items":["Outil : **GestiQ Devis**","Temps : ~3 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Message envoi devis — WhatsApp (le plus important)"},
    {"type":"template","text":"Bonjour [Prénom] 😊\n\nComme promis, voici votre proposition personnalisée pour [NOM PROJET] :\n\n📄 [LIEN DEVIS PDF]\n\nJ'ai veillé à inclure tout ce dont vous avez besoin pour [OBJECTIF DU CLIENT EN 1 PHRASE].\n\nPoints importants :\n✅ [ÉLÉMENT CLÉ 1 — ce qui compte pour ce client]\n✅ [ÉLÉMENT CLÉ 2]\n✅ Garantie 0 retard + satisfaction garantie par écrit\n\nCe devis est valable jusqu'au [DATE + 7J].\n\nN'hésitez pas si vous avez des questions — je suis disponible pour en discuter 🙏\n\nNext Gital · +212 620 002 066"},

    {"type":"heading","text":"Message envoi devis — Email (version formelle)"},
    {"type":"template","text":"Objet : Votre proposition personnalisée — [NOM PROJET] · Next Gital\n\nBonjour [Prénom],\n\nSuite à notre échange du [DATE], je vous adresse ci-joint votre proposition personnalisée pour [NOM PROJET].\n\nJ'ai structuré cette proposition en tenant compte de vos besoins spécifiques, notamment [BESOIN PRINCIPAL EN 1 PHRASE].\n\nPour démarrer votre projet, il vous suffit de répondre à cet email avec 'Je valide' — nous nous occupons de tout ensuite.\n\nCette proposition est valable jusqu'au [DATE + 7J].\n\nCordialement,\n[Votre prénom]\nNext Gital · Oujda\n+212 620 002 066 · info@nextgital.com"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Section 1 écrite avec les mots du client (compréhension)",
      "Section 2 personnalisée — pas générique",
      "Section 3 — liste précise de tout ce qui est inclus",
      "Section 4 — ce qui n'est pas inclus mentionné",
      "Section 5 — prix clair + plan de paiement 50/25/25",
      "Section 6 — planning avec dates réelles calculées",
      "Section 7 — 4 garanties + CTA clair + date d'expiration",
      "Devis envoyé par WhatsApp ET email dans les 48h"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-commercial-devis');


-- ── ng-commercial-suivi-fidelisation (commercial) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-commercial-suivi-fidelisation',
  'Après la signature — fidéliser et générer des recommandations',
  'Bienvenue J+1, avis Google J+2, appel satisfaction J+30 avec upsell, réactivation J+90 pour nouvelles opportunités.',
  'commercial',
  '["Fidélisation","Recommandation","Upsell","Suivi","Client"]'::jsonb,
  'Next Gital',
  5,
  false,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Dès la signature du contrat — puis à J+7 · J+30 · J+90."},
    {"type":"callout","variant":"info","title":"Canal","text":"WhatsApp · Email · GestiQ."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"100% des clients satisfaits deviennent des ambassadeurs de Next Gital."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Acquérir un nouveau client coûte 5x plus cher que de fidéliser un client existant. Et 1 client satisfait en parle à 3 personnes. Mais 1 client insatisfait en parle à 10. Le suivi post-vente est aussi important que la vente elle-même."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. J+1 après signature — message de bienvenue chaleureux"},
    {"type":"paragraph","text":"Dès le lendemain de la signature : envoyer un message de bienvenue personnalisé (pas automatique — écrit à la main)."},
    {"type":"paragraph","text":"**Contenu :**"},
    {"type":"list","items":[
      "Remercier de la confiance",
      "Confirmer l'excitation de commencer ce projet",
      "Rappeler que le Chef de projet prend contact dans les 24h pour le kick-off",
      "Laisser le numéro direct en cas de question"
    ]},
    {"type":"callout","variant":"success","title":"Effet","text":"Ce message doit faire sentir au client qu'il a pris la bonne décision."},
    {"type":"list","items":["Outil : **WhatsApp**","Temps : ~3 min","Statut : requis"]},

    {"type":"heading2","text":"2. J+2 après livraison — demander l'avis Google"},
    {"type":"paragraph","text":"2 jours après la mise en ligne : envoyer le message de demande d'avis Google."},
    {"type":"callout","variant":"tip","title":"Timing parfait","text":"Le client vient de voir son site en ligne — il est au maximum de sa satisfaction. NE PAS demander pendant le projet (trop tôt). NE PAS attendre 2 semaines (l'enthousiasme retombe). J+2 = le moment idéal."},
    {"type":"callout","variant":"success","title":"Objectif","text":"80%+ des clients donnent un avis quand on demande au bon moment avec le bon message."},
    {"type":"list","items":["Outil : **WhatsApp**","Temps : ~2 min","Statut : requis"]},

    {"type":"heading2","text":"3. J+30 après livraison — appel de satisfaction"},
    {"type":"paragraph","text":"Un mois après la mise en ligne : appeler le client (pas WhatsApp — appeler). Durée : 5-10 minutes."},
    {"type":"paragraph","text":"**Questions à poser :**"},
    {"type":"numbered","items":[
      "« Comment se passe le site depuis le lancement ? »",
      "« Avez-vous reçu des contacts ou clients grâce au site ? »",
      "« Y a-t-il quelque chose que vous aimeriez améliorer ? »",
      "« Avez-vous des amis ou collègues qui auraient besoin d'un service similaire ? »"
    ]},
    {"type":"callout","variant":"success","title":"Question clé","text":"La dernière question est la plus importante — 40% des recommandations viennent de ce type d'appel."},
    {"type":"list","items":["Outil : **Téléphone + GestiQ**","Temps : ~10 min","Statut : requis"]},

    {"type":"heading2","text":"4. J+30 — proposer les services additionnels (upsell naturel)"},
    {"type":"paragraph","text":"Pendant l'appel de satisfaction ou juste après : proposer naturellement les services complémentaires."},
    {"type":"paragraph","text":"Ne pas **vendre** — **proposer** :"},
    {"type":"quote","text":"« Maintenant que le site est en ligne, la prochaine étape logique pour attirer plus de clients serait [SERVICE]. On a des forfaits à partir de [PRIX]/mois — ça vous intéresse qu'on en discute ? »"},
    {"type":"paragraph","text":"**Services à proposer selon le profil :**"},
    {"type":"list","items":[
      "Maintenance mensuelle",
      "Publicités Meta / Google",
      "SEO mensuel",
      "Refonte ou ajout de pages",
      "Système de réservation"
    ]},
    {"type":"callout","variant":"warning","title":"Toujours","text":"Mettre à jour GestiQ avec les intérêts exprimés."},
    {"type":"list","items":["Outil : **Téléphone + GestiQ**","Temps : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"5. J+90 — réactivation et nouvelles opportunités"},
    {"type":"paragraph","text":"3 mois après la livraison : reprendre contact."},
    {"type":"paragraph","text":"**Contenu du message :**"},
    {"type":"list","items":[
      "Montrer un chiffre si disponible (vues Google Maps, Analytics)",
      "Partager une nouveauté de Next Gital pertinente pour ce client",
      "Demander comment évoluent les affaires"
    ]},
    {"type":"callout","variant":"tip","title":"Opportunités","text":"C'est souvent à ce stade que le client pense à agrandir son site, lancer les publicités, ou recommande Next Gital à un ami."},
    {"type":"list","items":["Outil : **WhatsApp + GestiQ**","Temps : ~5 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Message de bienvenue J+1 après signature"},
    {"type":"template","text":"Bonjour [Prénom] 🎉\n\nBienvenue dans la famille Next Gital !\n\nOn est vraiment contents de travailler sur ce projet avec vous — [QUELQUE CHOSE DE SPÉCIFIQUE AU PROJET ou SECTEUR].\n\n[Chef de projet] prendra contact avec vous dans les prochaines 24h pour démarrer officiellement.\n\nD'ici là, si vous avez la moindre question, mon numéro direct : [VOTRE NUMÉRO].\n\nÀ très bientôt ! 🚀"},

    {"type":"heading","text":"Message demande avis Google — J+2 après livraison"},
    {"type":"template","text":"Bonjour [Prénom] 😊\n\nVotre site est en ligne depuis 2 jours — j'espère que vous êtes satisfait du résultat !\n\nSi vous avez une minute, un avis Google nous aiderait énormément à continuer notre travail :\n\n⭐ Laisser un avis (1 minute) : [LIEN DIRECT GOOGLE REVIEW]\n\nVotre retour compte beaucoup pour nous et pour les futurs clients qui veulent en savoir plus sur Next Gital.\n\nMerci d'avance [Prénom] 🙏"},

    {"type":"heading","text":"Message de suivi J+90"},
    {"type":"template","text":"Bonjour [Prénom] 👋\n\n3 mois déjà depuis le lancement de votre site — le temps passe vite !\n\nJ'espère que tout va bien et que vous recevez des contacts grâce à votre présence en ligne.\n\nOn vient de lancer [NOUVEAU SERVICE ou AMELIORATION] qui pourrait être intéressant pour vous — mais sans urgence.\n\nComment se passent les affaires en ce moment ?\n\nBonne semaine ! 🙏\nNext Gital"},

    {"type":"divider"},

    {"type":"heading","text":"KPIs commerciaux — à mesurer chaque semaine"},
    {"type":"table","table":{
      "headers":["Métrique","Objectif"],
      "rows":[
        ["Réunions effectuées","5+/semaine"],
        ["Devis envoyés","3+/semaine"],
        ["Taux conversion devis","≥ 40%"],
        ["Contrats signés","2+/semaine"],
        ["Valeur moyenne devis","≥ 6 000 MAD"],
        ["Avis Google obtenus","2+/mois"],
        ["Upsells réalisés","1+/mois"]
      ]
    }},

    {"type":"divider"},

    {"type":"heading","text":"Règles absolues du Commercial Next Gital"},
    {"type":"numbered","items":[
      "Ne JAMAIS donner un prix avant une réunion de découverte",
      "Ne JAMAIS baisser le prix sans contrepartie",
      "Ne JAMAIS envoyer un devis sans l'avoir personnalisé",
      "TOUJOURS fixer une prochaine étape avant de finir une réunion",
      "TOUJOURS relancer par téléphone (pas WhatsApp) 48h après le devis",
      "TOUJOURS demander l'avis Google à J+2 après livraison",
      "Maximum 3 contacts sur un prospect avant de le marquer Perdu",
      "Si conflit avec un client → informer le fondateur immédiatement (+212 620 002 066)"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Message de bienvenue envoyé J+1 après signature",
      "Avis Google demandé à J+2 après livraison",
      "Appel de satisfaction effectué à J+30",
      "Services additionnels proposés pendant l'appel J+30",
      "Message de réactivation envoyé à J+90",
      "GestiQ mis à jour avec les intérêts et opportunités identifiés"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-commercial-suivi-fidelisation');


COMMIT;
