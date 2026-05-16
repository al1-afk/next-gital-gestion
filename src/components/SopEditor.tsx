import { useEffect, useState } from 'react'
import { createPortal } from 'react-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  X, Plus, Trash2, GripVertical, Save, FileText,
  Type, ListOrdered, CheckSquare, MessageSquare, Code as CodeIcon,
  AlertCircle, Minus,
} from 'lucide-react'
import type { Sop, SopBlock, SopBlockType } from '@/hooks/useSops'
import { makeSopSlug, useCreateSop, useUpdateSop } from '@/hooks/useSops'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { cn } from '@/lib/utils'

interface Props {
  open:        boolean
  existing?:   Sop | null
  initialCategory?: string
  onClose:     () => void
}

const CATEGORY_OPTIONS = [
  { key: 'whatsapp',   label: 'Scripts WhatsApp' },
  { key: 'quick',      label: 'Réponses rapides' },
  { key: 'sales',      label: 'Process Commercial' },
  { key: 'onboarding', label: 'Onboarding Client' },
  { key: 'delivery',   label: 'Livraison Projet' },
  { key: 'support',    label: 'Support Client' },
  { key: 'marketing',  label: 'Marketing & Ads' },
  { key: 'faq',        label: 'FAQ Interne' },
  { key: 'ai',         label: 'IA & Automatisation' },
]

const BLOCK_TYPES: { type: SopBlockType; label: string; icon: React.ElementType }[] = [
  { type: 'heading',   label: 'Titre',     icon: Type },
  { type: 'paragraph', label: 'Paragraphe',icon: FileText },
  { type: 'list',      label: 'Liste',     icon: ListOrdered },
  { type: 'checklist', label: 'Checklist', icon: CheckSquare },
  { type: 'steps',     label: 'Étapes',    icon: ListOrdered },
  { type: 'callout',   label: 'Encadré',   icon: AlertCircle },
  { type: 'template',  label: 'Template',  icon: MessageSquare },
  { type: 'code',      label: 'Code',      icon: CodeIcon },
  { type: 'divider',   label: 'Séparateur',icon: Minus },
]

