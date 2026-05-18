/**
 * /my-space/tasks — member's task list with status update.
 */
import { useMemo, useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { motion } from 'framer-motion'
import {
  CheckSquare, Square, Circle, Loader2, AlertTriangle, Calendar, Tag, Inbox,
} from 'lucide-react'
import { mySpaceApi } from '@/lib/api'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { toast } from 'sonner'

const PRIORITY_META: Record<string, { label: string; color: string; dot: string }> = {
  urgent: { label: 'URGENTE', color: 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300',         dot: 'bg-red-500' },
  high:   { label: 'HAUTE',   color: 'bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-300', dot: 'bg-orange-500' },
  normal: { label: 'NORMALE', color: 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300',     dot: 'bg-blue-500' },
  low:    { label: 'BASSE',   color: 'bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300',    dot: 'bg-slate-400' },
}

function dueLabel(due?: string | null): { text: string; tone: 'overdue' | 'soon' | 'normal' | 'none' } {
  if (!due) return { text: 'Pas de date', tone: 'none' }
  const d = new Date(due + 'T23:59:59')
  const diff = d.getTime() - Date.now()
  const days = Math.ceil(diff / 86_400_000)
  if (days < 0) return { text: `En retard de ${-days}j`, tone: 'overdue' }
  if (days === 0) return { text: "Aujourd'hui", tone: 'soon' }
  if (days === 1) return { text: 'Demain', tone: 'soon' }
  if (days <= 7) return { text: `Dans ${days}j`, tone: 'normal' }
  return { text: d.toLocaleDateString('fr-FR'), tone: 'normal' }
}

export default function MyTasks() {
  const qc = useQueryClient()
  const [filter, setFilter] = useState<'all' | 'open' | 'done'>('open')
  const { data: tasks = [], isLoading } = useQuery<any[]>({
    queryKey: ['my-space', 'tasks'],
    queryFn:  () => mySpaceApi.tasks(),
    staleTime: 30_000,
  })

  const update = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      mySpaceApi.updateTaskStatus(id, status),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['my-space', 'tasks'] })
      qc.invalidateQueries({ queryKey: ['my-space', 'dashboard'] })
    },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })

  const filtered = useMemo(() => {
    if (filter === 'open') return tasks.filter(t => t.status !== 'done' && t.status !== 'cancelled')
    if (filter === 'done') return tasks.filter(t => t.status === 'done')
    return tasks
  }, [tasks, filter])

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 dark:text-slate-100">Mes tâches</h1>
          <p className="text-sm text-slate-500 dark:text-slate-400">Mettez à jour leur statut au fur et à mesure.</p>
        </div>
        <div className="flex bg-slate-100 dark:bg-slate-800 rounded-lg p-1">
          {(['open','done','all'] as const).map(k => (
            <button
              key={k}
              onClick={() => setFilter(k)}
              className={cn(
                'px-3 py-1.5 text-xs font-medium rounded-md transition-colors',
                filter === k
                  ? 'bg-white dark:bg-slate-900 text-slate-900 dark:text-slate-100 shadow-sm'
                  : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-200',
              )}
            >
              {k === 'open' ? 'En cours' : k === 'done' ? 'Terminées' : 'Toutes'}
            </button>
          ))}
        </div>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-12"><Loader2 className="w-6 h-6 animate-spin text-blue-600" /></div>
      ) : filtered.length === 0 ? (
        <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 p-10 text-center">
          <Inbox className="w-10 h-10 text-slate-300 dark:text-slate-700 mx-auto mb-3" />
          <p className="text-sm text-slate-500 dark:text-slate-400">
            {filter === 'open' ? 'Aucune tâche en cours.' : filter === 'done' ? 'Aucune tâche terminée.' : 'Aucune tâche.'}
          </p>
        </div>
      ) : (
        <div className="space-y-2">
          {filtered.map((t, i) => {
            const p = PRIORITY_META[t.priority] ?? PRIORITY_META.normal
            const due = dueLabel(t.due_date)
            const isDone = t.status === 'done'
            const isInProgress = t.status === 'in_progress'
            return (
              <motion.div
                key={t.id}
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.02 }}
                className={cn(
                  'bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 p-4 flex items-start gap-3 group hover:shadow-sm transition-shadow',
                  isDone && 'opacity-60',
                )}
              >
                <button
                  onClick={() => update.mutate({ id: t.id, status: isDone ? 'todo' : 'done' })}
                  className="mt-0.5 flex-shrink-0"
                  title={isDone ? 'Rouvrir la tâche' : 'Marquer comme fait'}
                >
                  {isDone ? (
                    <CheckSquare className="w-5 h-5 text-emerald-600" />
                  ) : isInProgress ? (
                    <Circle className="w-5 h-5 text-blue-600 fill-blue-100 dark:fill-blue-900/40" />
                  ) : (
                    <Square className="w-5 h-5 text-slate-300 dark:text-slate-600 group-hover:text-blue-500" />
                  )}
                </button>

                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className={cn('text-[10px] font-bold px-1.5 py-0.5 rounded', p.color)}>
                      <span className="inline-block w-1.5 h-1.5 rounded-full mr-1 align-middle" style={{ backgroundColor: 'currentColor', opacity: .5 }} />
                      {p.label}
                    </span>
                    {due.tone !== 'none' && (
                      <span className={cn(
                        'text-[10px] font-semibold px-1.5 py-0.5 rounded flex items-center gap-1',
                        due.tone === 'overdue' ? 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300' :
                        due.tone === 'soon'    ? 'bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300' :
                                                  'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300',
                      )}>
                        {due.tone === 'overdue' ? <AlertTriangle className="w-2.5 h-2.5" /> : <Calendar className="w-2.5 h-2.5" />}
                        {due.text}
                      </span>
                    )}
                  </div>
                  <div className={cn('mt-1.5 text-sm font-medium text-slate-900 dark:text-slate-100', isDone && 'line-through')}>
                    {t.title}
                  </div>
                  {t.description && (
                    <p className="mt-1 text-xs text-slate-500 dark:text-slate-400 line-clamp-2">{t.description}</p>
                  )}
                </div>

                {!isDone && (
                  <div className="flex gap-1.5">
                    {!isInProgress && (
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => update.mutate({ id: t.id, status: 'in_progress' })}
                        className="text-xs h-8"
                      >
                        En cours
                      </Button>
                    )}
                    <Button
                      size="sm"
                      onClick={() => update.mutate({ id: t.id, status: 'done' })}
                      className="text-xs h-8 bg-emerald-600 hover:bg-emerald-700 text-white"
                    >
                      ✓ Fait
                    </Button>
                  </div>
                )}
              </motion.div>
            )
          })}
        </div>
      )}
    </div>
  )
}
