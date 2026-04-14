import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Bot, Send, Sparkles, TrendingUp, AlertTriangle, Target, RefreshCw, User, Loader2 } from 'lucide-react'
import { useProspects } from '@/hooks/useProspects'
import { Button } from '@/components/ui/button'
import { formatCurrency } from '@/lib/utils'

const SAMPLE_INSIGHTS = [
  {
    type: 'urgent',
    icon: AlertTriangle,
    title: 'Relances urgentes (3)',
    content: 'Omar Berrada est en Relance 1 depuis 23 jours sans réponse. Karim Alaoui est en négociation depuis 10 jours. Fatima Zahra attend une réponse sur le devis DEV-2026-002 depuis 7 jours.',
    color: 'red',
  },
  {
    type: 'opportunity',
    icon: TrendingUp,
    title: 'Opportunités prioritaires',
    content: "Corp Solutions (25 000 MAD) est en phase de négociation — proposez un avantage pour débloquer la signature avant fin du mois. Hôtel Atlas est un client fidèle — explorez une extension de contrat pour l'été.",
    color: 'emerald',
  },
  {
    type: 'strategy',
    icon: Target,
    title: 'Recommandations stratégiques',
    content: "Votre taux de conversion LinkedIn est de 40% — investissez davantage dans ce canal. Votre pipeline actif représente 78 500 MAD — concentrez-vous sur les 3 prospects en négociation pour maximiser les gains du mois.",
    color: 'blue',
  },
]

interface Message {
  role: 'user' | 'assistant'
  content: string
}