export default function SopEditor({ open, existing, initialCategory, onClose }: Props) {
  const [title,       setTitle]       = useState('')
  const [description, setDescription] = useState('')
  const [category,    setCategory]    = useState('whatsapp')
  const [tagsInput,   setTagsInput]   = useState('')
  const [readMin,     setReadMin]     = useState(2)
  const [popular,     setPopular]     = useState(false)
  const [blocks,      setBlocks]      = useState<SopBlock[]>([])

  const create = useCreateSop()
  const update = useUpdateSop()

  /* Charger les données existantes en mode édition */
  useEffect(() => {
    if (!open) return
    if (existing) {
      setTitle(existing.title ?? '')
      setDescription(existing.description ?? '')
      setCategory(existing.category ?? 'whatsapp')
      setTagsInput((existing.tags ?? []).join(', '))
      setReadMin(existing.read_min ?? 2)
      setPopular(existing.popular ?? false)
      setBlocks(existing.blocks ?? [])
    } else {
      setTitle('')
      setDescription('')
      setCategory(initialCategory && initialCategory !== 'home' ? initialCategory : 'whatsapp')
      setTagsInput('')
      setReadMin(2)
      setPopular(false)
      setBlocks([
        { type: 'paragraph', text: '' },
      ])
    }
  }, [open, existing, initialCategory])

  const tags = tagsInput
    .split(',')
    .map(t => t.trim())
    .filter(Boolean)

  const addBlock = (type: SopBlockType) => {
    const newBlock: SopBlock =
      type === 'list' || type === 'checklist' || type === 'steps'
        ? { type, items: [''] }
        : type === 'callout'
        ? { type, variant: 'tip', title: '', text: '' }
        : type === 'divider'
        ? { type }
        : { type, text: '' }
    setBlocks(b => [...b, newBlock])
  }

  const updateBlock = (idx: number, patch: Partial<SopBlock>) => {
    setBlocks(b => b.map((blk, i) => (i === idx ? { ...blk, ...patch } : blk)))
  }

  const removeBlock = (idx: number) => {
    setBlocks(b => b.filter((_, i) => i !== idx))
  }

  const moveBlock = (idx: number, dir: 'up' | 'down') => {
    setBlocks(b => {
      const next = [...b]
      const j = dir === 'up' ? idx - 1 : idx + 1
      if (j < 0 || j >= next.length) return b
      ;[next[idx], next[j]] = [next[j], next[idx]]
      return next
    })
  }

  const updateItem = (blockIdx: number, itemIdx: number, value: string) => {
    setBlocks(b => b.map((blk, i) => {
      if (i !== blockIdx) return blk
      const items = [...(blk.items ?? [])]
      items[itemIdx] = value
      return { ...blk, items }
    }))
  }

  const addItem = (blockIdx: number) => {
    setBlocks(b => b.map((blk, i) =>
      i === blockIdx ? { ...blk, items: [...(blk.items ?? []), ''] } : blk
    ))
  }

  const removeItem = (blockIdx: number, itemIdx: number) => {
    setBlocks(b => b.map((blk, i) => {
      if (i !== blockIdx) return blk
      const items = (blk.items ?? []).filter((_, k) => k !== itemIdx)
      return { ...blk, items }
    }))
  }

  const save = async () => {
    if (!title.trim()) return
    /* Nettoyer les items vides */
    const cleanBlocks = blocks
      .map(blk =>
        blk.items
          ? { ...blk, items: blk.items.filter(it => it.trim() !== '') }
          : blk
      )
      .filter(blk => {
        if (blk.type === 'divider') return true
        if (blk.items) return blk.items.length > 0
        return (blk.text ?? '').trim() !== ''
      })

    const payload = {
      title:       title.trim(),
      description: description.trim() || null,
      category,
      tags,
      slug:        existing?.slug || makeSopSlug(title),
      read_min:    Number(readMin) || 2,
      popular,
      blocks:      cleanBlocks,
    }

    if (existing) {
      await update.mutateAsync({ id: existing.id, ...payload } as any)
    } else {
      await create.mutateAsync(payload as any)
    }
    onClose()
  }

  /* Bloquer le scroll de la page + touche Escape pour fermer */
  useEffect(() => {
    if (!open) return
    const prev = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose() }
    window.addEventListener('keydown', onKey)
    return () => {
      document.body.style.overflow = prev
      window.removeEventListener('keydown', onKey)
    }
  }, [open, onClose])

  if (!open) return null

  /* Rendu via Portal pour éviter les parents avec transform/filter qui
     créeraient un containing block et casseraient `position: fixed`. */
  return createPortal(
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.2 }}
        style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, zIndex: 100 }}
        className="bg-slate-950/80 backdrop-blur-md flex items-center justify-center p-0 md:p-6"
        onClick={onClose}
      >
        <motion.div
          initial={{ opacity: 0, y: 20, scale: 0.97 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: 20, scale: 0.97 }}
          transition={{ type: 'spring', damping: 28, stiffness: 280 }}
          className="relative bg-background border border-border rounded-2xl shadow-2xl ring-1 ring-white/10 w-full md:max-w-3xl flex flex-col overflow-hidden"
          style={{ maxHeight: 'min(92vh, 900px)' }}
          onClick={e => e.stopPropagation()}
        >
          {/* Header avec accent gradient en haut */}
          <div className="relative flex-shrink-0">
            <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-blue-500 via-violet-500 to-emerald-500" />
            <div className="flex items-center justify-between px-5 md:px-6 py-4 border-b border-border bg-gradient-to-br from-blue-50/50 to-violet-50/30 dark:from-blue-950/20 dark:to-violet-950/10">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-violet-600 flex items-center justify-center shadow-md shadow-blue-500/20">
                  <FileText className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h2 className="text-lg font-extrabold tracking-tight text-foreground">
                    {existing ? 'Modifier le SOP' : 'Nouveau SOP'}
                  </h2>
                  <p className="text-xs text-muted-foreground">
                    {existing ? 'Édition d\'une procédure existante' : 'Créer une nouvelle procédure ou un template'}
                  </p>
                </div>
              </div>
              <button
                onClick={onClose}
                className="p-2 rounded-lg hover:bg-white/80 dark:hover:bg-slate-800 transition-colors"
                title="Fermer (Echap)"
              >
                <X className="w-5 h-5 text-muted-foreground" />
              </button>
            </div>
          </div>

          {/* Body — scrollable */}
          <div className="flex-1 overflow-y-auto px-5 md:px-6 py-5 space-y-6">
            {/* Section : Métadonnées */}
            <section className="space-y-3">
              <h3 className="text-[11px] font-bold uppercase tracking-[0.12em] text-muted-foreground flex items-center gap-1.5">
                <span className="inline-block w-1 h-4 rounded-full bg-blue-500" />
                Informations
              </h3>
              <Field label="Titre" required>
                <Input
                  value={title}
                  onChange={e => setTitle(e.target.value)}
                  placeholder="Ex. Message d'accueil WhatsApp"
                />
              </Field>

              <Field label="Description">
                <Input
                  value={description}
                  onChange={e => setDescription(e.target.value)}
                  placeholder="Une phrase qui résume quand utiliser ce SOP"
                />
              </Field>

              <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                <Field label="Catégorie">
                  <select
                    value={category}
                    onChange={e => setCategory(e.target.value)}
                    className="w-full h-10 rounded-lg border border-border bg-[var(--surface-input)] px-3 text-sm text-foreground focus:outline-none focus:border-[#378ADD]"
                  >
                    {CATEGORY_OPTIONS.map(c => (
                      <option key={c.key} value={c.key}>{c.label}</option>
                    ))}
                  </select>
                </Field>

                <Field label="Temps de lecture (min)">
                  <Input
                    type="number"
                    min={1}
                    max={60}
                    value={readMin}
                    onChange={e => setReadMin(Number(e.target.value))}
                  />
                </Field>

                <Field label="Populaire">
                  <label className="flex items-center gap-2 h-10 px-3 rounded-lg border border-border bg-[var(--surface-input)] cursor-pointer">
                    <input
                      type="checkbox"
                      checked={popular}
                      onChange={e => setPopular(e.target.checked)}
                      className="w-4 h-4 accent-blue-600"
                    />
                    <span className="text-sm text-foreground">Marquer comme populaire</span>
                  </label>
                </Field>
              </div>

              <Field label="Tags (séparés par des virgules)">
                <Input
                  value={tagsInput}
                  onChange={e => setTagsInput(e.target.value)}
                  placeholder="Ex. WhatsApp, Accueil, Prospect"
                />
                {tags.length > 0 && (
                  <div className="flex flex-wrap gap-1 mt-2">
                    {tags.map(t => (
                      <span key={t} className="px-2 py-0.5 rounded-md text-[11px] font-semibold bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/50 dark:text-blue-300">
                        #{t}
                      </span>
                    ))}
                  </div>
                )}
              </Field>
            </section>

            {/* Section : Contenu / Blocs */}
            <section>
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-[11px] font-bold uppercase tracking-[0.12em] text-muted-foreground flex items-center gap-1.5">
                  <span className="inline-block w-1 h-4 rounded-full bg-violet-500" />
                  Contenu
                </h3>
                <span className="text-[11px] font-semibold text-muted-foreground bg-muted px-2 py-0.5 rounded-md">{blocks.length} bloc{blocks.length > 1 ? 's' : ''}</span>
              </div>

              <div className="space-y-3">
                {blocks.map((blk, i) => (
                  <BlockEditor
                    key={i}
                    block={blk}
                    index={i}
                    total={blocks.length}
                    onUpdate={patch => updateBlock(i, patch)}
                    onUpdateItem={(j, v) => updateItem(i, j, v)}
                    onAddItem={() => addItem(i)}
                    onRemoveItem={j => removeItem(i, j)}
                    onMoveUp={() => moveBlock(i, 'up')}
                    onMoveDown={() => moveBlock(i, 'down')}
                    onRemove={() => removeBlock(i)}
                  />
                ))}
              </div>

              {/* Ajouter bloc */}
              <div className="mt-4 p-4 rounded-xl border border-dashed border-blue-300 dark:border-blue-700/50 bg-blue-50/30 dark:bg-blue-950/10">
                <p className="text-[11px] font-bold uppercase tracking-[0.12em] text-blue-700 dark:text-blue-300 mb-3 flex items-center gap-1.5">
                  <Plus className="w-3.5 h-3.5" />
                  Ajouter un bloc
                </p>
                <div className="flex flex-wrap gap-1.5">
                  {BLOCK_TYPES.map(bt => {
                    const Icon = bt.icon
                    return (
                      <button
                        key={bt.type}
                        onClick={() => addBlock(bt.type)}
                        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold border border-border bg-background hover:bg-blue-50 hover:border-blue-400 hover:text-blue-700 dark:hover:bg-blue-950/40 dark:hover:text-blue-300 transition-all"
                      >
                        <Icon className="w-3.5 h-3.5" />
                        {bt.label}
                      </button>
                    )
                  })}
                </div>
              </div>
            </section>
          </div>

          {/* Footer collant */}
          <div className="flex items-center justify-between gap-3 px-5 md:px-6 py-3.5 border-t border-border flex-shrink-0 bg-card/95 backdrop-blur-sm">
            <div className="text-[11px] text-muted-foreground hidden sm:block">
              {existing
                ? `Modifié le ${new Date(existing.updated_at).toLocaleDateString('fr-FR')} • ${blocks.length} bloc${blocks.length > 1 ? 's' : ''}`
                : `${blocks.length} bloc${blocks.length > 1 ? 's' : ''} • Échap pour annuler`}
            </div>
            <div className="flex items-center gap-2 ml-auto">
              <Button variant="secondary" size="sm" onClick={onClose}>
                Annuler
              </Button>
              <Button
                size="sm"
                onClick={save}
                disabled={!title.trim() || create.isPending || update.isPending}
                className="min-w-[120px]"
              >
                <Save className="w-3.5 h-3.5" />
                {(create.isPending || update.isPending) ? 'Sauvegarde…' : existing ? 'Mettre à jour' : 'Créer le SOP'}
              </Button>
            </div>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>,
    document.body
  )
}

