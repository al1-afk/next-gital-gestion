import { useEffect, useMemo, useState } from 'react'
import { motion } from 'framer-motion'
import {
  Target, TrendingUp, Plus, Trash2, Edit2, Check, RotateCcw,
  Trophy, Zap, ListChecks, Sparkles, Calendar as CalendarIcon,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input }  from '@/components/ui/input'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { cn } from '@/lib/utils'
import { toast } from 'sonner'

const STORAGE_KEY = 'gestiq_planner'

/* ─── Types ──────────────────────────────────────────────────── */
type CategoryKey =
  | 'wakeup' | 'sport' | 'leads' | 'comms' | 'lunch' | 'closing'
  | 'service' | 'team' | 'outdoor' | 'rest' | 'learning' | 'review'
  | 'sleep' | 'family' | 'nature' | 'goals' | 'evening' | 'work' | 'free'

interface Block {
  time:     string
  emoji:    string
  title:    string
  subtitle?:string
  category: CategoryKey
}

interface DayPlan {
  day:    string   // 'Lundi'
  short:  string   // 'Lun'
  weekend: boolean
  blocks: Block[]
}

interface PlannerData {
  title:    string
  subtitle: string
  goal: {
    revenue:   number
    months:    number
    avgClient: number
  }
  weeklyKpis: {
    leads:    number
    calls:    number
    closings: number
    revenue:  number
  }
  habits: string[]
  rules:  string[]
  days:   DayPlan[]
}

/* ─── Category palette ──────────────────────────────────────── */
const CAT: Record<CategoryKey, { color: string; bg: string; ring: string }> = {
  wakeup:   { color: 'text-amber-700  dark:text-amber-300',   bg: 'bg-amber-50  dark:bg-amber-500/10',   ring: 'border-amber-200  dark:border-amber-500/30'  },
  sport:    { color: 'text-emerald-700 dark:text-emerald-300', bg: 'bg-emerald-50 dark:bg-emerald-500/10', ring: 'border-emerald-200 dark:border-emerald-500/30' },
  leads:    { color: 'text-green-700  dark:text-green-300',   bg: 'bg-green-50  dark:bg-green-500/10',   ring: 'border-green-200  dark:border-green-500/30'  },
  comms:    { color: 'text-cyan-700   dark:text-cyan-300',    bg: 'bg-cyan-50   dark:bg-cyan-500/10',    ring: 'border-cyan-200   dark:border-cyan-500/30'   },
  lunch:    { color: 'text-orange-700 dark:text-orange-300',  bg: 'bg-orange-50 dark:bg-orange-500/10',  ring: 'border-orange-200 dark:border-orange-500/30' },
  closing:  { color: 'text-violet-700 dark:text-violet-300',  bg: 'bg-violet-50 dark:bg-violet-500/10',  ring: 'border-violet-200 dark:border-violet-500/30' },
  service:  { color: 'text-blue-700   dark:text-blue-300',    bg: 'bg-blue-50   dark:bg-blue-500/10',    ring: 'border-blue-200   dark:border-blue-500/30'   },
  team:     { color: 'text-pink-700   dark:text-pink-300',    bg: 'bg-pink-50   dark:bg-pink-500/10',    ring: 'border-pink-200   dark:border-pink-500/30'   },
  outdoor:  { color: 'text-teal-700   dark:text-teal-300',    bg: 'bg-teal-50   dark:bg-teal-500/10',    ring: 'border-teal-200   dark:border-teal-500/30'   },
  rest:     { color: 'text-sky-700    dark:text-sky-300',     bg: 'bg-sky-50    dark:bg-sky-500/10',     ring: 'border-sky-200    dark:border-sky-500/30'    },
  learning: { color: 'text-indigo-700 dark:text-indigo-300',  bg: 'bg-indigo-50 dark:bg-indigo-500/10',  ring: 'border-indigo-200 dark:border-indigo-500/30' },
  review:   { color: 'text-fuchsia-700 dark:text-fuchsia-300',bg: 'bg-fuchsia-50 dark:bg-fuchsia-500/10',ring: 'border-fuchsia-200 dark:border-fuchsia-500/30' },
  sleep:    { color: 'text-slate-600  dark:text-slate-300',   bg: 'bg-slate-100 dark:bg-slate-800/40',   ring: 'border-slate-200  dark:border-slate-700'      },
  family:   { color: 'text-rose-700   dark:text-rose-300',    bg: 'bg-rose-50   dark:bg-rose-500/10',    ring: 'border-rose-200   dark:border-rose-500/30'   },
  nature:   { color: 'text-lime-700   dark:text-lime-300',    bg: 'bg-lime-50   dark:bg-lime-500/10',    ring: 'border-lime-200   dark:border-lime-500/30'   },
  goals:    { color: 'text-purple-700 dark:text-purple-300',  bg: 'bg-purple-50 dark:bg-purple-500/10',  ring: 'border-purple-200 dark:border-purple-500/30' },
  evening:  { color: 'text-stone-700  dark:text-stone-300',   bg: 'bg-stone-50  dark:bg-stone-800/30',   ring: 'border-stone-200  dark:border-stone-700'      },
  work:     { color: 'text-zinc-700   dark:text-zinc-300',    bg: 'bg-zinc-50   dark:bg-zinc-500/10',    ring: 'border-zinc-200   dark:border-zinc-500/30'   },
  free:     { color: 'text-neutral-600 dark:text-neutral-400', bg: 'bg-neutral-50 dark:bg-neutral-800/30', ring: 'border-neutral-200 dark:border-neutral-700' },
}

