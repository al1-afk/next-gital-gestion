import { useMemo, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  BookOpen, MessageSquare, Zap, Briefcase, UserPlus, Rocket, LifeBuoy,
  Megaphone, HelpCircle, Sparkles, Home, Search, Star, Clock,
  Filter, Plus, ChevronRight, Copy, Share2, Pencil, Download,
  CheckCircle2, ArrowLeft, FileText, Tag as TagIcon, Eye,
  TrendingUp, Bookmark, BookmarkCheck, MoreHorizontal, Users,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input }  from '@/components/ui/input'
import { Badge }  from '@/components/ui/badge'
import { cn } from '@/lib/utils'
import { toast } from 'sonner'

/* ═══════════════════════════════════════════════════════════════════
   TYPES
   ═══════════════════════════════════════════════════════════════════ */
type CategoryKey =
  | 'home' | 'whatsapp' | 'quick' | 'sales' | 'onboarding'
  | 'delivery' | 'support' | 'marketing' | 'faq' | 'ai'

interface Category {
  key:   CategoryKey
  label: string
  icon:  React.ElementType
  color: string
  bg:    string
  desc:  string
}

type BlockType =
  | 'heading' | 'paragraph' | 'list' | 'checklist' | 'steps'
  | 'callout' | 'template' | 'code' | 'divider'

interface SOPBlock {
  type:    BlockType
  text?:   string
  items?:  string[]
  variant?:'info' | 'warning' | 'success' | 'tip'
  title?:  string
}

interface SOP {
  id:        string
  title:     string
  description: string
  category:  CategoryKey
  tags:      string[]
  author:    string
  authorBg:  string
  updatedAt: string
  readMin:   number
  views:     number
  popular?:  boolean
  blocks:    SOPBlock[]
}

/* ═══════════════════════════════════════════════════════════════════
   CATEGORIES
   ═══════════════════════════════════════════════════════════════════ */
const CATEGORIES: Category[] = [
  { key: 'home',       label: 'Accueil SOP',         icon: Home,         color: 'text-blue-600 dark:text-blue-400',       bg: 'bg-blue-50 dark:bg-blue-900/20',       desc: 'Vue d\'ensemble & accès rapide' },
  { key: 'whatsapp',   label: 'Scripts WhatsApp',    icon: MessageSquare,color: 'text-emerald-600 dark:text-emerald-400', bg: 'bg-emerald-50 dark:bg-emerald-900/20', desc: 'Messages prêts pour clients'   },
  { key: 'quick',      label: 'Réponses rapides',    icon: Zap,          color: 'text-amber-600 dark:text-amber-400',     bg: 'bg-amber-50 dark:bg-amber-900/20',     desc: 'Snippets prêts à copier'        },
  { key: 'sales',      label: 'Process Commercial',  icon: Briefcase,    color: 'text-violet-600 dark:text-violet-400',   bg: 'bg-violet-50 dark:bg-violet-900/20',   desc: 'Qualification, closing, devis' },
  { key: 'onboarding', label: 'Onboarding Client',   icon: UserPlus,     color: 'text-cyan-600 dark:text-cyan-400',       bg: 'bg-cyan-50 dark:bg-cyan-900/20',       desc: 'Bienvenue & démarrage'         },
  { key: 'delivery',   label: 'Livraison Projet',    icon: Rocket,       color: 'text-pink-600 dark:text-pink-400',       bg: 'bg-pink-50 dark:bg-pink-900/20',       desc: 'Process de livraison & QA'     },
  { key: 'support',    label: 'Support Client',      icon: LifeBuoy,     color: 'text-red-600 dark:text-red-400',         bg: 'bg-red-50 dark:bg-red-900/20',         desc: 'Réclamations & SAV'            },
  { key: 'marketing',  label: 'Marketing & Ads',     icon: Megaphone,    color: 'text-orange-600 dark:text-orange-400',   bg: 'bg-orange-50 dark:bg-orange-900/20',   desc: 'Campagnes, retargeting, ROI'   },
  { key: 'faq',        label: 'FAQ Interne',         icon: HelpCircle,   color: 'text-teal-600 dark:text-teal-400',       bg: 'bg-teal-50 dark:bg-teal-900/20',       desc: 'Questions fréquentes équipe'   },
  { key: 'ai',         label: 'IA & Automatisation', icon: Sparkles,     color: 'text-purple-600 dark:text-purple-400',   bg: 'bg-purple-50 dark:bg-purple-900/20',   desc: 'Workflows IA & prompts'        },
]

/* ═══════════════════════════════════════════════════════════════════
   SEED DATA — exemples SOP réalistes
   ═══════════════════════════════════════════════════════════════════ */