/* ── Sub-components ──────────────────────────────────────────── */

function Field({ label, required, children }: {
  label: string; required?: boolean; children: React.ReactNode
}) {
  return (
    <label className="block">
      <span className="block text-[11px] font-bold uppercase tracking-wider text-muted-foreground mb-1">
        {label}
        {required && <span className="text-rose-500 ml-1">*</span>}
      </span>
      {children}
    </label>
  )
}

function BlockEditor({
  block, index, total,
  onUpdate, onUpdateItem, onAddItem, onRemoveItem,
  onMoveUp, onMoveDown, onRemove,
}: {
  block:        SopBlock
  index:        number
  total:        number
  onUpdate:     (patch: Partial<SopBlock>) => void
  onUpdateItem: (idx: number, value: string) => void
  onAddItem:    () => void
  onRemoveItem: (idx: number) => void
  onMoveUp:     () => void
  onMoveDown:   () => void
  onRemove:     () => void
}) {
  const isList = block.type === 'list' || block.type === 'checklist' || block.type === 'steps'
  return (
    <div className="group rounded-xl border border-border bg-card overflow-hidden">
      {/* Header */}
      <div className="flex items-center justify-between px-3 py-2 border-b border-border bg-muted/20">
        <div className="flex items-center gap-2">
          <GripVertical className="w-3.5 h-3.5 text-muted-foreground/50" />
          <span className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">
            #{index + 1} · {block.type}
          </span>
        </div>
        <div className="flex items-center gap-1">
          <button
            onClick={onMoveUp}
            disabled={index === 0}
            className="p-1 rounded text-muted-foreground hover:bg-muted disabled:opacity-30"
            title="Monter"
          >▲</button>
          <button
            onClick={onMoveDown}
            disabled={index === total - 1}
            className="p-1 rounded text-muted-foreground hover:bg-muted disabled:opacity-30"
            title="Descendre"
          >▼</button>
          <button
            onClick={onRemove}
            className="p-1 rounded text-muted-foreground hover:bg-rose-50 hover:text-rose-600 dark:hover:bg-rose-900/30"
            title="Supprimer"
          >
            <Trash2 className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>

      {/* Body */}
      <div className="p-3 space-y-2">
        {block.type === 'divider' ? (
          <p className="text-center text-xs text-muted-foreground italic">— Séparateur visuel —</p>
        ) : block.type === 'callout' ? (
          <>
            <div className="grid grid-cols-2 gap-2">
              <select
                value={block.variant ?? 'tip'}
                onChange={e => onUpdate({ variant: e.target.value as SopBlock['variant'] })}
                className="h-9 rounded-lg border border-border bg-[var(--surface-input)] px-2 text-sm"
              >
                <option value="tip">💡 Tip</option>
                <option value="info">ℹ️ Info</option>
                <option value="warning">⚠️ Attention</option>
                <option value="success">✅ Succès</option>
              </select>
              <Input
                value={block.title ?? ''}
                onChange={e => onUpdate({ title: e.target.value })}
                placeholder="Titre de l'encadré"
              />
            </div>
            <textarea
              value={block.text ?? ''}
              onChange={e => onUpdate({ text: e.target.value })}
              placeholder="Contenu de l'encadré…"
              rows={3}
              className="w-full rounded-lg border border-border bg-[var(--surface-input)] px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:border-[#378ADD] resize-y"
            />
          </>
        ) : isList ? (
          <>
            {(block.items ?? []).map((item, j) => (
              <div key={j} className="flex items-center gap-2">
                <span className="text-xs text-muted-foreground w-5 text-right">
                  {block.type === 'steps' ? `${j + 1}.` : '•'}
                </span>
                <Input
                  value={item}
                  onChange={e => onUpdateItem(j, e.target.value)}
                  placeholder={`Élément ${j + 1}`}
                  className="flex-1"
                />
                <button
                  onClick={() => onRemoveItem(j)}
                  className="p-1.5 rounded text-muted-foreground hover:bg-rose-50 hover:text-rose-600 dark:hover:bg-rose-900/30"
                >
                  <Trash2 className="w-3.5 h-3.5" />
                </button>
              </div>
            ))}
            <button
              onClick={onAddItem}
              className="inline-flex items-center gap-1.5 px-2 py-1 rounded-md text-xs font-semibold text-blue-600 hover:bg-blue-50 dark:hover:bg-blue-950/30 transition-colors"
            >
              <Plus className="w-3 h-3" /> Ajouter un élément
            </button>
          </>
        ) : block.type === 'heading' ? (
          <Input
            value={block.text ?? ''}
            onChange={e => onUpdate({ text: e.target.value })}
            placeholder="Titre de la section"
            className="font-bold text-base"
          />
        ) : (
          <textarea
            value={block.text ?? ''}
            onChange={e => onUpdate({ text: e.target.value })}
            placeholder={
              block.type === 'template'
                ? 'Template avec variables — ex: Bonjour {{prenom}} …'
                : block.type === 'code'
                ? 'Code (sera affiché en monospace)'
                : 'Tapez votre texte…'
            }
            rows={block.type === 'template' || block.type === 'code' ? 5 : 3}
            className={cn(
              'w-full rounded-lg border border-border bg-[var(--surface-input)] px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:border-[#378ADD] resize-y',
              (block.type === 'template' || block.type === 'code') && 'font-mono text-[13px]'
            )}
          />
        )}
      </div>
    </div>
  )
}
