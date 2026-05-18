/**
 * /my-space — Dashboard tab.
 */
import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'
import { motion } from 'framer-motion'
import {
  CheckSquare, BookOpen, Activity, Clock, AlertTriangle, ChevronRight,
  Loader2, Sparkles,
} from 'lucide-react'
import { mySpaceApi } from '@/lib/api'
import { SOP_CATEGORY_BY_KEY } from '@/lib/sopCategories'
import { cn } from '@/lib/utils'

function timeAgo(iso?: string | null): string {
  if (!iso) return 'jamais'
  const diff = Date.now() - new Date(iso).getTime()
  const m = Math.floor(diff / 60000)
  if (m < 1)   return "à l'instant"
  if (m < 60)  return `il y a ${m} min`
  const h = Math.floor(m / 60)
  if (h < 24)  return `il y a ${h} h`
  const d = Math.floor(h / 24)
  if (d < 7)   return `il y a ${d} j`
  return new Date(iso).toLocaleDateString('fr-FR')
}

const ACTION_LABELS: Record<string, string> = {
  login:                   'Connexion',
  logout:                  'Déconnexion',
  sop_viewed:              'A consulté une SOP',
  sop_checklist_completed: 'A complété une checklist',
  sop_marked_read:         'A marqué une SOP comme lue',
  task_completed:          'Tâche terminée',
  task_updated:            'Tâche mise à jour',
  password_changed:        'Mot de passe modifié',
  invitation_accepted:     'Invitation acceptée',
}

