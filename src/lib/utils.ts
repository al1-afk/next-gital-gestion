import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function formatCurrency(amount: number, currency = 'MAD'): string {
  return new Intl.NumberFormat('fr-MA', {
    style: 'currency',
    currency,
    minimumFractionDigits: 2,
  }).format(amount)
}

export function formatDate(date: string | Date | null): string {
  if (!date) return '—'
  return new Intl.DateTimeFormat('fr-FR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  }).format(new Date(date))
}

export function formatDateRelative(date: string | Date): string {
  const d = new Date(date)
  const now = new Date()
  const diff = Math.floor((d.getTime() - now.getTime()) / (1000 * 60 * 60 * 24))
  if (diff === 0) return "Aujourd'hui"
  if (diff === 1) return 'Demain'
  if (diff === -1) return 'Hier'
  if (diff > 0) return `Dans ${diff} jours`
  return `Il y a ${Math.abs(diff)} jours`
}

export function getDaysUntil(date: string): number {
  const d = new Date(date)
  const now = new Date()
  return Math.floor((d.getTime() - now.getTime()) / (1000 * 60 * 60 * 24))
}

export function truncate(str: string, length = 40): string {
  return str.length > length ? str.slice(0, length) + '...' : str
}

export function getInitials(name: string): string {
  return name
    .split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)
}

export function slugify(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^\w ]+/g, '')
    .replace(/ +/g, '-')
}

export function generateId(): string {
  return Math.random().toString(36).slice(2, 11)
}

export const PIPELINE_STAGES = [
  { id: 'lead_brut', label: 'Lead Brut', color: 'bg-gray-500' },
  { id: 'contact_etabli', label: 'Contact Établi', color: 'bg-blue-500' },
  { id: 'qualifie', label: 'Qualifié', color: 'bg-cyan-500' },
  { id: 'proposition_envoyee', label: 'Proposition Envoyée', color: 'bg-purple-500' },
  { id: 'relance_1', label: 'Relance 1', color: 'bg-yellow-500' },
  { id: 'relance_2', label: 'Relance 2', color: 'bg-orange-500' },
  { id: 'negociation', label: 'Négociation', color: 'bg-pink-500' },
  { id: 'gagne', label: 'Gagné', color: 'bg-emerald-500' },
  { id: 'perdu', label: 'Perdu', color: 'bg-red-500' },
] as const

export const EXPENSE_CATEGORIES = [
  'nourriture', 'transport', 'logement', 'sante', 'loisirs',
  'shopping', 'factures', 'education', 'autre',
]

export const PAYMENT_METHODS = [
  { value: 'virement', label: 'Virement' },
  { value: 'especes', label: 'Espèces' },
  { value: 'cheque', label: 'Chèque' },
  { value: 'carte', label: 'Carte' },
  { value: 'autre', label: 'Autre' },
]
