import { useMemo } from 'react'
import { useNavigate, useParams, useSearchParams } from 'react-router-dom'
import { motion } from 'framer-motion'
import { Rocket, ArrowLeft, Sparkles, Clock, Bell } from 'lucide-react'

function MeshBackground() {
  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none">
      <div className="absolute top-[-10%] left-[-5%] w-[480px] h-[480px] rounded-full bg-indigo-400/20 blur-3xl animate-blob" />
      <div className="absolute top-[10%] right-[-10%] w-[520px] h-[520px] rounded-full bg-pink-400/20 blur-3xl animate-blob [animation-delay:-4s]" />
      <div className="absolute bottom-[-10%] left-[30%] w-[460px] h-[460px] rounded-full bg-purple-400/20 blur-3xl animate-blob [animation-delay:-8s]" />
      <div
        className="absolute inset-0 opacity-[0.18]"
        style={{
          backgroundImage:
            'linear-gradient(rgba(99,102,241,0.08) 1px, transparent 1px), linear-gradient(90deg, rgba(99,102,241,0.08) 1px, transparent 1px)',
          backgroundSize: '44px 44px',
          maskImage: 'radial-gradient(ellipse at center, black 45%, transparent 80%)',
        }}
      />
    </div>
  )
}

export default function ComingSoon() {
  const navigate = useNavigate()
  const { tenantSlug } = useParams<{ tenantSlug: string }>()
  const [params] = useSearchParams()

  const featureName = params.get('feature') ?? 'Cette fonctionnalité'

  const eta = useMemo(() => {
    const target = new Date()
    target.setMonth(target.getMonth() + 1)
    return target.toLocaleDateString('fr-FR', { month: 'long', year: 'numeric' })
  }, [])

  const goHome = () => navigate(tenantSlug ? `/${tenantSlug}` : '/')

  return (
    <div className="relative min-h-[100dvh] flex items-center justify-center px-4 py-16 overflow-hidden bg-gradient-to-br from-slate-50 via-white to-indigo-50 dark:from-[#060d1c] dark:via-[#0a1428] dark:to-[#0f1a35]">
      <MeshBackground />

      <motion.div
        initial={{ opacity: 0, y: 24 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, ease: 'easeOut' }}
        className="relative z-10 w-full max-w-2xl text-center"
      >
        <motion.div
          initial={{ scale: 0, rotate: -45 }}
          animate={{ scale: 1, rotate: 0 }}
          transition={{ type: 'spring', stiffness: 180, damping: 14, delay: 0.1 }}
          className="inline-flex items-center justify-center w-24 h-24 rounded-3xl mb-8 relative"
          style={{
            background: 'linear-gradient(135deg, #2563EB 0%, #7C3AED 100%)',
            boxShadow: '0 20px 50px -10px rgba(124,58,237,0.55)',
          }}
        >
          <Rocket className="w-11 h-11 text-white" strokeWidth={2.2} />
          <motion.div
            animate={{ y: [0, -6, 0], rotate: [0, 8, 0] }}
            transition={{ duration: 2.4, repeat: Infinity, ease: 'easeInOut' }}
            className="absolute -top-2 -right-2 w-8 h-8 rounded-full bg-white dark:bg-slate-900 flex items-center justify-center shadow-lg"
          >
            <Sparkles className="w-4 h-4 text-amber-500" />
          </motion.div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border border-violet-200/60 bg-violet-50/70 dark:bg-violet-950/40 dark:border-violet-800/40 mb-6"
        >
          <span className="w-2 h-2 rounded-full bg-violet-500 animate-pulse" />
          <span className="text-xs font-semibold text-violet-700 dark:text-violet-300 tracking-wide">
            En cours de développement
          </span>
        </motion.div>

        <motion.h1
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.25 }}
          className="text-4xl sm:text-5xl md:text-6xl font-black tracking-tight text-slate-900 dark:text-white mb-4"
        >
          Bientôt disponible
        </motion.h1>

        <motion.p
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="text-base sm:text-lg text-slate-600 dark:text-slate-400 mb-8 max-w-lg mx-auto leading-relaxed"
        >
          {featureName} sera disponible très prochainement. Notre équipe travaille
          activement pour vous offrir la meilleure expérience possible.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.35 }}
          className="grid grid-cols-1 sm:grid-cols-2 gap-3 max-w-md mx-auto mb-10"
        >
          <div className="flex items-center gap-3 p-4 rounded-2xl bg-white/70 dark:bg-slate-900/50 border border-slate-200/70 dark:border-slate-800/60 backdrop-blur">
            <div className="w-10 h-10 rounded-xl bg-indigo-100 dark:bg-indigo-950/50 flex items-center justify-center">
              <Clock className="w-5 h-5 text-indigo-600 dark:text-indigo-400" />
            </div>
            <div className="text-left">
              <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-500">
                Lancement prévu
              </p>
              <p className="text-sm font-bold text-slate-900 dark:text-white capitalize">
                {eta}
              </p>
            </div>
          </div>

          <div className="flex items-center gap-3 p-4 rounded-2xl bg-white/70 dark:bg-slate-900/50 border border-slate-200/70 dark:border-slate-800/60 backdrop-blur">
            <div className="w-10 h-10 rounded-xl bg-pink-100 dark:bg-pink-950/50 flex items-center justify-center">
              <Bell className="w-5 h-5 text-pink-600 dark:text-pink-400" />
            </div>
            <div className="text-left">
              <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-500">
                Statut
              </p>
              <p className="text-sm font-bold text-slate-900 dark:text-white">
                Bêta privée
              </p>
            </div>
          </div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="flex flex-col sm:flex-row items-center justify-center gap-3"
        >
          <button
            onClick={goHome}
            className="inline-flex items-center gap-2 px-6 py-3 rounded-xl font-semibold text-white transition-all hover:scale-[1.02] active:scale-[0.98]"
            style={{
              background: 'linear-gradient(135deg, #2563EB 0%, #7C3AED 100%)',
              boxShadow: '0 10px 25px -8px rgba(124,58,237,0.55)',
            }}
          >
            <ArrowLeft className="w-4 h-4" />
            Retour au tableau de bord
          </button>

          <button
            onClick={() => navigate(-1)}
            className="inline-flex items-center gap-2 px-6 py-3 rounded-xl font-semibold text-slate-700 dark:text-slate-200 bg-white/80 dark:bg-slate-900/60 border border-slate-200 dark:border-slate-800 hover:bg-white dark:hover:bg-slate-900 transition-all"
          >
            Page précédente
          </button>
        </motion.div>
      </motion.div>
    </div>
  )
}
