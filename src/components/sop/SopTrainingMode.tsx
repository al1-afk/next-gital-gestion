import { useMemo, useState } from 'react'
import { createPortal } from 'react-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  X, GraduationCap, ChevronLeft, ChevronRight, CheckCircle2, Circle,
  Trophy, Loader2,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import type { Sop, SopBlock } from '@/hooks/useSops'
import {
  useSopTraining, useUpsertTrainingStep,
} from '@/hooks/useSopCollab'
import { useAuth } from '@/hooks/useAuth'
import { parseRichText } from './parseRichText'

interface StepRef {
  blockIndex: number
  stepIndex:  number
  text:       string
}

interface Props {
  open:    boolean
  sop:     Sop | null
  onClose: () => void
}

/**
 * Mode Formation — affiche les étapes du SOP une par une.
 * Sources des étapes :
 *   1. tous les blocs `type='steps'` (chacun avec ses items)
 *   2. à défaut, les blocs `type='checklist'`
 *   3. à défaut, les blocs `type='numbered'`
 */
function extractSteps(blocks: SopBlock[]): StepRef[] {
  const out: StepRef[] = []
  const isStepBlock = (b: SopBlock) => b.type === 'steps'
  const hasSteps = blocks.some(isStepBlock)
  const fallback = !hasSteps
  blocks.forEach((b, bi) => {
    const useThis = isStepBlock(b) || (fallback && (b.type === 'checklist' || b.type === 'numbered'))
    if (!useThis) return
    (b.items ?? []).forEach((text, si) => {
      out.push({ blockIndex: bi, stepIndex: si, text })
    })
  })
  return out
}

