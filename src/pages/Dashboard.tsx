import { useMemo, useState } from 'react'
import { motion } from 'framer-motion'
import { Link } from 'react-router-dom'
import {
  TrendingUp, Users, FileText, Receipt, DollarSign, AlertTriangle,
  Clock, CheckCircle2, Globe, Server, ArrowUpRight, ArrowRight,
  UserCheck, ChevronRight, Repeat, Activity, X,
} from 'lucide-react'
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, PieChart, Pie, Cell,
} from 'recharts'
import { useProspects } from '@/hooks/useProspects'
import { useClients }   from '@/hooks/useClients'
import { useFactures }  from '@/hooks/useFactures'
import { useDevis }     from '@/hooks/useDevis'
import { useCountUp }   from '@/hooks/useCountUp'
import { formatCurrency, formatDate } from '@/lib/utils'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'

const REVENUE_DATA = [
  { mois: 'Jan', ca: 45000, depenses: 18000 },
  { mois: 'Fév', ca: 52000, depenses: 21000 },
  { mois: 'Mar', ca: 48000, depenses: 19500 },
  { mois: 'Avr', ca: 61000, depenses: 23000 },
  { mois: 'Mai', ca: 55000, depenses: 20000 },
  { mois: 'Jun', ca: 67000, depenses: 25000 },
]

const PROSPECT_SOURCE = [
  { name: 'LinkedIn',       value: 35, color: '#378ADD' },
  { name: 'Référence',      value: 25, color: '#6B63D4' },
  { name: 'Site web',       value: 20, color: '#27500A' },
  { name: 'Réseaux sociaux',value: 12, color: '#639922' },
  { name: 'Autre',          value: 8,  color: '#888780' },
]

const ACTIVITY_LOG = [
  { action: 'Nouveau prospect ajouté', detail: 'Karim Alaoui — Corp Solutions',   time: 'Il y a 2h', color: 'info' },
  { action: 'Facture payée',           detail: 'FAC-2026-001 — 32 542 MAD',        time: 'Il y a 3h', color: 'success' },
  { action: 'Devis accepté',           detail: 'DEV-2026-001 — Hôtel Atlas',        time: 'Il y a 5h', color: 'success' },
  { action: 'Contrat signé',           detail: 'Youssef Tazi — 32 000 MAD',         time: 'Hier',      color: 'ai' },
  { action: 'Relance envoyée',         detail: 'Omar Berrada — FAC-2026-003',       time: 'Hier',      color: 'warning' },
]

const ACTIVITY_DOTS: Record<string, string> = {
  info:    '#378ADD',
  success: '#639922',
  warning: '#BA7517',
  danger:  '#E24B4A',
  ai:      '#6B63D4',
}

const RENEWALS = [
  { nom: 'nextgital.ma',  type: 'Domaine',     expiration: '2026-05-15', jours: 33, prix: 120 },
  { nom: 'nextgital.com', type: 'Domaine',     expiration: '2026-06-01', jours: 50, prix: 150 },
  { nom: 'VPS Contabo',   type: 'Hébergement', expiration: '2026-04-30', jours: 18, prix: 350 },
  { nom: 'Canva Pro',     type: 'Abonnement',  expiration: '2026-04-25', jours: 13, prix: 130 },
]

/* ─── KPI Card ────────────────────────────────────────────────────── */
type KpiColor = 'success' | 'warning' | 'danger' | 'info' | 'neutral' | 'ai'

interface KpiCardProps {
  title:    string
  rawValue: number
  formatter:(n: number) => string
  subtitle: string
  icon:     React.ElementType
  color:    KpiColor
  trend?:   { value: string; up: boolean }
  delay?:   number
}

function KpiCard({ title, rawValue, formatter, subtitle, icon: Icon, color, trend, delay = 0 }: KpiCardProps) {
  const animated = useCountUp(rawValue, 800, delay)
  const display  = rawValue === 0 ? '—' : formatter(animated)

  return (
    <motion.div
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: delay / 1000 + 0.05, duration: 0.3 }}
      whileHover={{ y: -2, boxShadow: '0 4px 20px rgba(0,0,0,0.08)' }}
      className={cn('kpi-semantic rounded-xl p-5 cursor-default transition-shadow duration-200', `kpi-color-${color}`)}
    >
      {/* Header row */}
      <div className="flex items-start justify-between mb-3">
        <p className="kpi-label">{title}</p>
        <div
          className="w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0"
          style={{ backgroundColor: 'var(--kpi-text)', opacity: 0.12 }}
        >
          <Icon className="w-4 h-4" style={{ color: 'var(--kpi-text)' }} />
        </div>
      </div>

      {/* Value */}
      <p className="kpi-value mb-2">{display}</p>

      {/* Footer row */}
      <div className="flex items-center justify-between">
        <p className="text-xs" style={{ color: 'var(--kpi-text)', opacity: 0.65 }}>{subtitle}</p>
        {trend && (
          <motion.span
            initial={{ x: -8, opacity: 0 }}
            animate={{ x: 0, opacity: 1 }}
            transition={{ delay: delay / 1000 + 0.5, duration: 0.25 }}
            className="flex items-center gap-0.5 text-xs font-semibold"
            style={{ color: trend.up ? '#27500A' : '#A32D2D' }}
          >
            <ArrowUpRight className={cn('w-3 h-3', !trend.up && 'rotate-180')} />
            {trend.value}
          </motion.span>
        )}
      </div>
    </motion.div>
  )
}

