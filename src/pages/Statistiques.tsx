import { useMemo } from 'react'
import { motion } from 'framer-motion'
import {
  AreaChart, Area, BarChart, Bar, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend, LineChart, Line
} from 'recharts'
import { useProspects } from '@/hooks/useProspects'
import { useFactures } from '@/hooks/useFactures'
import { useClients } from '@/hooks/useClients'
import { formatCurrency } from '@/lib/utils'
import { TrendingUp, TrendingDown, Target, Users } from 'lucide-react'

const MONTHLY_DATA = [
  { mois: 'Jan', ca: 45000, prospects: 12, clients: 3 },
  { mois: 'Fév', ca: 52000, prospects: 18, clients: 5 },
  { mois: 'Mar', ca: 48000, prospects: 15, clients: 4 },
  { mois: 'Avr', ca: 65000, prospects: 22, clients: 7 },
]

const CONVERSION_DATA = [
  { stage: 'Lead Brut', count: 45 },
  { stage: 'Contact', count: 30 },
  { stage: 'Qualifié', count: 20 },
  { stage: 'Proposition', count: 12 },
  { stage: 'Négociation', count: 8 },
  { stage: 'Gagné', count: 5 },
]

const COLORS = ['#3b82f6', '#8b5cf6', '#06b6d4', '#10b981', '#f59e0b', '#ef4444']

export default function Statistiques() {
  const { data: prospects = [] } = useProspects()
  const { data: factures = [] } = useFactures()
  const { data: clients = [] } = useClients()

  const stats = useMemo(() => {
    const totalCA = factures.filter(f => f.statut === 'payee').reduce((s, f) => s + f.montant_ttc, 0)
    const tauxConversion = prospects.length > 0
      ? ((prospects.filter(p => p.statut === 'gagne').length / prospects.length) * 100).toFixed(1)
      : 0
    const valeurMoyenne = prospects.filter(p => p.valeur_estimee).length > 0
      ? prospects.filter(p => p.valeur_estimee).reduce((s, p) => s + (p.valeur_estimee || 0), 0) / prospects.filter(p => p.valeur_estimee).length
      : 0
    return { totalCA, tauxConversion, valeurMoyenne, nbProspects: prospects.length }
  }, [prospects, factures])

  return (
    <div className="space-y-6 animate-fade-in">
      <div>
        <h1 className="page-title">Statistiques & Analytique</h1>
        <p className="text-muted-foreground text-sm mt-1">Performance globale de votre activité</p>
      </div>

      {/* KPIs */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { label: 'CA Total', value: formatCurrency(stats.totalCA), icon: TrendingUp, color: 'emerald' },
          { label: 'Taux conversion', value: `${stats.tauxConversion}%`, icon: Target, color: 'blue' },
          { label: 'Valeur prospect moy.', value: formatCurrency(stats.valeurMoyenne), icon: TrendingDown, color: 'purple' },
          { label: 'Clients actifs', value: String(clients.length), icon: Users, color: 'cyan' },
        ].map((kpi, i) => (
          <motion.div key={kpi.label} initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.06 }}
            className="card p-5">
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

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Revenue trend */}
        <div className="card p-5">
          <h2 className="section-title mb-4">Évolution du CA</h2>
          <ResponsiveContainer width="100%" height={220}>
            <AreaChart data={MONTHLY_DATA}>
              <defs>
                <linearGradient id="colorCA2" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.3} />
                  <stop offset="95%" stopColor="#3b82f6" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#1e293b" />
              <XAxis dataKey="mois" tick={{ fill: '#64748b', fontSize: 11 }} />
              <YAxis tick={{ fill: '#64748b', fontSize: 11 }} tickFormatter={v => `${v/1000}k`} />
              <Tooltip contentStyle={{ backgroundColor: '#0f172a', border: '1px solid #1e293b', borderRadius: 8 }}
                formatter={(v: any) => [`${v.toLocaleString('fr-FR')} MAD`]} />
              <Area type="monotone" dataKey="ca" stroke="#3b82f6" strokeWidth={2} fill="url(#colorCA2)" />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* Prospects funnel */}
        <div className="card p-5">
          <h2 className="section-title mb-4">Entonnoir de conversion</h2>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={CONVERSION_DATA} layout="vertical" margin={{ top: 5, right: 20, bottom: 5, left: 60 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#1e293b" horizontal={false} />
              <XAxis type="number" tick={{ fill: '#64748b', fontSize: 11 }} />
              <YAxis type="category" dataKey="stage" tick={{ fill: '#94a3b8', fontSize: 11 }} />
              <Tooltip contentStyle={{ backgroundColor: '#0f172a', border: '1px solid #1e293b', borderRadius: 8 }} />
              <Bar dataKey="count" radius={[0, 4, 4, 0]}>
                {CONVERSION_DATA.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Prospects vs Clients */}
        <div className="card p-5">
          <h2 className="section-title mb-4">Prospects & Nouveaux clients</h2>
          <ResponsiveContainer width="100%" height={220}>
            <LineChart data={MONTHLY_DATA}>
              <CartesianGrid strokeDasharray="3 3" stroke="#1e293b" />
              <XAxis dataKey="mois" tick={{ fill: '#64748b', fontSize: 11 }} />
              <YAxis tick={{ fill: '#64748b', fontSize: 11 }} />
              <Tooltip contentStyle={{ backgroundColor: '#0f172a', border: '1px solid #1e293b', borderRadius: 8 }} />
              <Legend wrapperStyle={{ fontSize: 12, color: '#94a3b8' }} />
              <Line type="monotone" dataKey="prospects" stroke="#3b82f6" strokeWidth={2} dot={{ fill: '#3b82f6' }} name="Prospects" />
              <Line type="monotone" dataKey="clients" stroke="#10b981" strokeWidth={2} dot={{ fill: '#10b981' }} name="Nouveaux clients" />
            </LineChart>
          </ResponsiveContainer>
        </div>

        {/* Statut factures */}
        <div className="card p-5">
          <h2 className="section-title mb-4">Répartition factures</h2>
          <div className="flex items-center justify-center">
            <PieChart width={220} height={220}>
              <Pie
                data={[
                  { name: 'Payées', value: factures.filter(f => f.statut === 'payee').length },
                  { name: 'Impayées', value: factures.filter(f => f.statut === 'impayee').length },
                  { name: 'Partielles', value: factures.filter(f => f.statut === 'partielle').length },
                ]}
                cx={110} cy={110} outerRadius={90} paddingAngle={3} dataKey="value"
              >
                {['#10b981', '#ef4444', '#f59e0b'].map((color, i) => <Cell key={i} fill={color} />)}
              </Pie>
              <Tooltip contentStyle={{ backgroundColor: '#0f172a', border: '1px solid #1e293b', borderRadius: 8 }} />
              <Legend wrapperStyle={{ fontSize: 12, color: '#94a3b8' }} />
            </PieChart>
          </div>
        </div>
      </div>
    </div>
  )
}
