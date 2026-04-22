/**
 * DevisPreview — Full page that hosts the A4 template + action buttons.
 * Route: /devis/:id/preview
 */
import { useRef, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { ArrowLeft, Loader2, Copy, Check } from 'lucide-react'
import { useDevis }   from '@/hooks/useDevis'
import { useClients } from '@/hooks/useClients'
import { Button }      from '@/components/ui/button'
import DevisTemplate   from '@/components/devis/DevisTemplate'
import DevisActions    from '@/components/devis/DevisActions'

export default function DevisPreview() {
  const { id }      = useParams<{ id: string }>()
  const navigate    = useNavigate()
  const templateRef = useRef<HTMLDivElement>(null)
  const [copied, setCopied] = useState(false)

  const copyLink = () => {
    navigator.clipboard.writeText(window.location.href)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  const { data: allDevis = [],   isLoading: loadingDevis   } = useDevis()
  const { data: allClients = [], isLoading: loadingClients } = useClients()

  const devis  = allDevis.find(d => d.id === id)
  const client = devis ? allClients.find(c => c.id === devis.client_id) : undefined

  const loading = loadingDevis || loadingClients

  /* ── Loading ── */
  if (loading) return (
    <div className="flex items-center justify-center min-h-[100dvh]">
      <Loader2 className="w-8 h-8 animate-spin text-blue-400" />
    </div>
  )

  /* ── Not found ── */
  if (!devis) return (
    <div className="flex flex-col items-center justify-center min-h-[100dvh] gap-4">
      <p className="text-muted-foreground">Devis introuvable.</p>
      <Button variant="secondary" onClick={() => navigate('/devis')}>
        <ArrowLeft className="w-4 h-4 mr-2" /> Retour aux devis
      </Button>
    </div>
  )

  return (
    /* Page background */
    <div className="flex flex-col h-[100dvh] bg-slate-100 dark:bg-slate-900 overflow-hidden">

      {/* ── Top bar (fixed) ──────────────────────────────── */}
      <div className="flex-shrink-0 bg-white dark:bg-slate-800 border-b border-slate-200 dark:border-slate-700 shadow-sm px-5 py-3">
        <div className="max-w-[230mm] mx-auto flex items-center justify-between">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => navigate('/devis')}
            className="text-muted-foreground hover:text-foreground"
          >
            <ArrowLeft className="w-4 h-4 mr-1.5" />
            Retour
          </Button>

          <div className="flex items-center gap-2">
            <span className="text-sm text-muted-foreground hidden sm:block font-mono">
              {devis.numero}
            </span>

            {/* Copy link */}
            <Button
              variant="ghost"
              size="sm"
              onClick={copyLink}
              className="flex items-center gap-1.5 text-muted-foreground hover:text-foreground"
            >
              {copied
                ? <><Check className="w-4 h-4 text-green-500" /><span className="text-green-500 text-xs">Copié !</span></>
                : <><Copy className="w-4 h-4" /><span className="text-xs hidden sm:inline">Copier le lien</span></>
              }
            </Button>

            <DevisActions templateRef={templateRef} numero={devis.numero} />
          </div>
        </div>
      </div>

      {/* ── Scrollable A4 area ────────────────────────────── */}
      <div className="flex-1 overflow-y-auto">
        <div className="min-h-full py-8 px-4 flex justify-center">
          <div
            style={{
              width: '210mm',
              flexShrink: 0,
              alignSelf: 'flex-start',
              boxShadow: '0 4px 40px rgba(0,0,0,0.18)',
              borderRadius: '4px',
              overflow: 'hidden',
            }}
          >
            <DevisTemplate ref={templateRef} devis={devis} client={client} />
          </div>
        </div>
        <div className="h-12" />
      </div>
    </div>
  )
}
