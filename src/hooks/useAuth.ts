import { useState, useEffect, useCallback } from 'react'
import { supabase } from '@/lib/supabase'
import type { User, Session } from '@supabase/supabase-js'

const AUTHORIZED_EMAILS = [
  'admin@nextgital.com',
  'owner@nextgital.com',
]

interface AuthState {
  user: User | null
  session: Session | null
  loading: boolean
  isAuthorized: boolean
}

export function useAuth() {
  const [state, setState] = useState<AuthState>({
    user: null,
    session: null,
    loading: true,
    isAuthorized: false,
  })

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      const user = session?.user ?? null
      setState({
        user,
        session,
        loading: false,
        isAuthorized: user ? AUTHORIZED_EMAILS.includes(user.email ?? '') : false,
      })
    })

    // Listen for changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      const user = session?.user ?? null
      setState({
        user,
        session,
        loading: false,
        isAuthorized: user ? AUTHORIZED_EMAILS.includes(user.email ?? '') : false,
      })
    })

    return () => subscription.unsubscribe()
  }, [])

  const signIn = useCallback(async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
    return data
  }, [])

  const signOut = useCallback(async () => {
    await supabase.auth.signOut()
  }, [])

  return { ...state, signIn, signOut }
}
