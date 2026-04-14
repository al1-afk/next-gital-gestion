import { useState, useMemo } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Plus, Search, CheckSquare, Circle, CheckCircle2, Clock, AlertTriangle, Loader2, Trash2, Edit2, Calendar, Flag } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { formatDate } from '@/lib/utils'
import { toast } from 'sonner'

interface Task {
  id: string; titre: string; description?: string; statut: 'todo' | 'en_cours' | 'done'
  priorite: 'urgent_important' | 'important' | 'urgent' | 'low'; date_echeance?: string; created_at: string
}

const MOCK_TASKS: Task[] = [
  { id: '1', titre: 'Terminer la maquette du site Hôtel Atlas', statut: 'en_cours', priorite: 'urgent_important', date_echeance: '2026-04-15', created_at: '2026-04-10' },
  { id: '2', titre: 'Relancer PharmaTech pour le devis', statut: 'todo', priorite: 'urgent', date_echeance: '2026-04-12', created_at: '2026-04-10' },
  { id: '3', titre: 'Préparer rapport mensuel des ventes', statut: 'todo', priorite: 'important', date_echeance: '2026-04-20', created_at: '2026-04-09' },
  { id: '4', titre: 'Formation équipe sur le nouveau CRM', statut: 'todo', priorite: 'important', date_echeance: '2026-04-25', created_at: '2026-04-08' },
  { id: '5', titre: 'Mettre à jour les CGU du site', statut: 'done', priorite: 'low', created_at: '2026-04-07' },
  { id: '6', titre: 'Appel client FoodTech MA', statut: 'done', priorite: 'urgent', created_at: '2026-04-06' },
]

const PRIORITE_CONFIG = {
  urgent_important: { label: 'Urgent & Important', color: 'text-red-400', bg: 'bg-red-500/20', icon: AlertTriangle },
  important:        { label: 'Important',          color: 'text-blue-400', bg: 'bg-blue-500/20', icon: Flag },
  urgent:           { label: 'Urgent',             color: 'text-yellow-400', bg: 'bg-yellow-500/20', icon: Clock },
  low:              { label: 'Faible priorité',    color: 'text-muted-foreground', bg: 'bg-muted', icon: Circle },
}

const STATUT_CONFIG = {
  todo:     { label: 'À faire', icon: Circle },
  en_cours: { label: 'En cours', icon: Clock },
  done:     { label: 'Terminé', icon: CheckCircle2 },
}

