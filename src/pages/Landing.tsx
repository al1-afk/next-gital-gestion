import { useState, useRef, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  motion, useScroll, useTransform, useSpring, useMotionValue,
  useInView, AnimatePresence, type Variants,
} from 'framer-motion'
import {
  CheckCircle, Users, FileText, CreditCard, AlertCircle, Loader2,
  Bell, Shield, Globe, Wallet, Calendar, Smartphone, Palette,
  Sparkles, Brain, Command, Languages, Moon, ArrowRight, Zap,
  Lock as LockIcon, FileSpreadsheet, Clock,
} from 'lucide-react'
import { authApi, tokenStore } from '@/lib/api'

function slugify(str: string) {
  return str
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')
    .replace(/[^a-z0-9-]/g, '')
    .slice(0, 30)
}

/* ────────────────────────────────────────────────────────────
   Animated mesh-gradient background with floating blobs
   ──────────────────────────────────────────────────────────── */
function MeshBackground() {
  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none">
      <div className="absolute top-[-10%] left-[-5%] w-[480px] h-[480px] rounded-full bg-indigo-400/30 blur-3xl animate-blob" />
      <div className="absolute top-[10%] right-[-10%] w-[520px] h-[520px] rounded-full bg-pink-400/30 blur-3xl animate-blob [animation-delay:-4s]" />
      <div className="absolute bottom-[-10%] left-[30%] w-[460px] h-[460px] rounded-full bg-purple-400/30 blur-3xl animate-blob [animation-delay:-8s]" />
      <div
        className="absolute inset-0 opacity-[0.25]"
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

/* ────────────────────────────────────────────────────────────
   Animated count-up (uses IntersectionObserver via useInView)
   ──────────────────────────────────────────────────────────── */
function Counter({ to, suffix = '', duration = 1.6 }: { to: number; suffix?: string; duration?: number }) {
  const ref = useRef<HTMLSpanElement>(null)
  const inView = useInView(ref, { once: true, margin: '-20% 0px' })
  const [value, setValue] = useState(0)

  useEffect(() => {
    if (!inView) return
    const start = performance.now()
    let raf = 0
    const tick = (now: number) => {
      const t = Math.min((now - start) / (duration * 1000), 1)
      const eased = 1 - Math.pow(1 - t, 3)
      setValue(Math.round(to * eased))
      if (t < 1) raf = requestAnimationFrame(tick)
    }
    raf = requestAnimationFrame(tick)
    return () => cancelAnimationFrame(raf)
  }, [inView, to, duration])

  return (
    <span ref={ref}>
      {value.toLocaleString('fr-FR')}
      {suffix}
    </span>
  )
}

/* ────────────────────────────────────────────────────────────
   3D-tilt wrapper for the signup card
   ──────────────────────────────────────────────────────────── */
function TiltCard({ children }: { children: React.ReactNode }) {
  const x = useMotionValue(0)
  const y = useMotionValue(0)
  const rotateX = useSpring(useTransform(y, [-0.5, 0.5], [8, -8]), { stiffness: 150, damping: 15 })
  const rotateY = useSpring(useTransform(x, [-0.5, 0.5], [-8, 8]), { stiffness: 150, damping: 15 })

  const onMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect()
    x.set((e.clientX - rect.left) / rect.width - 0.5)
    y.set((e.clientY - rect.top) / rect.height - 0.5)
  }
  const onMouseLeave = () => { x.set(0); y.set(0) }

  return (
    <motion.div
      onMouseMove={onMouseMove}
      onMouseLeave={onMouseLeave}
      style={{ rotateX, rotateY, transformStyle: 'preserve-3d', perspective: 1000 }}
      className="relative"
    >
      {children}
    </motion.div>
  )
}

/* ────────────────────────────────────────────────────────────
   Magnetic button — follows cursor within a radius
   ──────────────────────────────────────────────────────────── */
