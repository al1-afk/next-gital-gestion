/**
 * Shared catalogue of SOP categories used in:
 *  - /my-space  (member sees only categories in their access list)
 *  - /equipe    (admin selects categories when inviting a member)
 *  - /sop       (the main SOP browser already has its own list, mirror it here)
 */
import {
  MessageSquare, Zap, Briefcase, UserPlus, Rocket, LifeBuoy, Megaphone,
  HelpCircle, Sparkles, FolderKanban, Code2, UserSearch, Palette, HandCoins, AtSign,
  type LucideIcon,
} from 'lucide-react'

export type SopCategoryKey =
  | 'whatsapp' | 'quick' | 'sales' | 'onboarding' | 'delivery' | 'support'
  | 'marketing' | 'faq' | 'ai' | 'projets' | 'dev' | 'media_buyer'
  | 'prospection' | 'designer' | 'commercial' | 'community_manager'

export interface SopCategoryMeta {
  key:   SopCategoryKey
  label: string
  icon:  LucideIcon
  emoji: string
  bg:    string
  text:  string
  desc:  string
}

export const SOP_CATEGORIES: SopCategoryMeta[] = [
  { key: 'projets',           label: 'Chef de projet',     icon: FolderKanban, emoji: '📋', bg: 'bg-violet-100 dark:bg-violet-900/30',   text: 'text-violet-700 dark:text-violet-300', desc: 'Ouverture, suivi, livraison, KPIs' },
  { key: 'dev',               label: 'Développeur',        icon: Code2,        emoji: '👨‍💻', bg: 'bg-sky-100 dark:bg-sky-900/30',         text: 'text-sky-700 dark:text-sky-300',       desc: 'WordPress, Dokploy, Titan, IA' },
  { key: 'media_buyer',       label: 'Media Buyer',        icon: Megaphone,    emoji: '📣', bg: 'bg-amber-100 dark:bg-amber-900/30',     text: 'text-amber-700 dark:text-amber-300',   desc: 'FB, TikTok, Google Ads, GMB' },
  { key: 'prospection',       label: 'Prospection',        icon: UserSearch,   emoji: '🎯', bg: 'bg-teal-100 dark:bg-teal-900/30',       text: 'text-teal-700 dark:text-teal-300',     desc: 'LinkedIn, WhatsApp, terrain' },
  { key: 'designer',          label: 'Designer',           icon: Palette,      emoji: '🎨', bg: 'bg-rose-100 dark:bg-rose-900/30',       text: 'text-rose-700 dark:text-rose-300',     desc: 'Canva, Figma, charte, visuels' },
  { key: 'commercial',        label: 'Commercial',         icon: HandCoins,    emoji: '🤝', bg: 'bg-green-100 dark:bg-green-900/30',     text: 'text-green-700 dark:text-green-300',   desc: 'Réunion, closing, devis' },
  { key: 'community_manager', label: 'Community Manager',  icon: AtSign,       emoji: '📱', bg: 'bg-fuchsia-100 dark:bg-fuchsia-900/30', text: 'text-fuchsia-700 dark:text-fuchsia-300', desc: 'Contenu, engagement, reels' },
  { key: 'support',           label: 'Support Client',     icon: LifeBuoy,     emoji: '🛟', bg: 'bg-red-100 dark:bg-red-900/30',         text: 'text-red-700 dark:text-red-300',       desc: 'Tickets, SAV, formation' },
  { key: 'sales',             label: 'Process Commercial', icon: Briefcase,    emoji: '💼', bg: 'bg-indigo-100 dark:bg-indigo-900/30',   text: 'text-indigo-700 dark:text-indigo-300', desc: 'Qualification, closing' },
  { key: 'marketing',         label: 'Marketing & Ads',    icon: Megaphone,    emoji: '📊', bg: 'bg-orange-100 dark:bg-orange-900/30',   text: 'text-orange-700 dark:text-orange-300', desc: 'Campagnes, retargeting' },
  { key: 'whatsapp',          label: 'Scripts WhatsApp',   icon: MessageSquare,emoji: '💬', bg: 'bg-emerald-100 dark:bg-emerald-900/30', text: 'text-emerald-700 dark:text-emerald-300', desc: 'Messages clients' },
  { key: 'quick',             label: 'Réponses rapides',   icon: Zap,          emoji: '⚡', bg: 'bg-yellow-100 dark:bg-yellow-900/30',   text: 'text-yellow-700 dark:text-yellow-300', desc: 'Snippets à copier' },
  { key: 'onboarding',        label: 'Onboarding Client',  icon: UserPlus,     emoji: '🚀', bg: 'bg-cyan-100 dark:bg-cyan-900/30',       text: 'text-cyan-700 dark:text-cyan-300',     desc: 'Bienvenue & démarrage' },
  { key: 'delivery',          label: 'Livraison Projet',   icon: Rocket,       emoji: '📦', bg: 'bg-pink-100 dark:bg-pink-900/30',       text: 'text-pink-700 dark:text-pink-300',     desc: 'Process de livraison & QA' },
  { key: 'faq',               label: 'FAQ Interne',        icon: HelpCircle,   emoji: '❓', bg: 'bg-lime-100 dark:bg-lime-900/30',       text: 'text-lime-700 dark:text-lime-300',     desc: 'Questions fréquentes' },
  { key: 'ai',                label: 'IA & Automatisation',icon: Sparkles,     emoji: '🤖', bg: 'bg-purple-100 dark:bg-purple-900/30',   text: 'text-purple-700 dark:text-purple-300', desc: 'Workflows IA & prompts' },
]

export const SOP_CATEGORY_BY_KEY: Record<string, SopCategoryMeta> = Object.fromEntries(
  SOP_CATEGORIES.map(c => [c.key, c]),
)

export function sopCategoryLabel(key: string): string {
  return SOP_CATEGORY_BY_KEY[key]?.label ?? key
}