const SOPS: SOP[] = [
  {
    id: 'wa-welcome',
    title: 'Message d\'accueil WhatsApp',
    description: 'Premier message à envoyer dès qu\'un prospect nous contacte sur WhatsApp.',
    category: 'whatsapp',
    tags: ['WhatsApp', 'Accueil', 'Prospect'],
    author: 'Said',
    authorBg: 'bg-blue-500',
    updatedAt: '2026-05-12',
    readMin: 2,
    views: 412,
    popular: true,
    blocks: [
      { type: 'callout', variant: 'tip', title: 'Quand l\'utiliser', text: 'Dès le 1er contact WhatsApp avec un prospect, dans les 5 minutes maximum. La rapidité de réponse augmente le taux de conversion de +60%.' },
      { type: 'heading', text: 'Template — Premier contact' },
      { type: 'template', text: 'Bonjour {{prenom}} 👋\n\nMerci de nous avoir contactés ! Je suis {{commercial}}, responsable des nouveaux projets chez GestiQ.\n\nPour mieux vous aider, pouvez-vous me dire :\n• Quel type de projet souhaitez-vous lancer ?\n• Avez-vous un délai en tête ?\n• Avez-vous déjà un budget envisagé ?\n\nJe vous prépare une proposition adaptée 🚀' },
      { type: 'heading', text: 'Variables à remplacer' },
      { type: 'list', items: [
        '{{prenom}} — Prénom du prospect (récupéré du formulaire ou demandé)',
        '{{commercial}} — Votre nom (Said, Yassine, etc.)',
      ] },
      { type: 'heading', text: 'Règles d\'or' },
      { type: 'checklist', items: [
        'Toujours répondre en moins de 5 minutes en heures ouvrables',
        'Tutoyer uniquement si le client tutoie en premier',
        'Ne jamais envoyer plus de 3 questions à la fois',
        'Ajouter un emoji pour humaniser, mais pas plus de 2',
      ] },
    ],
  },
  {
    id: 'wa-price-site',
    title: 'Réponse "C\'est combien un site web ?"',
    description: 'La question prix arrive très tôt. Voici comment qualifier sans donner un chiffre au hasard.',
    category: 'whatsapp',
    tags: ['Prix', 'Qualification', 'Site web'],
    author: 'Said',
    authorBg: 'bg-blue-500',
    updatedAt: '2026-05-10',
    readMin: 3,
    views: 587,
    popular: true,
    blocks: [
      { type: 'callout', variant: 'warning', title: 'Ne jamais donner un prix tout de suite', text: 'Un prix donné sans contexte est perdu 8 fois sur 10. Toujours qualifier le besoin avant de citer une fourchette.' },
      { type: 'heading', text: 'Template de réponse' },
      { type: 'template', text: 'Excellente question 👍\n\nLe prix d\'un site dépend de 3 choses :\n\n1️⃣ Le type de site (vitrine, e-commerce, plateforme)\n2️⃣ Le nombre de pages et fonctionnalités\n3️⃣ Si vous avez déjà le contenu (textes, photos, logo)\n\nOn propose des sites à partir de 3 500 MAD pour une vitrine pro, jusqu\'à 25 000 MAD pour de l\'e-commerce avancé.\n\nVoulez-vous qu\'on planifie un appel de 15 min pour que je vous fasse un devis précis ?' },
      { type: 'heading', text: 'Process derrière le message' },
      { type: 'steps', items: [
        'Donner une fourchette claire (rassure et qualifie le budget)',
        'Lister les variables qui influent sur le prix',
        'Proposer un appel court — jamais un devis direct',
        'Créer le devis uniquement après l\'appel de découverte',
      ] },
    ],
  },
  {
    id: 'sales-qualification',
    title: 'Qualification d\'un nouveau client (BANT)',
    description: 'Méthode BANT adaptée : qualifier un prospect en 8 minutes lors du premier appel.',
    category: 'sales',
    tags: ['Qualification', 'BANT', 'Découverte'],
    author: 'Yassine',
    authorBg: 'bg-violet-500',
    updatedAt: '2026-05-08',
    readMin: 5,
    views: 298,
    popular: true,
    blocks: [
      { type: 'paragraph', text: 'BANT = Budget, Autorité, Besoin, Timing. À évaluer dès le premier contact pour ne pas perdre de temps sur des prospects non qualifiés.' },
      { type: 'heading', text: 'Les 4 dimensions' },
      { type: 'steps', items: [
        'BUDGET — "Avez-vous une enveloppe budgétaire prévue pour ce projet ?"',
        'AUTORITÉ — "Êtes-vous le décisionnaire ou faut-il valider avec quelqu\'un ?"',
        'BESOIN — "Quel problème concret ce projet résout-il pour vous ?"',
        'TIMING — "Quand souhaitez-vous démarrer ? Avez-vous une deadline ?"',
      ] },
      { type: 'callout', variant: 'success', title: 'Score idéal pour avancer', text: 'Au moins 3 des 4 dimensions doivent être claires. Sinon, on relance plus tard ou on disqualifie.' },
      { type: 'heading', text: 'Checklist post-appel' },
      { type: 'checklist', items: [
        'Créer la fiche prospect dans le CRM',
        'Tagger avec un niveau de chaleur (chaud / tiède / froid)',
        'Programmer le follow-up dans le calendrier',
        'Si chaud → préparer le devis sous 24h',
      ] },
    ],
  },
  {
    id: 'sales-closing',
    title: 'Scripts de closing — gérer les 5 objections',
    description: 'Les 5 objections classiques en fin de cycle de vente et les réponses qui marchent.',
    category: 'sales',
    tags: ['Closing', 'Objections', 'Vente'],
    author: 'Yassine',
    authorBg: 'bg-violet-500',
    updatedAt: '2026-05-06',
    readMin: 7,
    views: 234,
    blocks: [
      { type: 'heading', text: '1. "C\'est trop cher"' },
      { type: 'template', text: 'Je comprends. Avant de parler prix, dites-moi : si le budget n\'était pas un problème, ce projet vous semble-t-il le bon choix ?\n\n[Si oui] → On peut découper en 2-3 phases pour étaler l\'investissement.\n[Si non] → Quelles sont les vraies réserves ?' },
      { type: 'heading', text: '2. "Je dois en parler à mon associé"' },
      { type: 'template', text: 'Bien sûr. Pour faciliter cette discussion, je vous prépare un PDF clair avec le périmètre, le ROI attendu et les délais. Vous pourrez le partager directement avec votre associé. Quand pensez-vous pouvoir avoir la réponse ?' },
      { type: 'heading', text: '3. "Je vais réfléchir"' },
      { type: 'template', text: 'Tout à fait, c\'est une décision importante. Sur quoi exactement allez-vous réfléchir ? Le périmètre, le prix, le timing ? Je peux peut-être répondre maintenant.' },
      { type: 'heading', text: '4. "Votre concurrent est moins cher"' },
      { type: 'template', text: 'C\'est tout à fait possible. La vraie question est : leur livrable est-il identique au nôtre ? Souhaitez-vous qu\'on compare ligne par ligne ?' },
      { type: 'heading', text: '5. "Envoyez-moi juste un email"' },
      { type: 'template', text: 'Bien sûr. Pour que cet email soit utile et pas générique, donnez-moi 5 minutes maintenant pour comprendre exactement ce qui compte pour vous. Sinon, je risque de vous envoyer une proposition qui ne vous correspond pas.' },
    ],
  },
  {
    id: 'onboarding-client',
    title: 'Onboarding d\'un nouveau client',
    description: 'Process complet J0 → J7 après signature : faire de chaque client un ambassadeur.',
    category: 'onboarding',
    tags: ['Onboarding', 'Welcome', 'Process'],
    author: 'Said',
    authorBg: 'bg-blue-500',
    updatedAt: '2026-05-05',
    readMin: 6,
    views: 178,
    blocks: [
      { type: 'callout', variant: 'info', title: 'Pourquoi c\'est critique', text: 'Les 7 premiers jours déterminent 80% de la perception client. Un onboarding raté = un client qui ne reviendra pas et ne recommandera pas.' },
      { type: 'heading', text: 'J0 — Jour de la signature' },
      { type: 'checklist', items: [
        'Envoyer le message WhatsApp de bienvenue',
        'Créer le dossier client dans Google Drive',
        'Inviter le client sur le portail GestiQ',
        'Programmer la réunion de kickoff dans les 48h',
      ] },
      { type: 'heading', text: 'J+1 → J+3' },
      { type: 'checklist', items: [
        'Réunion de kickoff (visio 45 min)',
        'Envoyer le récap écrit dans les 2h après la réunion',
        'Créer toutes les tâches du projet dans le planificateur',
        'Définir le canal de communication officiel (WhatsApp / Email)',
      ] },
      { type: 'heading', text: 'J+7' },
      { type: 'checklist', items: [
        'Premier livrable intermédiaire (maquette, plan, brief, etc.)',
        'Appel de check-in 15 min',
        'Demander un feedback à chaud',
      ] },
    ],
  },
  {
    id: 'delivery-website',
    title: 'Livraison d\'un site web — Checklist QA',
    description: 'Tous les points à vérifier avant de livrer un site à un client.',
    category: 'delivery',
    tags: ['Livraison', 'QA', 'Site web'],
    author: 'Said',
    authorBg: 'bg-blue-500',
    updatedAt: '2026-05-04',
    readMin: 4,
    views: 156,
    blocks: [
      { type: 'heading', text: 'Performance & SEO' },
      { type: 'checklist', items: [
        'Score Lighthouse ≥ 90 sur Performance',
        'Toutes les images optimisées (WebP, < 200KB)',
        'Meta titles & descriptions sur toutes les pages',
        'Sitemap.xml généré et soumis à Search Console',
        'Favicon présent dans tous les formats',
      ] },
      { type: 'heading', text: 'Responsive' },
      { type: 'checklist', items: [
        'Tester sur iPhone (Safari)',
        'Tester sur Android (Chrome)',
        'Tester sur iPad / tablette',
        'Tester en mode paysage',
      ] },
      { type: 'heading', text: 'Sécurité & Légal' },
      { type: 'checklist', items: [
        'Certificat SSL actif (https://)',
        'Mentions légales conformes',
        'Politique de confidentialité',
        'Bandeau cookies si nécessaire',
      ] },
      { type: 'heading', text: 'Handover client' },
      { type: 'checklist', items: [
        'Vidéo Loom de présentation (5 min max)',
        'Identifiants envoyés via canal sécurisé',
        'Facture finale envoyée',
        'Demande d\'avis Google planifiée',
      ] },
    ],
  },
  {
    id: 'support-complaint',
    title: 'Gestion des réclamations clients',
    description: 'Méthode HEARD pour désamorcer une réclamation et garder le client.',
    category: 'support',
    tags: ['Réclamation', 'Support', 'SAV'],
    author: 'Mehdi',
    authorBg: 'bg-red-500',
    updatedAt: '2026-05-03',
    readMin: 5,
    views: 198,
    blocks: [
      { type: 'callout', variant: 'warning', title: 'Règle d\'or', text: 'JAMAIS répondre dans l\'émotion. Toujours laisser 15 min entre la lecture du message et la réponse.' },
      { type: 'heading', text: 'Méthode HEARD' },
      { type: 'steps', items: [
        'HEAR — Écouter sans interrompre, laisser le client vider son sac',
        'EMPATHIZE — Reconnaître l\'émotion : "Je comprends votre frustration"',
        'APOLOGIZE — S\'excuser même si on n\'est pas en tort à 100%',
        'RESOLVE — Proposer une solution concrète avec un délai clair',
        'DIAGNOSE — Analyser en interne pour éviter que ça se reproduise',
      ] },
      { type: 'heading', text: 'Template de première réponse' },
      { type: 'template', text: 'Bonjour {{prenom}},\n\nMerci d\'avoir pris le temps de nous écrire, et je suis sincèrement désolé pour la gêne occasionnée.\n\nJe prends personnellement votre demande en charge. Voici ce que je fais maintenant :\n1. {{action_immediate}}\n2. Je reviens vers vous avant {{deadline}} avec une solution\n\nMerci pour votre patience, on va vous trouver une solution.\n\n— {{commercial}}' },
    ],
  },
  {
    id: 'marketing-retarget',
    title: 'Stratégie de retargeting Ads',
    description: 'Comment relancer les visiteurs qui n\'ont pas converti via Meta Ads.',
    category: 'marketing',
    tags: ['Ads', 'Retargeting', 'Meta'],
    author: 'Nora',
    authorBg: 'bg-orange-500',
    updatedAt: '2026-05-01',
    readMin: 6,
    views: 142,
    blocks: [
      { type: 'heading', text: 'Audiences à créer' },
      { type: 'list', items: [
        'Visiteurs du site — 30 jours',
        'Engagement Instagram — 60 jours',
        'Vidéo vue à 50% — 30 jours',
        'Ajout au panier sans achat — 14 jours',
      ] },
      { type: 'heading', text: 'Séquence retargeting (4 étapes)' },
      { type: 'steps', items: [
        'Jour 1-3 → Témoignage client (preuve sociale)',
        'Jour 4-7 → Bénéfice clé du produit (vidéo courte)',
        'Jour 8-14 → Offre avec urgence (-15%, places limitées)',
        'Jour 15+ → Dernière chance (témoignage + offre)',
      ] },
      { type: 'callout', variant: 'tip', title: 'Budget recommandé', text: 'Allouer 20% du budget total au retargeting. ROAS attendu : 4x à 8x selon le secteur.' },
    ],
  },
  {
    id: 'support-tech',
    title: 'Support technique — Niveau 1',
    description: 'Premier diagnostic à faire avant d\'escalader un ticket technique.',
    category: 'support',
    tags: ['Support', 'Technique', 'Diagnostic'],
    author: 'Mehdi',
    authorBg: 'bg-red-500',
    updatedAt: '2026-04-28',
    readMin: 4,
    views: 87,
    blocks: [
      { type: 'heading', text: 'Diagnostic en 3 questions' },
      { type: 'steps', items: [
        'Quand est-ce que ça a commencé ? (date + heure si possible)',
        'Avez-vous changé quelque chose récemment ? (mot de passe, navigateur, appareil)',
        'Ça arrive sur un seul appareil ou plusieurs ?',
      ] },
      { type: 'heading', text: 'Tests à demander au client' },
      { type: 'checklist', items: [
        'Vider le cache du navigateur (Cmd+Shift+R)',
        'Essayer en navigation privée',
        'Tester sur un autre navigateur (Chrome, Firefox)',
        'Tester sur un autre appareil',
        'Envoyer une capture d\'écran de l\'erreur',
      ] },
      { type: 'callout', variant: 'info', title: 'Quand escalader', text: 'Si le problème persiste après les 5 tests, créer un ticket dev avec capture + URL + navigateur.' },
    ],
  },
  {
    id: 'ai-prompts-crm',
    title: 'Prompts IA pour le CRM',
    description: 'Templates de prompts pour utiliser le Conseiller IA efficacement.',
    category: 'ai',
    tags: ['IA', 'Prompts', 'CRM'],
    author: 'Said',
    authorBg: 'bg-blue-500',
    updatedAt: '2026-04-25',
    readMin: 3,
    views: 124,
    blocks: [
      { type: 'heading', text: 'Analyse client' },
      { type: 'code', text: 'Analyse le profil du client {{client}} : montre-moi son CA total, ses derniers achats, son niveau d\'engagement et propose 3 actions pour le fidéliser.' },
      { type: 'heading', text: 'Relance automatique' },
      { type: 'code', text: 'Liste tous les devis en attente depuis plus de 7 jours. Pour chacun, propose un message de relance personnalisé en fonction du montant et du contexte.' },
      { type: 'heading', text: 'Diagnostic financier' },
      { type: 'code', text: 'Compare le CA des 30 derniers jours vs les 30 jours précédents. Identifie les 3 plus gros écarts et explique-moi à quoi c\'est dû.' },
    ],
  },
  {
    id: 'faq-team',
    title: 'FAQ Interne — Équipe',
    description: 'Réponses aux questions fréquentes des nouveaux arrivants.',
    category: 'faq',
    tags: ['FAQ', 'Équipe', 'Onboarding'],
    author: 'Said',
    authorBg: 'bg-blue-500',
    updatedAt: '2026-04-22',
    readMin: 4,
    views: 92,
    blocks: [
      { type: 'heading', text: 'Combien de temps pour répondre à un prospect ?' },
      { type: 'paragraph', text: 'Maximum 5 minutes en heures ouvrables (9h-19h). En dehors, le bot envoie une réponse automatique et tu rappelles le lendemain avant 10h.' },
      { type: 'heading', text: 'Où je trouve les templates de devis ?' },
      { type: 'paragraph', text: 'Module Devis → bouton "+ Nouveau" → choisir un template dans le sélecteur. Si le template manque, ping Said dans #produits.' },
      { type: 'heading', text: 'Quand on facture un acompte ?' },
      { type: 'paragraph', text: 'Toujours 30% à la signature pour les projets > 10 000 MAD. 50% pour les projets > 30 000 MAD. Solde à la livraison.' },
      { type: 'heading', text: 'Qui valide les remises ?' },
      { type: 'paragraph', text: '< 10% → le commercial peut décider seul. 10-20% → validation Yassine. > 20% → validation Said uniquement.' },
    ],
  },
  {
    id: 'quick-thanks',
    title: 'Réponse rapide — Remerciement après paiement',
    description: 'Message court à envoyer dès qu\'un paiement est confirmé.',
    category: 'quick',
    tags: ['Paiement', 'Remerciement'],
    author: 'Said',
    authorBg: 'bg-blue-500',
    updatedAt: '2026-04-20',
    readMin: 1,
    views: 56,
    blocks: [
      { type: 'template', text: 'Bonjour {{prenom}} 🙏\n\nPaiement bien reçu, merci pour votre confiance.\n\nOn enchaîne sur la suite, je vous tiens informé(e) à chaque étape.\n\nBonne journée !' },
    ],
  },
]

