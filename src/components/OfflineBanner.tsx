import { useEffect, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { WifiOff } from 'lucide-react'

export default function OfflineBanner() {
  const [online, setOnline] = useState(() => navigator.onLine)

  useEffect(() => {
    const on  = () => setOnline(true)
    const off = () => setOnline(false)
    window.addEventListener('online',  on)
    window.addEventListener('offline', off)
    return () => {
      window.removeEventListener('online',  on)
      window.removeEventListener('offline', off)
    }
  }, [])

  return (
    <AnimatePresence>
      {!online && (
        <motion.div
          initial={{ height: 0, opacity: 0 }}
          animate={{ height: 'auto', opacity: 1 }}
          exit={{ height: 0, opacity: 0 }}
          transition={{ duration: 0.2, ease: 'easeOut' }}
          role="status"
          aria-live="polite"
          className="overflow-hidden"
        >
          <div className="flex items-center justify-center gap-2 bg-amber-500 text-white text-xs sm:text-sm font-medium px-4 py-2">
            <WifiOff className="w-3.5 h-3.5 flex-shrink-0" />
            <span className="truncate">Hors ligne — mode lecture. Vos modifications seront synchronisées au retour de la connexion.</span>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}
