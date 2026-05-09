import { useEffect, useMemo, useRef, useState, type ChangeEvent } from 'react'
import { motion } from 'framer-motion'
import {
  Upload, FileText, Sparkles, TrendingUp, TrendingDown, Wallet,
  Megaphone, Users, AlertTriangle, Trash2, Search, RefreshCw, Banknote, Server, Bot,
} from 'lucide-react'
import {
  ResponsiveContainer, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  PieChart, Pie, Cell, AreaChart, Area, Legend,
} from 'recharts'
import { toast } from 'sonner'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { formatCurrency } from '@/lib/utils'
import { parseBankStatement } from '@/lib/financeAI/parser'
import { transactionsStore } from '@/lib/financeAI/storage'
import { checkAiStatus, classifyWithAI } from '@/lib/financeAI/aiClient'
import {
  CATEGORY_LABELS, CATEGORY_COLORS,
  type BankTransaction, type Category,
} from '@/lib/financeAI/types'
import {
  computeKPIs, expensesByCategory, monthlyEvolution,
  generateAlerts, detectRecurring, topClients,
} from '@/lib/financeAI/insights'

const ALL_CATEGORIES: Category[] = [
  'client_revenue', 'invoice_paid',
  'advertising', 'freelance', 'cash_withdrawal',
  'hosting', 'saas_tool', 'salary', 'fixed_charge',
  'card_topup', 'bank_fee', 'transfer', 'other',
]