export default function Taches() {
  const [tasks, setTasks] = useState<Task[]>(MOCK_TASKS)
  const [search, setSearch] = useState('')
  const [filterStatut, setFilterStatut] = useState('all')
  const [showForm, setShowForm] = useState(false)
  const [newTask, setNewTask] = useState({ titre: '', description: '', priorite: 'important' as Task['priorite'], date_echeance: '' })

  const filtered = useMemo(() =>
    tasks.filter(t => {
      const matchSearch = !search || t.titre.toLowerCase().includes(search.toLowerCase())
      const matchStatut = filterStatut === 'all' || t.statut === filterStatut
      return matchSearch && matchStatut
    })
  , [tasks, search, filterStatut])

  const stats = useMemo(() => ({
    todo: tasks.filter(t => t.statut === 'todo').length,
    en_cours: tasks.filter(t => t.statut === 'en_cours').length,
    done: tasks.filter(t => t.statut === 'done').length,
    urgent: tasks.filter(t => (t.priorite === 'urgent' || t.priorite === 'urgent_important') && t.statut !== 'done').length,
  }), [tasks])

  const toggleStatut = (id: string) => {
    setTasks(prev => prev.map(t => {
      if (t.id !== id) return t
      const next: Task['statut'] = t.statut === 'todo' ? 'en_cours' : t.statut === 'en_cours' ? 'done' : 'todo'
      return { ...t, statut: next }
    }))
    toast.success('Tâche mise à jour')
  }

  const deleteTask = (id: string) => {
    setTasks(prev => prev.filter(t => t.id !== id))
    toast.success('Tâche supprimée')
  }

  const addTask = () => {
    if (!newTask.titre) return
    const task: Task = {
      id: Date.now().toString(),
      ...newTask,
      statut: 'todo',
      created_at: new Date().toISOString().slice(0, 10),
    }
    setTasks(prev => [task, ...prev])
    setNewTask({ titre: '', description: '', priorite: 'important', date_echeance: '' })
    setShowForm(false)
    toast.success('Tâche créée')
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title">Tâches personnelles</h1>
          <p className="text-muted-foreground text-sm mt-1">{stats.urgent} urgentes · {stats.todo} à faire · {stats.done} terminées</p>
        </div>
        <Button size="sm" onClick={() => setShowForm(true)}>
          <Plus className="w-4 h-4" /> Nouvelle tâche
        </Button>
      </div>

      {/* Eisenhower Matrix mini summary */}
      <div className="grid grid-cols-4 gap-3">
        {[
          { label: 'À faire', count: stats.todo, color: 'text-muted-foreground', bg: 'bg-muted' },
          { label: 'En cours', count: stats.en_cours, color: 'text-blue-400', bg: 'bg-blue-500/10' },
          { label: 'Terminées', count: stats.done, color: 'text-emerald-400', bg: 'bg-emerald-500/10' },
          { label: 'Urgentes', count: stats.urgent, color: 'text-red-400', bg: 'bg-red-500/10' },
        ].map(s => (
          <div key={s.label} className={`card p-3 ${s.bg} text-center`}>
            <p className={`text-xl font-bold ${s.color}`}>{s.count}</p>
            <p className="text-xs text-muted-foreground mt-0.5">{s.label}</p>
          </div>
        ))}
      </div>

      {/* Filters */}
      <div className="flex items-center gap-3">
        <div className="relative flex-1 min-w-48">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input placeholder="Rechercher une tâche..." value={search} onChange={e => setSearch(e.target.value)} className="pl-9" />
        </div>
        <Select value={filterStatut} onValueChange={setFilterStatut}>
          <SelectTrigger className="w-36"><SelectValue /></SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Tous</SelectItem>
            <SelectItem value="todo">À faire</SelectItem>
            <SelectItem value="en_cours">En cours</SelectItem>
            <SelectItem value="done">Terminées</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Task list */}
      <div className="space-y-2">
        <AnimatePresence>
          {filtered.map((task) => {
            const pConfig = PRIORITE_CONFIG[task.priorite]
            const sConfig = STATUT_CONFIG[task.statut]
            return (
              <motion.div
                key={task.id}
                layout
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, x: -20 }}
                className={`card p-4 group flex items-start gap-3 ${task.statut === 'done' ? 'opacity-60' : ''}`}
              >
                <button
                  onClick={() => toggleStatut(task.id)}
                  className={`mt-0.5 flex-shrink-0 w-5 h-5 rounded-full border-2 flex items-center justify-center transition-all ${
                    task.statut === 'done' ? 'bg-emerald-500 border-emerald-500' :
                    task.statut === 'en_cours' ? 'border-blue-500' : 'border-slate-600'
                  }`}
                >
                  {task.statut === 'done' && <CheckCircle2 className="w-3.5 h-3.5 text-white" />}
                  {task.statut === 'en_cours' && <div className="w-2 h-2 rounded-full bg-blue-500" />}
                </button>

                <div className="flex-1 min-w-0">
                  <div className="flex items-start gap-2 flex-wrap">
                    <p className={`font-medium text-sm ${task.statut === 'done' ? 'text-muted-foreground line-through' : 'text-foreground'}`}>
                      {task.titre}
                    </p>
                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${pConfig.bg} ${pConfig.color}`}>
                      {pConfig.label}
                    </span>
                  </div>
                  {task.description && <p className="text-xs text-muted-foreground mt-0.5">{task.description}</p>}
                  <div className="flex items-center gap-3 mt-1">
                    <span className={`text-xs ${task.statut === 'en_cours' ? 'text-blue-400' : 'text-muted-foreground'}`}>
                      {sConfig.label}
                    </span>
                    {task.date_echeance && (
                      <span className="flex items-center gap-1 text-xs text-muted-foreground">
                        <Calendar className="w-3 h-3" />
                        {formatDate(task.date_echeance)}
                      </span>
                    )}
                  </div>
                </div>

                <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                  <Button variant="ghost" size="icon" className="w-7 h-7 text-red-400" onClick={() => deleteTask(task.id)}>
                    <Trash2 className="w-3.5 h-3.5" />
                  </Button>
                </div>
              </motion.div>
            )
          })}
        </AnimatePresence>

        {filtered.length === 0 && (
          <div className="empty-state">
            <CheckSquare className="empty-state-icon" />
            <p className="empty-state-title">Aucune tâche trouvée</p>
            <p className="empty-state-desc">Créez votre première tâche pour commencer</p>
          </div>
        )}
      </div>

      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent>
          <DialogHeader><DialogTitle>Nouvelle tâche</DialogTitle></DialogHeader>
          <div className="space-y-4">
            <div className="space-y-1.5">
              <label className="form-label">Titre *</label>
              <Input autoFocus value={newTask.titre} onChange={e => setNewTask(p => ({ ...p, titre: e.target.value }))} placeholder="Titre de la tâche..." />
            </div>
            <div className="space-y-1.5">
              <label className="form-label">Description</label>
              <textarea value={newTask.description} onChange={e => setNewTask(p => ({ ...p, description: e.target.value }))}
                className="input-field resize-none h-20" placeholder="Détails..." />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="form-label">Priorité</label>
                <Select value={newTask.priorite} onValueChange={v => setNewTask(p => ({ ...p, priorite: v as Task['priorite'] }))}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    {Object.entries(PRIORITE_CONFIG).map(([k, v]) => <SelectItem key={k} value={k}>{v.label}</SelectItem>)}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-1.5">
                <label className="form-label">Échéance</label>
                <Input type="date" value={newTask.date_echeance} onChange={e => setNewTask(p => ({ ...p, date_echeance: e.target.value }))} />
              </div>
            </div>
            <div className="flex justify-end gap-3">
              <Button variant="secondary" onClick={() => setShowForm(false)}>Annuler</Button>
              <Button onClick={addTask}>Créer la tâche</Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
