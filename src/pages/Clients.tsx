import { useState, useMemo } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import {
  Plus, Search, User, Building2, Phone, Mail, MapPin,
  Edit2, Trash2, Loader2, Eye, Download
} from 'lucide-react'
import { useClients, useCreateClient, useUpdateClient, useDeleteClient, type Client } from '@/hooks/useClients'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { formatDate, getInitials } from '@/lib/utils'

function ClientForm({ client, onClose }: { client?: Client; onClose: () => void }) {
  const create = useCreateClient()
  const update = useUpdateClient()
  const [form, setForm] = useState({
    nom: client?.nom || '',
    email: client?.email || '',
    telephone: client?.telephone || '',
    entreprise: client?.entreprise || '',
    adresse: client?.adresse || '',
    ville: client?.ville || '',
    pays: client?.pays || 'Maroc',
    notes: client?.notes || '',
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (client) await update.mutateAsync({ id: client.id, ...form })
    else await create.mutateAsync(form as any)
    onClose()
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-1.5 col-span-2 sm:col-span-1">
          <label className="form-label">Nom complet *</label>
          <Input value={form.nom} onChange={e => setForm(p => ({ ...p, nom: e.target.value }))} required />
        </div>
        <div className="space-y-1.5">
          <label className="form-label">Entreprise</label>
          <Input value={form.entreprise} onChange={e => setForm(p => ({ ...p, entreprise: e.target.value }))} />
        </div>
        <div className="space-y-1.5">
          <label className="form-label">Email</label>
          <Input type="email" value={form.email} onChange={e => setForm(p => ({ ...p, email: e.target.value }))} />
        </div>
        <div className="space-y-1.5">
          <label className="form-label">Téléphone</label>
          <Input value={form.telephone} onChange={e => setForm(p => ({ ...p, telephone: e.target.value }))} />
        </div>
        <div className="space-y-1.5">
          <label className="form-label">Adresse</label>
          <Input value={form.adresse} onChange={e => setForm(p => ({ ...p, adresse: e.target.value }))} />
        </div>
        <div className="space-y-1.5">
          <label className="form-label">Ville</label>
          <Input value={form.ville} onChange={e => setForm(p => ({ ...p, ville: e.target.value }))} />
        </div>
        <div className="space-y-1.5">
          <label className="form-label">Pays</label>
          <Input value={form.pays} onChange={e => setForm(p => ({ ...p, pays: e.target.value }))} />
        </div>
      </div>
      <div className="space-y-1.5">
        <label className="form-label">Notes</label>
        <textarea value={form.notes} onChange={e => setForm(p => ({ ...p, notes: e.target.value }))}
          className="input-field resize-none h-20" placeholder="Notes internes..." />
      </div>
      <div className="flex items-center justify-end gap-3 pt-2">
        <Button type="button" variant="secondary" onClick={onClose}>Annuler</Button>
        <Button type="submit" disabled={create.isPending || update.isPending}>
          {(create.isPending || update.isPending) && <Loader2 className="w-4 h-4 animate-spin" />}
          {client ? 'Mettre à jour' : 'Créer client'}
        </Button>
      </div>
    </form>
  )
}

export default function Clients() {
  const navigate = useNavigate()
  const { data: clients = [], isLoading } = useClients()
  const deleteClient = useDeleteClient()
  const [search, setSearch] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [editingClient, setEditingClient] = useState<Client | undefined>()

  const filtered = useMemo(() =>
    clients.filter(c => !search || [c.nom, c.email, c.entreprise, c.ville].some(f => f?.toLowerCase().includes(search.toLowerCase())))
  , [clients, search])

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title">Clients</h1>
          <p className="text-muted-foreground text-sm mt-1">{clients.length} clients au total</p>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="secondary" size="sm">
            <Download className="w-4 h-4" />
            Exporter
          </Button>
          <Button size="sm" onClick={() => { setEditingClient(undefined); setShowForm(true) }}>
            <Plus className="w-4 h-4" />
            Nouveau client
          </Button>
        </div>
      </div>

      {/* Search */}
      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
        <Input placeholder="Rechercher un client..." value={search} onChange={e => setSearch(e.target.value)} className="pl-9" />
      </div>

      {/* Grid */}
      {isLoading ? (
        <div className="flex items-center justify-center py-20">
          <Loader2 className="w-8 h-8 animate-spin text-blue-400" />
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {filtered.map((c, i) => (
            <motion.div
              key={c.id}
              initial={{ opacity: 0, y: 12 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.04 }}
              className="card p-5 hover:border-blue-500/30 transition-all duration-300 group"
            >
              <div className="flex items-start gap-3">
                <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-600/30 to-blue-800/30 border border-blue-500/20 flex items-center justify-center flex-shrink-0">
                  <span className="text-blue-300 font-bold text-sm">{getInitials(c.nom)}</span>
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-semibold text-foreground truncate">{c.nom}</h3>
                  {c.entreprise && (
                    <div className="flex items-center gap-1 mt-0.5">
                      <Building2 className="w-3 h-3 text-muted-foreground" />
                      <span className="text-xs text-muted-foreground truncate">{c.entreprise}</span>
                    </div>
                  )}
                </div>
                <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                  <Button variant="ghost" size="icon" className="w-7 h-7" onClick={() => { setEditingClient(c); setShowForm(true) }}>
                    <Edit2 className="w-3.5 h-3.5" />
                  </Button>
                  <Button variant="ghost" size="icon" className="w-7 h-7 text-red-400" onClick={() => { if (confirm('Supprimer ce client ?')) deleteClient.mutate(c.id) }}>
                    <Trash2 className="w-3.5 h-3.5" />
                  </Button>
                </div>
              </div>

              <div className="mt-4 space-y-1.5">
                {c.email && (
                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                    <Mail className="w-3.5 h-3.5 text-muted-foreground" />
                    <span className="truncate">{c.email}</span>
                  </div>
                )}
                {c.telephone && (
                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                    <Phone className="w-3.5 h-3.5 text-muted-foreground" />
                    <span>{c.telephone}</span>
                  </div>
                )}
                {(c.ville || c.pays) && (
                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                    <MapPin className="w-3.5 h-3.5 text-muted-foreground" />
                    <span>{[c.ville, c.pays].filter(Boolean).join(', ')}</span>
                  </div>
                )}
              </div>

              {c.notes && (
                <div className="mt-3 pt-3 border-t border-border">
                  <p className="text-xs text-muted-foreground line-clamp-2">{c.notes}</p>
                </div>
              )}

              <div className="mt-3 pt-3 border-t border-border flex items-center justify-between">
                <span className="text-xs text-muted-foreground">Depuis {formatDate(c.created_at)}</span>
                <Button variant="ghost" size="sm" className="h-7 text-xs text-blue-400 hover:text-blue-300"
                  onClick={() => navigate(`/clients/${c.id}`)}>
                  <Eye className="w-3 h-3 mr-1" />
                  Détails
                </Button>
              </div>
            </motion.div>
          ))}

          {filtered.length === 0 && (
            <div className="col-span-full empty-state">
              <User className="empty-state-icon" />
              <p className="empty-state-title">Aucun client trouvé</p>
              <p className="empty-state-desc">Ajoutez votre premier client ou modifiez votre recherche</p>
            </div>
          )}
        </div>
      )}

      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>{editingClient ? 'Modifier le client' : 'Nouveau client'}</DialogTitle>
          </DialogHeader>
          <ClientForm client={editingClient} onClose={() => { setShowForm(false); setEditingClient(undefined) }} />
        </DialogContent>
      </Dialog>
    </div>
  )
}
