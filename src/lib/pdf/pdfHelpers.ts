import type { StagiaireGenre } from '@/hooks/useStagiaires'

/** "M." pour homme, "Mme" pour femme. */
export function civilite(genre: StagiaireGenre): string {
  return genre === 'homme' ? 'M.' : 'Mme'
}

/** Accord féminin "e" (ou vide) — pour "accepté(e)", "intéressé(e)", etc. */
export function accordE(genre: StagiaireGenre): string {
  return genre === 'femme' ? 'e' : ''
}

/** "accepté" / "acceptée" */
export function accepteAccord(genre: StagiaireGenre): string {
  return genre === 'femme' ? 'acceptée' : 'accepté'
}

/** "couvert" / "couverte" */
export function couvertAccord(genre: StagiaireGenre): string {
  return genre === 'femme' ? 'couverte' : 'couvert'
}

/** "Il" / "Elle" */
export function pronomSujet(genre: StagiaireGenre): string {
  return genre === 'femme' ? 'Elle' : 'Il'
}

/** "Le stagiaire" / "La stagiaire" */
export function articleStagiaire(genre: StagiaireGenre): string {
  return genre === 'femme' ? 'La stagiaire' : 'Le stagiaire'
}

/** "qu'il" / "qu'elle" */
export function quilQuelle(genre: StagiaireGenre): string {
  return genre === 'femme' ? "qu'elle" : "qu'il"
}

/** Formate une date ISO (YYYY-MM-DD) ou Date en JJ/MM/AAAA. */
export function formatDateFR(date: string | Date | null | undefined): string {
  if (!date) return ''
  const d = typeof date === 'string' ? new Date(date) : date
  if (isNaN(d.getTime())) return ''
  const jj = String(d.getDate()).padStart(2, '0')
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  const aa = d.getFullYear()
  return `${jj}/${mm}/${aa}`
}

/** Durée en mois entre deux dates (arrondi à l'entier le plus proche, min 1). */
export function dureeEnMois(debut: string, fin: string): number {
  const d1 = new Date(debut)
  const d2 = new Date(fin)
  if (isNaN(d1.getTime()) || isNaN(d2.getTime())) return 0
  const ms = d2.getTime() - d1.getTime()
  const mois = ms / (1000 * 60 * 60 * 24 * 30.4375)
  return Math.max(1, Math.round(mois))
}

/** Date du jour au format JJ/MM/AAAA. */
export function dateAujourdHui(): string {
  return formatDateFR(new Date())
}

/** Nettoie un nom pour usage en nom de fichier (PDF). */
export function safeFilename(s: string): string {
  return s
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-zA-Z0-9_-]+/g, '_')
    .replace(/^_+|_+$/g, '')
    .slice(0, 60)
}
