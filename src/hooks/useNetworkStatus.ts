import { useEffect, useRef, useState } from 'react'
import { toast } from 'sonner'

/**
 * Tracks online/offline status.
 * The persistent offline indicator is rendered by <OfflineBanner /> (push-down, not overlay).
 * This hook only surfaces a one-shot success toast when the connection comes back.
 */
export function useNetworkStatus() {
  const [online, setOnline] = useState(() => navigator.onLine)
  const wasOffline = useRef(!navigator.onLine)

  useEffect(() => {
    const handleOnline = () => {
      setOnline(true)
      if (wasOffline.current) {
        toast.success('Connexion rétablie', {
          description: 'Vos données se synchronisent…',
          duration: 3000,
        })
        wasOffline.current = false
      }
    }
    const handleOffline = () => {
      setOnline(false)
      wasOffline.current = true
    }

    window.addEventListener('online',  handleOnline)
    window.addEventListener('offline', handleOffline)
    return () => {
      window.removeEventListener('online',  handleOnline)
      window.removeEventListener('offline', handleOffline)
    }
  }, [])

  return online
}
