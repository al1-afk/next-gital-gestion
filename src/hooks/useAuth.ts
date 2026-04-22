import { useState, useEffect, useCallback } from 'react'
import { useNavigate } from 'react-router-dom'
import { tokenStore, authApi } from '@/lib/api'
import { logoutAndPurge, purgeClientSession } from '@/lib/session'

interface AuthState {
  loading:      boolean
  isAuthorized: boolean
  tenantSlug:   string | null
  tenantId:     string | null
  userId:       string | null
  email:        string | null
  name:         string | null
  role:         string | null
}

const INITIAL: AuthState = {
  loading:      true,
  isAuthorized: false,
  tenantSlug:   null,
  tenantId:     null,
  userId:       null,
  email:        null,
  name:         null,
  role:         null,
}

function parseJwt(token: string) {
  try {
    return JSON.parse(atob(token.split('.')[1]))
  } catch {
    return null
  }
}

export function useAuth() {
  const navigate = useNavigate()
  const [state, setState] = useState<AuthState>(INITIAL)

  /* On mount: verify existing token */
  useEffect(() => {
    const token = tokenStore.get()
    if (!token) {
      setState({ ...INITIAL, loading: false })
      return
    }
    const payload = parseJwt(token)
    if (!payload || (payload.exp && payload.exp * 1000 < Date.now())) {
      tokenStore.clear()
      setState({ ...INITIAL, loading: false })
      return
    }
    /* Token looks valid — try to confirm with server */
    authApi.me()
      .then(me => {
        setState({
          loading:      false,
          isAuthorized: true,
          tenantSlug:   me.slug,
          tenantId:     payload.tenantId ?? null,
          userId:       me.id,
          email:        me.email,
          name:         me.name,
          role:         me.role,
        })
      })
      .catch(() => {
        tokenStore.clear()
        setState({ ...INITIAL, loading: false })
      })
  }, [])

  const signIn = useCallback(async (
    email:       string,
    password:    string,
    tenantSlug?: string,
  ) => {
    /* Always purge any leftover state from a previous user BEFORE
       writing the new token — prevents cross-user data leakage. */
    await purgeClientSession()

    const data = await authApi.login(email, password, tenantSlug)
    tokenStore.set(data.token)
    const payload = parseJwt(data.token)
    setState({
      loading:      false,
      isAuthorized: true,
      tenantSlug:   data.tenantSlug,
      tenantId:     data.tenantId,
      userId:       payload?.userId ?? payload?.sub ?? null,
      email,
      name:         null,
      role:         data.role,
    })
    navigate(`/${data.tenantSlug}`, { replace: true })
    return data
  }, [navigate])

  const signOut = useCallback(async () => {
    await logoutAndPurge()
    setState({ ...INITIAL, loading: false })
    navigate('/auth', { replace: true })
  }, [navigate])

  return { ...state, signIn, signOut }
}
