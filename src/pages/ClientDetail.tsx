import { useState, useMemo } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  ArrowLeft, Plus, Edit2, Trash2, Phone, Mail, MapPin,
  Building2, CheckSquare, Clock, FileText, Receipt,
  CreditCard, FileCheck, DollarSign, Package, Upload,
  ChevronDown, ChevronRight, User, Bell, Calendar,
  Loader2, AlertCircle, Circle, CheckCircle2, AlertTriangle,
} from 'lucide-react'
import { Button }  from '@/components/ui/button'
import { Input }   from '@/components/ui/input'
import { Badge }   from '@/components/ui/badge'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { useClients, useUpdateClient, useDeleteClient, type Client } from '@/hooks/useClients'
import { useFactures }  from '@/hooks/useFactures'
import { useDevis }     from '@/hooks/useDevis'
import { formatDate, formatCurrency, getInitials } from '@/lib/utils'
import { toast } from 'sonner'

/* ─── Section wrapper ─────────────────────────────────────────────── */
function Section({
  title, icon: Icon, count, action, children, accent = '#378ADD',
}: {
  title:    string
  icon:     React.ElementType
  count?:   number
  action?:  { label: string; onClick: () => void }
  children: React.ReactNode
  accent?:  string
}) {
  const [open, setOpen] = useState(true)
  return (
    <div className="card overflow-hidden">
      <div
        className="flex items-center justify-between px-4 py-3 cursor-pointer select-none hover:bg-muted/30 transition-colors"
        onClick={() => setOpen(o => !o)}
      >
        <div className="flex items-center gap-2">
          <Icon className="w-4 h-4 text-muted-foreground" />
          <span className="text-sm font-semibold text-foreground">{title}</span>
          {count !== undefined && (
            <span className="text-xs px-1.5 py-0.5 rounded-full bg-muted text-muted-foreground font-medium">
              {count}
            </span>
          )}
        </div>
        <div className="flex items-center gap-2">
          {action && open && (
            <button
              className="flex items-center gap-1 text-xs font-medium px-2.5 py-1 rounded-lg transition-colors hover:bg-muted"
              style={{ color: accent }}
              onClick={e => { e.stopPropagation(); action.onClick() }}
            >
              <Plus className="w-3 h-3" />
              {action.label}
            </button>
          )}
          {open ? <ChevronDown className="w-4 h-4 text-muted-foreground" /> : <ChevronRight className="w-4 h-4 text-muted-foreground" />}
        </div>
      </div>
      <AnimatePresence initial={false}>
        {open && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.2 }}
            className="overflow-hidden"
          >
            <div className="border-t border-border px-4 py-3">
              {children}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}

function EmptyState({ label }: { label: string }) {
  return (
    <p className="text-sm text-muted-foreground py-2 text-center">{label}</p>
  )
}

/* ─── Statut badges ───────────────────────────────────────────────── */
const DEVIS_STATUT: Record<string, { label: string; color: string }> = {
  brouillon: { label: 'Brouillon', color: 'text-muted-foreground' },
  envoye:    { label: 'Envoyé',    color: 'text-blue-400'         },
  accepte:   { label: 'Accepté',   color: 'text-emerald-400'      },
  refuse:    { label: 'Refusé',    color: 'text-red-400'          },
  expire:    { label: 'Expiré',    color: 'text-amber-400'        },
}

const FACTURE_STATUT: Record<string, { label: string; color: string }> = {
  brouillon: { label: 'Brouillon', color: 'text-muted-foreground' },
  envoyee:   { label: 'Envoyée',   color: 'text-blue-400'         },
  impayee:   { label: 'Impayée',   color: 'text-red-400'          },
  partielle: { label: 'Partielle', color: 'text-amber-400'        },
  payee:     { label: 'Payée',     color: 'text-emerald-400'      },
  annulee:   { label: 'Annulée',   color: 'text-muted-foreground' },
  refusee:   { label: 'Refusée',   color: 'text-red-400'          },
}

/* ─── Note interface ──────────────────────────────────────────────── */
interface ClientNote {
  id:         string
  created_at: string
  tag:        string
  text:       string
}

