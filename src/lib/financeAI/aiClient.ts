import { api } from '@/lib/api'
import type { BankTransaction, Category } from './types'

interface ClassifyResponse {
  results: { id: string; category: Category; confidence: number }[]
}

interface StatusResponse { enabled: boolean; cacheSize: number }

export async function checkAiStatus(): Promise<boolean> {
  try {
    const r = await api.get<StatusResponse>('/api/finance-ai/status')
    return !!r.enabled
  } catch { return false }
}

/* Re-classify the given transactions using Claude. Falls back to the
   existing rule-based category if the API is unavailable or returns 503.
   Server batches up to 100 per request, so we chunk on the client too. */
export async function classifyWithAI(
  transactions: BankTransaction[],
): Promise<Map<string, { category: Category; confidence: number }>> {
  const out = new Map<string, { category: Category; confidence: number }>()
  if (transactions.length === 0) return out

  const CHUNK = 50
  for (let i = 0; i < transactions.length; i += CHUNK) {
    const slice = transactions.slice(i, i + CHUNK)
    const payload = {
      transactions: slice.map(t => ({ id: t.id, label: t.label, amount: t.amount })),
    }
    const resp = await api.post<ClassifyResponse>('/api/finance-ai/classify', payload)
    for (const r of resp.results) {
      out.set(r.id, { category: r.category, confidence: r.confidence })
    }
  }
  return out
}
