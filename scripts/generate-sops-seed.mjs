#!/usr/bin/env node
/* ════════════════════════════════════════════════════════════════════
   Génère la migration 026_seed_full_sops.sql à partir des 29 SOPs
   officielles de Next Gital. Les blocks sont sérialisés en JSON et
   inclus via dollar-quoted strings (pas d'échappement nécessaire).

   Usage:
     node scripts/generate-sops-seed.mjs > supabase/migrations/026_seed_full_sops.sql
   ════════════════════════════════════════════════════════════════════ */

import { writeFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, resolve } from 'node:path'

const __dirname = dirname(fileURLToPath(import.meta.url))
const OUT = resolve(__dirname, '..', 'supabase', 'migrations', '026_seed_full_sops.sql')

/* ── Helpers pour construire les blocks ─────────────────────────── */
const H = (text) => ({ type: 'heading', text })
const P = (text) => ({ type: 'paragraph', text })
const L = (...items) => ({ type: 'list', items })
const C = (...items) => ({ type: 'checklist', items })
const S = (...items) => ({ type: 'steps', items })
const T = (text) => ({ type: 'template', text })
const CODE = (text) => ({ type: 'code', text })
const DIV = () => ({ type: 'divider' })
const CO = (variant, title, text) => ({ type: 'callout', variant, title, text })

