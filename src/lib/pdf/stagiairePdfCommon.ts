import jsPDF from 'jspdf'
import { ENTREPRISE } from '@/lib/entreprise'

/** Couleurs partagées. */
export const COLORS = {
  primary:    [30, 58, 138]  as [number, number, number],  // bleu profond
  accent:     [37, 99, 235]  as [number, number, number],  // bleu vif
  dark:       [15, 23, 42]   as [number, number, number],  // slate-900
  text:       [30, 41, 59]   as [number, number, number],  // slate-800
  muted:      [100, 116, 139] as [number, number, number], // slate-500
  divider:    [203, 213, 225] as [number, number, number], // slate-300
}

export const MARGIN = 20
export const PAGE_W = 210
export const PAGE_H = 297

/** En-tête NEXT GITAL — bandeau bleu avec raison sociale, activité, adresse. */
export function drawHeader(doc: jsPDF): void {
  // Bandeau
  doc.setFillColor(...COLORS.primary)
  doc.rect(0, 0, PAGE_W, 32, 'F')

  // Raison sociale
  doc.setTextColor(255, 255, 255)
  doc.setFont('helvetica', 'bold')
  doc.setFontSize(18)
  doc.text(ENTREPRISE.raisonSociale, MARGIN, 14)

  // Activité
  doc.setFont('helvetica', 'normal')
  doc.setFontSize(9)
  doc.text(ENTREPRISE.activite, MARGIN, 21)

  // Adresse
  doc.setFontSize(8)
  doc.text(ENTREPRISE.adresse, MARGIN, 27)
}

/** Titre centré, sous le bandeau. */
export function drawTitle(doc: jsPDF, title: string, y = 50): void {
  doc.setTextColor(...COLORS.dark)
  doc.setFont('helvetica', 'bold')
  doc.setFontSize(16)
  doc.text(title, PAGE_W / 2, y, { align: 'center' })

  // Ligne décorative sous le titre
  const titleW = doc.getTextWidth(title)
  doc.setDrawColor(...COLORS.accent)
  doc.setLineWidth(0.6)
  doc.line(PAGE_W / 2 - titleW / 2, y + 2, PAGE_W / 2 + titleW / 2, y + 2)
}

/** Pied de page : ligne fine + mentions. */
export function drawFooter(doc: jsPDF): void {
  doc.setDrawColor(...COLORS.divider)
  doc.setLineWidth(0.3)
  doc.line(MARGIN, PAGE_H - 18, PAGE_W - MARGIN, PAGE_H - 18)

  doc.setTextColor(...COLORS.muted)
  doc.setFont('helvetica', 'normal')
  doc.setFontSize(7.5)
  doc.text(
    `${ENTREPRISE.raisonSociale}  ·  ${ENTREPRISE.adresse}  ·  Tél: ${ENTREPRISE.telephone}`,
    PAGE_W / 2,
    PAGE_H - 12,
    { align: 'center' },
  )
}

/** Écrit du texte justifié dans la largeur de page utile, avec retour à la ligne automatique. */
export function writeParagraph(
  doc: jsPDF,
  text: string,
  y: number,
  opts: { fontSize?: number; bold?: boolean; align?: 'left' | 'justify' | 'center' } = {},
): number {
  const { fontSize = 11, bold = false, align = 'justify' } = opts
  doc.setFont('helvetica', bold ? 'bold' : 'normal')
  doc.setFontSize(fontSize)
  doc.setTextColor(...COLORS.text)

  const maxWidth = PAGE_W - MARGIN * 2
  const lines = doc.splitTextToSize(text, maxWidth)
  doc.text(lines, MARGIN, y, { align: align as any, maxWidth })
  return y + lines.length * (fontSize * 0.45) + 2
}

/** Écrit une ligne courte (label/value). Retourne le nouveau Y. */
export function writeLine(doc: jsPDF, text: string, y: number, fontSize = 11, bold = false): number {
  doc.setFont('helvetica', bold ? 'bold' : 'normal')
  doc.setFontSize(fontSize)
  doc.setTextColor(...COLORS.text)
  doc.text(text, MARGIN, y)
  return y + fontSize * 0.55
}
