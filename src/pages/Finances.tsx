import { useMemo } from 'react'
import { useQuery } from '@tanstack/react-query'
import { motion } from 'framer-motion'
import { TrendingUp, TrendingDown, Wallet, CreditCard, AlertTriangle, DollarSign } from 'lucide-react'
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar, Cell } from 'recharts'
import { useFactures } from '@/hooks/useFactures'
import { useDepenses } from '@/hooks/useDepenses'
import { formatCurrency } from '@/lib/utils'
import { bankAccountsApi, creditsDettesApi } from '@/lib/api'

interface BankAccount { id: string; nom: string; solde: number; iban: string; couleur: string }
interface Credit      { id: string; nom: string; montant: number; mensualite: number; echeances: number; couleur: string }

export default function Finances() {
  const { data: factures     = [] } = useFactures()
  const { data: depenses     = [] } = useDepenses()
  const { data: bankAccounts = [] } = useQuery<BankAccount[]>({
    queryKey: ['bank_accounts'],
    queryFn:  () => bankAccountsApi.list() as Promise<BankAccount[]>,
  })
  const { data: credits      = [] } = useQuery<Credit[]>({
    queryKey: ['credits_dettes'],
    queryFn:  () => creditsDettesApi.list() as Promise<Credit[]>,
  })

  const MONTHS_FR = ['Jan','Fév','Mar','Avr','Mai','Jun','Jul','Aoû','Sep','Oct','Nov','Déc']

  const { stats, cashflowData } = useMemo(() => {
    const totalCA       = factures.filter(f => f.statut === 'payee').reduce((s, f) => s + f.montant_ttc, 0)
    const totalDepenses = depenses.reduce((s, d) => s + d.montant, 0)
    const profit        = totalCA - totalDepenses
    const totalBanque   = bankAccounts.reduce((s, a) => s + a.solde, 0)
    const totalDettes   = credits.reduce((s, c) => s + c.montant, 0)

    const now = new Date()
    const cashflowData = Array.from({ length: 4 }, (_, i) => {
      const d = new Date(now.getFullYear(), now.getMonth() - 3 + i, 1)
      const prefix = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
      const entrees = factures
        .filter(f => f.statut === 'payee' && f.date_emission?.startsWith(prefix))
        .reduce((s, f) => s + f.montant_ttc, 0)
      const sorties = depenses
        .filter(dep => dep.date_depense?.startsWith(prefix))
        .reduce((s, dep) => s + dep.montant, 0)
      return { mois: MONTHS_FR[d.getMonth()], entrees, sorties }
    })

    return { stats: { totalCA, totalDepenses, profit, totalBanque, totalDettes }, cashflowData }
  }, [factures, depenses, bankAccounts, credits])

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title">Finances</h1>
          <p className="text-muted-foreground text-sm mt-1">Vue d'ensemble financière</p>
        </div>
      </div>

      {/* KPIs */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0 }} className="card-premium p-5">
          <div className="flex items-center justify-between mb-3">
            <p className="text-xs text-muted-foreground uppercase tracking-wider">CA Encaissé</p>
            <div className="w-9 h-9 rounded-lg bg-emerald-500/20 flex items-center justify-center">
              <TrendingUp className="w-4 h-4 text-emerald-600 dark:text-emerald-400" />
            </div>
          </div>
          <p className="text-xl font-bold text-emerald-600 dark:text-emerald-400">{formatCurrency(stats.totalCA)}</p>
        </motion.div>
        <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.06 }} className="card-premium p-5">
          <div className="flex items-center justify-between mb-3">
            <p className="text-xs text-muted-foreground uppercase tracking-wider">Dépenses</p>
            <div className="w-9 h-9 rounded-lg bg-red-500/20 flex items-center justify-center">
              <TrendingDown className="w-4 h-4 text-red-600 dark:text-red-400" />
            </div>
          </div>
          <p className="text-xl font-bold text-red-600 dark:text-red-400">{formatCurrency(stats.totalDepenses)}</p>
        </motion.div>
        <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.12 }} className="card-premium p-5">
          <div className="flex items-center justify-between mb-3">
            <p className="text-xs text-muted-foreground uppercase tracking-wider">Profit Net</p>
            <div className={`w-9 h-9 rounded-lg flex items-center justify-center ${stats.profit > 0 ? 'bg-emerald-500/20' : 'bg-red-500/20'}`}>
              <DollarSign className={`w-4 h-4 ${stats.profit > 0 ? 'text-emerald-600 dark:text-emerald-400' : 'text-red-600 dark:text-red-400'}`} />
            </div>
          </div>
          <p className={`text-xl font-bold ${stats.profit > 0 ? 'text-emerald-600 dark:text-emerald-400' : 'text-red-600 dark:text-red-400'}`}>{formatCurrency(stats.profit)}</p>
        </motion.div>
        <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.18 }} className="card-premium p-5">
          <div className="flex items-center justify-between mb-3">
            <p className="text-xs text-muted-foreground uppercase tracking-wider">Trésorerie</p>
            <div className="w-9 h-9 rounded-lg bg-blue-500/20 flex items-center justify-center">
              <Wallet className="w-4 h-4 text-blue-600 dark:text-blue-400" />
            </div>
          </div>
          <p className="text-xl font-bold text-blue-600 dark:text-blue-400">{formatCurrency(stats.totalBanque)}</p>
        </motion.div>
      </div>

      {/* Cash Flow Chart */}
      <div className="card-premium p-5">
        <h2 className="section-title mb-4">Cash Flow — 4 derniers mois</h2>
        <ResponsiveContainer width="100%" height={220}>
          <BarChart data={cashflowData} margin={{ top: 5, right: 5, bottom: 5, left: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
            <XAxis dataKey="mois" tick={{ fill: '#64748b', fontSize: 11 }} />
            <YAxis tick={{ fill: '#64748b', fontSize: 11 }} tickFormatter={v => `${v/1000}k`} />
            <Tooltip
              contentStyle={{ backgroundColor: 'white', border: '1px solid #e2e8f0', borderRadius: 8, color: '#1e293b' }}
              formatter={(v: any) => [`${v.toLocaleString('fr-FR')} MAD`]}
            />
            <Bar dataKey="entrees" fill="#3b82f6" name="Entrées" radius={[4, 4, 0, 0]} />
            <Bar dataKey="sorties" fill="#ef4444" name="Sorties" radius={[4, 4, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Bank Accounts */}
        <div className="card-premium p-5">
          <h2 className="section-title mb-4 flex items-center gap-2">
            <Wallet className="w-4 h-4 text-blue-600 dark:text-blue-400" />
            Comptes bancaires
          </h2>
          <div className="space-y-3">
            {bankAccounts.length === 0 && (
              <p className="text-xs text-muted-foreground text-center py-4">Aucun compte bancaire enregistré</p>
            )}
            {bankAccounts.map((account) => (
              <div key={account.id} className="flex items-center justify-between p-3 bg-muted rounded-lg border border-border">
                <div>
                  <p className="text-sm font-medium text-foreground">{account.nom}</p>
                  <p className="text-xs text-muted-foreground font-mono">{account.iban}</p>
                </div>
                <p className="text-sm font-bold text-blue-600 dark:text-blue-400">{formatCurrency(account.solde)}</p>
              </div>
            ))}
            <div className="pt-3 border-t border-border flex items-center justify-between">
              <span className="text-sm font-medium text-muted-foreground">Total trésorerie</span>
              <span className="text-base font-bold text-foreground">{formatCurrency(stats.totalBanque)}</span>
            </div>
          </div>
        </div>

        {/* Credits */}
        <div className="card-premium p-5">
          <h2 className="section-title mb-4 flex items-center gap-2">
            <CreditCard className="w-4 h-4 text-red-600 dark:text-red-400" />
            Crédits & Dettes
          </h2>
          <div className="space-y-3">
            {credits.length === 0 && (
              <p className="text-xs text-muted-foreground text-center py-4">Aucun crédit enregistré</p>
            )}
            {credits.map((credit) => (
              <div key={credit.id} className="p-3 bg-muted rounded-lg border border-border">
                <div className="flex items-center justify-between mb-2">
                  <p className="text-sm font-medium text-foreground">{credit.nom}</p>
                  <p className="text-sm font-bold text-red-600 dark:text-red-400">{formatCurrency(credit.montant)}</p>
                </div>
                <div className="flex items-center justify-between text-xs text-muted-foreground">
                  <span>Mensualité : {formatCurrency(credit.mensualite)}</span>
                  <span>{credit.echeances} échéances restantes</span>
                </div>
                <div className="mt-2 h-1.5 bg-border rounded-full overflow-hidden">
                  <div
                    className="h-full bg-red-500/60 rounded-full"
                    style={{ width: `${(credit.echeances / 36) * 100}%` }}
                  />
                </div>
              </div>
            ))}
            <div className="pt-3 border-t border-border flex items-center justify-between">
              <span className="text-sm font-medium text-muted-foreground">Total dettes</span>
              <span className="text-base font-bold text-red-600 dark:text-red-400">{formatCurrency(stats.totalDettes)}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
