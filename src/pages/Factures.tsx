import { useState, useMemo } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Plus, Search, Download, Receipt, Loader2, Edit2, Trash2, CheckCircle,
  Eye, MoreHorizontal, Copy, Send, AlertTriangle, Clock, X,
  CreditCard, Calendar, FileText, MailOpen,
} from 'lucide-react'
import {
  useFactures, useCreateFacture, useUpdateFacture, useDeleteFacture,
  useMarkFacturePaid, useMarkFactureEnvoyee, useDuplicateFacture,
  computeAutoStatut,
  type Facture, type FactureStatut,
} from '@/hooks/useFactures'
import { useClients }     from '@/hooks/useClients'
import { useStockProducts, useCreateStockMovement } from '@/hooks/useStock'
import { Button }         from '@/components/ui/button'
import { Input }          from '@/components/ui/input'
import { Badge }          from '@/components/ui/badge'
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from '@/components/ui/select'
import {
  Dialog, DialogContent, DialogHeader, DialogTitle,
} from '@/components/ui/dialog'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem,
  DropdownMenuSeparator, DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { formatCurrency, formatCurrencyCompact, formatDate, useIsMobileViewport } from '@/lib/utils'
import { generateFacturePDF } from '@/lib/generatePdf'
import { ImportExportButtons } from '@/components/ImportExportButtons'
import { facturesSchema } from '@/lib/importExportSchemas'
import {
  DateRangeFilter, DEFAULT_RANGE, makeDatePredicate, type DateRange,
} from '@/components/ui/DateRangeFilter'

/* ─── Status config ──────────────────────────────────────────────── */
type BadgeVariant = 'success' | 'warning' | 'destructive' | 'default' | 'secondary' | 'outline'

const STATUT_CONFIG: Record<FactureStatut, { label: string; variant: BadgeVariant }> = {
  brouillon: { label: 'Brouillon',  variant: 'secondary'   },
  envoyee:   { label: 'Envoyée',    variant: 'default'     },
  impayee:   { label: 'Impayée',    variant: 'destructive' },
  partielle: { label: 'Partielle',  variant: 'warning'     },
  payee:     { label: 'Payée',      variant: 'success'     },
  annulee:   { label: 'Annulée',    variant: 'secondary'   },
  refusee:   { label: 'Refusée',    variant: 'destructive' },
}

/* ─── Helpers ────────────────────────────────────────────────────── */
const fmtCur = (v: number) => (v === 0 ? '—' : formatCurrency(v))
const fmtCurCompact = (v: number) => (v === 0 ? '—' : formatCurrencyCompact(v))

function paymentPercent(f: Facture): number {
  if (!f.montant_ttc || f.montant_ttc === 0) return 0
  return Math.min(100, Math.round((f.montant_paye / f.montant_ttc) * 100))
}

/* ─── EcheanceCell ───────────────────────────────────────────────── */
function EcheanceCell({ date, statut }: { date: string | null | undefined; statut: string }) {
  if (!date) return <span className="text-muted-foreground">—</span>
  const diff    = Math.floor((new Date(date).getTime() - Date.now()) / 86_400_000)
  const settled = statut === 'payee' || statut === 'annulee' || statut === 'refusee'
  if (settled)  return <span className="text-muted-foreground text-sm">{formatDate(date)}</span>
  if (diff < 0) return (
    <span className="flex items-center gap-1 text-[#E24B4A] font-medium text-sm">
      <AlertTriangle className="w-3 h-3 shrink-0" />{formatDate(date)}
    </span>
  )
  if (diff <= 7) return (
    <span className="flex items-center gap-1 font-medium text-sm text-[#BA7517] dark:text-amber-400">
      <Clock className="w-3 h-3 shrink-0" />{formatDate(date)}
    </span>
  )
  return <span className="text-muted-foreground text-sm">{formatDate(date)}</span>
}

/* ─── SkeletonRows ───────────────────────────────────────────────── */
function SkeletonRows() {
  return (
    <>
      {Array.from({ length: 5 }).map((_, i) => (
        <tr key={i} className="table-row">
          {[70, 120, 80, 80, 90, 70, 60, 40].map((w, j) => (
            <td key={j}><div className="skeleton h-4 rounded" style={{ width: `${w}%` }} /></td>
          ))}
        </tr>
      ))}
    </>
  )
}

