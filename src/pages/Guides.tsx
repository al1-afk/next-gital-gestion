import { useMemo } from 'react'
import { Link, useParams } from 'react-router-dom'
import {
  MessageCircle, ClipboardList, Video, FileText, FileSignature, Rocket,
  CheckCircle2, Circle, ArrowRight, BookOpen, Sparkles,
} from 'lucide-react'
import { useGuideSteps, useGuideChecklists, useGuideChecklistState } from '@/hooks/useGuides'
import { cn } from '@/lib/utils'

const ICONS: Record<string, React.ElementType> = {
  MessageCircle, ClipboardList, Video, FileText, FileSignature, Rocket,
}

export default function Guides() {
  const { tenantSlug } = useParams<{ tenantSlug: string }>()
  const base = tenantSlug ? `/${tenantSlug}` : ''

  const { data: steps = [], isLoading: stepsLoading } = useGuideSteps()
  const { data: checklists = [] } = useGuideChecklists()
  const { data: state = [] } = useGuideChecklistState()

  /* Calcul progression par étape : items cochés / total */
  const progressByStep = useMemo(() => {
    const result: Record<string, { done: number; total: number }> = {}
    for (const step of steps) {
      const items = checklists.filter(c => c.step_id === step.id)
      const total = items.length
      const done = items.filter(i =>
        state.find(s => s.checklist_item_id === i.id && s.is_checked)
      ).length
      result[step.id] = { done, total }
    }
    return result
  }, [steps, checklists, state])

  const totalDone  = Object.values(progressByStep).reduce((a, b) => a + b.done, 0)
  const totalItems = Object.values(progressByStep).reduce((a, b) => a + b.total, 0)
  const globalPct  = totalItems > 0 ? Math.round((totalDone / totalItems) * 100) : 0

  return (
    <div className="space-y-6 pb-12">
      {/* Header */}
      <div className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <BookOpen className="w-5 h-5 text-blue-600 dark:text-blue-400" />
            <h1 className="text-2xl font-extrabold text-slate-900 dark:text-white tracking-tight">
              Guides Onboarding Client
            </h1>
            <span className="px-2 py-0.5 rounded-md text-[10px] font-bold bg-violet-50 text-violet-600 border border-violet-200 dark:bg-violet-950/50 dark:text-violet-300 dark:border-violet-800/50">
              Playbook
            </span>
          </div>
          <p className="text-sm text-slate-500 dark:text-slate-400">
            Le système Next Gital en 6 étapes — du premier contact au kick-off projet.
          </p>
        </div>

        {/* Progression globale */}
        <div className="flex items-center gap-3 px-4 py-2.5 rounded-xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900/50">
          <div className="text-right">
            <div className="text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">Progression</div>
            <div className="text-lg font-extrabold text-slate-900 dark:text-white">{globalPct}%</div>
          </div>
          <div className="w-24 h-2 rounded-full bg-slate-100 dark:bg-slate-800 overflow-hidden">
            <div
              className="h-full bg-gradient-to-r from-blue-500 to-violet-500 transition-all duration-500"
              style={{ width: `${globalPct}%` }}
            />
          </div>
        </div>
      </div>

      {/* Banner "Philosophie" */}
      <div className="relative overflow-hidden rounded-2xl border border-violet-200 dark:border-violet-800/50 bg-gradient-to-br from-violet-50 to-blue-50 dark:from-violet-950/30 dark:to-blue-950/30 p-5">
        <div className="flex items-start gap-3">
          <div className="w-10 h-10 rounded-xl flex items-center justify-center bg-gradient-to-br from-violet-500 to-blue-600 shadow-lg shadow-violet-500/30 flex-shrink-0">
            <Sparkles className="w-5 h-5 text-white" />
          </div>
          <div>
            <p className="font-bold text-slate-900 dark:text-white mb-1">
              Travaille SUR ta boîte, pas DANS ta boîte.
            </p>
            <p className="text-sm text-slate-600 dark:text-slate-300 leading-relaxed">
              Chaque étape ci-dessous est un système — exécutable par toi, ton équipe, ou un futur collaborateur,
              avec la même qualité. Copie les messages, coche les checklists, livre des projets professionnels en série.
            </p>
          </div>
        </div>
      </div>

      {/* Grille des 6 étapes */}
      {stepsLoading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {[...Array(6)].map((_, i) => (
            <div key={i} className="rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900/50 p-5 h-44 animate-pulse" />
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {steps.map(step => {
            const Icon = ICONS[step.icon ?? ''] ?? BookOpen
            const prog = progressByStep[step.id] ?? { done: 0, total: 0 }
            const pct  = prog.total > 0 ? Math.round((prog.done / prog.total) * 100) : 0
            const isComplete = prog.total > 0 && prog.done === prog.total

            return (
              <Link
                key={step.id}
                to={`${base}/guides/${step.step_key}`}
                className="group relative overflow-hidden rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900/50 p-5 hover:shadow-lg hover:border-slate-300 dark:hover:border-slate-700 transition-all"
              >
                {/* Top stripe */}
                <div
                  className="absolute top-0 left-0 right-0 h-1"
                  style={{ background: `linear-gradient(90deg, ${step.color_hex}, ${step.color_hex}aa)` }}
                />

                <div className="flex items-start gap-3 mb-3">
                  <div
                    className="w-11 h-11 rounded-xl flex items-center justify-center flex-shrink-0 shadow-md"
                    style={{
                      background: `linear-gradient(135deg, ${step.color_hex}, ${step.color_hex}cc)`,
                      boxShadow: `0 4px 12px ${step.color_hex}40`,
                    }}
                  >
                    <Icon className="w-5 h-5 text-white" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-1.5 mb-0.5">
                      <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">
                        Étape {step.step_number}
                      </span>
                      {isComplete && (
                        <span className="px-1.5 py-0.5 rounded-md text-[10px] font-bold bg-emerald-50 text-emerald-600 border border-emerald-200 dark:bg-emerald-950/50 dark:text-emerald-300 dark:border-emerald-800/50">
                          ✓ Configuré
                        </span>
                      )}
                    </div>
                    <h3 className="font-bold text-slate-900 dark:text-white truncate">{step.title}</h3>
                    {step.subtitle && (
                      <p className="text-xs text-slate-500 dark:text-slate-400 truncate">{step.subtitle}</p>
                    )}
                  </div>
                </div>

                {step.timer_label && (
                  <div className="inline-flex items-center gap-1 px-2 py-1 rounded-md text-[11px] font-semibold bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 mb-3">
                    ⏱ {step.timer_label}
                  </div>
                )}

                {/* Progression de l'étape */}
                {prog.total > 0 && (
                  <div className="mt-3 mb-1">
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-[11px] font-semibold text-slate-500 dark:text-slate-400">
                        {prog.done}/{prog.total} checklist
                      </span>
                      <span className="text-[11px] font-bold text-slate-700 dark:text-slate-200">{pct}%</span>
                    </div>
                    <div className="w-full h-1.5 rounded-full bg-slate-100 dark:bg-slate-800 overflow-hidden">
                      <div
                        className="h-full transition-all duration-500"
                        style={{
                          width: `${pct}%`,
                          background: `linear-gradient(90deg, ${step.color_hex}, ${step.color_hex}cc)`,
                        }}
                      />
                    </div>
                  </div>
                )}

                <div className="mt-4 flex items-center justify-between">
                  <span className="text-xs font-semibold text-blue-600 dark:text-blue-400 group-hover:translate-x-0.5 transition-transform">
                    Ouvrir l'étape
                  </span>
                  <ArrowRight className="w-4 h-4 text-blue-600 dark:text-blue-400 group-hover:translate-x-1 transition-transform" />
                </div>
              </Link>
            )
          })}
        </div>
      )}

      {/* Résumé checklist en bas */}
      {steps.length > 0 && (
        <div className="rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900/50 p-5">
          <h2 className="text-sm font-bold text-slate-900 dark:text-white mb-3 flex items-center gap-2">
            <CheckCircle2 className="w-4 h-4 text-emerald-500" />
            Récapitulatif checklist par étape
          </h2>
          <div className="space-y-2">
            {steps.map(step => {
              const prog = progressByStep[step.id] ?? { done: 0, total: 0 }
              const items = checklists.filter(c => c.step_id === step.id)
              if (items.length === 0) return null

              return (
                <div key={step.id} className="flex items-center gap-3 py-2 border-b border-slate-100 dark:border-slate-800 last:border-0">
                  <div className="w-7 h-7 rounded-lg flex items-center justify-center text-[11px] font-bold flex-shrink-0"
                       style={{ background: `${step.color_hex}20`, color: step.color_hex }}>
                    {step.step_number}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-semibold text-slate-700 dark:text-slate-200 truncate">{step.title}</p>
                  </div>
                  <span className={cn(
                    'text-xs font-bold tabular-nums',
                    prog.done === prog.total
                      ? 'text-emerald-600 dark:text-emerald-400'
                      : 'text-slate-500 dark:text-slate-400'
                  )}>
                    {prog.done}/{prog.total}
                  </span>
                  {prog.done === prog.total
                    ? <CheckCircle2 className="w-4 h-4 text-emerald-500 flex-shrink-0" />
                    : <Circle className="w-4 h-4 text-slate-300 dark:text-slate-700 flex-shrink-0" />}
                </div>
              )
            })}
          </div>
        </div>
      )}
    </div>
  )
}
