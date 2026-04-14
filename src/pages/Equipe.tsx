import { useState, useMemo } from 'react'
import { motion } from 'framer-motion'
import {
  Plus, Search, Briefcase, Mail, Phone, Edit2, Trash2, Loader2,
  TrendingUp, Users, DollarSign, CalendarDays
} from 'lucide-react'
import { useTeam, useCreateTeamMember, useUpdateTeamMember, useDeleteTeamMember, type TeamMember } from '@/hooks/useTeam'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs'
import { formatCurrency, formatDate, getInitials } from '@/lib/utils'

const STATUT_COLORS = {
  actif:   { label: 'Actif',   variant: 'success' as const },
  inactif: { label: 'Inactif', variant: 'secondary' as const },
  conge:   { label: 'En congé', variant: 'warning' as const },
}

const DEPT_COLORS: Record<string, string> = {
  Tech: 'text-blue-400 bg-blue-500/20',
  Design: 'text-purple-400 bg-purple-500/20',
  Ventes: 'text-emerald-400 bg-emerald-500/20',
  Admin: 'text-yellow-400 bg-yellow-500/20',
}

function TeamMemberForm({ member, onClose }: { member?: TeamMember; onClose: () => void }) {
  const create = useCreateTeamMember()
  const update = useUpdateTeamMember()
  const [form, setForm] = useState({
    nom: member?.nom || '',
    prenom: member?.prenom || '',
    email: member?.email || '',
    telephone: member?.telephone || '',
    poste: member?.poste || '',
    departement: member?.departement || '',
    salaire_base: member?.salaire_base || 0,
    date_embauche: member?.date_embauche || '',
    statut: member?.statut || 'actif' as TeamMember['statut'],
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (member) await update.mutateAsync({ id: member.id, ...form })
    else await create.mutateAsync(form as any)
    onClose()
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-1.5"><label className="form-label">Prénom</label>
          <Input value={form.prenom} onChange={e => setForm(p => ({ ...p, prenom: e.target.value }))} required /></div>
        <div className="space-y-1.5"><label className="form-label">Nom *</label>
          <Input value={form.nom} onChange={e => setForm(p => ({ ...p, nom: e.target.value }))} required /></div>
        <div className="space-y-1.5"><label className="form-label">Email</label>
          <Input type="email" value={form.email} onChange={e => setForm(p => ({ ...p, email: e.target.value }))} /></div>
        <div className="space-y-1.5"><label className="form-label">Téléphone</label>
          <Input value={form.telephone} onChange={e => setForm(p => ({ ...p, telephone: e.target.value }))} /></div>
        <div className="space-y-1.5"><label className="form-label">Poste</label>
          <Input value={form.poste} onChange={e => setForm(p => ({ ...p, poste: e.target.value }))} /></div>
        <div className="space-y-1.5"><label className="form-label">Département</label>
          <Input value={form.departement} onChange={e => setForm(p => ({ ...p, departement: e.target.value }))} /></div>
        <div className="space-y-1.5"><label className="form-label">Salaire de base (MAD)</label>
          <Input type="number" value={form.salaire_base} onChange={e => setForm(p => ({ ...p, salaire_base: +e.target.value }))} /></div>
        <div className="space-y-1.5"><label className="form-label">Date d'embauche</label>
          <Input type="date" value={form.date_embauche} onChange={e => setForm(p => ({ ...p, date_embauche: e.target.value }))} /></div>
        <div className="space-y-1.5"><label className="form-label">Statut</label>
          <Select value={form.statut} onValueChange={v => setForm(p => ({ ...p, statut: v as TeamMember['statut'] }))}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent>
              {Object.entries(STATUT_COLORS).map(([k, v]) => <SelectItem key={k} value={k}>{v.label}</SelectItem>)}
            </SelectContent>
          </Select></div>
      </div>
      <div className="flex items-center justify-end gap-3 pt-2">
        <Button type="button" variant="secondary" onClick={onClose}>Annuler</Button>
        <Button type="submit" disabled={create.isPending || update.isPending}>
          {(create.isPending || update.isPending) && <Loader2 className="w-4 h-4 animate-spin" />}
          {member ? 'Mettre à jour' : 'Ajouter'}
        </Button>
      </div>
    </form>
  )
}

export default function Equipe() {
  const { data: members = [], isLoading } = useTeam()
  const deleteMember = useDeleteTeamMember()
  const [search, setSearch] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [editing, setEditing] = useState<TeamMember | undefined>()

  const filtered = useMemo(() =>
    members.filter(m => !search || [m.nom, m.prenom, m.poste, m.email, m.departement].some(f => f?.toLowerCase().includes(search.toLowerCase())))
  , [members, search])

  const stats = useMemo(() => ({
    actifs: members.filter(m => m.statut === 'actif').length,
    masseSalariale: members.filter(m => m.statut === 'actif').reduce((s, m) => s + m.salaire_base, 0),
    depts: [...new Set(members.map(m => m.departement).filter(Boolean))].length,
  }), [members])

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title">Équipe</h1>
          <p className="text-muted-foreground text-sm mt-1">{members.length} membres · Masse salariale : {formatCurrency(stats.masseSalariale)}</p>
        </div>
        <Button size="sm" onClick={() => { setEditing(undefined); setShowForm(true) }}>
          <Plus className="w-4 h-4" /> Ajouter un membre
        </Button>
      </div>

      <div className="grid grid-cols-3 gap-4">
        <div className="card p-4 flex items-center gap-3">
          <div className="w-10 h-10 rounded-lg bg-blue-500/20 flex items-center justify-center">
            <Users className="w-5 h-5 text-blue-400" />
          </div>
          <div>
            <p className="text-xl font-bold text-foreground">{stats.actifs}</p>
            <p className="text-xs text-muted-foreground">Membres actifs</p>
          </div>
        </div>
        <div className="card p-4 flex items-center gap-3">
          <div className="w-10 h-10 rounded-lg bg-emerald-500/20 flex items-center justify-center">
            <DollarSign className="w-5 h-5 text-emerald-400" />
          </div>
          <div>
            <p className="text-xl font-bold text-foreground">{formatCurrency(stats.masseSalariale)}</p>
            <p className="text-xs text-muted-foreground">Masse salariale</p>
          </div>
        </div>
        <div className="card p-4 flex items-center gap-3">
          <div className="w-10 h-10 rounded-lg bg-purple-500/20 flex items-center justify-center">
            <Briefcase className="w-5 h-5 text-purple-400" />
          </div>
          <div>
            <p className="text-xl font-bold text-foreground">{stats.depts}</p>
            <p className="text-xs text-muted-foreground">Départements</p>
          </div>
        </div>
      </div>

      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
        <Input placeholder="Rechercher un membre..." value={search} onChange={e => setSearch(e.target.value)} className="pl-9" />
      </div>

      {isLoading ? (
        <div className="flex items-center justify-center py-20"><Loader2 className="w-8 h-8 animate-spin text-blue-400" /></div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {filtered.map((m, i) => (
            <motion.div
              key={m.id}
              initial={{ opacity: 0, y: 12 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.04 }}
              className="card p-5 hover:border-blue-500/30 transition-all duration-300 group"
            >
              <div className="flex items-start gap-3">
                <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-600/30 to-purple-600/30 border border-blue-500/20 flex items-center justify-center flex-shrink-0">
                  <span className="text-blue-300 font-bold text-sm">{getInitials(`${m.prenom} ${m.nom}`)}</span>
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-semibold text-foreground">{m.prenom} {m.nom}</h3>
                  {m.poste && <p className="text-xs text-muted-foreground truncate">{m.poste}</p>}
                </div>
                <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                  <Button variant="ghost" size="icon" className="w-7 h-7" onClick={() => { setEditing(m); setShowForm(true) }}>
                    <Edit2 className="w-3.5 h-3.5" />
                  </Button>
                  <Button variant="ghost" size="icon" className="w-7 h-7 text-red-400" onClick={() => { if (confirm('Supprimer ?')) deleteMember.mutate(m.id) }}>
                    <Trash2 className="w-3.5 h-3.5" />
                  </Button>
                </div>
              </div>

              <div className="mt-4 space-y-1.5">
                {m.email && <div className="flex items-center gap-2 text-xs text-muted-foreground"><Mail className="w-3.5 h-3.5 text-muted-foreground00" />{m.email}</div>}
                {m.telephone && <div className="flex items-center gap-2 text-xs text-muted-foreground"><Phone className="w-3.5 h-3.5 text-muted-foreground00" />{m.telephone}</div>}
                {m.date_embauche && <div className="flex items-center gap-2 text-xs text-muted-foreground"><CalendarDays className="w-3.5 h-3.5 text-muted-foreground00" />Depuis {formatDate(m.date_embauche)}</div>}
              </div>

              <div className="mt-3 pt-3 border-t border-border flex items-center justify-between">
                <div className="flex items-center gap-2">
                  {m.departement && (
                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${DEPT_COLORS[m.departement] || 'text-muted-foreground bg-muted'}`}>
                      {m.departement}
                    </span>
                  )}
                  <Badge variant={STATUT_COLORS[m.statut]?.variant}>{STATUT_COLORS[m.statut]?.label}</Badge>
                </div>
                <span className="text-sm font-semibold text-emerald-400">{formatCurrency(m.salaire_base)}</span>
              </div>
            </motion.div>
          ))}
          {filtered.length === 0 && (
            <div className="col-span-full empty-state">
              <Users className="empty-state-icon" />
              <p className="empty-state-title">Aucun membre trouvé</p>
            </div>
          )}
        </div>
      )}

      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>{editing ? 'Modifier le membre' : 'Ajouter un membre'}</DialogTitle>
          </DialogHeader>
          <TeamMemberForm member={editing} onClose={() => { setShowForm(false); setEditing(undefined) }} />
        </DialogContent>
      </Dialog>
    </div>
  )
}
