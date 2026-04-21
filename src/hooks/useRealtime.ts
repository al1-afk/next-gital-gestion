import { useEffect, useRef } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'

const IS_DEMO =
  !import.meta.env.VITE_SUPABASE_URL ||
  import.meta.env.VITE_SUPABASE_URL === 'https://placeholder.supabase.co'

// Tables to watch → query keys to invalidate
const WATCHED: Array<{ table: string; queryKey: string[] }> = [
  { table: 'factures',           queryKey: ['factures']            },
  { table: 'prospects',          queryKey: ['prospects']            },
  { table: 'devis',              queryKey: ['devis']                },
  { table: 'alerts',             queryKey: ['alerts']               },
  { table: 'client_subscriptions', queryKey: ['client_subscriptions'] },
  { table: 'team_members',       queryKey: ['team_members']         },
  { table: 'depenses',           queryKey: ['depenses']             },
]

export function useRealtime() {
  const qc = useQueryClient()
  const channelRef = useRef<ReturnType<typeof supabase.channel> | null>(null)

  useEffect(() => {
    // Skip in demo mode — no real Supabase connection
    if (IS_DEMO) return

    const channel = supabase.channel('gestiq-realtime')

    for (const { table, queryKey } of WATCHED) {
      channel.on(
        'postgres_changes' as any,
        { event: '*', schema: 'public', table },
        () => {
          qc.invalidateQueries({ queryKey })
        },
      )
    }

    channel.subscribe()
    channelRef.current = channel

    return () => {
      channel.unsubscribe()
      channelRef.current = null
    }
  }, [qc])
}
