import { Router, Request, Response } from 'express'
import rateLimit from 'express-rate-limit'
import Anthropic from '@anthropic-ai/sdk'
import { requireAuth } from '../middleware/auth'

const router = Router()

/* The Anthropic SDK reads ANTHROPIC_API_KEY from process.env automatically.
   Lazily instantiate so the server still boots if the key is absent —
   the route returns 503 in that case. */
let _client: Anthropic | null = null
function getClient(): Anthropic | null {
  if (_client) return _client
  if (!process.env.ANTHROPIC_API_KEY) return null
  _client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY })
  return _client
}

const ALLOWED_CATEGORIES = [
  'cash_withdrawal', 'freelance', 'advertising', 'hosting', 'saas_tool',
  'salary', 'invoice_paid', 'client_revenue', 'fixed_charge', 'card_topup',
  'bank_fee', 'transfer', 'other',
] as const

type Category = typeof ALLOWED_CATEGORIES[number]

interface InputTx { id: string; label: string; amount: number }
interface OutputTx { id: string; category: Category; confidence: number }

/* Per-tenant in-memory cache: same (label|amount) → same answer.
   Keeps API costs low and protects against duplicate uploads. */
const cache = new Map<string, OutputTx>()
const CACHE_MAX = 5000
function cacheKey(t: InputTx) { return `${t.label.trim().toLowerCase()}|${t.amount < 0 ? 'D' : 'C'}` }

/* Tighter rate limit than global — Claude calls are expensive. */
const aiLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Limite de requêtes IA atteinte (20/min). Réessayez dans une minute.' },
})

const SYSTEM_PROMPT = `Tu es un classificateur de transactions bancaires pour une agence digitale marocaine.
Pour chaque transaction (libellé + montant signé), choisis EXACTEMENT UNE catégorie parmi :
- cash_withdrawal : retrait ATM/cash/DAB
- freelance : Upwork, Fiverr, Malt, paiement à un freelance externe
- advertising : Facebook/Meta Ads, Google Ads, TikTok Ads, LinkedIn Ads, dépenses publicitaires
- hosting : OVH, Hostinger, AWS, hébergement, domaines, Cloudflare, Vercel
- saas_tool : Notion, Slack, GitHub, Figma, ChatGPT, OpenAI, Anthropic, Microsoft 365, abonnements logiciels
- salary : virement de salaire à un employé (sortant)
- invoice_paid : facture payée à un fournisseur identifié
- client_revenue : encaissement d'un client (entrant)
- fixed_charge : loyer, électricité (Lydec, Redal), eau, télécom (IAM, Inwi, Orange), assurance
- card_topup : recharge de carte internationale (Wise, Revolut, Payoneer, carte prépayée)
- bank_fee : frais bancaires, commission, agios
- transfer : virement interne ou non identifié
- other : aucune des catégories ci-dessus

Retourne UNIQUEMENT un objet JSON avec la forme :
{"results":[{"id":"...","category":"...","confidence":0.0}]}

confidence ∈ [0,1] reflète ta certitude. Pas de texte hors JSON, pas de markdown.`

router.post('/classify', requireAuth, aiLimiter, async (req: Request, res: Response) => {
  const client = getClient()
  if (!client) {
    return res.status(503).json({ error: 'Service IA non configuré (ANTHROPIC_API_KEY manquant)' })
  }

  const transactions = Array.isArray(req.body?.transactions) ? req.body.transactions : null
  if (!transactions) return res.status(400).json({ error: 'transactions[] requis' })
  if (transactions.length === 0) return res.json({ results: [] })
  if (transactions.length > 100) return res.status(400).json({ error: 'Maximum 100 transactions par requête' })

  // Validate + split into cached vs to-fetch
  const valid: InputTx[] = []
  const cached: OutputTx[] = []
  const toFetch: InputTx[] = []
  for (const t of transactions) {
    if (typeof t?.id !== 'string' || typeof t?.label !== 'string' || typeof t?.amount !== 'number') {
      return res.status(400).json({ error: 'Chaque transaction doit avoir id, label, amount' })
    }
    if (t.label.length > 200) return res.status(400).json({ error: 'Libellé trop long' })
    valid.push(t)
    const key = cacheKey(t)
    const hit = cache.get(key)
    if (hit) cached.push({ id: t.id, category: hit.category, confidence: hit.confidence })
    else toFetch.push(t)
  }

  if (toFetch.length === 0) return res.json({ results: cached })

  try {
    const response = await client.messages.create({
      model: 'claude-haiku-4-5-20251001',
      max_tokens: 2048,
      system: SYSTEM_PROMPT,
      messages: [
        {
          role: 'user',
          content: `Classe ces transactions :\n${JSON.stringify(toFetch.map(t => ({ id: t.id, label: t.label, amount: t.amount })))}`,
        },
      ],
    })

    const textBlock = response.content.find(b => b.type === 'text')
    const raw = textBlock && textBlock.type === 'text' ? textBlock.text.trim() : ''
    // Strip optional ``` fences if Claude wraps the JSON
    const jsonStr = raw.replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/i, '')
    let parsed: { results?: OutputTx[] }
    try { parsed = JSON.parse(jsonStr) } catch {
      console.error('AI classify: invalid JSON from Claude:', raw.slice(0, 300))
      return res.status(502).json({ error: 'Réponse IA invalide' })
    }

    const fresh: OutputTx[] = []
    const inputById = new Map(toFetch.map(t => [t.id, t]))
    for (const r of parsed.results ?? []) {
      if (!ALLOWED_CATEGORIES.includes(r.category as Category)) continue
      const conf = Math.max(0, Math.min(1, Number(r.confidence) || 0))
      const out: OutputTx = { id: r.id, category: r.category as Category, confidence: conf }
      fresh.push(out)
      const inp = inputById.get(r.id)
      if (inp) {
        if (cache.size >= CACHE_MAX) cache.delete(cache.keys().next().value!)
        cache.set(cacheKey(inp), out)
      }
    }

    return res.json({ results: [...cached, ...fresh] })
  } catch (err: any) {
    console.error('AI classify error:', err?.message ?? err)
    const status = err?.status === 429 ? 429 : 502
    return res.status(status).json({ error: err?.status === 429 ? 'Quota Anthropic dépassé' : 'Erreur IA' })
  }
})

router.get('/status', requireAuth, (_req, res) => {
  res.json({ enabled: !!process.env.ANTHROPIC_API_KEY, cacheSize: cache.size })
})

export default router