/* ═══════════════════════════════════════════════════════════════════
   STORAGE — favoris persistés localement
   ═══════════════════════════════════════════════════════════════════ */
const FAV_KEY = 'sop-favorites'
function loadFavs(): string[] {
  try { return JSON.parse(localStorage.getItem(FAV_KEY) || '[]') } catch { return [] }
}
function saveFavs(ids: string[]) {
  try { localStorage.setItem(FAV_KEY, JSON.stringify(ids)) } catch {}
}

/* ═══════════════════════════════════════════════════════════════════
   PAGE
   ═══════════════════════════════════════════════════════════════════ */
export default function SOPPage() {
  const [activeCat,  setActiveCat]  = useState<CategoryKey>('home')
  const [query,      setQuery]      = useState('')
  const [openId,     setOpenId]     = useState<string | null>(null)
  const [favs,       setFavs]       = useState<string[]>(loadFavs)
  const [activeTag,  setActiveTag]  = useState<string | null>(null)
  const [onlyFavs,   setOnlyFavs]   = useState(false)

  const toggleFav = (id: string) => {
    setFavs(prev => {
      const next = prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id]
      saveFavs(next)
      return next
    })
  }

  /* ── Filtres ── */
  const filtered = useMemo(() => {
    let list = SOPS
    if (activeCat !== 'home') list = list.filter(s => s.category === activeCat)
    if (onlyFavs) list = list.filter(s => favs.includes(s.id))
    if (activeTag) list = list.filter(s => s.tags.includes(activeTag))
    if (query.trim()) {
      const q = query.toLowerCase()
      list = list.filter(s =>
        s.title.toLowerCase().includes(q) ||
        s.description.toLowerCase().includes(q) ||
        s.tags.some(t => t.toLowerCase().includes(q))
      )
    }
    return list
  }, [activeCat, query, favs, onlyFavs, activeTag])

  const allTags = useMemo(() => {
    const set = new Set<string>()
    SOPS.forEach(s => s.tags.forEach(t => set.add(t)))
    return Array.from(set)
  }, [])

  const openedSOP = openId ? SOPS.find(s => s.id === openId) : null

  /* ═══ Page header ═══ */
  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title flex items-center gap-2">
            <BookOpen className="w-6 h-6 text-blue-500" />
            SOP & Procédures Internes
          </h1>
          <p className="page-sub">
            Centralisez les méthodes de travail, scripts et templates de votre équipe
          </p>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="secondary" size="sm">
            <Download className="w-3.5 h-3.5" /> Exporter
          </Button>
          <Button size="sm" onClick={() => toast.success('Bientôt : création de SOP')}>
            <Plus className="w-3.5 h-3.5" /> Nouveau SOP
          </Button>
        </div>
      </div>

      {/* ═══ Hero search + KPIs ═══ */}
      {!openedSOP && (
        <div className="card-premium p-5">
          <div className="relative">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground pointer-events-none" />
            <Input
              value={query}
              onChange={e => setQuery(e.target.value)}
              placeholder="Rechercher un SOP, un script, un template..."
              className="pl-12 h-12 text-[15px] rounded-xl"
            />
            {query && (
              <button
                onClick={() => setQuery('')}
                className="absolute right-4 top-1/2 -translate-y-1/2 text-xs text-muted-foreground hover:text-foreground"
              >
                Effacer
              </button>
            )}
          </div>

          {/* Mini-stats sous la search */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mt-4">
            <MiniStat icon={FileText}   label="SOP totaux"   value={SOPS.length} className="kpi-blue text-[var(--pastel-blue-txt)]" />
            <MiniStat icon={Star}       label="Favoris"      value={favs.length} className="kpi-orange text-[var(--pastel-orange-txt)]" />
            <MiniStat icon={TrendingUp} label="Populaires"   value={SOPS.filter(s => s.popular).length} className="kpi-green text-[var(--pastel-green-txt)]" />
            <MiniStat icon={Users}      label="Catégories"   value={CATEGORIES.length - 1} className="kpi-purple text-[var(--pastel-purple-txt)]" />
          </div>
        </div>
      )}

      {/* ═══ Body : sidebar SOP + content ═══ */}
      <div className="grid grid-cols-1 lg:grid-cols-[260px_1fr] gap-6 items-start">

        {/* ── Sidebar interne des catégories ── */}
        <aside className="card-premium p-3 lg:sticky lg:top-4">
          <div className="flex items-center justify-between px-2 py-1 mb-2">
            <p className="text-[10px] font-bold uppercase tracking-[0.12em] text-muted-foreground">
              Catégories
            </p>
            <span className="text-[10px] text-muted-foreground">{SOPS.length}</span>
          </div>
          <nav className="space-y-0.5">
            {CATEGORIES.map(cat => {
              const count = cat.key === 'home'
                ? SOPS.length
                : SOPS.filter(s => s.category === cat.key).length
              const active = activeCat === cat.key
              return (
                <button
                  key={cat.key}
                  onClick={() => { setActiveCat(cat.key); setOpenId(null); setOnlyFavs(false); setActiveTag(null) }}
                  className={cn(
                    'w-full flex items-center gap-2.5 px-2.5 py-2 rounded-lg text-[13px] font-medium transition-all duration-150',
                    active
                      ? 'bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-md shadow-blue-500/30'
                      : 'text-muted-foreground hover:bg-muted/60 hover:text-foreground'
                  )}
                >
                  <div className={cn(
                    'w-7 h-7 rounded-lg flex items-center justify-center flex-shrink-0',
                    active ? 'bg-white/15' : cat.bg
                  )}>
                    <cat.icon className={cn('w-3.5 h-3.5', active ? 'text-white' : cat.color)} />
                  </div>
                  <span className="flex-1 truncate text-left">{cat.label}</span>
                  <span className={cn(
                    'text-[10px] font-bold px-1.5 py-0.5 rounded-md',
                    active ? 'bg-white/20 text-white' : 'bg-muted text-muted-foreground'
                  )}>
                    {count}
                  </span>
                </button>
              )
            })}
          </nav>

          {/* Toggle favoris */}
          <div className="border-t border-border mt-3 pt-3 px-2 space-y-1">
            <button
              onClick={() => { setOnlyFavs(v => !v); setOpenId(null) }}
              className={cn(
                'w-full flex items-center gap-2 px-2 py-2 rounded-lg text-[13px] font-medium transition-all',
                onlyFavs ? 'bg-amber-50 dark:bg-amber-900/20 text-amber-700 dark:text-amber-300' : 'text-muted-foreground hover:bg-muted/60'
              )}
            >
              <Star className={cn('w-3.5 h-3.5', onlyFavs && 'fill-amber-500 text-amber-500')} />
              Favoris uniquement
              <span className="ml-auto text-[10px] bg-muted px-1.5 py-0.5 rounded-md">{favs.length}</span>
            </button>
          </div>
        </aside>

        {/* ── Main content ── */}
        <main className="min-w-0">
          <AnimatePresence mode="wait">
            {openedSOP ? (
              <motion.div
                key="detail"
                initial={{ opacity: 0, x: 12 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -12 }}
                transition={{ duration: 0.18 }}
              >
                <SOPDetail
                  sop={openedSOP}
                  isFav={favs.includes(openedSOP.id)}
                  onClose={() => setOpenId(null)}
                  onToggleFav={() => toggleFav(openedSOP.id)}
                />
              </motion.div>
            ) : (
              <motion.div
                key="list"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.18 }}
                className="space-y-6"
              >
                {/* Tags chips */}
                {activeCat === 'home' && !query && (
                  <div className="card-premium p-4">
                    <div className="flex items-center gap-2 mb-3">
                      <TagIcon className="w-3.5 h-3.5 text-muted-foreground" />
                      <p className="text-xs font-semibold text-muted-foreground uppercase tracking-wide">Tags populaires</p>
                    </div>
                    <div className="flex flex-wrap gap-1.5">
                      {allTags.slice(0, 14).map(tag => (
                        <button
                          key={tag}
                          onClick={() => setActiveTag(t => t === tag ? null : tag)}
                          className={cn(
                            'px-2.5 py-1 rounded-full text-xs font-medium border transition-all',
                            activeTag === tag
                              ? 'bg-blue-600 border-blue-600 text-white'
                              : 'bg-muted/50 border-border text-muted-foreground hover:border-blue-400 hover:text-blue-600'
                          )}
                        >
                          #{tag}
                        </button>
                      ))}
                    </div>
                  </div>
                )}

                {/* Quick categories grid (home only, no query) */}
                {activeCat === 'home' && !query && !onlyFavs && !activeTag && (
                  <section>
                    <div className="flex items-center justify-between mb-3">
                      <h2 className="section-title">Catégories</h2>
                      <span className="text-xs text-muted-foreground">Sélectionnez pour filtrer</span>
                    </div>
                    <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
                      {CATEGORIES.filter(c => c.key !== 'home').map((cat, i) => {
                        const count = SOPS.filter(s => s.category === cat.key).length
                        return (
                          <motion.button
                            key={cat.key}
                            initial={{ opacity: 0, y: 8 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: i * 0.04 }}
                            onClick={() => setActiveCat(cat.key)}
                            className="card-premium p-4 text-left group cursor-pointer"
                          >
                            <div className={cn('w-10 h-10 rounded-xl flex items-center justify-center mb-3', cat.bg)}>
                              <cat.icon className={cn('w-5 h-5', cat.color)} />
                            </div>
                            <p className="font-semibold text-sm text-foreground group-hover:text-blue-600 transition-colors">
                              {cat.label}
                            </p>
                            <p className="text-[11px] text-muted-foreground mt-0.5 line-clamp-1">{cat.desc}</p>
                            <div className="flex items-center justify-between mt-3 pt-3 border-t border-border/50">
                              <span className="text-[11px] font-semibold text-muted-foreground">{count} SOP</span>
                              <ChevronRight className="w-3.5 h-3.5 text-muted-foreground group-hover:text-blue-500 group-hover:translate-x-0.5 transition-all" />
                            </div>
                          </motion.button>
                        )
                      })}
                    </div>
                  </section>
                )}

                {/* Populaires (home only) */}
                {activeCat === 'home' && !query && !onlyFavs && !activeTag && (
                  <section>
                    <div className="flex items-center justify-between mb-3">
                      <h2 className="section-title flex items-center gap-1.5">
                        <TrendingUp className="w-4 h-4 text-emerald-500" />
                        SOP populaires
                      </h2>
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3">
                      {SOPS.filter(s => s.popular).slice(0, 6).map((sop, i) => (
                        <SOPCard
                          key={sop.id}
                          sop={sop}
                          isFav={favs.includes(sop.id)}
                          onOpen={() => setOpenId(sop.id)}
                          onToggleFav={() => toggleFav(sop.id)}
                          delay={i * 0.04}
                        />
                      ))}
                    </div>
                  </section>
                )}

                {/* Documents récents (home only) */}
                {activeCat === 'home' && !query && !onlyFavs && !activeTag && (
                  <section>
                    <div className="flex items-center justify-between mb-3">
                      <h2 className="section-title flex items-center gap-1.5">
                        <Clock className="w-4 h-4 text-blue-500" />
                        Récemment modifiés
                      </h2>
                    </div>
                    <div className="card-premium divide-y divide-border/50">
                      {[...SOPS].sort((a, b) => b.updatedAt.localeCompare(a.updatedAt)).slice(0, 5).map(sop => {
                        const cat = CATEGORIES.find(c => c.key === sop.category)!
                        return (
                          <button
                            key={sop.id}
                            onClick={() => setOpenId(sop.id)}
                            className="w-full flex items-center gap-4 px-4 py-3 hover:bg-muted/20 transition-colors text-left"
                          >
                            <div className={cn('w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0', cat.bg)}>
                              <cat.icon className={cn('w-4 h-4', cat.color)} />
                            </div>
                            <div className="flex-1 min-w-0">
                              <p className="font-medium text-sm text-foreground truncate">{sop.title}</p>
                              <p className="text-xs text-muted-foreground truncate">{sop.description}</p>
                            </div>
                            <div className="hidden md:flex items-center gap-3 text-xs text-muted-foreground flex-shrink-0">
                              <span className="flex items-center gap-1">
                                <Clock className="w-3 h-3" />
                                {sop.readMin} min
                              </span>
                              <span>{sop.updatedAt}</span>
                            </div>
                            <ChevronRight className="w-4 h-4 text-muted-foreground" />
                          </button>
                        )
                      })}
                    </div>
                  </section>
                )}

                {/* Liste filtrée (catégorie / recherche / favoris / tag) */}
                {(activeCat !== 'home' || query || onlyFavs || activeTag) && (
                  <section>
                    <div className="flex items-center justify-between mb-3 flex-wrap gap-2">
                      <div className="flex items-center gap-2 flex-wrap">
                        <h2 className="section-title">
                          {query ? `Recherche : "${query}"`
                            : onlyFavs ? 'Mes favoris'
                            : activeTag ? `Tag : #${activeTag}`
                            : CATEGORIES.find(c => c.key === activeCat)?.label}
                        </h2>
                        <Badge variant="secondary" size="sm">{filtered.length} SOP</Badge>
                        {activeTag && (
                          <button
                            onClick={() => setActiveTag(null)}
                            className="text-xs text-muted-foreground hover:text-foreground"
                          >
                            Effacer le tag
                          </button>
                        )}
                      </div>
                      <Button variant="ghost" size="sm" onClick={() => { setQuery(''); setActiveTag(null); setOnlyFavs(false); setActiveCat('home') }}>
                        <Filter className="w-3.5 h-3.5" /> Réinitialiser
                      </Button>
                    </div>

                    {filtered.length === 0 ? (
                      <div className="card-premium empty-state">
                        <BookOpen className="empty-state-icon" />
                        <p className="empty-state-title">Aucun SOP trouvé</p>
                        <p className="empty-state-desc">Essayez un autre mot-clé ou parcourez les catégories.</p>
                      </div>
                    ) : (
                      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3">
                        {filtered.map((sop, i) => (
                          <SOPCard
                            key={sop.id}
                            sop={sop}
                            isFav={favs.includes(sop.id)}
                            onOpen={() => setOpenId(sop.id)}
                            onToggleFav={() => toggleFav(sop.id)}
                            delay={i * 0.04}
                          />
                        ))}
                      </div>
                    )}
                  </section>
                )}
              </motion.div>
            )}
          </AnimatePresence>
        </main>
      </div>
    </div>
  )
}

