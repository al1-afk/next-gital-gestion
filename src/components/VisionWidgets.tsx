import { useMemo } from 'react'
import { Link, useParams } from 'react-router-dom'
import { motion } from 'framer-motion'
import { Target, Crown, ArrowRight, Check } from 'lucide-react'
import { useTenantVision } from '@/hooks/useGuides'
import { useFactures } from '@/hooks/useFactures'
import { useAuth } from '@/hooks/useAuth'
import { cn } from '@/lib/utils'

/* ─────────────────────────────────────────────────────────────────
   VisionWidgets — Cap mensuel + Objectif du mois

   - Lit tenant_vision.monthly_revenue_cap et .monthly_target
   - Calcule le CA du mois courant depuis factures (statut "payee")
   - Affiche "Objectif atteint" quand cap >= CA mois
   - Bouton "Définir" visible aux admins si vision vide
─────────────────────────────────────────────────────────────────── */

function formatMAD(n: number): string {
  return new Intl.NumberFormat('fr-MA', {
    maximumFractionDigits: 0,
    minimumFractionDigits: 0,
  }).format(n) + ' MAD'
}

export default function VisionWidgets() {
  const { tenantSlug } = useParams<{ tenantSlug: string }>()
  const base = tenantSlug ? `/${tenantSlug}` : ''
  const { role } = useAuth()
  const { data: vision } = useTenantVision()
  const { data: factures = [] } = useFactures()

  /* CA encaissé ce mois-ci */
  const caCeMois = useMemo(() => {
    const now = new Date()
    const y = now.getFullYear(), m = now.getMonth()
    return factures
      .filter(f => {
        if (f.statut !== 'payee') return false
        const d = new Date(f.created_at)
        return d.getFullYear() === y && d.getMonth() === m
      })
      .reduce((s, f) => s + (f.montant_ttc || 0), 0)
  }, [factures])

  const monthlyTarget = vision?.monthly_target ?? null
  const monthlyCap    = vision?.monthly_revenue_cap ?? null

  /* Rien à afficher si pas de vision ET non-admin → silencieux */
  const hasAny = monthlyTarget != null || monthlyCap != null
  if (!hasAny && role !== 'admin') return null

  /* État vide pour admin → CTA */
  if (!hasAny && role === 'admin') {
    return (
      <Link
        to={`${base}/vision`}
        className="block rounded-2xl border border-dashed border-violet-300 dark:border-violet-700/50 bg-violet-50/40 dark:bg-violet-950/10 p-4 hover:bg-violet-50 dark:hover:bg-violet-950/20 transition-colors"
      >
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl flex items-center justify-center bg-gradient-to-br from-violet-500 to-blue-600 shadow-md flex-shrink-0">
            <Crown className="w-5 h-5 text-white" />
          </div>
          <div className="flex-1">
            <p className="text-sm font-bold text-slate-900 dark:text-white">
              Définis ta vision et tes objectifs mensuels
            </p>
            <p className="text-xs text-slate-500 dark:text-slate-400">
              Cap mensuel · Objectif CA · Style de vie visé
            </p>
          </div>
          <ArrowRight className="w-4 h-4 text-violet-500" />
        </div>
      </Link>
    )
  }

  const targetPct = monthlyTarget && monthlyTarget > 0 ? Math.min(100, Math.round((caCeMois / monthlyTarget) * 100)) : 0
  const capPct    = monthlyCap    && monthlyCap    > 0 ? Math.min(100, Math.round((caCeMois / monthlyCap)    * 100)) : 0
  const capReached = monthlyCap != null && caCeMois >= monthlyCap

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
      {/* ── Objectif du mois ── */}
      {monthlyTarget != null && (
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          className="rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900/50 p-5"
        >
          <div className="flex items-start justify-between gap-3 mb-3">
            <div className="flex items-center gap-2.5">
              <div className="w-9 h-9 rounded-xl flex items-center justify-center bg-gradient-to-br from-blue-500 to-cyan-500 shadow-md shadow-blue-500/30 flex-shrink-0">
                <Target className="w-4 h-4 text-white" />
              </div>
              <div>
                <div className="text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">
                  Objectif du mois
                </div>
                <div className="text-sm font-bold text-slate-900 dark:text-white">
                  {formatMAD(caCeMois)} <span className="text-slate-400 dark:text-slate-500 font-normal">/ {formatMAD(monthlyTarget)}</span>
                </div>
              </div>
            </div>
            <div className="text-right">
              <div className={cn(
                'text-2xl font-extrabold tabular-nums',
                targetPct >= 100 ? 'text-emerald-600 dark:text-emerald-400'
                  : targetPct >= 70 ? 'text-blue-600 dark:text-blue-400'
                  : 'text-slate-700 dark:text-slate-200',
              )}>
                {targetPct}%
              </div>
            </div>
          </div>

          <div className="w-full h-2 rounded-full bg-slate-100 dark:bg-slate-800 overflow-hidden">
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${targetPct}%` }}
              transition={{ duration: 0.8, ease: 'easeOut' }}
              className={cn(
                'h-full transition-colors',
                targetPct >= 100 ? 'bg-gradient-to-r from-emerald-500 to-green-500'
                  : 'bg-gradient-to-r from-blue-500 to-cyan-500',
              )}
            />
          </div>

          {targetPct >= 100 && (
            <p className="text-[11px] font-bold text-emerald-600 dark:text-emerald-400 mt-2 flex items-center gap-1">
              <Check className="w-3 h-3" /> Objectif atteint ce mois-ci 🎉
            </p>
          )}
        </motion.div>
      )}

      {/* ── Cap mensuel ── */}
      {monthlyCap != null && (
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.05 }}
          className={cn(
            'rounded-2xl border p-5 relative overflow-hidden',
            capReached
              ? 'border-emerald-200 dark:border-emerald-800/50 bg-gradient-to-br from-emerald-50 to-green-50 dark:from-emerald-950/30 dark:to-green-950/20'
              : 'border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900/50',
          )}
        >
          <div className="flex items-start justify-between gap-3 mb-3">
            <div className="flex items-center gap-2.5">
              <div className={cn(
                'w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0 shadow-md',
                capReached
                  ? 'bg-gradient-to-br from-emerald-500 to-green-600 shadow-emerald-500/40'
                  : 'bg-gradient-to-br from-amber-500 to-orange-500 shadow-amber-500/30',
              )}>
                <Crown className="w-4 h-4 text-white" />
              </div>
              <div>
                <div className="text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">
                  Cap mensuel
                </div>
                <div className="text-sm font-bold text-slate-900 dark:text-white">
                  {formatMAD(caCeMois)} <span className="text-slate-400 dark:text-slate-500 font-normal">/ {formatMAD(monthlyCap)}</span>
                </div>
              </div>
            </div>
            <div className="text-right">
              <div className={cn(
                'text-2xl font-extrabold tabular-nums',
                capReached ? 'text-emerald-600 dark:text-emerald-400' : 'text-amber-600 dark:text-amber-400',
              )}>
                {capPct}%
              </div>
            </div>
          </div>

          <div className="w-full h-2 rounded-full bg-slate-100 dark:bg-slate-800 overflow-hidden">
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${capPct}%` }}
              transition={{ duration: 0.8, ease: 'easeOut' }}
              className={cn(
                'h-full',
                capReached
                  ? 'bg-gradient-to-r from-emerald-500 to-green-500'
                  : 'bg-gradient-to-r from-amber-500 to-orange-500',
              )}
            />
          </div>

          {capReached ? (
            <p className="text-[11px] font-bold text-emerald-700 dark:text-emerald-300 mt-2 flex items-center gap-1">
              <Check className="w-3 h-3" /> Cap atteint — tu peux lever le pied 🌴
            </p>
          ) : (
            <p className="text-[11px] text-slate-500 dark:text-slate-400 mt-2">
              {formatMAD(monthlyCap - caCeMois)} restants avant le cap
            </p>
          )}
        </motion.div>
      )}
    </div>
  )
}
