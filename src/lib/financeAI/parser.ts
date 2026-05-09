import * as pdfjsLib from 'pdfjs-dist'
// Vite-friendly worker import
// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore — worker imported as URL
import workerSrc from 'pdfjs-dist/build/pdf.worker.min.mjs?url'

pdfjsLib.GlobalWorkerOptions.workerSrc = workerSrc

import type { BankTransaction } from './types'
import { classify } from './classifier'

export interface ParsedRow {
  date: string
  label: string
  amount: number
}

/* Convert a French/Moroccan bank-statement amount string to a Number.
   Handles "1.234,56", "1 234,56", "1234.56", and trailing minus / parens. */
function parseAmount(raw: string): number | null {
  let s = raw.trim()
  if (!s) return null
  let sign = 1
  if (/^\(.+\)$/.test(s)) { sign = -1; s = s.slice(1, -1) }
  if (/-$/.test(s)) { sign = -1; s = s.slice(0, -1) }
  if (/^-/.test(s)) { sign = -1; s = s.slice(1) }
  s = s.replace(/[^\d.,]/g, '')
  if (!s) return null

  // If both . and , present → assume , is decimal (FR) and . is thousands
  if (s.includes(',') && s.includes('.')) {
    s = s.replace(/\./g, '').replace(',', '.')
  } else if (s.includes(',')) {
    // Single comma = decimal separator (fr-MA)
    s = s.replace(',', '.')
  }
  const n = Number(s)
  return Number.isFinite(n) ? sign * n : null
}

/* Normalise a date token to ISO yyyy-mm-dd. Accepts dd/mm/yyyy, dd-mm-yyyy,
   dd/mm/yy, dd.mm.yyyy. Returns null on failure. */
function parseDate(raw: string, fallbackYear: number): string | null {
  const m = raw.trim().match(/^(\d{1,2})[\/.\-](\d{1,2})(?:[\/.\-](\d{2,4}))?$/)
  if (!m) return null
  const dd = parseInt(m[1], 10)
  const mm = parseInt(m[2], 10)
  let yyyy = m[3] ? parseInt(m[3], 10) : fallbackYear
  if (yyyy < 100) yyyy += yyyy >= 70 ? 1900 : 2000
  if (mm < 1 || mm > 12 || dd < 1 || dd > 31) return null
  return `${yyyy}-${String(mm).padStart(2, '0')}-${String(dd).padStart(2, '0')}`
}

/** Extract every text line from the PDF, preserving page order. */
async function extractLines(file: File): Promise<string[]> {
  const buf = await file.arrayBuffer()
  const pdf = await pdfjsLib.getDocument({ data: buf }).promise
  const lines: string[] = []
  for (let p = 1; p <= pdf.numPages; p++) {
    const page = await pdf.getPage(p)
    const content = await page.getTextContent()

    // Group items by Y coordinate so a row that PDF.js splits across items
    // is reassembled into a single line.
    const rows = new Map<number, { x: number; str: string }[]>()
    for (const it of content.items as any[]) {
      const y = Math.round(it.transform[5])
      const x = it.transform[4]
      const str = (it.str ?? '').toString()
      if (!str) continue
      const arr = rows.get(y) ?? []
      arr.push({ x, str })
      rows.set(y, arr)
    }
    const sortedY = Array.from(rows.keys()).sort((a, b) => b - a) // top to bottom
    for (const y of sortedY) {
      const cells = rows.get(y)!.sort((a, b) => a.x - b.x)
      const line = cells.map(c => c.str).join(' ').replace(/\s+/g, ' ').trim()
      if (line) lines.push(line)
    }
  }
  return lines
}

/* Heuristic row parser. Looks for a leading date and a trailing amount on
   the same line. The middle text becomes the label.
   Works for Attijariwafa, CIH, Banque Populaire, SGMB and most Moroccan
   bank exports because they all share the date / libellé / amount layout. */
function parseLines(lines: string[]): ParsedRow[] {
  const fallbackYear = new Date().getFullYear()
  const dateRe   = /^(\d{1,2}[\/.\-]\d{1,2}(?:[\/.\-]\d{2,4})?)\b/
  const amountRe = /(-?\(?[\d\s.]*\d[.,]\d{2}\)?-?)\s*(?:MAD|DH|DHS|EUR|USD)?\s*$/i

  const rows: ParsedRow[] = []
  for (const line of lines) {
    const dm = line.match(dateRe)
    if (!dm) continue
    const am = line.match(amountRe)
    if (!am) continue

    const date = parseDate(dm[1], fallbackYear)
    if (!date) continue
    const amount = parseAmount(am[1])
    if (amount === null) continue

    const label = line.slice(dm[0].length, line.length - am[0].length).replace(/\s+/g, ' ').trim()
    if (!label) continue
    rows.push({ date, label, amount })
  }
  return rows
}

export interface ParseResult {
  transactions: BankTransaction[]
  rawLines: number
  matched: number
}

export async function parseBankStatement(file: File): Promise<ParseResult> {
  const lines = await extractLines(file)
  const rows  = parseLines(lines)
  const transactions: BankTransaction[] = rows.map((r, i) => {
    const cls = classify(r.label, r.amount)
    return {
      id: `${Date.now()}-${i}-${Math.random().toString(36).slice(2, 8)}`,
      date: r.date,
      label: r.label,
      amount: r.amount,
      type: r.amount >= 0 ? 'income' : 'expense',
      category: cls.category,
      ai_confidence: cls.confidence,
      source_pdf: file.name,
    }
  })
  return { transactions, rawLines: lines.length, matched: transactions.length }
}
