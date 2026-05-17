-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 032 : Seed des 6 SOPs « Prospection »
--  Date : 2026-05-17
--
--  Catégorie : prospection · Auteur : Next Gital · Idempotent
--  Cible : trouver des clients SANS publicité payante
--  (LinkedIn · WhatsApp · Terrain · Partenariats · Google Maps)
--  Insère pour TOUS les tenants existants.
--
--  Conformité ARCHITECTURE_TENANT.md :
--    - tenant_id NOT NULL, contrôle d'existence par (tenant_id, slug)
--    - RLS déjà actif sur public.sops (migration 025)
--    - Pas de modification de la structure existante
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ── ng-prospect-identifier (prospection) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-prospect-identifier',
  'Identifier et qualifier les prospects — Qui cibler en priorité',
  'Construire une liste de 20 prospects qualifiés par semaine via Google Maps, Facebook, Instagram et le terrain.',
  'prospection',
  '["Prospect","Qualification","Ciblage","Priorité"]'::jsonb,
  'Next Gital',
  4,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Chaque matin — 1h de travail."},
    {"type":"callout","variant":"info","title":"Canal","text":"Google Maps · Facebook · Instagram · Terrain Oujda."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Avoir une liste de 20 prospects qualifiés prêts à être contactés chaque semaine."},
    {"type":"callout","variant":"warning","title":"Règle","text":"Ne jamais contacter quelqu'un sans l'avoir qualifié d'abord. Un prospect non qualifié = temps perdu. La qualification prend 2 minutes et économise 20 minutes."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Les 5 profils de clients prioritaires Next Gital"},
    {"type":"paragraph","text":"Mémoriser ces 5 profils — ce sont les meilleurs clients de Next Gital :"},
    {"type":"numbered","items":[
      "**Médecins / Dentistes / Cliniques** — besoin urgent de crédibilité en ligne, budget disponible, décident vite.",
      "**Avocats / Notaires / Experts-comptables** — cherchent la confiance et le professionnalisme.",
      "**Restaurants / Cafés / Hôtels** — besoin de visibilité locale et de réservations.",
      "**Agences immobilières** — besoin de montrer leur catalogue en ligne.",
      "**Boutiques et commerces locaux** — veulent vendre en ligne ou être trouvés sur Google."
    ]},
    {"type":"callout","variant":"success","title":"Pourquoi","text":"Ces 5 profils = 80% des ventes de Next Gital."},
    {"type":"list","items":["Outil : **Connaissance**","Temps : à mémoriser","Statut : requis"]},

    {"type":"heading2","text":"2. Les 3 signaux qui montrent qu'un prospect est PRÊT à acheter"},
    {"type":"numbered","items":[
      "**Pas de site web** (ou site cassé) : chercher sur Google le nom de l'entreprise — si rien ou site vieux → prospect chaud.",
      "**Présence faible sur les réseaux** : page Facebook avec peu d'abonnés, peu de posts, mauvaises photos → opportunité.",
      "**Mauvais avis Google ou peu d'avis** : si le concurrent a 50 avis et lui en a 5 → il a besoin d'aide."
    ]},
    {"type":"callout","variant":"tip","title":"Lecture","text":"Ces 3 signaux = le prospect SOUFFRE déjà d'un problème réel."},
    {"type":"list","items":["Outil : **Google + Facebook + Instagram**","Temps : ~2 min par prospect","Statut : requis"]},

    {"type":"heading2","text":"3. Chercher les prospects sur Google Maps"},
    {"type":"paragraph","text":"Ouvrir Google Maps. Taper : **[SECTEUR] + [VILLE]**. Exemples : « dentiste oujda », « restaurant oujda », « agence immobilière oujda »."},
    {"type":"list","items":[
      "Vérifier si le site web est absent, vieux, ou cassé",
      "Vérifier le nombre et la qualité des photos",
      "Vérifier le nombre d'avis Google",
      "Copier dans la fiche prospect GestiQ : nom, téléphone, adresse, niveau d'urgence (1-5)"
    ]},
    {"type":"list","items":["Outil : **Google Maps + GestiQ**","Temps : ~30 min","Objectif : 10 prospects qualifiés"]},

    {"type":"heading2","text":"4. Chercher les prospects sur Facebook et Instagram"},
    {"type":"list","items":[
      "**Facebook** : pages d'entreprises locales avec peu d'abonnés, mauvaises photos, dernière publication ancienne",
      "**Instagram** : #oujda + secteur. Regarder qui poste avec peu d'engagement",
      "**TikTok** : entreprises d'Oujda avec peu de vues"
    ]},
    {"type":"callout","variant":"warning","title":"Important","text":"NE PAS contacter encore — juste lister dans GestiQ avec nom + lien profil + problème identifié."},
    {"type":"list","items":["Outil : **Facebook · Instagram · TikTok**","Temps : ~20 min","Statut : requis"]},

    {"type":"heading2","text":"5. Remplir la fiche prospect dans GestiQ"},
    {"type":"paragraph","text":"GestiQ → CRM → Nouveau Prospect. Remplir toutes les colonnes (voir template ci-dessous). Objectif : 20 fiches remplies par semaine."},
    {"type":"list","items":["Outil : **GestiQ CRM**","Temps : ~5 min par prospect","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Template fiche prospect — à remplir dans GestiQ"},
    {"type":"template","text":"NOM ENTREPRISE : [___________]\nSECTEUR : [___________]\nDÉCIDEUR : [Nom + Prénom si connu]\nTÉLÉPHONE : [___________]\nEMAIL : [___________ ou Inconnu]\nSITE WEB : [URL ou 'Pas de site']\n\nPROBLÈME IDENTIFIÉ :\n☐ Pas de site web\n☐ Site vieux / cassé\n☐ Pas de présence réseaux sociaux\n☐ Peu d'avis Google (< 10)\n☐ Mauvaises photos / contenu pauvre\n☐ Concurrent mieux positionné\n\nURGENCE (1-5) : [__]\nSOURCE : [Google Maps / FB / IG / Terrain / Reco]\nSTATUT : À contacter\nDATE À CONTACTER : [__/__/____]"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Les 5 profils prioritaires mémorisés",
      "Les 3 signaux d'achat connus",
      "10 prospects trouvés sur Google Maps",
      "10 prospects trouvés sur réseaux sociaux",
      "20 fiches prospects remplies dans GestiQ cette semaine",
      "Niveau d'urgence attribué à chaque prospect"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-prospect-identifier');


-- ── ng-prospect-whatsapp (prospection) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-prospect-whatsapp',
  'Prospection WhatsApp — Messages qui obtiennent des réponses',
  'Templates WhatsApp ciblés (pas de site, site vieux, peu d''avis, recommandation) + gestion des réponses.',
  'prospection',
  '["WhatsApp","Prospection","Message","Maroc","Lead"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Chaque jour — 10 à 15 messages envoyés."},
    {"type":"callout","variant":"info","title":"Canal","text":"WhatsApp Business Next Gital."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Taux de réponse ≥ 30% · 3 à 5 réunions fixées par semaine."},
    {"type":"callout","variant":"danger","title":"Règle d'or","text":"1 seul message par prospect au départ — jamais 2 messages non sollicités d'affilée. Attendre 48h avant de relancer. Si refus → remercier et fermer proprement. Ne jamais insister."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Préparer le message AVANT d'appuyer sur Envoyer"},
    {"type":"list","items":[
      "Vérifier le **nom exact** du prospect et de son entreprise",
      "Identifier le **problème spécifique** (pas de site, mauvaises photos, peu d'avis)",
      "Adapter le message à ce problème précis — pas de copier-coller générique",
      "Horaires : **9h–12h ou 15h–18h, du lundi au vendredi** uniquement",
      "Jamais le vendredi soir, samedi, ou dimanche"
    ]},
    {"type":"list","items":["Outil : **WhatsApp Business**","Temps : ~2 min par message","Statut : requis"]},

    {"type":"heading2","text":"2. MESSAGE TYPE 1 — Prospect sans site web"},
    {"type":"paragraph","text":"Pour les professionnels (médecins, avocats, artisans) sans site."},
    {"type":"template","text":"Bonjour [Prénom],\n\nJe suis [Votre prénom] de Next Gital, agence web à Oujda. J'ai cherché [Nom de son entreprise] sur Google et j'ai remarqué que vous n'avez pas encore de site web.\n\nVos patients / clients vous cherchent en ligne avant de venir vous voir — et ils ne vous trouvent pas.\n\nJe peux vous créer un site professionnel en 7 jours, avec votre logo, vos services et votre numéro de téléphone.\n\nEst-ce que ça vous intéresse qu'on en discute 10 minutes cette semaine ?"},

    {"type":"heading2","text":"3. MESSAGE TYPE 2 — Prospect avec site vieux ou cassé"},
    {"type":"paragraph","text":"Pour les entreprises avec un site web dépassé ou qui ne fonctionne pas bien."},
    {"type":"template","text":"Bonjour [Prénom],\n\nJe suis [Votre prénom] de Next Gital à Oujda. J'ai visité votre site [URL] et j'ai remarqué qu'il est difficile à lire sur mobile — la majorité de vos clients naviguent sur téléphone.\n\nUn site qui ne fonctionne pas bien sur mobile fait perdre des clients. On peut le moderniser et le rendre rapide en 10 jours.\n\nVous avez 15 minutes cette semaine pour qu'on en parle ?"},

    {"type":"heading2","text":"4. MESSAGE TYPE 3 — Prospect avec peu d'avis Google"},
    {"type":"paragraph","text":"Pour les entreprises avec moins de 10 avis Google ou une note faible."},
    {"type":"template","text":"Bonjour [Prénom],\n\nJe suis [Votre prénom] de Next Gital. J'ai regardé votre fiche Google — vous avez [X] avis. Votre concurrent [Nom concurrent] en a [X].\n\nLes gens choisissent en fonction des avis Google avant même de visiter. On peut vous aider à améliorer votre présence sur Google et à avoir plus d'avis positifs — et ça commence par un beau site web.\n\nCurieux d'en savoir plus ?"},

    {"type":"heading2","text":"5. MESSAGE TYPE 4 — Après une recommandation d'un client"},
    {"type":"paragraph","text":"Le plus facile à convertir — un client actuel a recommandé ce prospect."},
    {"type":"template","text":"Bonjour [Prénom],\n\nJe suis [Votre prénom] de Next Gital, l'agence web qui a créé le site de [Nom du client qui recommande].\n\n[Client] m'a parlé de vous et m'a dit que vous cherchez peut-être à améliorer votre présence en ligne. On travaille avec beaucoup d'[SECTEUR] à Oujda et les résultats sont concrets.\n\nEst-ce qu'on peut discuter 15 minutes pour voir si on peut vous aider ?"},

    {"type":"heading2","text":"6. Gérer les réponses — 4 scénarios possibles"},
    {"type":"numbered","items":[
      "**Intéressé** : répondre dans les 30 min. Envoyer le lien Calendly pour fixer une réunion de 30 min.",
      "**Pas intéressé maintenant** : « Pas de problème, je comprends tout à fait. Si jamais vous changez d'avis, n'hésitez pas. Bonne journée ! » → Marquer « Refus » dans GestiQ + rappel dans 3 mois.",
      "**Pas de réponse après 48h** : envoyer le message de relance unique (voir étape 7).",
      "**Demande le prix immédiatement** : « Le tarif dépend de votre projet — c'est pour ça que je préfère qu'on discute 15 min pour vous donner un prix précis. Êtes-vous disponible cette semaine ? »"
    ]},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Ne JAMAIS donner un prix par WhatsApp. Toujours proposer une réunion."},

    {"type":"heading2","text":"7. Message de relance unique — après 48h sans réponse"},
    {"type":"paragraph","text":"Une seule relance, jamais deux."},
    {"type":"template","text":"Bonjour [Prénom],\n\nJe voulais juste m'assurer que mon message est bien arrivé. Si ce n'est pas le bon moment, pas de problème du tout.\n\nJe reste disponible si vous souhaitez en discuter. Bonne journée ! 🙏"},
    {"type":"callout","variant":"warning","title":"Après la relance","text":"Si pas de réponse après cette relance → marquer « Perdu » dans GestiQ et ne plus contacter pendant 90 jours."},

    {"type":"divider"},

    {"type":"heading","text":"Checklist quotidienne"},
    {"type":"checklist","items":[
      "10 à 15 messages WhatsApp personnalisés envoyés aujourd'hui",
      "Heure d'envoi respectée (9h-12h ou 15h-18h en semaine)",
      "Chaque message adapté au problème spécifique du prospect",
      "Aucun prix donné par WhatsApp",
      "Toutes les réponses traitées dans les 30 minutes",
      "Statut mis à jour dans GestiQ pour chaque prospect contacté",
      "Relances envoyées uniquement après 48h — 1 seule fois"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-prospect-whatsapp');


-- ── ng-prospect-terrain (prospection) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-prospect-terrain',
  'Prospection terrain — Visites physiques à Oujda',
  'Sortie terrain 2x/semaine : préparation, accroche en face à face, qualification, RDV fixé, suivi WhatsApp.',
  'prospection',
  '["Terrain","Visite","Oujda","Physique","BtoB"]'::jsonb,
  'Next Gital',
  4,
  false,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"2 fois par semaine — mardi et jeudi matin (9h–12h)."},
    {"type":"callout","variant":"info","title":"Canal","text":"Terrain · Bureau Oujda."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"5 visites par sortie · 1 rendez-vous fixé minimum par sortie."},
    {"type":"callout","variant":"warning","title":"À retenir","text":"Au Maroc, voir quelqu'un en face à face crée une confiance immédiate qu'un message WhatsApp ne peut pas créer. Tenue correcte obligatoire : chemise ou veste Next Gital."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Préparer la sortie terrain la veille"},
    {"type":"list","items":[
      "Choisir le quartier (alterner : Centre-ville / Hay Al Qods / Sidi Maârouf / Lazaret / autres)",
      "Lister les 10 entreprises à visiter dans GestiQ ou via Google Maps",
      "Préparer : **10 cartes de visite Next Gital**, **3 flyers** avec les offres",
      "Téléphone chargé, application GestiQ ouverte",
      "Prévoir **3 heures minimum** (9h–12h recommandé)"
    ]},
    {"type":"list","items":["Outil : **GestiQ + Google Maps**","Temps : ~20 min la veille","Statut : requis"]},

    {"type":"heading2","text":"2. L'accroche en face à face — les 30 premières secondes"},
    {"type":"paragraph","text":"Les 30 premières secondes décident de tout. Script exact à dire à l'entrée :"},
    {"type":"template","text":"Bonjour [sourire] !\n\nJe suis [Prénom] de Next Gital, une agence web basée ici à Oujda.\n\nOn aide les [SECTEUR] de la région à trouver plus de clients grâce à un beau site web et une meilleure présence sur Google.\n\nEst-ce que c'est quelque chose qui vous intéresse, ou est-ce que ce n'est pas le bon moment ?"},
    {"type":"list","items":[
      "**Sourire sincère** dès l'entrée",
      "Poser une **question fermée** (oui/non) pour qualifier immédiatement",
      "Si le décideur n'est pas là → demander son prénom et son numéro",
      "Ne jamais rester **plus de 5 minutes** si pas intéressé"
    ]},

    {"type":"heading2","text":"3. Si la personne est intéressée — les 5 questions clés"},
    {"type":"numbered","items":[
      "Avez-vous déjà un site web ? *(création ou refonte)*",
      "Quels types de clients cherchez-vous à attirer ? *(objectif)*",
      "Vos clients vous trouvent-ils facilement sur Google ? *(douleur)*",
      "Avez-vous un budget en tête pour ce type de projet ? *(qualification budget)*",
      "Quel est le meilleur moment pour se rappeler et voir ça ensemble ? *(RDV)*"
    ]},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"NE PAS parler de prix sur le terrain — proposer une réunion de 30 min."},

    {"type":"heading2","text":"4. Fixer le rendez-vous — en sortant du commerce"},
    {"type":"paragraph","text":"Si intéressé : sortir immédiatement le téléphone et ouvrir Calendly."},
    {"type":"template","text":"Je vous propose qu'on se retrouve [JOUR] à [HEURE] — soit ici chez vous, soit dans notre bureau au 4ème étage Immeuble Kissi.\n\nQu'est-ce qui vous convient le mieux ?"},
    {"type":"list","items":[
      "Enregistrer le RDV dans Calendly **et** dans GestiQ immédiatement",
      "Donner une carte de visite Next Gital",
      "Envoyer un WhatsApp de confirmation dans la minute qui suit la visite"
    ]},

    {"type":"heading2","text":"5. Remplir GestiQ juste après chaque visite"},
    {"type":"paragraph","text":"Ne pas attendre le retour au bureau. Remplir depuis le téléphone, sur place ou dans la voiture."},
    {"type":"list","items":[
      "Nom entreprise · Décideur · Téléphone",
      "Problème identifié · Niveau d'intérêt (1-5)",
      "RDV fixé (O/N) · Prochain contact (date)",
      "Si décideur absent : noter son prénom et rappeler dans l'après-midi"
    ]},
    {"type":"list","items":["Outil : **GestiQ mobile**","Temps : ~2 min par visite","Statut : requis"]},

    {"type":"heading2","text":"6. Message WhatsApp de suivi — dans l'heure après la visite"},
    {"type":"paragraph","text":"Pour chaque personne rencontrée (intéressée ou non) :"},
    {"type":"template","text":"Bonjour [Prénom],\n\nC'est [Votre Prénom] de Next Gital — on s'est vus tout à l'heure à [Nom de l'endroit].\n\nMerci pour votre accueil ! Je me permets de vous envoyer notre site pour que vous puissiez voir nos réalisations : nextgital.tech\n\nN'hésitez pas si vous avez des questions. Bonne journée ! 🙏"},
    {"type":"callout","variant":"tip","title":"Si RDV fixé","text":"Ajouter la confirmation du RDV dans ce même message."},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de sortie terrain"},
    {"type":"checklist","items":[
      "Liste des 10 prospects préparée la veille",
      "Cartes de visite + flyers dans le sac",
      "Tenue correcte (chemise ou veste Next Gital)",
      "Téléphone chargé + GestiQ ouvert",
      "5 visites effectuées minimum par sortie",
      "GestiQ rempli immédiatement après chaque visite",
      "Message WhatsApp de suivi envoyé dans l'heure"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-prospect-terrain');


-- ── ng-prospect-linkedin (prospection) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-prospect-linkedin',
  'Prospection LinkedIn — Professionnels et entreprises',
  'B2B sur LinkedIn : optimiser le profil, identifier les décideurs, connexions personnalisées, contenu 3x/sem.',
  'prospection',
  '["LinkedIn","BtoB","Prospection","Professionnel","Message"]'::jsonb,
  'Next Gital',
  4,
  false,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"30 min par jour — le matin."},
    {"type":"callout","variant":"info","title":"Canal","text":"LinkedIn."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"10 connexions + 5 messages par jour · 2 RDV par semaine via LinkedIn."},
    {"type":"callout","variant":"warning","title":"À retenir","text":"LinkedIn fonctionne mieux pour les entreprises (B2B) : avocats, experts-comptables, agences, directeurs. Pour les petits commerçants : préférer WhatsApp et terrain."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Optimiser le profil LinkedIn Next Gital"},
    {"type":"list","items":[
      "**Photo de profil** : logo Next Gital carré (ou photo du fondateur professionnelle)",
      "**Photo de couverture** : bannière Next Gital avec tagline",
      "**Titre** : « Agence Web à Oujda | Sites WordPress · E-commerce · Publicité Digitale | 100+ entreprises aidées »",
      "**Description** : commencer par le problème du client, pas par Next Gital",
      "**Réalisations** : ajouter 3-5 projets avec captures d'écran"
    ]},
    {"type":"paragraph","text":"Exemple de description à propos : « Votre entreprise perd des clients chaque jour sans présence digitale. Next Gital construit les sites et les systèmes qui font grandir votre business — à Oujda et partout au Maroc. »"},
    {"type":"list","items":["Outil : **LinkedIn**","Temps : ~1h une seule fois","Statut : requis"]},

    {"type":"heading2","text":"2. Trouver les prospects LinkedIn chaque matin"},
    {"type":"paragraph","text":"LinkedIn → Recherche → Personnes. Filtres à utiliser :"},
    {"type":"list","items":[
      "**Lieu** : Maroc → Oujda ou région orientale",
      "**Secteur** : Médical, Juridique, Immobilier, Restauration, etc.",
      "**Poste** : Directeur, Gérant, Propriétaire, Fondateur, PDG",
      "Éviter les profils avec moins de 200 connexions ou sans photo (souvent inactifs)"
    ]},
    {"type":"list","items":["Outil : **LinkedIn**","Temps : ~15 min","Objectif : 10 nouveaux prospects/jour"]},

    {"type":"heading2","text":"3. Demandes de connexion AVEC message personnalisé"},
    {"type":"callout","variant":"warning","title":"Limite LinkedIn","text":"20 invitations par semaine (compte gratuit). Ne JAMAIS envoyer une demande sans message. Max 300 caractères."},
    {"type":"template","text":"Bonjour [Prénom],\n\nJe suis [Votre Prénom] de Next Gital, agence web à Oujda. Je travaille avec des [SECTEUR] de la région pour renforcer leur présence en ligne.\n\nJ'aimerais qu'on soit en contact. Bonne journée !"},
    {"type":"callout","variant":"danger","title":"Important","text":"NE PAS vendre dans ce premier message — juste créer la connexion."},

    {"type":"heading2","text":"4. Message de prospection — 48h après acceptation"},
    {"type":"paragraph","text":"Attendre que la personne accepte. Puis envoyer 48h après (jamais immédiatement) :"},
    {"type":"template","text":"Bonjour [Prénom],\n\nMerci d'avoir accepté ma demande !\n\nJ'ai vu que vous [DÉTAIL PRÉCIS : êtes directeur de X / travaillez dans le secteur Y / avez fondé Z].\n\nOn travaille justement avec des [SECTEUR] à Oujda pour les aider à [RÉSULTAT : être trouvés sur Google / avoir plus de clients / vendre en ligne].\n\nEst-ce que c'est quelque chose qui vous intéresse, ou est-ce que ce n'est pas une priorité en ce moment ?"},
    {"type":"callout","variant":"tip","title":"Pourquoi la question fermée","text":"Cette question fermée force une réponse claire."},

    {"type":"heading2","text":"5. Publier du contenu LinkedIn 3x par semaine"},
    {"type":"paragraph","text":"Le contenu attire les prospects vers vous — plus besoin de les chercher. 3 types de posts qui fonctionnent :"},
    {"type":"numbered","items":[
      "**Étude de cas** : avant/après un projet client avec résultats chiffrés — 200 mots + photo",
      "**Conseil pratique** : astuce sur le web, le SEO, les réseaux sociaux — liste de 5 points",
      "**Témoignage client** : copier un extrait d'un avis Google positif avec photo du projet"
    ]},
    {"type":"callout","variant":"success","title":"Créneaux à fort engagement","text":"Mardi 9h · Jeudi 9h · Vendredi 10h."},
    {"type":"list","items":["Outil : **LinkedIn**","Temps : ~20 min par post","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Checklist quotidienne"},
    {"type":"checklist","items":[
      "Profil LinkedIn Next Gital optimisé à 100%",
      "10 nouveaux prospects identifiés ce matin",
      "10 demandes de connexion personnalisées envoyées",
      "Messages envoyés aux connexions acceptées depuis 48h",
      "1 post LinkedIn publié (mardi / jeudi / vendredi)",
      "GestiQ mis à jour pour chaque prospect contacté"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-prospect-linkedin');


-- ── ng-prospect-partenariats (prospection) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-prospect-partenariats',
  'Créer un réseau de partenaires apporteurs d''affaires',
  'Identifier 5 partenaires/mois (imprimeurs, comptables, photographes), commission 500-1000 MAD, suivi mensuel.',
  'prospection',
  '["Partenariat","Réseau","ApporteurAffaires","Oujda","Commission"]'::jsonb,
  'Next Gital',
  4,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Action mensuelle — 4 à 5 partenaires par mois."},
    {"type":"callout","variant":"info","title":"Canal","text":"Terrain · WhatsApp · LinkedIn."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"10 partenaires actifs qui envoient 2-3 prospects par mois chacun = 20-30 leads gratuits."},
    {"type":"callout","variant":"success","title":"Pourquoi","text":"Les partenariats sont la source de leads la plus rentable — zéro coût publicitaire, forte confiance car recommandation. 1 partenaire bien choisi vaut 50 messages WhatsApp à froid."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Identifier les meilleurs partenaires potentiels"},
    {"type":"paragraph","text":"Les meilleurs partenaires sont ceux qui côtoient vos clients idéaux **SANS être concurrents**. Liste des profils prioritaires :"},
    {"type":"numbered","items":[
      "**Imprimeurs / Graphistes locaux** — clients ont souvent besoin d'un site après un logo",
      "**Experts-comptables** — leurs clients entreprises ont besoin de présence digitale",
      "**Consultants en création d'entreprise** — nouvelles entreprises = besoin de site",
      "**Agences de recrutement** — entreprises qui recrutent = entreprises qui grandissent",
      "**Notaires et avocats d'affaires** — clients entreprises = budget disponible",
      "**Photographes professionnels** — clients qui veulent des photos = clients qui veulent un site"
    ]},
    {"type":"list","items":["Outil : **Google Maps + LinkedIn**","Temps : ~20 min de recherche","Statut : requis"]},

    {"type":"heading2","text":"2. Le pitch partenariat — comment proposer"},
    {"type":"paragraph","text":"En personne ou par WhatsApp."},
    {"type":"template","text":"Bonjour [Prénom] 👋\n\nJe suis [Votre Prénom] de Next Gital, agence web à Oujda.\n\nOn aide les entreprises locales à créer de beaux sites web et à se développer en ligne — 100+ projets réalisés, 4.9 étoiles sur Google.\n\nJe pensais à une collaboration simple : quand un de vos clients a besoin d'un site web, vous nous le recommandez. Pour chaque client qui signe avec nous, on vous verse **500 MAD de commission** — virés dès que le client signe.\n\nÇa vous intéresse d'en discuter 15 minutes ?"},
    {"type":"callout","variant":"tip","title":"Logique","text":"500 MAD de commission = pratiquement rien pour nous, mais très motivant pour le partenaire."},

    {"type":"heading2","text":"3. Officialiser le partenariat"},
    {"type":"paragraph","text":"Une fois d'accord : créer une fiche Partenaire dans GestiQ avec nom complet, entreprise, téléphone, email, secteur, date de début. Envoyer la confirmation WhatsApp avec les termes simples."},
    {"type":"template","text":"Bonjour [Prénom] 🤝\n\nRavi qu'on s'associe ! Voici les termes de notre collaboration :\n\n✅ Vous recommandez Next Gital à vos clients qui ont besoin d'un site web\n✅ Commission : 500 MAD (site vitrine) · 1 000 MAD (e-commerce)\n✅ Paiement : par virement dans la semaine qui suit la signature\n✅ Pas de minimum · Pas d'engagement\n\nPour nous envoyer un prospect : envoyez-nous son nom + téléphone par WhatsApp en précisant que c'est de votre part.\n\nMerci [Prénom] — on ne vous décevra pas 🙏\nNext Gital · +212 620 002 066"},
    {"type":"callout","variant":"info","title":"Simplicité","text":"Garder ça simple — pas besoin d'un contrat formel pour commencer."},

    {"type":"heading2","text":"4. Maintenir la relation active — contact mensuel"},
    {"type":"paragraph","text":"Un partenaire qui n'a pas de nouvelles de vous pendant 2 mois vous oublie. Règle : contacter chaque partenaire actif une fois par mois."},
    {"type":"template","text":"Bonjour [Prénom] !\n\nJ'espère que tout va bien. Je voulais juste vous rappeler qu'on est toujours disponibles pour aider vos clients qui cherchent un site web.\n\nOn vient de finir un projet sympa pour [SECTEUR] — si vous voulez je vous montre.\n\nBon weekend ! 🙏"},
    {"type":"list","items":["Outil : **WhatsApp + GestiQ**","Temps : ~5 min par partenaire","Astuce : enregistrer le rappel mensuel dans GestiQ Alertes"]},

    {"type":"heading2","text":"5. Payer la commission rapidement — ça motive"},
    {"type":"paragraph","text":"Dès qu'un partenaire envoie un client qui signe et paye l'acompte : **virer la commission DANS LA SEMAINE**. Ne pas attendre."},
    {"type":"template","text":"Bonjour [Prénom] 😊\n\nVotre client [NOM CLIENT] vient de signer son contrat avec Next Gital — merci pour cette belle recommandation !\n\nVotre commission de [MONTANT] MAD a été virée aujourd'hui sur votre compte.\n\nOn prend très bien soin de [NOM CLIENT] — vous pouvez lui demander dans 2 semaines 😊\n\nMerci encore, et on compte sur vous pour la prochaine ! 🙏"},
    {"type":"callout","variant":"success","title":"Effet","text":"Un partenaire payé rapidement devient votre meilleur commercial."},

    {"type":"divider"},

    {"type":"heading","text":"Checklist mensuelle"},
    {"type":"checklist","items":[
      "5 partenaires potentiels identifiés ce mois",
      "Pitch partenariat envoyé aux 5 prospects",
      "2 partenariats officialisés dans GestiQ",
      "Message mensuel envoyé à tous les partenaires actifs",
      "Commissions payées dans la semaine après chaque signature"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-prospect-partenariats');


-- ── ng-prospect-pipeline (prospection) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-prospect-pipeline',
  'Suivi prospects — Pipeline de vente Next Gital',
  'Pipeline CRM : 6 statuts, règles de relance, revue hebdo du vendredi, KPIs et rapport au fondateur.',
  'prospection',
  '["Pipeline","Suivi","CRM","GestiQ","Vente"]'::jsonb,
  'Next Gital',
  4,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Chaque vendredi — revue de pipeline 30 min."},
    {"type":"callout","variant":"info","title":"Canal","text":"GestiQ CRM."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Aucun prospect ne tombe dans l'oubli · Taux de conversion prospects → clients ≥ 15%."},
    {"type":"callout","variant":"warning","title":"À retenir","text":"La plupart des ventes se font entre le 5ème et le 12ème contact. 80% des commerciaux abandonnent après 2 contacts. La différence entre un bon prospecteur et un mauvais : la persistance organisée."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Les 6 statuts du pipeline prospect dans GestiQ"},
    {"type":"paragraph","text":"Chaque prospect est dans un statut précis. Utiliser ces 6 statuts UNIQUEMENT :"},
    {"type":"numbered","items":[
      "**À contacter** — identifié mais pas encore contacté",
      "**Contacté** — premier message envoyé, en attente de réponse",
      "**Intéressé** — a répondu positivement, réunion à fixer",
      "**Réunion fixée** — date de réunion confirmée",
      "**Devis envoyé** — réunion faite, devis en attente de décision",
      "**Perdu** ou **Converti** — clôture du prospect"
    ]},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Mettre à jour le statut après CHAQUE interaction. Un statut à jour = pipeline fiable."},

    {"type":"heading2","text":"2. La règle des relances — quand et combien"},
    {"type":"table","table":{
      "headers":["Statut","Action","Délai"],
      "rows":[
        ["Contacté sans réponse","Relance unique","48h"],
        ["Intéressé mais pas de RDV","Relance pour fixer RDV","3 jours"],
        ["Réunion passée, devis non envoyé","Envoyer le devis","48h max"],
        ["Devis envoyé sans réponse","Relance unique puis fermer à J+7","3 jours"],
        ["Refus aujourd'hui","Rappel à dans 90 jours","90 jours"]
      ]
    }},
    {"type":"callout","variant":"warning","title":"Plafond","text":"Maximum 3 contacts par prospect avant de passer à « Perdu ». Jamais plus."},

    {"type":"heading2","text":"3. Revue de pipeline — chaque vendredi matin"},
    {"type":"paragraph","text":"Chaque vendredi, 30 minutes de revue. GestiQ → CRM → filtrer par statut. Traiter dans cet ordre :"},
    {"type":"numbered","items":[
      "**Devis envoyé** → relancer ceux qui n'ont pas répondu depuis 3+ jours",
      "**Réunion fixée** → préparer les réunions de la semaine prochaine",
      "**Intéressé** → fixer les RDV manquants",
      "**Contacté** → relancer ceux sans réponse depuis 48h",
      "Mettre à jour tous les statuts",
      "Préparer les **20 nouveaux prospects** pour la semaine suivante"
    ]},
    {"type":"list","items":["Outil : **GestiQ CRM**","Temps : ~30 min","Fréquence : chaque vendredi"]},

    {"type":"heading2","text":"4. Les KPIs de prospection — à mesurer chaque semaine"},
    {"type":"table","table":{
      "headers":["Métrique","Objectif hebdo"],
      "rows":[
        ["Nouveaux prospects identifiés","20"],
        ["Premiers contacts effectués","15"],
        ["Réponses reçues","5+ (≥ 30%)"],
        ["Réunions fixées","3"],
        ["Devis envoyés","2"],
        ["Contrats signés","1"]
      ]
    }},
    {"type":"callout","variant":"warning","title":"Si en dessous","text":"Si un chiffre est en dessous de l'objectif 2 semaines de suite → analyser pourquoi avec le fondateur."},

    {"type":"heading2","text":"5. Rapport hebdomadaire prospection — au fondateur"},
    {"type":"paragraph","text":"**Chaque vendredi 17h** : envoyer le rapport de prospection au fondateur par WhatsApp. Ne jamais sauter un rapport — même si la semaine est mauvaise."},
    {"type":"template","text":"📊 RAPPORT PROSPECTION — Semaine du [DATE]\n\n━━ CHIFFRES ━━\n🔍 Prospects identifiés : [X] / objectif 20\n📱 Premiers contacts : [X] / objectif 15\n💬 Réponses reçues : [X] ([X]% de taux)\n📅 Réunions fixées : [X] / objectif 3\n📄 Devis envoyés : [X] / objectif 2\n✅ Contrats signés : [X] / objectif 1\n\n━━ TOP 3 PROSPECTS CHAUDS ━━\n🔥 [NOM 1] — [SECTEUR] — Statut : [___]\n🔥 [NOM 2] — [SECTEUR] — Statut : [___]\n🔥 [NOM 3] — [SECTEUR] — Statut : [___]\n\n━━ BLOQUAGES ━━\n[Ce qui a empêché d'atteindre les objectifs]\n\n━━ PLAN SEMAINE PROCHAINE ━━\n[3 actions prioritaires]\n\n[Votre prénom] — Équipe Prospection Next Gital"},

    {"type":"divider"},

    {"type":"heading","text":"Message de réactivation — prospect « Perdu » depuis 90 jours"},
    {"type":"template","text":"Bonjour [Prénom] 👋\n\nÇa fait quelques mois qu'on s'est parlé — j'espère que tout va bien !\n\nJe voulais juste prendre des nouvelles et voir si la situation a évolué côté présence en ligne.\n\nOn a justement lancé [NOUVELLE OFFRE ou PROJET SIMILAIRE AU SIEN] récemment — je pensais à vous.\n\nPas de pression — juste un check. Bonne journée ! 🙏"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist du vendredi"},
    {"type":"checklist","items":[
      "Statuts GestiQ mis à jour après chaque interaction",
      "Revue pipeline effectuée ce vendredi matin",
      "Relances envoyées aux prospects sans réponse depuis 48h+",
      "KPIs hebdomadaires calculés et notés",
      "Rapport envoyé au fondateur ce vendredi avant 17h",
      "20 nouveaux prospects préparés pour la semaine prochaine",
      "Prospects « Perdu » depuis 90 jours remis en « À contacter »"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-prospect-pipeline');


-- ── ng-prospect-regles-objectifs (prospection) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-prospect-regles-objectifs',
  'Règles absolues & Objectifs hebdomadaires — Prospection',
  'Les 8 règles non négociables de la prospection Next Gital + le tableau des objectifs hebdo attendus.',
  'prospection',
  '["Règles","Objectifs","Discipline","Hebdo"]'::jsonb,
  'Next Gital',
  2,
  false,
  $sop$[
    {"type":"callout","variant":"danger","title":"Lecture obligatoire","text":"Ces 8 règles sont non négociables. Elles protègent la réputation de Next Gital et la santé mentale de l'équipe prospection."},

    {"type":"heading","text":"Les 8 règles absolues de la prospection"},

    {"type":"numbered","items":[
      "**Ne JAMAIS envoyer 2 messages non sollicités d'affilée** — attendre 48h entre les contacts.",
      "**Ne JAMAIS donner de prix par WhatsApp** — toujours proposer une réunion pour cadrer le besoin.",
      "**Ne JAMAIS relancer plus de 2 fois** un prospect qui ne répond pas — passer à « Perdu » et rappeler à 90 jours.",
      "**TOUJOURS mettre à jour GestiQ** après chaque contact — un statut à jour vaut plus qu'une réunion.",
      "**TOUJOURS envoyer le rapport vendredi avant 17h** — même si la semaine est mauvaise.",
      "**Ne JAMAIS promettre des résultats publicitaires** au prospect — vendre la compétence, pas un résultat.",
      "**Respecter les horaires de contact** : 9h–12h et 15h–18h en semaine uniquement. Jamais le weekend.",
      "**Si un prospect devient agressif** → stopper le contact et informer le fondateur immédiatement."
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Objectifs hebdomadaires — ce que le fondateur attend"},
    {"type":"table","table":{
      "headers":["Métrique","Objectif semaine"],
      "rows":[
        ["Prospects identifiés","20"],
        ["Messages WhatsApp envoyés","15"],
        ["Sorties terrain","2 (mardi + jeudi)"],
        ["Connexions LinkedIn","10"],
        ["Réunions fixées","3"],
        ["Devis envoyés (avec Chef de projet)","2"],
        ["Contrat signé","1 minimum"]
      ]
    }},

    {"type":"divider"},

    {"type":"heading","text":"Temps & blocage"},
    {"type":"callout","variant":"warning","title":"Règle des 20 min","text":"Si bloqué plus de 20 min sur un point de procédure → stopper et appeler le fondateur (+212 620 002 066). Ne pas modifier l'existant. Ne pas perdre 2h sur un détail."},

    {"type":"heading","text":"Contact référent"},
    {"type":"list","items":[
      "📞 **+212 620 002 066** — fondateur Next Gital",
      "✉️ **info@nextgital.com** — email général",
      "🏢 **4ème étage, Bureau N°7, Immeuble Kissi, Oujda**"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Checklist du nouvel arrivant"},
    {"type":"checklist","items":[
      "Les 8 règles absolues lues et comprises",
      "Tableau d'objectifs hebdomadaires connu par cœur",
      "Numéro du fondateur enregistré",
      "Profil LinkedIn Next Gital étudié",
      "Premiers 5 prospects identifiés dans GestiQ",
      "Premier message WhatsApp envoyé"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-prospect-regles-objectifs');

COMMIT;
