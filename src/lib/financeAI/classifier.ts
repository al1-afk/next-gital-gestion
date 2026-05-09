import type { Category } from './types'

interface Rule {
  category: Category
  patterns: RegExp[]
  /** confidence boost (0..1) when a pattern matches */
  confidence: number
}

/* Smart-tag rule set. Order matters: first hit wins.
   Patterns are case-insensitive. */
const RULES: Rule[] = [
  {
    category: 'advertising',
    confidence: 0.95,
    patterns: [/facebook/i, /\bmeta\b/i, /\bfb\s*ads?\b/i, /google\s*ads?/i, /\badwords\b/i, /tiktok\s*ads?/i, /linkedin\s*ads?/i, /snap\s*ads?/i],
  },
  {
    category: 'freelance',
    confidence: 0.92,
    patterns: [/upwork/i, /fiverr/i, /freelancer\.com/i, /malt\b/i, /toptal/i, /payoneer/i],
  },
  {
    category: 'hosting',
    confidence: 0.95,
    patterns: [/\bovh\b/i, /hostinger/i, /godaddy/i, /namecheap/i, /\bgandi\b/i, /digitalocean/i, /\baws\b/i, /amazon\s*web/i, /hetzner/i, /cloudflare/i, /vercel/i, /netlify/i, /\bplesk\b/i],
  },
  {
    category: 'saas_tool',
    confidence: 0.9,
    patterns: [/notion/i, /slack/i, /\bzoom\b/i, /github/i, /gitlab/i, /figma/i, /adobe/i, /canva/i, /chatgpt/i, /openai/i, /anthropic/i, /microsoft\s*365/i, /office\s*365/i, /dropbox/i, /\basana\b/i, /trello/i, /\bjira\b/i, /\bclickup\b/i, /typeform/i, /mailchimp/i, /sendgrid/i, /twilio/i, /stripe\s*billing/i],
  },
  {
    category: 'card_topup',
    confidence: 0.88,
    patterns: [/recharge\s*carte/i, /carte\s*international/i, /\bwise\b/i, /transferwise/i, /revolut/i, /\bpayoneer\s*top/i],
  },
  {
    category: 'cash_withdrawal',
    confidence: 0.97,
    patterns: [/\batm\b/i, /\bcash\b/i, /retrait/i, /\bdab\b/i, /gab\b/i, /withdraw/i],
  },
  {
    category: 'bank_fee',
    confidence: 0.9,
    patterns: [/\bfrais\b/i, /commission/i, /agios/i, /\bcotis(ation)?\b/i, /\btva\s*bancaire/i],
  },
  {
    category: 'salary',
    confidence: 0.85,
    patterns: [/salaire/i, /\bpaie\b/i, /\bpayroll\b/i, /\bwage[s]?\b/i, /\bvirement\s+salai/i],
  },
  {
    category: 'invoice_paid',
    confidence: 0.7,
    patterns: [/\bfact(ure)?\s*\w+/i, /paiement\s*facture/i, /\bfact\s*n[°o]/i],
  },
  {
    category: 'transfer',
    confidence: 0.6,
    patterns: [/virement/i, /\btransfer\b/i, /\bvir\.?\s/i],
  },
  {
    category: 'fixed_charge',
    confidence: 0.75,
    patterns: [/\bredal\b/i, /\blydec\b/i, /\bamendis\b/i, /\bonee\b/i, /\bonep\b/i, /\biam\b/i, /maroc\s*telecom/i, /inwi/i, /orange/i, /\bloyer\b/i, /\brent\b/i, /assurance/i, /\baxa\b/i, /\brma\b/i, /\bsanad\b/i],
  },
  {
    category: 'client_revenue',
    confidence: 0.6,
    patterns: [/\bclient\b/i, /\bencaisseme?nt/i, /\bencais\b/i, /\bdépot\b/i, /\bdepot\b/i, /paypal\s+receive/i],
  },
]

export interface Classification {
  category: Category
  confidence: number
}

/** Classify a transaction label + signed amount. */
export function classify(label: string, amount: number): Classification {
  const text = (label || '').trim()
  const sign = amount >= 0 ? 'income' : 'expense'

  for (const rule of RULES) {
    if (rule.patterns.some(p => p.test(text))) {
      let cat = rule.category
      // an income hit on "transfer" is more likely client revenue
      if (cat === 'transfer' && sign === 'income') cat = 'client_revenue'
      return { category: cat, confidence: rule.confidence }
    }
  }

  // Fallback: low-confidence default
  return {
    category: sign === 'income' ? 'client_revenue' : 'other',
    confidence: 0.35,
  }
}

export function isIncomeCategory(c: Category): boolean {
  return c === 'client_revenue' || c === 'invoice_paid'
}