/* ─── DeleteConfirmDialog ────────────────────────────────────────── */
function DeleteConfirmDialog({
  facture, open, onConfirm, onCancel, loading,
}: {
  facture: Facture | null
  open: boolean
  onConfirm: () => void
  onCancel: () => void
  loading: boolean
}) {
  return (
    <Dialog open={open} onOpenChange={v => !v && onCancel()}>
      <DialogContent className="max-w-sm">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2 text-[#A32D2D] dark:text-red-400">
            <Trash2 className="w-5 h-5" /> Supprimer la facture
          </DialogTitle>
        </DialogHeader>
        <div className="py-2 space-y-3">
          <p className="text-sm text-foreground">
            Vous êtes sur le point de supprimer{' '}
            <span className="font-semibold font-mono">{facture?.numero}</span>.
            Cette action est <span className="font-semibold">irréversible</span>.
          </p>
          {facture?.statut === 'payee' && (
            <div className="flex items-start gap-2 p-3 rounded-lg bg-amber-50 border border-amber-200 dark:bg-amber-950/30 dark:border-amber-800/50">
              <AlertTriangle className="w-4 h-4 text-amber-600 shrink-0 mt-0.5" />
              <p className="text-xs text-amber-700 dark:text-amber-400">
                Cette facture est marquée comme payée. Êtes-vous sûr de vouloir la supprimer ?
              </p>
            </div>
          )}
        </div>
        <div className="flex items-center justify-end gap-3 pt-1">
          <Button variant="secondary" onClick={onCancel} disabled={loading}>Annuler</Button>
          <Button
            variant="destructive"
            onClick={onConfirm}
            disabled={loading}
            className="bg-[#A32D2D] hover:bg-[#8a2424] text-white border-0"
          >
            {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Trash2 className="w-4 h-4" />}
            Supprimer définitivement
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  )
}

/* ─── SendEmailDialog ────────────────────────────────────────────── */
function SendEmailDialog({
  facture, open, onClose, onMarkSent,
}: {
  facture: Facture | null
  open: boolean
  onClose: () => void
  onMarkSent: () => void
}) {
  const [emailTo, setEmailTo] = useState(facture?.client_email || '')
  const subject = `Facture ${facture?.numero} — GestiQ`
  const body = [
    `Bonjour,`,
    ``,
    `Veuillez trouver ci-joint la facture ${facture?.numero} d'un montant de ${facture ? formatCurrency(facture.montant_ttc) : ''}.`,
    ``,
    facture?.date_echeance ? `Date d'échéance : ${formatDate(facture.date_echeance)}` : '',
    ``,
    `N'hésitez pas à nous contacter pour toute question.`,
    ``,
    `Cordialement,`,
    `GestiQ`,
  ].join('\n').trim()

  const handleOpenMailto = () => {
    const mailto = `mailto:${emailTo}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`
    window.open(mailto, '_blank')
    onMarkSent()
    onClose()
  }

  // Reset email when facture changes
  const email = facture?.client_email || emailTo

  return (
    <Dialog open={open} onOpenChange={v => !v && onClose()}>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <MailOpen className="w-5 h-5 text-blue-600 dark:text-blue-400" /> Envoyer par email
          </DialogTitle>
        </DialogHeader>
        <div className="space-y-4 py-1">
          <div className="p-3 rounded-lg bg-muted flex items-center justify-between">
            <div>
              <p className="text-xs text-muted-foreground">Facture</p>
              <p className="text-sm font-semibold font-mono">{facture?.numero}</p>
            </div>
            <div className="text-right">
              <p className="text-xs text-muted-foreground">Montant TTC</p>
              <p className="text-sm font-bold">{facture ? fmtCur(facture.montant_ttc) : ''}</p>
            </div>
          </div>
          <div className="space-y-1.5">
            <label className="form-label">Adresse email du destinataire</label>
            <Input
              type="email"
              placeholder="client@exemple.com"
              value={email}
              onChange={e => setEmailTo(e.target.value)}
            />
          </div>
          <div className="space-y-1.5">
            <label className="form-label">Objet</label>
            <Input value={subject} readOnly className="opacity-70 cursor-default" />
          </div>
          <p className="text-xs text-muted-foreground leading-relaxed">
            Votre messagerie par défaut s'ouvrira avec ce message pré-rempli.
            Téléchargez le PDF et joignez-le avant l'envoi.
          </p>
        </div>
        <div className="flex items-center justify-between pt-1">
          <Button variant="secondary" size="sm" onClick={() => { generateFacturePDF(facture!); }}>
            <Download className="w-4 h-4" /> Télécharger PDF
          </Button>
          <div className="flex items-center gap-2">
            <Button variant="secondary" onClick={onClose}>Annuler</Button>
            <Button onClick={handleOpenMailto} disabled={!email}>
              <Send className="w-4 h-4" /> Ouvrir dans ma messagerie
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}

/* ─── FactureDetailModal ─────────────────────────────────────────── */
function FactureDetailModal({
  facture, open, onClose, onEdit, onMarkPaid,
}: {
  facture: Facture | null
  open: boolean
  onClose: () => void
  onEdit: () => void
  onMarkPaid: () => void
}) {
  if (!facture) return null
  const pct     = paymentPercent(facture)
  const reste   = facture.montant_ttc - facture.montant_paye
  const cfg     = STATUT_CONFIG[facture.statut]
  const canPay  = !['payee', 'annulee', 'refusee'].includes(facture.statut)

  return (
    <Dialog open={open} onOpenChange={v => !v && onClose()}>
      <DialogContent className="max-w-2xl">
        {/* Header */}
        <DialogHeader>
          <div className="flex items-start justify-between gap-4">
            <div>
              <p className="text-xs text-muted-foreground uppercase tracking-wider mb-1">Facture</p>
              <DialogTitle className="text-2xl font-mono">{facture.numero}</DialogTitle>
            </div>
            <Badge variant={cfg.variant} className="text-sm px-3 py-1 mt-1">{cfg.label}</Badge>
          </div>
        </DialogHeader>

        {/* Body */}
        <div className="space-y-5 py-1">
          {/* Client + Dates row */}
          <div className="grid grid-cols-2 gap-4">
            <div className="p-4 rounded-xl bg-muted space-y-1">
              <p className="text-xs text-muted-foreground uppercase tracking-wider">Client</p>
              <p className="font-semibold text-foreground">{facture.client_nom || '—'}</p>
              {facture.client_email && (
                <p className="text-xs text-muted-foreground">{facture.client_email}</p>
              )}
            </div>
            <div className="p-4 rounded-xl bg-muted space-y-2">
              <div className="flex items-center gap-2">
                <Calendar className="w-3.5 h-3.5 text-muted-foreground" />
                <span className="text-xs text-muted-foreground">Émission</span>
                <span className="text-sm font-medium ml-auto">{formatDate(facture.date_emission)}</span>
              </div>
              <div className="flex items-center gap-2">
                <Clock className="w-3.5 h-3.5 text-muted-foreground" />
                <span className="text-xs text-muted-foreground">Échéance</span>
                <span className="ml-auto">
                  <EcheanceCell date={facture.date_echeance} statut={facture.statut} />
                </span>
              </div>
            </div>
          </div>

          {/* Amounts */}
          <div className="rounded-xl border border-border overflow-hidden">
            <div className="grid grid-cols-3 divide-x divide-border">
              <div className="p-4 text-center">
                <p className="text-xs text-muted-foreground mb-1">Montant HT</p>
                <p className="text-base font-semibold text-foreground">{fmtCur(facture.montant_ht)}</p>
              </div>
              <div className="p-4 text-center">
                <p className="text-xs text-muted-foreground mb-1">TVA ({facture.tva}%)</p>
                <p className="text-base font-semibold text-foreground">
                  {fmtCur(facture.montant_ttc - facture.montant_ht)}
                </p>
              </div>
              <div className="p-4 text-center bg-[var(--surface-card)]">
                <p className="text-xs text-muted-foreground mb-1">Total TTC</p>
                <p className="text-xl font-bold text-foreground">{fmtCur(facture.montant_ttc)}</p>
              </div>
            </div>

            {/* Payment progress */}
            <div className="px-4 py-3 border-t border-border bg-muted/40">
              <div className="flex items-center justify-between mb-2 text-xs">
                <span className="text-muted-foreground">
                  Payé : <span className="font-medium text-foreground">{fmtCur(facture.montant_paye)}</span>
                </span>
                <span className="text-muted-foreground">
                  {facture.statut === 'payee'
                    ? <span className="text-[#27500A] dark:text-emerald-400 font-medium">✓ Soldé</span>
                    : <>Reste : <span className="font-medium text-[#A32D2D] dark:text-red-400">{fmtCur(reste)}</span></>
                  }
                </span>
              </div>
              <div className="h-2 rounded-full bg-border overflow-hidden">
                <motion.div
                  initial={{ width: 0 }}
                  animate={{ width: `${pct}%` }}
                  transition={{ duration: 0.6, ease: 'easeOut' }}
                  className={`h-full rounded-full ${
                    pct >= 100 ? 'bg-[#639922]' :
                    pct > 0    ? 'bg-amber-500'  : 'bg-[#E24B4A]'
                  }`}
                />
              </div>
              {pct > 0 && pct < 100 && (
                <p className="text-xs text-muted-foreground mt-1 text-right">{pct}% payé</p>
              )}
            </div>
          </div>

          {/* Notes */}
          {facture.notes && (
            <div className="p-4 rounded-xl bg-muted border border-border">
              <p className="text-xs text-muted-foreground uppercase tracking-wider mb-2 flex items-center gap-1.5">
                <FileText className="w-3.5 h-3.5" /> Notes
              </p>
              <p className="text-sm text-foreground leading-relaxed">{facture.notes}</p>
            </div>
          )}
        </div>

        {/* Footer actions */}
        <div className="flex items-center justify-between pt-2 border-t border-border">
          <Button variant="secondary" size="sm" onClick={() => generateFacturePDF(facture)}>
            <Download className="w-4 h-4" /> Télécharger PDF
          </Button>
          <div className="flex items-center gap-2">
            <Button variant="secondary" onClick={onClose}>Fermer</Button>
            <Button variant="secondary" onClick={onEdit}>
              <Edit2 className="w-4 h-4" /> Modifier
            </Button>
            {canPay && (
              <Button onClick={onMarkPaid}>
                <CheckCircle className="w-4 h-4" /> Marquer payée
              </Button>
            )}
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}

/* ─── FactureForm ────────────────────────────────────────────────── */
function FactureForm({ facture, onClose }: { facture?: Facture; onClose: () => void }) {
  const create = useCreateFacture()
  const update = useUpdateFacture()
  const { data: clients = [] } = useClients()
  const { data: stockProducts = [] } = useStockProducts('')
  const createMovement = useCreateStockMovement()

  /* Optional stock-product link — off by default, only for new factures */
  const [stockLink, setStockLink] = useState<{ product_id: string; quantite: number }>({
    product_id: '',
    quantite:   1,
  })

  const [form, setForm] = useState<{
    numero:        string
    client_id:     string
    statut:        FactureStatut
    date_emission: string
    date_echeance: string
    montant_ht:    number
    tva:           number
    montant_ttc:   number
    montant_paye:  number
    notes:         string
  }>({
    numero:        facture?.numero        || `FAC-${new Date().getFullYear()}-${String(Date.now()).slice(-3)}`,
    client_id:     facture?.client_id     || '',
    statut:        facture?.statut        || 'brouillon',
    date_emission: facture?.date_emission || new Date().toISOString().slice(0, 10),
    date_echeance: facture?.date_echeance || '',
    montant_ht:    facture?.montant_ht    || 0,
    tva:           facture?.tva           || 20,
    montant_ttc:   facture?.montant_ttc   || 0,
    montant_paye:  facture?.montant_paye  || 0,
    notes:         facture?.notes         || '',
  })

  const setHT = (ht: number) => {
    const ttc = ht * (1 + form.tva / 100)
    const newStatut = computeAutoStatut(form.montant_paye, ttc, form.statut)
    setForm(p => ({ ...p, montant_ht: ht, montant_ttc: ttc, statut: newStatut }))
  }

  const setTVA = (tva: number) => {
    const ttc = form.montant_ht * (1 + tva / 100)
    const newStatut = computeAutoStatut(form.montant_paye, ttc, form.statut)
    setForm(p => ({ ...p, tva, montant_ttc: ttc, statut: newStatut }))
  }

  const setPaye = (paye: number) => {
    const newStatut = computeAutoStatut(paye, form.montant_ttc, form.statut)
    setForm(p => ({ ...p, montant_paye: paye, statut: newStatut }))
  }

  /* When a stock product is selected, prefill HT (= prix_vente × qty) + TVA */
  const applyStockProduct = (productId: string, qty: number) => {
    setStockLink({ product_id: productId, quantite: qty })
    if (!productId) return
    const p = stockProducts.find(sp => sp.id === productId)
    if (!p) return
    const ht  = Number(p.prix_vente) * Math.max(0, qty)
    const tva = Number(p.tva)
    const ttc = ht * (1 + tva / 100)
    const newStatut = computeAutoStatut(form.montant_paye, ttc, form.statut)
    setForm(prev => ({ ...prev, montant_ht: ht, tva, montant_ttc: ttc, statut: newStatut }))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    const payload = {
      ...form,
      date_echeance: form.date_echeance || null,
      notes:         form.notes         || null,
      client_id:     form.client_id     || null,
    }
    let created: Facture | null = null
    if (facture) {
      await update.mutateAsync({ id: facture.id, ...payload })
    } else {
      created = (await create.mutateAsync(payload as any)) as unknown as Facture
    }

    /* Optional stock decrement — only on NEW factures with a linked product */
    if (!facture && created?.id && stockLink.product_id && stockLink.quantite > 0) {
      try {
        await createMovement.mutateAsync({
          product_id: stockLink.product_id,
          type:       'sortie',
          quantite:   stockLink.quantite,
          reference:  form.numero,
          note:       `Décrément auto — facture ${form.numero}`,
          source:     'facture',
          source_id:  created.id,
        })
      } catch {
        /* Silent — the facture itself is already saved. Toast shown by hook. */
      }
    }

    onClose()
  }

  const isPending = create.isPending || update.isPending

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-1.5">
          <label className="form-label">Numéro</label>
          <Input value={form.numero} onChange={e => setForm(p => ({ ...p, numero: e.target.value }))} required />
        </div>
        <div className="space-y-1.5">
          <label className="form-label">Client</label>
          <Select value={form.client_id} onValueChange={v => setForm(p => ({ ...p, client_id: v }))}>
            <SelectTrigger><SelectValue placeholder="Sélectionner un client…" /></SelectTrigger>
            <SelectContent>
              {clients.map(c => (
                <SelectItem key={c.id} value={c.id}>{c.nom}{c.entreprise ? ` — ${c.entreprise}` : ''}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="space-y-1.5">
          <label className="form-label">Date d'émission</label>
          <Input type="date" value={form.date_emission}
            onChange={e => setForm(p => ({ ...p, date_emission: e.target.value }))} required />
        </div>
        <div className="space-y-1.5">
          <label className="form-label">Date d'échéance</label>
          <Input type="date" value={form.date_echeance}
            onChange={e => setForm(p => ({ ...p, date_echeance: e.target.value }))} />
        </div>

        <div className="space-y-1.5">
          <label className="form-label">Montant HT (MAD)</label>
          <Input type="number" step="0.01" min="0" value={form.montant_ht}
            onChange={e => setHT(+e.target.value)} required />
        </div>
        <div className="space-y-1.5">
          <label className="form-label">TVA (%)</label>
          <Select value={String(form.tva)} onValueChange={v => setTVA(+v)}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent>
              {['0', '7', '10', '14', '20'].map(v => (
                <SelectItem key={v} value={v}>{v}%</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        <div className="space-y-1.5">
          <label className="form-label">Montant TTC (calculé)</label>
          <Input value={form.montant_ttc.toFixed(2)} readOnly
            className="bg-muted opacity-70 cursor-not-allowed" />
        </div>
        <div className="space-y-1.5">
          <label className="form-label">Montant payé (MAD)</label>
          <Input type="number" step="0.01" min="0" max={form.montant_ttc}
            value={form.montant_paye}
            onChange={e => setPaye(+e.target.value)} />
        </div>

        <div className="space-y-1.5 col-span-2">
          <label className="form-label">
            Statut
            <span className="ml-2 text-xs text-muted-foreground font-normal">
              (calculé automatiquement à partir du montant payé)
            </span>
          </label>
          <Select value={form.statut}
            onValueChange={v => setForm(p => ({ ...p, statut: v as FactureStatut }))}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent>
              {Object.entries(STATUT_CONFIG).map(([k, v]) => (
                <SelectItem key={k} value={k}>{v.label}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      {/* ── Optional stock product link — new factures only ── */}
      {!facture && stockProducts.length > 0 && (
        <div className="rounded-lg border border-dashed border-border bg-muted/30 p-3 space-y-2">
          <div className="flex items-center justify-between">
            <label className="form-label m-0">Produit du stock (optionnel)</label>
            <span className="text-[11px] text-muted-foreground italic">
              Auto-remplit le prix + décrémente le stock à la validation
            </span>
          </div>
          <div className="grid grid-cols-[1fr_auto] gap-2">
            <Select
              value={stockLink.product_id || 'none'}
              onValueChange={v => applyStockProduct(v === 'none' ? '' : v, stockLink.quantite)}
            >
              <SelectTrigger><SelectValue placeholder="— Aucun produit —" /></SelectTrigger>
              <SelectContent>
                <SelectItem value="none">— Aucun produit —</SelectItem>
                {stockProducts.map(p => (
                  <SelectItem key={p.id} value={p.id}>
                    {p.nom} — {p.sku} (stock : {p.stock_actuel})
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Input
              type="number"
              step="0.01"
              min="0"
              value={stockLink.quantite}
              onChange={e => applyStockProduct(stockLink.product_id, +e.target.value)}
              className="w-24"
              placeholder="Qté"
              disabled={!stockLink.product_id}
            />
          </div>
        </div>
      )}

      <div className="space-y-1.5">
        <label className="form-label">Notes</label>
        <textarea
          value={form.notes}
          onChange={e => setForm(p => ({ ...p, notes: e.target.value }))}
          rows={3}
          placeholder="Notes internes, conditions de paiement…"
          className="w-full rounded-lg border border-border bg-[var(--surface-input)] px-3 py-2 text-base sm:text-sm text-foreground placeholder:text-muted-foreground resize-none focus:outline-none focus:border-blue-600 focus:shadow-[0_0_0_3px_rgba(37,99,235,0.15)] transition-all"
        />
      </div>

      <div className="flex items-center justify-end gap-3 pt-2">
        <Button type="button" variant="secondary" onClick={onClose} disabled={isPending}>Annuler</Button>
        <Button type="submit" disabled={isPending}>
          {isPending && <Loader2 className="w-4 h-4 animate-spin" />}
          {facture ? 'Mettre à jour' : 'Créer la facture'}
        </Button>
      </div>
    </form>
  )
}

/* ─── Main Page ──────────────────────────────────────────────────── */
export default function Factures() {
  const isMobile         = useIsMobileViewport()
  const fmtKpi           = isMobile ? fmtCurCompact : fmtCur
  const { data: factures = [], isLoading } = useFactures()
  const createFacture    = useCreateFacture()
  const updateFacture    = useUpdateFacture()
  const deleteFacture    = useDeleteFacture()
  const markPaid         = useMarkFacturePaid()
  const markEnvoyee      = useMarkFactureEnvoyee()
  const duplicate        = useDuplicateFacture()

  const [search,       setSearch]      = useState('')
  const [filterStatut, setFilterStatut]= useState('all')
  const [dateRange,    setDateRange]   = useState<DateRange>(DEFAULT_RANGE)

  // Modal states
  const [showForm,     setShowForm]    = useState(false)
  const [editing,      setEditing]     = useState<Facture | undefined>()
  const [viewTarget,   setViewTarget]  = useState<Facture | null>(null)
  const [deleteTarget, setDeleteTarget]= useState<Facture | null>(null)
  const [emailTarget,  setEmailTarget] = useState<Facture | null>(null)

  /* ── Filtered list ─────────────────────────────────────────────── */
  const dateMatch = useMemo(() => makeDatePredicate(dateRange), [dateRange])
  const filtered = useMemo(() =>
    factures.filter(f => {
      const q = search.toLowerCase()
      const matchSearch = !search || [f.numero, f.client_nom].some(x => x?.toLowerCase().includes(q))
      const matchStatut = filterStatut === 'all' || f.statut === filterStatut
      const matchDate   = dateMatch(f.date_emission)
      return matchSearch && matchStatut && matchDate
    }),
    [factures, search, filterStatut, dateMatch]
  )

  /* ── KPI stats ─────────────────────────────────────────────────── */
  const stats = useMemo(() => ({
    totalTTC: factures.reduce((s, f) => s + f.montant_ttc, 0),
    encaisse: factures.filter(f => f.statut === 'payee').reduce((s, f) => s + f.montant_ttc, 0),
    impaye:   factures
      .filter(f => !['payee', 'annulee', 'brouillon', 'refusee'].includes(f.statut))
      .reduce((s, f) => s + Math.max(0, f.montant_ttc - f.montant_paye), 0),
    parStatut: Object.entries(STATUT_CONFIG).reduce((acc, [key]) => {
      acc[key as FactureStatut] = factures.filter(f => f.statut === key).length
      return acc
    }, {} as Record<FactureStatut, number>),
  }), [factures])

  /* ── Action handlers ───────────────────────────────────────────── */
  const openEdit = (f: Facture) => { setEditing(f); setViewTarget(null); setShowForm(true) }
  const openNew  = () => { setEditing(undefined); setShowForm(true) }

  const handleDeleteConfirm = async () => {
    if (!deleteTarget) return
    await deleteFacture.mutateAsync(deleteTarget.id)
    setDeleteTarget(null)
  }

  const handleMarkPaid = async (f: Facture) => {
    await markPaid.mutateAsync(f)
    setViewTarget(prev => prev?.id === f.id ? { ...prev, statut: 'payee', montant_paye: f.montant_ttc } : prev)
  }

  const handleMarkEnvoyee = async (f: Facture) => {
    await markEnvoyee.mutateAsync(f.id)
    setEmailTarget(f)
  }

  const handleDuplicate = (f: Facture) => {
    duplicate.mutate(f)
  }

  return (
    <div className="space-y-6 animate-fade-in">
      {/* ── Page header ─────────────────────────────────────────── */}
      <div className="page-header">
        <div>
          <h1 className="page-title">Factures</h1>
          <p className="text-sm mt-0.5 text-muted-foreground">
            {factures.length} facture{factures.length !== 1 ? 's' : ''}
            {' · '}
            <span className="text-[#27500A] dark:text-emerald-400 font-medium">{fmtCur(stats.encaisse)} encaissé</span>
            {stats.impaye > 0 && (
              <> · <span className="text-[#A32D2D] dark:text-red-400 font-medium">{fmtCur(stats.impaye)} impayé</span></>
            )}
          </p>
        </div>
        <div className="flex items-center gap-2">
          <ImportExportButtons
            schema={facturesSchema}
            data={factures}
            onImport={async (row) => { await createFacture.mutateAsync(row as any) }}
          />
          <Button size="sm" onClick={openNew}>
            <Plus className="w-4 h-4" /> Nouvelle facture
          </Button>
        </div>
      </div>

      {/* ── KPI cards ───────────────────────────────────────────── */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 sm:gap-4">
        <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0 }}
          className="card-premium p-5 flex items-center gap-4">
          <div className="w-11 h-11 rounded-xl bg-blue-50 dark:bg-blue-900/20 flex items-center justify-center flex-shrink-0">
            <Receipt className="w-5 h-5 text-blue-600 dark:text-blue-400" />
          </div>
          <div className="min-w-0">
            <p className="text-lg sm:text-xl font-extrabold text-foreground truncate">{fmtKpi(stats.totalTTC)}</p>
            <p className="kpi-label mt-0.5">Total facturé</p>
          </div>
        </motion.div>
        <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.06 }}
          className="card-premium p-5 flex items-center gap-4">
          <div className="w-11 h-11 rounded-xl bg-emerald-50 dark:bg-emerald-900/20 flex items-center justify-center flex-shrink-0">
            <CheckCircle className="w-5 h-5 text-emerald-600 dark:text-emerald-400" />
          </div>
          <div className="min-w-0">
            <p className="text-lg sm:text-xl font-extrabold text-emerald-600 dark:text-emerald-400 truncate">{fmtKpi(stats.encaisse)}</p>
            <p className="kpi-label mt-0.5">Encaissé</p>
          </div>
        </motion.div>
        <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.12 }}
          className="card-premium p-5 flex items-center gap-4">
          <div className={`w-11 h-11 rounded-xl flex items-center justify-center flex-shrink-0 ${stats.impaye > 0 ? 'bg-red-50 dark:bg-red-900/20' : 'bg-emerald-50 dark:bg-emerald-900/20'}`}>
            <Clock className={`w-5 h-5 ${stats.impaye > 0 ? 'text-red-600 dark:text-red-400' : 'text-emerald-600 dark:text-emerald-400'}`} />
          </div>
          <div className="min-w-0">
            <p className={`text-lg sm:text-xl font-extrabold truncate ${stats.impaye > 0 ? 'text-red-600 dark:text-red-400' : 'text-foreground'}`}>{fmtKpi(stats.impaye)}</p>
            <p className="kpi-label mt-0.5">En attente</p>
          </div>
        </motion.div>
      </div>

      {/* ── Date filter ──────────────────────────────────────────── */}
      <div className="card-premium p-3">
        <DateRangeFilter value={dateRange} onChange={setDateRange} />
      </div>

      {/* ── Statut breakdown pills ───────────────────────────────── */}
      <div className="flex items-center gap-2 flex-wrap">
        <button
          onClick={() => setFilterStatut('all')}
          className={`text-xs px-3 py-1.5 rounded-full border transition-all font-medium ${
            filterStatut === 'all'
              ? 'bg-blue-600 text-white border-blue-600'
              : 'border-border text-muted-foreground hover:border-blue-400'
          }`}
        >
          Toutes ({factures.length})
        </button>
        {(Object.entries(STATUT_CONFIG) as [FactureStatut, { label: string; variant: BadgeVariant }][]).map(([key, cfg]) => {
          const count = stats.parStatut[key]
          if (!count) return null
          return (
            <button
              key={key}
              onClick={() => setFilterStatut(filterStatut === key ? 'all' : key)}
              className={`text-xs px-3 py-1.5 rounded-full border transition-all font-medium ${
                filterStatut === key
                  ? 'bg-blue-600 text-white border-blue-600'
                  : 'border-border text-muted-foreground hover:border-blue-400'
              }`}
            >
              {cfg.label} ({count})
            </button>
          )
        })}
      </div>

      {/* ── Search ──────────────────────────────────────────────── */}
      <div className="flex items-center gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input
            placeholder="Rechercher par numéro, client…"
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="pl-9"
          />
        </div>
        <Select value={filterStatut} onValueChange={setFilterStatut}>
          <SelectTrigger className="w-40 flex-shrink-0">
            <SelectValue placeholder="Tous les statuts" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Tous les statuts</SelectItem>
            {Object.entries(STATUT_CONFIG).map(([k, v]) => (
              <SelectItem key={k} value={k}>{v.label}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {/* ── Table ───────────────────────────────────────────────── */}
      <div className="card-premium overflow-hidden">
        <div className="table-scroll">
          <table className="w-full">
            <thead className="table-header">
              <tr className="table-header">
                <th>N° Facture</th>
                <th>Client</th>
                <th>Émission</th>
                <th>Échéance</th>
                <th>Total TTC</th>
                <th>Paiement</th>
                <th>Statut</th>
                <th style={{ width: 116 }}></th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <SkeletonRows />
              ) : (
                <AnimatePresence>
                  {filtered.map(f => {
                    const pct = paymentPercent(f)
                    return (
                      <tr key={f.id} className="table-row group">
                        <td>
                          <button
                            onClick={() => setViewTarget(f)}
                            className="font-mono font-medium text-sm text-blue-600 dark:text-blue-400 hover:underline"
                          >
                            {f.numero}
                          </button>
                        </td>
                        <td className="text-foreground/80">{f.client_nom || '—'}</td>
                        <td className="text-muted-foreground text-sm">{formatDate(f.date_emission)}</td>
                        <td><EcheanceCell date={f.date_echeance} statut={f.statut} /></td>
                        <td className="font-semibold text-foreground">{fmtCur(f.montant_ttc)}</td>
                        <td>
                          <div className="space-y-1 min-w-[80px]">
                            <div className="flex items-center justify-between text-xs">
                              <span className="text-muted-foreground">{fmtCur(f.montant_paye)}</span>
                              {pct > 0 && pct < 100 && (
                                <span className="text-muted-foreground">{pct}%</span>
                              )}
                            </div>
                            {f.montant_ttc > 0 && (
                              <div className="h-1 rounded-full bg-border overflow-hidden">
                                <div
                                  className={`h-full rounded-full transition-all ${
                                    pct >= 100 ? 'bg-[#639922]' :
                                    pct > 0    ? 'bg-amber-400'  : 'bg-[#E24B4A]/40'
                                  }`}
                                  style={{ width: `${pct}%` }}
                                />
                              </div>
                            )}
                          </div>
                        </td>
                        <td>
                          <Badge variant={STATUT_CONFIG[f.statut]?.variant}>
                            {STATUT_CONFIG[f.statut]?.label}
                          </Badge>
                        </td>

                        {/* ── Row actions ── */}
                        <td>
                          <div className="flex items-center gap-0.5 opacity-0 group-hover:opacity-100 transition-opacity">
                            {/* View */}
                            <Button
                              variant="ghost" size="icon" className="h-7 w-7" title="Voir les détails"
                              onClick={() => setViewTarget(f)}
                            >
                              <Eye className="w-3.5 h-3.5" />
                            </Button>

                            {/* Edit */}
                            <Button
                              variant="ghost" size="icon" className="h-7 w-7" title="Modifier"
                              onClick={() => openEdit(f)}
                              disabled={['annulee', 'refusee'].includes(f.statut)}
                            >
                              <Edit2 className="w-3.5 h-3.5" />
                            </Button>

                            {/* More actions */}
                            <DropdownMenu>
                              <DropdownMenuTrigger asChild>
                                <Button variant="ghost" size="icon" className="h-7 w-7" title="Plus d'actions">
                                  <MoreHorizontal className="w-3.5 h-3.5" />
                                </Button>
                              </DropdownMenuTrigger>
                              <DropdownMenuContent align="end" className="w-52">

                                {/* Dupliquer */}
                                <DropdownMenuItem
                                  className="gap-2 text-sm cursor-pointer"
                                  onClick={() => handleDuplicate(f)}
                                  disabled={duplicate.isPending}
                                >
                                  {duplicate.isPending ? (
                                    <Loader2 className="w-3.5 h-3.5 animate-spin" />
                                  ) : (
                                    <Copy className="w-3.5 h-3.5" />
                                  )}
                                  Dupliquer
                                </DropdownMenuItem>

                                {/* Télécharger PDF */}
                                <DropdownMenuItem
                                  className="gap-2 text-sm cursor-pointer"
                                  onClick={() => generateFacturePDF(f)}
                                >
                                  <Download className="w-3.5 h-3.5" />
                                  Télécharger PDF
                                </DropdownMenuItem>

                                {/* Envoyer par email */}
                                <DropdownMenuItem
                                  className="gap-2 text-sm cursor-pointer"
                                  onClick={() => handleMarkEnvoyee(f)}
                                  disabled={['annulee', 'refusee', 'envoyee'].includes(f.statut)}
                                >
                                  <Send className="w-3.5 h-3.5" />
                                  Envoyer par email
                                  {f.statut === 'envoyee' && (
                                    <span className="ml-auto text-[10px] text-muted-foreground">déjà envoyée</span>
                                  )}
                                </DropdownMenuItem>

                                {/* Marquer payée */}
                                {!['payee', 'annulee', 'refusee', 'brouillon'].includes(f.statut) && (
                                  <DropdownMenuItem
                                    className="gap-2 text-sm cursor-pointer"
                                    onClick={() => handleMarkPaid(f)}
                                    disabled={markPaid.isPending}
                                  >
                                    {markPaid.isPending
                                      ? <Loader2 className="w-3.5 h-3.5 animate-spin" />
                                      : <CheckCircle className="w-3.5 h-3.5 text-[#639922]" />
                                    }
                                    <span className="text-[#27500A] dark:text-emerald-400">Marquer payée</span>
                                  </DropdownMenuItem>
                                )}

                                {/* Annuler */}
                                {!['payee', 'annulee', 'refusee'].includes(f.statut) && (
                                  <DropdownMenuItem
                                    className="gap-2 text-sm cursor-pointer text-muted-foreground"
                                    onClick={() => updateFacture.mutate({ id: f.id, statut: 'annulee' })}
                                  >
                                    <X className="w-3.5 h-3.5" />
                                    Annuler la facture
                                  </DropdownMenuItem>
                                )}

                                <DropdownMenuSeparator />

                                {/* Supprimer */}
                                <DropdownMenuItem
                                  className="gap-2 text-sm cursor-pointer text-[#A32D2D] dark:text-red-400 focus:text-[#A32D2D] focus:bg-[#FCEBEB] dark:focus:bg-red-950/50"
                                  onClick={() => setDeleteTarget(f)}
                                >
                                  <Trash2 className="w-3.5 h-3.5" /> Supprimer
                                </DropdownMenuItem>
                              </DropdownMenuContent>
                            </DropdownMenu>
                          </div>
                        </td>
                      </tr>
                    )
                  })}
                </AnimatePresence>
              )}
            </tbody>
          </table>
        </div>

        {/* Empty state */}
        {!isLoading && filtered.length === 0 && (
          <div className="empty-state">
            <Receipt className="empty-state-icon" />
            <p className="empty-state-title">
              {search || filterStatut !== 'all' ? 'Aucun résultat' : 'Aucune facture'}
            </p>
            <p className="empty-state-desc">
              {search || filterStatut !== 'all'
                ? 'Essayez de modifier vos filtres de recherche.'
                : 'Créez votre première facture dès maintenant.'}
            </p>
            {!search && filterStatut === 'all' && (
              <Button size="sm" className="mt-4" onClick={openNew}>
                <Plus className="w-4 h-4" /> Créer une facture
              </Button>
            )}
          </div>
        )}
      </div>

      {/* ── Modals ──────────────────────────────────────────────── */}

      {/* Create / Edit form */}
      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <CreditCard className="w-5 h-5 text-blue-600 dark:text-blue-400" />
              {editing ? 'Modifier la facture' : 'Nouvelle facture'}
            </DialogTitle>
          </DialogHeader>
          <FactureForm
            facture={editing}
            onClose={() => { setShowForm(false); setEditing(undefined) }}
          />
        </DialogContent>
      </Dialog>

      {/* Detail view */}
      <FactureDetailModal
        facture={viewTarget}
        open={!!viewTarget}
        onClose={() => setViewTarget(null)}
        onEdit={() => { if (viewTarget) openEdit(viewTarget) }}
        onMarkPaid={() => { if (viewTarget) handleMarkPaid(viewTarget) }}
      />

      {/* Delete confirmation */}
      <DeleteConfirmDialog
        facture={deleteTarget}
        open={!!deleteTarget}
        onConfirm={handleDeleteConfirm}
        onCancel={() => setDeleteTarget(null)}
        loading={deleteFacture.isPending}
      />

      {/* Send email */}
      <SendEmailDialog
        facture={emailTarget}
        open={!!emailTarget}
        onClose={() => setEmailTarget(null)}
        onMarkSent={() => {
          if (emailTarget) markEnvoyee.mutate(emailTarget.id)
          setEmailTarget(null)
        }}
      />
    </div>
  )
}