export default function FinanceIA() {
  const [transactions, setTransactions] = useState<BankTransaction[]>([])
  const [parsing, setParsing] = useState(false)
  const [aiBusy, setAiBusy] = useState(false)
  const [aiEnabled, setAiEnabled] = useState(false)
  const [search, setSearch] = useState('')
  const [filterCategory, setFilterCategory] = useState<Category | 'all'>('all')
  const fileInput = useRef<HTMLInputElement>(null)

  useEffect(() => {
    setTransactions(transactionsStore.list())
    checkAiStatus().then(setAiEnabled).catch(() => setAiEnabled(false))
  }, [])

  const refresh = () => setTransactions(transactionsStore.list())

  const onFile = async (e: ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files ?? [])
    if (files.length === 0) return
    setParsing(true)
    try {
      let added = 0
      let totalMatched = 0
      for (const file of files) {
        if (!file.name.toLowerCase().endsWith('.pdf')) {
          toast.error(`${file.name} n'est pas un PDF`)
          continue
        }
        const result = await parseBankStatement(file)
        totalMatched += result.matched
        added += transactionsStore.addMany(result.transactions)
      }
      refresh()
      if (added > 0) toast.success(`${added} transaction(s) importée(s) — ${totalMatched} détectée(s)`)
      else if (totalMatched > 0) toast.info('Toutes les transactions étaient déjà importées')
      else toast.warning('Aucune transaction reconnue. Format PDF non supporté ?')
    } catch (err) {
      console.error(err)
      toast.error('Erreur lors de l\'analyse du PDF')
    } finally {
      setParsing(false)
      if (fileInput.current) fileInput.current.value = ''
    }
  }

  const updateCategory = (id: string, cat: Category) => {
    transactionsStore.updateCategory(id, cat)
    refresh()
  }

  const removeTx = (id: string) => {
    transactionsStore.remove(id)
    refresh()
  }

  const clearAll = () => {
    if (!confirm('Effacer toutes les transactions importées ?')) return
    transactionsStore.clear()
    refresh()
    toast.success('Données effacées')
  }

  /* Re-classify every non-manual transaction with Claude. Manual overrides
     are preserved; rule-based categories get replaced when AI is more
     confident. */
  const reclassifyWithAI = async () => {
    const targets = transactions.filter(t => !t.manual_override)
    if (targets.length === 0) {
      toast.info('Aucune transaction à reclasser')
      return
    }
    setAiBusy(true)
    try {
      const map = await classifyWithAI(targets)
      let updated = 0
      for (const [id, r] of map) {
        if (r.confidence < 0.4) continue
        transactionsStore.updateCategory(id, r.category)
        // updateCategory marks manual_override = true, which is wrong here —
        // we want the AI result to remain auto so the user can re-run later.
        // Reset that flag below by writing through the raw store.
        updated++
      }
      // Patch: clear manual_override flag on AI-classified ones
      const list = transactionsStore.list().map(t => {
        if (map.has(t.id) && map.get(t.id)!.confidence >= 0.4) {
          return { ...t, manual_override: false, ai_confidence: map.get(t.id)!.confidence }
        }
        return t
      })
      localStorage.setItem('gestiq_finance_ai_transactions', JSON.stringify(list))
      refresh()
      toast.success(`${updated} transaction(s) reclassée(s) par Claude`)
    } catch (err: any) {
      console.error(err)
      toast.error(err?.message?.includes('503') || err?.message?.includes('non configuré')
        ? 'IA non configurée côté serveur. Voir README.'
        : `Erreur IA : ${err?.message ?? 'inconnu'}`)
    } finally {
      setAiBusy(false)
    }
  }

  const kpis      = useMemo(() => computeKPIs(transactions), [transactions])
  const byCat     = useMemo(() => expensesByCategory(transactions), [transactions])
  const monthly   = useMemo(() => monthlyEvolution(transactions), [transactions])
  const alerts    = useMemo(() => generateAlerts(transactions), [transactions])
  const recurring = useMemo(() => detectRecurring(transactions), [transactions])
  const tops      = useMemo(() => topClients(transactions), [transactions])
  const sources   = useMemo(() => transactionsStore.bySource(), [transactions])

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase()
    return transactions.filter(t => {
      if (filterCategory !== 'all' && t.category !== filterCategory) return false
      if (q && !t.label.toLowerCase().includes(q)) return false
      return true
    })
  }, [transactions, search, filterCategory])

  const incomes  = filtered.filter(t => t.amount >= 0)
  const expenses = filtered.filter(t => t.amount < 0)

  return (
    <div className="space-y-6">
      {/* ── Header ── */}
      <div className="flex items-start justify-between flex-wrap gap-4">
        <div>
          <div className="flex items-center gap-2">
            <Sparkles className="w-5 h-5 text-violet-500" />
            <h1 className="text-2xl font-bold tracking-tight text-foreground">Finance Intelligence</h1>
            <Badge variant="default" className="bg-gradient-to-r from-blue-600 to-violet-600 text-white border-0">IA</Badge>
          </div>
          <p className="text-sm text-muted-foreground mt-1">
            Importez vos relevés bancaires PDF et obtenez une analyse financière intelligente automatique.
          </p>
        </div>
        <div className="flex items-center gap-2">
          <input
            ref={fileInput}
            type="file"
            accept="application/pdf"
            multiple
            className="hidden"
            onChange={onFile}
          />
          <Button onClick={() => fileInput.current?.click()} disabled={parsing}>
            {parsing
              ? (<><RefreshCw className="w-4 h-4 mr-2 animate-spin" /> Analyse…</>)
              : (<><Upload className="w-4 h-4 mr-2" /> Importer un relevé</>)}
          </Button>
          {transactions.length > 0 && aiEnabled && (
            <Button variant="outline" onClick={reclassifyWithAI} disabled={aiBusy}
              title="Reclasser toutes les transactions avec Claude (Anthropic)">
              {aiBusy
                ? (<><RefreshCw className="w-4 h-4 mr-2 animate-spin" /> IA…</>)
                : (<><Bot className="w-4 h-4 mr-2" /> Reclasser avec Claude</>)}
            </Button>
          )}
          {transactions.length > 0 && (
            <Button variant="outline" onClick={clearAll}>
              <Trash2 className="w-4 h-4 mr-2" /> Effacer
            </Button>
          )}
        </div>
      </div>

      {/* ── KPI cards ── */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
        <KpiCard label="Revenus" value={kpis.totalIncome} icon={TrendingUp}    color="text-emerald-600" bg="bg-emerald-50 dark:bg-emerald-950/40" />
        <KpiCard label="Dépenses" value={kpis.totalExpense} icon={TrendingDown} color="text-rose-600"    bg="bg-rose-50 dark:bg-rose-950/40" />
        <KpiCard label="Profit net" value={kpis.netProfit} icon={Wallet} color={kpis.netProfit >= 0 ? 'text-emerald-600' : 'text-rose-600'} bg="bg-blue-50 dark:bg-blue-950/40" highlight />
        <KpiCard label="Cash retiré" value={kpis.cashWithdrawn} icon={Banknote} color="text-amber-600" bg="bg-amber-50 dark:bg-amber-950/40" />
        <KpiCard label="Freelances" value={kpis.freelancesPaid} icon={Users} color="text-violet-600" bg="bg-violet-50 dark:bg-violet-950/40" />
        <KpiCard label="Publicité" value={kpis.adSpend} icon={Megaphone} color="text-pink-600" bg="bg-pink-50 dark:bg-pink-950/40" />
      </div>

      {transactions.length === 0 ? (
        <EmptyState onUpload={() => fileInput.current?.click()} />
      ) : (
        <Tabs defaultValue="releves">
          <TabsList>
            <TabsTrigger value="releves">Relevés</TabsTrigger>
            <TabsTrigger value="analyse">Analyse</TabsTrigger>
            <TabsTrigger value="depenses">Dépenses</TabsTrigger>
            <TabsTrigger value="revenus">Revenus</TabsTrigger>
            <TabsTrigger value="rapports">Rapports</TabsTrigger>
            <TabsTrigger value="previsions">Prévisions</TabsTrigger>
          </TabsList>

          {/* Relevés */}
          <TabsContent value="releves" className="space-y-4">
            <Card>
              <CardHeader>
                <CardTitle>Relevés importés</CardTitle>
              </CardHeader>
              <CardContent>
                {sources.length === 0 ? (
                  <p className="text-sm text-muted-foreground">Aucun fichier importé.</p>
                ) : (
                  <div className="space-y-2">
                    {sources.map(s => (
                      <div key={s.source} className="flex items-center justify-between p-3 rounded-lg border border-[var(--surface-card-border)]">
                        <div className="flex items-center gap-3 min-w-0">
                          <FileText className="w-4 h-4 text-blue-500 flex-shrink-0" />
                          <div className="min-w-0">
                            <p className="text-sm font-medium truncate">{s.source}</p>
                            <p className="text-xs text-muted-foreground">{s.count} transactions · solde {formatCurrency(s.total)}</p>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </CardContent>
            </Card>

            <Card className="border-dashed border-2">
              <CardContent className="p-6 text-center">
                <Sparkles className="w-8 h-8 mx-auto text-violet-500 mb-2" />
                <p className="text-sm text-muted-foreground mb-3">
                  Formats supportés : Attijariwafa, CIH, Banque Populaire, SGMB, et la plupart des PDF de relevés bancaires.
                </p>
                <Button onClick={() => fileInput.current?.click()} disabled={parsing} variant="outline">
                  <Upload className="w-4 h-4 mr-2" /> Importer un autre relevé
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Analyse — full transaction list with category override */}
          <TabsContent value="analyse" className="space-y-4">
            <div className="flex flex-wrap items-center gap-2">
              <div className="relative flex-1 min-w-[220px]">
                <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
                <Input
                  value={search}
                  onChange={e => setSearch(e.target.value)}
                  placeholder="Rechercher un libellé…"
                  className="pl-9"
                />
              </div>
              <select
                value={filterCategory}
                onChange={e => setFilterCategory(e.target.value as Category | 'all')}
                className="h-10 px-3 rounded-md border border-[var(--surface-card-border)] bg-[var(--surface-card)] text-sm"
              >
                <option value="all">Toutes catégories</option>
                {ALL_CATEGORIES.map(c => <option key={c} value={c}>{CATEGORY_LABELS[c]}</option>)}
              </select>
              <span className="text-xs text-muted-foreground">{filtered.length} / {transactions.length}</span>
            </div>
            <TransactionTable rows={filtered} onCategory={updateCategory} onRemove={removeTx} />
          </TabsContent>

          <TabsContent value="depenses">
            <TransactionTable rows={expenses} onCategory={updateCategory} onRemove={removeTx} />
          </TabsContent>

          <TabsContent value="revenus">
            <TransactionTable rows={incomes} onCategory={updateCategory} onRemove={removeTx} />
          </TabsContent>

          {/* Rapports */}
          <TabsContent value="rapports" className="space-y-4">
            {alerts.length > 0 && (
              <div className="grid gap-2 md:grid-cols-2 lg:grid-cols-3">
                {alerts.map(a => (
                  <div
                    key={a.id}
                    className={`p-3 rounded-lg border flex gap-3 ${
                      a.level === 'critical' ? 'border-rose-300 bg-rose-50/50 dark:bg-rose-950/30' :
                      a.level === 'warning'  ? 'border-amber-300 bg-amber-50/50 dark:bg-amber-950/30' :
                                               'border-blue-300 bg-blue-50/50 dark:bg-blue-950/30'
                    }`}
                  >
                    <AlertTriangle className={`w-4 h-4 flex-shrink-0 mt-0.5 ${
                      a.level === 'critical' ? 'text-rose-600' :
                      a.level === 'warning'  ? 'text-amber-600' : 'text-blue-600'
                    }`} />
                    <div>
                      <p className="text-sm font-semibold">{a.title}</p>
                      <p className="text-xs text-muted-foreground mt-0.5">{a.message}</p>
                    </div>
                  </div>
                ))}
              </div>
            )}

            <div className="grid gap-4 lg:grid-cols-2">
              <Card>
                <CardHeader><CardTitle>Dépenses par catégorie</CardTitle></CardHeader>
                <CardContent>
                  {byCat.length === 0 ? <Empty /> : (
                    <ResponsiveContainer width="100%" height={280}>
                      <PieChart>
                        <Pie data={byCat} dataKey="total" nameKey="category" outerRadius={100} innerRadius={55} paddingAngle={2}>
                          {byCat.map(d => <Cell key={d.category} fill={CATEGORY_COLORS[d.category]} />)}
                        </Pie>
                        <Tooltip formatter={(v: number, _n, p) => [formatCurrency(v), CATEGORY_LABELS[p.payload.category as Category]]} />
                        <Legend formatter={(v) => CATEGORY_LABELS[v as Category]} />
                      </PieChart>
                    </ResponsiveContainer>
                  )}
                </CardContent>
              </Card>

              <Card>
                <CardHeader><CardTitle>Évolution mensuelle</CardTitle></CardHeader>
                <CardContent>
                  {monthly.length === 0 ? <Empty /> : (
                    <ResponsiveContainer width="100%" height={280}>
                      <AreaChart data={monthly}>
                        <CartesianGrid strokeDasharray="3 3" stroke="var(--surface-card-border)" />
                        <XAxis dataKey="month" stroke="currentColor" fontSize={12} />
                        <YAxis stroke="currentColor" fontSize={12} />
                        <Tooltip formatter={(v: number) => formatCurrency(v)} />
                        <Area type="monotone" dataKey="income"  stroke="#10b981" fill="#10b98133" name="Revenus" />
                        <Area type="monotone" dataKey="expense" stroke="#f43f5e" fill="#f43f5e33" name="Dépenses" />
                      </AreaChart>
                    </ResponsiveContainer>
                  )}
                </CardContent>
              </Card>

              <Card>
                <CardHeader><CardTitle>Top sources de revenus</CardTitle></CardHeader>
                <CardContent>
                  {tops.length === 0 ? <Empty /> : (
                    <ResponsiveContainer width="100%" height={280}>
                      <BarChart data={tops} layout="vertical" margin={{ left: 60 }}>
                        <CartesianGrid strokeDasharray="3 3" stroke="var(--surface-card-border)" />
                        <XAxis type="number" stroke="currentColor" fontSize={12} />
                        <YAxis type="category" dataKey="label" stroke="currentColor" fontSize={11} width={140} />
                        <Tooltip formatter={(v: number) => formatCurrency(v)} />
                        <Bar dataKey="total" fill="#22c55e" radius={[0, 4, 4, 0]} />
                      </BarChart>
                    </ResponsiveContainer>
                  )}
                </CardContent>
              </Card>

              <Card>
                <CardHeader><CardTitle>Abonnements récurrents détectés</CardTitle></CardHeader>
                <CardContent>
                  {recurring.length === 0 ? <Empty text="Aucun abonnement récurrent identifié." /> : (
                    <div className="space-y-1.5 max-h-72 overflow-y-auto pr-2">
                      {recurring.map(r => (
                        <div key={r.label} className="flex items-center justify-between p-2 rounded-md hover:bg-[var(--surface-card-border)]/30 text-sm">
                          <span className="truncate flex items-center gap-2">
                            <Server className="w-3.5 h-3.5 text-cyan-500" />
                            {r.label}
                          </span>
                          <span className="text-xs text-muted-foreground whitespace-nowrap">
                            ~{formatCurrency(r.avg)} × {r.months} mois
                          </span>
                        </div>
                      ))}
                    </div>
                  )}
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          <TabsContent value="previsions">
            <Card>
              <CardHeader><CardTitle>Prévisions de cashflow</CardTitle></CardHeader>
              <CardContent>
                <Forecast monthly={monthly} />
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      )}
    </div>
  )
}

/* ── Sub-components ── */

function KpiCard(props: {
  label: string; value: number; icon: React.ElementType
  color: string; bg: string; highlight?: boolean
}) {
  const Icon = props.icon
  return (
    <motion.div
      initial={{ opacity: 0, y: 6 }}
      animate={{ opacity: 1, y: 0 }}
      className={`rounded-xl border p-4 ${props.bg} border-[var(--surface-card-border)] ${props.highlight ? 'ring-1 ring-blue-500/30' : ''}`}
    >
      <div className="flex items-center justify-between">
        <span className="text-xs font-medium text-muted-foreground">{props.label}</span>
        <Icon className={`w-4 h-4 ${props.color}`} />
      </div>
      <p className={`text-lg font-bold mt-1 ${props.color}`}>{formatCurrency(props.value)}</p>
    </motion.div>
  )
}

function TransactionTable({
  rows, onCategory, onRemove,
}: {
  rows: BankTransaction[]
  onCategory: (id: string, c: Category) => void
  onRemove:   (id: string) => void
}) {
  if (rows.length === 0) {
    return (
      <Card><CardContent className="py-10 text-center text-sm text-muted-foreground">
        Aucune transaction.
      </CardContent></Card>
    )
  }
  return (
    <Card>
      <CardContent className="p-0 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-[var(--surface-card-border)]/30">
              <tr className="text-left text-xs uppercase tracking-wider text-muted-foreground">
                <th className="px-4 py-2.5">Date</th>
                <th className="px-4 py-2.5">Libellé</th>
                <th className="px-4 py-2.5">Catégorie</th>
                <th className="px-4 py-2.5 text-right">Montant</th>
                <th className="px-4 py-2.5 w-12"></th>
              </tr>
            </thead>
            <tbody>
              {rows.map(t => (
                <tr key={t.id} className="border-t border-[var(--surface-card-border)] hover:bg-[var(--surface-card-border)]/20">
                  <td className="px-4 py-2.5 whitespace-nowrap text-muted-foreground">{t.date}</td>
                  <td className="px-4 py-2.5">
                    <div className="flex items-center gap-2">
                      <span className="truncate max-w-[280px]">{t.label}</span>
                      {!t.manual_override && (
                        <span title={`Confiance IA: ${(t.ai_confidence * 100).toFixed(0)}%`}
                              className={`text-[10px] px-1.5 py-0.5 rounded font-semibold ${
                                t.ai_confidence > 0.8 ? 'bg-emerald-100 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-300' :
                                t.ai_confidence > 0.5 ? 'bg-amber-100 text-amber-700 dark:bg-amber-950/40 dark:text-amber-300' :
                                                        'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300'
                              }`}>
                          IA {(t.ai_confidence * 100).toFixed(0)}%
                        </span>
                      )}
                    </div>
                  </td>
                  <td className="px-4 py-2.5">
                    <select
                      value={t.category}
                      onChange={e => onCategory(t.id, e.target.value as Category)}
                      className="h-8 px-2 rounded border border-[var(--surface-card-border)] bg-[var(--surface-card)] text-xs"
                      style={{ borderLeft: `3px solid ${CATEGORY_COLORS[t.category]}` }}
                    >
                      {ALL_CATEGORIES.map(c => <option key={c} value={c}>{CATEGORY_LABELS[c]}</option>)}
                    </select>
                  </td>
                  <td className={`px-4 py-2.5 text-right font-semibold whitespace-nowrap ${t.amount >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
                    {t.amount >= 0 ? '+' : ''}{formatCurrency(t.amount)}
                  </td>
                  <td className="px-4 py-2.5">
                    <button
                      onClick={() => onRemove(t.id)}
                      className="text-muted-foreground hover:text-rose-500 transition-colors"
                      title="Supprimer"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </CardContent>
    </Card>
  )
}

function EmptyState({ onUpload }: { onUpload: () => void }) {
  return (
    <Card className="border-dashed border-2">
      <CardContent className="py-16 text-center">
        <div className="mx-auto w-16 h-16 rounded-2xl bg-gradient-to-br from-blue-500 to-violet-600 flex items-center justify-center mb-4">
          <Sparkles className="w-8 h-8 text-white" />
        </div>
        <h2 className="text-lg font-bold mb-2">Importez votre premier relevé bancaire</h2>
        <p className="text-sm text-muted-foreground max-w-md mx-auto mb-6">
          Le système lit automatiquement vos opérations, identifie les revenus, dépenses, retraits cash, paiements freelances, publicité Meta/Google, hébergements et abonnements SaaS.
        </p>
        <Button onClick={onUpload}>
          <Upload className="w-4 h-4 mr-2" /> Importer un PDF
        </Button>
        <p className="text-xs text-muted-foreground mt-4">
          Attijariwafa · CIH · Banque Populaire · SGMB · autres
        </p>
      </CardContent>
    </Card>
  )
}

function Empty({ text = 'Pas encore de données.' }: { text?: string }) {
  return <p className="text-sm text-muted-foreground py-6 text-center">{text}</p>
}

function Forecast({ monthly }: { monthly: { month: string; net: number }[] }) {
  if (monthly.length < 2) {
    return <Empty text="Importez au moins 2 mois de relevés pour générer une prévision." />
  }
  const avg = monthly.reduce((s, m) => s + m.net, 0) / monthly.length
  const last = monthly[monthly.length - 1]
  const next3 = Array.from({ length: 3 }, (_, i) => {
    const [y, m] = last.month.split('-').map(Number)
    const d = new Date(y, m - 1 + i + 1, 1)
    return {
      month: `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`,
      net: avg,
      forecast: true,
    }
  })
  const data = [...monthly.map(m => ({ ...m, forecast: false })), ...next3]

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">
        Basé sur la moyenne de votre flux net mensuel ({formatCurrency(avg)}/mois). Les 3 prochains mois sont projetés.
      </p>
      <ResponsiveContainer width="100%" height={280}>
        <AreaChart data={data}>
          <CartesianGrid strokeDasharray="3 3" stroke="var(--surface-card-border)" />
          <XAxis dataKey="month" stroke="currentColor" fontSize={12} />
          <YAxis stroke="currentColor" fontSize={12} />
          <Tooltip formatter={(v: number) => formatCurrency(v)} />
          <Area type="monotone" dataKey="net" stroke="#3b82f6" fill="#3b82f633" name="Cashflow net" />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  )
}
