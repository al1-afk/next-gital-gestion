import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Plus, Repeat, Trash2, AlertTriangle, DollarSign, CalendarClock } from 'lucide-react'
import { motion } from 'framer-motion'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { formatCurrency, formatDate, getDaysUntil } from '@/lib/utils'
import { abonnementsApi } from '@/lib/api'
import { toast } from 'sonner'
import { ImportExportButtons } from '@/components/ImportExportButtons'
import { abonnementsSchema } from '@/lib/importExportSchemas'

interface Abonnement {
  id: string; created_at: string; nom: string; fournisseur: string; montant: number
  cycle: 'mensuel' | 'annuel' | 'trimestriel'; date_renouvellement: string
  statut: 'actif' | 'inactif' | 'annule'; categorie: string
}

const EMPTY = { nom: '', fournisseur: '', montant: 0, cycle: 'mensuel' as Abonnement['cycle'], date_renouvellement: '', statut: 'actif' as Abonnement['statut'], categorie: '' }

function toMensuel(a: Abonnement) {
  if (a.cycle === 'mensuel')     return a.montant
  if (a.cycle === 'annuel')      return a.montant / 12
  if (a.cycle === 'trimestriel') return a.montant / 3
  return 0
}

export default function Abonnements() {
  const qc = useQueryClient()
  const { data: abonnements = [], isLoading } = useQuery<Abonnement[]>({
    queryKey: ['abonnements'],
    queryFn: () => abonnementsApi.list({ orderBy: 'date_renouvellement', order: 'asc' }) as Promise<Abonnement[]>,
  })

  const create = useMutation({
    mutationFn: (data: typeof EMPTY) => abonnementsApi.create(data),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['abonnements'] }); toast.success('Abonnement ajouté'); setShowForm(false); setForm(EMPTY) },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
  const remove = useMutation({
    mutationFn: (id: string) => abonnementsApi.remove(id),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['abonnements'] }); toast.success('Supprimé') },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })

  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState(EMPTY)

  const actifs = abonnements.filter(a => a.statut === 'actif')
  const totalMensuel = actifs.reduce((s, a) => s + toMensuel(a), 0)
  const prochains = actifs.filter(a => getDaysUntil(a.date_renouvellement) <= 30).length

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title">Abonnements</h1>
          <p className="text-muted-foreground text-sm mt-1">{actifs.length} actifs · {formatCurrency(totalMensuel)}/mois</p>
        </div>
        <div className="flex items-center gap-2">
          <ImportExportButtons
            schema={abonnementsSchema}
            data={abonnements}
            onImport={async (row) => { await create.mutateAsync(row as any) }}
          />
          <Button size="sm" onClick={() => setShowForm(true)}><Plus className="w-4 h-4" /> Ajouter</Button>
        </div>
      </div>

      <div className="grid grid-cols-3 gap-4">
        <div className="card-premium p-5 flex items-center gap-4">
          <div className="w-11 h-11 rounded-xl bg-blue-50 dark:bg-blue-900/20 flex items-center justify-center flex-shrink-0">
            <DollarSign className="w-5 h-5 text-blue-600 dark:text-blue-400" />
          </div>
          <div><p className="text-xl font-extrabold text-foreground">{formatCurrency(totalMensuel)}</p><p className="text-xs text-muted-foreground mt-0.5">Coût mensuel</p></div>
        </div>
        <div className="card-premium p-5 flex items-center gap-4">
          <div className="w-11 h-11 rounded-xl bg-purple-50 dark:bg-purple-900/20 flex items-center justify-center flex-shrink-0">
            <Repeat className="w-5 h-5 text-purple-600 dark:text-purple-400" />
          </div>
          <div><p className="text-xl font-extrabold text-purple-600 dark:text-purple-400">{formatCurrency(totalMensuel * 12)}</p><p className="text-xs text-muted-foreground mt-0.5">Coût annuel</p></div>
        </div>
        <div className="card-premium p-5 flex items-center gap-4">
          <div className="w-11 h-11 rounded-xl bg-amber-50 dark:bg-amber-900/20 flex items-center justify-center flex-shrink-0">
            <CalendarClock className="w-5 h-5 text-amber-600 dark:text-amber-400" />
          </div>
          <div><p className="text-xl font-extrabold text-amber-600 dark:text-amber-400">{prochains}</p><p className="text-xs text-muted-foreground mt-0.5">Renouvellements à venir</p></div>
        </div>
      </div>

      {isLoading ? <div className="text-center text-muted-foreground text-sm py-10">Chargement...</div> : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {abonnements.map((a, i) => {
            const days = getDaysUntil(a.date_renouvellement)
            return (
              <motion.div key={a.id} initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.04 }}
                className={`card-premium p-4 hover:border-blue-500/30 transition-all group ${days <= 15 ? 'border-yellow-500/20' : ''}`}>
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <div className="w-9 h-9 rounded-lg bg-blue-500/20 flex items-center justify-center flex-shrink-0">
                      <Repeat className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                    </div>
                    <div>
                      <p className="font-medium text-foreground text-sm">{a.nom}</p>
                      <p className="text-xs text-muted-foreground">{a.fournisseur}</p>
                    </div>
                  </div>
                  {days <= 15 && <AlertTriangle className="w-4 h-4 text-amber-600 dark:text-yellow-400 flex-shrink-0" />}
                </div>
                <div className="flex items-center justify-between text-sm">
                  <div>
                    <p className="text-lg font-bold text-foreground">{formatCurrency(a.montant)}</p>
                    <p className="text-xs text-muted-foreground capitalize">/ {a.cycle}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-xs text-muted-foreground">Renouvellement</p>
                    <p className="text-xs font-medium text-foreground">{formatDate(a.date_renouvellement)}</p>
                    <span className={`badge-pill mt-0.5 ${days <= 15 ? 'badge-warning' : days <= 30 ? 'badge-info' : 'badge-success'}`}>{days}j</span>
                  </div>
                </div>
                <div className="mt-3 pt-2 border-t border-border flex items-center justify-between">
                  <span className="text-xs text-muted-foreground capitalize">{a.categorie}</span>
                  <Button variant="ghost" size="icon" className="w-7 h-7 text-red-400 opacity-0 group-hover:opacity-100" onClick={() => remove.mutate(a.id)}>
                    <Trash2 className="w-3.5 h-3.5" />
                  </Button>
                </div>
              </motion.div>
            )
          })}
          {abonnements.length === 0 && <div className="col-span-full empty-state"><Repeat className="empty-state-icon" /><p className="empty-state-title">Aucun abonnement</p></div>}
        </div>
      )}

      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent>
          <DialogHeader><DialogTitle>Nouvel abonnement</DialogTitle></DialogHeader>
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5 col-span-2"><label className="form-label">Nom *</label><Input value={form.nom} onChange={e => setForm(p => ({ ...p, nom: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Fournisseur</label><Input value={form.fournisseur} onChange={e => setForm(p => ({ ...p, fournisseur: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Catégorie</label><Input value={form.categorie} onChange={e => setForm(p => ({ ...p, categorie: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Montant (MAD)</label><Input type="number" value={form.montant} onChange={e => setForm(p => ({ ...p, montant: +e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Cycle</label>
                <Select value={form.cycle} onValueChange={v => setForm(p => ({ ...p, cycle: v as Abonnement['cycle'] }))}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="mensuel">Mensuel</SelectItem>
                    <SelectItem value="trimestriel">Trimestriel</SelectItem>
                    <SelectItem value="annuel">Annuel</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-1.5 col-span-2"><label className="form-label">Prochain renouvellement</label><Input type="date" value={form.date_renouvellement} onChange={e => setForm(p => ({ ...p, date_renouvellement: e.target.value }))} /></div>
            </div>
            <div className="flex justify-end gap-3">
              <Button variant="secondary" onClick={() => setShowForm(false)}>Annuler</Button>
              <Button disabled={create.isPending || !form.nom} onClick={() => create.mutate(form)}>
                {create.isPending ? 'Ajout...' : 'Ajouter'}
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