export function SopTrainingMode({ open, sop, onClose }: Props) {
  const { userId } = useAuth()
  const [cursor, setCursor] = useState(0)

  const { data: allProgress = [], isLoading: loadingProgress } = useSopTraining()
  const upsert = useUpsertTrainingStep()

  const steps = useMemo(() => extractSteps(sop?.blocks ?? []), [sop])

  /* progression de l'utilisateur courant sur ce SOP */
  const progressByKey = useMemo(() => {
    if (!sop || !userId) return new Map<string, { id: string; done: boolean }>()
    const m = new Map<string, { id: string; done: boolean }>()
    allProgress
      .filter(p => p.sop_id === sop.id && p.user_id === userId)
      .forEach(p => m.set(`${p.block_index}:${p.step_index}`, { id: p.id, done: p.is_completed }))
    return m
  }, [allProgress, sop, userId])

  const completedCount = useMemo(() =>
    steps.filter(s => progressByKey.get(`${s.blockIndex}:${s.stepIndex}`)?.done).length,
  [steps, progressByKey])

  const percent = steps.length ? Math.round((completedCount / steps.length) * 100) : 0

  const current = steps[cursor]
  const isCurrentDone = current
    ? progressByKey.get(`${current.blockIndex}:${current.stepIndex}`)?.done ?? false
    : false

  const toggleCurrent = async () => {
    if (!sop || !userId || !current) return
    const existing = progressByKey.get(`${current.blockIndex}:${current.stepIndex}`)
    await upsert.mutateAsync({
      sop_id:       sop.id,
      user_id:      userId,
      block_index:  current.blockIndex,
      step_index:   current.stepIndex,
      is_completed: !isCurrentDone,
      existing_id:  existing?.id,
    })
  }

  if (!open || !sop) return null

  const allDone = completedCount === steps.length && steps.length > 0

  return createPortal(
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
        style={{ position: 'fixed', inset: 0, zIndex: 105 }}
        className="bg-slate-950/85 backdrop-blur-md flex items-center justify-center p-4"
        onClick={onClose}
      >
        <motion.div
          initial={{ opacity: 0, y: 20, scale: 0.97 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: 20, scale: 0.97 }}
          transition={{ type: 'spring', damping: 28, stiffness: 280 }}
          className="bg-background border border-border rounded-2xl shadow-2xl w-full max-w-2xl flex flex-col overflow-hidden"
          style={{ maxHeight: 'min(90vh, 800px)' }}
          onClick={e => e.stopPropagation()}
        >
          {/* Header */}
          <div className="px-5 md:px-6 py-4 border-b border-border bg-gradient-to-br from-amber-50/60 to-orange-50/30 dark:from-amber-950/20 dark:to-orange-950/10">
            <div className="flex items-center justify-between gap-3">
              <div className="flex items-center gap-3 min-w-0">
                <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-amber-500 to-orange-500 flex items-center justify-center shadow-md">
                  <GraduationCap className="w-5 h-5 text-white" />
                </div>
                <div className="min-w-0">
                  <p className="text-[11px] font-bold uppercase tracking-wider text-amber-700 dark:text-amber-300">Mode Formation</p>
                  <h2 className="text-base font-extrabold text-foreground truncate">{sop.title}</h2>
                </div>
              </div>
              <button onClick={onClose} className="p-2 rounded-lg hover:bg-white/80 dark:hover:bg-slate-800">
                <X className="w-5 h-5 text-muted-foreground" />
              </button>
            </div>

            {/* Progress bar */}
            <div className="mt-4">
              <div className="flex items-center justify-between text-xs text-foreground/80 mb-1.5">
                <span className="font-semibold">{completedCount}/{steps.length} étape{steps.length > 1 ? 's' : ''} complétée{completedCount > 1 ? 's' : ''}</span>
                <span className="font-bold text-amber-600 dark:text-amber-400">{percent}%</span>
              </div>
              <div className="h-2 rounded-full bg-muted overflow-hidden">
                <motion.div
                  initial={{ width: 0 }}
                  animate={{ width: `${percent}%` }}
                  transition={{ duration: 0.4, ease: 'easeOut' }}
                  className={cn('h-full rounded-full', allDone ? 'bg-emerald-500' : 'bg-gradient-to-r from-amber-500 to-orange-500')}
                />
              </div>
            </div>
          </div>

          {/* Body */}
          <div className="flex-1 overflow-y-auto px-5 md:px-6 py-6">
            {loadingProgress ? (
              <div className="flex items-center justify-center py-16">
                <Loader2 className="w-8 h-8 animate-spin text-amber-500" />
              </div>
            ) : steps.length === 0 ? (
              <div className="text-center py-12">
                <p className="text-base font-semibold text-foreground mb-2">Aucune étape</p>
                <p className="text-sm text-muted-foreground">
                  Ce SOP n'a pas de bloc « Étapes », « Checklist » ou « Liste numérotée ».
                </p>
              </div>
            ) : allDone ? (
              <div className="text-center py-10">
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1, rotate: [0, -10, 10, 0] }}
                  transition={{ delay: 0.1, duration: 0.6 }}
                  className="w-20 h-20 mx-auto mb-4 rounded-full bg-gradient-to-br from-emerald-400 to-emerald-600 flex items-center justify-center shadow-lg"
                >
                  <Trophy className="w-10 h-10 text-white" />
                </motion.div>
                <p className="text-xl font-extrabold text-foreground mb-2">Formation complétée 🎉</p>
                <p className="text-sm text-muted-foreground">Vous avez complété toutes les étapes de ce SOP.</p>
                <Button className="mt-5" onClick={onClose}>Terminer</Button>
              </div>
            ) : current && (
              <div className="space-y-5">
                <div className="flex items-center gap-2 text-[11px] font-bold uppercase tracking-wider text-muted-foreground">
                  <span className="inline-flex items-center justify-center w-6 h-6 rounded-full bg-amber-100 dark:bg-amber-900/40 text-amber-700 dark:text-amber-300">
                    {cursor + 1}
                  </span>
                  <span>Étape {cursor + 1} / {steps.length}</span>
                </div>

                <div className={cn(
                  'rounded-2xl border-2 p-6 transition-all',
                  isCurrentDone
                    ? 'border-emerald-400 bg-emerald-50/50 dark:bg-emerald-950/20'
                    : 'border-border bg-card',
                )}>
                  <p className="text-lg font-bold text-foreground leading-snug">
                    {parseRichText(current.text)}
                  </p>
                </div>

                <button
                  onClick={toggleCurrent}
                  disabled={upsert.isPending}
                  className={cn(
                    'w-full flex items-center justify-center gap-2 px-4 py-3 rounded-xl text-sm font-bold transition-all border-2',
                    isCurrentDone
                      ? 'bg-emerald-500 border-emerald-500 text-white hover:bg-emerald-600'
                      : 'bg-background border-border text-foreground hover:bg-muted',
                  )}
                >
                  {isCurrentDone ? <CheckCircle2 className="w-5 h-5" /> : <Circle className="w-5 h-5" />}
                  {isCurrentDone ? 'Étape complétée — Cliquer pour décocher' : 'Marquer comme complétée'}
                </button>

                {/* Mini sommaire des étapes */}
                <div className="pt-4 border-t border-border">
                  <p className="text-[11px] font-bold uppercase tracking-wider text-muted-foreground mb-2">Sommaire</p>
                  <div className="space-y-1 max-h-40 overflow-y-auto">
                    {steps.map((s, i) => {
                      const done = progressByKey.get(`${s.blockIndex}:${s.stepIndex}`)?.done
                      return (
                        <button key={i} onClick={() => setCursor(i)}
                          className={cn(
                            'w-full flex items-center gap-2 px-2 py-1.5 rounded-md text-xs text-left transition-colors',
                            i === cursor ? 'bg-amber-100 dark:bg-amber-900/30 text-amber-800 dark:text-amber-200' : 'hover:bg-muted text-foreground/80',
                          )}>
                          {done
                            ? <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500 flex-shrink-0" />
                            : <Circle className="w-3.5 h-3.5 text-muted-foreground flex-shrink-0" />}
                          <span className="truncate">{i + 1}. {s.text}</span>
                        </button>
                      )
                    })}
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Footer navigation */}
          {steps.length > 0 && !allDone && (
            <div className="flex items-center justify-between gap-3 px-5 md:px-6 py-3 border-t border-border bg-card/95">
              <Button variant="secondary" size="sm" disabled={cursor === 0} onClick={() => setCursor(c => Math.max(0, c - 1))}>
                <ChevronLeft className="w-4 h-4" /> Précédent
              </Button>
              <span className="text-xs text-muted-foreground">{cursor + 1} / {steps.length}</span>
              <Button size="sm" disabled={cursor >= steps.length - 1} onClick={() => setCursor(c => Math.min(steps.length - 1, c + 1))}>
                Suivant <ChevronRight className="w-4 h-4" />
              </Button>
            </div>
          )}
        </motion.div>
      </motion.div>
    </AnimatePresence>,
    document.body,
  )
}
