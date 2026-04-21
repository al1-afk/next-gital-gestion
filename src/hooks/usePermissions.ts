import { useMemo } from 'react'
import { useAuth } from './useAuth'
import { can, getRoleModules, type Role, type Module, type Action } from '@/lib/permissions'

export function usePermissions() {
  const { role: authRole } = useAuth()

  const role: Role = useMemo(() => (authRole ?? 'admin') as Role, [authRole])

  return useMemo(() => ({
    role,
    can: (module: Module, action: Action) => can(role, module, action),
    modules: getRoleModules(role),
    isAdmin: role === 'admin',
    isManager: role === 'manager' || role === 'admin',
  }), [role])
}
