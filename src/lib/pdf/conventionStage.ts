import jsPDF from 'jspdf'
import type { Stagiaire } from '@/hooks/useStagiaires'
import { ENTREPRISE } from '@/lib/entreprise'
import {
  articleStagiaire, quilQuelle, couvertAccord, pronomSujet,
  formatDateFR, dateAujourdHui, dureeEnMois, safeFilename,
} from './pdfHelpers'
import {
  drawHeader, drawFooter, COLORS, MARGIN, PAGE_W, PAGE_H,
} from './stagiairePdfCommon'

/**
 * Document 2 — Convention de stage.
 * Document principal signé entre les parties (entreprise + stagiaire).
 */
export function generateConventionStage(s: Stagiaire): void {
  const doc = new jsPDF('p', 'mm', 'a4')

  let y = renderPage1Header(doc)
  y = renderEntrepriseBloc(doc, y)
  y = renderStagiaireBloc(doc, s, y)
  y = renderArticle(doc, '1', 'ÉTUDES ET FORMATION', [
    `Nature : ${s.formation}`,
    `Durée du stage : ${dureeEnMois(s.date_debut, s.date_fin)} mois (du ${formatDateFR(s.date_debut)} au ${formatDateFR(s.date_fin)})`,
  ], y)

  y = renderArticle(doc, '2', 'OBJECTIFS DU STAGE', [
    "Le stage a pour objectif de permettre au stagiaire de mettre en pratique les connaissances théoriques acquises lors de sa formation, conformément aux exigences pédagogiques.",
  ], y)

  y = renderArticle(doc, '3', 'CONDITIONS DU STAGE',
    [
      "Le stagiaire s'engage à :",
      "• Respecter le règlement intérieur de l'entreprise.",
      "• Maintenir un environnement de travail 100 % professionnel.",
      "• Utiliser le téléphone uniquement pendant les pauses.",
      "• Porter une tenue correcte, respectueuse et professionnelle, reflétant l'image de l'entreprise.",
      "• Adopter un comportement professionnel en toutes circonstances.",
      "• Éviter tout comportement pouvant perturber la concentration ou le bon fonctionnement de l'équipe.",
      "• Respecter l'ensemble des membres de l'équipe, sans exception.",
      "• Garantir la confidentialité des informations obtenues.",
      '',
      "L'entreprise s'engage à :",
      "• Fournir les moyens nécessaires à la réalisation des missions.",
      "• Assurer un encadrement approprié.",
      '',
      "Le stagiaire conserve son statut d'étudiant pendant toute la durée du stage et reste sous la responsabilité de son établissement d'enseignement.",
    ], y)

  // Si on est trop bas, page break
  if (y > PAGE_H - 60) { doc.addPage(); y = 25 }

  y = renderArticle(doc, '4', 'SECRET PROFESSIONNEL', [
    "Conformément au Code Pénal marocain, le stagiaire est tenu au secret professionnel absolu et s'engage à ne divulguer aucune information à des tiers sans autorisation écrite de l'entreprise.",
  ], y)

  y = renderArticle(doc, '5', 'GRATIFICATION ET MOYENS MIS À DISPOSITION', [
    "L'entreprise mettra à disposition du stagiaire les outils et ressources nécessaires à la bonne réalisation de ses missions.",
    "Elle veillera également à lui fournir un encadrement de qualité, garantissant une immersion professionnelle enrichissante et conforme aux objectifs pédagogiques du stage.",
  ], y)

  if (y > PAGE_H - 60) { doc.addPage(); y = 25 }

  y = renderArticle(doc, '6', 'ASSURANCE DU STAGE', [
    `${articleStagiaire(s.genre)} confirme ${quilQuelle(s.genre)} est ${couvertAccord(s.genre)} par une assurance de responsabilité civile couvrant l'ensemble des risques liés à ses activités durant le stage, que cette couverture soit fournie par son établissement de formation ou par un organisme assureur privé.`,
    `${pronomSujet(s.genre)} déclare également bénéficier d'une police d'assurance contractée auprès d'un assureur, valable pendant toute la durée du stage, incluant la responsabilité civile pour les dommages pouvant survenir dans le cadre de l'exercice de ses missions en tant que stagiaire.`,
  ], y)

  y = renderArticle(doc, '7', 'ÉVALUATION DU STAGE', [
    "À l'issue du stage :",
    "• Le stagiaire doit fournir un rapport de stage à son établissement.",
    "• Une copie sera remise à l'entreprise.",
    "• L'entreprise délivrera une attestation de stage.",
  ], y)

  if (y > PAGE_H - 60) { doc.addPage(); y = 25 }

  y = renderArticle(doc, '8', 'NATURE JURIDIQUE DU STAGE', [
    "Le stage ne constitue en aucun cas un contrat de travail. Il n'entraîne aucune relation de subordination juridique permanente entre les parties.",
  ], y)

  y = renderArticle(doc, '9', 'PROPRIÉTÉ INTELLECTUELLE', [
    "Les productions réalisées durant le stage (documents, designs, contenus, etc.) demeurent la propriété exclusive de l'entreprise, sauf accord contraire écrit.",
  ], y)

  // Signatures
  if (y > PAGE_H - 55) { doc.addPage(); y = 30 }
  y += 6
  doc.setDrawColor(...COLORS.divider)
  doc.setLineWidth(0.3)
  doc.line(MARGIN, y, PAGE_W - MARGIN, y)
  y += 8

  doc.setFont('helvetica', 'bold')
  doc.setFontSize(11)
  doc.setTextColor(...COLORS.dark)
  doc.text('SIGNATURES', MARGIN, y)
  y += 8
  doc.setFont('helvetica', 'normal')
  doc.setFontSize(10)
  doc.setTextColor(...COLORS.text)
  doc.text(`Fait à : ${ENTREPRISE.ville}, le ${dateAujourdHui()}`, MARGIN, y)
  y += 14

  // Deux colonnes signatures
  doc.setFont('helvetica', 'bold')
  doc.setFontSize(11)
  doc.text("L'Entreprise :", MARGIN, y)
  doc.text('Le Stagiaire :', PAGE_W / 2 + 10, y)
  y += 6
  doc.setFont('helvetica', 'normal')
  doc.setFontSize(9)
  doc.setTextColor(...COLORS.muted)
  doc.text(`${ENTREPRISE.gerant} — ${ENTREPRISE.raisonSociale}`, MARGIN, y)
  doc.text(s.nom_complet, PAGE_W / 2 + 10, y)

  // Cadres de signature
  doc.setDrawColor(...COLORS.divider)
  doc.setLineWidth(0.3)
  doc.rect(MARGIN, y + 4, 80, 28)
  doc.rect(PAGE_W / 2 + 10, y + 4, 80, 28)

  // Footer sur chaque page
  const total = doc.getNumberOfPages()
  for (let i = 1; i <= total; i++) {
    doc.setPage(i)
    drawFooter(doc)
  }

  doc.save(`Convention_Stage_${safeFilename(s.nom_complet)}.pdf`)
}