/* ── Les 29 SOPs ────────────────────────────────────────────────── */
const SOPS = [
  /* ═══ 1. WhatsApp (3 SOPs) ═══ */
  {
    slug: 'ng-wa-welcome', category: 'whatsapp', popular: true, read_min: 3,
    title: "Message d'accueil (1er contact)",
    description: "Premier contact WhatsApp — qualifier et envoyer vers le formulaire Tally.",
    tags: ['WhatsApp', 'Accueil', 'Prospect', 'Welcome'],
    blocks: [
      CO('info', 'Délai de réponse', "Envoyer dans les 60 minutes après réception du message."),
      CO('info', 'Canal', "WhatsApp Business — Quick Reply nommé 'Accueil'."),
      CO('tip', 'Objectif', "Qualifier le prospect et l'envoyer vers le formulaire Tally.so."),
      H("Quand utiliser ce script"),
      L(
        "Un prospect envoie 'Bonjour' ou 'Je veux un site'",
        "Un prospect pose une question sur les prix ou les délais",
        "Une demande entrante sur WhatsApp, Instagram DM ou Facebook"
      ),
      H("Script — Message d'accueil standard"),
      T("Bonjour [Prénom] 👋\n\nMerci de contacter Next Gital !\n\nPour vous préparer une analyse personnalisée et une offre adaptée à votre projet, merci de remplir ce formulaire rapide (3 min seulement) :\n\n🔗 [LIEN TALLY.SO]\n\nNotre équipe vous revient avec une proposition dans les 24h. ✅\n\nSans engagement · 100% confidentiel"),
      H("Script — Si le prospect demande directement un prix"),
      T("Bonjour [Prénom] 😊\n\nMerci pour votre message ! Le prix dépend de plusieurs facteurs propres à votre projet.\n\nPour vous donner un tarif précis et juste, je vous invite à remplir ce formulaire (3 min) :\n\n🔗 [LIEN TALLY.SO]\n\nJe vous envoie une proposition personnalisée dans les 24h. Pas de surprise, pas de frais cachés."),
      H("Script — Relance si pas de réponse après 48h"),
      T("Bonjour [Prénom] 👋\n\nJe voulais juste m'assurer que vous avez bien reçu mon message de l'autre jour.\n\nSi vous avez des questions ou besoin d'informations supplémentaires, je suis disponible.\n\n🔗 Le formulaire reste disponible : [LIEN TALLY.SO]\n\nBonne journée ! 🙏"),
      CO('warning', 'Règle absolue', "1 seule relance maximum. Ne jamais envoyer 2 relances au même prospect — cela nuit à l'image de Next Gital."),
    ],
  },
  {
    slug: 'ng-wa-confirm-meeting', category: 'whatsapp', popular: false, read_min: 2,
    title: "Confirmation de réunion",
    description: "Messages de confirmation J-1, rappel 1h avant, et gestion d'absence.",
    tags: ['WhatsApp', 'Réunion', 'Calendly', 'Prospect'],
    blocks: [
      CO('info', 'Délai', "Confirmation envoyée automatiquement via Calendly — ou manuellement 2h avant."),
      CO('tip', 'Objectif', "Réduire le taux de no-show à moins de 10%."),
      H("Message — Confirmation J-1 (veille de la réunion)"),
      T("Bonjour [Prénom] 👋\n\nJe vous rappelle notre rendez-vous de demain :\n\n📅 [JOUR] à [HEURE]\n📞 Via Google Meet — le lien vous sera envoyé automatiquement\n\nLa réunion dure 30 minutes. Je prépare déjà des idées pour votre projet [TYPE DE PROJET].\n\nÀ demain ! 🙏\nNext Gital"),
      H("Message — Rappel 1h avant"),
      T("Bonjour [Prénom] ! ⏰\n\nNotre réunion commence dans 1 heure.\n\n🔗 Lien Meet : [LIEN GOOGLE MEET]\n\nÀ tout à l'heure ! 👋"),
      H("Message — Si le client ne se connecte pas"),
      T("Bonjour [Prénom],\n\nJe n'ai pas réussi à vous joindre à l'heure convenue.\n\nPas de problème — dites-moi quand vous êtes disponible et nous trouvons un autre créneau :\n\n🔗 [LIEN CALENDLY]\n\nBonne journée ! 🙏"),
    ],
  },
  {
    slug: 'ng-wa-send-devis', category: 'whatsapp', popular: true, read_min: 3,
    title: "Envoi du devis",
    description: "Messages WhatsApp pour envoi devis + relance J+3 si pas de réponse.",
    tags: ['WhatsApp', 'Devis', 'Commercial', 'Closing'],
    blocks: [
      CO('warning', 'Délai', "Dans les 48h après la réunion de découverte — sans exception."),
      CO('tip', 'Objectif', "Taux de conversion ≥ 40% sur les devis envoyés."),
      H("Message — Envoi du devis"),
      T("Bonjour [Prénom] 😊\n\nSuite à notre échange de [JOUR], j'ai préparé votre proposition personnalisée pour [NOM DU PROJET].\n\n📄 Voici votre devis : [LIEN DEVIS PDF]\n\nCe devis est valable 7 jours et comprend :\n✅ [LIVRABLE 1]\n✅ [LIVRABLE 2]\n✅ [LIVRABLE 3]\n✅ Garantie satisfaction + 0 retard\n\nPour démarrer, il vous suffit de valider depuis le document.\n\nJe reste disponible pour toute question 🙏\nNext Gital"),
      H("Message — Relance devis après 3 jours sans réponse"),
      T("Bonjour [Prénom] 👋\n\nJe voulais m'assurer que le devis vous est bien parvenu et qu'il est clair.\n\nY a-t-il des points à ajuster ou des questions à clarifier ?\n\nJe suis disponible pour en discuter quand vous le souhaitez.\n\nLe devis reste valable jusqu'au [DATE EXPIRATION]. 📅"),
    ],
  },

  /* ═══ 2. Réponses rapides (3 SOPs) ═══ */
  {
    slug: 'ng-quick-objections', category: 'quick', popular: true, read_min: 4,
    title: "Réponses aux objections fréquentes",
    description: "Réponses prêtes pour les 3 objections les plus courantes (prix, hésitation, concurrence).",
    tags: ['Objections', 'Prix', 'Délai', 'Commercial'],
    blocks: [
      CO('tip', 'Usage', "Répondre rapidement aux objections sans improviser."),
      H("Objection 1 — 'C'est trop cher'"),
      T("Je comprends tout à fait cette préoccupation, [Prénom].\n\nPermettez-moi de vous donner une autre perspective : un site professionnel qui vous ramène 1 nouveau client par mois — combien cela vaut-il sur 1 an ?\n\nChez Next Gital, chaque projet inclus : logo, hébergement 1 an, domaine, email pro, SSL, et 1 an de support. Si vous comparez composant par composant avec le marché, vous verrez que notre offre est la plus complète.\n\nEst-ce que le budget est la seule raison qui vous fait hésiter, ou y a-t-il autre chose ?"),
      H("Objection 2 — 'Je vais réfléchir'"),
      T("Bien sûr [Prénom], c'est tout à fait normal de prendre le temps de décider.\n\nJuste pour que votre réflexion soit bien éclairée : le devis est valable jusqu'au [DATE]. Après cette date, je devrai peut-être réviser le planning selon ma charge de travail.\n\nY a-t-il une information supplémentaire dont vous auriez besoin pour décider plus sereinement ?"),
      H("Objection 3 — 'J'ai une autre offre moins chère'"),
      T("Merci pour votre transparence [Prénom].\n\nIl est tout à fait possible de trouver moins cher. La question est : qu'est-ce qui est inclus ? Hébergement ? SSL ? Support ? Délais garantis ?\n\nChez Next Gital, nous avons 100+ projets livrés, 4.9★ sur Google, et 0 retard en 6 ans. Ce n'est pas un hasard — c'est le résultat de 6 ans de systèmes rodés.\n\nJe ne vous demande pas de choisir le moins cher. Je vous invite à choisir le meilleur rapport qualité/résultat. 🙏"),
    ],
  },
  {
    slug: 'ng-quick-faq', category: 'quick', popular: true, read_min: 3,
    title: "Réponses aux questions fréquentes",
    description: "Délais, modifications, garantie satisfaction — réponses standard.",
    tags: ['FAQ', 'Prospect', 'WhatsApp', 'Délai'],
    blocks: [
      H("Question : Combien de temps pour livrer ?"),
      T("Bonne question [Prénom] !\n\nLes délais varient selon le type de projet :\n📱 Site vitrine simple : 5 à 7 jours\n🌐 Site vitrine Pro : 10 à 14 jours\n🛒 E-commerce : 21 à 30 jours\n⚙️ Plateforme sur mesure : selon cahier des charges\n\nEt notre engagement : 0 retard en 6 ans. Le délai convenu dans le contrat est respecté — toujours."),
      H("Question : Puis-je modifier le site après ?"),
      T("Absolument [Prénom] !\n\nVotre site vous appartient à 100% et vous pouvez le modifier quand vous voulez.\n\nNous incluons aussi :\n✅ 3 modifications gratuites dans les 30 jours après livraison\n✅ Formation de 15 min pour gérer le contenu vous-même\n✅ Support technique 1 an inclus dans tous nos forfaits\n\nSi vous souhaitez qu'on gère les modifications pour vous, nous proposons un contrat de maintenance mensuel à partir de 500 MAD/mois."),
      H("Question : Que se passe-t-il si le résultat ne me convient pas ?"),
      T("C'est une excellente question [Prénom], et je suis content que vous la posiez.\n\nNotre garantie est simple et par écrit :\n🛡️ Si le résultat n'est pas conforme au devis validé — on refait, sans discussion et sans frais.\n\nC'est pour ça que nous travaillons avec des maquettes validées AVANT de développer. Vous approuvez chaque étape. Il n'y a jamais de surprise à la livraison.\n\nSur 100+ projets livrés, nous n'avons jamais eu à activer cette garantie. Mais elle existe pour votre tranquillité. 🙏"),
    ],
  },
  {
    slug: 'ng-quick-thanks', category: 'quick', popular: false, read_min: 2,
    title: "Messages de remerciement & fidélisation",
    description: "Post-livraison J+1 et suivi J+30 (upsell naturel maintenance / SEO).",
    tags: ['Fidélisation', 'Merci', 'Relation', 'J30'],
    blocks: [
      H("Message — Après livraison (J+1)"),
      T("Bonjour [Prénom] 🎉\n\nVotre site est maintenant en ligne ! C'est toujours un moment spécial pour nous de voir un projet mis en ligne.\n\nNous avons préparé pour vous :\n📹 Vidéo tuto (3 min) pour gérer votre contenu\n📘 Guide PDF d'utilisation\n🔐 Vos accès complets dans le dossier partagé\n\nSi vous remarquez quoi que ce soit à ajuster dans les prochains jours, contactez-moi directement.\n\nMerci de votre confiance, [Prénom]. C'était un plaisir ! 🙏"),
      H("Message — J+30 (suivi et upsell naturel)"),
      T("Bonjour [Prénom] 👋\n\nUn mois déjà depuis le lancement de votre site ! Le temps passe vite 😊\n\nComment ça se passe ? Recevez-vous des contacts ou des clients via le site ?\n\nLe moment venu, nous proposons également :\n📣 Gestion des publicités Meta & Google (à partir de 1 500 MAD/mois)\n🔧 Maintenance mensuelle (à partir de 500 MAD/mois)\n📈 Optimisation SEO continue\n🔄 Refonte ou évolution du site\n\nAucune urgence — juste une invitation à continuer à grandir ensemble 🙏\nNext Gital"),
    ],
  },

  /* ═══ 3. Process Commercial (4 SOPs) ═══ */
  {
    slug: 'ng-sales-bant', category: 'sales', popular: true, read_min: 5,
    title: "Qualification BANT",
    description: "Framework Budget · Authority · Need · Timeline pour qualifier en 8 minutes.",
    tags: ['BANT', 'Qualification', 'Commercial', 'Réunion'],
    blocks: [
      CO('tip', 'Usage', "Pendant la réunion de découverte de 30 minutes."),
      CO('warning', 'Objectif', "Ne jamais faire un devis pour un prospect non qualifié."),
      P("BANT = Budget · Authority · Need · Timeline. Ce framework garantit que tu ne passes pas 2h sur un devis pour quelqu'un qui n'a pas les moyens, n'est pas décideur, ou n'a pas de vrai besoin urgent."),
      H("Budget (B) — quel est votre budget approximatif ?"),
      L("Qualifié si : Budget ≥ 3 000 MAD", "Non qualifié si : Refuse de répondre ou budget < 2 000 MAD"),
      H("Authority (A) — qui prend la décision finale ?"),
      L("Qualifié si : C'est lui le décideur", "Non qualifié si : Il doit 'demander à quelqu'un'"),
      H("Need (N) — quel problème précis ce projet doit-il résoudre ?"),
      L("Qualifié si : Problème clair et douloureux", "Non qualifié si : Projet 'pour avoir un site' sans besoin réel"),
      H("Timeline (T) — avez-vous une deadline ?"),
      L("Qualifié si : Urgence identifiée", "Non qualifié si : 'Pas pressé, quand vous voulez'"),
      CO('warning', '🎯 Règle absolue', "Si 2 critères BANT ou plus sont non qualifiés → ne pas faire de devis. Remercier le prospect et proposer de revenir le contacter dans 3 mois."),
    ],
  },
  {
    slug: 'ng-sales-meeting-structure', category: 'sales', popular: true, read_min: 4,
    title: "Structure de la réunion de découverte (30 min)",
    description: "Découpage minute par minute de la réunion de 30 min avec un prospect.",
    tags: ['Réunion', 'Découverte', 'Commercial', 'Script'],
    blocks: [
      CO('info', 'Durée', "30 minutes exactement — respecter le timing."),
      CO('info', 'Outil', "Google Meet + Calendly pour la réservation."),
      H("Structure minute par minute"),
      S(
        "Min 0-5 — Accueil et présentation : « Bonjour [Prénom], je suis [votre prénom] de Next Gital. On a 6 ans d'expérience à Oujda, 100+ projets livrés, 0 retard. Avant de commencer, pouvez-vous me parler de votre activité en 2 minutes ? »",
        "Min 5-15 — Questions de profondeur : Qu'est-ce qui vous bloque actuellement ? Avez-vous déjà eu un site ? Qu'est-ce qui n'a pas fonctionné ? Comment vos clients vous trouvent-ils aujourd'hui ? C'est quoi le succès pour vous dans 6 mois ?",
        "Min 15-22 — Présentation de la méthode : montrer 1-2 projets similaires du portfolio. Expliquer les 4 étapes (Analyse → Conception → Développement → Support). Mentionner les garanties.",
        "Min 22-27 — Qualification BANT : poser les 4 questions BANT naturellement. Confirmer qui décide, quel budget, quelle deadline absolue.",
        "Min 27-30 — Conclusion et engagement : « Parfait, j'ai tout ce qu'il me faut. Je vous prépare une proposition personnalisée et je vous l'envoie dans 48h sur [email]. Merci pour votre temps [Prénom]. »"
      ),
    ],
  },
  {
    slug: 'ng-sales-devis-structure', category: 'sales', popular: true, read_min: 5,
    title: "Structure du devis professionnel",
    description: "Les 7 sections obligatoires d'un devis Next Gital — envoyé sous 48h.",
    tags: ['Devis', 'Commercial', 'PDF', 'Proposition'],
    blocks: [
      CO('warning', 'Délai', "48h après la réunion — jamais plus."),
      CO('info', 'Validité', "7 jours à compter de la date d'envoi."),
      CO('info', 'Format', "PDF généré via GestiQ + envoyé par WhatsApp et email."),
      H("Les 7 sections obligatoires du devis"),
      S(
        "Résumé de compréhension — « Suite à notre échange du [DATE], nous avons compris que votre objectif principal est [OBJECTIF] et que le problème actuel est [PROBLÈME]. » Le client doit se sentir écouté.",
        "La solution proposée — décrire pourquoi CETTE solution pour CE client. Pas un texte générique.",
        "Ce qui est inclus (Scope) — liste exhaustive : nombre de pages, fonctionnalités, logo, hébergement, domaine, SSL, email pro, support 1 an, révisions incluses.",
        "Ce qui n'est PAS inclus — explicit et clair : rédaction des textes (si non demandé), photos professionnelles, SEO mensuel, publicités. Évite 90% des litiges.",
        "Prix et plan de paiement — montant total TTC + plan 50/25/25. Modes : Virement · CIB/Visa · Cash · Wafacash.",
        "Planning détaillé — dates précises de chaque phase (Kick-off → Maquette → Validation → Développement → Tests → Mise en ligne).",
        "Vos 4 garanties écrites — Satisfaction garantie · 0 retard garanti · Support 24h toute l'année · Sécurité avancée."
      ),
    ],
  },
  {
    slug: 'ng-sales-closing', category: 'sales', popular: false, read_min: 4,
    title: "Closing et signature du contrat",
    description: "Plan de paiement 50/25/25 + les 8 clauses obligatoires du contrat.",
    tags: ['Closing', 'Contrat', 'Paiement', 'Commercial'],
    blocks: [
      CO('warning', 'Règle absolue', "Zéro travail sans signature + acompte de 50% reçu."),
      H("Plan de paiement standard"),
      L(
        "1er versement (50%) — à la signature du contrat. Modes : Virement · CIB/Visa · Cash · Wafacash · Cashplus",
        "2ème versement (25%) — à la livraison de la maquette V1",
        "3ème versement (25%) — à la réception et validation finale"
      ),
      H("Les 8 clauses obligatoires du contrat Next Gital"),
      C(
        "Identité des parties (Next Gital + Client avec coordonnées complètes)",
        "Périmètre exact du projet (scope du devis validé + ce qui n'est pas inclus)",
        "Planning et dates de livraison de chaque phase",
        "Plan de paiement 50/25/25 avec modes acceptés",
        "Politique de révisions : 3 révisions gratuites incluses, tarif pour révisions supplémentaires",
        "Politique d'annulation : le 1er versement (50%) est non remboursable si le client annule",
        "Propriété intellectuelle : transfert complet au client après paiement intégral uniquement",
        "Droit portfolio : autorisation d'utiliser le projet dans nos réalisations et communications"
      ),
      CO('warning', '🔒 Rappel', "La propriété intellectuelle du site reste chez Next Gital tant que le paiement intégral n'est pas reçu. Cette clause protège votre travail."),
    ],
  },

  /* ═══ 4. Onboarding Client (3 SOPs) ═══ */
  {
    slug: 'ng-onb-kickoff', category: 'onboarding', popular: true, read_min: 3,
    title: "Message de kick-off officiel",
    description: "Message de démarrage envoyé dans les 24h après réception du 1er acompte.",
    tags: ['Onboarding', 'Kickoff', 'Client', 'Démarrage'],
    blocks: [
      CO('info', 'Délai', "Dans les 24h après réception du 1er acompte (50%)."),
      CO('tip', 'Objectif', "Créer un sentiment de professionnalisme dès le départ."),
      H("Message de bienvenue officiel"),
      T("Bonjour [Prénom] 🎉\n\nPaiement bien reçu — votre projet [NOM DU PROJET] démarre officiellement !\n\nVoici votre dossier de démarrage :\n\n📁 Dossier projet partagé : [LIEN GOOGLE DRIVE]\n📋 Liste des éléments requis : [LIEN LISTE]\n📅 Planning détaillé : [LIEN PLANNING]\n\n🗂️ Règles de communication :\n• WhatsApp : pour les questions rapides (réponse < 1h en heures ouvrées)\n• Email : pour les validations officielles et l'envoi de fichiers\n• Réunions : via Calendly — [LIEN CALENDLY]\n\nHoraires : Lundi–Vendredi · 9h00–17h00\n\nNotre premier point est le [DATE] pour vous présenter la maquette initiale.\n\nBienvenue dans l'équipe Next Gital ! 🙏"),
    ],
  },
  {
    slug: 'ng-onb-elements', category: 'onboarding', popular: false, read_min: 3,
    title: "Liste des éléments à recevoir du client",
    description: "Checklist des fichiers à demander au client lors du kick-off — délai 5 jours.",
    tags: ['Onboarding', 'Brief', 'Fichiers', 'Client'],
    blocks: [
      CO('warning', 'Délai accordé', "5 jours ouvrés pour transmettre tous les éléments."),
      CO('info', 'Impact', "Si délai non respecté : le planning se décale d'autant — le client est responsable."),
      H("Checklist — éléments à demander au client"),
      C(
        "Logo — PNG transparent + SVG (sans logo : Next Gital crée un logo pro inclus)",
        "Photos professionnelles — JPG haute résolution min 1 Mo (sans photos : banque d'images)",
        "Textes / contenu — Word ou Google Doc (sinon : rédaction Next Gital en service additionnel)",
        "Coordonnées officielles — adresse, tél, email, horaires",
        "Liens réseaux sociaux — Instagram, Facebook, LinkedIn, TikTok...",
        "Couleurs de la marque — codes HEX si disponibles (sinon : définies au brief design)",
        "Accès hébergement existant — uniquement si refonte (cPanel / Plesk)",
        "Exemples de sites appréciés — aide à aligner les attentes visuelles"
      ),
      CO('warning', '⏰ Important', "Précisez dans le message que si les éléments ne sont pas reçus dans les 5 jours, la date de livraison est repoussée d'autant. Cela protège votre planning."),
    ],
  },
  {
    slug: 'ng-onb-charte-comm', category: 'onboarding', popular: false, read_min: 2,
    title: "Charte de communication projet",
    description: "Document à envoyer à chaque client lors du kick-off — règles WhatsApp / Email / RDV.",
    tags: ['Communication', 'Règles', 'Client', 'Projet'],
    blocks: [
      CO('warning', 'Usage', "Envoyer à CHAQUE client lors du kick-off — sans exception."),
      H("Charte complète à envoyer"),
      T("📋 CHARTE DE COMMUNICATION — [NOM DU PROJET]\nNext Gital × [NOM CLIENT]\n\n━━━━━━━━━━━━━━━━━━━━━━━━━━━\n📱 WHATSAPP (+212 620 002 066)\n• Pour : questions rapides, validations simples, urgences\n• Réponse garantie : dans les 60 min (heures ouvrées)\n• Heures ouvrées : Lundi–Vendredi, 9h00–17h00\n\n📧 EMAIL (info@nextgital.com)\n• Pour : validations officielles, envoi de fichiers, révisions\n• Réponse garantie : dans les 24h ouvrées\n• Toute validation par email est contraignante\n\n📅 RÉUNIONS (via Calendly)\n• Réservation : [LIEN CALENDLY]\n• Durée standard : 30 minutes\n• Préavis minimum : 24h\n\n🚫 CE QUI N'EST PAS INCLUS\n• Demandes hors scope du devis signé\n• Modifications après validation (au-delà des 3 révisions incluses)\n• Urgences hors heures ouvrées (sauf plan Support Priority)\n\n✅ NOS ENGAGEMENTS\n• Livraison dans les délais contractuels\n• Maquettes validées avant développement\n• Support disponible 1 an après livraison\n━━━━━━━━━━━━━━━━━━━━━━━━━━━\nNext Gital · +212 620 002 066 · Oujda"),
    ],
  },

  /* ═══ 5. Livraison Projet (3 SOPs) ═══ */
  {
    slug: 'ng-del-qa-checklist', category: 'delivery', popular: true, read_min: 4,
    title: "Checklist QA avant mise en ligne",
    description: "15 vérifications obligatoires avant de passer un projet en production.",
    tags: ['Livraison', 'QA', 'Qualité', 'Checklist'],
    blocks: [
      CO('warning', 'Règle', "Aucune mise en ligne sans que tous les points soient cochés."),
      H("Checklist technique — toutes les vérifications"),
      C(
        "Vitesse de chargement < 2 secondes sur mobile (tester avec GTmetrix ou PageSpeed)",
        "Responsive mobile testé sur iPhone, Android, tablette — tous les breakpoints",
        "Tous les liens internes et externes cliqués et fonctionnels",
        "Formulaire de contact : envoi testé + réception de l'email vérifiée",
        "Bouton WhatsApp testé sur mobile ET desktop",
        "SSL / HTTPS actif (cadenas visible dans la barre d'adresse)",
        "Certificat SSL valide et auto-renouvelable",
        "Google Analytics installé et données reçues",
        "Meta tags SEO : title, description, og:image sur toutes les pages",
        "Images optimisées (toutes < 200 Ko, format WebP si possible)",
        "Sauvegarde initiale complète du site avant mise en ligne",
        "Favicon visible dans l'onglet du navigateur",
        "Liens Instagram, Facebook, LinkedIn fonctionnels",
        "Textes relus — pas de fautes d'orthographe, informations vérifiées",
        "RGPD basique : mentions légales + politique de confidentialité présentes"
      ),
    ],
  },
  {
    slug: 'ng-del-delivery-msg', category: 'delivery', popular: false, read_min: 2,
    title: "Message de livraison finale",
    description: "Annonce officielle de la mise en ligne + demande d'avis Google J+2.",
    tags: ['Livraison', 'Message', 'Client', 'URL'],
    blocks: [
      CO('info', 'Délai', "Envoyer dans les heures qui suivent la mise en ligne."),
      H("Message de livraison officielle"),
      T("🎉 Bonjour [Prénom] !\n\nVotre site est maintenant en ligne : 🔗 [URL DU SITE]\n\nNous avons vérifié chaque détail avant la mise en ligne :\n✅ Vitesse optimisée (< 2 secondes)\n✅ 100% responsive mobile\n✅ SEO configuré\n✅ SSL actif\n✅ Formulaire de contact testé\n\nPour gérer votre site facilement :\n🎥 Vidéo tutoriel (5 min) : [LIEN VIDÉO]\n📘 Guide PDF : [LIEN PDF]\n🔐 Vos accès : voir le dossier Drive partagé\n\nVos 3 révisions gratuites sont disponibles pendant 30 jours.\n\nMerci pour votre confiance [Prénom] — c'est toujours une fierté de livrer un beau projet ! 🙏\nNext Gital"),
      H("Message — Demande d'avis Google (J+2)"),
      T("Bonjour [Prénom] 😊\n\nJ'espère que votre site vous plaît et que tout fonctionne bien !\n\nSi vous êtes satisfait de notre travail, un avis Google nous aiderait énormément. Cela prend 1 minute :\n\n⭐ Laisser un avis : [LIEN GOOGLE REVIEW DIRECT]\n\nMerci d'avance — chaque avis compte beaucoup pour notre petite équipe 🙏\nNext Gital"),
    ],
  },
  {
    slug: 'ng-del-maquette-validation', category: 'delivery', popular: false, read_min: 3,
    title: "Processus de validation des maquettes",
    description: "Workflow Figma : wireframe → design → validation écrite avant développement.",
    tags: ['Maquette', 'Design', 'Validation', 'Figma'],
    blocks: [
      CO('warning', 'Règle absolue', "Jamais commencer le développement sans validation écrite de la maquette."),
      CO('info', 'Outil', "Figma pour la maquette · Email pour la validation officielle."),
      H("Étapes du processus"),
      S(
        "Brief visuel — rassembler les références visuelles du client (sites aimés, couleurs, logo). Créer un board Figma avec toutes les inspirations.",
        "Wireframe (J1-J3) — maquette en nuances de gris, structure uniquement. Le client valide l'architecture avant le design.",
        "Message de présentation wireframe : « Voici la maquette structurelle de votre site [URL FIGMA]. Vous pouvez commenter directement sur Figma. Vos retours sont attendus dans 48h pour respecter le planning. »",
        "Design couleurs (J4-J8) — après validation wireframe, appliquer couleurs, typographies, images. Présentation au client.",
        "Validation finale écrite — le client envoie par email : « Je valide la maquette. » Ce message déclenche officiellement le développement.",
        "Développement — uniquement après la confirmation écrite. Aucune modification de scope acceptée après ce point sans avenant signé."
      ),
    ],
  },

  /* ═══ 6. Support Client (3 SOPs) ═══ */
  {
    slug: 'ng-sup-reclamations', category: 'support', popular: true, read_min: 3,
    title: "Gestion des réclamations",
    description: "Process en 4 étapes pour transformer une réclamation en opportunité de fidélisation.",
    tags: ['Réclamation', 'SAV', 'Client', 'Problème'],
    blocks: [
      CO('warning', 'Délai de réponse', "Accuser réception dans les 2h maximum."),
      CO('tip', 'Objectif', "Transformer chaque réclamation en opportunité de fidélisation."),
      H("Les 4 étapes de gestion d'une réclamation"),
      S(
        "Accuser réception immédiatement — ne jamais laisser un client sans réponse plus de 2h. Même sans solution, confirmer que le message est reçu et le problème pris en charge.",
        "Comprendre avant de répondre — poser des questions, ne pas supposer. Demander : captures d'écran, navigateur utilisé, device, comportement exact.",
        "Donner un délai de résolution — communiquer précisément : « Je reviens vers vous avec une solution dans les 4h / avant 17h aujourd'hui / demain matin. »",
        "Résoudre et faire un suivi — résoudre le problème, informer le client, et faire un suivi 24h après pour s'assurer que tout fonctionne bien."
      ),
      H("Message — Accusé de réception réclamation"),
      T("Bonjour [Prénom],\n\nMerci de nous avoir contactés. Je prends note du problème que vous rencontrez avec [DESCRIPTION DU PROBLÈME].\n\nJe vais analyser la situation et je reviens vers vous avec une solution avant [HEURE / DATE].\n\nSi vous avez des captures d'écran ou des informations supplémentaires, n'hésitez pas à me les envoyer — cela m'aidera à résoudre le problème plus rapidement.\n\nJe m'en occupe personnellement. 🙏\n[Votre prénom] · Next Gital"),
      H("Message — Résolution du problème"),
      T("Bonjour [Prénom] ✅\n\nBonne nouvelle — le problème [DESCRIPTION] a été résolu.\n\nCe qui a été fait : [EXPLICATION SIMPLE DE LA SOLUTION]\n\nVous pouvez vérifier par vous-même sur [URL]. Si vous constatez quoi que ce soit d'autre, n'hésitez pas à me contacter.\n\nDésolé pour le désagrément et merci de votre patience 🙏\nNext Gital"),
    ],
  },
  {
    slug: 'ng-sup-technique-1an', category: 'support', popular: false, read_min: 3,
    title: "Support technique inclus (1 an)",
    description: "Périmètre du support 1 an inclus, délais de réponse et de résolution par type de demande.",
    tags: ['Support', 'Technique', 'Bug', 'Maintenance'],
    blocks: [
      CO('info', 'Périmètre', "Bugs, plantages, problèmes d'affichage liés au travail de Next Gital."),
      CO('warning', 'Hors périmètre', "Modifications de contenu, nouvelles fonctionnalités, problèmes d'hébergeur tiers."),
      H("Grille des délais de réponse et résolution"),
      L(
        "Bug critique (site down) — réponse < 1h · résolution < 4h · INCLUS (priorité absolue)",
        "Bug visuel (affichage) — réponse < 4h · résolution < 24h · INCLUS",
        "Problème formulaire/email — réponse < 4h · résolution < 24h · INCLUS",
        "Mise à jour de contenu — réponse < 24h · résolution < 48h · NON inclus (facturation séparée)",
        "Nouvelle fonctionnalité — réponse < 48h · résolution selon devis · NON inclus (nouveau projet)",
        "Problème hébergeur/domaine — réponse < 2h · résolution selon prestataire · Assistance incluse"
      ),
    ],
  },
  {
    slug: 'ng-sup-maintenance-mensuelle', category: 'support', popular: true, read_min: 3,
    title: "Offre de maintenance mensuelle",
    description: "3 packages Basic / Pro / Premium — à proposer lors de la livraison et J+30.",
    tags: ['Maintenance', 'Abonnement', 'Récurrent', 'Upsell'],
    blocks: [
      CO('tip', 'Moment idéal', "Proposer lors de la livraison + relance à J+30."),
      H("Package Basic — 500 MAD/mois"),
      L(
        "Mises à jour CMS + plugins",
        "Sauvegarde hebdomadaire",
        "Surveillance uptime",
        "1h de modifications contenu / mois",
        "Idéal pour : sites vitrine simples"
      ),
      H("Package Pro — 1 000 MAD/mois"),
      L(
        "Tout Basic + mises à jour contenu illimitées",
        "Rapport mensuel de performance",
        "Support prioritaire < 4h",
        "SSL surveillé",
        "Idéal pour : sites e-commerce ou CRM"
      ),
      H("Package Premium — 2 000 MAD/mois"),
      L(
        "Tout Pro + optimisation SEO mensuelle",
        "Rapport analytics complet",
        "Appel mensuel de suivi",
        "Support < 1h",
        "Idéal pour : entreprises avec fort trafic"
      ),
      H("Message de proposition — WhatsApp"),
      T("Bonjour [Prénom] 👋\n\nVotre site a maintenant 1 mois. Pour continuer à le protéger et l'optimiser, nous proposons notre service de maintenance mensuelle.\n\n🔧 Package Basic (500 MAD/mois) :\n• Mises à jour automatiques\n• Sauvegarde hebdomadaire\n• Surveillance 24h/24\n• 1h de modifications contenu\n\n📈 Package Pro (1 000 MAD/mois) :\n• Tout le Basic + contenu illimité\n• Rapport mensuel de performance\n• Support prioritaire\n\nSans engagement — vous pouvez arrêter à tout moment.\n\nIntéressé ? Je vous prépare un devis en 5 minutes. 🙏"),
    ],
  },

  /* ═══ 7. Marketing & Ads (3 SOPs) ═══ */
  {
    slug: 'ng-mkt-content-plan', category: 'marketing', popular: false, read_min: 4,
    title: "Plan de contenu mensuel Next Gital",
    description: "Calendrier hebdo Instagram/LinkedIn — 3 publications/semaine minimum.",
    tags: ['Marketing', 'Contenu', 'Instagram', 'LinkedIn', 'Calendrier'],
    blocks: [
      CO('info', 'Fréquence', "Minimum 3 publications par semaine."),
      CO('info', 'Outils', "Canva (visuels) · CapCut (vidéos) · Buffer (planification)."),
      H("Calendrier hebdomadaire"),
      L(
        "Lundi — Conseil technique utile (Reel 30-45s ou Carrousel). Objectif : valorisation. Ex : 5 erreurs qui tuent votre site web",
        "Mercredi — Avant / Après projet (Carrousel 5-8 slides). Objectif : preuve. Ex : refonte site Dr. [Nom] — résultats en chiffres",
        "Vendredi — Témoignage ou étude de cas (Post + texte ou Story). Objectif : confiance. Ex : comment [Client X] reçoit 3x plus de patients",
        "Stories quotidiennes — Coulisses, process, équipe (Stories éphémères). Objectif : proximité."
      ),
      H("Template de légende Instagram"),
      T("[ACCROCHE — MAX 2 LIGNES] ❌ [PROBLÈME DU CLIENT]\n\nQuand [NOM CLIENT] est venu nous voir, il avait ce problème :\n👉 [PROBLÈME CONCRET]\n\nVoici ce qu'on a fait :\n✅ [ACTION 1]\n✅ [ACTION 2]\n✅ [ACTION 3]\n\nRésultat après [X semaines] :\n📈 [RÉSULTAT CHIFFRÉ]\n📱 [RÉSULTAT CHIFFRÉ]\n\nVous voulez le même résultat ?\n👇 Analyse gratuite en lien en bio (réponse sous 1h)\n\n#NextGital #AgenceDigitale #Oujda #SiteWeb #MarocDigital #[SECTEUR]"),
    ],
  },
  {
    slug: 'ng-mkt-meta-ads', category: 'marketing', popular: true, read_min: 5,
    title: "Gestion des campagnes Meta Ads",
    description: "Structure 3-campagnes (Notoriété + Considération + Conversion) + rapport hebdo.",
    tags: ['MetaAds', 'Facebook', 'Instagram', 'Publicité', 'ROI'],
    blocks: [
      CO('info', 'Budget min recommandé', "1 500 MAD/mois (budget client) + 1 500 MAD/mois (gestion Next Gital)."),
      CO('tip', 'Objectif', "ROAS ≥ 3x pour les e-commerce · CPL ≤ 50 MAD pour les services."),
      H("Étapes de gestion"),
      S(
        "Audit et brief client — identifier l'objectif (leads/ventes/notoriété), budget, cible géo et démo, offres à promouvoir.",
        "Création des visuels — 3-5 variantes par campagne. Format : 1080×1080 (feed) + 1080×1920 (stories/reels). Toujours brand client.",
        "Structure de campagne — Campagne 1 : Notoriété (audience froide) · Campagne 2 : Considération (engagement) · Campagne 3 : Conversion (retargeting). Budget : 60% conversion, 30% considération, 10% notoriété.",
        "Rapport de performance hebdomadaire — envoyer au client : Impressions, CPM, CTR, CPL/CPC, ROAS, recommandations.",
        "Optimisation continue — couper les pubs avec CTR < 0.5% après 3 jours · doubler le budget des pubs performantes · A/B tester en continu."
      ),
      H("Template Rapport mensuel Meta Ads"),
      T("📊 RAPPORT MENSUEL META ADS — [NOM CLIENT]\nPériode : [MOIS ANNÉE]\n\n━━ RÉSUMÉ PERFORMANCE ━━\n💰 Budget dépensé : [X] MAD\n👁️ Impressions : [X]\n🖱️ Clics : [X] (CTR : [X]%)\n📥 Leads générés : [X] (CPL : [X] MAD)\n🛒 Ventes (si e-commerce) : [X] MAD (ROAS : [X]x)\n\n━━ TOP 3 PUBLICITÉS ━━\n1. [Nom pub] — [X] leads — [X] MAD CPL\n2. [Nom pub] — [X] leads — [X] MAD CPL\n3. [Nom pub] — [X] leads — [X] MAD CPL\n\n━━ ACTIONS DU MOIS PROCHAIN ━━\n✅ [ACTION 1]\n✅ [ACTION 2]\n✅ [ACTION 3]\n\nBonne continuation,\nNext Gital · +212 620 002 066"),
    ],
  },
  {
    slug: 'ng-mkt-parrainage', category: 'marketing', popular: false, read_min: 3,
    title: "Programme de parrainage Next Gital",
    description: "Récompenses parrain/filleul selon le type de projet — à annoncer à chaque livraison.",
    tags: ['Parrainage', 'Référence', 'Fidélisation', 'Croissance'],
    blocks: [
      CO('warning', 'Règle', "Annoncer le programme à CHAQUE client lors de la livraison."),
      H("Fonctionnement du programme"),
      L(
        "Référer un site vitrine — parrain : 1 mois de maintenance gratuit (500 MAD) · filleul : 5% de réduction. Condition : projet signé + acompte payé.",
        "Référer un e-commerce — parrain : 2 mois de maintenance gratuit (1 000 MAD) · filleul : 10% de réduction.",
        "Référer un client abonnement — parrain : 1 mois de son abonnement offert · filleul : 1er mois à 50%. Condition : 3 mois d'abonnement du filleul."
      ),
      H("Message d'annonce — à la livraison"),
      T("🎁 Bonjour [Prénom],\n\nMaintenant que votre site est en ligne, j'ai une petite information qui pourrait vous intéresser.\n\nNotre programme de parrainage :\nSi vous recommandez Next Gital à un ami ou collègue qui signe avec nous — vous recevez 1 mois de maintenance gratuit (valeur 500 MAD) en guise de merci.\n\nAucune démarche compliquée : il suffit de lui envoyer notre numéro (+212 620 002 066) en précisant que vous nous avez recommandés.\n\nC'est notre façon de remercier nos clients de confiance 🙏"),
    ],
  },

  /* ═══ 8. FAQ Interne (4 SOPs) ═══ */
  {
    slug: 'ng-faq-hors-scope', category: 'faq', popular: false, read_min: 3,
    title: "FAQ : Gestion des demandes hors scope",
    description: "Arbre de décision quand un client demande quelque chose qui n'est pas dans le devis.",
    tags: ['FAQ', 'Scope', 'Avenant', 'Commercial'],
    blocks: [
      CO('warning', 'Problème', "Un client demande quelque chose qui n'est pas dans le devis signé."),
      H("Arbre de décision"),
      S(
        "Demande mineure (< 30 min de travail) — faire sans facturer. Mentionner : « J'ai fait ce petit ajustement en geste commercial. » Renforce la relation sans coût.",
        "Demande modérée (30 min à 2h) — inclure dans une des révisions gratuites restantes. Sinon : mini-avenant à 300-500 MAD.",
        "Demande importante (> 2h ou nouvelle fonctionnalité) — expliquer calmement que ça dépasse le scope. Proposer un avenant signé. Ne jamais dire 'non' — toujours 'oui avec devis complémentaire'.",
        "Le client insiste et devient difficile — rappeler les termes du contrat signé. Rester pro. Si ça persiste : escalader au fondateur. Ne jamais se disputer."
      ),
      H("Message hors scope — diplomate"),
      T("Bonjour [Prénom],\n\nMerci pour cette nouvelle demande ! Je comprends tout à fait que les besoins évoluent au cours d'un projet.\n\nCette fonctionnalité/modification n'est pas incluse dans le devis initial signé le [DATE], mais je peux absolument vous la préparer.\n\nJe vous envoie un devis complémentaire dans les 24h.\n\nEn attendant, n'hésitez pas si vous avez d'autres questions 🙏"),
    ],
  },
  {
    slug: 'ng-faq-revisions', category: 'faq', popular: false, read_min: 2,
    title: "FAQ : Politique des révisions",
    description: "Réponses officielles aux questions sur les 3 révisions gratuites incluses.",
    tags: ['Révisions', 'Scope', 'Client', 'Processus'],
    blocks: [
      H("Combien de révisions sont incluses ?"),
      P("3 révisions majeures gratuites dans les 30 jours après la livraison finale."),
      H("Qu'est-ce qu'une 'révision majeure' ?"),
      P("Un retour structurel sur une page ou une section entière. Exemple : changer la structure de la page d'accueil."),
      H("Qu'est-ce qui n'est PAS une révision ?"),
      P("Une correction de typo, un changement d'image ou un ajout de texte mineur — c'est du contenu, pas une révision."),
      H("Que se passe-t-il après les 3 révisions ?"),
      P("Chaque révision supplémentaire est facturée 200-500 MAD selon l'amplitude des changements."),
      H("Et si le client n'est jamais satisfait ?"),
      P("Appliquer la garantie satisfaction : si le résultat n'est pas conforme au devis validé, on refait. Si le client change continuellement ses exigences initiales, c'est hors garantie."),
    ],
  },
  {
    slug: 'ng-faq-retards', category: 'faq', popular: false, read_min: 3,
    title: "FAQ : Gestion des retards et imprévus",
    description: "Comment communiquer un retard selon sa cause (client, Next Gital, technique).",
    tags: ['Retard', 'Planning', 'Communication', 'Crise'],
    blocks: [
      CO('warning', 'Règle N°1', "Informer le client AVANT que le retard se produise — jamais après."),
      H("Types de retards et gestion"),
      L(
        "Client n'a pas envoyé les éléments — responsabilité client. Rappel immédiat. Le planning se décale automatiquement. Message : « Sans les éléments, le planning est décalé d'autant. Dès réception, nous reprenons immédiatement. »",
        "Trop de projets simultanés — responsabilité Next Gital. Honnêteté + compensation. Message : « Notre équipe est plus chargée qu'anticipé. Nouveau délai : [DATE]. En compensation : [service gratuit]. »",
        "Problème technique imprévu — neutre. Expliquer + nouveau délai. Message : « Un problème technique inattendu nous oblige à prendre 2 jours supplémentaires. Nouveau délai garanti : [DATE]. »",
        "Révisions excessives du client — responsabilité client. Rappeler le scope + proposer un planning révisé. Message : « Les retours ont été plus nombreux qu'anticipé. Avec les 3 nouvelles révisions, la mise en ligne est prévue le [DATE]. »"
      ),
    ],
  },
  {
    slug: 'ng-faq-paiements', category: 'faq', popular: false, read_min: 3,
    title: "FAQ : Gestion des paiements en retard",
    description: "Process J+1 / J+5 / J+10 / J+30 pour recouvrer un paiement client.",
    tags: ['Paiement', 'Retard', 'Finance', 'Recouvrement'],
    blocks: [
      CO('warning', 'Règle absolue', "Aucun travail supplémentaire tant que le paiement est en retard."),
      H("Process de recouvrement par étapes"),
      S(
        "J+1 après échéance — Premier rappel WhatsApp amical : « Bonjour [Prénom], je voulais vous rappeler que le versement de [MONTANT] MAD était prévu le [DATE]. Quand pouvez-vous effectuer le virement ? »",
        "J+5 — Deuxième rappel (WhatsApp + email plus formel) : « Votre versement de [MONTANT] MAD est maintenant en retard de 5 jours. Merci de régulariser avant le [DATE+3] pour ne pas impacter le planning. »",
        "J+10 — Suspension de travaux officielle : « Suite au non-paiement, nous suspendons les travaux jusqu'à régularisation. Le site ne sera pas mis en ligne avant réception du paiement. »",
        "J+30 — Mise en demeure officielle par email avec AR. Contacter un conseiller juridique si nécessaire. Ne jamais supprimer le travail déjà réalisé sans avis juridique."
      ),
    ],
  },

  /* ═══ 9. IA & Automatisation (3 SOPs) ═══ */
  {
    slug: 'ng-ai-prompts', category: 'ai', popular: true, read_min: 5,
    title: "Prompts IA pour le quotidien de Next Gital",
    description: "4 prompts Claude AI prêts à l'emploi : devis, analyse concurrent, contenu IG, réclamation.",
    tags: ['IA', 'Prompts', 'Claude', 'Automatisation', 'Productivité'],
    blocks: [
      CO('info', 'Outil principal', "Claude AI (Anthropic) + Conseiller IA intégré dans GestiQ."),
      H("Prompt 1 — Rédiger un devis personnalisé"),
      T("Tu es un consultant commercial senior de l'agence Next Gital basée à Oujda, Maroc.\n\nVoici les informations du prospect :\n- Nom : [NOM CLIENT]\n- Secteur : [SECTEUR]\n- Problème actuel : [PROBLÈME]\n- Objectif : [OBJECTIF]\n- Budget : [BUDGET] MAD\n- Délai souhaité : [DÉLAI]\n- Type de projet : [TYPE]\n\nRédige un devis professionnel en français avec les 7 sections suivantes :\n1. Résumé de compréhension (montrer qu'on a compris leur problème)\n2. Notre solution proposée (pourquoi ce choix pour ce client)\n3. Ce qui est inclus (scope détaillé)\n4. Ce qui n'est pas inclus\n5. Prix : [MONTANT] MAD + plan de paiement 50/25/25\n6. Planning détaillé avec dates précises\n7. Nos 4 garanties écrites\n\nTon de voix : professionnel, chaleureux, confiant. Pas de jargon technique inutile."),
      H("Prompt 2 — Analyser un site concurrent"),
      T("Analyse ce site web pour moi : [URL]\n\nJe suis une agence web marocaine (Next Gital) et ce site appartient au concurrent de mon prospect dans le secteur [SECTEUR] à [VILLE].\n\nDonne-moi :\n1. Les 3 points forts de ce site (design, contenu, SEO visible)\n2. Les 3 faiblesses identifiables\n3. Ce que mon prospect pourrait faire MIEUX avec nous\n4. 2-3 arguments de vente que je peux utiliser en réunion\n\nFormat : court, actionnable, bullet points."),
      H("Prompt 3 — Générer du contenu Instagram"),
      T("Tu es un expert en marketing digital pour PME marocaines.\n\nCrée un post Instagram pour Next Gital (agence web à Oujda) sur le sujet : [SUJET]\n\nFormat :\n- Accroche percutante (1-2 lignes, en français)\n- Corps du post (3-5 points avec émojis)\n- Call-to-action clair\n- 8-10 hashtags pertinents (mix français/anglais/marocain)\n\nStyle : professionnel mais accessible. Ton humain, pas robotique.\nLongueur : 150-200 mots maximum.\nLangue : Français (pas de darija dans le texte principal)"),
      H("Prompt 4 — Répondre à une réclamation difficile"),
      T("Tu es le responsable relation client de Next Gital, une agence web professionnelle.\n\nUn client (secteur : [SECTEUR]) est mécontent à cause de : [PROBLÈME]\n\nSa réclamation exacte : [MESSAGE DU CLIENT]\n\nRédige une réponse qui :\n1. Reconnaît le problème sans se défausser\n2. S'excuse sincèrement si la faute est de notre côté\n3. Propose une solution concrète avec délai précis\n4. Maintient la relation commerciale\n5. Ne promet pas ce qu'on ne peut pas tenir\n\nTon de voix : calme, professionnel, empathique. Pas défensif.\nLongueur : 100-150 mots."),
    ],
  },
  {
    slug: 'ng-ai-automations', category: 'ai', popular: false, read_min: 4,
    title: "Automatisations GestiQ à configurer",
    description: "Les 8 triggers essentiels à activer dans le module Automatisations.",
    tags: ['Automatisation', 'GestiQ', 'Triggers', 'Workflow'],
    blocks: [
      CO('info', 'Module', "Automatisations → Triggers dans GestiQ."),
      H("Les 8 triggers essentiels"),
      L(
        "🔴 Nouveau lead WhatsApp — Formulaire Tally reçu → créer fiche CRM + notifier Admin (CRITIQUE)",
        "🔴 Réunion réservée — Calendly booking confirmé → créer tâche 'Préparer réunion' + notifier (CRITIQUE)",
        "🟡 Devis envoyé sans réponse — J+3 après envoi → notification 'Relancer [NOM]' (IMPORTANT)",
        "🟡 Devis sans réponse J+7 — déplacer vers 'Perdu' + archiver (IMPORTANT)",
        "🟡 Projet sans activité 3 jours — aucune action sur projet ouvert → alerte 'Projet inactif' (IMPORTANT)",
        "🟢 Livraison effectuée — statut → Livré → créer tâche 'Demander avis Google J+2' (STANDARD)",
        "🔴 Facture impayée J+5 — facture non payée après échéance → notification + email relance auto (CRITIQUE)",
        "🟡 Fin d'hébergement dans 30j — date expiration domaine/hébergement → alerte renouvellement + email client (IMPORTANT)"
      ),
    ],
  },
  {
    slug: 'ng-ai-finance', category: 'ai', popular: false, read_min: 3,
    title: "Workflow IA pour l'analyse financière mensuelle",
    description: "Routine du 1er de chaque mois — 30 min max pour analyser la performance via IA.",
    tags: ['Finance', 'IA', 'Rapport', 'Mensuel', 'Analyse'],
    blocks: [
      CO('info', 'Fréquence', "Le 1er de chaque mois — 30 minutes max."),
      CO('info', 'Outil', "Conseiller IA GestiQ + données du dashboard finances."),
      H("Étapes du workflow"),
      S(
        "Exporter les données du mois — GestiQ → Rapports & Export → Rapport mensuel [MOIS]. Télécharger en CSV ou PDF.",
        "Prompt d'analyse financière — ouvrir le Conseiller IA et coller : « Analyse ces données financières de Next Gital pour le mois [MOIS] et donne-moi : 1) Performance vs objectif 2) Sources de revenus principales 3) Points d'attention 4) 3 actions prioritaires pour le mois prochain. » Coller les données.",
        "Interpréter et décider — lire l'analyse IA. Prendre 3 décisions actionnables pour le mois suivant. Les noter dans GestiQ sous /vision ou dans les objectifs mensuels.",
        "Partager avec l'équipe — partager le rapport simplifié : « Ce mois : [CA]. Objectif atteint ? [OUI/NON]. Priorité du mois prochain : [ACTION]. »"
      ),
      CO('tip', '🤖 Rappel important', "L'IA est un accélérateur, pas un remplaçant. Toujours vérifier et personnaliser les outputs de l'IA avant de les envoyer à un client. Votre jugement humain reste indispensable."),
    ],
  },
]