/* ─── Client edit form ────────────────────────────────────────────── */
function ClientEditForm({ client, onClose }: { client: Client; onClose: () => void }) {
  const update = useUpdateClient()
  const [form, setForm] = useState({
    nom:        client.nom,
    email:      client.email ?? '',
    telephone:  client.telephone ?? '',
    entreprise: client.entreprise ?? '',
    adresse:    client.adresse ?? '',
    ville:      client.ville ?? '',
    pays:       client.pays ?? 'Maroc',
    notes:      client.notes ?? '',
  })
  const s = (k: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
    setForm(p => ({ ...p, [k]: e.target.value }))

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    update.mutate({ id: client.id, ...form }, { onSuccess: onClose })
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="grid grid-cols-2 gap-3">
        <div className="space-y-1.5 col-span-2">
          <label className="form-label">Nom complet *</label>
          <Input value={form.nom} onChange={s('nom')} required />
        </div>
        <div className="space-y-1.5">
          <label className="form-label">Email</label>
          <Input type="email" value={form.email} onChange={s('email')} />
        </div>
        <div className="space-y-1.5">
          <label className="form-label">Téléphone</label>
          <Input value={form.telephone} onChange={s('telephone')} />
        </div>
        <div className="space-y-1.5">
          <label className="form-label">Entreprise</label>
          <Input value={form.entreprise} onChange={s('entreprise')} />
        </div>
        <div className="space-y-1.5">
          <label className="form-label">Ville</label>
          <Input value={form.ville} onChange={s('ville')} />
        </div>
        <div className="space-y-1.5 col-span-2">
          <label className="form-label">Adresse</label>
          <Input value={form.adresse} onChange={s('adresse')} />
        </div>
      </div>
      <div className="space-y-1.5">
        <label className="form-label">Notes internes</label>
        <textarea value={form.notes} onChange={s('notes')} className="input-field resize-none h-20" />
      </div>
      <div className="flex justify-end gap-3 pt-1">
        <Button type="button" variant="secondary" size="sm" onClick={onClose}>Annuler</Button>
        <Button type="submit" size="sm" disabled={update.isPending}>
          {update.isPending && <Loader2 className="w-3.5 h-3.5 animate-spin" />}
          Enregistrer
        </Button>
      </div>
    </form>
  )
}