function MagneticButton({ children, className = '', onClick }: {
  children: React.ReactNode; className?: string; onClick?: () => void
}) {
  const ref = useRef<HTMLButtonElement>(null)
  const x = useSpring(useMotionValue(0), { stiffness: 150, damping: 12 })
  const y = useSpring(useMotionValue(0), { stiffness: 150, damping: 12 })

  const onMove = (e: React.MouseEvent<HTMLButtonElement>) => {
    const rect = ref.current?.getBoundingClientRect()
    if (!rect) return
    x.set((e.clientX - rect.left - rect.width / 2) * 0.2)
    y.set((e.clientY - rect.top - rect.height / 2) * 0.2)
  }
  const onLeave = () => { x.set(0); y.set(0) }

  return (
    <motion.button
      ref={ref}
      onMouseMove={onMove}
      onMouseLeave={onLeave}
      onClick={onClick}
      style={{ x, y }}
      whileTap={{ scale: 0.96 }}
      className={className}
    >
      {children}
    </motion.button>
  )
}

/* ────────────────────────────────────────────────────────────
   Staggered section wrapper
   ──────────────────────────────────────────────────────────── */
const containerV: Variants = {
  hidden: {},
  show: { transition: { staggerChildren: 0.08, delayChildren: 0.05 } },
}
const itemV: Variants = {
  hidden: { opacity: 0, y: 24, filter: 'blur(8px)' },
  show:   { opacity: 1, y: 0,  filter: 'blur(0px)', transition: { type: 'spring', stiffness: 100, damping: 18 } },
}

