-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 031 : Seed des 6 SOPs « Media Buyer »
--  Date : 2026-05-17
--
--  Catégorie : media_buyer · Auteur : Next Gital · Idempotent
--  Insère pour TOUS les tenants existants.
--
--  6 SOPs :
--    1. Création comptes Facebook · Instagram · TikTok client
--    2. Configuration Meta Business Manager complet
--    3. Lancer une campagne Facebook & Instagram Ads
--    4. Lancer une campagne TikTok Ads
--    5. Google Ads + Création fiche Google Maps (GMB)
--    6. Prompts IA Media Buyer — Claude & ChatGPT
--
--  Conformité ARCHITECTURE_TENANT.md :
--    - tenant_id NOT NULL, contrôle d'existence par (tenant_id, slug)
--    - RLS déjà actif sur public.sops (migration 025)
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ════════════════════════════════════════════════════════════════════
-- SOP 1 — ng-mb-creation-comptes-sociaux
-- ════════════════════════════════════════════════════════════════════
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-mb-creation-comptes-sociaux',
  'Création comptes Facebook · Instagram · TikTok client',
  'Jour 1 — créer FB Page, Instagram Pro et TikTok Business, et ajouter Next Gital comme Admin partout.',
  'media_buyer',
  '["Facebook","Instagram","TikTok","Création","Compte","Admin"]'::jsonb,
  'Next Gital',
  6,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Jour 1 du projet publicité — avant tout."},
    {"type":"callout","variant":"info","title":"Canal","text":"Facebook · Instagram · TikTok."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Client a ses 3 comptes créés, configurés, et Next Gital est Admin sur tous."},
    {"type":"callout","variant":"warning","title":"RÈGLE ABSOLUE","text":"Toujours ajouter info@nextgital.com comme Admin sur TOUS les comptes créés. Sans ça, on ne peut pas gérer les pubs ni aider le client si problème."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. FACEBOOK — Créer la Page Facebook professionnelle"},
    {"type":"paragraph","text":"Aller sur facebook.com/pages/create. Choisir : « Entreprise ou marque ». Remplir : nom de la page (nom exact du client), catégorie (chercher le secteur — Dentiste, Restaurant, Agence immobilière...). Photo de profil : logo du client (carré 180×180 min). Photo de couverture : bannière (851×315). Cliquer « Créer une page ». Compléter ensuite : adresse, téléphone, site web, horaires. Bouton d'action : « Envoyer un message » ou « Appeler »."},
    {"type":"list","items":["Outil : **Facebook**","Temps estimé : ~20 min","Statut : requis"]},

    {"type":"heading2","text":"2. FACEBOOK — Ajouter Next Gital comme Admin de la Page"},
    {"type":"paragraph","text":"Page Facebook du client → Paramètres → Accès à la Page → Ajouter un nouvel utilisateur. Chercher : info@nextgital.com (ou le compte Facebook Next Gital). Rôle : **Admin** (le plus haut niveau — obligatoire). Envoyer. Vérifier que l'invitation est bien acceptée côté Next Gital. Sans ce step, on ne peut rien gérer pour le client."},
    {"type":"list","items":["Outil : **Facebook Page Paramètres**","Temps estimé : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"3. INSTAGRAM — Créer le compte professionnel"},
    {"type":"paragraph","text":"Sur instagram.com : s'inscrire avec l'email du client (email@nomclient.com via Titan). Nom d'utilisateur : @nomclient ou @nomclient_oujda. Photo de profil : logo. Biographie (150 caractères max) : activité principale + ville + contact + emoji pertinent. Lien en bio : site web. Passer en compte Professionnel : Paramètres → Compte → Passer en compte professionnel → Entreprise → catégorie. Connecter à la Page Facebook du client."},
    {"type":"list","items":["Outil : **Instagram**","Temps estimé : ~20 min","Statut : requis"]},

    {"type":"heading2","text":"4. INSTAGRAM — Ajouter Next Gital comme Admin"},
    {"type":"paragraph","text":"Instagram → Paramètres → Outils créateur / Business → Partenaires → Ajouter un partenaire. Ou via Meta Business Suite : ajouter le compte Instagram du client dans le Business Manager Next Gital avec accès **Admin**. Vérifier depuis le compte Next Gital que l'accès est bien actif."},
    {"type":"list","items":["Outil : **Instagram / Meta Business Suite**","Temps estimé : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"5. TIKTOK — Créer le compte Business TikTok"},
    {"type":"paragraph","text":"Sur tiktok.com : s'inscrire avec l'email du client. Choisir un nom d'utilisateur court et mémorable (@nomclient). Photo de profil : logo. Biographie : courte, claire, avec emoji. Passer en compte Business : Paramètres → Gérer le compte → Passer en compte Business. Choisir la catégorie. Lier le site web dans le profil."},
    {"type":"list","items":["Outil : **TikTok**","Temps estimé : ~15 min","Statut : requis"]},

    {"type":"heading2","text":"6. TIKTOK — Ajouter Next Gital comme Admin"},
    {"type":"paragraph","text":"TikTok Business Center → Members → Invite Member → entrer le compte TikTok de Next Gital → rôle **Admin**. Ou dans les paramètres du compte : Gérer le compte → Accès utilisateur → Ajouter. Email : info@nextgital.com. Confirmer."},
    {"type":"list","items":["Outil : **TikTok Business Center**","Temps estimé : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"7. Sauvegarder TOUS les accès dans GestiQ"},
    {"type":"paragraph","text":"GestiQ → Fiche client → Onglet Accès. Renseigner pour chaque compte : email de connexion, mot de passe (fort — 16+ caractères), URL du profil/page, nom d'utilisateur. NE JAMAIS envoyer les mots de passe par WhatsApp. Toujours via GestiQ ou un gestionnaire de mots de passe."},
    {"type":"list","items":["Outil : **GestiQ**","Temps estimé : ~5 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Messages prêts à envoyer"},

    {"type":"heading2","text":"Message au client — infos nécessaires pour créer les comptes"},
    {"type":"template","text":"Bonjour [Prénom] 👋\n\nPour créer vos comptes professionnels sur les réseaux sociaux, j'ai besoin de :\n\n📋 INFORMATIONS :\n• Nom exact de votre entreprise (tel qu'il apparaîtra partout)\n• Adresse complète\n• Numéro de téléphone\n• Site web\n• Secteur d'activité\n• Horaires d'ouverture\n\n🎨 VISUELS :\n• Logo en PNG fond transparent (carré, min 500×500px)\n• Photo de couverture Facebook (ou on en crée une)\n\n📧 EMAIL :\n• L'email [PRENOM]@[DOMAINE].com est-il déjà actif ?\n\nJe m'occupe de tout le reste 🙏\nDélai pour me transmettre ces infos : [DATE + 48H]"},

    {"type":"heading2","text":"Confirmation création comptes — message interne (Chef de projet)"},
    {"type":"template","text":"✅ Comptes créés pour [NOM CLIENT]\n\n📘 Facebook Page : [URL PAGE]\n📸 Instagram : @[USERNAME] → [URL]\n🎵 TikTok : @[USERNAME] → [URL]\n\n🔐 Next Gital Admin : ✅ sur les 3 comptes\n📁 Accès enregistrés dans GestiQ : ✅\n\nPrêt pour la configuration Business Manager."},

    {"type":"divider"},

    {"type":"heading","text":"Checklist finale"},
    {"type":"checklist","items":[
      "Page Facebook créée — logo, couverture, catégorie, infos complètes",
      "info@nextgital.com ajouté comme Admin sur la Page Facebook",
      "Compte Instagram professionnel créé et lié à la Page Facebook",
      "Next Gital ajouté comme Admin sur Instagram",
      "Compte TikTok Business créé — profil complet",
      "Next Gital ajouté comme Admin sur TikTok",
      "Tous les accès sauvegardés dans GestiQ (fiche client)"
    ]},

    {"type":"callout","variant":"warning","title":"En cas de problème","text":"Si bloqué plus de 20 min → stopper et appeler le fondateur Next Gital : +212 620 002 066."}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-mb-creation-comptes-sociaux');

-- ════════════════════════════════════════════════════════════════════
-- SOP 2 — ng-mb-meta-business-manager
-- ════════════════════════════════════════════════════════════════════
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-mb-meta-business-manager',
  'Configuration Meta Business Manager complet',
  'Créer le BM client, ad account, paiement, Pixel et ajouter Next Gital comme Partenaire Admin.',
  'media_buyer',
  '["BusinessManager","Meta","Facebook","Admin","Paiement","Pixel"]'::jsonb,
  'Next Gital',
  7,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Immédiatement après création de la Page Facebook."},
    {"type":"callout","variant":"info","title":"Canal","text":"business.facebook.com."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Business Manager configuré, compte publicitaire actif, paiement ajouté, Next Gital Admin."},
    {"type":"callout","variant":"warning","title":"Important","text":"Chaque client a son propre Business Manager séparé. Ne jamais mélanger les clients dans le même BM. Next Gital doit être ajouté comme **Partenaire** Admin sur le BM du client — pas comme employé."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Créer le Business Manager du client"},
    {"type":"paragraph","text":"Aller sur business.facebook.com → Créer un compte. Renseigner : nom de l'entreprise (nom du client), prénom (du client), email professionnel du client (email@nomclient.com). Valider l'email de vérification. **IMPORTANT** : le créer avec l'email du client, pas avec l'email Next Gital."},
    {"type":"list","items":["Outil : **business.facebook.com**","Temps estimé : ~10 min","Statut : requis"]},

    {"type":"heading2","text":"2. Ajouter la Page Facebook dans le Business Manager"},
    {"type":"paragraph","text":"BM → Paramètres → Comptes → Pages → Ajouter → Ajouter une Page. Chercher la page du client (créée précédemment). Cliquer « Ajouter la Page ». La page est maintenant gérée depuis le Business Manager."},
    {"type":"list","items":["Outil : **Meta Business Manager**","Temps estimé : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"3. Créer le compte publicitaire (Ad Account)"},
    {"type":"paragraph","text":"BM → Paramètres → Comptes → Comptes publicitaires → Ajouter → Créer un nouveau compte publicitaire. Renseigner : nom du compte (« Nom Client - Pub »), fuseau horaire (**Africa/Casablanca - GMT+1**), devise (**MAD - Dirham marocain**). Créer. Noter l'ID du compte dans GestiQ."},
    {"type":"list","items":["Outil : **Meta Business Manager**","Temps estimé : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"4. Ajouter le mode de paiement"},
    {"type":"paragraph","text":"BM → Paramètres → Compte publicitaire → sélectionner le compte → Informations de paiement → Ajouter un mode de paiement. Options Maroc : carte **Visa/Mastercard CIB** (la plus courante), PayPal (si disponible), ou prépaiement manuel. Renseigner les données de la carte du client. Vérifier avec une transaction test de 1$ si possible. **Attention** : la carte doit avoir les paiements internationaux activés."},
    {"type":"list","items":["Outil : **Meta Payments**","Temps estimé : ~10 min","Statut : requis"]},

    {"type":"heading2","text":"5. Ajouter Next Gital comme Partenaire Admin"},
    {"type":"paragraph","text":"BM du client → Paramètres → Partenaires → Ajouter un partenaire → entrer l'ID du Business Manager Next Gital **[ID : À COMPLÉTER PAR LE FONDATEUR]**. Accès à accorder : **Admin complet** sur les comptes publicitaires + Pages. Confirmer. Côté Next Gital : accepter la demande de partenariat. Vérifier que l'accès est actif."},
    {"type":"list","items":["Outil : **Meta Business Manager**","Temps estimé : ~10 min","Statut : requis"]},

    {"type":"heading2","text":"6. Installer le Meta Pixel sur le site WordPress du client"},
    {"type":"paragraph","text":"BM → Sources de données → Pixels → Ajouter → Créer un Pixel (nom : « Pixel [Nom Client] »). Copier l'ID du Pixel. Dans WordPress : Extensions → Ajouter → chercher **PixelYourSite** ou **Meta Pixel for WordPress**. Installer → Activer → coller l'ID du Pixel. Vérifier avec **Meta Pixel Helper** (extension Chrome). Tester : naviguer sur le site et voir les événements dans l'outil de test du BM."},
    {"type":"list","items":["Outil : **Meta BM + WordPress + PixelYourSite**","Temps estimé : ~15 min","Statut : requis"]},

    {"type":"heading2","text":"7. Configurer les événements de conversion du Pixel"},
    {"type":"paragraph","text":"BM → Pixel → Événements → Configurer les événements manuellement. Événements standards à configurer :"},
    {"type":"list","items":[
      "**PageView** (toutes les pages — automatique)",
      "**ViewContent** (pages produits/services)",
      "**Lead** (formulaire de contact soumis)",
      "**Contact** (clic sur bouton WhatsApp)",
      "**Purchase** (si e-commerce — page merci après commande)"
    ]},
    {"type":"paragraph","text":"Tester chaque événement avec l'outil de test."},
    {"type":"list","items":["Outil : **Meta Events Manager**","Temps estimé : ~20 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Message au client — explication Business Manager et paiement"},
    {"type":"template","text":"Bonjour [Prénom] 😊\n\nPour lancer vos publicités Facebook et Instagram, nous allons configurer votre espace publicitaire professionnel (Business Manager).\n\nCe dont nous avons besoin :\n\n💳 MODE DE PAIEMENT :\nUne carte Visa ou Mastercard CIB avec :\n• Les paiements en ligne activés (appeler votre banque si non)\n• Les paiements internationaux activés\n• Minimum 500 MAD de disponible pour la première recharge\n\n📧 ACCÈS EMAIL :\nL'email [EMAIL@DOMAINE.COM] — nous allons créer votre Business Manager avec cet email.\n\nNe vous inquiétez pas — nous gérons tout le technique. Vous avez juste besoin de votre carte. 🙏"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist finale"},
    {"type":"checklist","items":[
      "Business Manager créé avec l'email du client",
      "Page Facebook ajoutée dans le BM",
      "Compte publicitaire créé (devise MAD, fuseau Casablanca)",
      "Mode de paiement ajouté et vérifié",
      "Next Gital ajouté comme Partenaire Admin (ID BM Next Gital vérifié)",
      "Meta Pixel créé et installé sur WordPress",
      "Événements de conversion configurés et testés"
    ]},

    {"type":"callout","variant":"warning","title":"En cas de problème","text":"Si bloqué plus de 20 min → stopper et appeler le fondateur Next Gital : +212 620 002 066."}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-mb-meta-business-manager');

-- ════════════════════════════════════════════════════════════════════
-- SOP 3 — ng-mb-facebook-instagram-ads
-- ════════════════════════════════════════════════════════════════════
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-mb-facebook-instagram-ads',
  'Lancer une campagne Facebook & Instagram Ads',
  'Structure 1 Campagne → 2-3 Ad Sets → 3-5 pubs. Lancement, suivi 3 jours, optimisation J+7.',
  'media_buyer',
  '["FacebookAds","InstagramAds","Campagne","Meta","Pub"]'::jsonb,
  'Next Gital',
  8,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Après configuration BM complète."},
    {"type":"callout","variant":"info","title":"Canal","text":"Meta Ads Manager."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Campagne active avec leads qualifiés au coût le plus bas possible."},
    {"type":"callout","variant":"warning","title":"Structure obligatoire","text":"1 Campagne → 2-3 Ensembles de pubs → 3-5 pubs par ensemble. Toujours tester avec un budget minimal (50 MAD/jour) avant de scaler."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Définir l'objectif de la campagne avec le client"},
    {"type":"paragraph","text":"AVANT de toucher à Ads Manager — répondre à ces questions avec le client : Quel est l'objectif réel ? (messages WhatsApp, appels, visites site, ventes, notoriété). Qui est la cible ? (âge, sexe, ville, intérêts). Quel budget journalier ? (minimum recommandé : **50-100 MAD/jour**). Quelle durée ? (minimum **7 jours** pour que l'algo apprenne). Quelles offres ou promotions mettre en avant ?"},
    {"type":"list","items":["Outil : **Réunion avec le client**","Temps estimé : ~30 min","Statut : requis"]},

    {"type":"heading2","text":"2. Créer la campagne dans Ads Manager"},
    {"type":"paragraph","text":"Ads Manager → Créer → Campagne. Objectif selon le but client : **Messages** (pour WhatsApp leads) · **Trafic** (pour visites site) · **Conversions** (pour formulaires ou achats) · **Notoriété** (pour lancement). Nom de la campagne : `[NOM CLIENT] - [OBJECTIF] - [MOIS ANNÉE]`. Activer le budget Advantage Campaign Budget si total ≥ 200 MAD/jour. Limite de dépenses : définir un plafond de sécurité."},
    {"type":"list","items":["Outil : **Meta Ads Manager**","Temps estimé : ~10 min","Statut : requis"]},

    {"type":"heading2","text":"3. Configurer l'ensemble de publicités (ciblage)"},
    {"type":"paragraph","text":"Nom ensemble : `[NOM CLIENT] - [CIBLE] - [TYPE]`. **Lieu** : Maroc → ville(s) du client (ex: Oujda + 40km autour). **Âge** : selon le secteur (médecin : 25-65, restaurant : 18-45, etc.). **Sexe** : selon pertinence. **Intérêts** : 5-10 centres d'intérêt précis liés au secteur. **Comportements** : si applicable. **Placements** : Advantage+ (automatique) pour commencer. **Budget** : 50-100 MAD/jour pour tester. **Calendrier** : dates début et fin."},
    {"type":"list","items":["Outil : **Meta Ads Manager**","Temps estimé : ~20 min","Statut : requis"]},

    {"type":"heading2","text":"4. Créer 3-5 publicités (visuels + textes)"},
    {"type":"paragraph","text":"Pour chaque pub :"},
    {"type":"list","items":[
      "Format : image 1080×1080 ou 1080×1350, vidéo, carrousel selon contenu",
      "Texte principal : 3 versions à tester (voir prompts IA — SOP 6)",
      "Titre : 25 caractères max percutants",
      "Description : optionnel",
      "CTA : Envoyer un message / En savoir plus / Acheter",
      "Lien destination : site web ou WhatsApp",
      "Vérifier l'aperçu sur mobile, feed, stories",
      "Nommer chaque pub : `[TYPE VISUEL] - [ACCROCHE COURTE]`"
    ]},
    {"type":"list","items":["Outil : **Meta Ads Manager + Canva**","Temps estimé : ~30 min","Statut : requis"]},

    {"type":"heading2","text":"5. Checklist pré-lancement"},
    {"type":"paragraph","text":"Avant de cliquer **Publier**, vérifier :"},
    {"type":"checklist","items":[
      "Pixel installé et actif",
      "Lien destination fonctionne",
      "Numéro WhatsApp correct",
      "Budget et dates corrects",
      "Ciblage cohérent avec l'offre",
      "Pas de texte sur les images (pénalisé par Meta)",
      "Pas de contenu interdit (alcool, médicaments sans autorisation, casino)",
      "Compte publicitaire avec paiement actif"
    ]},
    {"type":"list","items":["Outil : **Meta Ads Manager**","Temps estimé : ~10 min","Statut : requis"]},

    {"type":"heading2","text":"6. Suivi quotidien les 3 premiers jours"},
    {"type":"paragraph","text":"Jours 1-3 : vérifier chaque matin les métriques clés. Si coût par résultat > objectif : ne pas paniquer avant 3 jours (l'algo apprend). **Ne jamais modifier une campagne avant 48h** — ça remet à zéro l'apprentissage. Si CPM très élevé (> 50 MAD) : vérifier le ciblage, peut-être trop restreint. Si 0 résultats après 24h : vérifier que la pub n'est pas bloquée."},
    {"type":"list","items":["Outil : **Meta Ads Manager**","Temps estimé : ~15 min/jour","Statut : requis"]},

    {"type":"heading2","text":"7. Optimisation à J+7"},
    {"type":"paragraph","text":"Après 7 jours :"},
    {"type":"list","items":[
      "Identifier les 2 pubs les plus performantes (coût/résultat le plus bas)",
      "Couper les pubs avec coût > 2× l'objectif",
      "Augmenter le budget de **20% max par semaine** sur les pubs gagnantes",
      "Créer 2 nouvelles pubs pour tester (nouvelles accroches, nouveaux visuels)",
      "Préparer le rapport hebdomadaire pour le client (voir SOP 6)"
    ]},
    {"type":"list","items":["Outil : **Meta Ads Manager**","Temps estimé : ~30 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Rapport hebdomadaire Meta Ads — au client"},
    {"type":"template","text":"📊 RAPPORT PUBLICITÉS — [NOM CLIENT]\nPériode : [DATE DÉBUT] → [DATE FIN]\n\n━━ RÉSULTATS ━━\n💰 Budget dépensé : [X] MAD\n👁️ Personnes touchées : [X]\n🖱️ Clics : [X] (Taux : [X]%)\n💬 Messages WhatsApp reçus : [X] (Coût/msg : [X] MAD)\n\n━━ TOP PUBLICITÉ ━━\n🏆 '[NOM PUB]' — [X] messages à [X] MAD chacun\n\n━━ SEMAINE PROCHAINE ━━\n✅ [ACTION 1]\n✅ [ACTION 2]\n\nBonne semaine ! 🙏\nNext Gital · Équipe Pub"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist finale"},
    {"type":"checklist","items":[
      "Objectif campagne défini avec le client",
      "Campagne créée — objectif, nom, limite budget",
      "Ciblage configuré — lieu, âge, intérêts cohérents",
      "3 à 5 pubs créées avec visuels et textes variés",
      "Checklist pré-lancement validée complète",
      "Campagne publiée — statut Actif confirmé",
      "Suivi J+1, J+2, J+3 effectués",
      "Rapport J+7 envoyé au client"
    ]},

    {"type":"callout","variant":"warning","title":"En cas de problème","text":"Si bloqué plus de 20 min → stopper et appeler le fondateur Next Gital : +212 620 002 066."}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-mb-facebook-instagram-ads');

-- ════════════════════════════════════════════════════════════════════
-- SOP 4 — ng-mb-tiktok-ads
-- ════════════════════════════════════════════════════════════════════
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-mb-tiktok-ads',
  'Lancer une campagne TikTok Ads',
  'TikTok Pixel, ciblage Maroc 18-35 ans, vidéos verticales 9:16 avec hook fort. Optimisation J+3.',
  'media_buyer',
  '["TikTokAds","TikTok","Pub","Vidéo","Jeunes"]'::jsonb,
  'Next Gital',
  7,
  false,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Après création du compte TikTok Business."},
    {"type":"callout","variant":"info","title":"Canal","text":"TikTok Ads Manager — ads.tiktok.com."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Campagne TikTok active touchant une audience jeune (18-35 ans) au Maroc."},
    {"type":"callout","variant":"warning","title":"Format vidéo","text":"TikTok au Maroc fonctionne mieux avec des vidéos authentiques (téléphone, voix naturelle) qu'avec des visuels très produits. Durée idéale : 15-30 secondes. Les 3 premières secondes sont cruciales — le hook doit accrocher immédiatement."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Accéder à TikTok Ads Manager et créer le compte publicitaire"},
    {"type":"paragraph","text":"Aller sur ads.tiktok.com. Se connecter avec le compte TikTok Business du client. Si premier accès : remplir les informations du compte publicitaire (pays : **Maroc**, devise : **MAD**, secteur d'activité). Soumettre pour vérification (24-48h). Ajouter le mode de paiement : carte Visa/Mastercard CIB internationale. Ajouter Next Gital comme membre Admin : Settings → Users → Add User → email Next Gital → **Admin**."},
    {"type":"list","items":["Outil : **TikTok Ads Manager**","Temps estimé : ~20 min","Statut : requis"]},

    {"type":"heading2","text":"2. Installer le TikTok Pixel sur WordPress"},
    {"type":"paragraph","text":"TikTok Ads Manager → Assets → Events → Web Events → Create Pixel. Copier l'ID du Pixel. WordPress → Extensions → Chercher **TikTok for Business** ou **TikTok Pixel**. Installer → Activer → entrer l'ID du Pixel. Ou manuellement : coller le code dans le `<head>` via Elementor Custom Code. Vérifier avec **TikTok Pixel Helper** (extension Chrome)."},
    {"type":"list","items":["Outil : **TikTok Ads + WordPress**","Temps estimé : ~15 min","Statut : requis"]},

    {"type":"heading2","text":"3. Créer la campagne TikTok"},
    {"type":"paragraph","text":"Ads Manager → Campaign → Create. Objectif : **Reach** (notoriété), **Traffic** (trafic site), **Lead Generation** (formulaire), ou **App Promotion**. Nom : `[NOM CLIENT] - [OBJECTIF] - [MOIS]`. Budget de campagne : minimum **50 MAD/jour**. Mode de création : **Simplified mode** pour commencer (plus simple), passer en Custom mode pour campagnes avancées."},
    {"type":"list","items":["Outil : **TikTok Ads Manager**","Temps estimé : ~10 min","Statut : requis"]},

    {"type":"heading2","text":"4. Configurer le ciblage (Ad Group)"},
    {"type":"list","items":[
      "**Emplacement** : Maroc",
      "**Langue** : Arabe + Français",
      "**Âge** : 18-35 (TikTok = audience jeune)",
      "**Sexe** : selon secteur",
      "**Intérêts et comportements** : choisir dans la liste TikTok les plus pertinents",
      "**Appareils** : tous (mobile principalement)",
      "**Placement** : TikTok uniquement pour commencer (pas Pangle)",
      "**Budget quotidien** : 50-100 MAD",
      "**Calendrier** : minimum 7 jours"
    ]},
    {"type":"list","items":["Outil : **TikTok Ads Manager**","Temps estimé : ~15 min","Statut : requis"]},

    {"type":"heading2","text":"5. Créer les publicités vidéo TikTok"},
    {"type":"paragraph","text":"Format obligatoire : **vidéo verticale 9:16**, résolution minimum 720×1280px. Durée : 15-30 secondes idéalement. Structure d'une pub TikTok qui convertit :"},
    {"type":"steps","items":[
      "**Secondes 0-3 (Hook)** : question ou affirmation choc",
      "**Secondes 3-10 (Problème)** : identifier le problème du client",
      "**Secondes 10-20 (Solution)** : présenter le produit/service comme solution",
      "**Secondes 20-30 (CTA)** : appel à l'action clair (Message, Appel, Site)"
    ]},
    {"type":"paragraph","text":"**Texte en overlay** : 3-5 mots maximum par écran. **Musique** : utiliser une musique tendance TikTok sans droits."},
    {"type":"list","items":["Outil : **CapCut + TikTok Ads Manager**","Temps estimé : ~45 min","Statut : requis"]},

    {"type":"heading2","text":"6. Optimisation et suivi TikTok Ads"},
    {"type":"paragraph","text":"Métriques clés à surveiller :"},
    {"type":"list","items":[
      "**CPM** (coût pour 1000 vues)",
      "**CTR** (taux de clic — objectif > 1%)",
      "**CPL** (coût par lead)",
      "**Taux de visionnage 100%** (si > 20% c'est bien)"
    ]},
    {"type":"paragraph","text":"Optimiser après 3 jours : si CTR < 0.5% → changer le hook de la vidéo. Si CPM > 30 MAD → élargir le ciblage. Tester toujours **3 vidéos différentes** avec des hooks différents."},
    {"type":"list","items":["Outil : **TikTok Ads Manager**","Temps estimé : ~15 min/jour","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Checklist finale"},
    {"type":"checklist","items":[
      "Compte publicitaire TikTok créé et vérifié",
      "Next Gital ajouté comme Admin sur le compte pub TikTok",
      "Mode de paiement ajouté (CIB internationale)",
      "TikTok Pixel installé sur WordPress et vérifié",
      "Campagne créée — objectif et budget définis",
      "Ciblage configuré (Maroc, 18-35 ans)",
      "Minimum 3 vidéos créées avec hooks différents",
      "Pub publiée — statut Actif confirmé"
    ]},

    {"type":"callout","variant":"warning","title":"En cas de problème","text":"Si bloqué plus de 20 min → stopper et appeler le fondateur Next Gital : +212 620 002 066."}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-mb-tiktok-ads');

-- ════════════════════════════════════════════════════════════════════
-- SOP 5 — ng-mb-google-ads-maps
-- ════════════════════════════════════════════════════════════════════
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-mb-google-ads-maps',
  'Google Ads + Création fiche Google Maps (GMB)',
  'Fiche Google Business Profile à 100% + campagne Search Ads locale avec extensions complètes.',
  'media_buyer',
  '["GoogleAds","GoogleMaps","GMB","SEA","LocalSEO"]'::jsonb,
  'Next Gital',
  9,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Dès que le client a un site actif."},
    {"type":"callout","variant":"info","title":"Canal","text":"Google Ads · Google Business Profile."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Client visible sur Google Maps + campagne Search Ads active pour les recherches locales."},
    {"type":"callout","variant":"warning","title":"Priorité absolue","text":"La fiche Google Maps (Google Business Profile) est **GRATUITE** et obligatoire avant Google Ads. Elle permet d'apparaître dans les résultats locaux sans payer. À faire en priorité absolue."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. GOOGLE MAPS — Créer la fiche Google Business Profile"},
    {"type":"paragraph","text":"Aller sur business.google.com. Cliquer « Gérer maintenant » → entrer le nom de l'entreprise → choisir la catégorie (très important pour le SEO local — être précis). Ajouter l'adresse exacte (ou « Zone de service » si déplacement). Numéro de téléphone. Site web. Horaires. Continuer. Google enverra une carte postale avec un code de vérification (5-14 jours) OU propose une vérification par téléphone immédiate (préférer cette option)."},
    {"type":"list","items":["Outil : **business.google.com**","Temps estimé : ~20 min","Statut : requis"]},

    {"type":"heading2","text":"2. GOOGLE MAPS — Compléter la fiche à 100%"},
    {"type":"paragraph","text":"Après vérification, compléter chaque section :"},
    {"type":"list","items":[
      "**Description** : 750 caractères max — inclure ville + secteur + points forts",
      "**Photos** : minimum **10 photos** (façade, intérieur, équipe, produits/services)",
      "**Logo**",
      "**Catégories supplémentaires** (jusqu'à 9)",
      "**Attributs spéciaux** (cartes bancaires, parking, wifi…)",
      "**Questions-Réponses** : créer **5 Q&R vous-mêmes** avec les questions fréquentes",
      "**Services/Produits** : ajouter avec prix si applicable"
    ]},
    {"type":"callout","variant":"tip","title":"Astuce","text":"Une fiche à 100% = 50% plus de clics."},
    {"type":"list","items":["Outil : **Google Business Profile**","Temps estimé : ~45 min","Statut : requis"]},

    {"type":"heading2","text":"3. GOOGLE MAPS — Ajouter Next Gital comme gestionnaire"},
    {"type":"paragraph","text":"Business Profile → Paramètres → Gestionnaires → Ajouter un gestionnaire. Entrer : info@nextgital.com → Rôle : **Gestionnaire** (pas Propriétaire). Confirmer. Next Gital peut maintenant gérer la fiche (avis, posts, infos) sans avoir les droits propriétaire."},
    {"type":"list","items":["Outil : **Google Business Profile**","Temps estimé : ~5 min","Statut : requis"]},

    {"type":"heading2","text":"4. GOOGLE ADS — Créer le compte client"},
    {"type":"paragraph","text":"Aller sur ads.google.com. Créer avec l'email du client. OU depuis le compte Manager Next Gital (MCC) : Tous les comptes → + → Créer un nouveau compte client. Renseigner : nom du client, fuseau (Africa/Casablanca), devise (MAD). Le compte est créé avec un ID unique à **noter dans GestiQ**."},
    {"type":"list","items":["Outil : **Google Ads**","Temps estimé : ~10 min","Statut : requis"]},

    {"type":"heading2","text":"5. GOOGLE ADS — Créer un compte Manager Next Gital (MCC)"},
    {"type":"paragraph","text":"Si pas encore fait : aller sur ads.google.com/home/tools/manager-accounts. Créer un compte Manager (MCC) avec info@nextgital.com. Ce compte permet de gérer tous les comptes clients depuis un seul endroit. Lier chaque compte client au MCC : MCC → Comptes → Lier le compte existant → ID du compte client."},
    {"type":"list","items":["Outil : **Google Ads Manager (MCC)**","Temps estimé : ~15 min","Statut : requis (une seule fois)"]},

    {"type":"heading2","text":"6. GOOGLE ADS — Configurer la campagne Search"},
    {"type":"paragraph","text":"Type de campagne : **Réseau de Recherche** (le plus efficace pour les PME locales). Objectif : Leads ou Trafic vers le site. Nom : `[NOM CLIENT] - Search - [VILLE] - [MOIS]`. **Réseaux** : décocher « Réseau Display » et « Recherche partenaires Google ». **Lieux** : cibler uniquement la ville du client + rayon (ex: Oujda 30km). **Langues** : Français + Arabe. **Budget journalier** : 30-50 MAD pour tester. **Stratégie d'enchères** : Maximiser les clics (débutant) → passer à Maximiser les conversions après 50 conversions."},
    {"type":"list","items":["Outil : **Google Ads**","Temps estimé : ~20 min","Statut : requis"]},

    {"type":"heading2","text":"7. GOOGLE ADS — Recherche de mots-clés et création des annonces"},
    {"type":"paragraph","text":"**Outil de planification des mots-clés** : trouver 15-30 mots-clés pertinents. Taper le service du client + ville. Exemple dentiste Oujda : `dentiste oujda`, `cabinet dentaire oujda`, `orthodontiste oujda`, `blanchiment dents oujda`. **Exclure** les mots-clés négatifs (gratuit, emploi, formation)."},
    {"type":"paragraph","text":"Créer **3 annonces par groupe d'annonces** :"},
    {"type":"list","items":[
      "**Titre 1** : service principal",
      "**Titre 2** : avantage clé",
      "**Titre 3** : CTA ou localisation",
      "**Description 1 et 2** : 90 caractères chacune",
      "**URL finale** : page la plus pertinente du site"
    ]},
    {"type":"list","items":["Outil : **Google Keyword Planner + Google Ads**","Temps estimé : ~45 min","Statut : requis"]},

    {"type":"heading2","text":"8. GOOGLE ADS — Ajouter les extensions d'annonces"},
    {"type":"paragraph","text":"Extensions obligatoires pour les PME locales :"},
    {"type":"list","items":[
      "**Liens de site** (4 liens vers pages clés du site)",
      "**Accroches** (4 points forts : « 6 ans d'expérience », « Sans engagement »…)",
      "**Extraits de site** (services, spécialités)",
      "**Lieu** (lier la fiche Google Maps)",
      "**Appel** (numéro de téléphone du client — cliquable mobile)"
    ]},
    {"type":"callout","variant":"tip","title":"Effet","text":"Ces extensions augmentent le CTR de 15-30% sans coût supplémentaire."},
    {"type":"list","items":["Outil : **Google Ads Extensions**","Temps estimé : ~20 min","Statut : requis"]},

    {"type":"divider"},

    {"type":"heading","text":"Rapport Google Ads mensuel — au client"},
    {"type":"template","text":"📊 RAPPORT GOOGLE ADS — [NOM CLIENT]\nPériode : [MOIS ANNÉE]\n\n━━ RÉSULTATS ━━\n💰 Budget dépensé : [X] MAD\n👁️ Impressions : [X]\n🖱️ Clics : [X] (CTR : [X]%)\n📞 Appels générés : [X]\n🌐 Visites site : [X]\n💰 Coût par clic moyen : [X] MAD\n\n━━ TOP MOTS-CLÉS ━━\n1. '[MOT CLÉ]' — [X] clics — [X] MAD/clic\n2. '[MOT CLÉ]' — [X] clics — [X] MAD/clic\n\n━━ FICHE GOOGLE MAPS ━━\n👁️ Vues fiche : [X]\n📞 Appels depuis Maps : [X]\n🗺️ Demandes d'itinéraire : [X]\n\nSemaine prochaine : [ACTIONS]\n\nNext Gital · Équipe Pub 🙏"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist finale"},
    {"type":"checklist","items":[
      "Fiche Google Business Profile créée et vérifiée",
      "Fiche complète à 100% (photos, description, services, Q&R)",
      "info@nextgital.com ajouté comme Gestionnaire GMB",
      "Compte Google Ads créé et lié au MCC Next Gital",
      "Campagne Search créée — ciblage local configuré",
      "15-30 mots-clés ajoutés + mots-clés négatifs",
      "3 annonces créées avec titres et descriptions",
      "5 types d'extensions configurés (liens, appel, lieu…)",
      "Conversion tracking installé sur le site"
    ]},

    {"type":"callout","variant":"warning","title":"En cas de problème","text":"Si bloqué plus de 20 min → stopper et appeler le fondateur Next Gital : +212 620 002 066."}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-mb-google-ads-maps');

-- ════════════════════════════════════════════════════════════════════
-- SOP 6 — ng-mb-prompts-ia
-- ════════════════════════════════════════════════════════════════════
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-mb-prompts-ia',
  'Prompts IA Media Buyer — Claude & ChatGPT',
  '7 prompts testés pour textes de pub, hooks vidéo, mots-clés, analyse résultats, calendrier contenu et avis Google.',
  'media_buyer',
  '["IA","Claude","ChatGPT","Prompts","Pub","Contenu"]'::jsonb,
  'Next Gital',
  10,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Usage quotidien."},
    {"type":"callout","variant":"info","title":"Canal","text":"Claude.ai + ChatGPT + Meta Ads Manager."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Créer des textes de pub, des hooks vidéo et des rapports 3× plus vite avec l'IA."},
    {"type":"callout","variant":"warning","title":"Règle d'or","text":"Ces prompts sont testés et optimisés pour Next Gital. Toujours remplacer les [VARIABLES] avant d'utiliser. L'IA génère une base — le Media Buyer doit relire et adapter au ton du client."},

    {"type":"heading","text":"Les 7 prompts opérationnels"},

    {"type":"heading2","text":"PROMPT 1 — Générer 5 textes de pub Facebook/Instagram"},
    {"type":"paragraph","text":"À copier-coller dans Claude ou ChatGPT :"},
    {"type":"template","text":"Tu es un expert en publicité digitale pour PME marocaines. Crée 5 textes de publicité Facebook/Instagram pour [NOM CLIENT], [SECTEUR] basé à [VILLE]. Offre à promouvoir : [OFFRE PRÉCISE]. Cible : [DESCRIPTION CIBLE]. Objectif de la pub : [MESSAGES WHATSAPP / VISITES SITE / APPELS]. Chaque texte doit avoir : une accroche émotionnelle puissante (problème ou désir), la solution (ce que propose le client), une preuve sociale si possible, un CTA clair. Langue : français marocain naturel. Longueur : 80-120 mots chacun. Format : numéroter les 5 versions."},
    {"type":"list","items":["Outil : **Claude.ai ou ChatGPT**","Temps estimé : ~5 min"]},

    {"type":"heading2","text":"PROMPT 2 — Créer 10 hooks vidéo TikTok/Reels"},
    {"type":"template","text":"Tu es un créateur de contenu TikTok spécialisé pour les entreprises marocaines. Crée 10 hooks vidéo percutants (les 3 premières secondes) pour [NOM CLIENT], [SECTEUR]. Le hook doit arrêter le scroll immédiatement. Format : 1 phrase maximum (10-15 mots). Types de hooks à varier : question provocatrice, affirmation choc, problème reconnaissable, statistique surprenante, before/after. Public cible : [CIBLE]. Contexte Maroc/Oujda si pertinent. Donne les 10 hooks numérotés, en français simple et direct."},
    {"type":"list","items":["Outil : **Claude.ai ou ChatGPT**","Temps estimé : ~5 min"]},

    {"type":"heading2","text":"PROMPT 3 — Trouver des mots-clés Google Ads"},
    {"type":"template","text":"Tu es un expert SEA Google Ads au Maroc. Pour [NOM CLIENT], [SECTEUR] basé à [VILLE], génère : 20 mots-clés principaux (intention d'achat forte), 10 mots-clés secondaires (intention de recherche), 10 mots-clés à exclure (négatifs). Pour chaque mot-clé principal, indique : type de correspondance recommandé (large, expression, exact). Priorité aux recherches locales incluant [VILLE] et les villes proches. Langue : mix français et arabe romanisé (darija). Format : tableau avec colonnes Mot-clé / Type / Priorité."},
    {"type":"list","items":["Outil : **Claude.ai ou ChatGPT**","Temps estimé : ~5 min"]},

    {"type":"heading2","text":"PROMPT 4 — Analyser les résultats et donner des recommandations"},
    {"type":"template","text":"Tu es un Media Buyer senior spécialisé sur le marché marocain. Voici les résultats de la campagne Facebook de [NOM CLIENT] cette semaine : [COPIER LES MÉTRIQUES : budget dépensé, CPM, CTR, CPL, nombre de leads]. Objectif initial : [OBJECTIF]. Budget : [X MAD/jour]. Secteur : [SECTEUR]. Analyse ces résultats et donne-moi : 1) Évaluation de la performance (bon / moyen / mauvais et pourquoi), 2) Les 3 causes probables des problèmes identifiés, 3) Les 5 actions concrètes à faire cette semaine pour améliorer les résultats. Sois direct et précis."},
    {"type":"list","items":["Outil : **Claude.ai ou ChatGPT**","Temps estimé : ~5 min"]},

    {"type":"heading2","text":"PROMPT 5 — Créer un calendrier de contenu mensuel"},
    {"type":"template","text":"Tu es un stratège en marketing digital pour entreprises locales marocaines. Crée un calendrier de contenu pour le mois de [MOIS] pour [NOM CLIENT], [SECTEUR] à [VILLE]. Le client poste sur : Facebook, Instagram (et TikTok si vidéos). Fréquence : 3 posts par semaine minimum. Pour chaque post, donner : Jour et heure de publication, Plateforme, Type de contenu (photo, vidéo, carrousel, story), Sujet précis, Objectif (notoriété, engagement, leads), Accroche courte. Inclure des idées pour des contenus authentiques et locaux (références à [VILLE], fêtes marocaines, actualités du secteur). Format : tableau."},
    {"type":"list","items":["Outil : **Claude.ai ou ChatGPT**","Temps estimé : ~5 min"]},

    {"type":"heading2","text":"PROMPT 6 — Rédiger la biographie Instagram/TikTok"},
    {"type":"template","text":"Rédige 3 versions de biographie pour le compte Instagram de [NOM CLIENT], [SECTEUR] basé à [VILLE], Maroc. Contrainte : 150 caractères maximum par version. Chaque version doit inclure : l'activité principale (1-2 mots clés), la proposition de valeur unique, un élément local (ville ou marché marocain), un CTA clair (👇 lien, 📞 appel, 💬 message). Ton : professionnel mais accessible. Utiliser des emojis pertinents pour aérer."},
    {"type":"list","items":["Outil : **Claude.ai ou ChatGPT**","Temps estimé : ~3 min"]},

    {"type":"heading2","text":"PROMPT 7a — Répondre à un avis Google POSITIF"},
    {"type":"template","text":"Rédige 3 réponses courtes et chaleureuses pour cet avis 5 étoiles laissé sur Google Maps : [COPIER L'AVIS]. Entreprise : [NOM CLIENT], [SECTEUR], [VILLE]. Ton : reconnaissant, humain, professionnel. Inclure le prénom du client si mentionné. Maximum 50 mots chacune."},

    {"type":"heading2","text":"PROMPT 7b — Répondre à un avis Google NÉGATIF"},
    {"type":"template","text":"Rédige une réponse professionnelle et apaisante pour cet avis négatif sur Google Maps : [COPIER L'AVIS]. Entreprise : [NOM CLIENT]. Objectif : montrer qu'on prend le retour au sérieux, proposer de résoudre en privé, ne pas être défensif. Maximum 80 mots. Ton : calme, empathique, constructif."},
    {"type":"list","items":["Outil : **Claude.ai ou ChatGPT**","Temps estimé : ~3 min par avis"]},

    {"type":"divider"},

    {"type":"heading","text":"Checklist d'utilisation"},
    {"type":"checklist","items":[
      "Prompt 1 utilisé pour les textes Facebook/Instagram — 5 versions générées",
      "Prompt 2 utilisé pour les hooks TikTok — 10 hooks générés",
      "Prompt 3 utilisé pour les mots-clés Google Ads",
      "Prompt 4 utilisé pour analyser les résultats hebdo",
      "Prompt 5 utilisé pour le calendrier contenu mensuel",
      "Prompt 6 utilisé pour les biographies des profils",
      "Prompt 7 utilisé pour répondre aux avis Google Maps",
      "Tous les outputs IA relus et adaptés avant utilisation"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Règles absolues Media Buyer"},
    {"type":"numbered","items":[
      "Ne JAMAIS lancer une campagne sans validation du fondateur sur le premier budget",
      "Ne JAMAIS toucher à la carte bancaire client sans accord écrit",
      "Toujours ajouter info@nextgital.com comme Admin AVANT de remettre les accès au client",
      "Ne JAMAIS envoyer de mots de passe par WhatsApp — uniquement via GestiQ",
      "Faire valider les visuels et textes par le client AVANT de lancer",
      "Respecter le budget défini — ne pas dépasser sans accord",
      "Rapport hebdomadaire client envoyé CHAQUE lundi sans exception",
      "Si campagne bloquée par Meta ou TikTok → informer le fondateur immédiatement"
    ]},

    {"type":"callout","variant":"warning","title":"En cas de problème","text":"Si bloqué plus de 20 min → stopper et appeler le fondateur Next Gital : +212 620 002 066."}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-mb-prompts-ia');

COMMIT;