const CAT_LIST: { key: CategoryKey; label: string }[] = [
  { key: 'wakeup',   label: 'Réveil'              },
  { key: 'sport',    label: 'Sport'               },
  { key: 'leads',    label: 'Leads'               },
  { key: 'comms',    label: 'Communications'      },
  { key: 'lunch',    label: 'Repas'               },
  { key: 'closing',  label: 'Closing'             },
  { key: 'service',  label: 'Service client'      },
  { key: 'team',     label: 'Équipe'              },
  { key: 'outdoor',  label: 'Extérieur'           },
  { key: 'rest',     label: 'Repos / Hygiène'     },
  { key: 'learning', label: 'Apprentissage'       },
  { key: 'review',   label: 'Bilan'               },
  { key: 'sleep',    label: 'Sommeil'             },
  { key: 'family',   label: 'Famille'             },
  { key: 'nature',   label: 'Nature'              },
  { key: 'goals',    label: 'Objectifs / Vision'  },
  { key: 'evening',  label: 'Soirée'              },
  { key: 'work',     label: 'Travail (autre)'     },
  { key: 'free',     label: 'Libre'               },
]

/* ─── Default schedule (matches the inspiration board) ─────── */
const WEEKDAY_TEMPLATE: Block[] = [
  { time: '06:00 – 07:00', emoji: '☀️', title: 'Réveil',                  subtitle: 'Eau · méditation · planification du jour', category: 'wakeup'   },
  { time: '07:00 – 08:00', emoji: '💪', title: 'Sport',                   subtitle: 'Force / cardio',                          category: 'sport'    },
  { time: '08:00 – 10:00', emoji: '🎯', title: 'Leads (acquisition)',     subtitle: 'Pubs · messages · recherche',             category: 'leads'    },
  { time: '10:00 – 12:00', emoji: '📞', title: 'Communications',          subtitle: 'Réponse aux prospects',                   category: 'comms'    },
  { time: '12:00 – 13:00', emoji: '🍽️', title: 'Déjeuner + pause',        subtitle: 'Sans écran',                              category: 'lunch'    },
  { time: '13:00 – 15:00', emoji: '🤝', title: 'Closing',                 subtitle: 'Offres · appels · persuasion',            category: 'closing'  },
  { time: '15:00 – 16:00', emoji: '👥', title: 'Suivi clients',           subtitle: 'Service · upsell · fidélité',             category: 'service'  },
  { time: '16:00 – 17:00', emoji: '⚙️', title: 'Équipe & tâches',         subtitle: 'Distribution · supervision',              category: 'team'     },
  { time: '17:00 – 18:00', emoji: '🚶', title: 'Sport / extérieur',       subtitle: 'Marche · air frais',                      category: 'outdoor'  },
  { time: '18:00 – 19:00', emoji: '🛁', title: 'Détente',                 subtitle: 'Bain · repas léger',                      category: 'rest'     },
  { time: '19:00 – 21:00', emoji: '📚', title: 'Apprentissage',           subtitle: 'Lecture · contenus · cours',              category: 'learning' },
  { time: '21:00 – 22:00', emoji: '📊', title: 'Bilan du jour',           subtitle: 'Chiffres · améliorations',                category: 'review'   },
  { time: '22:00 – 23:00', emoji: '🌙', title: 'Écrans off · coucher',    subtitle: 'Sommeil tôt',                             category: 'sleep'    },
]