/* ─────────────────────────────────────────────────────────────────── */

function renderPage1Header(doc: jsPDF): number {
  drawHeader(doc)
  // Titre centré
  doc.setTextColor(...COLORS.dark)
  doc.setFont('helvetica', 'bold')
  doc.setFontSize(18)
  doc.text('CONVENTION DE STAGE', PAGE_W / 2, 50, { align: 'center' })
  const w = doc.getTextWidth('CONVENTION DE STAGE')
  doc.setDrawColor(...COLORS.accent)
  doc.setLineWidth(0.6)
  doc.line(PAGE_W / 2 - w / 2, 52, PAGE_W / 2 + w / 2, 52)
  return 64
}

function renderEntrepriseBloc(doc: jsPDF, y: number): number {
  drawSectionTitle(doc, "ENTREPRISE D'ACCUEIL", y)
  y += 8
  const rows: [string, string][] = [
    ['Nom',          'NEXT GITAL'],
    ['Représentée par', ENTREPRISE.gerant],
    ['Adresse',      'Rue Mohammed V, Immeuble Kissi, 4ème étage, Bureau N°7, Oujda'],
    ['Téléphone',    ENTREPRISE.telephone],
    ['Activité',     'Agence de marketing digital'],
  ]
  return drawKeyValueList(doc, rows, y) + 4
}

function renderStagiaireBloc(doc: jsPDF, s: Stagiaire, y: number): number {
  drawSectionTitle(doc, 'STAGIAIRE', y)
  y += 8
  const naissance = [formatDateFR(s.date_naissance), s.lieu_naissance].filter(Boolean).join(' à ') || '—'
  const rows: [string, string][] = [
    ['Nom et prénom',                  s.nom_complet],
    ['Numéro de carte nationale',      s.cin],
    ['Date et lieu de naissance',      naissance],
    ['Adresse',                        s.adresse],
  ]
  return drawKeyValueList(doc, rows, y) + 4
}

function drawSectionTitle(doc: jsPDF, title: string, y: number): void {
  doc.setFillColor(...COLORS.primary)
  doc.rect(MARGIN, y - 4, 4, 6, 'F')
  doc.setFont('helvetica', 'bold')
  doc.setFontSize(11)
  doc.setTextColor(...COLORS.primary)
  doc.text(title, MARGIN + 7, y)
}

function drawKeyValueList(doc: jsPDF, rows: [string, string][], startY: number): number {
  let y = startY
  for (const [k, v] of rows) {
    doc.setFont('helvetica', 'bold')
    doc.setFontSize(9.5)
    doc.setTextColor(...COLORS.muted)
    doc.text(`${k} :`, MARGIN + 2, y)

    doc.setFont('helvetica', 'normal')
    doc.setFontSize(10)
    doc.setTextColor(...COLORS.text)
    const valueLines = doc.splitTextToSize(v, PAGE_W - MARGIN * 2 - 55)
    doc.text(valueLines, MARGIN + 55, y)
    y += Math.max(5.5, valueLines.length * 4.5)
  }
  return y
}

function renderArticle(doc: jsPDF, num: string, title: string, paragraphs: string[], y: number): number {
  // Saut de page si nécessaire
  if (y > PAGE_H - 50) { doc.addPage(); y = 25 }

  // Titre article
  doc.setFont('helvetica', 'bold')
  doc.setFontSize(10.5)
  doc.setTextColor(...COLORS.primary)
  doc.text(`ARTICLE ${num} : ${title}`, MARGIN, y)
  y += 6

  doc.setFont('helvetica', 'normal')
  doc.setFontSize(9.5)
  doc.setTextColor(...COLORS.text)

  for (const p of paragraphs) {
    if (p === '') { y += 2; continue }
    const lines = doc.splitTextToSize(p, PAGE_W - MARGIN * 2 - 2)
    // Saut de page si nécessaire au milieu d'un article
    if (y + lines.length * 4.3 > PAGE_H - 25) {
      doc.addPage()
      y = 25
    }
    doc.text(lines, MARGIN + 2, y, { align: 'justify', maxWidth: PAGE_W - MARGIN * 2 - 2 } as any)
    y += lines.length * 4.3 + 1
  }
  return y + 4
}
