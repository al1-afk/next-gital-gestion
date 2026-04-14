import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'

/* ─── Types ──────────────────────────────────────────────────────── */
export type LogType = 'creation' | 'statut' | 'note' | 'edit' | 'appel' | 'email'

export interface ProspectLog {
  id:           string
  prospect_id:  string
  created_at:   string
  type:         LogType
  message:      string
  auteur?:      string | null
}

const TABLE = 'prospect_logs'

/* ─── Mock store ─────────────────────────────────────────────────── */
let mockLogs: ProspectLog[] = [
  // Prospect 1 — Ahmed Benali
  { id: 'l01', prospect_id: '1', created_at: '2026-04-01T10:00:00Z', type: 'creation', message: 'Prospect créé',                                  auteur: 'Said' },
  { id: 'l02', prospect_id: '1', created_at: '2026-04-03T09:30:00Z', type: 'appel',   message: 'Appel de découverte effectué — 18 min',           auteur: 'Said' },
  { id: 'l03', prospect_id: '1', created_at: '2026-04-06T14:10:00Z', type: 'statut',  message: 'Statut : Nouveau → Contacté',                    auteur: 'Said' },
  { id: 'l04', prospect_id: '1', created_at: '2026-04-09T11:00:00Z', type: 'statut',  message: 'Statut : Contacté → Qualifié',                   auteur: 'Said' },
  { id: 'l05', prospect_id: '1', created_at: '2026-04-12T10:00:00Z', type: 'note',    message: 'Note : Intéressé par le pack premium',            auteur: 'Said' },

  // Prospect 2 — Fatima Zahra
  { id: 'l06', prospect_id: '2', created_at: '2026-04-02T09:00:00Z', type: 'creation', message: 'Prospect créé',                                 auteur: 'Said' },
  { id: 'l07', prospect_id: '2', created_at: '2026-04-03T16:00:00Z', type: 'email',   message: 'Email de présentation envoyé',                   auteur: 'Said' },
  { id: 'l08', prospect_id: '2', created_at: '2026-04-05T10:30:00Z', type: 'statut',  message: 'Statut : Nouveau → Contacté',                    auteur: 'Said' },
  { id: 'l09', prospect_id: '2', created_at: '2026-04-05T10:45:00Z', type: 'edit',    message: 'Devis envoyé le 5 avril (note ajoutée)',          auteur: 'Said' },
  { id: 'l10', prospect_id: '2', created_at: '2026-04-07T08:00:00Z', type: 'statut',  message: 'Statut : Contacté → Proposition',                auteur: 'Said' },

  // Prospect 3 — Karim Alaoui
  { id: 'l11', prospect_id: '3', created_at: '2026-04-03T14:00:00Z', type: 'creation', message: 'Prospect créé',                                 auteur: 'Said' },
  { id: 'l12', prospect_id: '3', created_at: '2026-04-04T09:00:00Z', type: 'appel',   message: 'Premier contact téléphonique',                   auteur: 'Said' },
  { id: 'l13', prospect_id: '3', created_at: '2026-04-06T15:30:00Z', type: 'statut',  message: 'Statut : Nouveau → Qualifié',                    auteur: 'Said' },
  { id: 'l14', prospect_id: '3', created_at: '2026-04-08T11:00:00Z', type: 'statut',  message: 'Statut : Qualifié → Proposition',                auteur: 'Said' },
  { id: 'l15', prospect_id: '3', created_at: '2026-04-10T14:00:00Z', type: 'note',    message: 'Note : En cours de négociation prix',            auteur: 'Said' },

  // Prospect 5 — Youssef Tazi (gagné)
  { id: 'l16', prospect_id: '5', created_at: '2026-03-10T08:30:00Z', type: 'creation', message: 'Prospect créé',                                 auteur: 'Said' },
  { id: 'l17', prospect_id: '5', created_at: '2026-03-12T10:00:00Z', type: 'appel',   message: 'Rencontre au salon professionnel',               auteur: 'Said' },
  { id: 'l18', prospect_id: '5', created_at: '2026-03-14T14:00:00Z', type: 'statut',  message: 'Statut : Nouveau → Contacté',                    auteur: 'Said' },
  { id: 'l19', prospect_id: '5', created_at: '2026-03-20T09:00:00Z', type: 'statut',  message: 'Statut : Contacté → Proposition',                auteur: 'Said' },
  { id: 'l20', prospect_id: '5', created_at: '2026-04-01T11:00:00Z', type: 'statut',  message: 'Statut : Proposition → Gagné',                   auteur: 'Said' },
  { id: 'l21', prospect_id: '5', created_at: '2026-04-01T11:05:00Z', type: 'note',    message: 'Contrat signé ✓',                                auteur: 'Said' },

  // Prospect 9 — Rachid El Idrissi
  { id: 'l22', prospect_id: '9', created_at: '2026-04-04T16:00:00Z', type: 'creation', message: 'Prospect créé',                                 auteur: 'Said' },
  { id: 'l23', prospect_id: '9', created_at: '2026-04-05T10:00:00Z', type: 'appel',   message: 'Appel de qualification — demande démo',          auteur: 'Said' },
  { id: 'l24', prospect_id: '9', created_at: '2026-04-06T09:30:00Z', type: 'statut',  message: 'Statut : Nouveau → Qualifié',                    auteur: 'Said' },
]

/* ─── Query key helper ───────────────────────────────────────────── */
function qKey(prospectId: string) {
  return [TABLE, prospectId] as const
}

/* ─── useProspectLogs ────────────────────────────────────────────── */
export function useProspectLogs(prospectId: string | null) {
  return useQuery<ProspectLog[]>({
    queryKey: qKey(prospectId ?? ''),
    enabled:  !!prospectId,
    queryFn: async () => {
      try {
        const { data, error } = await supabase
          .from(TABLE)
          .select('*')
          .eq('prospect_id', prospectId!)
          .order('created_at', { ascending: false })
        if (error) throw error
        return data as ProspectLog[]
      } catch {
        return mockLogs
          .filter(l => l.prospect_id === prospectId)
          .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
      }
    },
    staleTime: 0,
  })
}

/* ─── useAddProspectLog ──────────────────────────────────────────── */
export function useAddProspectLog() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (data: Omit<ProspectLog, 'id' | 'created_at'>) => {
      const entry: ProspectLog = {
        ...data,
        id:         Date.now().toString() + Math.random().toString(36).slice(2),
        created_at: new Date().toISOString(),
      }
      try {
        const { data: res, error } = await supabase.from(TABLE).insert(entry).select().single()
        if (error) throw error
        return res as ProspectLog
      } catch {
        mockLogs = [entry, ...mockLogs]
        return entry
      }
    },
    onSuccess: (log) => {
      qc.setQueryData<ProspectLog[]>(qKey(log.prospect_id), old =>
        [log, ...(old ?? [])].sort(
          (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
        )
      )
    },
  })
}