/* ─── Dashboard page ──────────────────────────────────────────────── */
export default function Dashboard() {
  const { data: prospects = [] } = useProspects()
  const { data: clients   = [] } = useClients()
  const { data: factures  = [] } = useFactures()
  const { data: devis     = [] } = useDevis()
  const [alertDismissed, setAlertDismissed] = useState(false)

  const kpis = useMemo(() => {
    const totalCA       = factures.filter(f => f.statut === 'payee').reduce((s, f) => s + f.montant_ttc, 0)
    const factImpayees  = factures.filter(f => f.statut === 'impayee')
    const totalImpaye   = factImpayees.reduce((s, f) => s + (f.montant_ttc - f.montant_paye), 0)
    const prospectsActifs = prospects.filter(p => !['gagne', 'perdu'].includes(p.statut))
    const valeurPipeline  = prospectsActifs.reduce((s, p) => s + (p.valeur_estimee || 0), 0)
    const devisPending    = devis.filter(d => d.statut === 'envoye')
    return {
      totalCA, totalImpaye,
      clients:          clients.length,
      prospectsActifs:  prospectsActifs.length,
      valeurPipeline,
      devisPending:     devisPending.length,
      facturesImpayees: factImpayees.length,
      profitEstime:     totalCA * 0.65,
    }
  }, [prospects, clients, factures, devis])

  const showAlert = !alertDismissed && (kpis.facturesImpayees > 0 || kpis.devisPending > 0)

  return (
    <div className="space-y-6 animate-fade-in">
      {/* ── Page header ── */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="page-title">Tableau de bord</h1>
          <p className="text-sm mt-0.5" style={{ color: 'hsl(var(--muted-foreground))' }}>
            {new Date().toLocaleDateString('fr-FR', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
          </p>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="secondary" size="sm" asChild>
            <Link to="/prospects">
              <UserCheck className="w-4 h-4" />
              <span className="hidden sm:inline">Prospects</span>
            </Link>
          </Button>
          <Button size="sm" asChild>
            <Link to="/factures">
              <Receipt className="w-4 h-4" />
              <span className="hidden sm:inline">Nouvelle facture</span>
            </Link>
          </Button>
        </div>
      </div>

      {/* ── Alert banner ── */}
      {showAlert && (
        <motion.div
          initial={{ opacity: 0, y: -8 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -8 }}
          className="alert-banner alert-banner-warning"
        >
          <AlertTriangle className="w-4 h-4 flex-shrink-0 mt-0.5" style={{ color: '#BA7517' }} />
          <div className="flex-1 text-sm">
            <span className="font-semibold">Alertes commerciales : </span>
            {kpis.facturesImpayees > 0 && (
              <Link to="/factures" className="underline underline-offset-2 hover:opacity-80 mr-3">
                {kpis.facturesImpayees} facture{kpis.facturesImpayees > 1 ? 's' : ''} impayée{kpis.facturesImpayees > 1 ? 's' : ''} →
              </Link>
            )}
            {kpis.devisPending > 0 && (
              <Link to="/devis" className="underline underline-offset-2 hover:opacity-80">
                {kpis.devisPending} devis en attente →
              </Link>
            )}
          </div>
          <button
            onClick={() => setAlertDismissed(true)}
            className="p-1 rounded hover:opacity-70 transition-opacity flex-shrink-0"
            aria-label="Fermer"
          >
            <X className="w-4 h-4" />
          </button>
        </motion.div>
      )}

      {/* ── KPI Grid — 6 cards, auto-fit ── */}
      <div
        className="grid gap-4"
        style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', alignItems: 'stretch' }}
      >
        <KpiCard title="CA Encaissé"    rawValue={kpis.totalCA}       formatter={formatCurrency} subtitle="Ce mois"                      icon={TrendingUp} color="success" trend={{ value: '+12%', up: true  }} delay={0}   />
        <KpiCard title="À Encaisser"    rawValue={kpis.totalImpaye}   formatter={formatCurrency} subtitle={`${kpis.facturesImpayees} factures`} icon={Receipt}    color="warning" trend={{ value: '-5%',  up: false }} delay={80}  />
        <KpiCard title="Pipeline"       rawValue={kpis.valeurPipeline}formatter={formatCurrency} subtitle={`${kpis.prospectsActifs} prospects`}  icon={UserCheck}  color="info"    trend={{ value: '+8%',  up: true  }} delay={160} />
        <KpiCard title="Clients"        rawValue={kpis.clients}       formatter={String}        subtitle="Total clients actifs"          icon={Users}      color="info"    trend={{ value: '+2',   up: true  }} delay={240} />
        <KpiCard title="Devis Envoyés"  rawValue={kpis.devisPending}  formatter={String}        subtitle="En attente réponse"            icon={FileText}   color="neutral"                                    delay={320} />
        <KpiCard title="Profit Estimé"  rawValue={kpis.profitEstime}  formatter={formatCurrency} subtitle="Marge estimée 65%"             icon={DollarSign} color="success" trend={{ value: '+15%', up: true  }} delay={400} />
      </div>

      {/* ── Charts row ── */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Revenue chart */}
        <div className="lg:col-span-2 card p-5">
          <div className="flex items-center justify-between mb-4">
            <h2 className="section-title">Chiffre d'affaires & Dépenses</h2>
            <span className="text-xs" style={{ color: 'hsl(var(--muted-foreground))' }}>6 derniers mois</span>
          </div>
          <ResponsiveContainer width="100%" height={220}>
            <AreaChart data={REVENUE_DATA} margin={{ top: 5, right: 5, bottom: 5, left: 0 }}>
              <defs>
                <linearGradient id="gCA" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%"  stopColor="#378ADD" stopOpacity={0.25} />
                  <stop offset="95%" stopColor="#378ADD" stopOpacity={0} />
                </linearGradient>
                <linearGradient id="gDep" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%"  stopColor="#E24B4A" stopOpacity={0.15} />
                  <stop offset="95%" stopColor="#E24B4A" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
              <XAxis dataKey="mois" tick={{ fill: 'hsl(var(--muted-foreground))', fontSize: 11 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill: 'hsl(var(--muted-foreground))', fontSize: 11 }} tickFormatter={v => `${v/1000}k`} axisLine={false} tickLine={false} />
              <Tooltip
                contentStyle={{ backgroundColor: 'hsl(var(--popover))', border: '1px solid hsl(var(--border))', borderRadius: 8, fontSize: 12 }}
                labelStyle={{ color: 'hsl(var(--foreground))', fontWeight: 500 }}
                formatter={(v: any) => [`${(+v).toLocaleString('fr-FR')} MAD`]}
              />
              <Area type="monotone" dataKey="ca"       stroke="#378ADD" strokeWidth={2} fill="url(#gCA)"  name="CA" />
              <Area type="monotone" dataKey="depenses" stroke="#E24B4A" strokeWidth={2} fill="url(#gDep)" name="Dépenses" />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* Prospects sources */}
        <div className="card p-5">
          <h2 className="section-title mb-4">Sources Prospects</h2>
          <div className="flex justify-center mb-3">
            <PieChart width={160} height={160}>
              <Pie data={PROSPECT_SOURCE} cx={80} cy={80} innerRadius={50} outerRadius={75} paddingAngle={3} dataKey="value">
                {PROSPECT_SOURCE.map((e, i) => <Cell key={i} fill={e.color} />)}
              </Pie>
              <Tooltip
                contentStyle={{ backgroundColor: 'hsl(var(--popover))', border: '1px solid hsl(var(--border))', borderRadius: 8, fontSize: 12 }}
                formatter={(v: any) => [`${v}%`]}
              />
            </PieChart>
          </div>
          <div className="space-y-2">
            {PROSPECT_SOURCE.map(item => (
              <div key={item.name} className="flex items-center justify-between text-xs">
                <div className="flex items-center gap-2">
                  <div className="w-2 h-2 rounded-full flex-shrink-0" style={{ backgroundColor: item.color }} />
                  <span style={{ color: 'hsl(var(--muted-foreground))' }}>{item.name}</span>
                </div>
                <span className="font-medium" style={{ color: 'hsl(var(--foreground))' }}>{item.value}%</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* ── Bottom row ── */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Activité récente */}
        <div className="card p-5">
          <div className="flex items-center justify-between mb-4">
            <h2 className="section-title flex items-center gap-2">
              <Activity className="w-4 h-4 text-[#378ADD]" />
              Activité récente
            </h2>
            <Link to="/activite" className="text-xs text-[#378ADD] hover:underline flex items-center gap-1">
              Tout voir <ChevronRight className="w-3 h-3" />
            </Link>
          </div>
          <div className="space-y-3">
            {ACTIVITY_LOG.map((item, i) => (
              <div key={i} className="flex items-start gap-3">
                <div
                  className="w-1.5 h-1.5 rounded-full mt-2 flex-shrink-0"
                  style={{ backgroundColor: ACTIVITY_DOTS[item.color] }}
                />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium truncate" style={{ color: 'hsl(var(--foreground))' }}>{item.action}</p>
                  <p className="text-xs truncate" style={{ color: 'hsl(var(--muted-foreground))' }}>{item.detail}</p>
                </div>
                <span className="text-xs flex-shrink-0 whitespace-nowrap" style={{ color: 'hsl(var(--muted-foreground))' }}>{item.time}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Factures impayées */}
        <div className="card p-5">
          <div className="flex items-center justify-between mb-4">
            <h2 className="section-title flex items-center gap-2">
              <Clock className="w-4 h-4 text-[#BA7517]" />
              Factures impayées
            </h2>
            <Link to="/factures" className="text-xs text-[#378ADD] hover:underline flex items-center gap-1">
              Voir tout <ChevronRight className="w-3 h-3" />
            </Link>
          </div>
          <div className="space-y-3">
            {factures.filter(f => f.statut !== 'payee' && f.statut !== 'annulee').slice(0, 5).map(f => (
              <div key={f.id} className="flex items-center justify-between gap-3">
                <div className="min-w-0">
                  <p className="text-sm font-medium truncate" style={{ color: 'hsl(var(--foreground))' }}>{f.numero}</p>
                  <p className="text-xs truncate" style={{ color: 'hsl(var(--muted-foreground))' }}>{f.client_nom || 'Client'}</p>
                </div>
                <div className="text-right flex-shrink-0">
                  <p className="text-sm font-semibold" style={{ color: 'hsl(var(--foreground))' }}>
                    {f.montant_ttc - f.montant_paye > 0 ? formatCurrency(f.montant_ttc - f.montant_paye) : '—'}
                  </p>
                  <Badge variant={f.statut === 'partielle' ? 'warning' : 'destructive'} size="sm">
                    {f.statut === 'partielle' ? 'Partielle' : 'Impayée'}
                  </Badge>
                </div>
              </div>
            ))}
            {factures.filter(f => f.statut !== 'payee' && f.statut !== 'annulee').length === 0 && (
              <div className="empty-state py-8">
                <CheckCircle2 className="w-10 h-10 mx-auto mb-2" style={{ color: '#639922' }} />
                <p className="text-sm" style={{ color: 'hsl(var(--muted-foreground))' }}>Tout est à jour !</p>
              </div>
            )}
          </div>
        </div>

        {/* Renouvellements */}
        <div className="card p-5">
          <div className="flex items-center justify-between mb-4">
            <h2 className="section-title flex items-center gap-2">
              <Repeat className="w-4 h-4 text-[#6B63D4]" />
              Renouvellements
            </h2>
            <Link to="/domaines" className="text-xs text-[#378ADD] hover:underline flex items-center gap-1">
              Voir tout <ChevronRight className="w-3 h-3" />
            </Link>
          </div>
          <div className="space-y-3">
            {RENEWALS.map((r, i) => {
              const v = r.jours <= 15 ? 'destructive' : r.jours <= 30 ? 'warning' : 'success'
              return (
                <div key={i} className="flex items-center justify-between gap-2">
                  <div className="flex items-center gap-2 min-w-0">
                    {r.type === 'Domaine'     ? <Globe  className="w-4 h-4 flex-shrink-0 text-[#378ADD]" />
                   : r.type === 'Hébergement' ? <Server className="w-4 h-4 flex-shrink-0 text-[#6B63D4]" />
                   :                            <Repeat className="w-4 h-4 flex-shrink-0" style={{ color: '#BA7517' }} />}
                    <div className="min-w-0">
                      <p className="text-sm font-medium truncate" style={{ color: 'hsl(var(--foreground))' }}>{r.nom}</p>
                      <p className="text-xs" style={{ color: 'hsl(var(--muted-foreground))' }}>{formatDate(r.expiration)}</p>
                    </div>
                  </div>
                  <Badge variant={v} size="sm">{r.jours}j</Badge>
                </div>
              )
            })}
          </div>
        </div>
      </div>
    </div>
  )
}
