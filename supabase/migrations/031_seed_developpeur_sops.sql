-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 031 : Seed des 6 SOPs « Développeur »
--  Date : 2026-05-17
--
--  Catégorie : dev · Auteur : Next Gital · Idempotent
--  Stack : WordPress + WooCommerce + Hostinger + Dokploy + Titan Email
--  Insère pour TOUS les tenants existants.
--
--  Conformité ARCHITECTURE_TENANT.md :
--    - tenant_id NOT NULL, contrôle d'existence par (tenant_id, slug)
--    - RLS déjà actif sur public.sops (migration 025)
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ── ng-dev-wp-hostinger (dev) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-dev-wp-hostinger',
  'Installation WordPress — Site Vitrine sur Hostinger',
  'Procédure d''installation WordPress sur Hostinger : domaine, SSL, plugins, SMTP Titan, sauvegardes.',
  'dev',
  '["WordPress","Hostinger","Installation","Vitrine","hPanel"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Jour 1 du projet — après réception des assets client."},
    {"type":"callout","variant":"info","title":"Canal","text":"hPanel Hostinger + VS Code + Claude Code."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Site WordPress installé, configuré et prêt pour le développement en moins de 1h."},
    {"type":"callout","variant":"warning","title":"Règle","text":"Toujours travailler sur staging.domaine.com avant de toucher au domaine principal."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Créer le domaine / sous-domaine dans hPanel"},
    {"type":"paragraph","text":"Connexion hPanel → Websites → Add Website. Si refonte d'un site existant : créer **staging.nomclient.com** pour travailler sans impacter le live. Vérifier que le DNS pointe correctement (propagation 1–24h)."},
    {"type":"list","items":["Outil : **hPanel Hostinger**","Temps : ~10 min"]},

    {"type":"heading2","text":"2. Installer WordPress (Auto Installer)"},
    {"type":"paragraph","text":"hPanel → Websites → Auto Installer → WordPress. Renseigner : URL staging, titre, email admin (info@nextgital.com temporairement), identifiants admin solides. **Décocher** « Installer les données de démonstration »."},
    {"type":"list","items":["Outil : **hPanel Auto Installer**","Temps : ~5 min"]},

    {"type":"heading2","text":"3. Configuration WordPress de base"},
    {"type":"paragraph","text":"Aller sur staging.domaine.com/wp-admin :"},
    {"type":"list","items":[
      "Réglages → Général : titre, tagline, **timezone Africa/Casablanca**, langue **français**",
      "Réglages → Lecture : page d'accueil statique (créer page « Accueil »)",
      "Réglages → Discussion : **désactiver** les commentaires",
      "Réglages → Permaliens : « **Nom de l'article** »",
      "Supprimer : article, page et commentaire de démo"
    ]},
    {"type":"list","items":["Outil : **WordPress Admin**","Temps : ~10 min"]},

    {"type":"heading2","text":"4. Installer les 7 plugins essentiels Next Gital"},
    {"type":"paragraph","text":"Extensions → Ajouter — dans cet ordre :"},
    {"type":"numbered","items":[
      "**Elementor** — constructeur visuel",
      "**Yoast SEO** — référencement",
      "**WP Rocket** ou **LiteSpeed Cache** — performance",
      "**Wordfence Security** — sécurité",
      "**UpdraftPlus** — sauvegardes",
      "**WP Mail SMTP** — emails via Titan",
      "**Contact Form 7** — formulaires"
    ]},
    {"type":"callout","variant":"warning","title":"À supprimer","text":"Akismet et Hello Dolly — désactiver puis supprimer."},
    {"type":"list","items":["Temps : ~15 min"]},

    {"type":"heading2","text":"5. Configurer WP Mail SMTP avec Titan Email"},
    {"type":"paragraph","text":"WP Mail SMTP → Settings → Mailer : **Other SMTP**."},
    {"type":"table","table":{
      "headers":["Paramètre","Valeur"],
      "rows":[
        ["Host","mail.titan.email"],
        ["Port","587"],
        ["Encryption","TLS"],
        ["Username","email@domaineclient.com"],
        ["Password","[mot de passe Titan]"],
        ["From Name","[Nom Client]"],
        ["From Email","email@domaineclient.com"]
      ]
    }},
    {"type":"callout","variant":"warning","title":"Important","text":"Utiliser l'adresse email du **client** créée dans Titan, pas celle de Next Gital. Cliquer « Send Test Email » pour vérifier."},

    {"type":"heading2","text":"6. Activer SSL et forcer HTTPS"},
    {"type":"paragraph","text":"hPanel → SSL → Let's Encrypt → Installer. Attendre 5 min. WordPress → Réglages → Général : changer les 2 URLs en `https://`. Ajouter dans `wp-config.php` au-dessus de « That is all » :"},
    {"type":"code","text":"define('FORCE_SSL_ADMIN', true);"},
    {"type":"paragraph","text":"Vérifier le cadenas vert dans le navigateur."},

    {"type":"heading2","text":"7. UpdraftPlus — sauvegarde automatique"},
    {"type":"paragraph","text":"UpdraftPlus → Settings :"},
    {"type":"list","items":[
      "**Fichiers** : hebdomadaire",
      "**Base de données** : quotidien",
      "Conserver **4 copies**",
      "Destination : Google Drive Next Gital → `/Backups/[NomClient]/`",
      "Lancer une sauvegarde **manuelle** immédiatement pour vérifier"
    ]},

    {"type":"heading2","text":"8. Noter les accès dans GestiQ"},
    {"type":"paragraph","text":"GestiQ → Fiche client → onglet « Accès » :"},
    {"type":"list","items":[
      "URL wp-admin + identifiant + mot de passe WordPress",
      "URL hPanel + identifiant + mot de passe Hostinger",
      "Email Titan + mot de passe"
    ]},
    {"type":"callout","variant":"danger","title":"Jamais","text":"Ne jamais stocker les mots de passe dans WhatsApp ou Drive non sécurisé."},

    {"type":"divider"},

    {"type":"heading","text":"Message — confirmation au Chef de projet"},
    {"type":"template","text":"✅ Installation WordPress terminée pour [NOM CLIENT]\n\n🌐 URL staging : staging.[DOMAINE].com\n🔐 Admin : [URL]/wp-admin\n📧 Email SMTP : configuré avec Titan Email\n🔒 SSL : actif\n💾 Backup : configuré (quotidien BDD / hebdo fichiers)\n\nPrêt pour le développement du thème. Je commence le design demain matin."},

    {"type":"divider"},

    {"type":"heading","text":"Checklist d'installation"},
    {"type":"checklist","items":[
      "Domaine / sous-domaine créé dans hPanel",
      "WordPress installé via Auto Installer",
      "Configuration de base WordPress (timezone, permaliens, langue)",
      "7 plugins essentiels installés et activés",
      "WP Mail SMTP configuré avec Titan Email — test d'envoi réussi",
      "SSL Let's Encrypt actif — HTTPS forcé",
      "UpdraftPlus configuré — 1ère sauvegarde manuelle réussie",
      "Tous les accès notés dans GestiQ (fiche client)"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-dev-wp-hostinger');


-- ── ng-dev-elementor-vitrine (dev) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-dev-elementor-vitrine',
  'Développement site vitrine — Standards Elementor Next Gital',
  'Construction d''un site vitrine avec Elementor : kit de marque, theme builder, sections, SEO, perf.',
  'dev',
  '["Elementor","WordPress","Design","Vitrine","Standards"]'::jsonb,
  'Next Gital',
  6,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Jours 2–10 du projet (selon package)."},
    {"type":"callout","variant":"info","title":"Canal","text":"VS Code + WordPress Admin + Elementor + Claude Code."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Site livré dans les délais avec un score PageSpeed ≥ 80 sur mobile."},
    {"type":"callout","variant":"warning","title":"Note","text":"Utiliser Claude Code pour générer le CSS personnalisé, les snippets PHP et les fonctions WordPress. Toujours tester chaque section sur mobile avant de passer à la suivante."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Kit de marque dans Elementor"},
    {"type":"paragraph","text":"Elementor → Site Settings → **Global Colors** : ajouter les couleurs HEX du brief client. **Global Fonts** : 2 polices Google Fonts maximum (1 titre + 1 corps). Ces réglages s'appliquent automatiquement à tout le site."},
    {"type":"list","items":["Temps : ~15 min"]},

    {"type":"heading2","text":"2. Header & Footer avec Theme Builder"},
    {"type":"paragraph","text":"Elementor → Theme Builder."},
    {"type":"list","items":[
      "**Header** : logo (SVG/PNG transparent), menu, bouton CTA WhatsApp",
      "**Footer** : logo, coordonnées, réseaux sociaux, liens rapides, copyright avec `[year]` dynamique",
      "Affichage : site entier",
      "Valider la responsivité **mobile** avant de continuer"
    ]},
    {"type":"list","items":["Temps : ~1h"]},

    {"type":"heading2","text":"3. Page d'accueil — 8 sections standards"},
    {"type":"paragraph","text":"Construction dans cet ordre :"},
    {"type":"steps","items":[
      "Hero — titre accrocheur + CTA + image",
      "Problème / Solution",
      "Services (3–4 cards)",
      "Preuves sociales (chiffres clés)",
      "Portfolio / Réalisations (si applicable)",
      "Témoignages clients",
      "FAQ (accordéon)",
      "CTA final (WhatsApp + formulaire)"
    ]},
    {"type":"paragraph","text":"Utiliser Claude Code pour générer les animations CSS et les effets hover."},
    {"type":"list","items":["Temps : ~3–4h"]},

    {"type":"heading2","text":"4. Pages secondaires"},
    {"type":"list","items":[
      "**À propos** — histoire, équipe, valeurs",
      "**Services** — une section par service avec CTA",
      "**Réalisations / Portfolio**",
      "**Contact** — formulaire CF7 + Google Maps + coordonnées"
    ]},
    {"type":"paragraph","text":"Utiliser les mêmes blocs globaux pour header/footer sur toutes les pages."},
    {"type":"list","items":["Temps : ~2–3h"]},

    {"type":"heading2","text":"5. Yoast SEO — page par page"},
    {"type":"list","items":[
      "SEO Title : 60 caractères max",
      "Meta Description : 155 caractères max",
      "Focus Keyphrase pour chaque page",
      "Page d'accueil : nom client + ville + activité"
    ]},
    {"type":"quote","text":"Exemple : « Dr Karim Médecin Dentiste Oujda | Cabinet [Nom] »"},
    {"type":"paragraph","text":"Yoast → Features → activer **XML Sitemap**. Soumettre à Google Search Console."},

    {"type":"heading2","text":"6. Optimisation images & performance"},
    {"type":"list","items":[
      "Format **WebP** (Squoosh.app si conversion nécessaire)",
      "Taille max **200Ko** par image",
      "Dimensions max **1920px**",
      "LiteSpeed Cache : Page Cache + Image Optimization + CSS/JS Minification + Lazy Load",
      "Tester sur **GTmetrix** — score A ou B obligatoire"
    ]},
    {"type":"callout","variant":"danger","title":"Bloquant","text":"Si score GTmetrix < 80 → optimiser avant livraison. Pas de livraison sans score ≥ 80 mobile."},

    {"type":"heading2","text":"7. Bouton WhatsApp flottant"},
    {"type":"paragraph","text":"Via Claude Code : générer un snippet PHP à ajouter dans `functions.php` du **thème enfant**."},
    {"type":"list","items":[
      "Numéro format international : **+212XXXXXXXXX**",
      "Message pré-rempli : « Bonjour [Nom Client], je vous contacte depuis votre site web. »",
      "Couleur : **#25D366**",
      "Position : bottom-right, z-index élevé",
      "Tester sur **iOS et Android**"
    ]},

    {"type":"heading2","text":"8. Google Analytics 4"},
    {"type":"paragraph","text":"Créer une propriété GA4 sur analytics.google.com (compte Next Gital en attendant transfert au client). Copier l'ID `G-XXXXXXXXXX`. Installer **MonsterInsights** (gratuit) ou coller via Elementor Custom Code. Vérifier la réception en temps réel."},

    {"type":"divider"},

    {"type":"heading","text":"Message — point d'avancement au Chef de projet (chaque soir)"},
    {"type":"template","text":"📊 Point développement — [NOM CLIENT] — [DATE]\n\n✅ Terminé aujourd'hui :\n— [SECTION 1]\n— [SECTION 2]\n\n🔄 En cours :\n— [SECTION EN COURS]\n\n📅 Demain :\n— [PROCHAINE ÉTAPE]\n\n⚠️ Blocage (si applicable) :\n— [BLOCAGE + CE QUI EST NÉCESSAIRE]\n\n🔗 Lien staging : staging.[DOMAINE].com"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist développement"},
    {"type":"checklist","items":[
      "Kit de marque configuré (couleurs + polices) dans Elementor",
      "Header et footer créés dans Theme Builder — responsive mobile vérifié",
      "Page d'accueil complète avec les 8 sections standards",
      "Pages secondaires créées (À propos, Services, Réalisations, Contact)",
      "Yoast SEO configuré sur toutes les pages",
      "Images optimisées (WebP, < 200Ko) — score GTmetrix ≥ 80",
      "Bouton WhatsApp flottant installé et testé mobile",
      "Google Analytics 4 installé — données reçues en temps réel"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-dev-elementor-vitrine');


-- ── ng-dev-woocommerce (dev) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-dev-woocommerce',
  'Installation et configuration WooCommerce',
  'Installation WooCommerce e-commerce : devise MAD, emails Titan, catalogue, paiements, commande test.',
  'dev',
  '["WooCommerce","Ecommerce","WordPress","Boutique","Paiement"]'::jsonb,
  'Next Gital',
  6,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Jours 1–3 d'un projet e-commerce."},
    {"type":"callout","variant":"info","title":"Canal","text":"WordPress Admin + VS Code + Claude Code."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Boutique en ligne fonctionnelle avec paiement, livraison et emails configurés."},
    {"type":"callout","variant":"warning","title":"Pré-requis hébergement","text":"Vérifier que le plan Hostinger est **Business ou supérieur**. Pour grandes boutiques : conseiller un **VPS via Dokploy**."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Installer et activer WooCommerce"},
    {"type":"paragraph","text":"Extensions → Ajouter → WooCommerce → Installer → Activer. L'assistant de configuration se lance."},
    {"type":"list","items":[
      "Pays : **Maroc**",
      "Devise : **MAD** (Dirham marocain)",
      "Type de produits : physiques / numériques / les deux",
      "Paiements : **Virement bancaire** + **Paiement à la livraison** pour commencer"
    ]},
    {"type":"callout","variant":"danger","title":"Ne pas activer","text":"PayPal ou Stripe si le client n'a pas de compte ouvert."},

    {"type":"heading2","text":"2. Paramètres WooCommerce"},
    {"type":"paragraph","text":"WooCommerce → Réglages :"},
    {"type":"list","items":[
      "**Général** : adresse magasin (client), pays vente, devise MAD (symbole : د.م., position : après le montant), séparateur décimal **virgule**",
      "**Produits** : activer les avis et la gestion de stock",
      "**TVA** : désactiver si client non assujetti (cas de la majorité des PME marocaines)",
      "**Livraison** : créer zone « Maroc » avec tarifs définis par le client"
    ]},

    {"type":"heading2","text":"3. Emails transactionnels avec Titan Email"},
    {"type":"paragraph","text":"WooCommerce → Réglages → Emails. Pour chaque type d'email (nouvelle commande, confirmée, expédiée…) :"},
    {"type":"list","items":[
      "From Name = **Nom du client**",
      "From Email = email@domaineclient.com (Titan)",
      "Personnaliser le header avec logo client + couleurs marque",
      "**Tester chaque email** en passant une fausse commande"
    ]},

    {"type":"heading2","text":"4. Catégories + premiers produits"},
    {"type":"paragraph","text":"Produits → Catégories : créer l'arborescence du brief client. Puis créer les produits :"},
    {"type":"list","items":[
      "Titre optimisé SEO",
      "Description courte (150 mots) + description longue",
      "Photos : minimum **3 par produit**, fond blanc recommandé",
      "Prix HT et TTC",
      "SKU + stock",
      "Poids et dimensions si livraison physique"
    ]},
    {"type":"paragraph","text":"Utiliser **Claude Code** pour générer les descriptions produits en masse."},
    {"type":"list","items":["Temps : ~2–4h selon catalogue"]},

    {"type":"heading2","text":"5. Personnaliser les pages WooCommerce"},
    {"type":"paragraph","text":"Avec Elementor Pro (ou Elementor + plugin) : personnaliser **boutique**, **page produit unique**, **panier**, **checkout**. Simplifier le checkout au maximum (supprimer les champs non nécessaires)."},

    {"type":"heading2","text":"6. Plugins complémentaires (selon besoins)"},
    {"type":"list","items":[
      "**WooCommerce PDF Invoices** — factures PDF automatiques",
      "**WooCommerce Multilingual** — si bilingue",
      "**YITH Wishlist** — liste de souhaits",
      "**Variation Swatches** — attributs visuels",
      "**CartFlows** — tunnel de vente amélioré si demandé"
    ]},
    {"type":"callout","variant":"warning","title":"Avant activation","text":"Tester la compatibilité de chaque plugin sur staging avant la production."},

    {"type":"heading2","text":"7. Commande test complète"},
    {"type":"paragraph","text":"Activer le **mode test** (Réglages → Avancé). Passer une commande complète :"},
    {"type":"numbered","items":[
      "Sélectionner un produit",
      "Ajouter au panier",
      "Checkout",
      "Choisir virement bancaire",
      "Confirmer"
    ]},
    {"type":"paragraph","text":"Vérifier : email confirmation client, email nouvelle commande admin, mise à jour stock, apparition dans WooCommerce → Commandes."},
    {"type":"callout","variant":"danger","title":"Avant la mise en ligne","text":"**Désactiver le mode test** — sinon les vraies commandes ne fonctionneront pas."},

    {"type":"divider"},

    {"type":"heading","text":"Message au client — infos nécessaires pour la boutique"},
    {"type":"template","text":"Bonjour [Prénom] 👋\n\nPour configurer votre boutique en ligne, j'ai besoin des informations suivantes :\n\n🏪 Boutique :\n• Nom exact de la boutique\n• Adresse complète (pour les factures)\n• Email boutique (ex: boutique@votrenom.com)\n\n📦 Livraison :\n• Zones de livraison (Oujda uniquement / tout le Maroc / international)\n• Tarifs de livraison par zone\n• Délais de livraison\n\n💳 Paiement :\n• Modes acceptés (virement, à la livraison, carte bancaire)\n• RIB pour le virement bancaire\n\n📋 Catalogue :\n• Fichier Excel avec tous les produits (nom, prix, description, SKU)\n• Photos des produits (minimum 3 par produit)\n\nDélai pour recevoir ces infos : [DATE + 5 JOURS]\n\nMerci 🙏"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist WooCommerce"},
    {"type":"checklist","items":[
      "WooCommerce installé et assistant de configuration complété",
      "Paramètres : devise MAD, pays Maroc, TVA selon situation client",
      "Emails transactionnels configurés avec Titan Email — tests réussis",
      "Catégories créées selon l'arborescence du brief",
      "Produits créés avec photos, descriptions, prix et stock",
      "Pages WooCommerce personnalisées avec Elementor",
      "Commande test complète effectuée et validée",
      "Mode test désactivé avant la mise en ligne"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-dev-woocommerce');


-- ── ng-dev-dokploy (dev) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-dev-dokploy',
  'Déploiement et gestion VPS avec Dokploy',
  'Déploiement d''applications sur VPS Hostinger via Dokploy : projet, env vars, domaine, SSL, backups.',
  'dev',
  '["Dokploy","VPS","Déploiement","Docker","Production"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Selon les besoins du projet (sites performants ou GestiQ)."},
    {"type":"callout","variant":"info","title":"Canal","text":"VS Code + Claude Code + Dokploy + VPS Hostinger."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Application déployée sur VPS, accessible en HTTPS, avec monitoring actif."},
    {"type":"callout","variant":"warning","title":"Quand utiliser Dokploy","text":"Pour GestiQ et apps custom (Node.js). Pour sites WordPress simples → **Hostinger mutualisé**. Dokploy pour les projets nécessitant plus de contrôle."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Accès VPS et Dokploy"},
    {"type":"paragraph","text":"SSH au VPS :"},
    {"type":"code","text":"ssh root@[IP_VPS]"},
    {"type":"paragraph","text":"Ou interface Dokploy : `http://[IP_VPS]:3000`. Si Dokploy down :"},
    {"type":"code","text":"cd /opt/dokploy && docker compose up -d"},

    {"type":"heading2","text":"2. Créer un nouveau projet Dokploy"},
    {"type":"paragraph","text":"Dokploy Dashboard → Projects → New Project. Renseigner nom (ex: `nextgital-gestiq`) et description. Puis Add Service :"},
    {"type":"list","items":[
      "**Application** — si depuis Git",
      "**Docker Compose** — si fichier compose",
      "**WordPress** — si site WP"
    ]},
    {"type":"paragraph","text":"Connecter le dépôt GitHub/GitLab si applicable."},

    {"type":"heading2","text":"3. Variables d'environnement"},
    {"type":"paragraph","text":"Dokploy → Service → Environment. Variables typiques :"},
    {"type":"list","items":[
      "`DATABASE_URL`",
      "`JWT_SECRET` (≥ 32 caractères)",
      "`ANTHROPIC_API_KEY` — pour le Conseiller IA GestiQ",
      "`NODE_ENV=production`",
      "`PORT`",
      "Variables spécifiques au projet"
    ]},
    {"type":"callout","variant":"danger","title":"Jamais","text":"Variables d'environnement dans le code ou commitées dans Git. Maintenir `.env.example` à jour dans le dépôt."},

    {"type":"heading2","text":"4. Domaine et SSL"},
    {"type":"paragraph","text":"Dokploy → Service → Domains → Add Domain :"},
    {"type":"list","items":[
      "Ajouter le domaine (ex: `app.nextgital.tech`)",
      "Activer **Let's Encrypt** pour SSL automatique",
      "Vérifier le DNS (record A → IP VPS)",
      "Attendre la propagation (5 min à 24h)",
      "Tester l'accès HTTPS"
    ]},

    {"type":"heading2","text":"5. Premier déploiement"},
    {"type":"paragraph","text":"Dokploy → Service → Deploy. Surveiller les logs **en temps réel** :"},
    {"type":"list","items":[
      "L'application démarre sans erreurs",
      "Le domaine HTTPS est accessible",
      "Connexions à la base de données fonctionnent",
      "Emails fonctionnent (si applicable)"
    ]},
    {"type":"callout","variant":"warning","title":"En cas d'erreur","text":"Lire les **logs complets** avant de modifier quoi que ce soit."},

    {"type":"heading2","text":"6. Sauvegardes automatiques"},
    {"type":"paragraph","text":"Dokploy → Service → Backups (si dispo) ou cron sur le VPS :"},
    {"type":"list","items":[
      "PostgreSQL : `pg_dump` automatique toutes les 24h → Google Drive via **rclone**",
      "Fichiers : `tar` hebdomadaire",
      "**Tester la restauration une fois par mois**"
    ]},

    {"type":"heading2","text":"7. Workflow de déploiement continu"},
    {"type":"paragraph","text":"À chaque mise à jour du code :"},
    {"type":"numbered","items":[
      "Tester en local ou sur staging",
      "Push sur GitHub",
      "Dokploy redéploie automatiquement (si GitHub Actions) OU cliquer « Redeploy »",
      "Vérifier les logs après redéploiement",
      "Tester les fonctionnalités impactées"
    ]},
    {"type":"callout","variant":"success","title":"Downtime","text":"~30 secondes avec Dokploy (rolling update)."},

    {"type":"divider"},

    {"type":"heading","text":"Message — déploiement réussi (au fondateur)"},
    {"type":"template","text":"✅ Déploiement réussi — [NOM PROJET]\n\n🌐 URL : https://[DOMAINE]\n🔒 SSL : actif (Let's Encrypt)\n🐳 Service Dokploy : en ligne\n💾 Sauvegardes : configurées\n📊 Monitoring : actif\n\nVersion déployée : [VERSION / COMMIT]\nDurée du déploiement : [X min]\n\nTous les tests passent ✅"},

    {"type":"heading","text":"Message — erreur de déploiement"},
    {"type":"template","text":"⚠️ Erreur de déploiement — [NOM PROJET]\n\n❌ Erreur rencontrée :\n[COPIER LE MESSAGE D'ERREUR EXACT]\n\n🔍 Investigation en cours.\n📋 Logs complets : [LIEN OU CAPTURE]\n\n⏰ Downtime depuis : [HEURE]\n🔧 Action en cours : [CE QUI EST FAIT]"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist déploiement"},
    {"type":"checklist","items":[
      "Accès VPS et Dokploy vérifiés",
      "Projet créé dans Dokploy",
      "Variables d'environnement configurées (aucune en dur dans le code)",
      "Domaine et SSL configurés — HTTPS accessible",
      "Premier déploiement réussi — logs sans erreur",
      "Sauvegardes automatiques configurées et testées",
      "Workflow de déploiement documenté dans GestiQ"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-dev-dokploy');


-- ── ng-dev-titan-email (dev) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-dev-titan-email',
  'Configuration Titan Email — Email professionnel client',
  'Création boîte Titan, enregistrements DNS (MX, SPF, DKIM, DMARC), SMTP WordPress, formation client.',
  'dev',
  '["TitanEmail","Email","Professionnel","DNS","Configuration"]'::jsonb,
  'Next Gital',
  4,
  false,
  $sop$[
    {"type":"callout","variant":"info","title":"Délai","text":"Inclus dans tout projet — à faire dès la création du domaine."},
    {"type":"callout","variant":"info","title":"Canal","text":"Titan Email Panel + hPanel Hostinger + VS Code."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Client dispose d'un email @sondomaine.com fonctionnel et professionnel."},
    {"type":"callout","variant":"warning","title":"Note","text":"L'email professionnel est inclus dans tous les packages Next Gital. Le créer dès que le domaine est actif — avant même de finir le site."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Créer le compte Titan Email"},
    {"type":"paragraph","text":"hPanel Hostinger → Emails → Titan Email → Gérer. Si première utilisation : créer un compte Titan (gratuit avec hébergement Hostinger). Choisir le domaine du client."},
    {"type":"list","items":[
      "Format recommandé : `contact@nomclient.com` ou `info@nomclient.com`",
      "Mot de passe fort : **16+ caractères**",
      "**Noter immédiatement dans GestiQ**"
    ]},

    {"type":"heading2","text":"2. Enregistrements DNS"},
    {"type":"paragraph","text":"hPanel → DNS Zone → Ajouter les enregistrements Titan :"},
    {"type":"table","table":{
      "headers":["Type","Valeur"],
      "rows":[
        ["MX","Fourni par Titan (priorités 1, 5, 10)"],
        ["TXT (SPF)","v=spf1 include:spf.titan.email ~all"],
        ["TXT (DKIM)","Clé fournie par Titan"],
        ["TXT (DMARC)","v=DMARC1; p=quarantine; rua=mailto:admin@nomclient.com"]
      ]
    }},
    {"type":"callout","variant":"warning","title":"Propagation","text":"Attendre 24h pour propagation DNS complète. Vérifier avec mxtoolbox.com."},

    {"type":"heading2","text":"3. Test envoi et réception"},
    {"type":"paragraph","text":"Depuis le webmail Titan (mail.titan.email) :"},
    {"type":"numbered","items":[
      "Envoyer un email de test à `info@nextgital.com`",
      "Répondre depuis `info@nextgital.com`",
      "Vérifier la réception dans les **deux sens**",
      "Tester aussi depuis Gmail et Outlook"
    ]},
    {"type":"callout","variant":"warning","title":"Si emails en spam","text":"Vérifier les enregistrements **SPF, DKIM, DMARC** — souvent une typo ou une propagation incomplète."},

    {"type":"heading2","text":"4. WordPress SMTP avec Titan"},
    {"type":"paragraph","text":"WP Mail SMTP → Settings → Other SMTP :"},
    {"type":"table","table":{
      "headers":["Paramètre","Valeur"],
      "rows":[
        ["SMTP Host","mail.titan.email"],
        ["SMTP Port","587"],
        ["Encryption","TLS"],
        ["Auto TLS","ON"],
        ["Authentication","ON"],
        ["SMTP Username","email@nomclient.com"],
        ["SMTP Password","[mot de passe Titan]"]
      ]
    }},
    {"type":"paragraph","text":"Cliquer « Send Test Email ». Si erreur : essayer **port 465 avec SSL** comme alternative."},

    {"type":"heading2","text":"5. Signature email professionnelle"},
    {"type":"paragraph","text":"Titan Webmail → Settings → Signature. Signature HTML avec :"},
    {"type":"list","items":[
      "Logo client (hébergé sur le site)",
      "Nom complet + poste",
      "Numéro de téléphone",
      "Adresse + site web",
      "**Taille logo : 120px max** de largeur"
    ]},
    {"type":"paragraph","text":"Utiliser Claude Code pour générer le HTML de la signature."},

    {"type":"heading2","text":"6. Formation client (Loom)"},
    {"type":"paragraph","text":"Enregistrer une vidéo Loom de 3 min montrant :"},
    {"type":"list","items":[
      "Connexion au webmail (mail.titan.email)",
      "Envoyer un email + répondre",
      "Créer des dossiers",
      "Configurer sur iPhone (IMAP)",
      "Configurer sur Android"
    ]},
    {"type":"paragraph","text":"Inclure la vidéo dans le dossier Drive de livraison."},

    {"type":"divider"},

    {"type":"heading","text":"Message au client — livraison de l'email"},
    {"type":"template","text":"Bonjour [Prénom] 😊\n\nVotre email professionnel est maintenant actif !\n\n📧 Votre adresse email : [EMAIL@DOMAINE.COM]\n🔐 Mot de passe : [voir dossier Drive sécurisé]\n🌐 Webmail : https://mail.titan.email\n\nPour consulter vos emails sur votre téléphone :\n• App Titan Mail (iOS & Android) — recommandée\n• Ou configurez votre client mail préféré (IMAP)\n\nJ'ai joint une vidéo rapide (3 min) qui explique tout :\n🎥 [LIEN VIDÉO LOOM]\n\nN'hésitez pas si vous avez des questions 🙏"},

    {"type":"divider"},

    {"type":"heading","text":"Checklist Titan Email"},
    {"type":"checklist","items":[
      "Compte Titan Email créé dans hPanel",
      "Boîte email client@domaine.com créée avec mot de passe fort",
      "Enregistrements DNS configurés (MX, SPF, DKIM, DMARC)",
      "Test envoi et réception réussi dans les deux sens",
      "WP Mail SMTP configuré — test WordPress réussi",
      "Signature email créée avec logo et coordonnées",
      "Accès notés dans GestiQ (fiche client)",
      "Vidéo tuto Loom enregistrée et partagée"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-dev-titan-email');


-- ── ng-dev-claude-codex-workflow (dev) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-dev-claude-codex-workflow',
  'Workflow développement — Claude Code + Codex + VS Code',
  'Workflow IA pour le dev : contexte projet, CSS Elementor, PHP WordPress, débogage, règles d''usage.',
  'dev',
  '["ClaudeCode","Codex","VSCode","IA","Workflow","Productivité"]'::jsonb,
  'Next Gital',
  5,
  true,
  $sop$[
    {"type":"callout","variant":"info","title":"Usage","text":"Quotidien."},
    {"type":"callout","variant":"info","title":"Canal","text":"VS Code + Claude Code + Codex."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Multiplier la productivité de développement par 3 grâce à l'IA."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Claude Code et Codex sont des outils d'assistance — toujours relire et comprendre le code généré avant de l'utiliser en production. Ne jamais copier-coller du code IA sans le tester."},

    {"type":"heading","text":"Étapes — dans l'ordre"},

    {"type":"heading2","text":"1. Démarrer chaque projet avec le contexte complet"},
    {"type":"paragraph","text":"Avant de commencer à coder : donner à Claude Code le contexte complet du projet (voir le prompt de démarrage plus bas)."},

    {"type":"heading2","text":"2. CSS personnalisé Elementor"},
    {"type":"paragraph","text":"Prompt type :"},
    {"type":"quote","text":"« Génère le CSS pour [EFFET SOUHAITÉ] compatible avec Elementor. Le sélecteur CSS doit utiliser la class Elementor. La couleur principale est [HEX]. Responsive : mobile d'abord, breakpoint 768px. Ajouter des commentaires. »"},
    {"type":"paragraph","text":"Coller le CSS dans Elementor → Site Settings → Custom CSS. **Tester sur mobile après chaque ajout.**"},

    {"type":"heading2","text":"3. Snippets PHP WordPress"},
    {"type":"paragraph","text":"Prompt type :"},
    {"type":"quote","text":"« Écris une fonction PHP WordPress qui [FONCTIONNALITÉ]. Utilise les bonnes pratiques WordPress : hooks, sanitization, nonce si formulaire. Compatible PHP 8.x. Ajouter des commentaires. La fonction va dans functions.php du thème enfant. »"},
    {"type":"callout","variant":"danger","title":"Jamais","text":"Modifier les fichiers du thème **parent**. Toujours créer un thème enfant avant d'ajouter du PHP."},

    {"type":"heading2","text":"4. Contenu produits WooCommerce (Codex)"},
    {"type":"paragraph","text":"Pour les descriptions produits, prompt :"},
    {"type":"quote","text":"« Rédige une description courte (150 mots) et une description longue (300 mots) pour ce produit : [NOM PRODUIT]. Secteur : [SECTEUR]. Public cible : [CIBLE]. Langue : français marocain professionnel. Inclure les mots-clés : [MOTS CLÉS SEO]. Format : HTML simple avec balises p et ul. »"},
    {"type":"paragraph","text":"Générer **10 descriptions à la fois** pour gagner du temps. ~1h pour 20 produits."},

    {"type":"heading2","text":"5. Déboguer les erreurs"},
    {"type":"paragraph","text":"Copier l'erreur complète (message + stack trace) avec le contexte :"},
    {"type":"quote","text":"« J'ai cette erreur sur mon site WordPress : [ERREUR]. Voici le code concerné : [CODE]. Stack : WordPress + Elementor + [plugins actifs]. Comment corriger ? »"},
    {"type":"callout","variant":"warning","title":"Règle","text":"Ne jamais modifier du code en production sans avoir compris la correction. Toujours tester sur **staging** d'abord."},

    {"type":"heading2","text":"6. Règles d'utilisation non négociables"},
    {"type":"numbered","items":[
      "Toujours **relire** le code généré avant de l'utiliser",
      "Ne **jamais** coller du code IA directement en production — tester sur staging d'abord",
      "**Comprendre** ce que fait le code avant de l'utiliser",
      "Garder une **trace** de chaque modification (commentaire avec date + raison)",
      "Pour les fonctions critiques (paiement, sécurité) : **deuxième paire d'yeux** obligatoire"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Prompt de démarrage projet — Claude Code"},
    {"type":"template","text":"CONTEXTE DU PROJET :\nClient : [NOM CLIENT]\nSecteur : [SECTEUR]\nVille : [VILLE], Maroc\nType de projet : [Site vitrine / E-commerce / Refonte]\n\nSTACK TECHNIQUE :\n- WordPress [VERSION]\n- Elementor Pro\n- Yoast SEO\n- [WooCommerce si applicable]\n- Hébergement : Hostinger [mutualisé / VPS]\n- Email : Titan Email\n\nKIT DE MARQUE :\n- Couleur principale : [HEX]\n- Couleur secondaire : [HEX]\n- Police titre : [NOM]\n- Police corps : [NOM]\n\nMON OBJECTIF MAINTENANT :\n[DÉCRIRE LA TÂCHE PRÉCISE]\n\nContraintes :\n- Mobile-first\n- Performance : score PageSpeed ≥ 80\n- Compatible avec Elementor (utiliser les classes .elementor-*)\n- Code commenté en français"},

    {"type":"heading","text":"Prompt débogage WordPress — Claude Code"},
    {"type":"template","text":"J'ai une erreur sur mon site WordPress. Aide-moi à la résoudre.\n\nERREUR EXACTE :\n[COPIER LE MESSAGE D'ERREUR COMPLET]\n\nCONTEXTE :\n- WordPress version : [VERSION]\n- Thème actif : [NOM THÈME]\n- Plugins actifs : [LISTE]\n- Hébergement : Hostinger\n- L'erreur se produit quand : [ACTION QUI DÉCLENCHE L'ERREUR]\n\nCODE CONCERNÉ :\n[COLLER LE CODE SI APPLICABLE]\n\nExplique la cause de l'erreur et propose la correction la plus simple et la plus sûre."},

    {"type":"divider"},

    {"type":"heading","text":"Checklist usage IA"},
    {"type":"checklist","items":[
      "Contexte complet donné à Claude Code en début de session",
      "Code généré relu et compris avant utilisation",
      "Tests sur staging avant toute mise en production",
      "CSS personnalisé testé sur mobile iOS et Android",
      "Fonctions PHP dans le thème enfant (jamais dans le thème parent)",
      "Erreurs déboguées avec Claude Code — solution comprise",
      "Commentaires ajoutés dans le code (date + raison des modifications)"
    ]}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-dev-claude-codex-workflow');


-- ── ng-dev-qa-checklist (dev) ────
INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)
SELECT t.id,
  'ng-dev-qa-checklist',
  'QA technique avant livraison — Checklist développeur',
  'Audit technique avant remise au client : performance, sécurité, SEO, responsive, sauvegardes.',
  'dev',
  '["QA","Tests","Performance","Sécurité","Livraison"]'::jsonb,
  'Next Gital',
  4,
  false,
  $sop$[
    {"type":"callout","variant":"warning","title":"Délai","text":"Avant chaque livraison — bloquant pour la mise en ligne."},
    {"type":"callout","variant":"info","title":"Canal","text":"Navigateur + GTmetrix + Wordfence + Yoast."},
    {"type":"callout","variant":"tip","title":"Objectif","text":"Zéro bug · Zéro régression · Performance et sécurité validées."},
    {"type":"callout","variant":"danger","title":"Règle absolue","text":"Aucun item de la checklist ne peut être ignoré. Si un point échoue → corriger avant livraison."},

    {"type":"heading","text":"Performance"},
    {"type":"checklist","items":[
      "GTmetrix mobile : score A ou B (≥ 80)",
      "GTmetrix desktop : score A (≥ 90)",
      "PageSpeed Insights mobile : ≥ 80",
      "Temps de chargement < 2 secondes (3G mobile)",
      "Toutes les images en WebP, < 200Ko chacune",
      "CSS et JS minifiés (LiteSpeed Cache / WP Rocket)",
      "Lazy loading actif sur images et iframes"
    ]},

    {"type":"heading","text":"Sécurité"},
    {"type":"checklist","items":[
      "Wordfence scan complet — 0 alerte critique",
      "Mots de passe admin forts (16+ caractères)",
      "wp-config.php : préfixe table custom (pas `wp_`)",
      "wp-config.php : `DISALLOW_FILE_EDIT` activé en prod",
      "Versions WordPress / plugins / thèmes à jour",
      "Limite tentatives de connexion activée",
      "SSL Let's Encrypt actif — HSTS recommandé"
    ]},

    {"type":"heading","text":"SEO"},
    {"type":"checklist","items":[
      "Yoast SEO : titre + meta description sur **toutes** les pages",
      "Sitemap XML accessible (/sitemap_index.xml)",
      "Google Search Console : site soumis et indexé",
      "Robots.txt configuré correctement",
      "URLs propres (slug en kebab-case, sans accents)",
      "Balises H1/H2/H3 hiérarchisées",
      "Texte alternatif (alt) sur toutes les images"
    ]},

    {"type":"heading","text":"Responsive"},
    {"type":"checklist","items":[
      "iPhone Safari (375px) — testé",
      "iPhone Chrome — testé",
      "Android Chrome (360px / 412px) — testé",
      "Tablette (768px) — testé",
      "Desktop Chrome (1920px) — testé",
      "Desktop Firefox + Safari — testé",
      "Menu mobile fonctionne (hamburger)",
      "Bouton WhatsApp visible et cliquable sur mobile"
    ]},

    {"type":"heading","text":"Fonctionnel"},
    {"type":"checklist","items":[
      "Tous les liens internes fonctionnent (pas de 404)",
      "Tous les liens externes ouvrent dans un nouvel onglet",
      "Formulaire de contact : envoi testé + email reçu",
      "Bouton WhatsApp : numéro et message corrects",
      "Google Maps affichée (si page contact)",
      "Réseaux sociaux : liens corrects et fonctionnels",
      "WooCommerce (si applicable) : commande test passée"
    ]},

    {"type":"heading","text":"Sauvegardes & Accès"},
    {"type":"checklist","items":[
      "Backup complet pris **juste avant** la livraison",
      "UpdraftPlus actif — destination Drive vérifiée",
      "Accès admin notés dans GestiQ (fiche client)",
      "Email Titan créé et testé",
      "Domaine principal pointé sur le site (DNS)",
      "Redirection `www` ↔ non-www configurée"
    ]},

    {"type":"divider"},

    {"type":"heading","text":"Outils de test"},
    {"type":"table","table":{
      "headers":["Outil","URL","Usage"],
      "rows":[
        ["GTmetrix","gtmetrix.com","Performance globale"],
        ["PageSpeed Insights","pagespeed.web.dev","Performance Google"],
        ["Wordfence","Plugin WP","Scan sécurité"],
        ["Google Search Console","search.google.com/search-console","Indexation SEO"],
        ["MX Toolbox","mxtoolbox.com","Vérification DNS / email"],
        ["BrowserStack","browserstack.com","Tests multi-navigateurs"]
      ]
    }},

    {"type":"divider"},

    {"type":"heading","text":"Message — feu vert au Chef de projet"},
    {"type":"template","text":"✅ QA technique terminé — [NOM CLIENT]\n\n📊 Résultats :\n• PageSpeed mobile : [X]/100\n• PageSpeed desktop : [X]/100\n• Wordfence : 0 alerte critique\n• Tests responsive : OK iPhone, Android, tablette, desktop\n• Formulaire contact : OK\n• Commande test WooCommerce : OK [si applicable]\n• Backup juste avant livraison : ✅\n\n🚀 Le site est prêt pour la mise en ligne définitive."}
  ]$sop$::jsonb
FROM public.tenants t
WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = 'ng-dev-qa-checklist');

COMMIT;
