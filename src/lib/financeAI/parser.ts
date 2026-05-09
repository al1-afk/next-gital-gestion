import * as pdfjsLib from 'pdfjs-dist'
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

/* Moroccan bank statements typically don't carry a +/- sign on the amount
   (the column position decides). PDF text extraction loses column info,
   so we infer direction from the operation label.
   Order matters: debit keywords are checked first because phrases like
   "DROIT DE TIMBRE SUR VERSEMENT" contain a credit word ("versement")
   but are actually a fee. */
const DEBIT_KEYWORDS: RegExp[] = [
  /\bretrait\b/i,
  /\bpaiement\b/i,
  /\bpayement\b/i,
  /\brecharge\b/i,
  /\bvirement\s+(emis|émis|d[ée]part)/i,
  /\bvir\.?\s+emis/i,
  /\bvirt\s+emis/i,
  /\bfacture\b/i,
  /\bvignette\b/i,
  /\bcommission\b/i,
  /\bfrais\b/i,
  /\bagios\b/i,
  /\bdroit\s+de\s+timbre\b/i,
  /\bch[eè]que\s+(émis|emis|pay[ée])/i,
  /\bpr[ée]l[èe]vement\b/i,
  /\bcotisation\b/i,
  /\babonnement\b/i,
  /\bach[ae]t\b/i,
  /\bd[ée]bit\b/i,
]

const CREDIT_KEYWORDS: RegExp[] = [
  /\bvirement\s+re[cç]u/i,
  /\bvir\.?\s+re[cç]u/i,
  /\bvirt\s+re[cç]u/i,
  /\bversement\b/i,
  /\brestitution\b/i,
  /\bremise\s+(de\s+)?(ch[eè]que|esp[èe]ce)/i,
  /\bencaissement\b/i,
  /\bcr[ée]dit\b/i,
  /\bd[ée]p[ôo]t\b/i,
  /\bdepot\b/i,
]

function detectSign(label: string): -1 | 1 {
  for (const re of DEBIT_KEYWORDS) if (re.test(label)) return -1
  for (const re of CREDIT_KEYWORDS) if (re.test(label)) return +1
  return -1
}

function parseAmount(raw: string): number | null {
  let s = raw.replace(/[  ]/g, ' ').trim()
  if (!s) return null
  let sign = 1
  if (/^\(.+\)$/.test(s)) { sign = -1; s = s.slice(1, -1) }
  if (/-$/.test(s)) { sign = -1; s = s.slice(0, -1) }
  if (/^-/.test(s)) { sign = -1; s = s.slice(1) }
  s = s.replace(/[^\d.,]/g, '')
  if (!s) return null

  if (s.includes(',') && s.includes('.')) {
    s = s.replace(/\./g, '').replace(',', '.')
  } else if (s.includes(',')) {
    s = s.replace(',', '.')
  }
  const n = Number(s)
  return Number.isFinite(n) ? sign * n : null
}

/* Scan the document for a 4-digit year inside a date pattern. The most
   common one is the statement period — fall back to the current year. */
function inferYear(lines: string[]): number {
  const re = /\b\d{1,2}[\/.\-]\d{1,2}[\/.\-](\d{4})\b/g
  const years = new Map<number, number>()
  for (const line of lines) {
    re.lastIndex = 0
    let m: RegExpExecArray | null
    while ((m = re.exec(line)) !== null) {
      const y = parseInt(m[1], 10)
      if (y >= 2000 && y <= 2100) years.set(y, (years.get(y) ?? 0) + 1)
    }
  }
  if (years.size === 0) return new Date().getFullYear()
  return Array.from(years.entries()).sort((a, b) => b[1] - a[1])[0][0]
}

const SKIP_PATTERNS: RegExp[] = [
  /^solde\b/i,
  /\bsolde\s+d[ée]part\b/i,
  /\bnouveau\s+solde\b/i,
  /\bancien\s+solde\b/i,
  /\btotal\s+des\s+mouvements/i,
  /\bpage\s+n[°o]/i,
]

/* Date prefix accepts:
   - "01/01"          single date
   - "01/01/2026"     single date with year
   - "01/01 01/01"    two dates separated by space (operation + value date)
   - "01/0101/01"     two dates concatenated (CIH layout — PDF.js merges them)
   followed by whitespace then a non-digit. */
const DATE_RE = /^(\d{1,2})[\/.\-](\d{1,2})(?:[\/.\-](\d{2,4}))?(?:\s*\d{1,2}[\/.\-]\d{1,2}(?:[\/.\-]\d{2,4})?)?(?=\s|$)/

/* Amount must start with 1-3 digits, may have space/dot thousand
   separators, and end with a comma or dot decimal. The (?:^|\s) anchor
   prevents matching the tail of an unrelated number like a card ref
   "2229 3,01" → only "3,01" is captured. */
const AMOUNT_RE = /(?:^|\s)(\d{1,3}(?:[\s.  ]\d{3})*[.,]\d{2})\s*(?:MAD|DH|DHS|EUR|USD|€|\$)?\s*$/i

async function extractLines(file: File): Promise<string[]> {
  const buf = await file.arrayBuffer()
  const pdf = await pdfjsLib.getDocument({ data: buf }).promise
  const lines: string[] = []
  for (let p = 1; p <= pdf.numPages; p++) {
    const page = await pdf.getPage(p)
    const content = await page.getTextContent()

    // Cluster text items by Y coordinate (rounded) to reconstruct rows.
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
    const sortedY = Array.from(rows.keys()).sort((a, b) => b - a) // top → bottom
    for (const y of sortedY) {
      const cells = rows.get(y)!.sort((a, b) => a.x - b.x)
      const line = cells
        .map(c => c.str)
        .join(' ')
        .replace(/[  ]/g, ' ')
        .replace(/\s+/g, ' ')
        .trim()
      if (line) lines.push(line)
    }
  }
  return lines
}

function parseLines(lines: string[]): ParsedRow[] {
  const fallbackYear = inferYear(lines)
  const rows: ParsedRow[] = []
  for (const line of lines) {
    if (SKIP_PATTERNS.some(p => p.test(line))) continue
    const dm = line.match(DATE_RE)
    if (!dm) continue
    const am = line.match(AMOUNT_RE)
    if (!am) continue

    const dd = parseInt(dm[1], 10)
    const mm = parseInt(dm[2], 10)
    let yyyy = dm[3] ? parseInt(dm[3], 10) : fallbackYear
    if (yyyy < 100) yyyy += yyyy >= 70 ? 1900 : 2000
    if (mm < 1 || mm > 12 || dd < 1 || dd > 31) continue
    const date = `${yyyy}-${String(mm).padStart(2, '0')}-${String(dd).padStart(2, '0')}`

    const amount = parseAmount(am[1])
    if (amount === null || amount === 0) continue

    const label = line
      .slice(dm[0].length, line.length - am[0].length)
      .replace(/\s+/g, ' ')
      .trim()
    if (!label || label.length < 3) continue

    const sign = detectSign(label)
    rows.push({ date, label, amount: sign * Math.abs(amount) })
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
  const rows = parseLines(lines)
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

  if (transactions.length === 0 && lines.length > 0) {
    // Help debugging unsupported formats
    console.warn('[FinanceIA] PDF parsed but no transactions matched. First 5 lines:')
    for (const l of lines.slice(0, 5)) console.warn('  →', l)
  }
  return { transactions, rawLines: lines.length, matched: transactions.length }
}
