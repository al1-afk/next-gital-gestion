-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 037 : Seed des 6 SOPs « Support Client »
--  Date : 2026-05-17
--
--  Catégorie : support · Auteur : Next Gital · Idempotent
--  Périmètre : Système de tickets · Support WordPress · Scope creep
--              Avis Google 4.9★ · Formation client · Reporting mensuel
--  Insère pour TOUS les tenants existants.
--
--  Conformité ARCHITECTURE_TENANT.md :
--    - tenant_id NOT NULL, contrôle d'existence par (tenant_id, slug)
--    - RLS déjà actif sur public.sops (migration 025)
--    - Pas de modification de la structure existante
--    - Catégorie « support » déjà présente dans SOP.tsx (label « Support Client »)
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ── ng-sup-tickets (support) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-sup-tickets',
  'Système de tickets — traiter chaque demande de A à Z',
  '5 niveaux de priorité (Critique/Urgent/Normal/Faible/Info), ouverture immédiate dans GestiQ, investigation avant promesse, communication à chaque étape, clôture documentée.',
  'support',
  '["Ticket","SAV","Support","Réclamation","Suivi"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Dès réception d'une demande — réponse sous 1h max."},
    {"type":"callout","variant":"info","title":"Canal","text":"WhatsApp · Email · GestiQ Tickets."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"100% des tickets traités · Zéro demande oubliée · Client informé à chaque étape."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Chaque demande client est un ticket. Même un simple « comment je change mon texte » est un ticket. Tout doit être tracé dans GestiQ — sinon ça se perd. Un ticket non tracé = un client qui relance = une mauvaise image."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Les 5 niveaux de priorité des tickets"},
    {"type":"list","items":[
      "🔴 **CRITIQUE** — répondre en moins de 1h, résoudre en moins de 4h : site complètement en panne, boutique e-commerce hors ligne, formulaire de contact cassé, page blanche",
      "🟠 **URGENT** — répondre en 2h, résoudre en 24h : problème d'affichage mobile, bug sur une page importante, email qui n'arrive pas",
      "🟡 **NORMAL** — répondre en 4h, résoudre en 48h : modification de contenu (texte, photo), ajout d'un élément simple",
      "🟢 **FAIBLE** — répondre en 24h, résoudre en 72h : question d'utilisation, conseil sur le contenu",
      "⚪ **INFO** — traiter dans la semaine : demande de renseignement, future évolution souhaitée"
    ]},
    {"type":"list","items":["Outil : **GestiQ Tickets**","Temps : à mémoriser","Statut : requis"]},

    {"type":"heading2","text":"2. Ouvrir un ticket dans GestiQ à chaque demande"},
    {"type":"paragraph","text":"Dès réception d'une demande (WhatsApp, email, appel) : ouvrir GestiQ → Tickets → Nouveau ticket. Renseigner :"},
    {"type":"list","items":[
      "Client concerné (lier à la fiche CRM)",
      "Canal de réception (WhatsApp / Email / Appel)",
      "Description exacte du problème (copier le message du client)",
      "Priorité (1 à 5)",
      "Assigné à (soi-même ou technicien)",
      "Deadline de résolution selon le niveau de priorité"
    ]},
    {"type":"callout","variant":"danger","title":"Règle","text":"Envoyer l'accusé de réception au client immédiatement. Ne jamais laisser une demande sans accusé de réception, même si la résolution prend du temps."},
    {"type":"list","items":["Outil : **GestiQ Tickets**","Temps : ~3 min par ticket","Statut : requis"]},

    {"type":"heading2","text":"3. Investiguer avant de répondre sur la solution"},
    {"type":"paragraph","text":"Avant de dire « c'est réglé » ou « c'est impossible » :"},
    {"type":"list","items":[
      "Vérifier la fiche du projet dans GestiQ (qu'est-ce qui a été livré ? qu'est-ce qui est dans le scope ?)",
      "Reproduire le problème soi-même (voir ce que voit le client)",
      "Identifier la cause (hébergement, plugin, code, contenu)",
      "Si problème technique → contacter le Développeur en interne",
      "Si demande hors scope → voir SOP « Scope creep »"
    ]},
    {"type":"callout","variant":"warning","title":"Important","text":"Ne jamais promettre une résolution sans avoir investigué."},
    {"type":"list","items":["Outil : **GestiQ + Site client**","Temps : ~5-15 min","Statut : requis"]},

    {"type":"heading2","text":"4. Communiquer à chaque étape — le client ne doit jamais se demander où en est son ticket"},
    {"type":"list","items":[
      "**Ouverture du ticket** → accusé de réception immédiat",
      "**Après investigation** (max 2h) → message avec cause identifiée et délai de résolution",
      "**Pendant la résolution** (si > 4h) → update intermédiaire",
      "**À la résolution** → message de clôture avec explication de ce qui a été fait",
      "**24h après** → message de suivi pour confirmer que tout fonctionne"
    ]},
    {"type":"callout","variant":"success","title":"Pourquoi","text":"Un client qui doit relancer pour avoir des nouvelles est un client qui part."},
    {"type":"list","items":["Outil : **WhatsApp · Email**","Temps : ~2 min par update","Statut : requis"]},

    {"type":"heading2","text":"5. Fermer le ticket dans GestiQ"},
    {"type":"paragraph","text":"Quand le problème est résolu et que le client a confirmé que tout va bien : GestiQ → Ticket → statut « Résolu »."},
    {"type":"paragraph","text":"Renseigner :"},
    {"type":"list","items":[
      "Solution appliquée (description technique de ce qui a été fait)",
      "Temps passé",
      "Cause du problème (pour statistiques et amélioration)",
      "Si erreur Next Gital → noter pour améliorer les processus",
      "Si erreur client (mauvaise manipulation) → noter pour améliorer la formation à la livraison"
    ]},
    {"type":"list","items":["Outil : **GestiQ Tickets**","Temps : ~3 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Accusé de réception ticket — message immédiat au client"},
    {"type":"template","text":"Bonjour [Prénom] 👋\n\nMerci de nous avoir contactés. J'ai bien pris note de votre problème concernant [DESCRIPTION COURTE DU PROBLÈME].\n\nNous traitons votre demande en priorité [NIVEAU : urgente / normale] et je reviens vers vous avec une solution avant [DÉLAI PRÉCIS : ex : 15h aujourd'hui / demain matin].\n\nSi la situation s'aggrave d'ici là, n'hésitez pas à me recontacter directement.\n\n[Votre prénom] · Next Gital · +212 620 002 066"},

    {"type":"heading","text":"Message de clôture ticket — problème résolu"},
    {"type":"template","text":"Bonjour [Prénom] ✅\n\nBonne nouvelle — le problème [DESCRIPTION] est maintenant résolu.\n\nCe qui a été fait : [EXPLICATION SIMPLE EN 1-2 LIGNES, sans jargon technique].\n\nVous pouvez vérifier sur [URL] que tout fonctionne correctement.\n\nN'hésitez pas si vous avez d'autres questions. 🙏\n\nNext Gital · +212 620 002 066"},

    {"type":"heading","text":"Message de suivi J+1 après résolution"},
    {"type":"template","text":"Bonjour [Prénom] 😊\n\nJuste un petit suivi pour m'assurer que tout fonctionne bien depuis hier.\n\nLe site fonctionne correctement de votre côté ?\n\nBonne journée ! 🙏"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Ticket ouvert dans GestiQ dès réception de la demande",
      "Priorité attribuée (Critique / Urgent / Normal / Faible / Info)",
      "Accusé de réception envoyé au client dans les 5 minutes",
      "Investigation effectuée avant promesse de solution",
      "Client informé à chaque étape (ouverture, investigation, résolution)",
      "Ticket fermé dans GestiQ avec solution documentée",
      "Suivi J+1 envoyé pour confirmer que tout va bien"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-sup-tickets');


-- ── ng-sup-wordpress-fixes (support) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-sup-wordpress-fixes',
  'Support technique WordPress — les 10 problèmes les plus fréquents',
  'Résoudre 80% des problèmes courants sans le Développeur : page blanche, login wp-admin, site lent, formulaire HS, Elementor cassé, piratage, expiration domaine/hébergement.',
  'support',
  '["WordPress","Technique","Bug","Support","Résolution"]'::jsonb,
  'Next Gital',
  8,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Selon la priorité du ticket — Critique < 4h · Urgent < 24h."},
    {"type":"callout","variant":"info","title":"Canal","text":"hPanel Hostinger · WordPress Admin · WP-CLI."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Résoudre 80% des problèmes techniques sans faire appel au Développeur."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Le Support Client doit pouvoir résoudre les problèmes courants seul. Si le problème est complexe (base de données, code, bug plugin critique) → escalader immédiatement au Développeur avec le maximum d'informations collectées."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. PROBLÈME 1 — Site en page blanche (White Screen of Death)"},
    {"type":"paragraph","text":"Cause la plus fréquente : plugin incompatible ou mise à jour WordPress ratée. Solution étape par étape :"},
    {"type":"numbered","items":[
      "hPanel → File Manager → wp-content → plugins → renommer le dossier du dernier plugin installé (ex : « elementor » → « elementor_OFF »). Si le site revient → ce plugin est la cause → le désactiver proprement depuis wp-admin",
      "Si toujours blanc : renommer TOUS les dossiers plugins → tester → réactiver un par un",
      "Si toujours blanc après désactivation de tous les plugins → escalader au Développeur immédiatement"
    ]},
    {"type":"list","items":["Outil : **hPanel File Manager**","Temps : ~15-30 min","Statut : requis"]},

    {"type":"heading2","text":"2. PROBLÈME 2 — Le client ne peut pas se connecter au wp-admin"},
    {"type":"paragraph","text":"Solutions dans l'ordre :"},
    {"type":"numbered","items":[
      "Vérifier l'URL correcte : nomdusite.com/wp-admin (pas /wordpress/wp-admin)",
      "Réinitialiser le mot de passe via « Mot de passe oublié » → email reçu ? Si non, le SMTP ne fonctionne pas → voir Problème 4",
      "Réinitialiser via hPanel → Bases de données → phpMyAdmin → table wp_users → modifier user_pass avec un hash MD5 d'un nouveau mot de passe",
      "Créer un nouveau compte admin via WP-CLI si accès SSH disponible"
    ]},
    {"type":"list","items":["Outil : **hPanel · phpMyAdmin**","Temps : ~10-20 min","Statut : requis"]},

    {"type":"heading2","text":"3. PROBLÈME 3 — Site lent (temps de chargement > 3 secondes)"},
    {"type":"paragraph","text":"Diagnostic : tester sur GTmetrix.com → identifier ce qui ralentit. Solutions courantes :"},
    {"type":"numbered","items":[
      "**Cache** : LiteSpeed Cache ou WP Rocket → vider complètement le cache → tester",
      "**Images** : identifier les images > 500 Ko → les compresser avec Smush ou Imagify",
      "**Plugins** : désactiver les plugins non utilisés",
      "**Hébergement** : vérifier dans hPanel si le quota de ressources est atteint → informer le fondateur pour upgrade si nécessaire"
    ]},
    {"type":"list","items":["Outil : **GTmetrix · LiteSpeed Cache · hPanel**","Temps : ~30-60 min","Statut : requis"]},

    {"type":"heading2","text":"4. PROBLÈME 4 — Le formulaire de contact n'envoie pas les emails"},
    {"type":"paragraph","text":"Cause fréquente : WP Mail SMTP mal configuré ou serveur mail bloqué."},
    {"type":"numbered","items":[
      "WordPress Admin → WP Mail SMTP → Send Test Email → noter l'erreur exacte",
      "Vérifier les paramètres Titan Email : Host = mail.titan.email, Port = 587, TLS, username = email@domaineclient.com, mot de passe correct",
      "Si erreur d'authentification : vérifier le mot de passe Titan Email dans hPanel",
      "Si Port 587 bloqué par l'hébergeur : tester Port 465 avec SSL",
      "Vérifier que l'email de destination n'est pas en spam"
    ]},
    {"type":"list","items":["Outil : **WP Mail SMTP · hPanel · Titan Email**","Temps : ~20-30 min","Statut : requis"]},

    {"type":"heading2","text":"5. PROBLÈME 5 — Le client a cassé son site en modifiant Elementor"},
    {"type":"paragraph","text":"Le client a supprimé ou modifié quelque chose par erreur dans Elementor."},
    {"type":"numbered","items":[
      "Elementor → Historique (icône horloge dans l'éditeur) → restaurer la version précédente",
      "Si pas d'historique disponible : restaurer depuis UpdraftPlus → sauvegardes → restaurer la dernière version avant l'incident",
      "Si aucune sauvegarde : reconstruire manuellement la section"
    ]},
    {"type":"callout","variant":"warning","title":"Préventif","text":"Vérifier qu'UpdraftPlus est bien configuré (sauvegarde quotidienne). Former le client sur ce qu'il peut modifier seul et ce qu'il ne doit pas toucher."},
    {"type":"list","items":["Outil : **Elementor Historique · UpdraftPlus**","Temps : ~15-45 min selon gravité","Statut : requis"]},

    {"type":"heading2","text":"6. PROBLÈME 6 — Site piraté (contenu spam, redirections malveillantes)"},
    {"type":"callout","variant":"danger","title":"CRITIQUE","text":"Agir immédiatement."},
    {"type":"numbered","items":[
      "Mettre le site en mode maintenance (plugin Maintenance Mode)",
      "Changer **TOUS** les mots de passe : WordPress admin, FTP, hPanel, base de données",
      "Wordfence → Scan → laisser tourner → noter les fichiers infectés",
      "Supprimer les fichiers infectés identifiés par Wordfence",
      "Mettre à jour WordPress + tous les plugins + le thème",
      "Restaurer depuis une sauvegarde UpdraftPlus propre (avant l'infection)",
      "Informer immédiatement le fondateur",
      "Informer le client avec transparence"
    ]},
    {"type":"list","items":["Outil : **Wordfence · UpdraftPlus · hPanel**","Temps : ~2-4h","Statut : requis (escalader au Développeur si infection profonde)"]},

    {"type":"heading2","text":"7. PROBLÈME 7 — Le domaine ou l'hébergement a expiré"},
    {"type":"paragraph","text":"GestiQ → Gestion Web → vérifier les dates d'expiration."},
    {"type":"list","items":[
      "Domaine expiré → hPanel → Domaines → Renouveler",
      "Hébergement expiré → hPanel → Plan → Renouveler",
      "AVANT l'expiration : GestiQ doit avoir envoyé une alerte 30 jours avant",
      "Si le client paie son propre hébergement : l'appeler immédiatement pour qu'il renouvelle",
      "Si Next Gital gère l'hébergement : avancer le paiement et refacturer le client"
    ]},
    {"type":"callout","variant":"danger","title":"Règle","text":"Ne jamais laisser un site client tomber pour expiration — c'est une faute grave."},
    {"type":"list","items":["Outil : **hPanel · GestiQ Gestion Web**","Temps : ~10-20 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Message escalade au Développeur — ticket technique complexe"},
    {"type":"template","text":"🔴 ESCALADE TECHNIQUE — [NOM CLIENT]\n\nProblème : [DESCRIPTION PRÉCISE]\nPriorité : [CRITIQUE / URGENT]\nDepuis quand : [HEURE / DATE]\n\nCe que j'ai déjà essayé :\n1. [ACTION 1 — résultat]\n2. [ACTION 2 — résultat]\n3. [ACTION 3 — résultat]\n\nErreur exacte affichée : [COPIER L'ERREUR]\nURL du site : [URL]\nAccès wp-admin : [URL] — ID : [__] MDP : [voir GestiQ]\n\nLe client attend une réponse avant [HEURE]. Merci 🙏"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Problème reproduit et identifié avant toute intervention",
      "Sauvegarde effectuée avant toute modification technique",
      "Solution testée sur staging si possible avant production",
      "Client informé pendant l'intervention si > 30 min",
      "Solution documentée dans le ticket GestiQ",
      "Escalade au Développeur si problème complexe — avec toutes les infos"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-sup-wordpress-fixes');


-- ── ng-sup-scope-creep (support) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-sup-scope-creep',
  'Gérer les demandes hors contrat — scope creep',
  'Identifier scope vs hors scope, catégoriser A/B/C/D, répondre « oui avec devis », proposer un contrat de maintenance aux clients récurrents.',
  'support',
  '["ScopeCreep","HorsContrat","Devis","Avenant","Limites"]'::jsonb,
  'Next Gital',
  4,
  false,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Dès qu'une demande dépasse le scope du contrat signé."},
    {"type":"callout","variant":"info","title":"Canal","text":"WhatsApp · Email · GestiQ."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Protéger les marges de Next Gital · Transformer le scope creep en opportunité commerciale."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Le scope creep est la cause numéro 1 de perte de rentabilité dans les agences web. Un client qui demande « juste une petite chose » toutes les semaines consomme des heures non facturées. La règle : gentil mais ferme. On dit oui à tout — mais avec un devis."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Identifier si la demande est dans ou hors contrat"},
    {"type":"paragraph","text":"Avant de répondre : ouvrir GestiQ → fiche client → contrat signé. Vérifier le scope exact :"},
    {"type":"list","items":[
      "Nombre de pages livrées",
      "Fonctionnalités incluses",
      "Nombre de révisions utilisées (3 incluses)",
      "Période de support (1 an inclus)"
    ]},
    {"type":"list","items":[
      "Si la demande est dans le scope ET dans la période de support → traiter normalement",
      "Si la demande est hors scope OU si les 3 révisions gratuites sont épuisées → suite de cette SOP",
      "Si le support 1 an est terminé → proposer un contrat de maintenance"
    ]},
    {"type":"list","items":["Outil : **GestiQ Contrat**","Temps : ~3 min","Statut : requis"]},

    {"type":"heading2","text":"2. Catégoriser la demande hors contrat"},
    {"type":"list","items":[
      "**CATÉGORIE A** — Petite demande (< 30 min) : modification de texte, changement d'image, ajout d'un lien. → Faire gracieusement SI c'est la première fois. Mentionner diplomatiquement que c'est un geste commercial",
      "**CATÉGORIE B** — Demande moyenne (30 min à 2h) : nouvelle section sur une page, modification de design, ajout d'un formulaire. → Proposer un mini-avenant à 200-500 MAD",
      "**CATÉGORIE C** — Demande importante (> 2h ou nouvelle fonctionnalité) : nouvelle page, nouvelle fonctionnalité, refonte d'une section. → Établir un devis complet",
      "**CATÉGORIE D** — Demande récurrente (le client demande régulièrement des petites choses) → Proposer un contrat de maintenance mensuel"
    ]},
    {"type":"list","items":["Outil : **Analyse + GestiQ**","Temps : ~2 min","Statut : requis"]},

    {"type":"heading2","text":"3. Répondre diplomatiquement sans dire non"},
    {"type":"callout","variant":"danger","title":"Règle d'or","text":"Ne JAMAIS dire « non » ou « ce n'est pas dans le contrat ». Dire toujours « oui, avec un devis »."},
    {"type":"paragraph","text":"Script : « Bonjour [Prénom], avec plaisir pour [DEMANDE] ! Cette modification n'est pas incluse dans votre forfait initial, mais je peux vous préparer un devis pour ça. Je vous reviens dans les 24h avec le tarif. Ça vous convient ? »"},
    {"type":"paragraph","text":"Cette approche :"},
    {"type":"list","items":[
      "Ne crée pas de conflit",
      "Transforme une demande en opportunité commerciale",
      "Établit clairement que les extras sont payants"
    ]},
    {"type":"list","items":["Outil : **WhatsApp · Email**","Temps : ~2 min","Statut : requis"]},

    {"type":"heading2","text":"4. Proposer le contrat de maintenance pour les clients récurrents"},
    {"type":"paragraph","text":"Si un client envoie plus de 2-3 demandes par mois : c'est le signal pour proposer la maintenance."},
    {"type":"callout","variant":"success","title":"Gagnant-gagnant","text":"Le client reçoit un service régulier, Next Gital reçoit un revenu récurrent."},
    {"type":"list","items":["Outil : **WhatsApp · GestiQ**","Temps : ~5 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Réponse demande hors contrat — diplomatique"},
    {"type":"template","text":"Bonjour [Prénom] 😊\n\nMerci pour votre message ! Je vais m'en occuper.\n\n[DEMANDE] n'est pas inclus dans votre forfait initial, mais c'est tout à fait réalisable.\n\nJe vous prépare un devis rapide et je vous reviens avant [DÉLAI].\n\nEn attendant, si vous avez d'autres modifications souhaitées, n'hésitez pas à me les lister — je ferai un devis groupé, c'est souvent plus économique. 🙏"},

    {"type":"heading","text":"Proposition contrat maintenance — client récurrent"},
    {"type":"template","text":"Bonjour [Prénom] 😊\n\nJe voulais vous proposer quelque chose qui pourrait vous simplifier la vie.\n\nJe vois que vous avez régulièrement de petites modifications à faire sur votre site — c'est tout à fait normal pour un site actif !\n\nPlutôt que de facturer chaque petite modification séparément, on a un forfait maintenance mensuel :\n\n🔧 Forfait Maintenance Basic — 500 MAD/mois\n✅ Mises à jour WordPress + plugins\n✅ Sauvegarde hebdomadaire\n✅ 1h de modifications contenu/mois\n✅ Support prioritaire\n\n📈 Forfait Maintenance Pro — 1 000 MAD/mois\n✅ Tout le Basic\n✅ Modifications contenu illimitées\n✅ Rapport mensuel de performance\n\nSans engagement — vous pouvez arrêter quand vous voulez.\n\nÇa vous intéresse qu'on en discute ? 🙏"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Contrat signé vérifié dans GestiQ avant de répondre",
      "Demande catégorisée (A / B / C / D)",
      "Jamais « non » — toujours « oui avec devis »",
      "Devis envoyé dans les 24h pour les catégories B et C",
      "Maintenance proposée si plus de 3 demandes/mois",
      "Ticket fermé dans GestiQ avec statut et décision notée"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-sup-scope-creep');


-- ── ng-sup-avis-google (support) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-sup-avis-google',
  'Obtenir et gérer les avis Google — maintenir le 4.9★',
  'Demande J+2 après livraison, lien direct, réponse à 100% des avis, campagne trimestrielle de rattrapage. Objectif : 100 avis 4.9★.',
  'support',
  '["AvisGoogle","Réputation","4.9étoiles","GoogleMaps","Témoignages"]'::jsonb,
  'Next Gital',
  4,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"J+2 après chaque livraison · Mensuel pour les clients existants."},
    {"type":"callout","variant":"info","title":"Canal","text":"WhatsApp · Google Business Profile."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Atteindre 100 avis 4.9★ · Chaque client livré = 1 avis demandé."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Les avis Google sont l'actif le plus précieux de Next Gital. Actuellement 4.9★ sur 67 avis. Objectif : 100 avis. Demander à CHAQUE client livré, au bon moment (J+2), avec le bon message. Ne jamais demander pendant le projet — le client n'est pas encore au maximum de sa satisfaction."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Le bon moment pour demander un avis Google"},
    {"type":"paragraph","text":"Timing optimal : **J+2 après la mise en ligne du site**. Pourquoi J+2 ?"},
    {"type":"list","items":[
      "**J+0** (jour de livraison) : le client est content mais encore dans l'émotion",
      "**J+1** : il commence à explorer son site, découvrir les fonctionnalités",
      "**J+2** : il a montré son site à des proches, reçu les premiers compliments — il est au pic de satisfaction",
      "**J+3 et après** : l'enthousiasme retombe progressivement"
    ]},
    {"type":"callout","variant":"warning","title":"Important","text":"Ne jamais demander pendant les révisions ou si un problème est en cours de résolution."},
    {"type":"list","items":["Outil : **GestiQ Alertes + WhatsApp**","Temps : ~2 min","Statut : requis"]},

    {"type":"heading2","text":"2. Configurer le rappel automatique J+2 dans GestiQ"},
    {"type":"paragraph","text":"Quand un projet passe au statut « Livré » dans GestiQ : créer automatiquement une tâche « Demander avis Google » avec deadline à J+2. Cette tâche apparaît dans le tableau de bord du Support Client chaque matin."},
    {"type":"callout","variant":"success","title":"Pourquoi","text":"Ne jamais oublier un client — le système GestiQ gère le suivi. Si J+2 tombe un weekend : envoyer le lundi matin."},
    {"type":"list","items":["Outil : **GestiQ Alertes**","Temps : automatique","Statut : requis"]},

    {"type":"heading2","text":"3. Créer le lien Google Review direct pour Next Gital"},
    {"type":"paragraph","text":"Lien à utiliser dans tous les messages de demande d'avis :"},
    {"type":"numbered","items":[
      "Aller sur Google Maps",
      "Chercher « Next Gital Oujda »",
      "Cliquer « Laisser un avis »",
      "Copier l'URL de la fenêtre pop-up"
    ]},
    {"type":"paragraph","text":"Ce lien ouvre directement la fenêtre de notation — le client n'a pas à chercher. Mettre ce lien dans GestiQ → Paramètres → Lien Google Review. Ce lien est fixe et s'utilise dans tous les messages de demande d'avis."},
    {"type":"list","items":["Outil : **Google Maps · GestiQ**","Temps : ~5 min (une seule fois)","Statut : requis"]},

    {"type":"heading2","text":"4. Répondre à CHAQUE avis — positif et négatif"},
    {"type":"paragraph","text":"Répondre à tous les avis dans les 24h :"},
    {"type":"list","items":[
      "**Avis 5 étoiles positif** → réponse personnalisée (utiliser le prénom, mentionner le projet ou secteur, remercier sincèrement, inviter à revenir)",
      "**Avis 4 étoiles ou moins** → traiter avec une grande attention (voir SOP commentaires négatifs)",
      "**Avis sans texte** (juste des étoiles) → répondre quand même avec une phrase de remerciement et l'invitation à revenir"
    ]},
    {"type":"callout","variant":"warning","title":"Attention","text":"Ne pas copier-coller la même réponse — Google pénalise les réponses génériques."},
    {"type":"list","items":["Outil : **Google Business Profile**","Temps : ~3 min par réponse","Statut : requis"]},

    {"type":"heading2","text":"5. Campagne de rattrapage — clients livrés sans avis"},
    {"type":"paragraph","text":"Une fois par trimestre :"},
    {"type":"numbered","items":[
      "Exporter la liste de tous les clients livrés depuis GestiQ",
      "Identifier ceux qui n'ont pas laissé d'avis",
      "Envoyer le message de relance (1 seule fois par client historique)"
    ]},
    {"type":"callout","variant":"success","title":"Impact","text":"Permet de récupérer des avis de clients satisfaits qui n'avaient pas pensé à le faire."},
    {"type":"list","items":["Outil : **GestiQ · WhatsApp**","Temps : ~1h par trimestre","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Demande d'avis Google — J+2 après livraison"},
    {"type":"template","text":"Bonjour [Prénom] 😊\n\nJ'espère que votre site vous plaît et que vous avez reçu les premiers retours de vos proches !\n\nSi vous êtes satisfait de notre travail, un avis Google nous aiderait énormément — ça prend moins d'une minute :\n\n⭐ Laisser un avis : [LIEN GOOGLE REVIEW DIRECT]\n\nVotre témoignage aide d'autres entrepreneurs à faire confiance à Next Gital. C'est le plus beau remerciement pour notre équipe 🙏\n\n[Votre prénom] · Next Gital"},

    {"type":"heading","text":"Relance avis Google — client historique (campagne trimestrielle)"},
    {"type":"template","text":"Bonjour [Prénom] 👋\n\nComment se passe votre site depuis la livraison ? J'espère qu'il vous apporte de bons résultats !\n\nSi vous n'avez pas encore eu le temps, un avis Google de votre part nous ferait vraiment plaisir — votre témoignage compte beaucoup :\n\n⭐ [LIEN GOOGLE REVIEW]\n\nMerci d'avance et bonne continuation ! 🙏"},

    {"type":"heading","text":"Réponse à un avis 5 étoiles positif"},
    {"type":"template","text":"Merci infiniment [Prénom] pour cet avis 🙏\n\nC'était un vrai plaisir de travailler sur le projet de [NOM DE SON ENTREPRISE ou SECTEUR]. On est ravis que le résultat soit à la hauteur de vos attentes.\n\nN'hésitez pas à nous contacter si vous avez besoin de quoi que ce soit — on reste à votre disposition !\n\nL'équipe Next Gital · Oujda ⭐"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Alerte GestiQ J+2 configurée à chaque livraison",
      "Message de demande d'avis envoyé exactement à J+2",
      "Lien Google Review direct utilisé (pas la page d'accueil Google Maps)",
      "100% des avis reçus répondus dans les 24h",
      "Réponses personnalisées — jamais copiées-collées",
      "Campagne rattrapage lancée une fois par trimestre"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-sup-avis-google');


-- ── ng-sup-formation-client (support) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-sup-formation-client',
  'Former le client à gérer son site WordPress',
  'Kit de formation (vidéo Loom 5-8 min + guide PDF + fiche accès), session live 15 min optionnelle, expliquer ce qu''il ne faut PAS toucher.',
  'support',
  '["Formation","Client","WordPress","Autonomie","Tutoriel"]'::jsonb,
  'Next Gital',
  4,
  false,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"À la livraison de chaque projet."},
    {"type":"callout","variant":"info","title":"Canal","text":"Loom · WhatsApp · Bureau Next Gital."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Client autonome pour les modifications simples · Réduction de 50% des tickets de niveau faible."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Un client formé est un client qui pose moins de questions basiques, qui est plus satisfait, et qui revient pour les projets complexes. La formation à la livraison évite des dizaines de tickets « comment je change mon texte » pendant l'année de support."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Préparer le kit de formation avant la livraison"},
    {"type":"paragraph","text":"Avant de livrer un projet : créer **3 ressources** de formation."},
    {"type":"numbered","items":[
      "**Vidéo Loom de 5-8 minutes** : enregistrer l'écran en montrant les actions principales dans wp-admin",
      "**Guide PDF de 2-3 pages** : captures d'écran annotées des actions les plus fréquentes",
      "**Fiche récapitulative des accès** : URL wp-admin, identifiant, mot de passe, URL hPanel, contacts Next Gital"
    ]},
    {"type":"paragraph","text":"Ces 3 ressources sont dans le dossier Drive → 05_Livraison → Formation."},
    {"type":"list","items":["Outil : **Loom · Canva · Google Drive**","Temps : ~45 min à 1h","Statut : requis"]},

    {"type":"heading2","text":"2. Contenu de la vidéo Loom de formation"},
    {"type":"paragraph","text":"La vidéo doit couvrir ces 6 actions dans l'ordre :"},
    {"type":"numbered","items":[
      "Comment se connecter à wp-admin (URL + identifiant)",
      "Comment modifier un texte sur une page (avec Elementor)",
      "Comment changer une image",
      "Comment voir et répondre aux messages du formulaire de contact",
      "Ce qu'il NE FAUT PAS toucher (thème, plugins critiques, base de données)",
      "Comment nous contacter si problème (WhatsApp Next Gital)"
    ]},
    {"type":"callout","variant":"tip","title":"Ton","text":"Décontracté, pas technique, parler comme à quelqu'un qui n'y connaît rien."},
    {"type":"list","items":["Outil : **Loom**","Temps : 5-8 min de vidéo","Statut : requis"]},

    {"type":"heading2","text":"3. Session de formation live (optionnel — 15 min)"},
    {"type":"paragraph","text":"Pour les clients qui le souhaitent : proposer une session de formation en direct de 15 min via Google Meet ou au bureau. Le client partage son écran et manipule lui-même sous la supervision du Support."},
    {"type":"paragraph","text":"Cette session live est incluse dans tous les projets. Avantages :"},
    {"type":"list","items":[
      "Le client apprend en faisant, pas juste en regardant",
      "Questions en temps réel",
      "Relation de confiance renforcée"
    ]},
    {"type":"paragraph","text":"Planifier via Calendly."},
    {"type":"list","items":["Outil : **Google Meet · Calendly**","Temps : 15 min","Statut : recommandé"]},

    {"type":"heading2","text":"4. Les choses à NE PAS faire sur son site — expliquer clairement"},
    {"type":"paragraph","text":"Expliquer au client ce qu'il ne doit absolument pas faire seul :"},
    {"type":"list","items":[
      "Ne pas mettre à jour WordPress ou les plugins seul (risque de casser le site)",
      "Ne pas supprimer de plugins sans demander",
      "Ne pas toucher aux fichiers PHP ou aux réglages avancés d'Elementor",
      "Ne pas installer de plugins non vérifiés depuis des sources inconnues",
      "Si doute → appeler Next Gital avant de faire"
    ]},
    {"type":"callout","variant":"success","title":"Impact","text":"Cette explication préventive évite 60% des bugs post-livraison."},
    {"type":"list","items":["Outil : **Conversation + Guide PDF**","Temps : ~5 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Message livraison du kit de formation"},
    {"type":"template","text":"Bonjour [Prénom] 😊\n\nVotre site est en ligne — et on vous a préparé tout ce qu'il faut pour le gérer facilement !\n\n📁 Votre dossier complet : [LIEN DRIVE]\n\nDedans vous trouverez :\n🎥 Vidéo tuto (8 min) — gérer votre site pas à pas\n📘 Guide PDF illustré — les actions fréquentes\n🔐 Fiche accès — tous vos identifiants\n\nSi vous souhaitez qu'on fasse une session rapide de 15 min ensemble pour que vous soyez 100% à l'aise — dites-le moi et on fixe ça sur [LIEN CALENDLY].\n\nBonne aventure avec votre nouveau site ! 🚀\nNext Gital · +212 620 002 066"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Vidéo Loom de 5-8 min enregistrée et uploadée sur Drive",
      "Guide PDF 2-3 pages créé avec captures annotées",
      "Fiche accès complète préparée (wp-admin + hPanel + contacts)",
      "Les 3 ressources dans le bon dossier Drive",
      "Session live de 15 min proposée au client",
      "Ce qu'il ne faut pas toucher expliqué clairement"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-sup-formation-client');


-- ── ng-sup-rapport-mensuel (support) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-sup-rapport-mensuel',
  'Reporting support mensuel — analyser et améliorer',
  'Collecte des KPIs tickets, identification des problèmes récurrents, actions correctives, rapport WhatsApp au fondateur le 1er du mois avant 10h.',
  'support',
  '["Reporting","KPIs","Amélioration","Qualité","Mensuel"]'::jsonb,
  'Next Gital',
  4,
  false,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Le 1er du mois — avant 10h."},
    {"type":"callout","variant":"info","title":"Canal","text":"GestiQ · WhatsApp Fondateur."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Réduire le nombre de tickets de 10% chaque mois · Satisfaction client ≥ 9/10."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Le meilleur support est celui qu'on n'a pas besoin d'utiliser. Si les mêmes problèmes reviennent chaque mois, il faut corriger la cause à la source (meilleure formation, meilleur processus de livraison, meilleure documentation). Le rapport mensuel permet d'identifier ces patterns."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Collecter les données du mois depuis GestiQ"},
    {"type":"paragraph","text":"GestiQ → Tickets → Filtrer par mois. Collecter :"},
    {"type":"list","items":[
      "Nombre total de tickets ouverts",
      "Répartition par priorité (Critique / Urgent / Normal / Faible)",
      "Délai moyen de résolution par priorité",
      "Tickets résolus vs tickets encore ouverts",
      "Problèmes les plus fréquents (top 5)",
      "Clients avec le plus de tickets",
      "Avis Google obtenus ce mois",
      "Score de satisfaction si collecté"
    ]},
    {"type":"list","items":["Outil : **GestiQ Tickets**","Temps : ~15 min","Statut : requis"]},

    {"type":"heading2","text":"2. Identifier les patterns — mêmes problèmes qui reviennent"},
    {"type":"paragraph","text":"Analyser les top 5 problèmes du mois. Pour chaque problème récurrent :"},
    {"type":"list","items":[
      "Bug récurrent → à corriger définitivement par le Développeur",
      "Le client refait toujours la même erreur → à mieux former à la livraison",
      "Problème de processus → à améliorer dans les SOPs"
    ]},
    {"type":"callout","variant":"warning","title":"Règle","text":"Chaque problème récurrent doit avoir une action corrective ce mois-ci pour ne pas le revoir le mois prochain."},
    {"type":"list","items":["Outil : **Analyse + Réflexion**","Temps : ~15 min","Statut : requis"]},

    {"type":"heading2","text":"3. Rédiger et envoyer le rapport mensuel au fondateur"},
    {"type":"paragraph","text":"Rapport concis envoyé par WhatsApp avec :"},
    {"type":"list","items":[
      "Les chiffres clés",
      "Les problèmes récurrents identifiés",
      "Les actions correctives proposées",
      "Les succès du mois (ticket résolu rapidement, client très satisfait, problème complexe résolu)"
    ]},
    {"type":"list","items":["Outil : **WhatsApp · GestiQ**","Temps : ~10 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Rapport mensuel support — au fondateur"},
    {"type":"template","text":"📊 RAPPORT SUPPORT CLIENT — [MOIS ANNÉE]\n\n━━ TICKETS ━━\nTotal ouverts : [X]\n— 🔴 Critique : [X] · Délai moyen résolution : [Xh]\n— 🟠 Urgent : [X] · Délai moyen : [Xh]\n— 🟡 Normal : [X] · Délai moyen : [Xh]\n— 🟢 Faible : [X] · Délai moyen : [Xh]\nTaux résolution dans les délais : [X]%\n\n━━ TOP 3 PROBLÈMES DU MOIS ━━\n1. [PROBLÈME] — [X] fois — Cause : [___]\n2. [PROBLÈME] — [X] fois — Cause : [___]\n3. [PROBLÈME] — [X] fois — Cause : [___]\n\n━━ AVIS GOOGLE ━━\nAvis obtenus ce mois : [X]\nNote actuelle : [X]★ ([X] avis total)\n\n━━ ACTIONS CORRECTIVES PROPOSÉES ━━\n1. [ACTION pour réduire problème récurrent 1]\n2. [ACTION pour réduire problème récurrent 2]\n\n━━ SATISFACTION ━━\nClients avec 0 ticket ce mois : [X]\nClients avec 3+ tickets : [X] → à surveiller\n\n[Votre prénom] — Support Client Next Gital"},

    {"type":"divider"},

    {"type":"heading","text":"KPIs Support Client — à mesurer chaque mois"},
    {"type":"table","table":{
      "headers":["Métrique","Objectif"],
      "rows":[
        ["Tickets Critique résolus en < 4h","100%"],
        ["Tickets Urgent résolus en < 24h","95%+"],
        ["Tickets Normal résolus en < 48h","90%+"],
        ["Taux de satisfaction client","≥ 9/10"],
        ["Avis Google obtenus / mois","3+ nouveaux avis"],
        ["Tickets hors contrat convertis","≥ 50%"],
        ["Clients avec contrat maintenance","+2 nouveaux/mois"],
        ["Nombre de tickets récurrents","-10% vs mois précédent"]
      ]
    }},

    {"type":"divider"},

    {"type":"heading","text":"Checklist de validation"},
    {"type":"checklist","items":[
      "Données tickets du mois collectées depuis GestiQ",
      "Top 5 problèmes récurrents identifiés",
      "Action corrective définie pour chaque problème récurrent",
      "Avis Google du mois comptabilisés",
      "Rapport envoyé au fondateur le 1er du mois avant 10h"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-sup-rapport-mensuel');


COMMIT;