export default function ConseillerIA() {
  const { data: prospects = [] } = useProspects()
  const [messages, setMessages] = useState<Message[]>([
    {
      role: 'assistant',
      content: `Bonjour ! Je suis votre conseiller commercial IA. J'analyse en ce moment votre pipeline de ${prospects.length} prospects avec une valeur totale de ${formatCurrency(prospects.filter(p => !['perdu'].includes(p.statut)).reduce((s, p) => s + (p.valeur_estimee || 0), 0))}.\n\nComment puis-je vous aider aujourd'hui ?`,
    },
  ])
  const [input, setInput] = useState('')
  const [loading, setLoading] = useState(false)

  const QUICK_QUESTIONS = [
    'Quels prospects dois-je relancer en priorité ?',
    'Analyse mon pipeline et donne-moi des recommandations',
    'Quel est mon taux de conversion ce mois ?',
    'Quelles opportunités ne pas manquer ?',
  ]

  const sendMessage = async (text: string) => {
    if (!text.trim()) return
    const userMsg: Message = { role: 'user', content: text }
    setMessages(prev => [...prev, userMsg])
    setInput('')
    setLoading(true)

    // Simulate AI response
    await new Promise(r => setTimeout(r, 1500))
    const responses: Record<string, string> = {
      'relancer': `**Prospects à relancer MAINTENANT :**\n\n1. **Omar Berrada** (Import Export MA) — Relance 1 depuis 23 jours · 18 000 MAD\n   → Email de suivi personnalisé avec nouvelle proposition de valeur\n\n2. **Fatima Zahra** (Agence Digital Plus) — Devis envoyé il y a 7 jours · 8 500 MAD\n   → Appel téléphonique + proposer une démo\n\n3. **Karim Alaoui** (Corp Solutions) — Négociation depuis 10 jours · 25 000 MAD\n   → Proposer une réunion de clôture cette semaine`,
      'pipeline': `**Analyse de votre pipeline :**\n\n📊 **Résumé :** ${prospects.length} prospects · ${formatCurrency(prospects.filter(p => !['perdu'].includes(p.statut)).reduce((s, p) => s + (p.valeur_estimee || 0), 0))} de valeur\n\n✅ **Points forts :**\n- 1 contrat signé (Youssef Tazi · 32 000 MAD)\n- 3 prospects actifs en phase avancée\n\n⚠️ **Points à améliorer :**\n- 3 prospects sans relance récente\n- Taux de conversion LinkedIn à optimiser\n\n🎯 **Priorité :** Fermer Karim Alaoui avant fin du mois`,
      'default': `Basé sur votre activité actuelle, voici mes recommandations :\n\n• **Court terme :** Relancez Omar Berrada et Fatima Zahra cette semaine\n• **Moyen terme :** Développez votre présence LinkedIn pour alimenter le pipeline\n• **Long terme :** Créez un programme de fidélisation pour vos clients existants\n\nAvez-vous besoin d'une analyse plus détaillée sur un point précis ?`,
    }

    const content = text.toLowerCase().includes('relancer') ? responses['relancer']
      : text.toLowerCase().includes('pipeline') || text.toLowerCase().includes('analyse') ? responses['pipeline']
      : responses['default']

    setMessages(prev => [...prev, { role: 'assistant', content }])
    setLoading(false)
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title flex items-center gap-2">
            <Bot className="w-7 h-7 text-blue-400" />
            Conseiller IA Commercial
          </h1>
          <p className="text-muted-foreground text-sm mt-1">Analyse intelligente de votre pipeline CRM</p>
        </div>
        <Button variant="secondary" size="sm" onClick={() => setMessages([{ role: 'assistant', content: `Bonjour ! Nouvelle session de conseil. Comment puis-je vous aider ?` }])}>
          <RefreshCw className="w-4 h-4" /> Nouvelle session
        </Button>
      </div>

      {/* Insights cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {SAMPLE_INSIGHTS.map((insight, i) => (
          <motion.div
            key={i}
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1 }}
            className={`card p-4 border-${insight.color}-500/20 cursor-pointer hover:border-${insight.color}-500/40 transition-all`}
            onClick={() => sendMessage(insight.title)}
          >
            <div className="flex items-center gap-2 mb-2">
              <div className={`w-8 h-8 rounded-lg bg-${insight.color}-500/20 flex items-center justify-center`}>
                <insight.icon className={`w-4 h-4 text-${insight.color}-400`} />
              </div>
              <span className="text-sm font-semibold text-foreground">{insight.title}</span>
            </div>
            <p className="text-xs text-muted-foreground leading-relaxed line-clamp-3">{insight.content}</p>
          </motion.div>
        ))}
      </div>

      {/* Chat */}
      <div className="card overflow-hidden flex flex-col" style={{ height: '500px' }}>
        {/* Messages */}
        <div className="flex-1 overflow-y-auto p-4 space-y-4">
          {messages.map((msg, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 8 }}
              animate={{ opacity: 1, y: 0 }}
              className={`flex gap-3 ${msg.role === 'user' ? 'flex-row-reverse' : ''}`}
            >
              <div className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${msg.role === 'assistant' ? 'bg-[#378ADD]' : 'bg-[#3a526b]'}`}>
                {msg.role === 'assistant' ? <Bot className="w-4 h-4 text-white" /> : <User className="w-4 h-4 text-white" />}
              </div>
              <div className={`max-w-[75%] px-4 py-3 rounded-2xl text-sm leading-relaxed ${msg.role === 'assistant' ? 'bg-muted text-foreground rounded-tl-sm' : 'bg-[#378ADD] text-white rounded-tr-sm'}`}>
                <pre className="whitespace-pre-wrap font-sans">{msg.content}</pre>
              </div>
            </motion.div>
          ))}
          {loading && (
            <div className="flex gap-3">
              <div className="w-8 h-8 rounded-full bg-[#378ADD] flex items-center justify-center">
                <Bot className="w-4 h-4 text-white" />
              </div>
              <div className="bg-muted rounded-2xl rounded-tl-sm px-4 py-3">
                <div className="flex items-center gap-1">
                  <div className="w-2 h-2 bg-blue-400 rounded-full animate-bounce" />
                  <div className="w-2 h-2 bg-blue-400 rounded-full animate-bounce [animation-delay:0.1s]" />
                  <div className="w-2 h-2 bg-blue-400 rounded-full animate-bounce [animation-delay:0.2s]" />
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Quick questions */}
        <div className="px-4 py-2 border-t border-border flex gap-2 overflow-x-auto">
          {QUICK_QUESTIONS.map((q, i) => (
            <button
              key={i}
              onClick={() => sendMessage(q)}
              className="flex-shrink-0 text-xs px-3 py-1.5 rounded-full bg-muted text-muted-foreground hover:bg-[#378ADD]/10 hover:text-[#378ADD] border border-border hover:border-[#378ADD]/40 transition-all"
            >
              {q}
            </button>
          ))}
        </div>

        {/* Input */}
        <div className="p-4 border-t border-border flex gap-3">
          <input
            value={input}
            onChange={e => setInput(e.target.value)}
            onKeyDown={e => e.key === 'Enter' && !e.shiftKey && sendMessage(input)}
            placeholder="Posez une question sur votre pipeline..."
            className="input-field flex-1"
          />
          <Button onClick={() => sendMessage(input)} disabled={!input.trim() || loading}>
            <Send className="w-4 h-4" />
          </Button>
        </div>
      </div>
    </div>
  )
}