const FRIDAY_TEMPLATE: Block[] = WEEKDAY_TEMPLATE.map(b => {
  if (b.category === 'comms')   return { ...b, title: 'Closing grandes affaires', subtitle: 'Offres puissantes · négociation', category: 'closing' as CategoryKey, emoji: '⭐' }
  if (b.category === 'team')    return { ...b, title: 'Systèmes & process',       subtitle: 'Tableaux · automatisations',     category: 'work'    as CategoryKey, emoji: '⚙️' }
  if (b.category === 'review')  return { ...b, title: 'Plan de la semaine prochaine', subtitle: 'Objectifs · tâches · priorités', category: 'goals' as CategoryKey, emoji: '📋' }
  return b
})

const SATURDAY_TEMPLATE: Block[] = [
  { time: 'Matin',         emoji: '☀️', title: 'Développement personnel', subtitle: 'Lecture · contenu · formations', category: 'learning' },
  { time: 'Midi',          emoji: '👨‍👩‍👧', title: 'Famille',              subtitle: '',                              category: 'family'   },
  { time: 'Après-midi',    emoji: '📋', title: 'Préparation grande campagne', subtitle: 'Pubs · offres · idées',     category: 'goals'    },
  { time: 'Soir',          emoji: '🌙', title: 'Repos total',             subtitle: 'Aucun travail',                  category: 'evening'  },
]

const SUNDAY_TEMPLATE: Block[] = [
  { time: 'Matin',         emoji: '😴', title: 'Sommeil long',            subtitle: 'Corps & esprit',                 category: 'sleep'    },
  { time: 'Midi',          emoji: '🌳', title: 'Sortie en nature',        subtitle: 'Marche · air pur',               category: 'nature'   },
  { time: 'Après-midi',    emoji: '🎯', title: 'Méditation + objectifs',  subtitle: 'Focus · gratitude · vision',     category: 'goals'    },
  { time: 'Soir',          emoji: '📖', title: 'Lecture / film / détente', subtitle: '',                              category: 'evening'  },
]

const DEFAULT_DATA: PlannerData = {
  title:    'Plan hebdo · Objectif 1 000 000 $',
  subtitle: 'Système quotidien haute productivité pour bâtir une agence digitale rentable',
  goal:     { revenue: 1_000_000, months: 12, avgClient: 700 },
  weeklyKpis: { leads: 150, calls: 50, closings: 15, revenue: 10_000 },
  habits: [
    'Sport quotidien (20–45 min)',
    'Eau (2–2 L par jour)',
    'Lecture / apprentissage 1 h',
    "Pas d'écran après 22:00",
    'Sommeil 7–8 h',
  ],
  rules: [
    "Concentre-toi sur le résultat, pas l'effort.",
    'Chaque jour = un pas vers le grand objectif.',
    'Mesure → Analyse → Améliore → Répète.',
    'Énergie avant temps, focus avant quantité.',
    'Ta santé est ton vrai capital.',
  ],
  days: [
    { day: 'Lundi',    short: 'Lun', weekend: false, blocks: [...WEEKDAY_TEMPLATE] },
    { day: 'Mardi',    short: 'Mar', weekend: false, blocks: [...WEEKDAY_TEMPLATE] },
    { day: 'Mercredi', short: 'Mer', weekend: false, blocks: [...WEEKDAY_TEMPLATE] },
    { day: 'Jeudi',    short: 'Jeu', weekend: false, blocks: [...WEEKDAY_TEMPLATE] },
    { day: 'Vendredi', short: 'Ven', weekend: false, blocks: [...FRIDAY_TEMPLATE]  },
    { day: 'Samedi',   short: 'Sam', weekend: true,  blocks: [...SATURDAY_TEMPLATE] },
    { day: 'Dimanche', short: 'Dim', weekend: true,  blocks: [...SUNDAY_TEMPLATE]   },
  ],
}

/* ─── Persistence ───────────────────────────────────────────── */
function loadData(): PlannerData {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return DEFAULT_DATA
    const parsed = JSON.parse(raw) as PlannerData
    // light shape guard — fall back to defaults if structure is broken
    if (!parsed.days || !parsed.goal || !parsed.weeklyKpis) return DEFAULT_DATA
    return parsed
  } catch { return DEFAULT_DATA }
}

