-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 036 : Seed des 6 SOPs « Community Manager »
--  Date : 2026-05-17
--
--  Catégorie : community_manager · Auteur : Next Gital · Idempotent
--  Périmètre : Routine quotidienne · Calendrier éditorial · Copywriting
--              Reels & TikToks · Gestion crises · Reporting mensuel
--  Insère pour TOUS les tenants existants.
--
--  Conformité ARCHITECTURE_TENANT.md :
--    - tenant_id NOT NULL, contrôle d'existence par (tenant_id, slug)
--    - RLS déjà actif sur public.sops (migration 025)
--    - Pas de modification de la structure existante
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ── ng-cm-routine-quotidienne (community_manager) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-cm-routine-quotidienne',
  'Routine quotidienne — ce que le CM fait chaque jour',
  '4 créneaux par jour : messages 9h, publication 10h, engagement actif 14h, story 17h + rapport quotidien 18h au Chef de projet.',
  'community_manager',
  '["Routine","Quotidien","Engagement","Community","Réseaux"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Chaque jour ouvré — matin et soir."},
    {"type":"callout","variant":"info","title":"Canal","text":"Instagram · Facebook · TikTok · LinkedIn."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Présence active quotidienne sur tous les comptes clients · Réponse à 100% des messages."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Le CM gère plusieurs clients en parallèle. Ne JAMAIS publier sur le mauvais compte — vérifier 2 fois avant chaque publication. Utiliser un tableau de bord pour ne jamais confondre les comptes."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. 9h00 — Vérification messages et commentaires (tous les clients)"},
    {"type":"paragraph","text":"Ouvrir Meta Business Suite (gère FB + IG en même temps). Pour chaque client, vérifier :"},
    {"type":"list","items":[
      "Messages privés non lus",
      "Commentaires sur les posts des 24 dernières heures",
      "Mentions et tags",
      "Avis Google si applicable"
    ]},
    {"type":"paragraph","text":"Règles de réponse — répondre à TOUT dans l'heure qui suit :"},
    {"type":"list","items":[
      "**Messages** → réponse personnalisée en moins de 1h",
      "**Commentaires positifs** → liker + répondre chaleureusement",
      "**Commentaires négatifs** → voir SOP « Gérer les commentaires négatifs »",
      "**Mentions** → liker et répondre si pertinent"
    ]},
    {"type":"list","items":["Outil : **Meta Business Suite + TikTok Business**","Temps : ~30-45 min","Statut : requis"]},

    {"type":"heading2","text":"2. 10h00 — Publier le contenu du jour"},
    {"type":"paragraph","text":"Ouvrir GestiQ → fiche client → onglet Calendrier éditorial. Vérifier quel client a un post prévu aujourd'hui et à quelle heure."},
    {"type":"list","items":[
      "Ouvrir **Canva** → récupérer le visuel préparé par le Designer",
      "Copier le texte du post (préparé selon SOP « Copywriting »)",
      "Publier sur la/les plateforme(s) prévue(s)"
    ]},
    {"type":"paragraph","text":"Vérifier après publication :"},
    {"type":"checklist","items":[
      "Le visuel s'affiche correctement",
      "Le texte est complet (pas coupé)",
      "Le lien fonctionne (si applicable)",
      "Statut mis à jour dans le calendrier éditorial : « Publié »"
    ]},
    {"type":"list","items":["Outil : **Meta Business Suite + Canva + GestiQ**","Temps : ~20-30 min","Statut : requis"]},

    {"type":"heading2","text":"3. 14h00 — Engagement actif (aller vers la communauté)"},
    {"type":"paragraph","text":"Le CM ne se contente pas d'attendre les réactions — il va chercher l'engagement. Pour chaque client :"},
    {"type":"list","items":[
      "Liker et commenter **5-10 posts** de comptes similaires ou partenaires (pas concurrents directs)",
      "Répondre aux stories des abonnés qui ont réagi",
      "Regarder les hashtags utilisés et engager avec les posts récents",
      "Envoyer **2-3 DM** de remerciement aux nouveaux abonnés (message court et sincère, pas robotique)"
    ]},
    {"type":"callout","variant":"success","title":"Pourquoi","text":"Cette activité augmente la portée organique de 20-30%."},
    {"type":"list","items":["Outil : **Instagram + Facebook + TikTok**","Temps : ~20-30 min","Statut : requis"]},

    {"type":"heading2","text":"4. 17h00 — Story du jour (pour les clients avec abonnement stories)"},
    {"type":"paragraph","text":"Publier 1-2 stories par jour pour chaque client actif. Choisir 1 type :"},
    {"type":"list","items":[
      "Coulisses du business (photo ou courte vidéo de l'activité)",
      "Question ou sondage (augmente l'engagement)",
      "Rappel d'un post récent (partager dans la story)",
      "Quote / conseil rapide",
      "Promotions ou actualités"
    ]},
    {"type":"callout","variant":"tip","title":"Authenticité > perfection","text":"Les stories ne nécessitent pas un visuel parfait. Utiliser les autocollants interactifs (sondage, question, compte à rebours)."},
    {"type":"list","items":["Outil : **Instagram Stories + Facebook Stories**","Temps : ~15 min","Statut : requis"]},

    {"type":"heading2","text":"5. 18h00 — Rapport d'activité quotidien au Chef de projet"},
    {"type":"paragraph","text":"Chaque soir avant 18h30 : envoyer un message WhatsApp au Chef de projet avec le récapitulatif de la journée."},
    {"type":"paragraph","text":"Contenu : posts publiés aujourd'hui, messages traités, commentaires importants à signaler, problèmes rencontrés, plan pour demain."},
    {"type":"list","items":["Outil : **WhatsApp + GestiQ**","Temps : ~5 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Rapport quotidien CM — au Chef de projet (18h)"},
    {"type":"template","text":"📱 Rapport CM — [DATE]\n\n━━ PUBLIÉ AUJOURD'HUI ━━\n[CLIENT 1] : [TYPE DE POST] sur [PLATEFORME] ✅\n[CLIENT 2] : [TYPE DE POST] sur [PLATEFORME] ✅\n\n━━ ENGAGEMENT ━━\n• Messages traités : [X]\n• Commentaires répondus : [X]\n• Nouveaux abonnés : [CLIENT] +[X]\n\n━━ À SIGNALER ━━\n[Si commentaire négatif / message important / opportunité]\n\n━━ DEMAIN ━━\n• [CLIENT] : [TYPE DE CONTENU PRÉVU]\n• [CLIENT] : [TYPE DE CONTENU PRÉVU]"},

    {"type":"heading","text":"Réponse DM — nouveau abonné (chaleureux et court)"},
    {"type":"template","text":"Bonjour [Prénom] 😊\n\nMerci de nous suivre ! On est ravis de vous compter parmi notre communauté.\n\nN'hésitez pas si vous avez des questions sur [ACTIVITÉ DU CLIENT].\n\nBonne journée ! 🙏"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "9h — Messages et commentaires vérifiés sur tous les comptes clients",
      "Toutes les réponses envoyées en moins de 1h",
      "10h — Post du jour publié selon le calendrier éditorial",
      "Publication vérifiée (visuel + texte + lien OK)",
      "14h — Engagement actif effectué (5-10 interactions/client)",
      "17h — Story du jour publiée pour les clients actifs",
      "18h — Rapport quotidien envoyé au Chef de projet"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-cm-routine-quotidienne');


-- ── ng-cm-calendrier-editorial (community_manager) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-cm-calendrier-editorial',
  'Calendrier éditorial mensuel — planifier 30 jours de contenu',
  'Analyse mois précédent, règle 40/30/20/10, remplissage GestiQ jour par jour, intégration événements marocains, validation Chef de projet.',
  'community_manager',
  '["Calendrier","Éditorial","Planning","Contenu","Mensuel"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Le 25 de chaque mois — pour le mois suivant."},
    {"type":"callout","variant":"info","title":"Canal","text":"GestiQ · Google Sheets · Canva."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"30 jours de contenu planifié · Zéro jour sans publication pour les clients actifs."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Planifier à l'avance évite le stress du « qu'est-ce qu'on publie aujourd'hui ? ». Le calendrier se crée le 25 du mois pour le mois suivant. Chaque client a son propre calendrier dans GestiQ."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Analyser le mois précédent avant de planifier"},
    {"type":"paragraph","text":"Avant de créer le nouveau calendrier : ouvrir les statistiques du mois précédent pour chaque client. Identifier :"},
    {"type":"list","items":[
      "Le post qui a eu le plus d'engagement (portée, likes, commentaires, partages)",
      "Le post qui a eu le moins d'engagement",
      "Le jour et l'heure où l'audience est la plus active",
      "Le type de contenu le plus performant (photo, vidéo, carrousel, texte)"
    ]},
    {"type":"callout","variant":"warning","title":"Important","text":"Ces données guident les décisions du mois suivant — ne pas répéter ce qui ne fonctionne pas."},
    {"type":"list","items":["Outil : **Meta Business Suite Insights + TikTok Analytics**","Temps : ~20 min par client","Statut : requis"]},

    {"type":"heading2","text":"2. La règle des 4 types de posts — équilibre mensuel"},
    {"type":"paragraph","text":"Chaque mois, le contenu doit être équilibré selon cette règle :"},
    {"type":"list","items":[
      "**40%** posts éducatifs/utiles (conseils, astuces, informations sur le secteur du client)",
      "**30%** posts de preuve sociale (avant/après, témoignages, avis clients, résultats)",
      "**20%** posts promotionnels (offres, services, appel à l'action)",
      "**10%** posts de culture d'entreprise (équipe, coulisses, valeurs)"
    ]},
    {"type":"callout","variant":"danger","title":"Attention","text":"Un calendrier déséquilibré avec trop de posts promotionnels fait fuir les abonnés. Un calendrier trop éducatif ne génère pas assez de leads."},
    {"type":"list","items":["Outil : **Réflexion stratégique**","Temps : ~10 min","Statut : requis"]},

    {"type":"heading2","text":"3. Remplir le calendrier — jour par jour"},
    {"type":"paragraph","text":"Pour chaque post planifié, renseigner dans GestiQ :"},
    {"type":"list","items":[
      "Date et heure de publication",
      "Plateforme (Instagram / Facebook / TikTok / LinkedIn)",
      "Type de contenu (photo / vidéo / carrousel / reel / story)",
      "Sujet précis du post",
      "Type selon la règle des 4 (éducatif / preuve / promo / culture)",
      "Visuel à créer (noter pour le Designer)",
      "Texte à rédiger (rédiger maintenant ou déléguer)",
      "Statut (À faire / Visuel en cours / Texte en cours / Prêt / Publié)"
    ]},
    {"type":"paragraph","text":"Fréquence minimale recommandée :"},
    {"type":"list","items":[
      "3 posts/semaine sur Instagram et Facebook",
      "2 posts/semaine sur TikTok si applicable",
      "1 post/semaine sur LinkedIn si applicable"
    ]},
    {"type":"list","items":["Outil : **GestiQ + Google Sheets**","Temps : ~45 min par client","Statut : requis"]},

    {"type":"heading2","text":"4. Intégrer les événements du mois (fêtes, actualités, secteur)"},
    {"type":"paragraph","text":"Vérifier les événements à ne pas manquer ce mois :"},
    {"type":"list","items":[
      "Fêtes religieuses marocaines (Aïd, Ramadan, Moharram) — adapter le ton et les visuels",
      "Fêtes nationales (Fête du Trône, Marche Verte...)",
      "Journées mondiales liées au secteur du client (Journée de la Santé pour un médecin, Journée de la Femme...)",
      "Actualités locales à Oujda",
      "Saisons et promotions saisonnières"
    ]},
    {"type":"callout","variant":"success","title":"Impact","text":"Ces hooks culturels multiplient l'engagement par 2-3."},
    {"type":"list","items":["Outil : **Calendrier marocain + secteur**","Temps : ~15 min","Statut : requis"]},

    {"type":"heading2","text":"5. Valider le calendrier avec le Chef de projet"},
    {"type":"paragraph","text":"Une fois le calendrier rempli : l'envoyer au Chef de projet pour validation. Le Chef de projet vérifie :"},
    {"type":"list","items":[
      "Cohérence avec les objectifs du client",
      "Pas de post problématique ou sensible",
      "Planning réaliste pour le Designer"
    ]},
    {"type":"paragraph","text":"Après validation :"},
    {"type":"list","items":[
      "Partager le calendrier avec le client s'il le demande",
      "Démarrer la production des visuels avec le Designer (partager la liste des visuels à créer)"
    ]},
    {"type":"list","items":["Outil : **GestiQ + WhatsApp**","Temps : ~10 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Message au Chef de projet — calendrier prêt pour validation"},
    {"type":"template","text":"📅 Calendrier éditorial [NOM CLIENT] — [MOIS ANNÉE] prêt\n\n📊 Contenu planifié :\n• [X] posts Instagram/Facebook\n• [X] Reels/vidéos\n• [X] Stories programmées\n• [X] posts LinkedIn\n\nRépartition :\n• Éducatif : [X]%\n• Preuve sociale : [X]%\n• Promotionnel : [X]%\n• Culture : [X]%\n\n🎨 Visuels à créer pour le Designer : [X] visuels\n📝 Textes rédigés : [X]/[TOTAL]\n\n📁 Lien calendrier : [URL GESTIQ]\n\nEn attente de ta validation pour démarrer la production."},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Statistiques du mois précédent analysées",
      "Règle des 4 types de posts respectée (40/30/20/10)",
      "Calendrier rempli pour les 30 jours — chaque post détaillé",
      "Événements du mois marocains intégrés",
      "Liste des visuels transmise au Designer",
      "Calendrier validé par le Chef de projet"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-cm-calendrier-editorial');


-- ── ng-cm-copywriting (community_manager) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-cm-copywriting',
  'Rédiger les textes des posts — copywriting qui engage',
  'Structure 4 blocs (accroche · développement · émotion · CTA), CTAs marocains qui convertissent, hashtags mix, ton par plateforme et prompts Claude.ai.',
  'community_manager',
  '["Copywriting","Texte","Post","Rédaction","Engagement"]'::jsonb,
  'Next Gital',
  6,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"En amont — textes rédigés avant la date de publication."},
    {"type":"callout","variant":"info","title":"Canal","text":"Instagram · Facebook · TikTok · LinkedIn."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Textes qui génèrent des likes, des commentaires, des partages et des messages."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Un bon visuel avec un mauvais texte ne convertit pas. Un mauvais visuel avec un excellent texte peut tout sauver. Le texte doit répondre à la question inconsciente du lecteur : « Pourquoi je lis ça ? Qu'est-ce que j'y gagne ? »"},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. La structure d'un post Instagram/Facebook efficace — 4 blocs"},
    {"type":"paragraph","text":"**BLOC 1 — L'accroche (ligne 1-2)** : la phrase la plus importante. Elle doit forcer le lecteur à cliquer « voir plus ». Commencer par une question, un chiffre, une affirmation forte, ou un problème que la cible reconnaît."},
    {"type":"paragraph","text":"Exemples d'accroches qui marchent :"},
    {"type":"list","items":[
      "« Vous perdez des clients sans même le savoir. »",
      "« 3 erreurs que font 90% des restaurants sur Instagram. »",
      "« Voici ce que vos concurrents font et pas vous. »"
    ]},
    {"type":"paragraph","text":"**BLOC 2 — Le développement (3-5 lignes)** : répondre à l'accroche avec de la valeur."},
    {"type":"paragraph","text":"**BLOC 3 — L'émotion / connexion (1-2 lignes)** : créer un lien humain."},
    {"type":"paragraph","text":"**BLOC 4 — Le CTA (1 ligne)** : dire exactement ce que le lecteur doit faire."},
    {"type":"list","items":["Outil : **Claude.ai ou ChatGPT + GestiQ**","Temps : ~15 min par post","Statut : requis"]},

    {"type":"heading2","text":"2. Les CTAs qui fonctionnent au Maroc"},
    {"type":"paragraph","text":"**Pour générer des messages WhatsApp** :"},
    {"type":"list","items":[
      "« Envoyez-nous un message pour [ACTION] 👇 »",
      "« Intéressé ? On vous répond en moins d'1h. »"
    ]},
    {"type":"paragraph","text":"**Pour l'engagement** :"},
    {"type":"list","items":[
      "« Dites-nous en commentaire : [QUESTION SIMPLE]. »",
      "« Partagez si vous connaissez quelqu'un qui en a besoin. »"
    ]},
    {"type":"paragraph","text":"**Pour les visites site** : « Découvrez [CHOSE] sur notre site → lien en bio 🔗 »"},
    {"type":"paragraph","text":"**Pour les appels** : « Appelez-nous au [NUMÉRO] pour [BÉNÉFICE]. »"},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"1 seul CTA par post. Trop de CTAs = confusion = aucune action."},
    {"type":"list","items":["Outil : **Copywriting**","Temps : ~1 min","Statut : requis"]},

    {"type":"heading2","text":"3. Les hashtags — comment les choisir"},
    {"type":"paragraph","text":"**Règle hashtags Instagram** : 5-10 hashtags maximum (pas 30 — ça fait spam). Mix obligatoire :"},
    {"type":"list","items":[
      "**2-3 hashtags très populaires** (#Maroc · #Oujda · #[Secteur]Maroc)",
      "**3-4 hashtags moyens** (5 000-50 000 posts) liés au secteur",
      "**2-3 hashtags de niche** (moins de 5 000 posts) très précis"
    ]},
    {"type":"callout","variant":"warning","title":"À éviter","text":"#like4like #followme #spam — ces hashtags attirent des bots."},
    {"type":"paragraph","text":"**Pour Facebook** : aucun hashtag ou 2-3 maximum."},
    {"type":"paragraph","text":"**Pour TikTok** : 3-5 hashtags tendance du moment."},
    {"type":"list","items":["Outil : **Instagram Search + RiteTag**","Temps : ~5 min par post","Statut : requis"]},

    {"type":"heading2","text":"4. Adapter le ton selon la plateforme et le client"},
    {"type":"list","items":[
      "**Instagram** : visuel et inspirant, texte court à moyen (150-300 mots max visible), émojis modérés, hashtags",
      "**Facebook** : plus conversationnel, peut être plus long, partages d'articles, groupes locaux",
      "**TikTok** : ultra court dans la description (1-2 lignes max), tout le message est dans la vidéo",
      "**LinkedIn** : professionnel, structuré, stats et insights, pas d'émojis excessifs"
    ]},
    {"type":"paragraph","text":"Adapter aussi selon le secteur du client :"},
    {"type":"list","items":[
      "**Médecin** : sérieux et rassurant",
      "**Restaurant** : chaleureux et appétissant",
      "**Agence immobilière** : professionnel et aspirationnel"
    ]},
    {"type":"list","items":["Outil : **Adaptation plateforme**","Temps : variable","Statut : requis"]},

    {"type":"heading2","text":"5. Utiliser Claude AI pour rédiger les textes rapidement"},
    {"type":"paragraph","text":"Prompt type à utiliser dans Claude.ai (voir templates ci-dessous). Relire et personnaliser le texte avant de publier — jamais copier-coller directement."},
    {"type":"list","items":["Outil : **Claude.ai · ChatGPT**","Temps : ~5 min par post avec IA","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Prompt Claude.ai — rédiger un post Instagram"},
    {"type":"template","text":"Tu es un community manager expert pour des PME marocaines.\n\nRédige un post Instagram pour [NOM CLIENT], [SECTEUR] basé à [VILLE], Maroc.\n\nSujet du post : [SUJET PRÉCIS]\nType : [éducatif / promotionnel / témoignage / coulisses]\nTon : [sérieux et rassurant / chaleureux et humain / dynamique et jeune]\nCTA voulu : [messages WhatsApp / commentaires / visites site / appels]\n\nContraintes :\n• Accroche percutante en ligne 1 (sans « Vous » en début)\n• 100-150 mots maximum\n• 1 seul CTA clair à la fin\n• 7 hashtags mix (populaires + niche + local Maroc)\n• Langue : français naturel, accessible, pas trop formel\n• Inclure 2-3 émojis pertinents (pas excessif)\n\nFormat de sortie : l'accroche, puis le corps du texte, puis les hashtags séparés."},

    {"type":"heading","text":"Prompt Claude.ai — rédiger 5 accroches pour un post"},
    {"type":"template","text":"Génère 5 accroches percutantes pour un post Instagram sur le sujet : [SUJET].\n\nClient : [SECTEUR] à [VILLE], Maroc.\nCible : [DESCRIPTION CIBLE].\n\nChaque accroche doit :\n• Tenir en 1-2 lignes maximum\n• Forcer le clic « voir plus »\n• Varier les approches (question, chiffre, affirmation, problème, mystère)\n• Être en français naturel marocain\n• Ne pas commencer par « Vous »\n\nNuméroter les 5 versions."},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Accroche forte en ligne 1 — force le « voir plus »",
      "Structure 4 blocs respectée (accroche, développement, émotion, CTA)",
      "1 seul CTA par post",
      "Hashtags : 5-10 avec mix populaire/moyen/niche",
      "Ton adapté à la plateforme et au secteur du client",
      "Texte relu et personnalisé avant publication (pas de copier-coller IA brut)"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-cm-copywriting');


-- ── ng-cm-reels-tiktok (community_manager) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-cm-reels-tiktok',
  'Créer des Reels Instagram et vidéos TikTok',
  '5 types qui marchent au Maroc, structure 15-30 sec, montage CapCut, hooks 3 secondes et publication aux meilleures heures.',
  'community_manager',
  '["Reels","TikTok","Vidéo","CapCut","Contenu"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"2 Reels ou TikToks par semaine minimum par client actif."},
    {"type":"callout","variant":"info","title":"Canal","text":"Instagram Reels · TikTok · CapCut · Canva."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Vidéos qui génèrent 3x plus de portée que les posts photos."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Les Reels et TikToks ont une portée organique 3 à 5 fois supérieure aux photos. Un seul Reel viral peut apporter 10 fois plus d'abonnés qu'un mois de posts photos. Objectif : 2 vidéos courtes par semaine minimum pour chaque client qui a ce service."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Les 5 types de Reels qui fonctionnent pour les PME marocaines"},
    {"type":"list","items":[
      "**TYPE 1 — Avant/Après** : montrer une transformation (avant le site → après le site, avant la rénovation → après). Très partageable.",
      "**TYPE 2 — Coulisses** : 15-30 secondes du quotidien du business (cuisine d'un restaurant, consultation d'un médecin, chantier d'un artisan). Authentique et humain.",
      "**TYPE 3 — Conseil rapide** : « 3 choses à savoir sur [SUJET] » — texte sur écran + voix ou musique.",
      "**TYPE 4 — Témoignage client** : client qui parle de son expérience, ou message WhatsApp positif affiché à l'écran.",
      "**TYPE 5 — FAQ** : répondre à une question fréquente du secteur en 30 secondes."
    ]},
    {"type":"list","items":["Outil : **Smartphone + CapCut**","Temps : référence créative","Statut : requis"]},

    {"type":"heading2","text":"2. Structure d'une vidéo courte efficace (15-30 secondes)"},
    {"type":"list","items":[
      "**Secondes 0-3 (Hook visuel)** : l'image ou action qui accroche immédiatement. Pas d'introduction, pas de logo — commencer au cœur du sujet.",
      "**Secondes 3-20 (Corps)** : le contenu principal. Texte sur écran + narration ou musique. Maximum 3 points si conseil.",
      "**Secondes 20-30 (CTA)** : appel à l'action clair. « Envoyez-nous un message », « Suivez pour plus de conseils », « Lien en bio »."
    ]},
    {"type":"callout","variant":"tip","title":"Musique","text":"Choisir une musique tendance sur TikTok/Reels — augmente la portée organique de l'algorithme."},
    {"type":"list","items":["Outil : **CapCut + Smartphone**","Temps : ~30-60 min par vidéo","Statut : requis"]},

    {"type":"heading2","text":"3. Monter la vidéo avec CapCut"},
    {"type":"paragraph","text":"CapCut (gratuit, très puissant). Étapes :"},
    {"type":"numbered","items":[
      "Importer les clips vidéo ou photos",
      "Couper et réorganiser les clips",
      "Ajouter du texte sur écran (utiliser les polices et couleurs de la charte du client)",
      "Ajouter des sous-titres automatiques (CapCut le fait en 1 clic)",
      "Choisir la musique depuis la bibliothèque TikTok/CapCut (sans droits)",
      "Ajouter des transitions si nécessaire (2-3 max — pas d'effets excessifs)",
      "Exporter en 1080p, format vertical 9:16"
    ]},
    {"type":"paragraph","text":"Durée recommandée : 15-30 secondes pour TikTok, 15-60 secondes pour Reels."},
    {"type":"list","items":["Outil : **CapCut**","Temps : ~30-45 min","Statut : requis"]},

    {"type":"heading2","text":"4. Publier et optimiser le Reel/TikTok"},
    {"type":"paragraph","text":"**Pour Instagram Reel** :"},
    {"type":"list","items":[
      "Choisir la couverture (moment le plus attrayant)",
      "Rédiger la légende avec l'accroche et les hashtags",
      "Activer « Recommander sur Facebook » si applicable",
      "Publier aux meilleures heures : mardi-jeudi-vendredi entre 18h-21h"
    ]},
    {"type":"paragraph","text":"**Pour TikTok** :"},
    {"type":"list","items":[
      "Description courte (1-2 lignes max)",
      "3-5 hashtags tendance",
      "Ajouter à une playlist thématique si applicable"
    ]},
    {"type":"callout","variant":"success","title":"Astuce algorithme","text":"Surveiller les premières heures : liker les commentaires rapidement — ça signale à l'algorithme que le contenu est engageant."},
    {"type":"list","items":["Outil : **Instagram + TikTok**","Temps : ~10 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Prompt Claude.ai — script pour un Reel 30 secondes"},
    {"type":"template","text":"Écris un script pour un Reel Instagram de 30 secondes pour [NOM CLIENT], [SECTEUR] à [VILLE].\n\nType de vidéo : [Conseil / Avant-Après / Coulisses / Témoignage / FAQ]\nSujet : [SUJET PRÉCIS]\nCible : [DESCRIPTION CIBLE]\n\nFormat du script :\n• Secondes 0-3 : [Hook visuel — décrire ce qu'on voit + texte à l'écran]\n• Secondes 3-20 : [Contenu principal — voix off ou texte à l'écran]\n• Secondes 20-30 : [CTA clair]\n\nTon : naturel, pas trop formel, accessible au public marocain.\nLangue : français ou mix français/darija si approprié.\nMaximum 80 mots au total (vidéo courte)."},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Type de vidéo choisi selon le plan éditorial",
      "Hook visuel fort dans les 3 premières secondes",
      "Durée respectée : 15-30 secondes",
      "Texte sur écran lisible et dans la charte graphique du client",
      "Musique tendance choisie (sans droits)",
      "Exporté en 1080p format 9:16",
      "Publié aux bonnes heures selon les statistiques client"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-cm-reels-tiktok');


-- ── ng-cm-crise-commentaires (community_manager) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-cm-crise-commentaires',
  'Gérer les commentaires négatifs et les crises réseaux sociaux',
  'Catégoriser A/B/C/D, répondre avec empathie, masquer pas supprimer, alerter le fondateur sur les crises virales.',
  'community_manager',
  '["CommentairesNégatifs","Crise","Modération","Réputation","Réponse"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Dès qu'un commentaire négatif est détecté — dans l'heure."},
    {"type":"callout","variant":"info","title":"Canal","text":"Instagram · Facebook · TikTok · Google Maps."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Transformer 80% des avis négatifs en preuves de professionnalisme."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Un commentaire négatif bien géré est plus puissant qu'un commentaire positif. Les gens regardent comment une entreprise réagit aux critiques. La règle : ne jamais supprimer, ne jamais agresser, toujours répondre avec calme et proposer une solution. Informer le fondateur IMMÉDIATEMENT si la crise dépasse le cadre normal."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Catégoriser le commentaire avant de répondre"},
    {"type":"paragraph","text":"Avant de répondre à un commentaire négatif, identifier la catégorie :"},
    {"type":"list","items":[
      "**TYPE A — Insatisfaction réelle** (client mécontent d'un produit ou service) → répondre avec empathie + solution",
      "**TYPE B — Malentendu** (commentaire basé sur une fausse information) → corriger poliment avec les faits",
      "**TYPE C — Troll ou commentaire abusif** (insultes, contenu hors sujet, spam) → 1 seule réponse professionnelle puis signaler/masquer si récidive",
      "**TYPE D — Crise grave** (accusation sérieuse, contenu viral négatif) → informer immédiatement le fondateur avant de répondre"
    ]},
    {"type":"callout","variant":"warning","title":"Important","text":"Ne jamais répondre à chaud — prendre 5 minutes pour se calmer."},
    {"type":"list","items":["Outil : **Analyse + Calme**","Temps : ~2 min","Statut : requis"]},

    {"type":"heading2","text":"2. TYPE A — Répondre à une insatisfaction réelle"},
    {"type":"paragraph","text":"Structure de réponse en 4 temps :"},
    {"type":"numbered","items":[
      "**Reconnaître** : « Bonjour [Prénom], merci de nous avoir partagé votre expérience. »",
      "**S'excuser sincèrement** : « Nous sommes vraiment désolés que votre expérience n'ait pas été à la hauteur de vos attentes. »",
      "**Proposer une solution** : « Nous aimerions arranger les choses — pouvez-vous nous contacter en DM ou au [NUMÉRO] ? »",
      "**Conclure positivement** : « Votre satisfaction est notre priorité et nous ferons tout pour y remédier. »"
    ]},
    {"type":"callout","variant":"danger","title":"NE JAMAIS","text":"Se justifier de façon défensive · Rejeter la faute sur le client · Offrir publiquement une compensation (faire ça en privé)."},
    {"type":"list","items":["Outil : **Réponse publique + DM**","Temps : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"3. TYPE B — Répondre à un malentendu"},
    {"type":"paragraph","text":"Structure :"},
    {"type":"numbered","items":[
      "Remercier du retour",
      "Corriger avec les faits (sans agressivité) : « En fait, notre fonctionnement est [EXPLICATION SIMPLE]. »",
      "Proposer d'en discuter en privé si nécessaire"
    ]},
    {"type":"paragraph","text":"**Exemple** — commentaire « Votre site m'a été livré en retard » → réponse :"},
    {"type":"quote","text":"« Bonjour, nous comprenons votre ressenti. Suite à vérification dans notre système, le livrable a bien été envoyé le [DATE] dans les délais convenus. N'hésitez pas à nous contacter en DM pour qu'on clarifie ensemble. »"},
    {"type":"list","items":["Outil : **Faits + Dialogue**","Temps : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"4. TYPE C — Gérer un troll ou commentaire abusif"},
    {"type":"paragraph","text":"1 seule réponse professionnelle :"},
    {"type":"quote","text":"« Bonjour, nous prenons note de votre message. N'hésitez pas à nous contacter en privé si vous souhaitez discuter. »"},
    {"type":"paragraph","text":"Si récidive d'insultes :"},
    {"type":"list","items":[
      "**Masquer** le commentaire (pas supprimer — ça peut créer une polémique)",
      "Signaler le profil à la plateforme"
    ]},
    {"type":"callout","variant":"danger","title":"Ne jamais","text":"Rentrer dans un débat public avec un troll — ça attire l'attention négativement. Pas d'ironie ni d'humour sarcastique."},
    {"type":"list","items":["Outil : **1 réponse + Masquer si nécessaire**","Temps : ~2 min","Statut : requis"]},

    {"type":"heading2","text":"5. TYPE D — Protocole crise grave : informer le fondateur"},
    {"type":"paragraph","text":"Si : commentaire viral avec beaucoup de partages, accusation grave (arnaque, mauvaise foi), article ou vidéo négative sur le client, bad buzz qui commence à se développer → **NE PAS répondre seul**."},
    {"type":"numbered","items":[
      "Faire une capture d'écran immédiatement",
      "Envoyer au fondateur par WhatsApp avec le message d'alerte",
      "Attendre les instructions avant toute réponse publique"
    ]},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Ne jamais supprimer une publication virale sans accord — ça amplifie toujours la crise."},
    {"type":"list","items":["Outil : **WhatsApp Fondateur (+212 620 002 066)**","Temps : ~2 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Réponse type — commentaire négatif insatisfaction"},
    {"type":"template","text":"Bonjour [Prénom],\n\nMerci de nous avoir partagé votre expérience — votre retour est important pour nous.\n\nNous sommes sincèrement désolés que votre expérience n'ait pas été à la hauteur de vos attentes.\n\nNous aimerions comprendre et arranger les choses. Pouvez-vous nous contacter directement en message privé ou au [NUMÉRO] ?\n\nVotre satisfaction est notre priorité. 🙏\n[NOM CLIENT]"},

    {"type":"heading","text":"Message d'alerte crise — au fondateur (WhatsApp urgent)"},
    {"type":"template","text":"⚠️ ALERTE CRISE RÉSEAUX — [NOM CLIENT]\n\nPlateforme : [Instagram / Facebook / TikTok / Google]\nType de problème : [DESCRIPTION EN 2 LIGNES]\nUrgence : [Faible / Moyenne / Élevée]\n\nCapture d'écran : [joindre la capture]\n\nJ'attends vos instructions avant de répondre.\n\nLien vers le commentaire/post : [URL si disponible]"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Commentaire catégorisé (A/B/C/D) avant de répondre",
      "Réponse rédigée avec calme — jamais à chaud",
      "Structure 4 temps respectée pour les insatisfactions",
      "Aucune justification défensive dans la réponse",
      "Solution proposée en privé (DM ou téléphone)",
      "Fondateur alerté immédiatement pour les crises TYPE D"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-cm-crise-commentaires');


-- ── ng-cm-rapport-mensuel (community_manager) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-cm-rapport-mensuel',
  'Rapport mensuel community management — client et fondateur',
  'Collecte stats Meta + TikTok, analyse insights, rapport client visuel 2-3 pages Canva, rapport interne détaillé + 3 recommandations.',
  'community_manager',
  '["Rapport","Statistiques","Mensuel","KPIs","Analytics"]'::jsonb,
  'Next Gital',
  5,
  false,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Le 1er du mois — pour le mois précédent."},
    {"type":"callout","variant":"info","title":"Canal","text":"GestiQ · Meta Business Suite · Google Sheets."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Prouver la valeur du service CM avec des chiffres concrets · Identifier ce qui fonctionne."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Le rapport mensuel est ce qui justifie l'abonnement mensuel du client. Un rapport clair avec des chiffres qui progressent = client fidèle. Un rapport flou = client qui se demande pourquoi il paie. Toujours accompagner les chiffres d'une analyse et de recommandations."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Collecter les statistiques — toutes les plateformes"},
    {"type":"paragraph","text":"Meta Business Suite → Insights → Exporter les données du mois. Données à collecter :"},
    {"type":"list","items":[
      "**Portée totale** (nombre de personnes qui ont vu le contenu)",
      "**Impressions** (nombre total d'affichages)",
      "**Nouveaux abonnés** (net : arrivées - départs)",
      "**Engagement total** (likes + commentaires + partages + saves)",
      "**Taux d'engagement** (engagement / portée × 100)",
      "**Messages reçus en DM**",
      "**Meilleur post du mois** (celui avec le plus d'engagement)",
      "**Posts les moins performants**"
    ]},
    {"type":"paragraph","text":"Mêmes données sur TikTok Analytics si applicable."},
    {"type":"list","items":["Outil : **Meta Business Suite + TikTok Analytics**","Temps : ~20 min par client","Statut : requis"]},

    {"type":"heading2","text":"2. Analyser les données — trouver les insights"},
    {"type":"paragraph","text":"Au-delà des chiffres bruts, identifier :"},
    {"type":"list","items":[
      "Le type de contenu le plus performant ce mois (photo, vidéo, carrousel, Reel)",
      "Les jours et heures avec le plus d'engagement",
      "L'évolution par rapport au mois précédent (hausse ou baisse et pourquoi)",
      "Ce qui a surpris positivement (un post inattendu qui a bien marché)",
      "Ce qui a déçu (un post attendu qui n'a pas marché et pourquoi)"
    ]},
    {"type":"callout","variant":"success","title":"Pourquoi","text":"Ces insights guident le calendrier du mois suivant."},
    {"type":"list","items":["Outil : **Analyse données**","Temps : ~15 min par client","Statut : requis"]},

    {"type":"heading2","text":"3. Rédiger le rapport client — version simple et visuelle"},
    {"type":"paragraph","text":"Le rapport client doit être :"},
    {"type":"list","items":[
      "**Simple** (pas de jargon technique)",
      "**Visuel** (chiffres en gros, graphiques si possible)",
      "**Positif** (mettre en avant les progressions)",
      "**Actionnable** (3 recommandations concrètes)"
    ]},
    {"type":"paragraph","text":"**Format recommandé** : PDF 2-3 pages créé dans Canva avec les couleurs du client. Structure : résumé exécutif (1 page), stats détaillées (1 page), recommandations mois prochain (1 demi-page)."},
    {"type":"list","items":["Outil : **Canva + Google Slides**","Temps : ~30 min par client","Statut : requis"]},

    {"type":"heading2","text":"4. Rédiger le rapport interne — version détaillée pour le fondateur"},
    {"type":"paragraph","text":"Version plus détaillée avec :"},
    {"type":"list","items":[
      "Toutes les statistiques brutes",
      "Analyse des performances vs objectifs",
      "Problèmes rencontrés ce mois",
      "Ce qui a bien fonctionné (à répliquer)",
      "Ce qui n'a pas fonctionné (à améliorer ou abandonner)",
      "Recommandations stratégiques pour le mois suivant",
      "Temps passé sur ce client (pour évaluer la rentabilité)"
    ]},
    {"type":"list","items":["Outil : **GestiQ + WhatsApp**","Temps : ~15 min","Statut : requis"]},

    {"type":"heading2","text":"5. Envoyer les rapports et planifier le call de suivi"},
    {"type":"list","items":[
      "Envoyer le rapport client via WhatsApp (PDF) + proposer un appel de 15 min pour en discuter",
      "Envoyer le rapport interne au fondateur",
      "Inclure dans les deux rapports : les 3 recommandations pour le mois suivant et le calendrier éditorial du mois prochain (déjà préparé)"
    ]},
    {"type":"list","items":["Outil : **WhatsApp + Email**","Temps : ~10 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Rapport mensuel client — message d'accompagnement WhatsApp"},
    {"type":"template","text":"Bonjour [Prénom] 😊\n\nVoici le rapport de votre présence sur les réseaux sociaux pour le mois de [MOIS] :\n\n📊 Rapport mensuel : [LIEN PDF ou PDF joint]\n\nEn résumé ce mois :\n✅ [X] personnes touchées\n✅ +[X] nouveaux abonnés\n✅ [X]% de taux d'engagement\n✅ Meilleur post : [SUJET] avec [X] interactions\n\nPour le mois prochain, on va [RECOMMANDATION PRINCIPALE].\n\nUn call de 15 min pour en discuter ? Je suis disponible [JOURS]. 🙏"},

    {"type":"heading","text":"Rapport mensuel CM — au fondateur"},
    {"type":"template","text":"📊 RAPPORT CM MENSUEL — [NOM CLIENT] — [MOIS]\n\n━━ CHIFFRES ━━\nPortée : [X] (vs [X] mois dernier : [+/-]%)\nNouveaux abonnés : [X]\nEngagement total : [X] ([X]%)\nMessages DM reçus : [X]\nMeilleur post : « [SUJET] » — [X] interactions\n\n━━ ANALYSE ━━\nCe qui a marché : [EXPLICATION]\nCe qui n'a pas marché : [EXPLICATION]\nSurprise du mois : [SI APPLICABLE]\n\n━━ RECOMMANDATIONS MOIS PROCHAIN ━━\n1. [ACTION CONCRÈTE]\n2. [ACTION CONCRÈTE]\n3. [ACTION CONCRÈTE]\n\n━━ TEMPS PASSÉ ━━\n[X] heures ce mois sur ce client"},

    {"type":"divider"},

    {"type":"heading","text":"KPIs Community Manager — à mesurer chaque mois"},
    {"type":"table","table":{
      "headers":["Métrique","Objectif mensuel par client"],
      "rows":[
        ["Posts publiés","12+ (3/semaine)"],
        ["Reels / TikToks","8+ (2/semaine)"],
        ["Taux d'engagement","≥ 3%"],
        ["Nouveaux abonnés","+50 minimum"],
        ["Messages DM traités","100% en moins d'1h"],
        ["Commentaires répondus","100%"],
        ["Rapport mensuel envoyé","Le 1er du mois"]
      ]
    }},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Statistiques collectées sur toutes les plateformes actives",
      "Analyse des données effectuée — insights identifiés",
      "Rapport client créé (PDF simple, 2-3 pages)",
      "Rapport interne rédigé pour le fondateur",
      "Rapport client envoyé avec message d'accompagnement",
      "Call de suivi proposé au client",
      "Calendrier du mois suivant joint au rapport"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-cm-rapport-mensuel');


COMMIT;