/* ── Construction du SQL ────────────────────────────────────────── */
const lines = []
lines.push(`-- ════════════════════════════════════════════════════════════════════`)
lines.push(`--  GestiQ — Migration 026 : Seed des 29 SOPs officiels Next Gital`)
lines.push(`--  Date : 2026-05-16`)
lines.push(`--  Insère le contenu pour TOUS les tenants. Idempotent.`)
lines.push(`-- ════════════════════════════════════════════════════════════════════`)
lines.push(``)
lines.push(`BEGIN;`)
lines.push(``)

function sqlEsc(s) {
  return String(s).replace(/'/g, "''")
}

for (const sop of SOPS) {
  const tagsJson = JSON.stringify(sop.tags)
  const blocksJson = JSON.stringify(sop.blocks)
  lines.push(`-- ── ${sop.slug} (${sop.category}) ────`)
  lines.push(`INSERT INTO public.sops (tenant_id, slug, title, description, category, tags, author, read_min, popular, blocks)`)
  lines.push(`SELECT t.id,`)
  lines.push(`  '${sqlEsc(sop.slug)}',`)
  lines.push(`  '${sqlEsc(sop.title)}',`)
  lines.push(`  '${sqlEsc(sop.description)}',`)
  lines.push(`  '${sqlEsc(sop.category)}',`)
  lines.push(`  '${sqlEsc(tagsJson)}'::jsonb,`)
  lines.push(`  'Next Gital',`)
  lines.push(`  ${sop.read_min},`)
  lines.push(`  ${sop.popular},`)
  lines.push(`  $sop$${blocksJson}$sop$::jsonb`)
  lines.push(`FROM public.tenants t`)
  lines.push(`WHERE NOT EXISTS (SELECT 1 FROM public.sops WHERE tenant_id = t.id AND slug = '${sqlEsc(sop.slug)}');`)
  lines.push(``)
}

lines.push(``)
lines.push(`COMMIT;`)
lines.push(``)
lines.push(`-- Vérification :`)
lines.push(`--   SELECT category, COUNT(*) FROM sops GROUP BY category ORDER BY category;`)
lines.push(`--   Attendu : ${SOPS.length} SOPs × nb_tenants`)

const out = lines.join('\n')
writeFileSync(OUT, out, 'utf8')
console.log(`✓ Generated ${SOPS.length} SOPs → ${OUT}`)
console.log(`  Categories: ${[...new Set(SOPS.map(s => s.category))].join(', ')}`)