function fmtMoney(n: number) {
  return n.toLocaleString('fr-FR') + ' $'
}

/* ─── Page ──────────────────────────────────────────────────── */
export default function Planificateur() {
  const [data, setData] = useState<PlannerData>(() => loadData())
  const [editing, setEditing] = useState<{ dayIdx: number; blockIdx: number } | null>(null)

  useEffect(() => {
    try { localStorage.setItem(STORAGE_KEY, JSON.stringify(data)) } catch {}
  }, [data])

  const computed = useMemo(() => {
    const perMonth  = Math.round(data.goal.revenue / data.goal.months)
    const perDay    = Math.round(perMonth / 30)
    const clientsPerDay = data.goal.avgClient > 0 ? (perDay / data.goal.avgClient).toFixed(1) : '—'
    return { perMonth, perDay, clientsPerDay }
  }, [data.goal])

  const updateBlock = (dayIdx: number, blockIdx: number, patch: Partial<Block>) => {
    setData(d => {
      const days = d.days.map((day, di) => {
        if (di !== dayIdx) return day
        const blocks = day.blocks.map((b, bi) => bi === blockIdx ? { ...b, ...patch } : b)
        return { ...day, blocks }
      })
      return { ...d, days }
    })
  }

  const addBlock = (dayIdx: number) => {
    setData(d => {
      const days = d.days.map((day, di) => {
        if (di !== dayIdx) return day
        const newBlock: Block = { time: '', emoji: '✨', title: 'Nouvelle activité', subtitle: '', category: 'free' }
        return { ...day, blocks: [...day.blocks, newBlock] }
      })
      return { ...d, days }
    })
    setEditing({ dayIdx, blockIdx: data.days[dayIdx].blocks.length })
  }

  const deleteBlock = (dayIdx: number, blockIdx: number) => {
    setData(d => {
      const days = d.days.map((day, di) => {
        if (di !== dayIdx) return day
        return { ...day, blocks: day.blocks.filter((_, bi) => bi !== blockIdx) }
      })
      return { ...d, days }
    })
    setEditing(null)
  }

  const resetData = () => {
    if (confirm('Réinitialiser tout le plan aux valeurs par défaut ?')) {
      setData(DEFAULT_DATA)
      toast.success('Plan réinitialisé')
    }
  }

  const editingBlock = editing ? data.days[editing.dayIdx].blocks[editing.blockIdx] : null

  return (
    <div className="space-y-6 animate-fade-in pb-10">
      {/* ── Hero / Goal banner ── */}
      <div className="card-premium p-6 bg-gradient-to-br from-slate-900 via-blue-950 to-violet-950 text-white relative overflow-hidden">
        <div className="absolute -top-24 -right-24 w-72 h-72 bg-violet-500/20 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute -bottom-24 -left-24 w-72 h-72 bg-blue-500/20 rounded-full blur-3xl pointer-events-none" />
        <div className="relative flex items-start justify-between gap-4 flex-wrap">
          <div className="flex-1 min-w-0">
            <input
              value={data.title}
              onChange={e => setData(d => ({ ...d, title: e.target.value }))}
              className="bg-transparent text-2xl md:text-3xl font-bold text-white outline-none w-full border-b border-transparent focus:border-white/30 pb-1"
            />
            <input
              value={data.subtitle}
              onChange={e => setData(d => ({ ...d, subtitle: e.target.value }))}
              className="bg-transparent text-sm text-white/70 outline-none w-full mt-1 border-b border-transparent focus:border-white/20 pb-0.5"
            />
          </div>
          <div className="flex items-center gap-2">
            <Button variant="outline" size="sm" onClick={resetData} className="bg-white/10 hover:bg-white/20 border-white/20 text-white gap-1.5">
              <RotateCcw className="w-3.5 h-3.5" />
              Reset
            </Button>
          </div>
        </div>

        <div className="relative grid grid-cols-2 sm:grid-cols-4 gap-3 mt-6">
          <GoalKPI icon={Target} label="Objectif annuel" value={fmtMoney(data.goal.revenue)} />
          <GoalKPI icon={TrendingUp} label="Par mois" value={fmtMoney(computed.perMonth)} />
          <GoalKPI icon={Zap} label="Par jour" value={fmtMoney(computed.perDay)} />
          <GoalKPI icon={Trophy} label="Clients/jour" value={`~${computed.clientsPerDay}`} sub={`${fmtMoney(data.goal.avgClient)} / client`} />
        </div>

        {/* Editable goal inputs */}
        <div className="relative grid grid-cols-1 sm:grid-cols-3 gap-3 mt-4 pt-4 border-t border-white/10">
          <EditNumber
            label="Revenu cible ($)"
            value={data.goal.revenue}
            onChange={v => setData(d => ({ ...d, goal: { ...d.goal, revenue: v } }))}
          />
          <EditNumber
            label="Sur combien de mois"
            value={data.goal.months}
            onChange={v => setData(d => ({ ...d, goal: { ...d.goal, months: Math.max(1, v) } }))}
          />
          <EditNumber
            label="Valeur moyenne / client ($)"
            value={data.goal.avgClient}
            onChange={v => setData(d => ({ ...d, goal: { ...d.goal, avgClient: Math.max(1, v) } }))}
          />
        </div>
      </div>

      {/* ── Weekly schedule grid ── */}
      <div className="space-y-3">
        <div className="flex items-center gap-2">
          <CalendarIcon className="w-4 h-4 text-blue-600 dark:text-blue-400" />
          <h2 className="text-base font-bold text-foreground">Programme hebdomadaire</h2>
          <span className="text-xs text-muted-foreground">— cliquez sur n'importe quelle case pour la modifier</span>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-7 gap-3">
          {data.days.map((day, di) => (
            <DayColumn
              key={day.day}
              day={day}
              onEdit={(bi) => setEditing({ dayIdx: di, blockIdx: bi })}
              onAdd={() => addBlock(di)}
              onChangeName={(name) => setData(d => {
                const days = d.days.map((x, i) => i === di ? { ...x, day: name } : x)
                return { ...d, days }
              })}
            />
          ))}
        </div>
      </div>

      {/* ── KPIs · Habits · Rules ── */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {/* KPIs */}
        <div className="card-premium p-5 space-y-3">
          <h3 className="section-title flex items-center gap-2">
            <TrendingUp className="w-4 h-4 text-emerald-500" /> Indicateurs hebdomadaires
          </h3>
          <KPIRow label="Leads"     value={data.weeklyKpis.leads}    suffix=""        onChange={v => setData(d => ({ ...d, weeklyKpis: { ...d.weeklyKpis, leads: v   } }))} />
          <KPIRow label="Appels"    value={data.weeklyKpis.calls}    suffix=""        onChange={v => setData(d => ({ ...d, weeklyKpis: { ...d.weeklyKpis, calls: v   } }))} />
          <KPIRow label="Closings"  value={data.weeklyKpis.closings} suffix=""        onChange={v => setData(d => ({ ...d, weeklyKpis: { ...d.weeklyKpis, closings: v} }))} />
          <KPIRow label="Revenus"   value={data.weeklyKpis.revenue}  suffix=" $"      onChange={v => setData(d => ({ ...d, weeklyKpis: { ...d.weeklyKpis, revenue: v } }))} />
        </div>

        {/* Habits */}
        <div className="card-premium p-5 space-y-2">
          <h3 className="section-title flex items-center gap-2">
            <ListChecks className="w-4 h-4 text-blue-500" /> Habitudes quotidiennes
          </h3>
          {data.habits.map((h, i) => (
            <div key={i} className="flex items-center gap-2 group">
              <Check className="w-3.5 h-3.5 text-emerald-500 flex-shrink-0" />
              <input
                value={h}
                onChange={e => setData(d => {
                  const habits = [...d.habits]
                  habits[i] = e.target.value
                  return { ...d, habits }
                })}
                className="flex-1 text-sm bg-transparent outline-none border-b border-transparent focus:border-blue-400 pb-0.5"
              />
              <button
                onClick={() => setData(d => ({ ...d, habits: d.habits.filter((_, idx) => idx !== i) }))}
                className="opacity-0 group-hover:opacity-100 text-muted-foreground hover:text-destructive transition"
              >
                <Trash2 className="w-3.5 h-3.5" />
              </button>
            </div>
          ))}
          <button
            onClick={() => setData(d => ({ ...d, habits: [...d.habits, 'Nouvelle habitude'] }))}
            className="flex items-center gap-1 text-xs text-blue-600 dark:text-blue-400 hover:underline pt-1"
          >
            <Plus className="w-3 h-3" /> Ajouter une habitude
          </button>
        </div>

        {/* Rules */}
        <div className="card-premium p-5 space-y-2">
          <h3 className="section-title flex items-center gap-2">
            <Sparkles className="w-4 h-4 text-violet-500" /> Règles d'or
          </h3>
          {data.rules.map((r, i) => (
            <div key={i} className="flex items-start gap-2 group">
              <span className="text-xs font-bold text-violet-600 dark:text-violet-400 mt-0.5">{i + 1}.</span>
              <input
                value={r}
                onChange={e => setData(d => {
                  const rules = [...d.rules]
                  rules[i] = e.target.value
                  return { ...d, rules }
                })}
                className="flex-1 text-sm bg-transparent outline-none border-b border-transparent focus:border-violet-400 pb-0.5"
              />
              <button
                onClick={() => setData(d => ({ ...d, rules: d.rules.filter((_, idx) => idx !== i) }))}
                className="opacity-0 group-hover:opacity-100 text-muted-foreground hover:text-destructive transition"
              >
                <Trash2 className="w-3.5 h-3.5" />
              </button>
            </div>
          ))}
          <button
            onClick={() => setData(d => ({ ...d, rules: [...d.rules, 'Nouvelle règle'] }))}
            className="flex items-center gap-1 text-xs text-violet-600 dark:text-violet-400 hover:underline pt-1"
          >
            <Plus className="w-3 h-3" /> Ajouter une règle
          </button>
        </div>
      </div>

      {/* ── Edit dialog ── */}
      <Dialog open={!!editing} onOpenChange={v => { if (!v) setEditing(null) }}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Edit2 className="w-4 h-4" />
              Modifier la case
            </DialogTitle>
          </DialogHeader>
          {editingBlock && editing && (
            <div className="space-y-3 pt-1">
              <div className="grid grid-cols-[60px_1fr] gap-3">
                <div className="space-y-1.5">
                  <label className="form-label">Emoji</label>
                  <Input
                    value={editingBlock.emoji}
                    onChange={e => updateBlock(editing.dayIdx, editing.blockIdx, { emoji: e.target.value })}
                    className="text-center text-lg"
                    maxLength={4}
                  />
                </div>
                <div className="space-y-1.5">
                  <label className="form-label">Plage horaire / créneau</label>
                  <Input
                    value={editingBlock.time}
                    onChange={e => updateBlock(editing.dayIdx, editing.blockIdx, { time: e.target.value })}
                    placeholder="06:00 – 07:00"
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="form-label">Titre *</label>
                <Input
                  value={editingBlock.title}
                  onChange={e => updateBlock(editing.dayIdx, editing.blockIdx, { title: e.target.value })}
                  autoFocus
                />
              </div>

              <div className="space-y-1.5">
                <label className="form-label">Sous-titre / détail</label>
                <Input
                  value={editingBlock.subtitle ?? ''}
                  onChange={e => updateBlock(editing.dayIdx, editing.blockIdx, { subtitle: e.target.value })}
                  placeholder="Ex: cardio, lecture, etc."
                />
              </div>

              <div className="space-y-1.5">
                <label className="form-label">Catégorie / couleur</label>
                <div className="flex flex-wrap gap-1.5">
                  {CAT_LIST.map(c => (
                    <button
                      key={c.key}
                      onClick={() => updateBlock(editing.dayIdx, editing.blockIdx, { category: c.key })}
                      className={cn(
                        'flex items-center gap-1.5 text-[11px] px-2.5 py-1.5 rounded-lg border transition-all',
                        editingBlock.category === c.key
                          ? `${CAT[c.key].bg} ${CAT[c.key].color} ${CAT[c.key].ring} font-semibold ring-2 ring-current/20`
                          : 'border-border text-muted-foreground hover:bg-muted',
                      )}
                    >
                      <span className={cn('w-2 h-2 rounded-full', CAT[c.key].bg.replace('bg-', 'bg-').split(' ')[0].replace('-50', '-500'))} />
                      {c.label}
                    </button>
                  ))}
                </div>
              </div>

              <div className="flex justify-between gap-2 pt-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => deleteBlock(editing.dayIdx, editing.blockIdx)}
                  className="gap-1.5 text-destructive hover:text-destructive"
                >
                  <Trash2 className="w-3.5 h-3.5" /> Supprimer
                </Button>
                <Button size="sm" onClick={() => setEditing(null)} className="gap-1.5">
                  <Check className="w-3.5 h-3.5" /> Terminé
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  )
}

/* ─── Sub-components ────────────────────────────────────────── */
function DayColumn({ day, onEdit, onAdd, onChangeName }: {
  day: DayPlan
  onEdit: (blockIdx: number) => void
  onAdd: () => void
  onChangeName: (name: string) => void
}) {
  return (
    <div className={cn(
      'card-premium p-3 space-y-2',
      day.weekend && 'bg-gradient-to-b from-amber-50/50 to-white dark:from-amber-500/5 dark:to-transparent',
    )}>
      <div className="text-center pb-2 border-b border-border">
        <input
          value={day.day}
          onChange={e => onChangeName(e.target.value)}
          className={cn(
            'w-full text-center text-sm font-bold uppercase tracking-wider bg-transparent outline-none',
            day.weekend ? 'text-amber-600 dark:text-amber-400' : 'text-blue-600 dark:text-blue-400',
          )}
        />
      </div>

      <div className="space-y-1.5">
        {day.blocks.map((b, bi) => {
          const cfg = CAT[b.category] ?? CAT.free
          return (
            <motion.button
              key={bi}
              layout
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              onClick={() => onEdit(bi)}
              className={cn(
                'w-full text-left p-2 rounded-xl border transition-all',
                cfg.bg, cfg.ring,
              )}
            >
              {b.time && (
                <p className="text-[10px] font-bold opacity-70 uppercase tracking-wide truncate">{b.time}</p>
              )}
              <div className="flex items-start gap-1.5 mt-0.5">
                <span className="text-base leading-none flex-shrink-0">{b.emoji}</span>
                <div className="min-w-0 flex-1">
                  <p className={cn('text-xs font-semibold leading-tight', cfg.color)}>{b.title}</p>
                  {b.subtitle && (
                    <p className="text-[10px] text-muted-foreground leading-tight mt-0.5 line-clamp-2">{b.subtitle}</p>
                  )}
                </div>
              </div>
            </motion.button>
          )
        })}
      </div>

      <button
        onClick={onAdd}
        className="w-full flex items-center justify-center gap-1 text-[10px] py-2 rounded-lg border border-dashed border-border text-muted-foreground hover:bg-muted hover:text-foreground transition"
      >
        <Plus className="w-3 h-3" /> Ajouter
      </button>
    </div>
  )
}

function GoalKPI({ icon: Icon, label, value, sub }: {
  icon: React.ElementType
  label: string
  value: string
  sub?: string
}) {
  return (
    <div className="bg-white/5 backdrop-blur-sm rounded-xl p-3 border border-white/10">
      <div className="flex items-center gap-1.5 text-white/60 text-[10px] uppercase tracking-wider">
        <Icon className="w-3 h-3" />
        {label}
      </div>
      <p className="text-lg md:text-xl font-bold text-white mt-1">{value}</p>
      {sub && <p className="text-[10px] text-white/50 mt-0.5">{sub}</p>}
    </div>
  )
}

function EditNumber({ label, value, onChange }: {
  label: string
  value: number
  onChange: (n: number) => void
}) {
  return (
    <div>
      <label className="text-[10px] uppercase tracking-wider text-white/60">{label}</label>
      <input
        type="number"
        value={value}
        onChange={e => onChange(+e.target.value)}
        className="w-full bg-white/5 border border-white/10 rounded-lg px-3 py-1.5 text-white text-sm font-semibold mt-1 outline-none focus:border-white/30"
      />
    </div>
  )
}

function KPIRow({ label, value, suffix, onChange }: {
  label: string
  value: number
  suffix: string
  onChange: (n: number) => void
}) {
  return (
    <div className="flex items-center justify-between gap-3">
      <span className="text-sm text-muted-foreground">{label}</span>
      <div className="flex items-center gap-1">
        <span className="text-xs text-muted-foreground">≥</span>
        <input
          type="number"
          value={value}
          onChange={e => onChange(+e.target.value)}
          className="w-24 text-right text-sm font-bold bg-transparent border-b border-border outline-none focus:border-blue-500 pb-0.5"
        />
        {suffix && <span className="text-xs text-muted-foreground">{suffix}</span>}
      </div>
    </div>
  )
}
