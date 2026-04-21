import { useEffect, useState } from 'react'
import { toast } from 'sonner'

export function useNetworkStatus() {
  const [online, setOnline] = useState(navigator.onLine)

  useEffect(() => {
    const handleOnline = () => {
      setOnline(true)
      toast.success('Connexion rétablie', {
        description: 'Vos données se synchronisent…',
        duration: 3000,
      })
    }
    const handleOffline = () => {
      setOnline(false)
      toast.error('Hors ligne', {
        description: "L'application fonctionne en mode lecture.",
        duration: Infinity,
        id: 'offline-toast',
      })
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