/* ═══════════════════════════════════════════════════════════════════
   MINI-STAT
   ═══════════════════════════════════════════════════════════════════ */
function MiniStat({ icon: Icon, label, value, className }: {
  icon: React.ElementType; label: string; value: number; className: string
}) {
  return (
    <div className={cn('rounded-2xl p-3 flex items-center gap-3', className)}>
      <div className="w-9 h-9 rounded-lg bg-white/60 dark:bg-white/10 flex items-center justify-center flex-shrink-0">
        <Icon className="w-4 h-4" />
      </div>
      <div className="min-w-0">
        <p className="text-lg font-bold leading-none">{value}</p>
        <p className="text-[11px] font-medium opacity-80 mt-1">{label}</p>
      </div>
    </div>
  )
}

/* ═══════════════════════════════════════════════════════════════════
   SOP CARD
   ═══════════════════════════════════════════════════════════════════ */
function SOPCard({ sop, isFav, onOpen, onToggleFav, delay = 0 }: {
  sop: SOP; isFav: boolean; onOpen: () => void; onToggleFav: () => void; delay?: number
}) {
  const cat = CATEGORIES.find(c => c.key === sop.category)!
  return (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay }}
      onClick={onOpen}
      className="card-premium p-4 cursor-pointer group flex flex-col"
    >
      <div className="flex items-start justify-between gap-2 mb-3">
        <div className={cn('w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0', cat.bg)}>
          <cat.icon className={cn('w-5 h-5', cat.color)} />
        </div>
        <div className="flex items-center gap-1">
          {sop.popular && (
            <span className="px-1.5 py-0.5 rounded-md text-[9px] font-bold bg-emerald-50 dark:bg-emerald-900/20 text-emerald-600 dark:text-emerald-400 border border-emerald-200 dark:border-emerald-800/50">
              POPULAIRE
            </span>
          )}
          <button
            onClick={(e) => { e.stopPropagation(); onToggleFav() }}
            className={cn(
              'p-1.5 rounded-lg transition-colors',
              isFav ? 'text-amber-500 hover:bg-amber-50 dark:hover:bg-amber-900/20' : 'text-muted-foreground hover:text-amber-500 hover:bg-amber-50 dark:hover:bg-amber-900/20'
            )}
          >
            {isFav ? <BookmarkCheck className="w-3.5 h-3.5 fill-amber-500" /> : <Bookmark className="w-3.5 h-3.5" />}
          </button>
        </div>
      </div>

      <p className="font-semibold text-sm text-foreground group-hover:text-blue-600 transition-colors line-clamp-2 leading-snug">
        {sop.title}
      </p>
      <p className="text-xs text-muted-foreground mt-1 line-clamp-2 flex-1">
        {sop.description}
      </p>

      <div className="flex items-center gap-1.5 mt-3 flex-wrap">
        {sop.tags.slice(0, 2).map(tag => (
          <span key={tag} className="text-[10px] px-1.5 py-0.5 rounded-md bg-muted text-muted-foreground font-medium">
            #{tag}
          </span>
        ))}
        {sop.tags.length > 2 && (
          <span className="text-[10px] text-muted-foreground">+{sop.tags.length - 2}</span>
        )}
      </div>

      <div className="flex items-center justify-between mt-3 pt-3 border-t border-border/50 text-[11px] text-muted-foreground">
        <div className="flex items-center gap-1">
          <div className={cn('w-5 h-5 rounded-full flex items-center justify-center text-white text-[9px] font-bold', sop.authorBg)}>
            {sop.author[0]}
          </div>
          <span className="truncate">{sop.author}</span>
        </div>
        <div className="flex items-center gap-2">
          <span className="flex items-center gap-1"><Clock className="w-3 h-3" /> {sop.readMin}m</span>
          <span className="flex items-center gap-1"><Eye className="w-3 h-3" /> {sop.views}</span>
        </div>
      </div>
    </motion.div>
  )
}

