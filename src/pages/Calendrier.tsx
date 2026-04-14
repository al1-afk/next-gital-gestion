import { useState } from 'react'
import { motion } from 'framer-motion'
import { ChevronLeft, ChevronRight, CalendarDays, Plus, Clock, User } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { formatDate } from '@/lib/utils'

const EVENTS = [
  { id: '1', titre: 'RDV Hôtel Atlas', date: '2026-04-15', heure: '10:00', type: 'rdv', client: 'Hôtel Atlas', color: 'blue' },
  { id: '2', titre: 'Démo PharmaTech', date: '2026-04-15', heure: '14:00', type: 'demo', client: 'PharmaTech', color: 'purple' },
  { id: '3', titre: 'Appel Karim Alaoui', date: '2026-04-16', heure: '09:30', type: 'appel', client: 'Corp Solutions', color: 'green' },
  { id: '4', titre: 'Présentation devis', date: '2026-04-18', heure: '11:00', type: 'rdv', client: 'Nadia Mansouri', color: 'yellow' },
  { id: '5', titre: 'Réunion équipe', date: '2026-04-20', heure: '09:00', type: 'interne', color: 'gray' },
  { id: '6', titre: 'Formation CRM', date: '2026-04-22', heure: '14:00', type: 'formation', color: 'cyan' },
]

const DAYS_FR = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']
const MONTHS_FR = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']

const EVENT_COLORS: Record<string, string> = {
  blue: 'bg-blue-500/20 text-blue-300 border-blue-500/30',
  purple: 'bg-purple-500/20 text-purple-300 border-purple-500/30',
  green: 'bg-emerald-500/20 text-emerald-300 border-emerald-500/30',
  yellow: 'bg-yellow-500/20 text-yellow-300 border-yellow-500/30',
  gray: 'bg-muted text-muted-foreground border-border',
  cyan: 'bg-cyan-500/20 text-cyan-300 border-cyan-500/30',
}

function getMonthDays(year: number, month: number) {
  const firstDay = new Date(year, month, 1).getDay()
  const daysInMonth = new Date(year, month + 1, 0).getDate()
  const startOffset = firstDay === 0 ? 6 : firstDay - 1
  return { firstDay: startOffset, daysInMonth }
}

export default function Calendrier() {
  const now = new Date()
  const [currentYear, setCurrentYear] = useState(now.getFullYear())
  const [currentMonth, setCurrentMonth] = useState(now.getMonth())

  const { firstDay, daysInMonth } = getMonthDays(currentYear, currentMonth)

  const prevMonth = () => {
    if (currentMonth === 0) { setCurrentMonth(11); setCurrentYear(y => y - 1) }
    else setCurrentMonth(m => m - 1)
  }
  const nextMonth = () => {
    if (currentMonth === 11) { setCurrentMonth(0); setCurrentYear(y => y + 1) }
    else setCurrentMonth(m => m + 1)
  }

  const getEventsForDay = (day: number) => {
    const dateStr = `${currentYear}-${String(currentMonth + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`
    return EVENTS.filter(e => e.date === dateStr)
  }

  const todayEvents = EVENTS.filter(e => e.date === now.toISOString().slice(0, 10))
  const upcomingEvents = EVENTS.filter(e => e.date >= now.toISOString().slice(0, 10)).slice(0, 5)

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title flex items-center gap-2">
            <CalendarDays className="w-6 h-6 text-blue-400" />
            Calendrier
          </h1>
        </div>
        <Button size="sm"><Plus className="w-4 h-4" /> Nouvel événement</Button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Calendar */}
        <div className="lg:col-span-2 card p-5">
          <div className="flex items-center justify-between mb-5">
            <h2 className="text-lg font-bold text-foreground">{MONTHS_FR[currentMonth]} {currentYear}</h2>
            <div className="flex items-center gap-2">
              <Button variant="ghost" size="icon" onClick={prevMonth}><ChevronLeft className="w-4 h-4" /></Button>
              <Button variant="ghost" size="icon" onClick={nextMonth}><ChevronRight className="w-4 h-4" /></Button>
            </div>
          </div>

          <div className="grid grid-cols-7 gap-1 mb-2">
            {DAYS_FR.map(d => (
              <div key={d} className="text-center text-xs font-medium text-muted-foreground py-1">{d}</div>
            ))}
          </div>

          <div className="grid grid-cols-7 gap-1">
            {Array.from({ length: firstDay }).map((_, i) => (
              <div key={`empty-${i}`} className="aspect-square" />
            ))}
            {Array.from({ length: daysInMonth }).map((_, i) => {
              const day = i + 1
              const dateStr = `${currentYear}-${String(currentMonth + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`
              const events = getEventsForDay(day)
              const isToday = dateStr === now.toISOString().slice(0, 10)

              return (
                <div
                  key={day}
                  className={`aspect-square p-1 rounded-lg text-xs flex flex-col cursor-pointer transition-colors
                    ${isToday ? 'bg-[#378ADD] text-white' : 'hover:bg-muted text-muted-foreground'}
                  `}
                >
                  <span className="font-medium">{day}</span>
                  {events.slice(0, 2).map(e => (
                    <div key={e.id} className={`text-[9px] rounded px-0.5 truncate mt-0.5 ${EVENT_COLORS[e.color]}`}>
                      {e.titre}
                    </div>
                  ))}
                  {events.length > 2 && <span className="text-[9px] text-muted-foreground">+{events.length - 2}</span>}
                </div>
              )
            })}
          </div>
        </div>

        {/* Sidebar */}
        <div className="space-y-4">
          {/* Today */}
          <div className="card p-4">
            <h3 className="section-title mb-3">Aujourd'hui</h3>
            {todayEvents.length > 0 ? (
              <div className="space-y-2">
                {todayEvents.map(e => (
                  <div key={e.id} className={`p-3 rounded-lg border text-sm ${EVENT_COLORS[e.color]}`}>
                    <p className="font-medium">{e.titre}</p>
                    <div className="flex items-center gap-2 mt-1 text-xs opacity-80">
                      <Clock className="w-3 h-3" />
                      <span>{e.heure}</span>
                      {e.client && <><User className="w-3 h-3" /><span>{e.client}</span></>}
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-sm text-muted-foreground">Aucun événement aujourd'hui</p>
            )}
          </div>

          {/* Upcoming */}
          <div className="card p-4">
            <h3 className="section-title mb-3">À venir</h3>
            <div className="space-y-2">
              {upcomingEvents.map(e => (
                <div key={e.id} className="flex items-start gap-3 py-2 border-b border-border last:border-0">
                  <div className={`w-2 h-2 rounded-full mt-1.5 flex-shrink-0 bg-${e.color}-400`} />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-foreground truncate">{e.titre}</p>
                    <p className="text-xs text-muted-foreground">{formatDate(e.date)} · {e.heure}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
