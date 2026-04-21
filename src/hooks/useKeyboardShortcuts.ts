import { useEffect, useCallback, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { openGlobalSearch } from '@/components/GlobalSearch'
import { SHORTCUTS_MODAL_EVENT } from '@/components/ShortcutsModal'

// G + key sequences for navigation
const G_MAP: Record<string, string> = {
  d: '/',            // G D → Dashboard
  p: '/prospects',   // G P → Prospects
  c: '/clients',     // G C → Clients
  f: '/factures',    // G F → Factures
  v: '/devis',       // G V → Devis (Devis)
  t: '/taches',      // G T → Tâches
  a: '/paiements',   // G A → Cash flow (pAiements)
  s: '/statistiques',// G S → Statistiques
  e: '/equipe',      // G E → Équipe
  r: '/rapports',    // G R → Rapports
  i: '/conseiller-ia', // G I → IA
}


export function useKeyboardShortcuts() {
  const navigate = useNavigate()
  const [gPressed, setGPressed] = useState(false)
  const [gTimer, setGTimer]     = useState<ReturnType<typeof setTimeout> | null>(null)

  const handleKey = useCallback((e: KeyboardEvent) => {
    const tag = (e.target as HTMLElement).tagName
    const inInput = tag === 'INPUT' || tag === 'TEXTAREA' || (e.target as HTMLElement).isContentEditable

    // ── Cmd/Ctrl + K → global search (works everywhere) ──
    if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
      e.preventDefault()
      openGlobalSearch()
      return
    }

    // Skip all other shortcuts when user is typing in a field
    if (inInput) return

    // ── ? → show shortcut help modal ──
    if (e.key === '?') {
      window.dispatchEvent(new CustomEvent(SHORTCUTS_MODAL_EVENT))
      return
    }

    // ── G → start sequence ──
    if (e.key === 'g' || e.key === 'G') {
      if (gPressed) return
      setGPressed(true)
      const t = setTimeout(() => setGPressed(false), 1500)
      setGTimer(t)
      return
    }

    // ── G + key → navigate ──
    if (gPressed) {
      const target = G_MAP[e.key.toLowerCase()]
      if (target) {
        e.preventDefault()
        setGPressed(false)
        if (gTimer) clearTimeout(gTimer)
        navigate(target)
      }
      return
    }

  }, [navigate, gPressed, gTimer])

  useEffect(() => {
    window.addEventListener('keydown', handleKey)
    return () => window.removeEventListener('keydown', handleKey)
  }, [handleKey])

  // Cleanup timer on unmount
  useEffect(() => {
    return () => { if (gTimer) clearTimeout(gTimer) }
  }, [gTimer])
}