/* ═══════════════════════════════════════════════════════════════════
   SOP DETAIL (Notion-like)
   ═══════════════════════════════════════════════════════════════════ */
function SOPDetail({ sop, isFav, onClose, onToggleFav }: {
  sop: SOP; isFav: boolean; onClose: () => void; onToggleFav: () => void
}) {
  const cat = CATEGORIES.find(c => c.key === sop.category)!
  const [checked, setChecked] = useState<Record<string, boolean>>({})

  const toggleCheck = (key: string) =>
    setChecked(p => ({ ...p, [key]: !p[key] }))

  const handleCopy = (text: string) => {
    navigator.clipboard.writeText(text).then(() => toast.success('Copié dans le presse-papier'))
  }

  return (
    <div className="space-y-4">
      {/* ── Breadcrumb + actions ── */}
      <div className="flex items-center justify-between flex-wrap gap-2">
        <button
          onClick={onClose}
          className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Retour</span>
          <ChevronRight className="w-3 h-3" />
          <span className={cn('font-medium', cat.color)}>{cat.label}</span>
        </button>
        <div className="flex items-center gap-1.5">
          <Button variant="ghost" size="sm" onClick={onToggleFav}>
            {isFav
              ? <BookmarkCheck className="w-3.5 h-3.5 fill-amber-500 text-amber-500" />
              : <Bookmark className="w-3.5 h-3.5" />}
            {isFav ? 'Favori' : 'Ajouter aux favoris'}
          </Button>
          <Button variant="ghost" size="sm" onClick={() => toast.success('Lien copié')}>
            <Share2 className="w-3.5 h-3.5" /> Partager
          </Button>
          <Button variant="ghost" size="sm" onClick={() => toast.success('Bientôt : export PDF')}>
            <Download className="w-3.5 h-3.5" /> PDF
          </Button>
          <Button variant="secondary" size="sm" onClick={() => toast.success('Bientôt : édition')}>
            <Pencil className="w-3.5 h-3.5" /> Modifier
          </Button>
        </div>
      </div>

      {/* ── Header ── */}
      <div className="card-premium p-6 md:p-8">
        <div className="flex items-start gap-4">
          <div className={cn('w-14 h-14 rounded-2xl flex items-center justify-center flex-shrink-0', cat.bg)}>
            <cat.icon className={cn('w-7 h-7', cat.color)} />
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-2 flex-wrap">
              <Badge variant="default" size="sm">{cat.label}</Badge>
              {sop.popular && <Badge variant="success" size="sm">Populaire</Badge>}
            </div>
            <h1 className="text-[24px] md:text-[28px] font-extrabold text-foreground leading-tight tracking-tight">
              {sop.title}
            </h1>
            <p className="text-sm text-muted-foreground mt-2">{sop.description}</p>

            <div className="flex items-center gap-5 mt-4 flex-wrap text-xs text-muted-foreground">
              <div className="flex items-center gap-1.5">
                <div className={cn('w-6 h-6 rounded-full flex items-center justify-center text-white text-[10px] font-bold', sop.authorBg)}>
                  {sop.author[0]}
                </div>
                <span className="font-medium text-foreground">{sop.author}</span>
              </div>
              <span className="flex items-center gap-1"><Clock className="w-3.5 h-3.5" /> {sop.readMin} min de lecture</span>
              <span className="flex items-center gap-1"><Eye className="w-3.5 h-3.5" /> {sop.views} vues</span>
              <span>Mis à jour le {sop.updatedAt}</span>
            </div>

            <div className="flex items-center gap-1.5 mt-3 flex-wrap">
              {sop.tags.map(tag => (
                <span key={tag} className="text-[11px] px-2 py-0.5 rounded-md bg-muted text-muted-foreground font-medium">
                  #{tag}
                </span>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* ── Content blocks ── */}
      <div className="card-premium p-6 md:p-10 space-y-4">
        {sop.blocks.map((block, i) => (
          <BlockRenderer
            key={i}
            block={block}
            blockKey={`${sop.id}-${i}`}
            checked={checked}
            onCheck={toggleCheck}
            onCopy={handleCopy}
          />
        ))}
      </div>

      {/* ── Footer ── */}
      <div className="card-premium p-4 flex items-center justify-between flex-wrap gap-3">
        <div className="flex items-center gap-2 text-xs text-muted-foreground">
          <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500" />
          Procédure validée par l'équipe — version du {sop.updatedAt}
        </div>
        <div className="flex items-center gap-2">
          <Button variant="ghost" size="sm" onClick={() => toast.success('SOP dupliqué')}>
            <Copy className="w-3.5 h-3.5" /> Dupliquer
          </Button>
          <Button variant="ghost" size="sm">
            <MoreHorizontal className="w-3.5 h-3.5" />
          </Button>
        </div>
      </div>
    </div>
  )
}

/* ═══════════════════════════════════════════════════════════════════
   BLOCK RENDERER — Notion-style
   ═══════════════════════════════════════════════════════════════════ */
function BlockRenderer({ block, blockKey, checked, onCheck, onCopy }: {
  block:    SOPBlock
  blockKey: string
  checked:  Record<string, boolean>
  onCheck:  (key: string) => void
  onCopy:   (text: string) => void
}) {
  switch (block.type) {
    case 'heading':
      return (
        <h2 className="text-lg font-bold text-foreground mt-4 mb-2 tracking-tight">
          {block.text}
        </h2>
      )

    case 'paragraph':
      return (
        <p className="text-[15px] text-foreground/85 leading-relaxed whitespace-pre-line">
          {block.text}
        </p>
      )

    case 'list':
      return (
        <ul className="space-y-1.5">
          {block.items?.map((item, i) => (
            <li key={i} className="flex items-start gap-2.5 text-[15px] text-foreground/85">
              <span className="w-1.5 h-1.5 rounded-full bg-blue-500 mt-2 flex-shrink-0" />
              <span className="flex-1">{item}</span>
            </li>
          ))}
        </ul>
      )

    case 'checklist':
      return (
        <ul className="space-y-2">
          {block.items?.map((item, i) => {
            const key = `${blockKey}-${i}`
            const isChecked = checked[key]
            return (
              <li
                key={i}
                onClick={() => onCheck(key)}
                className="flex items-start gap-3 cursor-pointer group"
              >
                <span className={cn(
                  'w-5 h-5 rounded-md border-2 flex items-center justify-center flex-shrink-0 mt-0.5 transition-all',
                  isChecked
                    ? 'bg-emerald-500 border-emerald-500'
                    : 'border-border group-hover:border-emerald-400'
                )}>
                  {isChecked && <CheckCircle2 className="w-3 h-3 text-white" strokeWidth={3} />}
                </span>
                <span className={cn(
                  'text-[15px] transition-all',
                  isChecked ? 'text-muted-foreground line-through' : 'text-foreground/85'
                )}>
                  {item}
                </span>
              </li>
            )
          })}
        </ul>
      )

    case 'steps':
      return (
        <ol className="space-y-3">
          {block.items?.map((item, i) => (
            <li key={i} className="flex items-start gap-3">
              <span className="w-7 h-7 rounded-full bg-gradient-to-br from-blue-600 to-indigo-600 text-white text-xs font-bold flex items-center justify-center flex-shrink-0 shadow-md shadow-blue-500/20">
                {i + 1}
              </span>
              <span className="text-[15px] text-foreground/85 leading-relaxed pt-0.5 flex-1">
                {item}
              </span>
            </li>
          ))}
        </ol>
      )

    case 'callout': {
      const variants = {
        info:    { bg: 'bg-blue-50 dark:bg-blue-900/20',       border: 'border-blue-200 dark:border-blue-800/50',     icon: 'text-blue-500',    iconBg: 'bg-blue-100 dark:bg-blue-900/40' },
        warning: { bg: 'bg-amber-50 dark:bg-amber-900/20',     border: 'border-amber-200 dark:border-amber-800/50',   icon: 'text-amber-500',   iconBg: 'bg-amber-100 dark:bg-amber-900/40' },
        success: { bg: 'bg-emerald-50 dark:bg-emerald-900/20', border: 'border-emerald-200 dark:border-emerald-800/50', icon: 'text-emerald-500', iconBg: 'bg-emerald-100 dark:bg-emerald-900/40' },
        tip:     { bg: 'bg-violet-50 dark:bg-violet-900/20',   border: 'border-violet-200 dark:border-violet-800/50', icon: 'text-violet-500',  iconBg: 'bg-violet-100 dark:bg-violet-900/40' },
      }
      const v = variants[block.variant || 'info']
      return (
        <div className={cn('rounded-2xl border p-4 flex gap-3', v.bg, v.border)}>
          <div className={cn('w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0', v.iconBg)}>
            <Sparkles className={cn('w-4 h-4', v.icon)} />
          </div>
          <div className="flex-1 min-w-0">
            {block.title && <p className="font-semibold text-sm text-foreground mb-1">{block.title}</p>}
            <p className="text-sm text-foreground/80 leading-relaxed whitespace-pre-line">{block.text}</p>
          </div>
        </div>
      )
    }

    case 'template':
      return (
        <div className="rounded-2xl border border-border bg-muted/30 dark:bg-muted/10 overflow-hidden group">
          <div className="flex items-center justify-between px-4 py-2 border-b border-border bg-muted/40">
            <div className="flex items-center gap-2">
              <MessageSquare className="w-3.5 h-3.5 text-emerald-500" />
              <span className="text-xs font-semibold text-foreground">Template message</span>
            </div>
            <button
              onClick={() => onCopy(block.text || '')}
              className="flex items-center gap-1 text-xs text-muted-foreground hover:text-blue-500 transition-colors"
            >
              <Copy className="w-3 h-3" /> Copier
            </button>
          </div>
          <pre className="p-4 text-[13px] text-foreground/90 whitespace-pre-wrap font-sans leading-relaxed">
            {block.text}
          </pre>
        </div>
      )

    case 'code':
      return (
        <div className="rounded-2xl bg-slate-900 dark:bg-slate-950 overflow-hidden">
          <div className="flex items-center justify-between px-4 py-2 border-b border-slate-800">
            <span className="text-[11px] font-mono text-slate-400">prompt</span>
            <button
              onClick={() => onCopy(block.text || '')}
              className="flex items-center gap-1 text-xs text-slate-400 hover:text-white transition-colors"
            >
              <Copy className="w-3 h-3" /> Copier
            </button>
          </div>
          <pre className="p-4 text-[13px] text-slate-200 whitespace-pre-wrap font-mono leading-relaxed">
            {block.text}
          </pre>
        </div>
      )

    case 'divider':
      return <hr className="border-t border-border/60 my-4" />

    default:
      return null
  }
}
