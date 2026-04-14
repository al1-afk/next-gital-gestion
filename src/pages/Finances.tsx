import { useMemo } from 'react'
import { motion } from 'framer-motion'
import { TrendingUp, TrendingDown, Wallet, CreditCard, AlertTriangle, DollarSign } from 'lucide-react'
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar, Cell } from 'recharts'
import { useFactures } from '@/hooks/useFactures'
import { useDepenses } from '@/hooks/useDepenses'
import { formatCurrency } from '@/lib/utils'

const BANK_ACCOUNTS = [
  { nom: 'CIH Bank - Compte Principal', solde: 187450, iban: 'MA**** **** 4521', color: 'blue' },
  { nom: 'Attijariwafa - Épargne', solde: 95000, iban: 'MA**** **** 7823', color: 'emerald' },
  { nom: 'BMCE - Opérations', solde: 43200, iban: 'MA**** **** 3341', color: 'purple' },
]

const CREDITS = [
  { nom: 'Crédit équipement', montant: 120000, mensualite: 4500, echeances: 28, color: 'red' },
  { nom: 'Leasing véhicule', montant: 45000, mensualite: 1800, echeances: 20, color: 'orange' },
]

const CASHFLOW_DATA = [
  { mois: 'Jan', entrees: 45000, sorties: 32000 },
  { mois: 'Fév', entrees: 52000, sorties: 38000 },
  { mois: 'Mar', entrees: 48000, sorties: 35000 },
  { mois: 'Avr', entrees: 65000, sorties: 42000 },
]

export default function Finances() {
  const { data: factures = [] } = useFactures()
  const { data: depenses = [] } = useDepenses()

  const stats = useMemo(() => {
    const totalCA = factures.filter(f => f.statut === 'payee').reduce((s, f) => s + f.montant_ttc, 0)
    const totalDepenses = depenses.reduce((s, d) => s + d.montant, 0)
    const profit = totalCA - totalDepenses
    const totalBanque = BANK_ACCOUNTS.reduce((s, a) => s + a.solde, 0)
    const totalDettes = CREDITS.reduce((s, c) => s + c.montant, 0)
    return { totalCA, totalDepenses, profit, totalBanque, totalDettes }
  }, [factures, depenses])

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
        {[
          { label: 'CA Encaissé', value: formatCurrency(stats.totalCA), icon: TrendingUp, color: 'emerald' },
          { label: 'Dépenses', value: formatCurrency(stats.totalDepenses), icon: TrendingDown, color: 'red' },
          { label: 'Profit Net', value: formatCurrency(stats.profit), icon: DollarSign, color: stats.profit > 0 ? 'emerald' : 'red' },
          { label: 'Trésorerie', value: formatCurrency(stats.totalBanque), icon: Wallet, color: 'blue' },
        ].map((kpi, i) => (
          <motion.div
            key={kpi.label}
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.06 }}
            className={`card p-5 border-${kpi.color}-500/20`}
          >
            <div className="flex items-center justify-between mb-3">
              <p className="text-xs text-muted-foreground uppercase tracking-wider">{kpi.label}</p>
              <div className={`w-9 h-9 rounded-lg bg-${kpi.color}-500/20 flex items-center justify-center`}>
                <kpi.icon className={`w-4 h-4 text-${kpi.color}-400`} />
              </div>
            </div>
            <p className={`text-xl font-bold text-${kpi.color}-400`}>{kpi.value}</p>
          </motion.div>
        ))}
      </div>

      {/* Cash Flow Chart */}
      <div className="card p-5">
        <h2 className="section-title mb-4">Cash Flow — 4 derniers mois</h2>
        <ResponsiveContainer width="100%" height={220}>
          <BarChart data={CASHFLOW_DATA} margin={{ top: 5, right: 5, bottom: 5, left: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#1e293b" />
            <XAxis dataKey="mois" tick={{ fill: '#64748b', fontSize: 11 }} />
            <YAxis tick={{ fill: '#64748b', fontSize: 11 }} tickFormatter={v => `${v/1000}k`} />
            <Tooltip
              contentStyle={{ backgroundColor: '#0f172a', border: '1px solid #1e293b', borderRadius: 8 }}
              formatter={(v: any) => [`${v.toLocaleString('fr-FR')} MAD`]}
            />
            <Bar dataKey="entrees" fill="#3b82f6" name="Entrées" radius={[4, 4, 0, 0]} />
            <Bar dataKey="sorties" fill="#ef4444" name="Sorties" radius={[4, 4, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Bank Accounts */}
        <div className="card p-5">
          <h2 className="section-title mb-4 flex items-center gap-2">
            <Wallet className="w-4 h-4 text-blue-400" />
            Comptes bancaires
          </h2>
          <div className="space-y-3">
            {BANK_ACCOUNTS.map((account, i) => (
              <div key={i} className="flex items-center justify-between p-3 bg-muted rounded-lg border border-border">
                <div>
                  <p className="text-sm font-medium text-foreground">{account.nom}</p>
                  <p className="text-xs text-muted-foreground font-mono">{account.iban}</p>
                </div>
                <p className={`text-sm font-bold text-${account.color}-400`}>{formatCurrency(account.solde)}</p>
              </div>
            ))}
            <div className="pt-3 border-t border-border flex items-center justify-between">
              <span className="text-sm font-medium text-muted-foreground">Total trésorerie</span>
              <span className="text-base font-bold text-foreground">{formatCurrency(stats.totalBanque)}</span>
            </div>
          </div>
        </div>

        {/* Credits */}
        <div className="card p-5">
          <h2 className="section-title mb-4 flex items-center gap-2">
            <CreditCard className="w-4 h-4 text-red-400" />
            Crédits & Dettes
          </h2>
          <div className="space-y-3">
            {CREDITS.map((credit, i) => (
              <div key={i} className="p-3 bg-muted rounded-lg border border-border">
                <div className="flex items-center justify-between mb-2">
                  <p className="text-sm font-medium text-foreground">{credit.nom}</p>
                  <p className="text-sm font-bold text-red-400">{formatCurrency(credit.montant)}</p>
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
              <span className="text-base font-bold text-red-400">{formatCurrency(stats.totalDettes)}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