/* ─── Main page ───────────────────────────────────────────────────── */
export default function ClientDetail() {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const { data: clients = [] }   = useClients()
  const { data: allFactures = [] } = useFactures()
  const { data: allDevis = [] }    = useDevis()
  const deleteClient = useDeleteClient()

  const client = clients.find(c => c.id === id)

  const factures = useMemo(() => allFactures.filter(f => f.client_id === id), [allFactures, id])
  const devis    = useMemo(() => allDevis.filter(d => d.client_id === id),    [allDevis, id])

  /* ── Local state (mock until DB wired) ── */
  const [tasks,     setTasks]     = useState<{ id: string; titre: string; done: boolean }[]>([])
  const [notes,     setNotes]     = useState<ClientNote[]>([
    client?.notes
      ? { id: '0', created_at: new Date().toISOString(), tag: 'Info', text: client.notes }
      : null,
  ].filter(Boolean) as ClientNote[])
  const [newNote,   setNewNote]   = useState('')
  const [noteTag,   setNoteTag]   = useState('Info')
  const [newTask,   setNewTask]   = useState('')
  const [editOpen,  setEditOpen]  = useState(false)
  const [delConfirm, setDelConfirm] = useState(false)

  if (!client) {
    return (
      <div className="flex flex-col items-center justify-center py-32 gap-4">
        <AlertCircle className="w-10 h-10 text-muted-foreground" />
        <p className="text-muted-foreground">Client introuvable.</p>
        <Button size="sm" variant="secondary" onClick={() => navigate('/clients')}>
          <ArrowLeft className="w-4 h-4" /> Retour aux clients
        </Button>
      </div>
    )
  }

  const initials = getInitials(client.nom)
  const totalCA  = factures
    .filter(f => f.statut === 'payee')
    .reduce((s, f) => s + f.montant_ttc, 0)

  const addNote = () => {
    if (!newNote.trim()) return
    const now = new Date()
    const dateStr = now.toLocaleDateString('fr-FR') + ' ' + now.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
    setNotes(p => [{
      id:         Date.now().toString(),
      created_at: now.toISOString(),
      tag:        noteTag,
      text:       newNote.trim(),
    }, ...p])
    setNewNote('')
    toast.success('Note ajoutée')
  }

  const addTask = () => {
    if (!newTask.trim()) return
    setTasks(p => [{ id: Date.now().toString(), titre: newTask.trim(), done: false }, ...p])
    setNewTask('')
  }

  const handleDelete = () => {
    deleteClient.mutate(client.id, {
      onSuccess: () => { navigate('/clients'); toast.success('Client supprimé') },
    })
  }

  return (
    <div className="space-y-5 animate-fade-in">

      {/* ── Top bar ── */}
      <div className="flex items-center gap-3">
        <button
          onClick={() => navigate('/clients')}
          className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
        >
          <ArrowLeft className="w-4 h-4" />
          Clients
        </button>
        <span className="text-muted-foreground">/</span>
        <span className="text-sm font-medium text-foreground">{client.nom}</span>
      </div>

      {/* ── Hero header ── */}
      <div className="card p-5">
        <div className="flex items-start gap-4">
          {/* Avatar */}
          <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-[#378ADD]/40 to-[#3a526b]/60 border border-[#378ADD]/30 flex items-center justify-center flex-shrink-0 shadow-lg">
            <span className="text-[#378ADD] font-bold text-xl">{initials}</span>
          </div>

          <div className="flex-1 min-w-0">
            <h1 className="text-xl font-bold text-foreground leading-tight">{client.nom}</h1>
            {client.entreprise && (
              <p className="text-sm text-muted-foreground flex items-center gap-1.5 mt-0.5">
                <Building2 className="w-3.5 h-3.5" />{client.entreprise}
              </p>
            )}
            <div className="flex flex-wrap gap-3 mt-3">
              {client.telephone && (
                <a href={`tel:${client.telephone}`}
                   className="flex items-center gap-1.5 text-xs text-muted-foreground hover:text-foreground transition-colors">
                  <Phone className="w-3.5 h-3.5 text-emerald-400" />{client.telephone}
                </a>
              )}
              {client.email && (
                <a href={`mailto:${client.email}`}
                   className="flex items-center gap-1.5 text-xs text-muted-foreground hover:text-foreground transition-colors">
                  <Mail className="w-3.5 h-3.5 text-blue-400" />{client.email}
                </a>
              )}
              {client.ville && (
                <span className="flex items-center gap-1.5 text-xs text-muted-foreground">
                  <MapPin className="w-3.5 h-3.5" />{[client.ville, client.pays].filter(Boolean).join(', ')}
                </span>
              )}
            </div>
          </div>

          {/* KPIs */}
          <div className="hidden sm:flex items-center gap-4 text-center">
            <div>
              <p className="text-lg font-bold text-foreground">{factures.length}</p>
              <p className="text-[11px] text-muted-foreground">Factures</p>
            </div>
            <div className="w-px h-8 bg-border" />
            <div>
              <p className="text-lg font-bold text-emerald-400">{formatCurrency(totalCA)}</p>
              <p className="text-[11px] text-muted-foreground">CA payé</p>
            </div>
            <div className="w-px h-8 bg-border" />
            <div>
              <p className="text-lg font-bold text-foreground">{devis.length}</p>
              <p className="text-[11px] text-muted-foreground">Devis</p>
            </div>
          </div>

          {/* Actions */}
          <div className="flex gap-2 flex-shrink-0">
            <Button variant="secondary" size="sm" onClick={() => setEditOpen(true)}>
              <Edit2 className="w-3.5 h-3.5" /> Modifier
            </Button>
            <Button
              size="sm"
              className="bg-red-500/10 text-red-400 hover:bg-red-500/20 border-0"
              variant="ghost"
              onClick={() => setDelConfirm(true)}
            >
              <Trash2 className="w-3.5 h-3.5" /> Supprimer
            </Button>
          </div>
        </div>
      </div>

      {/* ── Two-column layout ── */}
      <div className="grid grid-cols-1 lg:grid-cols-[1fr_300px] gap-5 items-start">

        {/* ── LEFT: activity sections ── */}
        <div className="space-y-3">

          {/* Tâches */}
          <Section
            title="Tâches"
            icon={CheckSquare}
            count={tasks.length}
            action={{ label: 'Ajouter', onClick: () => {} }}
          >
            {/* Quick add */}
            <div className="flex gap-2 mb-3">
              <Input
                value={newTask}
                onChange={e => setNewTask(e.target.value)}
                onKeyDown={e => e.key === 'Enter' && addTask()}
                placeholder="Nouvelle tâche..."
                className="h-8 text-sm"
              />
              <Button size="sm" className="h-8 px-3" onClick={addTask} disabled={!newTask.trim()}>
                <Plus className="w-3.5 h-3.5" />
              </Button>
            </div>
            {tasks.length === 0
              ? <EmptyState label="Aucune tâche" />
              : tasks.map(t => (
                  <div key={t.id} className="flex items-center gap-2 py-1.5">
                    <button onClick={() => setTasks(p => p.map(x => x.id === t.id ? { ...x, done: !x.done } : x))}>
                      {t.done
                        ? <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                        : <Circle       className="w-4 h-4 text-muted-foreground" />
                      }
                    </button>
                    <span className={`text-sm flex-1 ${t.done ? 'line-through text-muted-foreground' : 'text-foreground'}`}>
                      {t.titre}
                    </span>
                    <button onClick={() => setTasks(p => p.filter(x => x.id !== t.id))}>
                      <Trash2 className="w-3.5 h-3.5 text-muted-foreground hover:text-red-400 transition-colors" />
                    </button>
                  </div>
                ))
            }
          </Section>

          {/* Journal d'activité */}
          <Section title="Journal d'activité" icon={Clock}>
            <EmptyState label="Aucune activité enregistrée" />
          </Section>

          {/* Historique / Notes */}
          <Section
            title="Historique"
            icon={FileText}
            count={notes.length}
            action={{ label: 'Ajouter une note', onClick: () => {} }}
            accent="#8B5CF6"
          >
            {/* Add note form */}
            <div className="space-y-2 mb-3">
              <div className="flex gap-2">
                <Input
                  value={noteTag}
                  onChange={e => setNoteTag(e.target.value)}
                  placeholder="Tag (ex : CRM)"
                  className="h-8 text-sm w-28 flex-shrink-0"
                />
                <Input
                  value={newNote}
                  onChange={e => setNewNote(e.target.value)}
                  onKeyDown={e => e.key === 'Enter' && addNote()}
                  placeholder="Ajouter une note..."
                  className="h-8 text-sm flex-1"
                />
                <Button size="sm" className="h-8 px-3 bg-violet-500/20 text-violet-400 hover:bg-violet-500/30 border-0" onClick={addNote} disabled={!newNote.trim()}>
                  <Plus className="w-3.5 h-3.5" />
                </Button>
              </div>
            </div>
            {notes.length === 0
              ? <EmptyState label="Aucun historique" />
              : notes.map(n => (
                  <div key={n.id} className="flex items-start gap-2 py-2 border-b border-border last:border-0">
                    <div className="w-1.5 h-1.5 rounded-full bg-violet-400 mt-1.5 flex-shrink-0" />
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-0.5">
                        <span className="text-[10px] text-muted-foreground">
                          [{new Date(n.created_at).toLocaleDateString('fr-FR')} {new Date(n.created_at).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })}]
                        </span>
                        <span className="text-[10px] font-semibold text-violet-400 uppercase tracking-wide">{n.tag}</span>
                      </div>
                      <p className="text-sm text-foreground">{n.text}</p>
                    </div>
                    <button onClick={() => setNotes(p => p.filter(x => x.id !== n.id))}>
                      <Trash2 className="w-3.5 h-3.5 text-muted-foreground hover:text-red-400 transition-colors" />
                    </button>
                  </div>
                ))
            }
          </Section>

          {/* Devis */}
          <Section
            title="Devis"
            icon={FileCheck}
            count={devis.length}
            action={{ label: 'Nouveau devis', onClick: () => navigate('/devis') }}
            accent="#8B5CF6"
          >
            {devis.length === 0
              ? <EmptyState label="Aucun devis" />
              : devis.map(d => {
                  const s = DEVIS_STATUT[d.statut]
                  return (
                    <div key={d.id} className="flex items-center justify-between py-2 border-b border-border last:border-0">
                      <div>
                        <p className="text-sm font-medium text-foreground">{d.numero}</p>
                        <p className="text-xs text-muted-foreground">{formatDate(d.date_emission)}</p>
                      </div>
                      <div className="flex items-center gap-3">
                        <span className={`text-xs font-medium ${s?.color}`}>{s?.label}</span>
                        <span className="text-sm font-semibold text-foreground">{formatCurrency(d.montant_ttc)}</span>
                      </div>
                    </div>
                  )
                })
            }
          </Section>

          {/* Factures */}
          <Section
            title="Factures"
            icon={Receipt}
            count={factures.length}
            action={{ label: 'Nouvelle facture', onClick: () => navigate('/factures') }}
            accent="#3B82F6"
          >
            {factures.length === 0
              ? <EmptyState label="Aucune facture" />
              : factures.map(f => {
                  const s = FACTURE_STATUT[f.statut]
                  return (
                    <div key={f.id} className="flex items-center justify-between py-2 border-b border-border last:border-0">
                      <div>
                        <p className="text-sm font-medium text-foreground">{f.numero}</p>
                        <p className="text-xs text-muted-foreground">{formatDate(f.date_emission)}</p>
                      </div>
                      <div className="flex items-center gap-3">
                        <span className={`text-xs font-medium ${s?.color}`}>{s?.label}</span>
                        <span className="text-sm font-semibold text-foreground">{formatCurrency(f.montant_ttc)}</span>
                      </div>
                    </div>
                  )
                })
            }
          </Section>

          {/* Paiements */}
          <Section
            title="💰 Paiements"
            icon={DollarSign}
            count={0}
            action={{ label: 'Nouveau paiement', onClick: () => navigate('/paiements') }}
            accent="#10B981"
          >
            <EmptyState label="Aucun paiement" />
          </Section>

          {/* Chèques */}
          <Section
            title="Chèques"
            icon={CreditCard}
            count={0}
            action={{ label: 'Nouveau chèque', onClick: () => navigate('/cheques-recus') }}
          >
            <EmptyState label="Aucun chèque" />
          </Section>

          {/* Contrats */}
          <Section
            title="Contrats"
            icon={FileText}
            count={0}
            action={{ label: 'Nouveau contrat', onClick: () => navigate('/contrats') }}
            accent="#F59E0B"
          >
            <EmptyState label="Aucun contrat" />
          </Section>

          {/* Reçus */}
          <Section
            title="Reçus"
            icon={Package}
            count={0}
            action={{ label: 'Nouveau reçu', onClick: () => {} }}
          >
            <EmptyState label="Aucun reçu" />
          </Section>

          {/* Documents */}
          <Section
            title="Documents"
            icon={Upload}
            count={0}
            action={{ label: 'Uploader', onClick: () => {} }}
          >
            <div className="flex flex-col items-center py-4 gap-2">
              <Upload className="w-8 h-8 text-muted-foreground opacity-30" />
              <p className="text-sm text-muted-foreground">Aucun document</p>
              <button className="text-xs text-[#378ADD] hover:underline">Glisser-déposer ou cliquer pour uploader</button>
            </div>
          </Section>
        </div>

        {/* ── RIGHT: info sidebar ── */}
        <div className="space-y-3 lg:sticky lg:top-4">

          {/* Info card */}
          <div className="card p-4 space-y-3">
            <p className="text-xs font-bold text-muted-foreground uppercase tracking-widest">Informations</p>

            <div className="space-y-2.5">
              {client.telephone && (
                <div className="flex items-center gap-2.5">
                  <Phone className="w-3.5 h-3.5 text-emerald-400 flex-shrink-0" />
                  <a href={`tel:${client.telephone}`} className="text-sm text-foreground hover:text-emerald-400 transition-colors">
                    {client.telephone}
                  </a>
                </div>
              )}
              {client.email && (
                <div className="flex items-center gap-2.5">
                  <Mail className="w-3.5 h-3.5 text-blue-400 flex-shrink-0" />
                  <a href={`mailto:${client.email}`} className="text-sm text-foreground hover:text-blue-400 transition-colors truncate">
                    {client.email}
                  </a>
                </div>
              )}
              {client.adresse && (
                <div className="flex items-start gap-2.5">
                  <MapPin className="w-3.5 h-3.5 text-muted-foreground flex-shrink-0 mt-0.5" />
                  <span className="text-sm text-muted-foreground leading-snug">
                    {[client.adresse, client.ville, client.pays].filter(Boolean).join(', ')}
                  </span>
                </div>
              )}
              <div className="flex items-center gap-2.5">
                <Calendar className="w-3.5 h-3.5 text-muted-foreground flex-shrink-0" />
                <span className="text-sm text-muted-foreground">Client depuis {formatDate(client.created_at)}</span>
              </div>
            </div>

            {/* Notes */}
            {notes.length > 0 && (
              <div className="pt-2 border-t border-border space-y-2">
                <p className="text-xs font-semibold text-muted-foreground">Notes</p>
                {notes.slice(0, 3).map(n => (
                  <div key={n.id} className="text-xs text-muted-foreground leading-relaxed">
                    <span className="text-[10px] text-violet-400 font-medium">
                      [{new Date(n.created_at).toLocaleDateString('fr-FR')} {new Date(n.created_at).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })}] {n.tag}
                    </span>
                    <br />
                    {n.text}
                  </div>
                ))}
              </div>
            )}

            <div className="flex gap-2 pt-1">
              <Button variant="secondary" size="sm" className="flex-1 h-7 text-xs" onClick={() => setEditOpen(true)}>
                <Edit2 className="w-3 h-3" /> Modifier
              </Button>
              <Button
                variant="ghost"
                size="sm"
                className="flex-1 h-7 text-xs text-red-400 hover:bg-red-500/10"
                onClick={() => setDelConfirm(true)}
              >
                <Trash2 className="w-3 h-3" /> Supprimer
              </Button>
            </div>
          </div>

          {/* Stats card */}
          <div className="card p-4 space-y-3">
            <p className="text-xs font-bold text-muted-foreground uppercase tracking-widest">Statistiques</p>
            {[
              { label: 'Devis créés',      value: devis.length,    color: 'text-violet-400' },
              { label: 'Factures',         value: factures.length, color: 'text-blue-400'   },
              { label: 'CA payé',          value: formatCurrency(totalCA), color: 'text-emerald-400' },
              { label: 'En attente',       value: formatCurrency(
                factures.filter(f => ['envoyee','impayee','partielle'].includes(f.statut))
                        .reduce((s,f) => s + f.montant_ttc - f.montant_paye, 0)
              ), color: 'text-amber-400' },
            ].map(k => (
              <div key={k.label} className="flex items-center justify-between">
                <span className="text-xs text-muted-foreground">{k.label}</span>
                <span className={`text-sm font-bold ${k.color}`}>{k.value}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* ── Edit dialog ── */}
      <Dialog open={editOpen} onOpenChange={setEditOpen}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>Modifier {client.nom}</DialogTitle>
          </DialogHeader>
          <ClientEditForm client={client} onClose={() => setEditOpen(false)} />
        </DialogContent>
      </Dialog>

      {/* ── Delete confirm ── */}
      <Dialog open={delConfirm} onOpenChange={setDelConfirm}>
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2 text-red-400">
              <AlertTriangle className="w-5 h-5" /> Supprimer ce client ?
            </DialogTitle>
          </DialogHeader>
          <p className="text-sm text-muted-foreground py-2">
            Cette action est irréversible. Toutes les données liées à <strong className="text-foreground">{client.nom}</strong> seront perdues.
          </p>
          <div className="flex justify-end gap-3">
            <Button variant="secondary" size="sm" onClick={() => setDelConfirm(false)}>Annuler</Button>
            <Button
              size="sm"
              className="bg-red-500 hover:bg-red-600 text-white border-0"
              onClick={handleDelete}
              disabled={deleteClient.isPending}
            >
              {deleteClient.isPending ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Trash2 className="w-3.5 h-3.5" />}
              Supprimer définitivement
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