export default function MyDashboard() {
  const { data, isLoading } = useQuery({
    queryKey: ['my-space', 'dashboard'],
    queryFn:  () => mySpaceApi.dashboard(),
    staleTime: 60_000,
  })

  if (isLoading || !data) {
    return (
      <div className="flex items-center justify-center py-16">
        <Loader2 className="w-6 h-6 animate-spin text-blue-600" />
      </div>
    )
  }

  const { profile, access, tasks, recent_activity } = data
  const taskDonePct = tasks.total > 0 ? Math.round((tasks.done / tasks.total) * 100) : 0

  return (
    <div className="space-y-6">
      {/* Greeting */}
      <div className="bg-gradient-to-br from-blue-600 to-violet-600 rounded-2xl p-6 text-white shadow-lg">
        <div className="flex items-start justify-between gap-4 flex-wrap">
          <div>
            <h1 className="text-2xl font-bold">
              👋 Bonjour {profile?.first_name} !
            </h1>
            <p className="text-blue-100 text-sm mt-1">
              {profile?.job_title || 'Membre'} · {profile?.tenant_name ?? 'Next Gital'}
            </p>
          </div>
          <div className="text-xs text-blue-100 bg-white/15 px-3 py-1.5 rounded-lg">
            Dernière connexion : {timeAgo(profile?.last_login_at)}
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <StatCard
          icon={CheckSquare}
          label="Tâches"
          value={`${tasks.done}/${tasks.total}`}
          sublabel={`${tasks.todo + tasks.in_progress} en cours`}
          accent="bg-emerald-50 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-300"
          alertLabel={tasks.overdue > 0 ? `${tasks.overdue} en retard` : null}
        />
        <StatCard
          icon={BookOpen}
          label="Catégories SOPs"
          value={`${access.length}`}
          sublabel={`${access.reduce((s, a) => s + a.total_sops, 0)} procédures`}
          accent="bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300"
        />
        <StatCard
          icon={Activity}
          label="Progression"
          value={`${taskDonePct}%`}
          sublabel="tâches terminées"
          accent="bg-violet-50 dark:bg-violet-900/20 text-violet-700 dark:text-violet-300"
        />
      </div>

      {/* My SOPs */}
      <section>
        <h2 className="text-base font-semibold text-slate-900 dark:text-slate-100 mb-3 flex items-center gap-2">
          <BookOpen className="w-4 h-4 text-blue-600" /> Mes SOPs
        </h2>
        {access.length === 0 ? (
          <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 p-6 text-center text-sm text-slate-500 dark:text-slate-400">
            Aucune catégorie ne vous a encore été assignée.
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
            {access.map((a, i) => {
              const meta = SOP_CATEGORY_BY_KEY[a.category]
              return (
                <motion.div
                  key={a.category}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: i * 0.03 }}
                >
                  <Link
                    to={`/my-space/sops?category=${a.category}`}
                    className="group block bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 p-4 hover:border-blue-300 dark:hover:border-blue-700 transition-all hover:shadow-md"
                  >
                    <div className="flex items-start gap-3">
                      <div className={cn('w-10 h-10 rounded-lg flex items-center justify-center text-lg', meta?.bg ?? 'bg-slate-100 dark:bg-slate-800')}>
                        {meta?.emoji ?? '📚'}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="text-sm font-semibold text-slate-900 dark:text-slate-100 truncate">
                          {meta?.label ?? a.category}
                        </div>
                        <div className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                          {a.total_sops} procédure{a.total_sops > 1 ? 's' : ''} · {a.level === 'edit' ? 'Édition' : a.level === 'complete' ? 'Checklist' : 'Lecture'}
                        </div>
                      </div>
                      <ChevronRight className="w-4 h-4 text-slate-300 dark:text-slate-600 group-hover:text-blue-500 dark:group-hover:text-blue-400 transition-colors" />
                    </div>
                  </Link>
                </motion.div>
              )
            })}
          </div>
        )}
      </section>

      {/* Recent activity */}
      <section>
        <h2 className="text-base font-semibold text-slate-900 dark:text-slate-100 mb-3 flex items-center gap-2">
          <Sparkles className="w-4 h-4 text-violet-600" /> Activité récente
        </h2>
        <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 divide-y divide-slate-100 dark:divide-slate-800">
          {recent_activity.length === 0 ? (
            <div className="p-6 text-sm text-slate-500 dark:text-slate-400 text-center">Aucune activité récente.</div>
          ) : recent_activity.slice(0, 10).map((a: any, i: number) => (
            <div key={i} className="p-3.5 flex items-center gap-3 text-sm">
              <div className="w-8 h-8 rounded-full bg-slate-100 dark:bg-slate-800 flex items-center justify-center">
                <Clock className="w-3.5 h-3.5 text-slate-500 dark:text-slate-400" />
              </div>
              <div className="flex-1 min-w-0">
                <div className="text-slate-700 dark:text-slate-300 truncate">
                  {ACTION_LABELS[a.action_type] ?? a.action_type}
                  {a.action_details?.sop_title && (
                    <span className="text-slate-400 dark:text-slate-500"> · {a.action_details.sop_title}</span>
                  )}
                </div>
              </div>
              <div className="text-xs text-slate-400 dark:text-slate-500 whitespace-nowrap">
                {timeAgo(a.created_at)}
              </div>
            </div>
          ))}
        </div>
      </section>
    </div>
  )
}

function StatCard(props: {
  icon: React.ElementType
  label: string
  value: string
  sublabel: string
  accent: string
  alertLabel?: string | null
}) {
  const Icon = props.icon
  return (
    <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 p-4">
      <div className="flex items-center gap-3">
        <div className={cn('w-10 h-10 rounded-lg flex items-center justify-center', props.accent)}>
          <Icon className="w-5 h-5" />
        </div>
        <div className="flex-1 min-w-0">
          <div className="text-xs text-slate-500 dark:text-slate-400">{props.label}</div>
          <div className="text-xl font-bold text-slate-900 dark:text-slate-100">{props.value}</div>
          <div className="text-xs text-slate-500 dark:text-slate-400 truncate">{props.sublabel}</div>
        </div>
      </div>
      {props.alertLabel && (
        <div className="mt-2 inline-flex items-center gap-1 text-xs text-red-700 dark:text-red-400 bg-red-50 dark:bg-red-900/20 px-2 py-1 rounded">
          <AlertTriangle className="w-3 h-3" />
          {props.alertLabel}
        </div>
      )}
    </div>
  )
}
