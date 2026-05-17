-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 039 : SOPs ultra-détaillés Développeur
--  Date : 2026-05-17
--  Auteur : Next Gital · Oujda
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ────────────────────────────────────────────────────────────────────
-- 1. ng-dev-wp-hostinger — Installation WordPress sur Hostinger
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏱️ Délai","text":"Installation complète WordPress + SSL + base sécurité : 45-60 minutes."},
  {"type":"callout","variant":"info","title":"📞 Canal","text":"Toute question hPanel/DNS → WhatsApp tech +212 620 002 066. Logs erreurs → Slack #dev-wordpress."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"JAMAIS installer WP sans SSL actif AVANT. Si tu installes en HTTP puis migres HTTPS → liens cassés. Active SSL EN PREMIER dans hPanel."},
  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. CONNEXION hPANEL HOSTINGER"},
  {"type":"paragraph","text":"🎯 Objectif : Accéder au panneau Hostinger du client. ⏱️ Temps : 3 min."},
  {"type":"paragraph","text":"📍 Point de départ : Brief client signé + accès Hostinger reçus (email/mdp ou accès délégué)."},
  {"type":"paragraph","text":"🖥️ OÙ : https://hpanel.hostinger.com"},
  {"type":"numbered","items":["Ouvre Chrome → mode incognito (évite cache ancien client)","Va sur hpanel.hostinger.com","Connecte-toi avec email/mdp client","Si 2FA → demande code OTP au client via WhatsApp","Section « Hébergement » → clique sur le domaine concerné (ex : drkarim.ma)"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu vois le dashboard du domaine avec sections : Domaines, Emails, Bases de données, Fichiers, SSL."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"« Accès refusé » → le client n'a pas activé l'accès délégué → demande-lui d'ajouter nextgital10@gmail.com via hPanel → Accès. Domaine introuvable → vérifier que le domaine est bien lié à l'hébergement."},
  {"type":"paragraph","text":"➡️ Étape suivante : activer SSL avant toute installation."},

  {"type":"heading2","text":"2. ACTIVER SSL GRATUIT (avant WP)"},
  {"type":"paragraph","text":"🎯 Objectif : Activer Let's Encrypt SSL avant install WP. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : hPanel ouvert sur le domaine."},
  {"type":"paragraph","text":"🖥️ OÙ : hPanel → Sécurité → SSL."},
  {"type":"numbered","items":["Clique « Sécurité » dans la sidebar gauche","Sous-menu « SSL »","Bouton « Installer SSL » → choisis « SSL gratuit Let's Encrypt »","Coche « Forcer HTTPS » → Activer","Attends ~3-5 minutes que le statut passe à « Actif »"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le statut SSL affiche « Actif » avec un cadenas vert. Tester en ouvrant https://drkarim.ma → cadenas Chrome vert."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"SSL bloqué sur « En attente » > 30 min → DNS pas propagé → vérifier nameservers Hostinger (ns1/ns2.dns-parking.com). Erreur « Domain not verified » → ajouter A record dans DNS Zone Editor."},
  {"type":"paragraph","text":"➡️ Étape suivante : créer la base de données MySQL."},

  {"type":"heading2","text":"3. CRÉER BASE DE DONNÉES MYSQL"},
  {"type":"paragraph","text":"🎯 Objectif : Créer DB + user MySQL pour WordPress. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : SSL actif."},
  {"type":"paragraph","text":"🖥️ OÙ : hPanel → Bases de données → MySQL."},
  {"type":"numbered","items":["hPanel → Bases de données → MySQL","Clique « Créer une nouvelle base »","Remplis les champs (voir CONTENU EXACT)","Note le mdp dans 1Password / Bitwarden (vault Next Gital)","Clique « Créer » → attends confirmation verte"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Nom de la base** → `u123_drkarim_wp` → format `uXXX_<slug>_wp` → ne PAS mettre d'espaces","**Nom utilisateur** → `u123_drkarim_adm` → identique préfixe → ne PAS réutiliser un user existant","**Mot de passe** → généré par hPanel (16 caractères) → copie-le dans 1Password → ne PAS mettre `admin123`"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"DB visible dans la liste MySQL avec statut « Active ». User assigné avec privilèges « ALL »."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"« Nom trop long » → max 16 caractères pour user MySQL → raccourcir le slug. Mot de passe oublié → impossible à récupérer → reset via hPanel → mettre à jour wp-config.php."},
  {"type":"paragraph","text":"➡️ Étape suivante : installer WordPress via Auto Installer."},

  {"type":"heading2","text":"4. INSTALLER WORDPRESS (AUTO INSTALLER)"},
  {"type":"paragraph","text":"🎯 Objectif : Installer WP 6.x via outil Hostinger. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : DB créée."},
  {"type":"paragraph","text":"🖥️ OÙ : hPanel → Site web → Installateur automatique."},
  {"type":"numbered","items":["hPanel → Site web → Installateur auto","Sélectionne « WordPress » (dernière version, ex 6.5)","Choisis le domaine (drkarim.ma) → laisse path vide (install racine)","Remplis les credentials admin (voir CONTENU EXACT)","Décoche « Installer LiteSpeed Cache » (on utilise WP Rocket)","Clique « Installer » → attends 2-3 min"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Titre site** → « Cabinet Dr. Karim » → titre commercial réel → ne PAS mettre « Mon site »","**Admin user** → `ng_admin_<slug>` → ex `ng_admin_karim` → JAMAIS `admin` ou `administrator`","**Mot de passe admin** → généré 20 char → 1Password → ne PAS réutiliser","**Email admin** → `info@nextgital.com` → on garde la main → pas l'email client tant que pas livré","**Langue** → Français (France)"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"https://drkarim.ma affiche le thème par défaut Twenty Twenty-Four. https://drkarim.ma/wp-admin → login fonctionne."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"« Installation failed » → DB déjà utilisée → créer nouvelle DB. Page blanche → vérifier permissions fichiers (755 dossiers, 644 fichiers) via File Manager."},
  {"type":"paragraph","text":"➡️ Étape suivante : sécuriser wp-config.php."},

  {"type":"heading2","text":"5. SÉCURISER wp-config.php"},
  {"type":"paragraph","text":"🎯 Objectif : Forcer HTTPS, désactiver éditeur fichiers, salts neufs. ⏱️ Temps : 8 min."},
  {"type":"paragraph","text":"📍 Point de départ : WP installé."},
  {"type":"paragraph","text":"🖥️ OÙ : hPanel → Fichiers → Gestionnaire fichiers → /public_html/wp-config.php"},
  {"type":"numbered","items":["File Manager → public_html → clic droit wp-config.php → Modifier","Génère nouveaux salts sur https://api.wordpress.org/secret-key/1.1/salt/","Remplace tout le bloc AUTH_KEY...NONCE_SALT par les nouveaux","Ajoute les 3 lignes de sécurité (voir CONTENU EXACT) AVANT la ligne `/* That's all */`","Sauvegarde (Ctrl+S) → ferme l'éditeur"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT à ajouter :"},
  {"type":"template","text":"define('FORCE_SSL_ADMIN', true);\ndefine('DISALLOW_FILE_EDIT', true);\ndefine('WP_AUTO_UPDATE_CORE', 'minor');\nif (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {\n    $_SERVER['HTTPS'] = 'on';\n}"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"wp-admin force HTTPS (essaie http://drkarim.ma/wp-admin → redirige). Apparence → Éditeur de thème = absent (DISALLOW_FILE_EDIT actif)."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Erreur 500 après modif → erreur syntaxe PHP → restaurer backup wp-config.php (Hostinger garde 7 jours). Boucle de redirection → enlever ligne FORCE_SSL si proxy mal configuré."},
  {"type":"paragraph","text":"➡️ Étape suivante : installer plugins essentiels."},

  {"type":"heading2","text":"6. INSTALLER PLUGINS ESSENTIELS"},
  {"type":"paragraph","text":"🎯 Objectif : Installer la stack NG standard. ⏱️ Temps : 12 min."},
  {"type":"paragraph","text":"📍 Point de départ : wp-admin accessible."},
  {"type":"paragraph","text":"🖥️ OÙ : wp-admin → Extensions → Ajouter."},
  {"type":"numbered","items":["Connecte-toi à drkarim.ma/wp-admin","Extensions → Ajouter","Installe + active chaque plugin (voir liste)","Pour plugins premium (Elementor Pro, WP Rocket) → upload .zip depuis vault NG","Configure les paramètres de base (voir étape 7)"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — plugins à installer :"},
  {"type":"list","items":["**Yoast SEO** (gratuit) → SEO on-page, sitemap","**WP Rocket** (premium NG) → cache + minify","**UpdraftPlus** (gratuit) → backups Google Drive","**WP Mail SMTP** (gratuit) → envois email via Titan","**Wordfence Security** (gratuit) → firewall + scan malware","**Elementor Pro** (premium NG) → builder visuel","**Loco Translate** (gratuit) → traduire plugins/thèmes FR"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"7 plugins actifs visibles dans Extensions → Installées. Aucun warning rouge."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"« Upload limit exceeded » pour plugin premium → augmenter via .htaccess : `php_value upload_max_filesize 64M`. Conflit plugin → désactiver un par un pour identifier le coupable."},
  {"type":"paragraph","text":"➡️ Étape suivante : configurer SMTP Titan."},

  {"type":"heading2","text":"7. CONFIGURER WP MAIL SMTP (TITAN)"},
  {"type":"paragraph","text":"🎯 Objectif : WP envoie emails via Titan Email du client. ⏱️ Temps : 7 min."},
  {"type":"paragraph","text":"📍 Point de départ : WP Mail SMTP actif + boîte Titan créée (voir SOP Titan)."},
  {"type":"paragraph","text":"🖥️ OÙ : wp-admin → WP Mail SMTP → Réglages."},
  {"type":"numbered","items":["WP Mail SMTP → Réglages → Général","Sélectionne « Other SMTP » comme mailer","Remplis les champs SMTP (voir CONTENU EXACT)","Sauvegarde","Onglet « Email Test » → envoie à info@nextgital.com → vérifie réception"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**From Email** → `contact@drkarim.ma` → adresse Titan créée → ne PAS mettre Gmail","**From Name** → « Cabinet Dr. Karim » → nom commercial","**SMTP Host** → `smtp.titan.email`","**Encryption** → SSL","**SMTP Port** → 465","**Authentication** → ON","**SMTP Username** → `contact@drkarim.ma` (email complet)","**SMTP Password** → mdp Titan (depuis 1Password)"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Email test reçu < 1 min avec headers Titan. Pas dans spam."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"« Connection refused » → vérifier port 465 (pas 587). Email dans spam → ajouter SPF + DKIM + DMARC dans DNS Hostinger (voir SOP Titan étape DNS)."},
  {"type":"paragraph","text":"➡️ Étape suivante : premier backup UpdraftPlus."},

  {"type":"heading2","text":"8. CONFIGURER UPDRAFTPLUS + 1ER BACKUP"},
  {"type":"paragraph","text":"🎯 Objectif : Backup quotidien sur Google Drive, garde 7 jours. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Plugins installés."},
  {"type":"paragraph","text":"🖥️ OÙ : wp-admin → Réglages → UpdraftPlus."},
  {"type":"numbered","items":["UpdraftPlus → Paramètres","Planning fichiers : « Tous les jours » → Conserver 7","Planning DB : « Tous les jours » → Conserver 7","Stockage distant : Google Drive → Authentifier avec backups@nextgital.com","Coche : Plugins, Thèmes, Uploads, Autres répertoires WP, Base de données","Sauvegarde paramètres","Onglet Sauvegarde → « Sauvegarder maintenant » → coche DB+Fichiers+remote → Lancer"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Backup terminé en < 5 min (site neuf). Visible dans Google Drive → dossier UpdraftPlus → drkarim.ma. 5 fichiers .zip + 1 .gz."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"« Auth Google failed » → re-faire OAuth en mode incognito. Backup partiel → augmenter memory_limit PHP à 512M dans hPanel → Avancé → PHP Config."},
  {"type":"paragraph","text":"➡️ Site prêt pour développement thème/contenu."},

  {"type":"divider"},
  {"type":"heading2","text":"Checklist de validation"},
  {"type":"checklist","items":["SSL actif + cadenas vert visible","HTTPS forcé partout (wp-admin redirige)","DB créée avec mdp dans 1Password","Admin user ≠ 'admin' (format ng_admin_xxx)","Salts wp-config régénérés","DISALLOW_FILE_EDIT activé","7 plugins essentiels installés + actifs","SMTP Titan configuré + test email reçu","UpdraftPlus : 1er backup Google Drive réussi","URL WP : Réglages → Général = https:// (pas http)","Permaliens : Réglages → /%postname%/","wp-admin user info dans Notion DB clients"]},
  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"> 30 min bloqué sur une étape → WhatsApp tech +212 620 002 066. JAMAIS supprimer/désinstaller WordPress sans validation lead dev."}
]$sop$::jsonb,
    read_min = 18,
    updated_at = now()
WHERE slug = 'ng-dev-wp-hostinger';

-- ────────────────────────────────────────────────────────────────────
-- 2. ng-dev-elementor-vitrine — Site vitrine Elementor
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏱️ Délai","text":"Site vitrine 5 pages standard : 6-8h dev. Ce SOP : structure + page d'accueil (2h)."},
  {"type":"callout","variant":"info","title":"📞 Canal","text":"Validation maquette → Designer. Bug Elementor → Slack #dev-wordpress."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"JAMAIS modifier le thème parent directement. TOUJOURS utiliser Hello Elementor + Customizer + Elementor. Sinon updates écraseront ton travail."},
  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. INSTALLER THÈME HELLO ELEMENTOR"},
  {"type":"paragraph","text":"🎯 Objectif : Thème minimal optimisé pour Elementor. ⏱️ Temps : 3 min."},
  {"type":"paragraph","text":"📍 Point de départ : WP installé (SOP wp-hostinger terminé)."},
  {"type":"paragraph","text":"🖥️ OÙ : wp-admin → Apparence → Thèmes → Ajouter."},
  {"type":"numbered","items":["Apparence → Thèmes → Ajouter","Recherche « Hello Elementor »","Installer → Activer","Supprime tous les autres thèmes (Twenty Twenty-Four, etc.) pour réduire attack surface","Vérifie : Apparence → Thèmes → Hello Elementor = actif"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Front-end (drkarim.ma) affiche page vierge minimaliste sans header/footer pré-définis."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Thème introuvable → vérifier connexion WP.org. Activation échoue → permissions /wp-content/themes/ = 755."},
  {"type":"paragraph","text":"➡️ Étape suivante : créer Global Site Settings."},

  {"type":"heading2","text":"2. ELEMENTOR — GLOBAL SITE SETTINGS"},
  {"type":"paragraph","text":"🎯 Objectif : Définir typo + couleurs globales (charte client). ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : Elementor Pro actif + charte graphique du client (PDF ou Figma)."},
  {"type":"paragraph","text":"🖥️ OÙ : wp-admin → Elementor → Site Settings."},
  {"type":"numbered","items":["Modifier n'importe quelle page avec Elementor","Menu hamburger en haut à gauche → Site Settings","Onglet « Global Colors » → définis 4 couleurs primaires (voir CONTENU EXACT)","Onglet « Global Fonts » → définis Primary + Secondary","Onglet « Theme Style » → règle Buttons + Forms par défaut","Sauvegarde"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT (exemple Dr. Karim — santé) :"},
  {"type":"list","items":["**Primary** → #0E7C7B (vert médical) → couleur de marque principale","**Secondary** → #F4A261 (orange chaleureux) → CTAs","**Text** → #2A2A2A (gris foncé) → corps de texte","**Accent** → #E76F51 (rouge corail) → highlights, badges","**Primary Font** → « Poppins » (Google Fonts) → titres → weight 600","**Secondary Font** → « Open Sans » → paragraphes → weight 400"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Site Settings → preview montre les couleurs/typo appliquées. Les sélecteurs couleur affichent les noms définis."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Couleurs ne s'appliquent pas → vider cache (WP Rocket → Settings → Clear Cache). Google Fonts pas chargées → cocher « Google Fonts » dans Elementor → Settings → Advanced."},
  {"type":"paragraph","text":"➡️ Étape suivante : créer Header + Footer globaux."},

  {"type":"heading2","text":"3. THEME BUILDER — HEADER GLOBAL"},
  {"type":"paragraph","text":"🎯 Objectif : Header unique appliqué à toutes les pages. ⏱️ Temps : 25 min."},
  {"type":"paragraph","text":"📍 Point de départ : Logo client (SVG/PNG transparent) reçu du Designer."},
  {"type":"paragraph","text":"🖥️ OÙ : wp-admin → Templates → Theme Builder → Header."},
  {"type":"numbered","items":["Templates → Theme Builder → Add New Header","Choisis template « Header » → Create New","Skip library → start from blank","Ajoute Section 1 colonne → Background blanc → padding 15px","Drag widget « Site Logo » → upload logo client → max-height 60px","Drag widget « Nav Menu » → sélectionne menu « Menu Principal » → align right","Drag widget « Button » → texte « Prendre RDV » → couleur Primary → lien WhatsApp wa.me/212XXXXXXXXX","Display Conditions → Include → Entire Site → Save & Close"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Header visible sur toutes les pages front. Logo cliquable → renvoie homepage. Menu mobile (burger) fonctionne."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Header ne s'affiche pas → vérifier Display Conditions = Entire Site. Logo flou → uploader version 2x (ex 600px wide pour affichage 300px)."},
  {"type":"paragraph","text":"➡️ Étape suivante : Footer."},

  {"type":"heading2","text":"4. THEME BUILDER — FOOTER GLOBAL"},
  {"type":"paragraph","text":"🎯 Objectif : Footer avec coordonnées + mentions + social. ⏱️ Temps : 20 min."},
  {"type":"paragraph","text":"📍 Point de départ : Header créé."},
  {"type":"paragraph","text":"🖥️ OÙ : Templates → Theme Builder → Footer → Add New."},
  {"type":"numbered","items":["Add New Footer → Create New (blank)","Section 4 colonnes → Background #2A2A2A → padding 60px haut/bas","Col 1 : Logo blanc + 1 phrase pitch","Col 2 : Liens rapides (Accueil, Services, Contact, Mentions)","Col 3 : Coordonnées (adresse, tel, email)","Col 4 : Icônes social (FB, IG, LinkedIn)","Sous-section : Copyright « © 2026 Cabinet Dr. Karim — Tous droits réservés — Réalisé par Next Gital »","Display Conditions → Entire Site → Publish"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — coordonnées :"},
  {"type":"list","items":["**Adresse** → adresse réelle client (vérifier brief)","**Tel** → format `+212 6 XX XX XX XX` → cliquable `tel:+2126XXXXXXXX`","**Email** → email Titan créé (ex contact@drkarim.ma)","**Mention NG** → toujours inclure « Réalisé par Next Gital » → lien nextgital.tech"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Footer visible bas de chaque page. Tel cliquable sur mobile (ouvre composeur). Email cliquable (ouvre mailto)."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Icônes social cassées → installer kit icônes Elementor (intégré). Footer dupliqué → un seul footer doit avoir Display = Entire Site."},
  {"type":"paragraph","text":"➡️ Étape suivante : construire la homepage."},

  {"type":"heading2","text":"5. HOMEPAGE — STRUCTURE STANDARD NG"},
  {"type":"paragraph","text":"🎯 Objectif : Construire homepage 7 sections (template NG). ⏱️ Temps : 60 min."},
  {"type":"paragraph","text":"📍 Point de départ : Header/Footer publiés."},
  {"type":"paragraph","text":"🖥️ OÙ : Pages → Ajouter → titre « Accueil » → Modifier avec Elementor."},
  {"type":"numbered","items":["Crée page « Accueil » → publie","Réglages → Lecture → Page d'accueil statique → « Accueil »","Modifier avec Elementor","Construis les 7 sections (voir CONTENU EXACT)","Pour chaque section : utilise Container Flexbox (pas Section legacy)","Active mode Responsive → ajuste mobile/tablet par section","Publie"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — 7 sections homepage :"},
  {"type":"list","items":["**1. Hero** → Image full-width + Headline + Sous-titre + 2 CTAs (Primary + Secondary)","**2. Services / Pourquoi nous** → 3-4 cartes icône + titre + description courte","**3. À propos** → 2 colonnes : image + texte présentation","**4. Témoignages** → Slider 3 témoignages clients (widget Testimonial Carousel)","**5. Galerie / Réalisations** → Grille 6-8 images (widget Gallery)","**6. FAQ** → Accordion 5-6 questions fréquentes","**7. CTA final + Contact** → Background couleur Primary + Formulaire contact + coordonnées"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Homepage publiée affiche 7 sections. Test responsive mobile (DevTools → 375px) : pas de débordement horizontal. Headline visible above the fold."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Container vide en mobile → vérifier flex-direction column. Image hero trop lourde → compresser via ShortPixel < 200 Ko. Texte illisible sur image → ajouter overlay sombre 40%."},
  {"type":"paragraph","text":"➡️ Étape suivante : optimisation perf + SEO."},

  {"type":"heading2","text":"6. OPTIMISATION PERFORMANCE"},
  {"type":"paragraph","text":"🎯 Objectif : Score PageSpeed > 90 + GTmetrix < 2s. ⏱️ Temps : 20 min."},
  {"type":"paragraph","text":"📍 Point de départ : Site fonctionnel."},
  {"type":"paragraph","text":"🖥️ OÙ : wp-admin → WP Rocket + Réglages images."},
  {"type":"numbered","items":["WP Rocket → File Optimization → Activer Minify CSS + JS + Combine","WP Rocket → Media → Lazyload images + iframes","WP Rocket → Preload → Activer sitemap-based preload","Installe ShortPixel → Optimize all images (mode Glossy)","Elementor → Settings → Features → activer « Improved CSS Loading »","Vide cache → teste sur PageSpeed Insights"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"PageSpeed Mobile > 85, Desktop > 95. GTmetrix Grade A. LCP < 2.5s."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Minify casse le site → désactiver Combine JS uniquement. Images encore lourdes → convertir en WebP via ShortPixel. CLS > 0.1 → définir width/height sur toutes les images."},
  {"type":"paragraph","text":"➡️ Étape suivante : SEO Yoast."},

  {"type":"heading2","text":"7. SEO ON-PAGE YOAST"},
  {"type":"paragraph","text":"🎯 Objectif : Configurer Yoast + meta sur toutes pages. ⏱️ Temps : 25 min."},
  {"type":"paragraph","text":"📍 Point de départ : Pages publiées."},
  {"type":"paragraph","text":"🖥️ OÙ : wp-admin → Yoast SEO."},
  {"type":"numbered","items":["Yoast → Configuration Wizard → suivre étapes (type de site, organisation, etc.)","Yoast → Réglages → Schema → définir type « Medical Business » (ou autre selon client)","Pour chaque page → bloc Yoast en bas → remplir Meta title + Meta description + mot-clé focus","Yoast → Sitemap XML → vérifier accessible : drkarim.ma/sitemap_index.xml","Soumettre sitemap dans Google Search Console"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Toutes les pages ont badge Yoast vert ou orange (jamais rouge). Sitemap renvoie XML valide."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Sitemap 404 → permaliens en mode défaut → passer à /%postname%/. Schema invalide → tester sur schema.org validator."},
  {"type":"paragraph","text":"➡️ Site prêt pour QA (voir SOP qa-checklist)."},

  {"type":"divider"},
  {"type":"heading2","text":"Checklist de validation"},
  {"type":"checklist","items":["Hello Elementor activé, autres thèmes supprimés","Site Settings : couleurs + typo charte client définies","Header global avec logo + menu + CTA","Footer global avec coordonnées + mention NG","Homepage 7 sections publiées","Page accueil définie comme front page","Responsive testé mobile + tablet + desktop","PageSpeed > 85 mobile / > 95 desktop","WP Rocket actif + cache préchargé","Images optimisées WebP","Yoast configuré + sitemap soumis GSC","Tous textes en français corrects (pas de lorem ipsum)"]},
  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"> 30 min bloqué sur une étape → WhatsApp tech +212 620 002 066. Avant de livrer : faire SOP qa-checklist obligatoire."}
]$sop$::jsonb,
    read_min = 20,
    updated_at = now()
WHERE slug = 'ng-dev-elementor-vitrine';

-- ────────────────────────────────────────────────────────────────────
-- 3. ng-dev-woocommerce — Configuration WooCommerce (CMI Maroc)
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏱️ Délai","text":"Setup WooCommerce + CMI + premiers produits : 3-4h. Ce SOP couvre la config complète."},
  {"type":"callout","variant":"info","title":"📞 Canal","text":"Activation CMI (marchand) → contact CMI client. Bug paiement → Slack #dev-woocommerce."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"JAMAIS tester paiements CMI en production avec vraie CB sans accord écrit client. TOUJOURS utiliser environnement test CMI pour validations."},
  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. INSTALLER WOOCOMMERCE"},
  {"type":"paragraph","text":"🎯 Objectif : Installer plugin + lancer Setup Wizard. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : WP installé."},
  {"type":"paragraph","text":"🖥️ OÙ : wp-admin → Extensions → Ajouter → « WooCommerce »."},
  {"type":"numbered","items":["Installe + active WooCommerce","Setup Wizard se lance automatiquement","Adresse boutique : adresse réelle client à Oujda (ex)","Pays : Maroc","Devise : MAD (Dirham marocain) — voir CONTENU EXACT","Type de produits : Physiques + Digitaux (selon brief)","Skip extensions WooCommerce.com payantes proposées"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — réglages devise :"},
  {"type":"list","items":["**Devise** → MAD","**Position devise** → Droite avec espace (« 250 DH »)","**Séparateur milliers** → espace","**Séparateur décimales** → virgule","**Nb décimales** → 2"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"WooCommerce → Réglages → Général affiche MAD. Menu admin a « Produits » et « WooCommerce »."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pages auto-créées manquantes (Boutique, Panier, Commande) → WooCommerce → État → Outils → « Créer les pages WooCommerce manquantes »."},
  {"type":"paragraph","text":"➡️ Étape suivante : zones de livraison."},

  {"type":"heading2","text":"2. ZONES & FRAIS DE LIVRAISON"},
  {"type":"paragraph","text":"🎯 Objectif : Définir tarifs livraison par région Maroc. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : Brief client avec grille tarifs livraison."},
  {"type":"paragraph","text":"🖥️ OÙ : WooCommerce → Réglages → Livraison."},
  {"type":"numbered","items":["Onglet Livraison → Ajouter une zone","Zone 1 « Oujda » → Code postal commençant par 60000 → Méthode : Forfait 20 DH","Zone 2 « Reste Maroc » → Pays : Maroc → Méthode : Forfait 40 DH","Zone 3 « Livraison gratuite > 500 DH » → Maroc + méthode « Free Shipping » conditionnel","Zone hors zones : Désactiver expédition (international = pas autorisé par défaut)"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Test panier avec adresse Oujda → frais = 20 DH. Adresse Casablanca → 40 DH. Panier > 500 DH → option gratuite proposée."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Frais cumulés bizarres → vérifier qu'une seule méthode est par zone. Code postal ne matche pas → utiliser wildcard (60* pour Oujda)."},
  {"type":"paragraph","text":"➡️ Étape suivante : moyens de paiement."},

  {"type":"heading2","text":"3. MOYENS DE PAIEMENT (CMI + COD + Virement)"},
  {"type":"paragraph","text":"🎯 Objectif : 3 moyens actifs : CMI (CB), paiement à la livraison, virement. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"📍 Point de départ : Contrat CMI signé client + credentials CMI reçus (CLIENT ID, STORE KEY)."},
  {"type":"paragraph","text":"🖥️ OÙ : WooCommerce → Réglages → Paiements."},
  {"type":"numbered","items":["Active « Paiement à la livraison » → renomme « Paiement à la livraison (espèces) »","Active « Virement bancaire direct » → ajoute coordonnées RIB client","Installe plugin « WooCommerce CMI Gateway » (depuis vault NG ou Codecanyon)","Configure CMI (voir CONTENU EXACT)","Test commande avec carte test CMI (4111 1111 1111 1111)"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — CMI :"},
  {"type":"list","items":["**Mode** → Test (au début) puis Production","**Client ID** → fourni par CMI (ex 600XXXX)","**Store Key** → fourni par CMI (vault NG)","**URL OK** → drkarim.ma/checkout/order-received/","**URL Fail** → drkarim.ma/checkout/","**Hash Algorithm** → ver3 (SHA-512)","**Currency** → 504 (MAD ISO 4217)","**Langue interface** → FR"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Virement :"},
  {"type":"list","items":["**Nom banque** → ex « Banque Populaire »","**Numéro compte** → RIB 24 chiffres","**SWIFT/BIC** → BCPOMAMC","**Bénéficiaire** → raison sociale client"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Checkout affiche les 3 options. CMI test : commande passe + redirige page CMI + retour OK. COD : commande créée en statut « En attente »."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"CMI « Hash mismatch » → vérifier Store Key (pas d'espace). Redirection cassée → URL OK/Fail doit être absolue avec https://. Mode test rejette CB perso → utiliser uniquement cartes test fournies par CMI."},
  {"type":"paragraph","text":"➡️ Étape suivante : TVA."},

  {"type":"heading2","text":"4. PARAMÈTRES TVA (20% Maroc)"},
  {"type":"paragraph","text":"🎯 Objectif : Activer TVA 20% si client assujetti. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Confirmation client (assujetti TVA ou non)."},
  {"type":"paragraph","text":"🖥️ OÙ : WooCommerce → Réglages → Général + onglet Taxe."},
  {"type":"numbered","items":["Si client assujetti → Activer la taxe (case Général)","Onglet Taxe → Prix entrés TTC ou HT (voir CONTENU EXACT)","Onglet Standard rates → Add row → Maroc → 20.0000 → Nom « TVA » → Composé OFF","Sauvegarder","Test : ajoute produit 100 DH HT → checkout affiche 120 DH TTC"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Prix entrés avec taxe** → Oui (recommandé B2C Maroc — client voit prix TTC direct)","**Calculer taxe basé sur** → Adresse de facturation","**Classe par défaut** → Standard","**Affichage prix** → TTC (boutique + panier)"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Page produit affiche prix TTC. Détail panier affiche « dont TVA 20% : X DH »."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Si client NON assujetti → désactiver TVA totalement (sinon facture non conforme). Double imposition → vérifier qu'une seule rate Maroc 20%."},
  {"type":"paragraph","text":"➡️ Étape suivante : créer 5 premiers produits."},

  {"type":"heading2","text":"5. CRÉER 5 PRODUITS TEMPLATE"},
  {"type":"paragraph","text":"🎯 Objectif : Créer 5 produits réels pour démarrer + valider flux. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"📍 Point de départ : Catalogue client + photos produits (haute qualité)."},
  {"type":"paragraph","text":"🖥️ OÙ : wp-admin → Produits → Ajouter."},
  {"type":"numbered","items":["Pour chaque produit → Ajouter","Remplis Titre + Description longue + Description courte","Prix régulier (TTC si activé)","Image principale + Galerie (4-6 images)","Catégorie + Tags","SKU unique format SLUG-001","Stock : gérer le stock = oui → quantité","Publier"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — exemple produit Boulangerie Atlas :"},
  {"type":"list","items":["**Titre** → « Pain au levain bio 500g »","**SKU** → ATLAS-PAIN-001","**Prix** → 25,00 DH","**Description courte** → 1-2 phrases vendeuses (apparaît à côté image)","**Description longue** → ingrédients + bénéfices + conservation","**Catégorie** → Pains > Pains bio","**Image** → 1500x1500 px min, format JPG, < 300 Ko"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Boutique (drkarim.ma/boutique) affiche les 5 produits avec prix et image. Page produit : ajout panier fonctionne."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Image floue front-end → uploader 2x la taille d'affichage. Stock toujours « Rupture » → décocher « En rupture » dans onglet Inventaire."},
  {"type":"paragraph","text":"➡️ Étape suivante : page Boutique + emails."},

  {"type":"heading2","text":"6. PAGE BOUTIQUE + EMAILS TRANSACTIONNELS"},
  {"type":"paragraph","text":"🎯 Objectif : Personnaliser page boutique + emails commande. ⏱️ Temps : 25 min."},
  {"type":"paragraph","text":"📍 Point de départ : Produits créés + SMTP Titan actif."},
  {"type":"paragraph","text":"🖥️ OÙ : Pages → Boutique + WooCommerce → Réglages → E-mails."},
  {"type":"numbered","items":["Modifier page Boutique avec Elementor → header + grille produits (widget WooCommerce Products)","Personnalise 6 emails : Nouvelle commande, Commande échouée, En attente, En cours, Terminée, Remboursée","Pour chaque email → Configurer → ajoute logo client + couleurs charte","Onglet « Expéditeur » → email = contact@drkarim.ma (Titan)","Test : passe commande test → vérifie réception email client + admin"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Commande test → email client reçu < 1 min avec logo + détails. Email admin reçu sur info@nextgital.com."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Emails dans spam → vérifier SPF/DKIM Titan. Logo absent → uploader via Réglages → E-mails → Image header (URL publique)."},
  {"type":"paragraph","text":"➡️ Étape suivante : tests E2E + QA."},

  {"type":"heading2","text":"7. TEST END-TO-END COMMANDE COMPLÈTE"},
  {"type":"paragraph","text":"🎯 Objectif : Simuler parcours client complet. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : Tout configuré."},
  {"type":"paragraph","text":"🖥️ OÙ : Front-end drkarim.ma → comme un client."},
  {"type":"numbered","items":["Mode incognito → drkarim.ma","Ajoute 2 produits différents au panier","Va au panier → vérifie totaux + frais livraison","Checkout → remplis adresse Oujda (test) + Casablanca (test)","Choisis CMI test → finalise → reviens sur page confirmation","Vérifie : commande visible dans wp-admin → WooCommerce → Commandes","Refais avec COD","Refais avec virement"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"3 commandes test créées (CMI/COD/Virement). Emails reçus. Stock décrémenté correctement."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Stock pas décrémenté → activer « Réduire le stock à la commande » dans Inventaire. CMI test renvoie erreur → contacter CMI support avec n° marchand."},
  {"type":"paragraph","text":"➡️ Avant livraison : supprimer les 3 commandes test, passer CMI en Production."},

  {"type":"divider"},
  {"type":"heading2","text":"Checklist de validation"},
  {"type":"checklist","items":["WooCommerce installé + Setup wizard complété","Devise MAD configurée + position droite avec espace","Zones livraison Oujda + Maroc + Gratuite > 500 DH","CMI test fonctionnel + commande passe","Paiement à la livraison actif","Virement actif + RIB rempli","TVA configurée (si applicable) + prix TTC affichés","Au moins 5 produits avec photos HD + SKU","Page Boutique customisée Elementor","6 emails WooCommerce personnalisés avec logo client","Tests E2E : 3 commandes test passées","Avant Go Live : CMI passé en Production + commandes test supprimées"]},
  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"> 30 min bloqué sur CMI → WhatsApp tech +212 620 002 066. JAMAIS communiquer Store Key CMI par email/Slack non chiffré → uniquement 1Password vault."}
]$sop$::jsonb,
    read_min = 22,
    updated_at = now()
WHERE slug = 'ng-dev-woocommerce';

-- ────────────────────────────────────────────────────────────────────
-- 4. ng-dev-dokploy — Déploiement Dokploy
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏱️ Délai","text":"Déploiement app Next.js + DB Supabase via Dokploy : 30-45 min."},
  {"type":"callout","variant":"info","title":"📞 Canal","text":"Bug déploiement → Slack #dev-infra. Accès Dokploy → WhatsApp tech."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"JAMAIS push secrets/env vars dans le repo Git. TOUJOURS utiliser Dokploy → Environment section. Les variables Supabase/Stripe/etc passent par UI Dokploy uniquement."},
  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. CONNEXION DOKPLOY"},
  {"type":"paragraph","text":"🎯 Objectif : Accéder au dashboard Dokploy NG. ⏱️ Temps : 3 min."},
  {"type":"paragraph","text":"📍 Point de départ : Compte Dokploy créé (lead dev fournit)."},
  {"type":"paragraph","text":"🖥️ OÙ : https://dokploy.nextgital.tech"},
  {"type":"numbered","items":["Ouvre dokploy.nextgital.tech","Login avec email + mdp (vault 1Password)","Active 2FA si pas déjà fait","Dashboard → tu vois la liste des projets actifs"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Dashboard affiche projets : gestiq, nextgital-web, sites clients. Statut Docker daemon = Healthy."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Dashboard renvoie 502 → serveur Dokploy down → contacter lead dev. Login échoue → mdp expiré → reset via email."},
  {"type":"paragraph","text":"➡️ Étape suivante : créer le projet."},

  {"type":"heading2","text":"2. CRÉER UN NOUVEAU PROJET"},
  {"type":"paragraph","text":"🎯 Objectif : Initialiser le projet dans Dokploy. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : Repo Git prêt (ex github.com/nextgital/projet-x)."},
  {"type":"paragraph","text":"🖥️ OÙ : Dokploy → Projects → Create Project."},
  {"type":"numbered","items":["Create Project","Nom : « projet-x-prod » (suffixe -prod ou -staging)","Description courte","Create → tu arrives sur la page projet vide","Ajoute des services via « Create Service »"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Projet visible dans dashboard. Page projet vide prête à recevoir services."},
  {"type":"paragraph","text":"➡️ Étape suivante : ajouter service application."},

  {"type":"heading2","text":"3. AJOUTER SERVICE APPLICATION (Next.js)"},
  {"type":"paragraph","text":"🎯 Objectif : Déployer l'app Next.js depuis GitHub. ⏱️ Temps : 12 min."},
  {"type":"paragraph","text":"📍 Point de départ : Projet créé + repo GitHub accessible."},
  {"type":"paragraph","text":"🖥️ OÙ : Page projet → Create Service → Application."},
  {"type":"numbered","items":["Create Service → Application","Type Source : GitHub","Sélectionne le repo (autorise Dokploy GitHub App si demandé)","Branch : main (ou production)","Build Type : Dockerfile (recommandé) ou Nixpacks","Dockerfile path : ./Dockerfile","Port : 3000 (Next.js par défaut)","Save"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — Dockerfile Next.js standard NG :"},
  {"type":"template","text":"FROM node:20-alpine AS deps\nWORKDIR /app\nCOPY package*.json ./\nRUN npm ci\n\nFROM node:20-alpine AS builder\nWORKDIR /app\nCOPY --from=deps /app/node_modules ./node_modules\nCOPY . .\nRUN npm run build\n\nFROM node:20-alpine AS runner\nWORKDIR /app\nENV NODE_ENV=production\nCOPY --from=builder /app/.next/standalone ./\nCOPY --from=builder /app/.next/static ./.next/static\nCOPY --from=builder /app/public ./public\nEXPOSE 3000\nCMD [\"node\", \"server.js\"]"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Service apparaît dans projet. Statut « Not deployed » initial."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Repo introuvable → autoriser Dokploy dans GitHub Settings → Applications. Build fail « package.json not found » → vérifier root du repo."},
  {"type":"paragraph","text":"➡️ Étape suivante : variables d'environnement."},

  {"type":"heading2","text":"4. ENVIRONMENT VARIABLES"},
  {"type":"paragraph","text":"🎯 Objectif : Configurer toutes les env vars (Supabase, etc). ⏱️ Temps : 8 min."},
  {"type":"paragraph","text":"📍 Point de départ : Credentials Supabase prêts (depuis dashboard Supabase du projet)."},
  {"type":"paragraph","text":"🖥️ OÙ : Service → onglet Environment."},
  {"type":"numbered","items":["Onglet Environment du service","Bouton « Edit » → éditeur clé=valeur","Colle toutes les variables (voir CONTENU EXACT)","Save → Dokploy redémarrera le service au prochain deploy"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — env vars typiques :"},
  {"type":"template","text":"NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co\nNEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOi...\nSUPABASE_SERVICE_ROLE_KEY=eyJhbGciOi...\nDATABASE_URL=postgresql://postgres:[PASSWORD]@db.xxxxx.supabase.co:5432/postgres\nNEXTAUTH_URL=https://app.client.ma\nNEXTAUTH_SECRET=<openssl rand -base64 32>\nNODE_ENV=production"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Env vars listées dans onglet Environment. Aucune valeur exposée en clair dans logs."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Var avec espaces → entourer de guillemets. NEXTAUTH_SECRET manquant → générer via `openssl rand -base64 32`."},
  {"type":"paragraph","text":"➡️ Étape suivante : domaine + SSL."},

  {"type":"heading2","text":"5. DOMAINE PERSONNALISÉ + SSL"},
  {"type":"paragraph","text":"🎯 Objectif : Attacher app.client.ma + SSL Let's Encrypt auto. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Accès DNS du domaine client."},
  {"type":"paragraph","text":"🖥️ OÙ : Service → onglet Domains."},
  {"type":"numbered","items":["Onglet Domains → Add Domain","Host : app.client.ma","Path : / → Container Port : 3000","HTTPS : ON → Certificate Provider : Let's Encrypt","Email : tech@nextgital.com","Save","Dans DNS du domaine (Hostinger / Cloudflare) → ajoute record A pointant vers IP serveur Dokploy (lead dev fournit)","Attends propagation DNS (5-30 min)"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"https://app.client.ma résout vers Dokploy. SSL vert. Pas d'erreur certificat."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"SSL ne s'émet pas → DNS pas propagé → attends 30 min + retry. Erreur « rate limit Let's Encrypt » → utiliser staging certificate d'abord, prod après."},
  {"type":"paragraph","text":"➡️ Étape suivante : premier déploiement."},

  {"type":"heading2","text":"6. DÉPLOIEMENT INITIAL"},
  {"type":"paragraph","text":"🎯 Objectif : Build + run du conteneur. ⏱️ Temps : 8 min."},
  {"type":"paragraph","text":"📍 Point de départ : Config complète."},
  {"type":"paragraph","text":"🖥️ OÙ : Service → bouton « Deploy »."},
  {"type":"numbered","items":["Bouton « Deploy » en haut à droite","Suis les logs en temps réel (onglet Logs)","Étapes : Pull repo → Docker build → Push image → Container start","Build prend 3-6 min (cache mis à jour)","Status passe à « Running » quand healthy"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Logs montrent « Server running on port 3000 ». https://app.client.ma affiche l'app."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Build fail « out of memory » → augmenter RAM serveur ou utiliser cache builder. Container restart loop → vérifier logs application (souvent env var manquante)."},
  {"type":"paragraph","text":"➡️ Étape suivante : auto-deploy + monitoring."},

  {"type":"heading2","text":"7. AUTO-DEPLOY + WEBHOOKS GIT"},
  {"type":"paragraph","text":"🎯 Objectif : Push main → auto-deploy Dokploy. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : Service déployé."},
  {"type":"paragraph","text":"🖥️ OÙ : Service → onglet Deployments."},
  {"type":"numbered","items":["Onglet Deployments → Auto Deploy → ON","Copie l'URL webhook fournie","GitHub → repo → Settings → Webhooks → Add","Payload URL = URL Dokploy → Content type application/json → événement « push »","Save","Test : push commit factice sur main → Dokploy doit déclencher build auto en < 30s"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Onglet Deployments montre nouveau deployment déclenché par push. Status « Success »."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Webhook délivre 401 → URL secret manquant → re-copier l'URL complète avec token. Auto-deploy déclenche sur toutes branches → filtrer par branch dans webhook GitHub."},
  {"type":"paragraph","text":"➡️ App en production avec CD configuré."},

  {"type":"divider"},
  {"type":"heading2","text":"Checklist de validation"},
  {"type":"checklist","items":["Login Dokploy OK + 2FA actif","Projet créé avec nommage clair","Service Application lié au repo GitHub","Dockerfile présent et valide","Toutes env vars Supabase configurées","NEXTAUTH_SECRET généré aléatoirement","Domaine custom attaché + DNS A record OK","SSL Let's Encrypt actif (cadenas vert)","Premier déploiement réussi","App accessible via https://","Auto-deploy webhook GitHub actif","Test push → déploiement automatique fonctionne","Logs propres (pas d'erreurs au démarrage)"]},
  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"> 30 min bloqué (build échec récurrent, SSL impossible) → WhatsApp tech +212 620 002 066. JAMAIS rebooter le serveur Dokploy sans autorisation lead dev (impacte autres clients)."}
]$sop$::jsonb,
    read_min = 18,
    updated_at = now()
WHERE slug = 'ng-dev-dokploy';

-- ────────────────────────────────────────────────────────────────────
-- 5. ng-dev-titan-email — Configuration Titan Email
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏱️ Délai","text":"Création boîte Titan + DNS + test : 30 min."},
  {"type":"callout","variant":"info","title":"📞 Canal","text":"DNS bloqué → support Hostinger. Boîte non créée → Slack #dev-email."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"JAMAIS donner mdp Titan au client par email/WhatsApp clair. TOUJOURS via 1Password share link ou en personne."},
  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. ACCÉDER À TITAN VIA HPANEL"},
  {"type":"paragraph","text":"🎯 Objectif : Ouvrir l'interface Titan du domaine. ⏱️ Temps : 3 min."},
  {"type":"paragraph","text":"📍 Point de départ : hPanel Hostinger ouvert, abonnement email actif."},
  {"type":"paragraph","text":"🖥️ OÙ : hPanel → Emails → Titan."},
  {"type":"numbered","items":["hPanel → onglet Emails","Si pas de service email → activer offre Titan gratuite incluse","Clique « Gérer » à côté de Titan","Tu arrives sur l'interface admin Titan : app.titan.email"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu vois le dashboard admin Titan avec onglet « Mailboxes »."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"« Titan non disponible » → DNS pas propagé après achat domaine → attendre 24h. Domaine déjà lié à un autre service email → désactiver Google Workspace / autre d'abord."},
  {"type":"paragraph","text":"➡️ Étape suivante : créer la boîte."},

  {"type":"heading2","text":"2. CRÉER LA BOÎTE EMAIL PRINCIPALE"},
  {"type":"paragraph","text":"🎯 Objectif : Créer contact@domaine.ma. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : Admin Titan ouvert."},
  {"type":"paragraph","text":"🖥️ OÙ : Titan Admin → Mailboxes → Add Mailbox."},
  {"type":"numbered","items":["Add Mailbox","Remplis champs (voir CONTENU EXACT)","Mot de passe → généré par 1Password (16 char min)","Save → boîte créée sous 30s"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":["**Local part** → `contact` → préfixe simple, professionnel","**Display name** → « Cabinet Dr. Karim » → nom commercial","**Mot de passe** → 1Password 16 char → noter dans vault sous nom client","**Forwarding** → désactivé par défaut (sauf demande client)"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Boîte visible dans liste Mailboxes. Login test sur https://app.titan.email avec contact@drkarim.ma → boîte de réception ouverte."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"« Mailbox already exists » → boîte déjà créée avant → demander reset au client. Mdp refusé → caractères spéciaux mal acceptés → utiliser uniquement [A-Za-z0-9!@#$%]."},
  {"type":"paragraph","text":"➡️ Étape suivante : DNS MX records."},

  {"type":"heading2","text":"3. CONFIGURER DNS MX (HOSTINGER)"},
  {"type":"paragraph","text":"🎯 Objectif : Pointer le mail du domaine vers Titan. ⏱️ Temps : 8 min."},
  {"type":"paragraph","text":"📍 Point de départ : Boîte créée, hPanel accessible."},
  {"type":"paragraph","text":"🖥️ OÙ : hPanel → Domaines → DNS Zone Editor."},
  {"type":"numbered","items":["hPanel → Domaines → ton domaine → DNS / Nameservers → DNS Zone","Supprime tous les MX existants (Hostinger par défaut)","Ajoute 2 MX records Titan (voir CONTENU EXACT)","Ajoute SPF (TXT)","Ajoute DKIM (TXT, fourni par Titan dans onglet « Domain Setup »)","Ajoute DMARC (TXT)","Save"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — DNS records :"},
  {"type":"table","text":"Type | Host | Value | Priority | TTL\nMX | @ | mx1.titan.email | 10 | 14400\nMX | @ | mx2.titan.email | 20 | 14400\nTXT | @ | v=spf1 include:spf.titan.email ~all | - | 14400\nTXT | titan1._domainkey | (clé fournie par Titan) | - | 14400\nTXT | _dmarc | v=DMARC1; p=quarantine; rua=mailto:dmarc@drkarim.ma | - | 14400"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Sur https://mxtoolbox.com → entrer drkarim.ma → MX lookup → mx1/mx2.titan.email visibles. SPF/DKIM/DMARC verts."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Propagation DNS lente (jusqu'à 24h) → attendre. SPF en doublon avec ancien provider → garder uniquement Titan. DKIM erreur → copier la clé sans saut de ligne (parfois s'étend sur 2 lignes dans Titan UI)."},
  {"type":"paragraph","text":"➡️ Étape suivante : test envoi/réception."},

  {"type":"heading2","text":"4. TEST ENVOI + RÉCEPTION"},
  {"type":"paragraph","text":"🎯 Objectif : Confirmer que mail entre et sort. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : DNS configuré (attendre 15 min après save)."},
  {"type":"paragraph","text":"🖥️ OÙ : https://app.titan.email + Gmail externe."},
  {"type":"numbered","items":["Login app.titan.email avec contact@drkarim.ma","Envoie un email à info@nextgital.com (Gmail externe pour test)","Depuis Gmail → réponds à contact@drkarim.ma","Vérifie réception dans Titan inbox","Vérifie via mail-tester.com : envoie email de Titan → score doit être > 9/10"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Email envoyé reçu sur Gmail < 1 min, pas dans spam. Réponse reçue sur Titan < 1 min. Score mail-tester ≥ 9/10."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Mail dans spam Gmail → SPF/DKIM/DMARC mal configurés → recheck mxtoolbox. Score < 7 → vérifier reverse DNS + warm-up domaine (envoyer progressivement)."},
  {"type":"paragraph","text":"➡️ Étape suivante : configuration SMTP pour WordPress / app."},

  {"type":"heading2","text":"5. PARAMÈTRES SMTP/IMAP POUR CLIENT/APP"},
  {"type":"paragraph","text":"🎯 Objectif : Fournir les credentials de connexion. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : Test envoi OK."},
  {"type":"paragraph","text":"🖥️ OÙ : Documentation à fournir au client / utiliser dans WP Mail SMTP."},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — SMTP outgoing :"},
  {"type":"list","items":["**Host SMTP** → smtp.titan.email","**Port** → 465","**Encryption** → SSL","**Auth** → Required","**Username** → email complet (contact@drkarim.ma)","**Password** → mdp boîte"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — IMAP incoming :"},
  {"type":"list","items":["**Host IMAP** → imap.titan.email","**Port** → 993","**Encryption** → SSL","**Username** → email complet","**Password** → mdp"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Test config dans WP Mail SMTP (voir SOP wp-hostinger étape 7) → email test reçu."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Port 587 ne fonctionne pas → utiliser 465 SSL (pas 587 TLS chez Titan). Connection timeout → firewall serveur bloque port 465."},
  {"type":"paragraph","text":"➡️ Étape suivante : remettre les accès au client."},

  {"type":"heading2","text":"6. REMISE ACCÈS AU CLIENT"},
  {"type":"paragraph","text":"🎯 Objectif : Transférer mdp + tuto au client. ⏱️ Temps : 4 min."},
  {"type":"paragraph","text":"📍 Point de départ : Tout fonctionne."},
  {"type":"paragraph","text":"🖥️ OÙ : 1Password share + WhatsApp client."},
  {"type":"numbered","items":["1Password → vault Next Gital → entrée client → bouton « Share » → généré lien 7 jours","Envoie lien au client via WhatsApp (lien expire seul)","Envoie également URL webmail : https://app.titan.email","Recommande au client de changer le mdp dès première connexion","Note la livraison dans Notion DB clients → date + qui"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Client confirme par WhatsApp avoir accédé à sa boîte. A changé le mdp."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Client n'arrive pas à se connecter → screenshot écran d'erreur via WhatsApp. Mdp oublié après change → reset depuis Titan Admin (Mailboxes → Reset password)."},
  {"type":"paragraph","text":"➡️ SOP terminée."},

  {"type":"divider"},
  {"type":"heading2","text":"Checklist de validation"},
  {"type":"checklist","items":["Boîte contact@domaine créée","Mot de passe stocké dans 1Password vault","MX mx1 + mx2.titan.email ajoutés","SPF Titan en place","DKIM (clé Titan) en place","DMARC quarantine configuré","Test mxtoolbox : tous verts","Test mail-tester : score ≥ 9/10","SMTP 465 SSL fonctionne (test WP)","Accès remis au client via 1Password share","Client a changé le mdp initial","Livraison loguée dans Notion DB clients"]},
  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"> 30 min bloqué sur DNS ou propagation → WhatsApp tech +212 620 002 066. JAMAIS envoyer un mdp en clair par email ou Slack."}
]$sop$::jsonb,
    read_min = 15,
    updated_at = now()
WHERE slug = 'ng-dev-titan-email';

-- ────────────────────────────────────────────────────────────────────
-- 6. ng-dev-claude-codex-workflow — Workflow IA Claude Code + Codex
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏱️ Délai","text":"Cycle complet ticket → PR via Claude + Codex : 30 min à 2h selon complexité."},
  {"type":"callout","variant":"info","title":"📞 Canal","text":"Question méthodo → lead dev sur Slack #dev-ai. Bug Claude → discord Anthropic."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"JAMAIS merger un PR généré par IA sans relire et tester localement. L'IA assiste, elle ne décide pas. Toute prod = revue humaine."},
  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. PRÉPARER LE TICKET (CONTEXT IS KING)"},
  {"type":"paragraph","text":"🎯 Objectif : Rédiger un ticket exploitable par l'IA. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Demande client/PM brute."},
  {"type":"paragraph","text":"🖥️ OÙ : Linear / Notion / GitHub Issues."},
  {"type":"numbered","items":["Rédige titre clair (verbe d'action + objet)","Décrit le « pourquoi » (contexte métier)","Décrit le « quoi » (comportement attendu)","Liste fichiers probablement impactés","Donne exemples d'entrée/sortie","Critères d'acceptation = checklist testable"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — template ticket :"},
  {"type":"template","text":"## Titre\n[FEAT] Ajouter export CSV liste clients\n\n## Contexte\nLe gérant veut exporter sa base clients pour analyse Excel.\n\n## Comportement attendu\nBouton « Export CSV » sur /clients → télécharge fichier .csv avec colonnes : nom, email, tel, créé_le.\n\n## Fichiers probables\n- src/pages/clients.tsx (UI bouton)\n- src/lib/csv.ts (helper à créer)\n- src/api/clients/export.ts (route API)\n\n## Critères d'acceptation\n- [ ] Bouton visible si role = admin\n- [ ] CSV téléchargé avec encoding UTF-8 BOM (Excel-friendly)\n- [ ] Test unitaire sur csv.ts"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le ticket peut être lu par un dev externe et donner exactement ce qui est attendu sans question."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Ticket vague (« améliorer la page clients ») → IA part dans tous les sens → reformule en comportements précis."},
  {"type":"paragraph","text":"➡️ Étape suivante : choisir l'outil (Claude Code ou Codex)."},

  {"type":"heading2","text":"2. CHOISIR L'OUTIL IA SELON LA TÂCHE"},
  {"type":"paragraph","text":"🎯 Objectif : Sélectionner Claude Code ou Codex pertinent. ⏱️ Temps : 1 min."},
  {"type":"paragraph","text":"📍 Point de départ : Ticket prêt."},
  {"type":"paragraph","text":"🖥️ OÙ : Terminal local."},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — quand utiliser quoi :"},
  {"type":"list","items":["**Claude Code (claude.ai/code CLI)** → refactor multi-fichiers, debug complexe, génération SOPs/docs, analyse architecture","**Codex (CLI OpenAI)** → génération courte de fonctions isolées, transformation de code","**Claude.ai (chat web)** → brainstorm design, revue plan, questions générales","**GitHub Copilot (IDE)** → autocomplétion en temps réel, snippets"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Choix justifiable en 1 phrase (« j'utilise Claude Code car la feature touche 6 fichiers »)."},
  {"type":"paragraph","text":"➡️ Étape suivante : lancer Claude Code."},

  {"type":"heading2","text":"3. LANCER CLAUDE CODE SUR LE REPO"},
  {"type":"paragraph","text":"🎯 Objectif : Démarrer une session Claude Code dans le projet. ⏱️ Temps : 3 min."},
  {"type":"paragraph","text":"📍 Point de départ : Repo cloné en local, branche feature créée."},
  {"type":"paragraph","text":"🖥️ OÙ : Terminal dans le dossier repo."},
  {"type":"numbered","items":["`cd /chemin/vers/repo`","`git checkout -b feature/export-csv`","`claude` (lance la CLI Claude Code)","Vérifie que CLAUDE.md existe à la racine (sinon `/init` pour le créer)","Vérifie permissions dans .claude/settings.json"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Prompt Claude Code actif. Tu peux taper une instruction."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"`claude: command not found` → installer via `npm i -g @anthropic-ai/claude-code`. Pas authentifié → `claude login`."},
  {"type":"paragraph","text":"➡️ Étape suivante : prompt initial."},

  {"type":"heading2","text":"4. RÉDIGER LE PROMPT INITIAL"},
  {"type":"paragraph","text":"🎯 Objectif : Donner à Claude le ticket + le contexte suffisant. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : Claude Code lancé."},
  {"type":"paragraph","text":"🖥️ OÙ : Prompt CLI."},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — structure prompt :"},
  {"type":"template","text":"Voici le ticket à implémenter :\n[colle le ticket complet]\n\nAvant d'écrire du code :\n1. Explore le repo avec Read/Glob pour comprendre la structure\n2. Propose un plan en 5-8 étapes\n3. Liste les fichiers à créer/modifier\n4. Attends ma validation du plan avant d'implémenter"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Claude répond avec un plan structuré, liste de fichiers, et attend validation."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Claude code direct sans plan → tu n'as pas demandé d'attendre validation → recommencer en ajoutant la consigne. Plan trop générique → ajouter exemples concrets dans le prompt."},
  {"type":"paragraph","text":"➡️ Étape suivante : valider plan + laisser implémenter."},

  {"type":"heading2","text":"5. VALIDER PLAN + LAISSER IMPLÉMENTER"},
  {"type":"paragraph","text":"🎯 Objectif : Itérer rapidement avec Claude. ⏱️ Temps : variable (10-60 min)."},
  {"type":"paragraph","text":"📍 Point de départ : Plan reçu de Claude."},
  {"type":"paragraph","text":"🖥️ OÙ : Prompt Claude."},
  {"type":"numbered","items":["Relis le plan → si OK : « valide, implémente étape par étape, fais un commit par étape »","Si plan incomplet : « ajoute X et reformule »","Pendant l'implémentation, lis chaque diff proposé","Réponds « OK » ou « non, change X »","À la fin : « lance les tests : npm test »"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tests verts. Code suit conventions repo (lint OK). Commits atomiques nommés."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Claude utilise lib qu'on n'a pas → corriger : « utilise plutôt X qui est déjà dans package.json ». Tests cassent autres features → demander tests d'intégration."},
  {"type":"paragraph","text":"➡️ Étape suivante : utiliser Codex pour vérif croisée."},

  {"type":"heading2","text":"6. CROSS-CHECK AVEC CODEX (optionnel mais conseillé)"},
  {"type":"paragraph","text":"🎯 Objectif : Faire revoir le diff par un second modèle. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Implémentation Claude terminée."},
  {"type":"paragraph","text":"🖥️ OÙ : Terminal — autre tab — `codex` CLI."},
  {"type":"numbered","items":["Génère le diff : `git diff main > /tmp/diff.patch`","Ouvre Codex CLI dans un autre terminal","Prompt : « Voici un diff produit par un autre modèle. Relis et liste : (a) bugs potentiels, (b) optimisations, (c) sécurité. »","Colle le diff","Codex renvoie une revue → applique les corrections pertinentes dans Claude Code"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Codex n'a pas relevé de bug critique. Suggestions mineures appliquées."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Diff trop gros pour fit dans contexte → splitter par fichier. Codex et Claude se contredisent → trancher humain, généralement le plus prudent."},
  {"type":"paragraph","text":"➡️ Étape suivante : tests manuels + PR."},

  {"type":"heading2","text":"7. TESTS MANUELS + CRÉATION PR"},
  {"type":"paragraph","text":"🎯 Objectif : Vérifier en réel puis PR. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : Code passe tests auto."},
  {"type":"paragraph","text":"🖥️ OÙ : Localhost + GitHub."},
  {"type":"numbered","items":["`npm run dev` → ouvre la feature dans navigateur","Teste 3 cas : nominal, edge case, erreur","Si OK → demande à Claude : « crée le PR avec gh »","Claude pousse + ouvre PR avec template","Review humaine du PR sur GitHub web (re-relecture)","Demande review à un autre dev NG via mention Slack"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"PR ouvert avec description claire, screenshots, lien ticket. CI verte."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"PR sans description → Claude oublie parfois → la générer manuellement. Tests CI échouent → relire logs CI, pas demander à Claude de « juste fixer » sans contexte."},
  {"type":"paragraph","text":"➡️ Étape suivante : merge après review."},

  {"type":"heading2","text":"8. MERGE + SUIVI POST-DÉPLOIEMENT"},
  {"type":"paragraph","text":"🎯 Objectif : Merger sereinement + monitorer. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : PR reviewé approved."},
  {"type":"paragraph","text":"🖥️ OÙ : GitHub + Dokploy + Sentry."},
  {"type":"numbered","items":["Squash and merge sur GitHub","Auto-deploy Dokploy déclenche (voir SOP dokploy)","Surveiller logs production 15 min après deploy","Vérifier Sentry → pas de nouvelle erreur","Update ticket Linear → status Done + lien PR","Annoncer dans Slack #releases"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Feature en prod. Pas d'erreur Sentry. Client peut tester."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Erreurs Sentry apparaissent → revert via Dokploy (deploy précédent) → hotfix avec Claude."},
  {"type":"paragraph","text":"➡️ Cycle terminé."},

  {"type":"divider"},
  {"type":"heading2","text":"Checklist de validation"},
  {"type":"checklist","items":["Ticket avec contexte + critères d'acceptation","Branche feature créée avant Claude","CLAUDE.md à jour à la racine","Plan reçu et validé AVANT implémentation","Commits atomiques par étape","Tests auto verts","Cross-check Codex effectué (si feature sensible)","Tests manuels 3 cas (nominal/edge/erreur)","PR ouvert avec description + screenshots","Review par un autre dev humain","Merge squash","Sentry monitoré post-deploy 15 min","Ticket fermé + annonce Slack"]},
  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"> 30 min de boucle (Claude n'arrive pas à fix un bug) → STOP IA → relire le code soi-même. WhatsApp tech +212 620 002 066 si bloqué architecture."}
]$sop$::jsonb,
    read_min = 20,
    updated_at = now()
WHERE slug = 'ng-dev-claude-codex-workflow';

-- ────────────────────────────────────────────────────────────────────
-- 7. ng-dev-qa-checklist — QA checklist pré-livraison
-- ────────────────────────────────────────────────────────────────────
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"⏱️ Délai","text":"QA complète pré-livraison : 1h30 à 2h. Indispensable avant chaque go-live."},
  {"type":"callout","variant":"info","title":"📞 Canal","text":"Bug bloquant trouvé → Slack #dev-qa + tag dev concerné. Doute UX → Designer."},
  {"type":"callout","variant":"danger","title":"🚫 Règle absolue","text":"JAMAIS livrer un site/app au client sans passer cette checklist EN ENTIER. Une étape non testée = un bug en prod = client mécontent."},
  {"type":"heading2","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. TEST RESPONSIVE — 5 BREAKPOINTS"},
  {"type":"paragraph","text":"🎯 Objectif : Vérifier rendu sur tous formats. ⏱️ Temps : 20 min."},
  {"type":"paragraph","text":"📍 Point de départ : Site/app en staging."},
  {"type":"paragraph","text":"🖥️ OÙ : Chrome DevTools + appareils réels."},
  {"type":"numbered","items":["Chrome → F12 → Toggle device toolbar","Test breakpoint mobile : 375x667 (iPhone SE)","Test breakpoint mobile L : 414x896 (iPhone 11 Pro Max)","Test breakpoint tablette : 768x1024 (iPad)","Test breakpoint desktop : 1440x900","Test breakpoint large : 1920x1080","Test sur appareil RÉEL : iPhone (Safari + Chrome) + Android (Chrome)"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — points à vérifier par breakpoint :"},
  {"type":"list","items":["Pas de scroll horizontal","Tous les boutons cliquables (taille ≥ 44x44px)","Texte lisible sans zoom (font ≥ 14px)","Images pas pixelisées ni écrasées","Menu burger fonctionne sur mobile","Formulaires utilisables (clavier ne masque pas le champ)"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Capture d'écran chaque breakpoint dans dossier QA → pas de problème visuel."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Scroll horizontal mobile → élément avec width fixe > 100vw → trouver via DevTools outline. Burger ne s'ouvre pas → JS bloqué par autre script."},
  {"type":"paragraph","text":"➡️ Étape suivante : cross-browser."},

  {"type":"heading2","text":"2. TEST CROSS-BROWSER"},
  {"type":"paragraph","text":"🎯 Objectif : Garantir rendu identique sur 4 navigateurs. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : Responsive OK."},
  {"type":"paragraph","text":"🖥️ OÙ : Chrome + Firefox + Safari + Edge."},
  {"type":"numbered","items":["Chrome (dernière version) → parcours complet","Firefox → idem","Safari (Mac) → idem","Edge → idem","Sur mobile : Safari iOS + Chrome iOS + Chrome Android"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Aucune différence visible majeure. Animations fluides partout."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Safari bug avec flexbox gap → fallback margin. Edge mauvais render font → fallback web-safe. Animations saccadées → réduire complexité ou ajouter will-change."},
  {"type":"paragraph","text":"➡️ Étape suivante : performance."},

  {"type":"heading2","text":"3. PERFORMANCE — GTMETRIX + PAGESPEED"},
  {"type":"paragraph","text":"🎯 Objectif : Vérifier scores et temps de chargement. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Site staging."},
  {"type":"paragraph","text":"🖥️ OÙ : https://gtmetrix.com + https://pagespeed.web.dev."},
  {"type":"numbered","items":["GTmetrix → entre URL → test depuis Paris ou London","PageSpeed Insights → entre URL → test Mobile + Desktop","Note les scores","Pour chaque audit rouge → identifier cause + corriger"]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT — seuils minimum :"},
  {"type":"list","items":["**GTmetrix Performance** ≥ 85 (Grade A ou B+)","**GTmetrix Structure** ≥ 90","**Loaded time** < 2s","**PageSpeed Mobile** ≥ 85","**PageSpeed Desktop** ≥ 95","**LCP** < 2.5s","**CLS** < 0.1","**FID/INP** < 200ms"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tous les seuils dépassés. Screenshot des résultats dans dossier QA."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"LCP > 2.5s → image hero trop lourde → compresser + preload. CLS élevé → images sans dimensions → ajouter width/height. JS render-blocking → defer ou async."},
  {"type":"paragraph","text":"➡️ Étape suivante : SEO."},

  {"type":"heading2","text":"4. SEO — AUDIT TECHNIQUE"},
  {"type":"paragraph","text":"🎯 Objectif : Vérifier base SEO. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Pages publiées + Yoast configuré."},
  {"type":"paragraph","text":"🖥️ OÙ : Site + outils en ligne."},
  {"type":"numbered","items":["View page source → vérifier <title>, <meta description>, <meta og:>","Toutes pages : title unique + meta description 150-160 char","H1 unique par page (pas plusieurs)","Hiérarchie H1 > H2 > H3 logique","Toutes images ont alt text","Liens internes pas cassés (test via screamingfrog ou siteliner)","sitemap.xml accessible","robots.txt présent (autorise crawl)","favicon présent et chargé"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tous points cochés. Site testé sur https://www.seoptimer.com → score > 75."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"H1 multiples → corriger thème ou Elementor. Alt vides → ajouter via WP Media Library. Sitemap 404 → permaliens en %postname%."},
  {"type":"paragraph","text":"➡️ Étape suivante : sécurité."},

  {"type":"heading2","text":"5. SÉCURITÉ — CHECKLIST"},
  {"type":"paragraph","text":"🎯 Objectif : Vérifier les fondamentaux sécurité. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Site en staging."},
  {"type":"paragraph","text":"🖥️ OÙ : Site + Wordfence + securityheaders.com."},
  {"type":"numbered","items":["SSL actif + cadenas vert","HTTPS forcé partout (HTTP redirige 301)","wp-admin user ≠ admin/administrator","Wordfence scan → 0 issue critique","https://securityheaders.com → grade ≥ A","Vérifier que /wp-config.php n'est pas accessible publiquement","Vérifier .env n'est jamais exposé","Backup UpdraftPlus actif + dernier backup < 24h","2FA admin activé (recommandé)"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Scan Wordfence clean. Securityheaders A. Backup récent visible."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Headers sécu manquants → ajouter via plugin Headers Security Advanced. .env exposé → ajouter règle .htaccess deny. User admin classique → renommer ou créer ng_admin et supprimer."},
  {"type":"paragraph","text":"➡️ Étape suivante : tests fonctionnels."},

  {"type":"heading2","text":"6. TESTS FONCTIONNELS — PARCOURS UTILISATEUR"},
  {"type":"paragraph","text":"🎯 Objectif : Simuler tous les parcours clés. ⏱️ Temps : 20 min."},
  {"type":"paragraph","text":"📍 Point de départ : Site complet."},
  {"type":"paragraph","text":"🖥️ OÙ : Front-end + back-end."},
  {"type":"numbered","items":["Parcours visiteur : Homepage → Services → Contact → Envoi formulaire","Vérifier réception email de contact sur boîte client","Si WooCommerce : Boutique → Produit → Panier → Checkout → Paiement test","Si login : créer compte → confirmer email → login → logout","Tester recherche interne","Tester filtre/tri (si applicable)","Tester pagination (si applicable)","Tester 404 → page custom s'affiche"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tous parcours fonctionnent sans erreur. Emails reçus < 1 min."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Formulaire ne s'envoie pas → vérifier reCAPTCHA + SMTP. Email contact pas reçu → vérifier WP Mail SMTP + spam. Pagination cassée → permaliens."},
  {"type":"paragraph","text":"➡️ Étape suivante : contenu."},

  {"type":"heading2","text":"7. CONTENU — RELECTURE ÉDITORIALE"},
  {"type":"paragraph","text":"🎯 Objectif : Zéro faute, contenu final, pas de lorem ipsum. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : Site quasi prêt."},
  {"type":"paragraph","text":"🖥️ OÙ : Toutes pages front."},
  {"type":"numbered","items":["Parcours toutes les pages","Aucun « Lorem ipsum » ou texte placeholder","Aucune image placeholder (drapeau gris, etc.)","Orthographe : passer par Antidote ou LanguageTool","Cohérence terminologique (ex toujours « rendez-vous » pas « RDV/rdv »)","Coordonnées EXACTES : tel, email, adresse (recroiser brief client)","Mentions légales présentes + à jour","Politique de confidentialité (RGPD/CNDP Maroc)","CGV si e-commerce"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Aucune faute. Tous textes finaux. Pages légales présentes."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Coordonnées erronées → demander relecture client AVANT livraison. Mentions absentes → générer via générateur en ligne + adapter Maroc."},
  {"type":"paragraph","text":"➡️ Étape suivante : analytics + monitoring."},

  {"type":"heading2","text":"8. ANALYTICS + MONITORING"},
  {"type":"paragraph","text":"🎯 Objectif : Tracking en place avant go-live. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Tests fonctionnels OK."},
  {"type":"paragraph","text":"🖥️ OÙ : GA4 + Search Console + uptime."},
  {"type":"numbered","items":["Google Analytics 4 installé → tag visible dans source","Test en temps réel GA4 → ta visite apparaît","Google Search Console : domaine vérifié + sitemap soumis","Meta Pixel installé (si Facebook ads prévues)","UptimeRobot → monitoring HTTP toutes les 5 min sur URL principale","Notification UptimeRobot → Slack channel #monitoring"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"GA4 temps réel détecte la visite. UptimeRobot statut Up."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"GA4 ne détecte pas → tag mal placé (doit être avant </head>). GSC vérification échoue → mauvais record DNS TXT."},
  {"type":"paragraph","text":"➡️ Étape suivante : passage en production."},

  {"type":"heading2","text":"9. GO-LIVE FINAL + REMISE CLIENT"},
  {"type":"paragraph","text":"🎯 Objectif : Mise en prod propre + transfert client. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : QA complète passée."},
  {"type":"paragraph","text":"🖥️ OÙ : Production."},
  {"type":"numbered","items":["Backup intégral pré go-live (UpdraftPlus)","Migrer staging → prod si site était en staging","Test final URL prod : tout fonctionne","Désactiver « Discourage search engines » dans WP → Réglages → Lecture","Soumettre URL à Google Search Console : Demander indexation","Créer accès admin pour le client (ng_admin_client) → lui envoyer via 1Password share","Programmer call onboarding 30 min avec client","Mettre à jour Notion DB clients : statut = Livré + date"]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Client accède en autonomie. Demande indexation envoyée. Notion à jour."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Site reste en « noindex » par oubli → catastrophe SEO → checker OBLIGATOIREMENT avant remise."},
  {"type":"paragraph","text":"➡️ Livraison terminée. Suivi 7 jours pour bugs résiduels."},

  {"type":"divider"},
  {"type":"heading2","text":"Checklist de validation"},
  {"type":"checklist","items":["Responsive testé 5 breakpoints + appareils réels","Cross-browser Chrome/FF/Safari/Edge OK","GTmetrix Grade A/B+ + PageSpeed ≥ 85 mobile","SEO on-page : titles, meta, alt, sitemap","Sécurité : SSL, headers, scan Wordfence, backup","Parcours fonctionnels testés (contact, achat, login)","Contenu final relu (zéro lorem, zéro faute)","Mentions légales + politique confidentialité + CGV","GA4 + GSC + UptimeRobot configurés","Backup pré go-live effectué","Discourage search engines désactivé","Demande indexation Google envoyée","Accès admin client transmis via 1Password","Notion DB clients à jour"]},
  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"> 30 min bloqué sur un point QA bloquant → WhatsApp tech +212 620 002 066. NE JAMAIS livrer un site qui a échoué à un point critique de cette checklist."}
]$sop$::jsonb,
    read_min = 22,
    updated_at = now()
WHERE slug = 'ng-dev-qa-checklist';

COMMIT;