export default function Landing() {
  const navigate = useNavigate()
  const [email, setEmail]         = useState('')
  const [password, setPassword]   = useState('')
  const [name, setName]           = useState('')
  const [company, setCompany]     = useState('')
  const [loading, setLoading]     = useState(false)
  const [error, setError]         = useState<string | null>(null)

  const heroRef = useRef<HTMLDivElement>(null)
  const { scrollYProgress } = useScroll({ target: heroRef, offset: ['start start', 'end start'] })
  const heroY     = useTransform(scrollYProgress, [0, 1], [0, -120])
  const heroFade  = useTransform(scrollYProgress, [0, 0.8], [1, 0])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)
    if (password.length < 8) {
      setError('Le mot de passe doit contenir au moins 8 caractères')
      return
    }
    const tenantName = company.trim() || name.trim()
    const tenantSlug = slugify(tenantName) || 'mon-espace'

    setLoading(true)
    try {
      const res = await authApi.register({ email, password, name, tenantSlug, tenantName })
      tokenStore.set(res.token)
      sessionStorage.setItem('gestiq_tenant_slug', res.tenantSlug)
      navigate(`/${res.tenantSlug}`, { replace: true })
    } catch (err: any) {
      setError(err.message || 'Une erreur est survenue')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-slate-50 text-slate-900 overflow-x-clip">

      {/* ── Nav ─────────────────────────────────────────────── */}
      <motion.nav
        initial={{ y: -24, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 0.5, ease: 'easeOut' }}
        className="bg-white/70 backdrop-blur-xl border-b border-slate-200/70 sticky top-0 z-30"
      >
        <div className="max-w-6xl mx-auto px-6 py-4 flex items-center justify-between">
          <motion.div whileHover={{ scale: 1.03 }} className="flex items-center gap-2 cursor-pointer">
            <div className="relative w-9 h-9 rounded-xl bg-[linear-gradient(135deg,#6366f1,#a855f7,#ec4899)] bg-[length:200%_200%] animate-gradient-pan flex items-center justify-center shadow-lg shadow-purple-500/30">
              <span className="text-white font-bold text-sm">G</span>
              <div className="absolute inset-0 rounded-xl bg-white/20 blur-md -z-10" />
            </div>
            <span className="font-bold text-slate-900 text-lg tracking-tight">GestiQ</span>
          </motion.div>
          <a href="/auth" className="text-sm font-medium text-slate-600 hover:text-indigo-600 transition-colors">
            Se connecter
          </a>
        </div>
      </motion.nav>

      {/* ── Hero ────────────────────────────────────────────── */}
      <section ref={heroRef} className="relative">
        <MeshBackground />

        <motion.div
          style={{ y: heroY, opacity: heroFade }}
          className="relative max-w-6xl mx-auto px-6 pt-20 pb-20 grid lg:grid-cols-2 gap-12 items-center"
        >
          <motion.div variants={containerV} initial="hidden" animate="show">
            <motion.div variants={itemV} className="inline-flex items-center gap-2 bg-white/80 backdrop-blur border border-purple-200/70 rounded-full px-3 py-1 text-xs font-medium text-purple-700 mb-6 shadow-sm">
              <span className="relative flex w-1.5 h-1.5">
                <span className="absolute inline-flex w-full h-full rounded-full bg-purple-400 animate-ping opacity-75" />
                <span className="relative inline-flex rounded-full w-1.5 h-1.5 bg-purple-500" />
              </span>
              Gratuit pour commencer — aucune carte requise
            </motion.div>

            <motion.h1 variants={itemV} className="text-4xl lg:text-6xl font-bold text-slate-900 leading-[1.08] tracking-tight mb-5">
              Gérez vos clients et factures en 1 minute —{' '}
              <span className="relative inline-block">
                <span className="bg-[linear-gradient(135deg,#6366f1,#a855f7,#ec4899,#a855f7,#6366f1)] bg-[length:300%_auto] animate-gradient-pan bg-clip-text text-transparent">
                  sans Excel
                </span>
                <motion.svg
                  viewBox="0 0 200 12" fill="none"
                  className="absolute -bottom-2 left-0 w-full h-3"
                  initial={{ pathLength: 0 }}
                  animate={{ pathLength: 1 }}
                  transition={{ duration: 1.2, delay: 0.8, ease: 'easeInOut' }}
                >
                  <motion.path
                    d="M2 8 C 50 2, 150 2, 198 8"
                    stroke="url(#underline-grad)" strokeWidth="3" strokeLinecap="round"
                    initial={{ pathLength: 0 }}
                    animate={{ pathLength: 1 }}
                    transition={{ duration: 1.2, delay: 0.8 }}
                  />
                  <defs>
                    <linearGradient id="underline-grad" x1="0" x2="1">
                      <stop offset="0%"  stopColor="#6366f1" />
                      <stop offset="50%" stopColor="#a855f7" />
                      <stop offset="100%" stopColor="#ec4899" />
                    </linearGradient>
                  </defs>
                </motion.svg>
              </span>
            </motion.h1>

            <motion.p variants={itemV} className="text-slate-600 text-lg mb-8 max-w-xl">
              Simple, rapide, et adapté aux petites entreprises. Tout ce dont vous avez besoin, rien de plus.
            </motion.p>

            <motion.div variants={itemV} className="flex flex-wrap gap-4">
              {['Sans formation', 'Données sécurisées', 'Support réactif'].map(f => (
                <span key={f} className="flex items-center gap-1.5 text-sm text-slate-600">
                  <CheckCircle className="w-4 h-4 text-purple-600 shrink-0" />
                  {f}
                </span>
              ))}
            </motion.div>

            {/* Social proof counters */}
            <motion.div variants={itemV} className="mt-10 grid grid-cols-3 gap-6 max-w-md">
              {[
                { v: 500, suf: '+',  l: 'Entreprises' },
                { v: 12,  suf: 'k+', l: 'Factures' },
                { v: 99,  suf: '%',  l: 'Satisfaction' },
              ].map(s => (
                <div key={s.l}>
                  <div className="text-2xl font-bold bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-500 bg-clip-text text-transparent">
                    <Counter to={s.v} suffix={s.suf} />
                  </div>
                  <div className="text-xs text-slate-500 mt-0.5">{s.l}</div>
                </div>
              ))}
            </motion.div>
          </motion.div>

          {/* ── Signup form — tilt + glow ─────────────────── */}
          <motion.div
            initial={{ opacity: 0, scale: 0.94, y: 30 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            transition={{ duration: 0.7, delay: 0.3, ease: [0.22, 1, 0.36, 1] }}
          >
            <TiltCard>
              <div className="absolute -inset-2 bg-[linear-gradient(135deg,#6366f1,#a855f7,#ec4899)] rounded-[28px] blur-xl opacity-30 animate-gradient-pan bg-[length:200%_200%]" />
              <div className="relative bg-white/90 backdrop-blur-xl border border-white rounded-3xl p-8 shadow-2xl shadow-purple-500/20">
                <div className="flex items-center gap-2 mb-1">
                  <Sparkles className="w-4 h-4 text-purple-600" />
                  <h2 className="text-xl font-bold text-slate-900">Créer mon compte gratuit</h2>
                </div>
                <p className="text-slate-500 text-sm mb-6">Prêt en 60 secondes</p>

                <form onSubmit={handleSubmit} className="space-y-4">
                  <div className="grid sm:grid-cols-2 gap-3">
                    <InputField label="Votre prénom *" value={name} setValue={setName} placeholder="Ahmed" required />
                    <InputField label="Nom de l'entreprise" value={company} setValue={setCompany} placeholder="Mon Entreprise" />
                  </div>
                  <InputField label="Email *" value={email} setValue={setEmail} placeholder="vous@email.com" type="email" required />
                  <InputField label="Mot de passe *" value={password} setValue={setPassword} placeholder="8 caractères minimum" type="password" required />

                  <AnimatePresence>
                    {error && (
                      <motion.div
                        initial={{ opacity: 0, height: 0, y: -8 }}
                        animate={{ opacity: 1, height: 'auto', y: 0 }}
                        exit={{ opacity: 0, height: 0 }}
                        className="flex items-center gap-2 bg-rose-50 border border-rose-200 rounded-lg px-3 py-2 text-sm text-rose-700"
                      >
                        <AlertCircle className="w-4 h-4 shrink-0" />
                        {error}
                      </motion.div>
                    )}
                  </AnimatePresence>

                  <motion.button
                    type="submit"
                    disabled={loading}
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    className="group relative w-full overflow-hidden bg-[linear-gradient(135deg,#6366f1,#a855f7,#ec4899)] bg-[length:200%_200%] animate-gradient-pan disabled:opacity-60 text-white font-semibold py-3.5 rounded-xl text-sm transition-all shadow-lg shadow-purple-500/30 flex items-center justify-center gap-2"
                  >
                    <span className="absolute inset-0 bg-white/20 translate-x-[-120%] group-hover:translate-x-[120%] transition-transform duration-700 skew-x-[-20deg]" />
                    {loading ? (
                      <><Loader2 className="w-4 h-4 animate-spin" /> Création en cours...</>
                    ) : (
                      <>Créer mon compte gratuit <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" /></>
                    )}
                  </motion.button>
                </form>

                <p className="text-center text-xs text-slate-500 mt-4">
                  Pas de carte bancaire · Annulable à tout moment
                </p>
              </div>
            </TiltCard>
          </motion.div>
        </motion.div>

        {/* Trusted-by marquee */}
        <div className="relative border-y border-slate-200/70 bg-white/50 backdrop-blur py-5 overflow-hidden">
          <div className="flex animate-marquee whitespace-nowrap">
            {[...Array(2)].flatMap((_, i) =>
              ['Sans Excel', 'PWA Offline', 'Multi-tenant', 'IA Cashflow', 'RBAC', '4 langues', 'Cmd + K', 'Automatisations', 'PDF pro', 'Mobile Ready']
                .map((t, j) => (
                  <span key={`${i}-${j}`} className="mx-8 text-sm font-medium text-slate-400 flex items-center gap-2">
                    <Sparkles className="w-3.5 h-3.5 text-purple-400" /> {t}
                  </span>
                ))
            )}
          </div>
        </div>
      </section>

      {/* ── Problèmes ───────────────────────────────────────── */}
      <motion.section
        variants={containerV}
        initial="hidden"
        whileInView="show"
        viewport={{ once: true, margin: '-10% 0px' }}
        className="py-20 bg-white"
      >
        <div className="max-w-6xl mx-auto px-6">
          <motion.p variants={itemV} className="text-center text-slate-500 text-sm uppercase tracking-wider mb-10">
            Vous reconnaissez-vous ?
          </motion.p>
          <div className="grid md:grid-cols-3 gap-6">
            {[
              { Icon: FileSpreadsheet, title: 'Excel pour tout',    desc: 'Des fichiers partout, des versions incohérentes, des erreurs qui coûtent cher.',     bg: 'from-rose-50 to-rose-100/50',    border: 'border-rose-200/60',    iconBg: 'bg-rose-100',   iconColor: 'text-rose-600'   },
              { Icon: Clock,            title: 'Factures manuelles', desc: 'Vous perdez des heures à copier-coller les mêmes informations pour chaque client.', bg: 'from-amber-50 to-amber-100/50',  border: 'border-amber-200/60',   iconBg: 'bg-amber-100',  iconColor: 'text-amber-600'  },
              { Icon: Wallet,           title: 'Paiements oubliés',  desc: 'Vous courez après les impayés. GestiQ envoie un email de rappel automatique avec lien de paiement — vos clients règlent en un clic.',  bg: 'from-indigo-50 to-indigo-100/50', border: 'border-indigo-200/60', iconBg: 'bg-indigo-100', iconColor: 'text-indigo-600' },
            ].map(p => (
              <motion.div
                key={p.title}
                variants={itemV}
                whileHover={{ y: -6, scale: 1.01 }}
                className={`bg-gradient-to-br ${p.bg} border ${p.border} rounded-2xl p-7 shadow-sm hover:shadow-xl transition-shadow`}
              >
                <div className={`w-12 h-12 rounded-xl ${p.iconBg} flex items-center justify-center mb-4 shadow-sm animate-float-slow`}>
                  <p.Icon className={`w-6 h-6 ${p.iconColor}`} strokeWidth={2} />
                </div>
                <h3 className="font-semibold text-slate-900 mb-2 text-lg">{p.title}</h3>
                <p className="text-slate-600 text-sm leading-relaxed">{p.desc}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </motion.section>

      {/* ── Solution ────────────────────────────────────────── */}
      <motion.section
        variants={containerV}
        initial="hidden"
        whileInView="show"
        viewport={{ once: true, margin: '-10% 0px' }}
        className="py-20 bg-slate-50 relative overflow-hidden"
      >
        <div className="absolute top-0 right-0 w-[400px] h-[400px] rounded-full bg-purple-200/40 blur-3xl animate-blob" />

        <div className="max-w-6xl mx-auto px-6 relative">
          <motion.h2 variants={itemV} className="text-3xl lg:text-4xl font-bold text-slate-900 text-center mb-2">
            GestiQ règle ça en{' '}
            <span className="bg-gradient-to-r from-indigo-600 via-purple-600 to-pink-500 bg-clip-text text-transparent">
              3 modules
            </span>
          </motion.h2>
          <motion.p variants={itemV} className="text-slate-500 text-center text-sm mb-14">
            Pas de configuration. Pas de formation. Utilisable dès la première minute.
          </motion.p>

          <div className="grid md:grid-cols-3 gap-6">
            {[
              { icon: Users,      title: 'Clients',   desc: 'Centralisez tous vos clients en un seul endroit. Historique, contacts, notes — tout accessible en un clic.', iconBg: 'bg-indigo-100',  iconColor: 'text-indigo-600',  ring: 'from-indigo-500 to-purple-500' },
              { icon: FileText,   title: 'Factures',  desc: 'Créez et envoyez des factures professionnelles en moins de 2 minutes. PDF prêt à envoyer.',                 iconBg: 'bg-rose-100',    iconColor: 'text-rose-600',    ring: 'from-rose-500 to-pink-500' },
              { icon: CreditCard, title: 'Paiements', desc: 'Suivez ce qui est payé, ce qui est en attente. Sachez exactement où en est votre trésorerie.',              iconBg: 'bg-emerald-100', iconColor: 'text-emerald-600', ring: 'from-emerald-500 to-teal-500' },
            ].map(f => {
              const Icon = f.icon
              return (
                <motion.div
                  key={f.title}
                  variants={itemV}
                  whileHover={{ y: -8 }}
                  className="group relative"
                >
                  <div className={`absolute -inset-[2px] bg-gradient-to-br ${f.ring} rounded-[26px] opacity-0 group-hover:opacity-100 blur transition-opacity duration-500`} />
                  <div className="relative bg-white border border-slate-200 rounded-3xl p-7 shadow-sm group-hover:shadow-2xl transition-shadow">
                    <motion.div
                      whileHover={{ rotate: [0, -10, 10, 0] }}
                      transition={{ duration: 0.5 }}
                      className={`w-14 h-14 rounded-2xl ${f.iconBg} flex items-center justify-center mb-5`}
                    >
                      <Icon className={`w-7 h-7 ${f.iconColor}`} />
                    </motion.div>
                    <h3 className="font-bold text-slate-900 mb-2 text-xl">{f.title}</h3>
                    <p className="text-slate-600 text-sm leading-relaxed">{f.desc}</p>
                  </div>
                </motion.div>
              )
            })}
          </div>
        </div>
      </motion.section>

      {/* ── Full Features Grid ──────────────────────────────── */}
      <motion.section
        variants={containerV}
        initial="hidden"
        whileInView="show"
        viewport={{ once: true, margin: '-10% 0px' }}
        className="py-24 bg-white relative overflow-hidden"
      >
        <div className="absolute -top-40 left-1/2 -translate-x-1/2 w-[800px] h-[800px] rounded-full bg-gradient-to-br from-indigo-200/30 via-purple-200/30 to-pink-200/30 blur-3xl" />

        <div className="max-w-6xl mx-auto px-6 relative">
          <div className="text-center mb-16">
            <motion.div variants={itemV} className="inline-flex items-center gap-2 bg-white border border-purple-200/70 rounded-full px-3 py-1 text-xs font-medium text-purple-700 mb-4 shadow-sm">
              <Sparkles className="w-3 h-3" />
              Fonctionnalités principales
            </motion.div>
            <motion.h2 variants={itemV} className="text-3xl lg:text-5xl font-bold text-slate-900 mb-4 tracking-tight">
              Tout ce dont vous avez besoin,<br/>
              <span className="bg-[linear-gradient(135deg,#6366f1,#a855f7,#ec4899,#a855f7,#6366f1)] bg-[length:300%_auto] animate-gradient-pan bg-clip-text text-transparent">
                au même endroit
              </span>
            </motion.h2>
            <motion.p variants={itemV} className="text-slate-600 max-w-2xl mx-auto text-lg">
              10 modules puissants qui remplacent vos 10 outils dispersés.
            </motion.p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
            {[
              { icon: Users,      emoji: '👥', title: 'Gestion clients & CRM',       iconBg: 'bg-indigo-100',  iconColor: 'text-indigo-600',  ring: 'from-indigo-500 to-purple-500',   features: ['Fiche complète : infos, historique, factures, paiements','Pipeline commercial visuel (Drag & Drop)',"Journal d'activité : appels, réunions, messages",'Abonnements récurrents avec renouvellement auto'] },
              { icon: CreditCard, emoji: '💰', title: 'Facturation & Finances',       iconBg: 'bg-emerald-100', iconColor: 'text-emerald-600', ring: 'from-emerald-500 to-teal-500',     features: ['Devis professionnels + génération PDF','Factures intelligentes (conversion en 1 clic)','Bons de commande & contrats numériques',"Registre des chèques avec dates d'échéance"] },
              { icon: Brain,      emoji: '📈', title: 'Intelligence & Statistiques',  iconBg: 'bg-purple-100',  iconColor: 'text-purple-600',  ring: 'from-purple-500 to-fuchsia-500',   features: ['Dashboard : CA, bénéfices, prévisions','Prévision de trésorerie sur 90 jours','Détection automatique des anomalies','Conseiller IA pour vos questions business'] },
              { icon: Bell,       emoji: '🔔', title: 'Alertes & Automatisation',     iconBg: 'bg-amber-100',   iconColor: 'text-amber-600',   ring: 'from-amber-500 to-orange-500',     features: ['Centre de notifications intelligent','6 types de triggers automatiques',"Journal d'exécution de chaque action",'Alertes par priorité (critique/moyen/faible)'] },
              { icon: Shield,     emoji: '👔', title: 'Équipe & Permissions',         iconBg: 'bg-blue-100',    iconColor: 'text-blue-600',    ring: 'from-blue-500 to-indigo-500',      features: ['5 rôles : Admin, Manager, Commercial, Comptable, Viewer','RBAC complet : accès finement contrôlé','Multi-tenant : workspace séparé par entreprise','Journal des activités : qui, quoi, quand'] },
              { icon: Globe,      emoji: '🌐', title: 'Gestion Web',                  iconBg: 'bg-sky-100',     iconColor: 'text-sky-600',     ring: 'from-sky-500 to-blue-500',         features: ['Noms de domaine + alertes de renouvellement','Hébergements web centralisés','Contrats fournisseurs suivis',"Dates d'expiration jamais oubliées"] },
              { icon: Wallet,     emoji: '💼', title: 'Gestion des dépenses',         iconBg: 'bg-rose-100',    iconColor: 'text-rose-600',    ring: 'from-rose-500 to-pink-500',        features: ['Catégories personnalisables','Fournisseurs avec historique des paiements','Import / Export Excel et CSV','Suivi précis des charges'] },
              { icon: Calendar,   emoji: '📅', title: 'Organisation & Productivité',  iconBg: 'bg-fuchsia-100', iconColor: 'text-fuchsia-600', ring: 'from-fuchsia-500 to-pink-500',     features: ['Calendrier intégré (réunions, tâches, échéances)',"Tâches personnelles et d'équipe",'Recherche globale (Cmd+K)','Raccourcis clavier pour la rapidité'] },
              { icon: Smartphone, emoji: '📱', title: 'Mobile & PWA',                 iconBg: 'bg-teal-100',    iconColor: 'text-teal-600',    ring: 'from-teal-500 to-emerald-500',     features: ['Application installable (PWA)','Fonctionne hors ligne','Synchronisation auto au retour du réseau','Interface 100% responsive'] },
              { icon: Palette,    emoji: '🎨', title: 'Expérience utilisateur',       iconBg: 'bg-pink-100',    iconColor: 'text-pink-600',    ring: 'from-pink-500 to-rose-500',        features: ['Dark / Light Mode','Multilingue : Darija, Français, Arabe, Anglais','Onboarding interactif pour nouveaux utilisateurs','Import / Export simples'] },
            ].map(f => {
              const Icon = f.icon
              return (
                <motion.div
                  key={f.title}
                  variants={itemV}
                  whileHover={{ y: -8 }}
                  className="group relative"
                >
                  <div className={`absolute -inset-[2px] bg-gradient-to-br ${f.ring} rounded-[26px] opacity-0 group-hover:opacity-100 blur-md transition-opacity duration-500`} />
                  <div className="relative h-full bg-white border border-slate-200 rounded-3xl p-6 shadow-sm group-hover:shadow-2xl transition-all">
                    <div className="flex items-center gap-3 mb-4">
                      <motion.div
                        whileHover={{ scale: 1.12, rotate: [0, -8, 8, 0] }}
                        transition={{ duration: 0.45 }}
                        className={`w-12 h-12 rounded-xl ${f.iconBg} flex items-center justify-center ${f.iconColor}`}
                      >
                        <Icon className="w-5 h-5" />
                      </motion.div>
                      <div>
                        <div className="text-xs text-slate-500">{f.emoji}</div>
                        <h3 className="font-bold text-slate-900 text-base leading-tight">{f.title}</h3>
                      </div>
                    </div>
                    <ul className="space-y-2">
                      {f.features.map(item => (
                        <li key={item} className="flex items-start gap-2 text-sm text-slate-600">
                          <CheckCircle className={`w-4 h-4 ${f.iconColor} shrink-0 mt-0.5`} />
                          <span>{item}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                </motion.div>
              )
            })}
          </div>
        </div>
      </motion.section>

      {/* ── Highlights strip ────────────────────────────────── */}
      <motion.section
        variants={containerV}
        initial="hidden"
        whileInView="show"
        viewport={{ once: true }}
        className="py-16 bg-slate-50"
      >
        <div className="max-w-6xl mx-auto px-6">
          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {[
              { icon: Languages, label: 'Multilingue',     value: '4 langues',   color: 'indigo' },
              { icon: Moon,      label: 'Mode sombre',     value: 'Dark / Light', color: 'purple' },
              { icon: Command,   label: 'Recherche rapide', value: 'Cmd + K',     color: 'pink' },
              { icon: LockIcon,  label: 'Données',         value: 'Sécurisées',  color: 'emerald' },
            ].map(h => {
              const Icon = h.icon
              const colors: Record<string, string> = {
                indigo:  'bg-indigo-100 text-indigo-600',
                purple:  'bg-purple-100 text-purple-600',
                pink:    'bg-pink-100 text-pink-600',
                emerald: 'bg-emerald-100 text-emerald-600',
              }
              return (
                <motion.div
                  key={h.label}
                  variants={itemV}
                  whileHover={{ y: -4, scale: 1.02 }}
                  className="bg-white border border-slate-200 rounded-2xl p-5 flex items-center gap-4 shadow-sm hover:shadow-lg transition-all"
                >
                  <div className={`w-11 h-11 rounded-xl flex items-center justify-center shrink-0 ${colors[h.color]}`}>
                    <Icon className="w-5 h-5" />
                  </div>
                  <div>
                    <div className="text-xs text-slate-500">{h.label}</div>
                    <div className="text-sm font-semibold text-slate-900">{h.value}</div>
                  </div>
                </motion.div>
              )
            })}
          </div>
        </div>
      </motion.section>

      {/* ── Screenshot ──────────────────────────────────────── */}
      <motion.section
        initial={{ opacity: 0, y: 40 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: '-10% 0px' }}
        transition={{ duration: 0.7 }}
        className="py-20 bg-white border-t border-slate-200"
      >
        <div className="max-w-5xl mx-auto px-6 text-center">
          <h2 className="text-3xl lg:text-4xl font-bold text-slate-900 mb-3">
            Votre tableau de bord en temps réel
          </h2>
          <p className="text-slate-500 text-sm mb-10">Vue d'ensemble claire — chiffres, alertes, tâches</p>
          <motion.div
            initial={{ rotateX: 12, scale: 0.96 }}
            whileInView={{ rotateX: 0, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 1, ease: [0.22, 1, 0.36, 1] }}
            style={{ transformStyle: 'preserve-3d', perspective: 1200 }}
            className="relative rounded-3xl overflow-hidden border border-slate-200 shadow-2xl shadow-purple-500/20"
          >
            <div className="absolute -inset-[2px] bg-[linear-gradient(135deg,#6366f1,#a855f7,#ec4899)] rounded-[26px] blur opacity-30" />
            <div className="relative">
              <img
                src="/dashboard-preview.png"
                alt="GestiQ Dashboard"
                className="w-full object-cover"
                onError={e => { (e.target as HTMLImageElement).style.display = 'none' }}
              />
              <div className="bg-slate-50 p-16 flex items-center justify-center text-slate-400 text-sm hidden only:flex">
                Aperçu du dashboard
              </div>
            </div>
          </motion.div>
        </div>
      </motion.section>

      {/* ── Final CTA ───────────────────────────────────────── */}
      <section className="relative py-24 bg-[linear-gradient(135deg,#6366f1,#a855f7,#ec4899)] bg-[length:200%_200%] animate-gradient-pan overflow-hidden">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_right,_rgba(255,255,255,0.2),_transparent_50%)]" />
        <div
          className="absolute inset-0 opacity-20"
          style={{
            backgroundImage:
              'linear-gradient(rgba(255,255,255,0.15) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.15) 1px, transparent 1px)',
            backgroundSize: '40px 40px',
            maskImage: 'radial-gradient(ellipse at center, black 30%, transparent 70%)',
          }}
        />

        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7 }}
          className="relative max-w-2xl mx-auto px-6 text-center"
        >
          <Zap className="w-10 h-10 text-white mx-auto mb-5 animate-float-slow" />
          <h2 className="text-4xl lg:text-5xl font-bold text-white mb-5 tracking-tight">
            Prêt à gagner du temps <br/>chaque semaine ?
          </h2>
          <p className="text-white/90 mb-10 text-lg">
            Rejoignez des centaines de petites entreprises qui ont arrêté Excel.
          </p>
          <MagneticButton
            onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}
            className="group inline-flex items-center gap-2 bg-white hover:bg-slate-50 text-purple-700 font-semibold px-8 py-4 rounded-2xl text-sm transition-colors shadow-2xl"
          >
            Créer mon compte gratuit
            <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
          </MagneticButton>
          <p className="text-xs text-white/70 mt-4">Sans carte bancaire · Sans engagement</p>
        </motion.div>
      </section>

      {/* ── Footer ──────────────────────────────────────────── */}
      <footer className="border-t border-slate-200 bg-white py-7 text-center text-xs text-slate-500">
        © 2025 GestiQ — Tous droits réservés
      </footer>
    </div>
  )
}

/* ────────────────────────────────────────────────────────────
   Animated input field with focus ring
   ──────────────────────────────────────────────────────────── */
function InputField({
  label, value, setValue, placeholder, type = 'text', required = false,
}: {
  label: string; value: string; setValue: (v: string) => void;
  placeholder: string; type?: string; required?: boolean;
}) {
  return (
    <div className="relative">
      <label className="block text-xs font-semibold text-slate-700 mb-1.5">{label}</label>
      <input
        type={type}
        value={value}
        onChange={e => setValue(e.target.value)}
        placeholder={placeholder}
        required={required}
        className="peer w-full bg-slate-50 border border-slate-200 rounded-xl px-3.5 py-2.5 text-sm text-slate-900 placeholder-slate-400 focus:outline-none focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10 focus:bg-white transition-all"
      />
    </div>
  )
}
