/**
 * generateDevisPDF — Unified PDF engine.
 *
 * Renders the exact same DevisTemplate that is shown on screen,
 * then triggers the browser print dialog (or auto-closes for
 * the "download" path).  Zero divergence between preview and PDF.
 *
 * Previous jsPDF implementation removed: it ignored showQuantite /
 * showPrixUnit toggles, never rendered the signature, and could not
 * handle multi-page documents.
 */
import { createElement } from 'react'
import { createRoot }    from 'react-dom/client'
import { toast }         from 'sonner'
import DevisTemplate     from '@/components/devis/DevisTemplate'
import { openPrint }     from '@/components/devis/DevisActions'
import type { Devis }    from '@/hooks/useDevis'
import type { Client }   from '@/hooks/useClients'

/**
 * Render DevisTemplate in a hidden off-screen container, capture the
 * resulting DOM node, and pass it to the shared iframe-print engine.
 *
 * @param autoClose  true  → "Télécharger PDF" (closes after print)
 *                   false → "Imprimer" (keeps dialog open)
 */
export function generateDevisPDF(
  d:          Devis,
  client?:    Client,
  autoClose = true,
): Promise<void> {
  return new Promise((resolve, reject) => {
    /* 1. Hidden mount point — off-screen, never painted */
    const container = document.createElement('div')
    container.style.cssText =
      'position:fixed;top:-9999px;left:-9999px;width:210mm;' +
      'visibility:hidden;pointer-events:none;z-index:-1;'
    document.body.appendChild(container)

    /* 2. Render the template (synchronous component, no async deps) */
    const root = createRoot(container)
    root.render(createElement(DevisTemplate, { devis: d, client }))

    /* 3. Four rAF → ensures React has committed on slow devices */
    let rafCount = 0
    const waitFrames = (cb: () => void) => {
      if (++rafCount < 4) requestAnimationFrame(() => waitFrames(cb))
      else cb()
    }

    waitFrames(() => {
      const el = container.firstElementChild as HTMLDivElement | null

      if (!el) {
        root.unmount()
        container.remove()
        reject(new Error('PDF render failed: template element not found'))
        return
      }

      openPrint(el, d.numero, autoClose)

      /* 4. Cleanup after print dialog closes / iframe auto-removes */
      setTimeout(() => {
        root.unmount()
        container.remove()
        resolve()
      }, 4_000)
    })
  })
}

/**
 * Wraps generateDevisPDF with up to 3 automatic retries (1s apart).
 * Shows a user-facing toast on each attempt failure; fatal toast after
 * all retries are exhausted.
 */
export async function generateDevisPDFWithRetry(
  d:          Devis,
  client?:    Client,
  autoClose = true,
  maxRetries = 3,
): Promise<void> {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await generateDevisPDF(d, client, autoClose)
      return
    } catch (err) {
      if (attempt < maxRetries) {
        toast.warning(`Génération PDF échouée, nouvelle tentative (${attempt}/${maxRetries - 1})…`)
        await new Promise(r => setTimeout(r, 1_000))
      } else {
        toast.error('Impossible de générer le PDF après plusieurs tentatives. Veuillez réessayer.')
        throw err
      }
    }
  }
}
