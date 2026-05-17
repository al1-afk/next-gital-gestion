-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 043 : SOPs ultra-détaillés Media Buyer
--  Next Gital · Oujda · Bureau N°7 Immeuble Kissi
--  Date : 2026-05-17
-- ════════════════════════════════════════════════════════════════════
--  Cette migration REMPLACE le champ `blocks` des 10 SOPs Media Buyer
--  par une version ultra-détaillée (6-10 étapes par SOP avec OÙ, QUOI,
--  EXEMPLES, VÉRIFICATION, PROBLÈMES FRÉQUENTS, ESCALADE).
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ════════════════════════════════════════════════════════════════════
-- 1/10 — ng-mb-creation-comptes-sociaux
-- ════════════════════════════════════════════════════════════════════
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"À qui s'adresse cette SOP","text":"Media Buyer junior/senior de Next Gital qui démarre un nouveau client. Objectif : créer / sécuriser tous les comptes sociaux nécessaires AVANT toute campagne publicitaire."},
  {"type":"callout","variant":"warning","title":"Prérequis OBLIGATOIRES","text":"1) Email pro du client (ex : contact@cabinet-fedix.ma). 2) Numéro WhatsApp Business du client. 3) Logo PNG transparent 1080x1080. 4) Photo de couverture 1200x630. 5) Description 200 mots validée. 6) Adresse + horaires."},
  {"type":"callout","variant":"tip","title":"Règle d'or","text":"JAMAIS créer un compte sur l'email perso du Media Buyer. TOUJOURS sur l'email pro du client → sinon perte d'accès si on quitte le compte."},
  {"type":"callout","variant":"danger","title":"À ne JAMAIS faire","text":"Ne pas créer la page Facebook depuis un faux profil. Ne pas utiliser un numéro déjà utilisé pour un autre WhatsApp Business. Ne pas oublier l'authentification 2FA sur l'email racine."},

  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. Préparer le dossier client GestiQ"},
  {"type":"paragraph","text":"🎯 Objectif : Centraliser tous les accès dès le départ. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Brief signé par le client + contrat."},
  {"type":"paragraph","text":"🖥️ OÙ : gestiq.nextgital.tech → Clients → Nouveau → onglet « Accès »."},
  {"type":"numbered","items":[
    "Ouvre GestiQ → Clients → bouton « + Nouveau client ».",
    "Renseigne : Nom commercial exact (ex : Cabinet Fedix), Secteur (Avocat), Ville (Oujda), Contact principal.",
    "Va dans l'onglet « Accès » et crée 4 entrées vides : Email racine, Facebook Page, Instagram Pro, WhatsApp Business.",
    "Génère un mot de passe fort dans GestiQ → bouton 🔑 (16 caractères, A-z, 0-9, symboles).",
    "Stocke le mot de passe dans le coffre-fort GestiQ (chiffré)."
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":[
    "**Nom client** → Nom commercial complet → ex : « Cabinet Avocat Fedix » → PAS « cabinet » seul",
    "**Email racine** → email@domainedu client → ex : contact@cabinet-fedix.ma → PAS gmail perso",
    "**Téléphone** → +212 6XX XX XX XX → format international obligatoire"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le dossier client apparaît dans GestiQ avec 4 lignes d'accès vides et 1 mot de passe stocké."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Email déjà utilisé → demander au client un alias (contact+ads@). Mot de passe perdu → utiliser le coffre-fort GestiQ, JAMAIS un Post-it."},
  {"type":"paragraph","text":"➡️ Étape suivante : Créer l'email pro racine."},

  {"type":"heading2","text":"2. Sécuriser l'email racine + activer 2FA"},
  {"type":"paragraph","text":"🎯 Objectif : Verrouiller l'email qui sert à créer tous les comptes. ⏱️ Temps : 8 min."},
  {"type":"paragraph","text":"📍 Point de départ : Mot de passe stocké dans GestiQ."},
  {"type":"paragraph","text":"🖥️ OÙ : Gmail / Outlook / hébergeur du domaine client."},
  {"type":"numbered","items":[
    "Connecte-toi à l'email racine du client.",
    "Va dans Paramètres → Sécurité → Validation en deux étapes.",
    "Active la 2FA via SMS sur le numéro du client (PAS le tien).",
    "Génère un code de récupération et stocke-le dans GestiQ → onglet « Codes de secours ».",
    "Ajoute un email de récupération secondaire : info@nextgital.com."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu reçois un SMS de test à la déconnexion / reconnexion."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Le client ne reçoit pas le SMS → vérifier le format (+212 6...). Numéro déjà lié à un autre compte → utiliser un numéro pro dédié."},
  {"type":"paragraph","text":"➡️ Étape suivante : Créer la Page Facebook."},

  {"type":"heading2","text":"3. Créer la Page Facebook professionnelle"},
  {"type":"paragraph","text":"🎯 Objectif : Page officielle indexable. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : Logo + couverture + description validés."},
  {"type":"paragraph","text":"🖥️ OÙ : facebook.com/pages/create (connecté à l'email racine)."},
  {"type":"numbered","items":[
    "Va sur facebook.com/pages/create.",
    "Choisis « Entreprise ou marque ».",
    "Nom de la Page = nom commercial EXACT (ex : Restaurant Al Baraka Oujda).",
    "Catégorie = la plus précise possible (ex : Restaurant marocain).",
    "Sous-catégorie = secondaire (ex : Tagine, Couscous).",
    "Clique sur « Créer la Page ».",
    "Ajoute la photo de profil (logo PNG, idéalement 170x170 visible).",
    "Ajoute la photo de couverture 1200x630 (charte client).",
    "Va dans À propos → renseigne : adresse Bureau, téléphone, email, site web, horaires, description courte (155 caractères), description longue (200 mots)."
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":[
    "**Nom Page** → exactement comme sur l'enseigne → ex : « Pharmacie Andalous » → PAS « pharmacie andalous oujda 24/7 »",
    "**Catégorie** → la plus précise → ex : « Cabinet dentaire » → PAS « Santé »",
    "**Description courte** → 155 caractères max, mots-clés + ville → ex : « Cabinet dentaire à Oujda — soins, implants, urgences. RDV : +212 6XX »",
    "**Username** → @nomclient_oujda → ex : @pharmacieandalous → PAS d'espaces"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"La Page est publique, le logo est net, l'adresse Oujda est cliquable, le bouton « Appeler » fonctionne sur mobile."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Catégorie verrouillée → la modifier dans Paramètres → Modèles et onglets. Nom refusé (déjà pris) → ajouter la ville (« Oujda »). Username non disponible → essayer une variante."},
  {"type":"paragraph","text":"➡️ Étape suivante : Activer Instagram Pro."},

  {"type":"heading2","text":"4. Activer le compte Instagram Pro"},
  {"type":"paragraph","text":"🎯 Objectif : Compte Instagram en mode Business lié à la Page Facebook. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Page Facebook créée."},
  {"type":"paragraph","text":"🖥️ OÙ : application Instagram mobile (Android ou iOS)."},
  {"type":"numbered","items":[
    "Ouvre l'app Instagram → S'inscrire avec l'email racine.",
    "Username = identique à la Page Facebook (@pharmacieandalous).",
    "Une fois connecté → Profil → menu ☰ → Paramètres et confidentialité.",
    "Aller dans Compte → Passer au compte professionnel.",
    "Choisir « Entreprise » (PAS Créateur).",
    "Catégorie = la même que la Page Facebook.",
    "Lier à la Page Facebook créée à l'étape 3.",
    "Renseigner email, téléphone, adresse.",
    "Activer la 2FA dans Paramètres → Sécurité."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Dans Insights → Audience apparaît, le bouton « Contact » est visible sur le profil, la Page Facebook est listée dans « Comptes liés »."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Liaison Page Facebook impossible → vérifier que l'email racine est admin de la Page. Compte bloqué → patienter 24h et confirmer l'email."},
  {"type":"paragraph","text":"➡️ Étape suivante : Configurer WhatsApp Business."},

  {"type":"heading2","text":"5. Configurer WhatsApp Business"},
  {"type":"paragraph","text":"🎯 Objectif : Numéro pro avec catalogue + messages auto. ⏱️ Temps : 12 min."},
  {"type":"paragraph","text":"📍 Point de départ : Numéro pro dédié (PAS perso)."},
  {"type":"paragraph","text":"🖥️ OÙ : app WhatsApp Business (Play Store / App Store)."},
  {"type":"numbered","items":[
    "Installer WhatsApp Business sur le téléphone du client (ou pro dédié).",
    "Vérifier le numéro (+212 6XX) via SMS.",
    "Nom de l'entreprise = nom commercial exact.",
    "Catégorie = mêmes que Page Facebook.",
    "Ajouter photo de profil (logo).",
    "Renseigner adresse, horaires, email, site web.",
    "Configurer un message d'accueil : « Bonjour 👋 Bienvenue chez {Client}. Nous répondons en moins d'1h. »",
    "Configurer un message d'absence (horaires fermés).",
    "Activer le statut « Visible »."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Envoie un message-test depuis un autre numéro → tu reçois la réponse automatique."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Numéro déjà utilisé sur WhatsApp normal → désinstaller, sauvegarder, réinstaller en Business. Code SMS non reçu → option « Appel vocal »."},
  {"type":"paragraph","text":"➡️ Étape suivante : Documenter dans GestiQ."},

  {"type":"heading2","text":"6. Documenter tous les accès dans GestiQ"},
  {"type":"paragraph","text":"🎯 Objectif : Traçabilité totale. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Tous les comptes créés."},
  {"type":"paragraph","text":"🖥️ OÙ : gestiq.nextgital.tech → Clients → {Client} → onglet Accès."},
  {"type":"numbered","items":[
    "Renseigne pour chaque compte : URL, identifiant, mot de passe (chiffré).",
    "Ajoute une note avec la date de création et le créateur.",
    "Ajoute la photo de la 2FA (QR code) dans le coffre.",
    "Marque le client comme « Onboarding terminé »."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Un autre Media Buyer peut se connecter à tous les comptes sans te déranger."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Mot de passe en clair par erreur → utiliser TOUJOURS le champ 🔒 sécurisé. Note manquante → bloque l'audit mensuel."},
  {"type":"paragraph","text":"➡️ Étape suivante : Brief équipe via GestiQ → Notifications."},

  {"type":"divider"},

  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Email racine créé avec 2FA active",
    "Page Facebook publique, logo + couverture",
    "Instagram Pro lié à la Page",
    "WhatsApp Business configuré avec messages auto",
    "Tous les accès chiffrés dans GestiQ",
    "Note d'onboarding envoyée à l'équipe"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si bloqué plus de 30 minutes (création de compte refusée, 2FA cassée, accès perdu) → WhatsApp +212 620 002 066. JAMAIS contourner avec un compte perso."}
]$sop$::jsonb,
    read_min = 15,
    updated_at = now()
WHERE slug = 'ng-mb-creation-comptes-sociaux';

-- ════════════════════════════════════════════════════════════════════
-- 2/10 — ng-mb-meta-business-manager
-- ════════════════════════════════════════════════════════════════════
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"À qui s'adresse cette SOP","text":"Media Buyer qui configure Meta Business Manager pour Next Gital avec un nouveau client. Objectif : structurer proprement les actifs (Pages, comptes pub, Pixel) sans mélanger les clients."},
  {"type":"callout","variant":"warning","title":"Prérequis OBLIGATOIRES","text":"1) SOP « Création comptes sociaux » terminée. 2) Page Facebook client active. 3) Email pro Next Gital (info@nextgital.com) admin du BM principal. 4) Numéro carte bancaire client pour le compte pub."},
  {"type":"callout","variant":"tip","title":"Architecture cible","text":"Business Manager = NEXT GITAL (un seul BM, tous les clients dedans). Chaque client = 1 Page + 1 Compte publicitaire + 1 Pixel + 1 Catalogue (si e-com)."},
  {"type":"callout","variant":"danger","title":"À ne JAMAIS faire","text":"Ne JAMAIS donner accès au BM Next Gital au client. Le client doit créer SON BM et nous donner accès à SES actifs depuis SON BM."},

  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. Vérifier l'existence du BM Next Gital"},
  {"type":"paragraph","text":"🎯 Objectif : Confirmer qu'un seul BM Next Gital existe. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"📍 Point de départ : Compte Facebook perso du Media Buyer connecté."},
  {"type":"paragraph","text":"🖥️ OÙ : business.facebook.com."},
  {"type":"numbered","items":[
    "Ouvrir business.facebook.com.",
    "En haut à gauche → menu déroulant des BM.",
    "Vérifier qu'il y a UN SEUL BM nommé « Next Gital ».",
    "Si plusieurs → escalader, NE PAS créer un doublon.",
    "Cliquer sur « Next Gital » pour entrer."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu vois l'ID du BM (15 chiffres) dans Paramètres → Infos sur l'entreprise."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Tu n'as pas accès au BM Next Gital → demander à info@nextgital.com d'ajouter ton email pro comme Admin."},
  {"type":"paragraph","text":"➡️ Étape suivante : Demander l'accès à la Page client."},

  {"type":"heading2","text":"2. Ajouter la Page client au BM Next Gital"},
  {"type":"paragraph","text":"🎯 Objectif : Pouvoir publier et publier des ads pour la Page sans la posséder. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Client admin de SA Page."},
  {"type":"paragraph","text":"🖥️ OÙ : business.facebook.com → Paramètres → Comptes → Pages."},
  {"type":"numbered","items":[
    "Paramètres → Comptes → Pages.",
    "Bouton « Ajouter » → « Demander l'accès à une Page » (PAS « Réclamer »).",
    "Coller l'URL de la Page (ex : facebook.com/pharmacieandalous).",
    "Choisir les autorisations : Gérer la Page + Créer du contenu + Modérer + Publicités + Insights + Messages.",
    "Envoyer la demande.",
    "Côté client : il reçoit une notification → il doit accepter dans business.facebook.com OU directement sur la Page → Paramètres → Rôles de Page."
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":[
    "**Type de demande** → toujours « Demander l'accès » → JAMAIS « Réclamer la propriété »",
    "**Autorisations** → cocher TOUTES sauf « Gérer les actifs et les paramètres » (garde côté client)"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"La Page apparaît dans Comptes → Pages avec statut « Acceptée »."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Client ne trouve pas la demande → lui envoyer un screenshot du chemin (Paramètres → Demandes). Demande expirée après 30j → refaire."},
  {"type":"paragraph","text":"➡️ Étape suivante : Créer le compte publicitaire."},

  {"type":"heading2","text":"3. Créer le compte publicitaire du client"},
  {"type":"paragraph","text":"🎯 Objectif : Compte pub dédié, facturé sur la carte du client. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Carte bancaire client + RIB validés."},
  {"type":"paragraph","text":"🖥️ OÙ : business.facebook.com → Paramètres → Comptes → Comptes publicitaires."},
  {"type":"numbered","items":[
    "Paramètres → Comptes → Comptes publicitaires → Ajouter → Créer un nouveau compte publicitaire.",
    "Nom = « NG — {Client} — Ads » (ex : « NG — Cabinet Fedix — Ads »).",
    "Fuseau horaire = (GMT+01:00) Casablanca.",
    "Devise = MAD (dirham marocain).",
    "Choisir « Mon entreprise ».",
    "Assigner le compte au BM Next Gital.",
    "Ajouter une personne (toi) avec rôle « Annonceur ».",
    "Ajouter le moyen de paiement : carte Visa/Mastercard du client OU compte bancaire."
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":[
    "**Nom du compte** → « NG — {Client} — Ads » → ex : « NG — Restaurant Al Baraka — Ads »",
    "**Fuseau** → Casablanca → PAS Paris (sinon décalage des rapports)",
    "**Devise** → MAD → IMMUABLE après création"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le compte apparaît avec ID (16 chiffres), statut Actif, paiement validé (test de 1 MAD débité)."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Carte refusée → vérifier que les paiements internationaux sont activés. Compte limité → faire une dépense de 5 MAD pour le « déverrouiller »."},
  {"type":"paragraph","text":"➡️ Étape suivante : Créer le Pixel."},

  {"type":"heading2","text":"4. Créer le Pixel client + Conversion API"},
  {"type":"paragraph","text":"🎯 Objectif : Tracker les conversions sur le site client. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"📍 Point de départ : Site web client accessible (WordPress / Shopify / autre)."},
  {"type":"paragraph","text":"🖥️ OÙ : business.facebook.com → Sources de données → Ensembles de données (anciennement Pixel)."},
  {"type":"numbered","items":[
    "Aller dans Events Manager (business.facebook.com/events_manager).",
    "Connecter des sources de données → Web → Suivant.",
    "Nom = « Pixel {Client} » (ex : « Pixel Cabinet Fedix »).",
    "URL du site = https://{site-client}.ma.",
    "Choisir « Pixel Meta + API Conversions ».",
    "Méthode d'installation : recommandée = via Partenaire (Shopify/WP) OU code manuel.",
    "Copier le code Pixel (base code) et l'installer dans le <head> du site.",
    "Configurer les événements standards : PageView (auto), ViewContent, Lead, Contact, Purchase si e-com.",
    "Tester avec l'extension Chrome « Meta Pixel Helper » → ouvrir le site → l'extension doit afficher le Pixel ID en vert."
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":[
    "**Nom Pixel** → « Pixel {Client} » → ex : « Pixel Pharmacie Andalous »",
    "**Événements minimum** → PageView + Lead (ou Contact) + ViewContent",
    "**Événement Lead** → déclenché sur soumission formulaire ou clic WhatsApp"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Pixel Helper Chrome affiche le Pixel en vert. Events Manager → Vue d'ensemble montre des événements PageView dans les 5 min."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pixel Helper en rouge → vérifier que le code est bien dans le <head> et qu'il n'y a pas de cookie banner qui bloque. Aucun événement → vider cache + tester en navigation privée."},
  {"type":"paragraph","text":"➡️ Étape suivante : Vérifier le domaine."},

  {"type":"heading2","text":"5. Vérifier le domaine du site client"},
  {"type":"paragraph","text":"🎯 Objectif : Pouvoir prioriser les événements et débloquer iOS 14+. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Accès DNS du domaine OU FTP du site."},
  {"type":"paragraph","text":"🖥️ OÙ : Paramètres → Sécurité de la marque → Domaines."},
  {"type":"numbered","items":[
    "Paramètres → Sécurité de la marque → Domaines → Ajouter.",
    "Saisir le domaine racine (ex : cabinet-fedix.ma, PAS www. ni https://).",
    "Choisir une méthode : DNS TXT (recommandé) OU balise meta OU upload fichier HTML.",
    "Si DNS : ajouter l'enregistrement TXT chez le registrar du domaine.",
    "Si meta : ajouter la balise dans le <head>.",
    "Cliquer « Vérifier » → attendre confirmation."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le domaine apparaît avec statut « Vérifié » (point vert)."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"DNS pas propagé → attendre 24h max. Multi-domaines → vérifier chacun séparément."},
  {"type":"paragraph","text":"➡️ Étape suivante : Configurer la mesure agrégée."},

  {"type":"heading2","text":"6. Configurer la mesure agrégée des événements (iOS 14+)"},
  {"type":"paragraph","text":"🎯 Objectif : Hiérarchiser les 8 événements clés pour iOS. ⏱️ Temps : 8 min."},
  {"type":"paragraph","text":"📍 Point de départ : Domaine vérifié + Pixel installé."},
  {"type":"paragraph","text":"🖥️ OÙ : Events Manager → Mesure agrégée des événements."},
  {"type":"numbered","items":[
    "Events Manager → Mesure agrégée des événements → onglet Web.",
    "Cliquer sur ton domaine vérifié.",
    "Modifier les événements → ordre par priorité :",
    "Position 1 = Purchase (ou Lead si pas e-com)",
    "Position 2 = Contact (clic WhatsApp)",
    "Position 3 = AddToCart (ou ViewContent)",
    "Position 4 à 8 = autres événements pertinents.",
    "Sauvegarder."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"L'ordre est visible et l'événement #1 est celui qui rapporte le plus d'argent."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Changement d'ordre → 72h de gel des campagnes existantes. Faire AVANT lancement."},
  {"type":"paragraph","text":"➡️ Étape suivante : Inviter les membres de l'équipe."},

  {"type":"heading2","text":"7. Inviter l'équipe Next Gital"},
  {"type":"paragraph","text":"🎯 Objectif : Donner accès aux bons membres avec les bons rôles. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"🖥️ OÙ : Paramètres → Utilisateurs → Personnes."},
  {"type":"numbered","items":[
    "Paramètres → Personnes → Ajouter.",
    "Saisir l'email pro du membre (jamais perso).",
    "Rôle = Employé (PAS Admin).",
    "Attribuer le compte publicitaire {Client} avec rôle « Annonceur ».",
    "Attribuer la Page {Client} avec rôle « Contenu + Modérateur + Annonceur »."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le membre voit le compte dans son Ads Manager."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Membre voit pas le compte → vérifier qu'il a accepté l'invitation par email."},
  {"type":"paragraph","text":"➡️ Étape suivante : Documenter dans GestiQ."},

  {"type":"heading2","text":"8. Documenter dans GestiQ"},
  {"type":"paragraph","text":"🎯 Objectif : Traçabilité. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"🖥️ OÙ : gestiq.nextgital.tech → Clients → {Client} → onglet « Meta »."},
  {"type":"numbered","items":[
    "Noter : ID Compte pub, ID Pixel, ID Page, domaine vérifié, méthode de paiement.",
    "Capture d'écran du Pixel Helper en vert → upload dans GestiQ.",
    "Marquer la tâche « Setup Meta » comme terminée."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le dossier client dans GestiQ contient tous les IDs."},

  {"type":"divider"},

  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "BM Next Gital identifié (pas de doublon)",
    "Page client acceptée dans le BM",
    "Compte publicitaire créé en MAD",
    "Pixel installé + Pixel Helper vert",
    "Domaine vérifié",
    "Mesure agrégée configurée (8 événements ordonnés)",
    "Équipe invitée avec bons rôles",
    "IDs documentés dans GestiQ"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si bloqué plus de 45 minutes (BM refusé, Pixel ne fire pas, domaine non vérifié) → WhatsApp +212 620 002 066."}
]$sop$::jsonb,
    read_min = 18,
    updated_at = now()
WHERE slug = 'ng-mb-meta-business-manager';

-- ════════════════════════════════════════════════════════════════════
-- 3/10 — ng-mb-facebook-ads
-- ════════════════════════════════════════════════════════════════════
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"À qui s'adresse cette SOP","text":"Media Buyer Next Gital qui lance sa première campagne Facebook Ads pour un client (ex : Dr. Karim dentiste, Restaurant Al Baraka)."},
  {"type":"callout","variant":"warning","title":"Prérequis OBLIGATOIRES","text":"1) BM configuré (SOP ng-mb-meta-business-manager). 2) Pixel actif + Pixel Helper vert. 3) Brief client validé (objectif, budget, cible, USP). 4) 3 visuels Canva 1080x1080 + 1 vidéo 9:16. 5) Landing page testée mobile."},
  {"type":"callout","variant":"tip","title":"Structure CBO Next Gital","text":"1 Campagne (CBO) → 2-3 Ad sets (audience) → 3 Ads (créa) minimum. Budget centralisé sur la campagne, jamais sur l'ad set."},
  {"type":"callout","variant":"danger","title":"À ne JAMAIS faire","text":"Ne PAS lancer sans Pixel. Ne PAS toucher la campagne pendant les 48 premières heures (phase d'apprentissage). Ne PAS mettre <50 MAD/jour (trop faible pour apprendre)."},

  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. Définir l'objectif business + l'objectif Meta"},
  {"type":"paragraph","text":"🎯 Objectif : Aligner la campagne sur un KPI mesurable. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"📍 Point de départ : Brief client signé."},
  {"type":"paragraph","text":"🖥️ OÙ : document Notion ou GestiQ → Brief campagne."},
  {"type":"numbered","items":[
    "Identifier l'objectif business (ex : 30 RDV/mois pour Dr. Karim).",
    "Traduire en objectif Meta : Trafic / Engagement / Prospects / Ventes / Couverture / Vues vidéo.",
    "Définir le KPI principal (CPL, CPM, CTR, ROAS).",
    "Définir la cible chiffrée (ex : CPL < 15 MAD).",
    "Faire valider par le client par écrit (email)."
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":[
    "**Cabinet dentaire** → objectif Prospects → KPI CPL → cible 20 MAD",
    "**Restaurant** → objectif Trafic + Couverture locale → CPM",
    "**E-commerce** → objectif Ventes → ROAS ≥ 3"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le brief est signé par le client + objectif Meta noté dans GestiQ."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Client veut tout (notoriété + ventes + leads) → forcer un choix unique, expliquer qu'on testera les autres ensuite."},
  {"type":"paragraph","text":"➡️ Étape suivante : Créer la campagne dans Ads Manager."},

  {"type":"heading2","text":"2. Créer la campagne dans Ads Manager"},
  {"type":"paragraph","text":"🎯 Objectif : Squelette de la campagne. ⏱️ Temps : 8 min."},
  {"type":"paragraph","text":"🖥️ OÙ : adsmanager.facebook.com → bouton vert « + Créer »."},
  {"type":"numbered","items":[
    "Aller sur adsmanager.facebook.com → sélectionner le compte pub {Client}.",
    "Cliquer « + Créer ».",
    "Choisir l'objectif (ex : Prospects).",
    "Nom de la campagne = format Next Gital : « {Client} | {Objectif} | {Mois}-{Année} » → ex : « Dr Karim | Prospects | 05-2026 ».",
    "Activer le « Budget de campagne avantage+ » (CBO).",
    "Budget = quotidien (PAS à vie).",
    "Saisir le budget en MAD (ex : 100 MAD/jour).",
    "Stratégie d'enchère = « Volume le plus élevé » par défaut.",
    "Tests A/B = désactivé.",
    "Continuer."
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":[
    "**Nom campagne** → « {Client} | {Objectif} | {Mois}-{Année} » → ex : « Cabinet Fedix | Prospects | 05-2026 »",
    "**Budget min** → 50 MAD/jour pour engagement, 100 MAD/jour pour prospects, 200 MAD/jour pour ventes"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"La campagne apparaît dans Ads Manager avec statut « Brouillon »."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Objectif « Ventes » indisponible → vérifier que le Pixel a au moins 1 événement Purchase dans les 7 derniers jours."},
  {"type":"paragraph","text":"➡️ Étape suivante : Créer les ad sets."},

  {"type":"heading2","text":"3. Créer l'ad set (audience + placements)"},
  {"type":"paragraph","text":"🎯 Objectif : Cibler la bonne audience. ⏱️ Temps : 15 min par ad set."},
  {"type":"paragraph","text":"🖥️ OÙ : niveau Ad set sous la campagne."},
  {"type":"numbered","items":[
    "Nom ad set = « {Audience} | {Placement} » → ex : « Oujda 25-55 | Auto ».",
    "Événement de conversion = Lead (ou celui correspondant à l'objectif).",
    "Lieu = Oujda + rayon 25 km (cliquer sur la carte).",
    "Âge = 25-55 (ajuster selon le secteur).",
    "Sexe = Tous (sauf si pertinent).",
    "Langue = Français + Arabe.",
    "Centres d'intérêt = précis (ex : « Soins dentaires », « Implant dentaire », « Beauté »).",
    "Audience avantage+ = ON (recommandé).",
    "Placements = Avantage+ (automatique).",
    "Optimisation = Prospects.",
    "Fenêtre d'attribution = 7 jours après le clic, 1 jour après l'affichage."
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT (audiences types Oujda) :"},
  {"type":"list","items":[
    "**Dr. Karim dentiste** → Oujda 25 km → 25-60 → intérêts : soins dentaires, blanchiment, implants",
    "**Restaurant Al Baraka** → Oujda 15 km → 25-55 → intérêts : restaurants, food, sortie en famille",
    "**Cabinet Fedix avocat** → Oujda + Berkane + Nador 50 km → 30-65 → intérêts : droit, immobilier"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"L'estimation d'audience est entre 50k et 500k (zone verte)."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Audience trop large (>1M) → ajouter intérêts. Trop étroite (<10k) → enlever des contraintes."},
  {"type":"paragraph","text":"➡️ Étape suivante : Créer 3 ads minimum."},

  {"type":"heading2","text":"4. Créer 3 ads minimum (créa + copy)"},
  {"type":"paragraph","text":"🎯 Objectif : Tester plusieurs créas pour identifier la gagnante. ⏱️ Temps : 20 min."},
  {"type":"paragraph","text":"🖥️ OÙ : niveau Publicité."},
  {"type":"numbered","items":[
    "Identité = sélectionner la Page Facebook + compte Instagram client.",
    "Format = Image OU Vidéo OU Carrousel.",
    "Créa = upload du visuel Canva 1080x1080 (image) ou 1080x1920 (vidéo 9:16).",
    "Texte principal (90 caractères visibles avant « voir plus ») = accroche forte avec emoji.",
    "Titre (40 caractères) = bénéfice ou CTA.",
    "Description (30 caractères) = détail.",
    "Destination = WhatsApp OU site web (selon objectif).",
    "Si site → URL UTM-taggée → ?utm_source=facebook&utm_medium=cpc&utm_campaign={NomCampagne}.",
    "Si WhatsApp → numéro client + message pré-rempli « Bonjour, je viens de Facebook ».",
    "CTA = « En savoir plus » OU « Envoyer un message » OU « Réserver ».",
    "Suivi des événements = Pixel + Conversion API activés.",
    "Publier."
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT (copy type) :"},
  {"type":"list","items":[
    "**Cabinet dentaire** → « 🦷 Un sourire éclatant en 1 RDV à Oujda. Diagnostic offert cette semaine. » → CTA « Réserver »",
    "**Restaurant** → « 🍽️ Tajine signature + thé offert ce soir au Restaurant Al Baraka. » → CTA « Itinéraire »",
    "**Pharmacie** → « 💊 Livraison gratuite à Oujda en 30 min. Commandez sur WhatsApp. » → CTA « Envoyer un message »"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Les 3 ads sont en statut « En cours d'examen », l'aperçu mobile est OK."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Ad rejetée → souvent à cause d'allégations santé ou avant/après. Reformuler : remplacer « guérir » par « accompagner »."},
  {"type":"paragraph","text":"➡️ Étape suivante : Vérifier la cohérence + publier."},

  {"type":"heading2","text":"5. Vérifier puis publier la campagne"},
  {"type":"paragraph","text":"🎯 Objectif : Éviter les erreurs avant mise en ligne. ⏱️ Temps : 5 min."},
  {"type":"numbered","items":[
    "Vérifier le nom des 3 niveaux (campagne / ad set / ads).",
    "Vérifier le budget (jour, MAD).",
    "Vérifier la cible (lieu, âge, intérêts).",
    "Vérifier les liens UTM (cliquer dans l'aperçu).",
    "Vérifier le Pixel (Pixel Helper vert).",
    "Cliquer « Publier »."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Statut « En cours d'examen » dans les 5 min, puis « Actif » dans 1-24h."},
  {"type":"paragraph","text":"➡️ Étape suivante : Phase d'apprentissage."},

  {"type":"heading2","text":"6. Phase d'apprentissage (48h-7j)"},
  {"type":"paragraph","text":"🎯 Objectif : Laisser Meta apprendre sans toucher. ⏱️ Temps : passive."},
  {"type":"numbered","items":[
    "Ne PAS toucher la campagne pendant 48h minimum.",
    "Vérifier 2x/jour : impressions, CPM, CTR, CPL.",
    "Objectif : sortir de l'apprentissage = 50 conversions/ad set/7j.",
    "Si CPL > 2x cible après 48h → mettre en pause et analyser.",
    "Si CTR < 1% → créa à changer.",
    "Si CPM > 30 MAD → audience à élargir."
  ]},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Tentation de couper après 24h → résister. Modifier le budget en pleine phase d'apprentissage → reset complet."},
  {"type":"paragraph","text":"➡️ Étape suivante : Optimisation hebdomadaire."},

  {"type":"heading2","text":"7. Optimisation hebdomadaire"},
  {"type":"paragraph","text":"🎯 Objectif : Améliorer le CPL chaque semaine. ⏱️ Temps : 30 min/semaine."},
  {"type":"numbered","items":[
    "Chaque lundi : exporter le rapport Ads Manager.",
    "Identifier la meilleure ad (CPL le plus bas).",
    "Couper les ads avec CPL > 1.5x la moyenne.",
    "Dupliquer la meilleure ad + tester une nouvelle créa.",
    "Augmenter le budget de +20% max si performant.",
    "Refaire un Custom Audience des engagés à 60j."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le CPL diminue ou se stabilise sous la cible."},
  {"type":"paragraph","text":"➡️ Étape suivante : Reporting (voir SOP rapport mensuel)."},

  {"type":"divider"},

  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Objectif Meta aligné avec le brief client",
    "Campagne CBO créée avec nom standard NG",
    "Ad set(s) ciblés Oujda + intérêts précis",
    "3 ads minimum avec créas et copies validées",
    "Pixel Helper vert sur la landing",
    "UTM ajoutés à toutes les URLs",
    "Phase d'apprentissage respectée (48h sans toucher)",
    "Reporting hebdo programmé"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si bloqué plus de 30 min (compte désactivé, ad refusée 3x, CPL > 5x cible) → WhatsApp +212 620 002 066."}
]$sop$::jsonb,
    read_min = 20,
    updated_at = now()
WHERE slug = 'ng-mb-facebook-ads';

-- ════════════════════════════════════════════════════════════════════
-- 4/10 — ng-mb-facebook-instagram-ads (campagne combinée multi-plateforme)
-- ════════════════════════════════════════════════════════════════════
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"À qui s'adresse cette SOP","text":"Media Buyer qui lance une campagne CROSS Facebook + Instagram (Feed + Stories + Reels). Idéal pour secteurs visuels : restaurants, salons, mode, hammam, boulangeries."},
  {"type":"callout","variant":"warning","title":"Prérequis OBLIGATOIRES","text":"1) Compte Instagram Pro lié à la Page (SOP comptes sociaux). 2) BM + Pixel + Conversion API OK. 3) 1 visuel carré + 1 visuel vertical (9:16) + 1 vidéo 9:16 < 30s. 4) Brief client + KPI signés."},
  {"type":"callout","variant":"tip","title":"Astuce Next Gital","text":"Sur Instagram, les Reels et Stories convertissent 2-3x mieux que le Feed pour les secteurs visuels. Toujours faire un asset 9:16 dédié."},
  {"type":"callout","variant":"danger","title":"À ne JAMAIS faire","text":"Ne PAS prendre un visuel carré et le forcer en 9:16 (mauvais cadrage). Ne PAS oublier les sous-titres sur les vidéos (85% des gens regardent sans son)."},

  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. Auditer les comptes Page + Instagram"},
  {"type":"paragraph","text":"🎯 Objectif : Vérifier que les 2 comptes sont prêts. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"🖥️ OÙ : business.facebook.com → Comptes."},
  {"type":"numbered","items":[
    "Page Facebook : photo profil + couverture + bouton CTA = OK.",
    "Instagram Pro : 6 derniers posts récents (< 30j).",
    "Bio Instagram = 150 caractères + lien (Linktree ou direct).",
    "Compte Instagram lié à la Page (vérifier dans Paramètres Page → Instagram).",
    "Au moins 1 Reel et 1 Story actifs."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Les 2 comptes sont actifs, soignés, et liés."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Instagram pas lié à la Page → impossible de publier des ads Insta depuis le BM. Solution : Paramètres → Instagram → Connecter le compte."},
  {"type":"paragraph","text":"➡️ Étape suivante : Préparer les créas adaptées."},

  {"type":"heading2","text":"2. Préparer 3 formats de créas adaptés"},
  {"type":"paragraph","text":"🎯 Objectif : 1 créa par placement principal. ⏱️ Temps : 30 min (avec designer)."},
  {"type":"paragraph","text":"🖥️ OÙ : Canva Pro → templates Next Gital."},
  {"type":"numbered","items":[
    "Créa 1 : Image carrée 1080x1080 → Feed Facebook + Insta.",
    "Créa 2 : Image verticale 1080x1920 → Stories + Reels statiques.",
    "Créa 3 : Vidéo verticale 1080x1920 < 30s → Reels + Stories.",
    "Toutes les créas : logo client + texte court (max 7 mots) + CTA visible.",
    "Vidéo : sous-titres OBLIGATOIRES (générés via CapCut).",
    "Aucun texte dans les 250 pixels du bas (logo Insta) ni du haut."
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":[
    "**Restaurant Al Baraka** → Carré : plat signature ; Vidéo Reel : préparation tagine 15s ; Story : promo soir",
    "**Salon Atlas Beauté** → Carré : avant/après ; Vidéo : massage relaxant ; Story : tarif",
    "**Boulangerie Atlas** → Carré : croissants ; Vidéo : fournil 10s ; Story : nouveauté"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Les 3 formats sont stockés dans GestiQ → Médiathèque {Client} avec tags."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Trop de texte (>20%) → l'ad sera diffusée moins → utiliser l'outil officiel Meta Text Overlay."},
  {"type":"paragraph","text":"➡️ Étape suivante : Créer la campagne multi-placements."},

  {"type":"heading2","text":"3. Créer la campagne CBO multi-placements"},
  {"type":"paragraph","text":"🎯 Objectif : 1 campagne pour FB + IG. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"🖥️ OÙ : Ads Manager → + Créer."},
  {"type":"numbered","items":[
    "Objectif = Engagement OU Trafic OU Prospects (selon brief).",
    "Nom = « {Client} | Cross FB+IG | {Mois}-{Année} ».",
    "CBO activé = oui, budget quotidien 100-200 MAD.",
    "Stratégie d'enchère = Volume le plus élevé."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Campagne en brouillon avec budget correct."},
  {"type":"paragraph","text":"➡️ Étape suivante : Configurer l'ad set."},

  {"type":"heading2","text":"4. Configurer l'ad set avec placements manuels"},
  {"type":"paragraph","text":"🎯 Objectif : Contrôler quels placements reçoivent les ads. ⏱️ Temps : 10 min."},
  {"type":"numbered","items":[
    "Audience : Oujda + 25 km, 18-55, intérêts secteur.",
    "Placements = Manuel (PAS Avantage+).",
    "Cocher : Facebook Feed, Facebook Stories, Instagram Feed, Instagram Stories, Instagram Reels, Instagram Explore.",
    "Décocher : Audience Network + Messenger (souvent peu performants).",
    "Optimisation = Conversions (Lead/Contact)."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"6 placements cochés, AN décoché."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Reels Insta non disponible → vérifier que le compte Insta est en mode Pro Business."},
  {"type":"paragraph","text":"➡️ Étape suivante : Lier les bonnes créas par placement."},

  {"type":"heading2","text":"5. Lier les bonnes créas à chaque placement"},
  {"type":"paragraph","text":"🎯 Objectif : Image carrée pour Feed, verticale pour Stories/Reels. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"🖥️ OÙ : niveau Ad → onglet « Créa »."},
  {"type":"numbered","items":[
    "Pour chaque placement, sélectionner « Modifier le contenu publicitaire ».",
    "Feed FB + Feed IG = créa carrée 1080x1080.",
    "Stories FB + Stories IG + Reels = créa verticale 1080x1920.",
    "Explore IG = créa carrée.",
    "Texte = adapté par placement (Story = 1 ligne, Feed = 90 caractères)."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"L'aperçu Ad Manager montre la bonne créa par placement."},
  {"type":"paragraph","text":"➡️ Étape suivante : Configurer le CTA + destination."},

  {"type":"heading2","text":"6. Configurer CTA, destination et UTM"},
  {"type":"paragraph","text":"🎯 Objectif : Drainer le bon trafic. ⏱️ Temps : 5 min."},
  {"type":"numbered","items":[
    "CTA = « Envoyer un message » (WhatsApp) ou « En savoir plus » (site).",
    "Destination = numéro WhatsApp client OU URL avec UTM.",
    "UTM : ?utm_source=meta&utm_medium=cpc&utm_campaign={NomCamp}&utm_content={placement}.",
    "Message WhatsApp pré-rempli = « Bonjour 👋 je viens d'Instagram »."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Cliquer aperçu mobile → CTA fonctionne, WhatsApp s'ouvre avec le message."},
  {"type":"paragraph","text":"➡️ Étape suivante : Publier."},

  {"type":"heading2","text":"7. Publier + monitorer 48h"},
  {"type":"paragraph","text":"🎯 Objectif : Lancer puis observer. ⏱️ Temps : 5 min + monitoring."},
  {"type":"numbered","items":[
    "Cliquer « Publier ».",
    "Attendre validation Meta (1-12h en moyenne).",
    "Vérifier 2x/jour : impressions par placement.",
    "Si un placement ne reçoit pas d'impressions → vérifier la créa.",
    "Après 7j : analyser placement par placement, garder les 2 meilleurs."
  ]},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Reels reçoit 80% des impressions et 20% des conversions → normal en visuel, garder pour la notoriété."},

  {"type":"divider"},

  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Comptes FB + Insta liés et soignés",
    "3 formats de créas préparés (carré + vertical + vidéo)",
    "Campagne CBO avec budget approprié",
    "Placements manuels = 6 sélectionnés (sans AN)",
    "Créas adaptées par placement",
    "CTA + UTM + WhatsApp testés",
    "Monitoring 48h programmé"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si bloqué plus de 30 min → WhatsApp +212 620 002 066."}
]$sop$::jsonb,
    read_min = 18,
    updated_at = now()
WHERE slug = 'ng-mb-facebook-instagram-ads';

-- ════════════════════════════════════════════════════════════════════
-- 5/10 — ng-mb-tiktok-ads
-- ════════════════════════════════════════════════════════════════════
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"À qui s'adresse cette SOP","text":"Media Buyer Next Gital qui lance une campagne TikTok Ads pour un client jeune (18-35 ans) : restaurants tendance, mode, beauté, salles de sport."},
  {"type":"callout","variant":"warning","title":"Prérequis OBLIGATOIRES","text":"1) Compte TikTok Business client. 2) TikTok Ads Manager créé. 3) Pixel TikTok installé + Events API. 4) 1 vidéo UGC verticale 9:16 (15-30s) avec hook 3 premières secondes. 5) Budget min 100 MAD/jour."},
  {"type":"callout","variant":"tip","title":"Règle TikTok","text":"Le contenu doit ressembler à un TikTok organique, PAS à une pub. Style natif, vertical, son tendance, sous-titres animés."},
  {"type":"callout","variant":"danger","title":"À ne JAMAIS faire","text":"Ne PAS importer une vidéo Facebook (mauvais format/style). Ne PAS oublier le Spark Ad (booster un vrai post). Ne PAS dépenser sans avoir testé 3 hooks différents."},

  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. Créer / vérifier le compte TikTok Ads"},
  {"type":"paragraph","text":"🎯 Objectif : Compte Ads Manager actif lié au compte Business. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"🖥️ OÙ : ads.tiktok.com."},
  {"type":"numbered","items":[
    "Aller sur ads.tiktok.com → S'inscrire avec l'email racine du client.",
    "Pays = Maroc, fuseau Casablanca, devise MAD.",
    "Informations entreprise : nom légal, adresse, ICE.",
    "Mode de facturation = Manuel (recommandé) OU Auto.",
    "Ajouter une carte bancaire client.",
    "Vérifier l'identité via documents."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le compte est en statut « Approuvé » avec moyens de paiement vérifiés."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Compte refusé → fournir ICE + RC + carte ID. Délai 24-48h."},
  {"type":"paragraph","text":"➡️ Étape suivante : Installer le Pixel TikTok."},

  {"type":"heading2","text":"2. Installer le Pixel TikTok + Events API"},
  {"type":"paragraph","text":"🎯 Objectif : Tracker les conversions. ⏱️ Temps : 20 min."},
  {"type":"paragraph","text":"🖥️ OÙ : TikTok Ads Manager → Outils → Événements."},
  {"type":"numbered","items":[
    "Ads Manager → Outils → Événements → Source Web → Créer.",
    "Nom = « Pixel {Client} ».",
    "Méthode d'installation = via partenaire (Shopify/GTM) OU code manuel.",
    "Mode = Standard (recommandé).",
    "Copier le code Pixel dans le <head> du site.",
    "Configurer les événements : ViewContent, AddToCart, InitiateCheckout, CompletePayment, Contact.",
    "Activer Events API pour iOS (data côté serveur).",
    "Tester avec l'extension Chrome « TikTok Pixel Helper »."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Pixel Helper vert + événements reçus dans Events Manager dans les 10 min."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Pixel pas détecté → vérifier que le site n'a pas un cookie banner qui bloque le script."},
  {"type":"paragraph","text":"➡️ Étape suivante : Préparer la créa UGC."},

  {"type":"heading2","text":"3. Préparer la créa vidéo UGC (style natif)"},
  {"type":"paragraph","text":"🎯 Objectif : Vidéo qui ressemble à un TikTok organique. ⏱️ Temps : 1-2h (avec créateur ou client)."},
  {"type":"paragraph","text":"🖥️ OÙ : tournage smartphone + édition CapCut."},
  {"type":"numbered","items":[
    "Format vertical 9:16 (1080x1920).",
    "Durée 15-30s (sweet spot).",
    "Hook 3 premières secondes (question, choc, transformation).",
    "Sous-titres animés (CapCut → Légende auto).",
    "Son tendance TikTok (utiliser un son populaire libre de droits).",
    "CTA verbal : « Lien en bio » ou « Tape sur le bouton ».",
    "Pas de logo géant ni de cadre publicitaire.",
    "Format final : MP4, H.264, < 500 Mo."
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT (hooks Oujda) :"},
  {"type":"list","items":[
    "**Salon Atlas Beauté** → « Je teste le soin signature à Oujda pour 99 MAD » → résultat avant/après",
    "**Restaurant** → « 3 plats à goûter ABSOLUMENT à Oujda avant l'été » → top 3 visuel",
    "**Hammam Royal** → « POV : tu vis l'expérience hammam royal à Oujda » → ambiance"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"La vidéo passe le test « lookalike organique » : indistinguable d'un vrai TikTok."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Vidéo trop pub → pas de performance. Refaire avec un créateur UGC local."},
  {"type":"paragraph","text":"➡️ Étape suivante : Créer la campagne."},

  {"type":"heading2","text":"4. Créer la campagne TikTok"},
  {"type":"paragraph","text":"🎯 Objectif : Squelette campagne. ⏱️ Temps : 8 min."},
  {"type":"paragraph","text":"🖥️ OÙ : ads.tiktok.com → Campagnes → + Créer."},
  {"type":"numbered","items":[
    "Objectif = Conversions (ou Trafic ou Reach selon brief).",
    "Mode = Personnalisé (PAS Simplifié).",
    "Nom = « {Client} | {Objectif} | {Mois}-{Année} ».",
    "Budget de campagne = ON (CBO), quotidien, min 100 MAD/jour."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Campagne en brouillon, budget correct."},
  {"type":"paragraph","text":"➡️ Étape suivante : Ad Group."},

  {"type":"heading2","text":"5. Configurer l'Ad Group (audience + placements)"},
  {"type":"paragraph","text":"🎯 Objectif : Cibler la bonne audience. ⏱️ Temps : 10 min."},
  {"type":"numbered","items":[
    "Placement = Automatique (recommandé) OU TikTok uniquement.",
    "Promotion = Site Web → URL avec UTM.",
    "Optimisation = Conversion (événement choisi : Contact/Purchase).",
    "Audience : Maroc → Oujda + 25 km.",
    "Âge : 18-34.",
    "Sexe : selon secteur.",
    "Langues : Arabe + Français.",
    "Intérêts : sélectionner 3-5 catégories (Beauté, Fashion, Food).",
    "Comportements : Engagement vidéo > 75%.",
    "Budget Ad Group = hérité de la campagne (CBO)."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Audience estimée entre 100k et 1M."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Audience trop étroite à Oujda → étendre à Berkane, Nador, Taourirt."},
  {"type":"paragraph","text":"➡️ Étape suivante : Créer 3 ads."},

  {"type":"heading2","text":"6. Créer 3 ads (avec test de hooks)"},
  {"type":"paragraph","text":"🎯 Objectif : Tester 3 hooks différents. ⏱️ Temps : 15 min."},
  {"type":"numbered","items":[
    "Format = Vidéo unique (PAS Carrousel pour TikTok).",
    "Identité = Compte TikTok Business client.",
    "Spark Ad = ON si la vidéo est déjà publiée organiquement (recommandé).",
    "Si Spark Ad : coller le code TikTok du post.",
    "Sinon : uploader la vidéo MP4.",
    "Texte = 100 caractères max, 1 emoji max.",
    "CTA = « En savoir plus » / « Commander maintenant » / « Réserver ».",
    "Tracking = Pixel + Events API.",
    "Refaire pour 2 autres variantes (hook différent)."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"3 ads en statut « En cours de revue », aperçu mobile OK."},
  {"type":"paragraph","text":"➡️ Étape suivante : Publier et monitorer."},

  {"type":"heading2","text":"7. Publier et monitorer"},
  {"type":"paragraph","text":"🎯 Objectif : Apprentissage TikTok. ⏱️ Temps : passive 3-5j."},
  {"type":"numbered","items":[
    "Publier la campagne.",
    "TikTok prend 24-48h pour valider la vidéo.",
    "Phase d'apprentissage = 50 conversions/ad group/7j.",
    "Ne pas toucher avant 3 jours.",
    "Suivre KPIs : CPM, CTR, CVR, CPL/CPA.",
    "Couper les vidéos avec CTR < 0.8% après 5000 impressions.",
    "Doubler le budget si CPL < cible."
  ]},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Vidéo refusée pour « contenu inapproprié » → vérifier musique libre de droits + pas de propos santé."},

  {"type":"divider"},

  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Compte TikTok Ads approuvé + paiement OK",
    "Pixel + Events API installés (Pixel Helper vert)",
    "Vidéo UGC native 9:16 avec hook 3s",
    "Campagne CBO avec budget min 100 MAD/j",
    "Audience Oujda + intérêts précis",
    "3 ads avec hooks différents (Spark Ad si possible)",
    "Monitoring 3-5j sans toucher"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si bloqué plus de 30 min (compte refusé, vidéo bloquée, Pixel HS) → WhatsApp +212 620 002 066."}
]$sop$::jsonb,
    read_min = 18,
    updated_at = now()
WHERE slug = 'ng-mb-tiktok-ads';

-- ════════════════════════════════════════════════════════════════════
-- 6/10 — ng-mb-google-ads
-- ════════════════════════════════════════════════════════════════════
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"À qui s'adresse cette SOP","text":"Media Buyer Next Gital qui lance une campagne Google Ads Search (mots-clés) pour un client avec intention forte (avocat, dentiste, plombier, garage, pharmacie)."},
  {"type":"callout","variant":"warning","title":"Prérequis OBLIGATOIRES","text":"1) Compte Google Ads créé sur email client. 2) Compte MCC Next Gital lié au compte client. 3) Conversions Google Ads configurées (tag + GA4). 4) Landing page mobile rapide (< 3s). 5) Brief avec mots-clés validés."},
  {"type":"callout","variant":"tip","title":"Structure Next Gital","text":"1 Compte → 1 Campagne par thématique → 2-3 Ad Groups par campagne (1 par intention) → 15-20 mots-clés par Ad Group (3 types de correspondance)."},
  {"type":"callout","variant":"danger","title":"À ne JAMAIS faire","text":"Ne PAS utiliser « Smart Campaign » (boîte noire). Ne PAS mettre TOUS les mots-clés en correspondance large (gaspillage). Ne PAS oublier les mots-clés négatifs."},

  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. Configurer le compte Google Ads + lier MCC"},
  {"type":"paragraph","text":"🎯 Objectif : Compte actif lié à Next Gital. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"🖥️ OÙ : ads.google.com."},
  {"type":"numbered","items":[
    "Aller sur ads.google.com → Démarrer maintenant.",
    "Choisir le mode Expert (PAS Simplifié).",
    "Sauter la création de campagne (lien en bas).",
    "Renseigner pays : Maroc, fuseau Casablanca, devise MAD.",
    "Lier le compte au MCC Next Gital : Outils → Configuration → Préférences → Accès au compte → Inviter Manager nextgital@google.com.",
    "Accepter l'invitation côté MCC.",
    "Ajouter une carte bancaire client + facturation manuelle ou auto."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le compte client apparaît dans le MCC Next Gital."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Email pris par un autre compte → demander au client un alias dédié."},
  {"type":"paragraph","text":"➡️ Étape suivante : Configurer les conversions."},

  {"type":"heading2","text":"2. Configurer le tracking des conversions"},
  {"type":"paragraph","text":"🎯 Objectif : Tracker chaque action de valeur. ⏱️ Temps : 25 min."},
  {"type":"paragraph","text":"🖥️ OÙ : Google Ads → Objectifs → Conversions."},
  {"type":"numbered","items":[
    "Objectifs → Conversions → + Nouvelle action.",
    "Choisir : Site Web → Saisir URL → Continuer.",
    "Créer les conversions : Soumission formulaire (Lead), Clic WhatsApp, Appel, Achat.",
    "Méthode : Google Tag (recommandé) OU GTM.",
    "Installer le Google Tag dans le <head>.",
    "Ajouter le snippet d'événement sur la page de remerciement (Lead).",
    "Vérifier avec l'extension Chrome « Google Tag Assistant »."
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":[
    "**Cabinet dentaire** → Conversion principale = Lead (formulaire RDV)",
    "**Garage** → Conversion = Appel téléphonique",
    "**E-commerce** → Conversion = Achat avec valeur dynamique"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tag Assistant vert + 1 conversion test enregistrée dans les 24h."},
  {"type":"paragraph","text":"➡️ Étape suivante : Recherche mots-clés."},

  {"type":"heading2","text":"3. Faire la recherche de mots-clés"},
  {"type":"paragraph","text":"🎯 Objectif : Liste de 30-50 mots-clés rentables. ⏱️ Temps : 1h."},
  {"type":"paragraph","text":"🖥️ OÙ : Google Keyword Planner (ads.google.com → Outils → Planificateur)."},
  {"type":"numbered","items":[
    "Planificateur de mots-clés → Découvrir de nouveaux mots-clés.",
    "Saisir 3-5 mots seed (ex : « dentiste oujda », « implant dentaire »).",
    "Filtrer par lieu : Oujda + 25 km.",
    "Langue : Arabe + Français.",
    "Filtrer : Volume > 10, CPC < 10 MAD, Concurrence Faible/Moyenne.",
    "Exporter en CSV.",
    "Trier en 3 buckets : Très intention (« meilleur dentiste oujda »), Intention (« dentiste oujda »), Info (« mal de dent »).",
    "Garder Très intention + Intention pour Search, Info pour Display/Remarketing."
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT (exemples) :"},
  {"type":"list","items":[
    "**Très intention** → [dentiste oujda rdv] (exact) → [implant dentaire prix oujda]",
    "**Intention** → \"dentiste oujda\" (phrase) → \"cabinet dentaire oujda\"",
    "**Négatifs** → gratuit, formation, école, emploi, salaire"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu as une liste catégorisée stockée dans GestiQ."},
  {"type":"paragraph","text":"➡️ Étape suivante : Créer la campagne."},

  {"type":"heading2","text":"4. Créer la campagne Search"},
  {"type":"paragraph","text":"🎯 Objectif : Squelette campagne. ⏱️ Temps : 10 min."},
  {"type":"numbered","items":[
    "Campagnes → + Nouvelle campagne → Choisir un objectif (Leads / Ventes).",
    "Type = Search.",
    "Action de conversion = Lead.",
    "Nom = « {Client} | Search | {Thème} | {Mois}-{Année} ».",
    "Réseaux : décocher Display Network et Search Partners au début.",
    "Lieu : Oujda + rayon 25 km, présence (PAS intérêt).",
    "Langues : Arabe + Français.",
    "Audiences : ajouter en mode Observation (pas Ciblage).",
    "Budget = 80-200 MAD/jour.",
    "Enchères : Maximiser les conversions (avec CPA cible si historique)."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Campagne en brouillon."},
  {"type":"paragraph","text":"➡️ Étape suivante : Créer les Ad Groups."},

  {"type":"heading2","text":"5. Créer les Ad Groups (1 par intention)"},
  {"type":"paragraph","text":"🎯 Objectif : Grouper les mots-clés par thème serré. ⏱️ Temps : 20 min."},
  {"type":"numbered","items":[
    "1 Ad Group par intention (ex : « Implant dentaire », « Détartrage », « Urgence dentaire »).",
    "Nom Ad Group = thème exact.",
    "Mots-clés par Ad Group : 5-10 max, 3 types : exact [ ], phrase \" \", large modifié.",
    "Enchère par mot-clé = laisser auto.",
    "Audiences = ajouter en Observation : visiteurs site 30j, In-Market « Soins dentaires »."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Chaque Ad Group a un thème clair et 5-10 mots-clés cohérents."},
  {"type":"paragraph","text":"➡️ Étape suivante : Créer les annonces."},

  {"type":"heading2","text":"6. Créer 3 annonces RSA par Ad Group"},
  {"type":"paragraph","text":"🎯 Objectif : Annonces qualitatives. ⏱️ Temps : 25 min."},
  {"type":"numbered","items":[
    "Type d'annonce = Responsive Search Ad (RSA) — seul format dispo.",
    "URL finale = landing page avec UTM (?utm_source=google&utm_medium=cpc&utm_campaign={NomCamp}).",
    "URL d'affichage : domaine.ma/oujda/dentiste.",
    "Titres : 12-15 titres uniques de 30 caractères (mots-clés + bénéfices + ville + CTA + chiffres).",
    "Descriptions : 4 descriptions de 90 caractères.",
    "Épingler le titre 1 = mot-clé principal, le titre 2 = bénéfice.",
    "Indicateur de qualité = viser « Excellent »."
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT (cabinet dentaire) :"},
  {"type":"list","items":[
    "**Titre 1 (épinglé)** → « Dentiste à Oujda »",
    "**Titre 2 (épinglé)** → « RDV en 24h »",
    "**Titre 3-15** → « Diagnostic Offert », « Paiement 3x », « Urgence Acceptée », « Cabinet Moderne », etc.",
    "**Description 1** → « Soins, implants, urgences à Oujda. RDV en ligne en 2 min. Diagnostic offert.»"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Indicateur qualité Excellent, aperçu mobile OK."},
  {"type":"paragraph","text":"➡️ Étape suivante : Ajouter les extensions."},

  {"type":"heading2","text":"7. Ajouter toutes les extensions (Assets)"},
  {"type":"paragraph","text":"🎯 Objectif : +20% CTR avec extensions. ⏱️ Temps : 15 min."},
  {"type":"numbered","items":[
    "Liens annexes : 4 minimum (RDV, Tarifs, Équipe, Avis).",
    "Accroches : 4 minimum (Cabinet Moderne, Paiement 3x, Diagnostic Offert, Ouvert le samedi).",
    "Extraits de site : Services (Implant, Détartrage, Blanchiment).",
    "Appel : numéro pro + fuseau horaire.",
    "Lieu : lier Google My Business (essentiel).",
    "Formulaire : capture lead direct sur l'annonce.",
    "Image : 3-5 images 1200x1200."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Toutes les extensions activées et liées au lieu."},
  {"type":"paragraph","text":"➡️ Étape suivante : Mots-clés négatifs."},

  {"type":"heading2","text":"8. Ajouter les mots-clés négatifs"},
  {"type":"paragraph","text":"🎯 Objectif : Éviter le gaspillage. ⏱️ Temps : 10 min."},
  {"type":"numbered","items":[
    "Au niveau Campagne → Mots-clés → Négatifs.",
    "Liste de base : gratuit, école, formation, étudiant, emploi, salaire, jeu, free, pdf, wikipédia.",
    "Spécifique au secteur (dentiste) : recette, remede maison, douleur, fait maison.",
    "Créer une liste partagée « NG — Négatifs communs » à appliquer à tous les comptes."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Liste de négatifs >20 mots ajoutée."},

  {"type":"divider"},

  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Compte lié au MCC Next Gital",
    "Conversions configurées + tag vérifié",
    "Recherche mots-clés faite et catégorisée",
    "Campagne Search en MAD, lieu Oujda",
    "Ad Groups thématiques (5-10 mots-clés)",
    "3 RSA par Ad Group avec qualité Excellent",
    "Toutes les extensions activées",
    "Liste de mots-clés négatifs ajoutée"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si bloqué plus de 30 min (compte suspendu, conversions non trackées, qualité Faible) → WhatsApp +212 620 002 066."}
]$sop$::jsonb,
    read_min = 22,
    updated_at = now()
WHERE slug = 'ng-mb-google-ads';

-- ════════════════════════════════════════════════════════════════════
-- 7/10 — ng-mb-google-ads-maps (Performance Max + lieu)
-- ════════════════════════════════════════════════════════════════════
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"À qui s'adresse cette SOP","text":"Media Buyer qui lance une campagne Google Ads pour drainer du trafic physique vers une boutique/cabinet à Oujda (restaurant, pharmacie, garage, salon). Combine Search + extension de lieu + Performance Max."},
  {"type":"callout","variant":"warning","title":"Prérequis OBLIGATOIRES","text":"1) Fiche Google My Business 100% complétée + vérifiée (SOP ng-mb-google-my-business). 2) Compte Google Ads lié à la fiche GMB. 3) Conversions « Itinéraire » et « Appel » configurées. 4) Photos GMB récentes."},
  {"type":"callout","variant":"tip","title":"Format optimal","text":"Combiner 2 campagnes : Search avec extension de lieu + Performance Max avec objectif Visites en magasin. Couvre toutes les surfaces (Search, Maps, YouTube, Display, Gmail)."},
  {"type":"callout","variant":"danger","title":"À ne JAMAIS faire","text":"Ne PAS lancer si la fiche GMB n'est pas vérifiée (visites non trackables). Ne PAS oublier d'activer « Visites en magasin » comme conversion."},

  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. Vérifier la fiche Google My Business"},
  {"type":"paragraph","text":"🎯 Objectif : Fiche prête à recevoir du trafic Ads. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"🖥️ OÙ : business.google.com."},
  {"type":"numbered","items":[
    "Connexion business.google.com avec l'email racine du client.",
    "Vérifier statut : Vérifiée (point vert).",
    "Renseigner : nom exact, adresse Bureau, téléphone, horaires précis (7j/7), site, catégorie principale + secondaires.",
    "Photos : couverture, logo, intérieur, extérieur, équipe, produits (min 10 photos).",
    "Avis : minimum 10 avis 4+ étoiles avant lancement Ads.",
    "Posts hebdomadaires actifs."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Fiche complète à 100% (indicateur en haut)."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Fiche non vérifiée → suivre la SOP ng-mb-google-my-business (carte postale, appel, vidéo)."},
  {"type":"paragraph","text":"➡️ Étape suivante : Lier GMB à Google Ads."},

  {"type":"heading2","text":"2. Lier GMB à Google Ads"},
  {"type":"paragraph","text":"🎯 Objectif : Activer l'extension de lieu et le suivi des visites. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"🖥️ OÙ : Google Ads → Outils → Configuration → Comptes liés."},
  {"type":"numbered","items":[
    "Outils → Configuration → Comptes liés → Profil d'entreprise.",
    "Cliquer Détails → + Lier.",
    "Sélectionner le compte GMB du client → Envoyer.",
    "Accepter dans GMB.",
    "Vérifier que la fiche apparaît dans Assets → Lieu."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Le lieu Oujda apparaît dans Assets → Lieu."},
  {"type":"paragraph","text":"➡️ Étape suivante : Configurer conversion « Visites en magasin »."},

  {"type":"heading2","text":"3. Configurer les conversions de proximité"},
  {"type":"paragraph","text":"🎯 Objectif : Tracker appels + itinéraires + visites. ⏱️ Temps : 15 min."},
  {"type":"numbered","items":[
    "Objectifs → Conversions → + Nouvelle action.",
    "Créer : Appel depuis annonce.",
    "Créer : Demande d'itinéraire.",
    "Créer : Clic sur numéro depuis site (téléphone web).",
    "Si fiche multi-magasins : activer Visites en magasin (Google active automatiquement si seuil atteint)."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"3-4 conversions de proximité actives."},
  {"type":"paragraph","text":"➡️ Étape suivante : Créer la campagne Search + extension lieu."},

  {"type":"heading2","text":"4. Créer la campagne Search avec extension de lieu"},
  {"type":"paragraph","text":"🎯 Objectif : Capter les recherches « {service} oujda ». ⏱️ Temps : 30 min."},
  {"type":"numbered","items":[
    "Nouvelle campagne → Objectif : Visites en magasin (si dispo) ou Leads.",
    "Type = Search.",
    "Nom = « {Client} | Search Local | {Mois}-{Année} ».",
    "Lieu : Oujda + 15 km, présence.",
    "Mots-clés avec géo : [restaurant marocain oujda], [pharmacie 24/7 oujda], [garage auto oujda].",
    "Assets : Lieu (lié à GMB), Appel, Liens annexes (Menu, Horaires, Itinéraire).",
    "Enchères : Maximiser les conversions.",
    "Budget : 80-150 MAD/jour."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Aperçu mobile : extension de lieu apparaît sous l'annonce avec carte."},
  {"type":"paragraph","text":"➡️ Étape suivante : Créer la campagne Performance Max."},

  {"type":"heading2","text":"5. Créer la campagne Performance Max (PMax)"},
  {"type":"paragraph","text":"🎯 Objectif : Multi-surface auto. ⏱️ Temps : 25 min."},
  {"type":"numbered","items":[
    "Nouvelle campagne → Objectif : Ventes ou Leads ou Visites en magasin.",
    "Type = Performance Max.",
    "Nom = « {Client} | PMax Local | {Mois}-{Année} ».",
    "Budget : 100 MAD/jour min.",
    "Enchères : Maximiser conversions + CPA cible si historique.",
    "Lieu : Oujda + 25 km.",
    "Asset Group : ajouter 5+ images (1200x1200 + 1200x628 + 1200x1500), 1-2 vidéos < 30s, 5 titres courts (30c), 5 titres longs (90c), 5 descriptions (90c).",
    "Signaux d'audience : ajouter audience similaire visiteurs site + intérêts secteur."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Score d'efficacité de l'Asset Group = Excellent."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"PMax cannibalise le Search → toujours surveiller les rapports Insights de PMax pour identifier les termes."},
  {"type":"paragraph","text":"➡️ Étape suivante : Exclusions PMax."},

  {"type":"heading2","text":"6. Configurer les exclusions PMax"},
  {"type":"paragraph","text":"🎯 Objectif : Éviter la cannibalisation et le gaspillage. ⏱️ Temps : 10 min."},
  {"type":"numbered","items":[
    "Demander à Google Support : exclure les termes de marque (capture par Search exact).",
    "Exclure les placements YouTube/Display sensibles via la liste partagée du compte.",
    "Ajouter les négatifs au niveau compte (gratuit, école, etc.)."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Liste de négatifs au niveau compte + exclusions PMax demandées."},
  {"type":"paragraph","text":"➡️ Étape suivante : Lancer + monitorer."},

  {"type":"heading2","text":"7. Lancer + monitorer"},
  {"type":"paragraph","text":"🎯 Objectif : Démarrage. ⏱️ Temps : 5 min + suivi."},
  {"type":"numbered","items":[
    "Activer les 2 campagnes.",
    "Vérifier après 24h : impressions, clics, appels, itinéraires.",
    "Surveiller le rapport « Insights » de PMax (termes de recherche).",
    "Après 14j : optimiser les assets faibles (note Faible)."
  ]},

  {"type":"divider"},

  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Fiche GMB vérifiée et complète à 100%",
    "GMB lié à Google Ads (asset Lieu)",
    "Conversions appel + itinéraire actives",
    "Campagne Search avec extension de lieu",
    "Campagne PMax avec Asset Group complet",
    "Exclusions et négatifs configurés",
    "Monitoring 14j programmé"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si bloqué plus de 30 min → WhatsApp +212 620 002 066."}
]$sop$::jsonb,
    read_min = 18,
    updated_at = now()
WHERE slug = 'ng-mb-google-ads-maps';

-- ════════════════════════════════════════════════════════════════════
-- 8/10 — ng-mb-google-my-business
-- ════════════════════════════════════════════════════════════════════
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"À qui s'adresse cette SOP","text":"Media Buyer Next Gital qui crée ou optimise une fiche Google My Business (Profile Business) pour un client local à Oujda."},
  {"type":"callout","variant":"warning","title":"Prérequis OBLIGATOIRES","text":"1) Email pro du client. 2) Adresse exacte (avec photo de la devanture). 3) Numéro de téléphone qui répond. 4) Horaires précis 7j/7. 5) Logo + 10 photos minimum (devanture, intérieur, équipe, produits)."},
  {"type":"callout","variant":"tip","title":"Pourquoi c'est critique","text":"Une fiche GMB optimisée = 30 à 50% des appels d'un commerce local. Indispensable AVANT toute campagne Ads locale."},
  {"type":"callout","variant":"danger","title":"À ne JAMAIS faire","text":"Ne PAS créer une fausse fiche (sera supprimée). Ne PAS mettre des mots-clés dans le nom (« Pharmacie Oujda 24/7 » → interdit). Ne PAS oublier la vérification (carte postale, appel, vidéo)."},

  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. Vérifier l'existence d'une fiche"},
  {"type":"paragraph","text":"🎯 Objectif : Éviter les doublons. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"🖥️ OÙ : maps.google.com + business.google.com."},
  {"type":"numbered","items":[
    "Rechercher le nom + ville sur Google Maps.",
    "Si fiche existe → cliquer « Vous gérez cette entreprise » → revendiquer.",
    "Si pas de fiche → passer à l'étape 2 (créer)."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu sais si tu crées ou tu revendiques."},
  {"type":"paragraph","text":"➡️ Étape suivante : Créer ou revendiquer."},

  {"type":"heading2","text":"2. Créer / revendiquer la fiche"},
  {"type":"paragraph","text":"🎯 Objectif : Ajouter la fiche au compte client. ⏱️ Temps : 15 min."},
  {"type":"paragraph","text":"🖥️ OÙ : business.google.com → Ajouter votre établissement."},
  {"type":"numbered","items":[
    "Connexion avec email pro client.",
    "Ajouter une entreprise → saisir le nom commercial EXACT.",
    "Choisir Catégorie principale la plus précise (ex : Cabinet dentaire, Restaurant marocain).",
    "Ajouter l'adresse exacte (avec numéro de Bureau si applicable).",
    "Choisir si livraison/zone de service.",
    "Ajouter téléphone (qui répond) + site web."
  ]},
  {"type":"paragraph","text":"✏️ CONTENU EXACT :"},
  {"type":"list","items":[
    "**Nom** → exactement comme l'enseigne → ex : « Restaurant Al Baraka » → PAS « Restaurant Al Baraka Oujda meilleur tagine »",
    "**Catégorie principale** → la plus précise → ex : « Cabinet dentaire »",
    "**Catégories secondaires** → jusqu'à 9 → ex : « Implantologue », « Orthodontiste »"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Fiche créée en statut « En attente de vérification »."},
  {"type":"paragraph","text":"➡️ Étape suivante : Vérification."},

  {"type":"heading2","text":"3. Faire la vérification"},
  {"type":"paragraph","text":"🎯 Objectif : Activer la fiche. ⏱️ Temps : 5 min + 5-14 jours d'attente si carte postale."},
  {"type":"numbered","items":[
    "Choisir la méthode : Vidéo (recommandé), Téléphone, Email, Carte postale.",
    "VIDÉO : enregistrer 30s montrant l'enseigne + intérieur + preuve de gestion (ex : ordinateur connecté au compte Google).",
    "Soumettre.",
    "Délai validation : 24h-7j."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Badge « Vérifié » apparaît sur la fiche."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Vidéo refusée → refaire avec : enseigne visible + numéro de rue + intérieur clairement reconnaissable."},
  {"type":"paragraph","text":"➡️ Étape suivante : Compléter à 100%."},

  {"type":"heading2","text":"4. Compléter la fiche à 100%"},
  {"type":"paragraph","text":"🎯 Objectif : Maximum d'informations. ⏱️ Temps : 30 min."},
  {"type":"numbered","items":[
    "Description (750 caractères) : décrire activité + USP + ville + mots-clés naturels.",
    "Horaires : 7j/7 précis. Ajouter les horaires spéciaux (ramadan, fêtes).",
    "Services / Menu : lister chaque service avec prix indicatif.",
    "Attributs : Wifi, parking, accessible, paiement carte, etc.",
    "Date d'ouverture.",
    "Lien réservation (RDV) si applicable."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"L'indicateur « Compléter votre fiche » est à 100%."},
  {"type":"paragraph","text":"➡️ Étape suivante : Photos."},

  {"type":"heading2","text":"5. Ajouter 15+ photos qualitatives"},
  {"type":"paragraph","text":"🎯 Objectif : Donner envie + crédibilité. ⏱️ Temps : 20 min."},
  {"type":"numbered","items":[
    "Logo : carré 250x250 PNG.",
    "Couverture : 1080x608 (devanture).",
    "Photos intérieur : 5+ horizontales 4:3.",
    "Photos équipe : 3+ avec autorisation.",
    "Photos produits / services : 5+.",
    "Vidéo courte 30s (interview client ou tour du local).",
    "Renommer chaque fichier avec mot-clé (ex : restaurant-tagine-oujda.jpg)."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"15+ photos publiées, géolocalisées si possible."},
  {"type":"paragraph","text":"➡️ Étape suivante : Avis."},

  {"type":"heading2","text":"6. Activer la stratégie avis"},
  {"type":"paragraph","text":"🎯 Objectif : Obtenir 10 premiers avis 5★. ⏱️ Temps : 15 min setup."},
  {"type":"numbered","items":[
    "Récupérer le lien d'avis : business.google.com → Lecteur QR / Lien d'avis.",
    "Créer un QR code (canva.com → QR generator) imprimé sur le comptoir.",
    "Préparer un message WhatsApp type : « Merci pour votre visite 🙏 Pourriez-vous nous laisser un avis ? : {lien} ».",
    "Envoyer aux 20 derniers clients satisfaits.",
    "Configurer une réponse type pour chaque avis (5★, 4★, 1-2★).",
    "Répondre à TOUS les avis en moins de 24h."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"10 avis 4-5★ dans le premier mois, toutes les réponses faites."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Avis 1★ injustifié → JAMAIS supprimer, répondre poliment et signaler à Google si calomnieux."},
  {"type":"paragraph","text":"➡️ Étape suivante : Posts hebdo."},

  {"type":"heading2","text":"7. Publier des posts hebdomadaires"},
  {"type":"paragraph","text":"🎯 Objectif : Garder la fiche active. ⏱️ Temps : 15 min/semaine."},
  {"type":"numbered","items":[
    "1 post par semaine minimum (Nouveauté, Offre, Événement).",
    "Format : image 1200x900 + texte 150 caractères + CTA + lien.",
    "Programmer dans GestiQ → Calendrier Social.",
    "Tracker dans Insights GMB : vues, clics, appels, itinéraires."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"4 posts publiés sur le mois."},

  {"type":"divider"},

  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Fiche vérifiée (badge vert)",
    "Profil complété à 100%",
    "15+ photos qualitatives",
    "10+ avis 4-5★ avec réponses",
    "Stratégie d'avis active (QR + lien WhatsApp)",
    "Posts hebdo programmés dans GestiQ",
    "Liaison à Google Ads si client en Ads"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si vérification refusée 2x, ou fiche suspendue → WhatsApp +212 620 002 066."}
]$sop$::jsonb,
    read_min = 16,
    updated_at = now()
WHERE slug = 'ng-mb-google-my-business';

-- ════════════════════════════════════════════════════════════════════
-- 9/10 — ng-mb-prompts-ia
-- ════════════════════════════════════════════════════════════════════
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"À qui s'adresse cette SOP","text":"Media Buyer Next Gital qui utilise l'IA (ChatGPT, Claude, Gemini) pour accélérer la création de copies, audiences, plans de campagne, idées de hooks."},
  {"type":"callout","variant":"warning","title":"Prérequis OBLIGATOIRES","text":"1) Accès ChatGPT Plus ou Claude Pro (compte Next Gital). 2) Brief client validé. 3) Connaissance des persona client. 4) Templates de prompts Next Gital stockés dans GestiQ → Bibliothèque IA."},
  {"type":"callout","variant":"tip","title":"Règle d'or","text":"L'IA = un junior brillant à briefer. Plus le prompt est précis (contexte + rôle + format + ton + exemple + contraintes), meilleur le résultat."},
  {"type":"callout","variant":"danger","title":"À ne JAMAIS faire","text":"Ne JAMAIS publier une copie IA brute. TOUJOURS relire, ajouter de la personnalité locale, vérifier les chiffres et noms. NE PAS partager les infos confidentielles du client à l'IA gratuite (utiliser version payante avec opt-out training)."},

  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. Préparer le brief structuré"},
  {"type":"paragraph","text":"🎯 Objectif : Donner à l'IA tout le contexte en une fois. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"🖥️ OÙ : document Notion / GestiQ → Brief IA."},
  {"type":"numbered","items":[
    "Renseigner : Client (secteur, ville), Produit, USP (3 différences), Cible (persona : âge, sexe, freins, désirs), Objectif campagne, Plateforme (Meta/TikTok/Google), Ton (sérieux/fun/luxe), Contraintes (mots interdits, longueur)."
  ]},
  {"type":"paragraph","text":"✏️ TEMPLATE :"},
  {"type":"template","text":"CLIENT : Cabinet Fedix — Avocat à Oujda\nUSP : 1) 15 ans d'expérience droit familial, 2) Premier RDV gratuit, 3) Paiement échelonné\nCIBLE : Femmes 30-55, Oujda + 30km, freins : peur du coût, méconnaissance droits\nOBJECTIF : 25 prises de RDV / mois\nPLATEFORME : Meta Ads (Facebook + Instagram)\nTON : Rassurant, expert, accessible\nCONTRAINTES : Pas de chiffres précis sur taux de réussite, max 90 caractères pour le texte principal"},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Brief lisible en 30 secondes par un humain."},
  {"type":"paragraph","text":"➡️ Étape suivante : Choisir le bon modèle."},

  {"type":"heading2","text":"2. Choisir le bon modèle IA"},
  {"type":"paragraph","text":"🎯 Objectif : Modèle adapté à la tâche. ⏱️ Temps : instantané."},
  {"type":"paragraph","text":"🖥️ OÙ : chat.openai.com, claude.ai, gemini.google.com."},
  {"type":"list","items":[
    "**Claude (Sonnet/Opus)** → meilleur pour copy publicitaire long, ton nuancé, rédaction française",
    "**ChatGPT (4o / o1)** → meilleur pour analyse de data, audiences, recherche mots-clés",
    "**Gemini** → meilleur pour intégration Google Ads, recherche temps réel"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Modèle aligné avec la tâche."},
  {"type":"paragraph","text":"➡️ Étape suivante : Lancer un prompt structuré."},

  {"type":"heading2","text":"3. Prompt structuré pour générer 10 hooks d'ads"},
  {"type":"paragraph","text":"🎯 Objectif : Obtenir 10 accroches publicitaires. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"✏️ PROMPT EXACT À COPIER :"},
  {"type":"template","text":"Tu es copywriter senior spécialisé en publicité Meta Ads pour PME marocaines.\n\nCONTEXTE :\n[colle ici ton brief de l'étape 1]\n\nMISSION :\nGénère 10 hooks publicitaires différents pour Facebook Ads.\n\nCONTRAINTES :\n- Chaque hook = 1 phrase, max 90 caractères\n- Tonalité : rassurant, expert, accessible\n- Inclure 1 émoji pertinent au début\n- Adapter au marché marocain (mentionner Oujda quand pertinent)\n- Varier les angles : peur, désir, curiosité, urgence, preuve, social, autorité, bénéfice, contraste, question\n\nFORMAT DE RÉPONSE :\n| # | Angle | Hook | Pourquoi ça marche |\n|---|-------|------|---------------------|\n\nProcède."},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu reçois un tableau de 10 hooks variés et exploitables."},
  {"type":"paragraph","text":"➡️ Étape suivante : Itérer."},

  {"type":"heading2","text":"4. Itérer le prompt pour affiner"},
  {"type":"paragraph","text":"🎯 Objectif : Améliorer les résultats. ⏱️ Temps : 10 min."},
  {"type":"numbered","items":[
    "Repérer 2-3 hooks intéressants.",
    "Demander : « Reprends les hooks #2, #5, #8 et propose 3 variantes plus locales pour Oujda avec emoji et chiffre. »",
    "Demander une version plus courte / plus longue / plus urgente / plus douce.",
    "Demander la traduction en darija (arabe marocain)."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tu as 5-6 hooks finalistes prêts à tester."},
  {"type":"paragraph","text":"➡️ Étape suivante : Audience persona."},

  {"type":"heading2","text":"5. Prompt pour générer un persona + audiences Meta"},
  {"type":"paragraph","text":"🎯 Objectif : Créer des audiences Meta exploitables. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"✏️ PROMPT EXACT :"},
  {"type":"template","text":"Tu es media buyer Meta senior pour le marché marocain.\n\nCLIENT : [coller brief]\n\nMISSION :\n1) Crée 3 personas détaillés (nom fictif, âge, métier, situation familiale, freins, désirs, journée type)\n2) Pour chaque persona, propose 5 centres d'intérêt Meta exploitables (uniquement ceux qui existent réellement dans Ads Manager)\n3) Propose 2 audiences personnalisées (visiteurs site, engagement Insta)\n4) Propose 1 audience lookalike avec source recommandée\n\nFORMAT : sections claires avec titres."},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"3 personas + 15 intérêts + 3 audiences réutilisables."},
  {"type":"paragraph","text":"➡️ Étape suivante : Plan de campagne."},

  {"type":"heading2","text":"6. Prompt pour générer un plan de campagne complet"},
  {"type":"paragraph","text":"🎯 Objectif : Roadmap 30 jours. ⏱️ Temps : 10 min."},
  {"type":"paragraph","text":"✏️ PROMPT EXACT :"},
  {"type":"template","text":"Tu es head of paid media chez Next Gital, agence Oujda spécialisée TPE/PME.\n\nCLIENT : [coller brief]\nBUDGET MENSUEL : 3000 MAD\nDURÉE : 30 jours\n\nMISSION :\nGénère un plan de campagne 30j incluant :\n1) Répartition budget par plateforme (Meta / TikTok / Google)\n2) Structure campagne par plateforme (campagnes, ad sets, ads)\n3) Calendrier semaine par semaine (test → optimisation → scaling)\n4) KPIs cibles (CPL, CTR, ROAS)\n5) Liste des assets nécessaires (visuels, vidéos, landing)\n6) Risques + mitigations\n\nFORMAT : Markdown avec tableaux."},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Plan exploitable + livrable au client."},
  {"type":"paragraph","text":"➡️ Étape suivante : Mots-clés Google."},

  {"type":"heading2","text":"7. Prompt pour générer mots-clés Google Ads"},
  {"type":"paragraph","text":"🎯 Objectif : Liste mots-clés + négatifs. ⏱️ Temps : 5 min."},
  {"type":"paragraph","text":"✏️ PROMPT EXACT :"},
  {"type":"template","text":"Tu es expert SEA Google Ads pour marché marocain.\n\nCLIENT : [secteur, ville]\n\nMISSION :\nGénère :\n1) 30 mots-clés en français + 30 en darija/arabe latinisé\n2) Classer en : Très intention (achat), Intention (recherche), Info (curiosité)\n3) Proposer la correspondance recommandée (exact / phrase / large modifié)\n4) Lister 30 mots-clés négatifs à exclure\n5) Suggérer 5 ad groups thématiques pour grouper\n\nFORMAT : Tableau Markdown."},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"60 mots-clés catégorisés + 30 négatifs + 5 ad groups."},
  {"type":"paragraph","text":"➡️ Étape suivante : Validation humaine."},

  {"type":"heading2","text":"8. Validation humaine + adaptation locale"},
  {"type":"paragraph","text":"🎯 Objectif : Rendre le contenu unique et 100% local. ⏱️ Temps : 20 min."},
  {"type":"numbered","items":[
    "Relire chaque copie : supprimer le « ton corporate IA ».",
    "Ajouter 1 référence locale (quartier d'Oujda, marché, langue darija).",
    "Vérifier les chiffres / promesses (légal).",
    "Faire valider par le client avant publication.",
    "Stocker les meilleurs prompts dans GestiQ → Bibliothèque IA pour réutilisation."
  ]},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Hallucinations IA → toujours vérifier les noms (médecins, lieux). Copie générique → toujours injecter local (Bd Mohammed V, Oujda)."},

  {"type":"divider"},

  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Brief structuré préparé",
    "Modèle IA approprié choisi",
    "Prompt structuré (rôle + contexte + mission + contraintes + format)",
    "Itération faite (au moins 2 cycles)",
    "10 hooks + 3 personas + plan + mots-clés générés",
    "Adaptation locale Oujda ajoutée",
    "Validation client obtenue",
    "Prompts stockés dans GestiQ"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si l'IA refuse ou hallucine 3+ fois → WhatsApp +212 620 002 066."}
]$sop$::jsonb,
    read_min = 15,
    updated_at = now()
WHERE slug = 'ng-mb-prompts-ia';

-- ════════════════════════════════════════════════════════════════════
-- 10/10 — ng-mb-rapport-mensuel
-- ════════════════════════════════════════════════════════════════════
UPDATE public.sops
SET blocks = $sop$[
  {"type":"callout","variant":"info","title":"À qui s'adresse cette SOP","text":"Media Buyer Next Gital qui prépare le rapport mensuel de performance à envoyer au client (PDF + meeting Zoom 30 min)."},
  {"type":"callout","variant":"warning","title":"Prérequis OBLIGATOIRES","text":"1) Accès Meta Ads Manager + Google Ads + TikTok Ads. 2) Accès GA4 du client. 3) Accès GestiQ pour CRM/leads. 4) Template rapport Next Gital (Canva ou Google Slides). 5) Données du mois précédent pour comparaison."},
  {"type":"callout","variant":"tip","title":"Règle d'or","text":"Le rapport doit raconter une HISTOIRE business, pas une liste de chiffres. Toujours : ce qu'on a fait → résultats → apprentissages → plan du mois suivant."},
  {"type":"callout","variant":"danger","title":"À ne JAMAIS faire","text":"Ne PAS envoyer le rapport sans le présenter en visio. Ne PAS cacher les mauvais résultats — toujours expliquer + plan d'action. Ne PAS donner accès brut aux dashboards sans contexte."},

  {"type":"heading","text":"Étapes — dans l'ordre"},

  {"type":"heading2","text":"1. Définir la période + collecter les chiffres bruts"},
  {"type":"paragraph","text":"🎯 Objectif : Données fiables. ⏱️ Temps : 30 min."},
  {"type":"paragraph","text":"🖥️ OÙ : Ads Manager + Google Ads + TikTok + GA4 + GestiQ."},
  {"type":"numbered","items":[
    "Période = du 1er au dernier jour du mois M-1.",
    "Période comparative = mois M-2 + même mois N-1.",
    "Meta Ads : exporter rapport avec colonnes : Dépense, Impressions, Reach, CPM, Clics, CTR, CPC, Résultats, CPR.",
    "Google Ads : même export + Search Impression Share, position moyenne, mots-clés top.",
    "TikTok : Dépense, Impressions, CPM, CTR, CVR.",
    "GA4 : sessions Paid, conversions, source/medium.",
    "GestiQ : leads créés, leads qualifiés, RDV pris, ventes."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Toutes les sources extraites, données stockées dans un Google Sheet partagé."},
  {"type":"callout","variant":"warning","title":"⚠️ Problèmes fréquents","text":"Écart Pixel vs GA4 vs CRM → normal (15-30% de différence). Toujours indiquer la source dans le rapport."},
  {"type":"paragraph","text":"➡️ Étape suivante : Calculer les KPIs."},

  {"type":"heading2","text":"2. Calculer les KPIs business"},
  {"type":"paragraph","text":"🎯 Objectif : Traduire la data en sens business. ⏱️ Temps : 30 min."},
  {"type":"numbered","items":[
    "Calculer pour chaque plateforme : CPL (coût/lead), CPA (coût/RDV ou achat), ROAS si e-com.",
    "Calculer en consolidé : total dépense, total leads, CPL moyen, taux de conversion lead→vente.",
    "Calculer la variation vs mois précédent (%).",
    "Identifier la meilleure campagne / pire campagne.",
    "Identifier la meilleure créa (CTR + CVR)."
  ]},
  {"type":"paragraph","text":"✏️ FORMULES :"},
  {"type":"list","items":[
    "**CPL** → Dépense / Nb leads",
    "**CPA** → Dépense / Nb actions cible",
    "**ROAS** → Chiffre d'affaires / Dépense",
    "**Taux conversion lead→vente** → Ventes / Leads * 100"
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"KPIs présents + comparaison M-1."},
  {"type":"paragraph","text":"➡️ Étape suivante : Identifier les 3 insights clés."},

  {"type":"heading2","text":"3. Identifier 3 insights majeurs"},
  {"type":"paragraph","text":"🎯 Objectif : Insights actionnables. ⏱️ Temps : 20 min."},
  {"type":"numbered","items":[
    "Insight 1 = la victoire du mois (ex : « Carrousel produit a réduit le CPL de 30% »).",
    "Insight 2 = le constat surprenant (ex : « Audience 35-44 convertit 2x plus que 25-34 »).",
    "Insight 3 = la zone à améliorer (ex : « Google Search consomme 40% du budget pour 10% des leads »)."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"3 insights formulés en une phrase chacun, compréhensibles par le client."},
  {"type":"paragraph","text":"➡️ Étape suivante : Construire le PDF."},

  {"type":"heading2","text":"4. Construire le rapport PDF (template Next Gital)"},
  {"type":"paragraph","text":"🎯 Objectif : Document professionnel et lisible. ⏱️ Temps : 1h."},
  {"type":"paragraph","text":"🖥️ OÙ : Canva Pro → template « NG — Rapport Mensuel »."},
  {"type":"numbered","items":[
    "Slide 1 : Couverture (logo Next Gital + logo client + mois + nom Media Buyer).",
    "Slide 2 : Résumé exécutif (5 chiffres + 3 insights).",
    "Slide 3 : Objectifs du mois rappelés + statut atteint/dépassé/raté.",
    "Slide 4-6 : Performance par plateforme (1 slide / plateforme) avec graphiques.",
    "Slide 7 : Top 3 créas (visuels + CPL + CTR).",
    "Slide 8 : Funnel (Impressions → Clics → Leads → Ventes).",
    "Slide 9 : Apprentissages détaillés.",
    "Slide 10 : Plan d'action mois suivant (3-5 actions concrètes).",
    "Slide 11 : Budget recommandé + allocation.",
    "Slide 12 : Annexes / questions.",
    "Exporter en PDF haute qualité."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"PDF 10-12 slides, charte Next Gital, lisible mobile."},
  {"type":"paragraph","text":"➡️ Étape suivante : Relecture interne."},

  {"type":"heading2","text":"5. Relecture interne avant envoi"},
  {"type":"paragraph","text":"🎯 Objectif : Zéro erreur. ⏱️ Temps : 15 min."},
  {"type":"numbered","items":[
    "Faire relire par le chef de projet / autre Media Buyer.",
    "Vérifier orthographe (Antidote / LanguageTool).",
    "Vérifier les chiffres (cohérence inter-slides).",
    "Vérifier les logos clients (à jour).",
    "Vérifier le ton (positif mais honnête)."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Relecture validée, zéro coquille."},
  {"type":"paragraph","text":"➡️ Étape suivante : Planifier la visio."},

  {"type":"heading2","text":"6. Planifier et préparer la visio de présentation"},
  {"type":"paragraph","text":"🎯 Objectif : Restituer en 30 min. ⏱️ Temps : 15 min."},
  {"type":"numbered","items":[
    "Envoyer un lien Calendly (créneau 30 min Zoom).",
    "Envoyer le PDF en avance (24h avant) pour préparation client.",
    "Préparer 2-3 questions à poser au client (priorités M+1, nouveaux produits, événements).",
    "Préparer 1 recommandation forte (action concrète + budget)."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Visio confirmée, PDF reçu par le client."},
  {"type":"paragraph","text":"➡️ Étape suivante : Présentation."},

  {"type":"heading2","text":"7. Conduire la visio (structure 30 min)"},
  {"type":"paragraph","text":"🎯 Objectif : Réunion productive. ⏱️ Temps : 30 min."},
  {"type":"numbered","items":[
    "0-2 min : intro + agenda.",
    "2-7 min : résumé exécutif + 3 insights.",
    "7-15 min : performance par plateforme avec emphase sur la victoire.",
    "15-20 min : zone à améliorer + cause + plan.",
    "20-27 min : plan d'action M+1 + budget + actions client attendues.",
    "27-30 min : questions client + prochaines étapes."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Client repart avec 3 décisions claires."},
  {"type":"paragraph","text":"➡️ Étape suivante : Compte-rendu écrit."},

  {"type":"heading2","text":"8. Envoyer compte-rendu + archive"},
  {"type":"paragraph","text":"🎯 Objectif : Traçabilité + engagement. ⏱️ Temps : 15 min."},
  {"type":"numbered","items":[
    "Email récap dans les 24h : 3 décisions actées + budget validé + dates clés.",
    "Stocker le PDF + le Google Sheet + le compte-rendu dans GestiQ → Clients → {Client} → Rapports → {Mois-Année}.",
    "Mettre à jour le tableau de bord interne Next Gital (revenue, NPS, statut)."
  ]},
  {"type":"callout","variant":"success","title":"✅ Vérification","text":"Tout archivé, client réengagé pour le mois suivant."},

  {"type":"divider"},

  {"type":"heading","text":"Checklist de validation"},
  {"type":"checklist","items":[
    "Données collectées de toutes les sources (Ads + GA4 + CRM)",
    "KPIs calculés + comparaison M-1",
    "3 insights majeurs identifiés",
    "PDF Canva propre 10-12 slides",
    "Relecture interne faite",
    "Visio planifiée + PDF envoyé 24h avant",
    "Présentation faite avec plan d'action clair",
    "Compte-rendu envoyé + archivé dans GestiQ"
  ]},

  {"type":"callout","variant":"danger","title":"🚨 Escalade","text":"Si le client est insatisfait ou veut résilier → WhatsApp +212 620 002 066 IMMÉDIATEMENT, ne jamais répondre seul."}
]$sop$::jsonb,
    read_min = 20,
    updated_at = now()
WHERE slug = 'ng-mb-rapport-mensuel';

COMMIT;

-- ════════════════════════════════════════════════════════════════════
-- Fin migration 043 — 10 SOPs Media Buyer ultra-détaillés mis à jour
-- ════════════════════════════════════════════════════════════════════
