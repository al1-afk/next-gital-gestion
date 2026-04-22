# CORRECTIONS — Audit multi-tenancy GestiQ

Date : 2026-04-22 · Branche : `main`

Résumé des corrections appliquées après l'audit des 6 phases. Pour la
vue d'ensemble architecturale, voir [ARCHITECTURE_TENANT.md](ARCHITECTURE_TENANT.md).
Pour la checklist avant déploiement, voir
[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md).

---

## 1. Backend — durcissement (auth, RBAC, erreurs)

**[server/middleware/auth.ts](server/middleware/auth.ts)**
- Refus au démarrage en production si `JWT_SECRET` ou `JWT_REFRESH_SECRET`
  est absent ou < 32 caractères (fonction `loadSecret`). Fallback dev
  conservé pour ne pas bloquer le mode local.
- `ROLE_RANK` étendu à `admin/manager/commercial/comptable/viewer`
  (aligné avec `src/lib/permissions.ts`) ; le typage `Role` est exporté
  pour les routes.

**[server/middleware/rbac.ts](server/middleware/rbac.ts)** (nouveau)
- Matrice ACL `table × action × role` (une ligne par table CRUD) qui
  miroir côté serveur le `ROLE_PERMISSIONS` du frontend.
- Middleware `tableRbac` branché sur `/:table` — toute requête CRUD
  sans permission retourne 403 avant de toucher la DB.

**[server/routes/crud.ts](server/routes/crud.ts)**
- Ajout de `personal_tasks` à `ALLOWED_TABLES`.
- Montage du middleware `tableRbac`.
- En production, les 500 ne fuitent plus le détail Postgres (`err.code`,
  `err.message`, `err.detail`) — un simple `{ error: 'Erreur serveur' }`
  est renvoyé ; les détails restent dans les logs serveur.

## 2. DB — safety-net

**[supabase/migrations/012_tenant_isolation_safety_net.sql](supabase/migrations/012_tenant_isolation_safety_net.sql)** (nouvelle migration)
- **Abort si `gestiq_api` est SUPERUSER ou BYPASSRLS** : empêche silencieusement
  que toutes les policies soient contournées.
- Crée/retrofit la table `personal_tasks` (absente de 007) avec
  `tenant_id NOT NULL + FK CASCADE + RLS FORCE + 4 policies + trigger
  d'immuabilité`.
- Sweep final : chaque business table doit avoir `tenant_id NOT NULL`,
  aucune ligne NULL, RLS ENABLE + FORCE, ≥ 4 policies. Sinon EXCEPTION.
- Idempotent, transactionnel.

## 3. Frontend — logout complet

**[src/lib/queryClient.ts](src/lib/queryClient.ts)** (nouveau)
- Singleton exportable du QueryClient TanStack, réutilisé par
  `purgeClientSession()`.

**[src/lib/session.ts](src/lib/session.ts)** (nouveau)
- `purgeClientSession()` — vide token, React Query cache, localStorage
  (prefixes `gestiq_`, `alerts_read_`, `automation_`), sessionStorage,
  IndexedDB.
- `logoutAndPurge()` — appelle `/api/auth/logout` (révocation refresh
  token côté serveur) PUIS purge.

**[src/hooks/useAuth.ts](src/hooks/useAuth.ts)**
- `signIn` appelle `purgeClientSession()` AVANT d'écrire le nouveau
  token (élimine la contamination cross-user).
- `signOut` → `logoutAndPurge()` (était : simple `localStorage.removeItem`).

**[src/lib/api.ts](src/lib/api.ts)**
- En cas d'échec du refresh token, ou sur les codes
  `TOKEN_REUSE/NO_REFRESH/INVALID_REFRESH`, déclenche
  `purgeClientSession()` avant la redirection vers `/auth`.
- Export `authApi.logout`.

## 4. Frontend — isolation du cache (queryKeys + IndexedDB)

**[src/lib/authToken.ts](src/lib/authToken.ts)** (nouveau)
- `currentTenantIdForCache()` décode le JWT et renvoie le tenantId,
  ou `'__anon__'` — utilisable HORS React (Dexie, interceptors).

**Tous les hooks data — queryKey scopé par tenant** :
- `src/hooks/useClients.ts`, `useProspects.ts`, `useDevis.ts`,
  `useFactures.ts`, `usePaiements.ts`, `useDepenses.ts`, `useTeam.ts`,
  `useClientSubscriptions.ts`.
- Pattern : `queryKey: [KEY, currentTenantIdForCache()]`.
- `invalidateQueries({ queryKey: [KEY] })` continue de fonctionner
  (TanStack Query matche par préfixe).

**[src/lib/offline/db.ts](src/lib/offline/db.ts)**
- Nom de la base Dexie dynamique : `gestiq_offline_<tenantId>` →
  chaque tenant a SA propre IndexedDB.
- Proxy `offlineDB` qui ré-ouvre la bonne DB au premier accès après
  changement de tenant (fermeture propre de l'ancienne).
- Fonction `deleteAllTenantDatabases()` qui supprime toutes les bases
  `gestiq_offline_*` du navigateur (appelée par `purgeClientSession`).

**[src/hooks/useAlerts.ts](src/hooks/useAlerts.ts)**,
**[src/hooks/useAutomations.ts](src/hooks/useAutomations.ts)**
- Clés localStorage scopées par tenant
  (`gestiq_alerts_read_<tenantId>`, `automation_rules_<tenantId>`,
  `automation_logs_<tenantId>`).

## 5. Frontend — validation URL et suppression du fallback démo

**[src/components/auth/ProtectedRoute.tsx](src/components/auth/ProtectedRoute.tsx)**
- Nouveau garde : si `tenantSlug` d'URL ≠ `tenantSlug` du JWT, redirige
  silencieusement vers la bonne URL. Évite le symptôme
  « je vois les données de A sous l'URL de B ».

**[src/contexts/TenantContext.tsx](src/contexts/TenantContext.tsx)**
- Suppression de `DEMO_TENANT` et `isDemoMode`. Un slug inconnu est
  désormais un état d'erreur explicite (`error: 'Workspace introuvable'`)
  — plus d'injection silencieuse d'un `tenant_id = 000…001` qui
  pouvait masquer un échec de résolution.
- `useTenantId()` retourne `string | null` et lit en fallback le JWT
  (jamais une valeur de démo).

**[src/hooks/useTenant.ts](src/hooks/useTenant.ts)** (réécrit)
- Toutes les opérations membres/paramètres passent désormais par
  l'API Express (`/api/tenants/*`). Suppression des 3 RPC Supabase
  morts (`get_my_tenant_role`, `invite_tenant_member`,
  `create_tenant_with_owner`).

## 6. Tests automatisés anti-fuite

**[tests/tenant-isolation.test.ts](tests/tenant-isolation.test.ts)** (nouveau) — 7 scénarios :

| # | Test | Assertion |
|---|------|-----------|
| 1 | Isolation basique | B voit 0 client de A |
| 2 | GET cross-tenant par id | 404 (pas 403) |
| 3 | UPDATE cross-tenant | 404 + ressource non modifiée |
| 4 | DELETE cross-tenant | 404 + ligne conservée |
| 5 | Forge de `tenant_id` en body | Serveur ignore le body |
| 6 | RBAC viewer DELETE | 403 + ligne conservée |
| 7 | CASCADE delete tenant | Toutes les lignes de A effacées, B intact |

Script : `npm run test:tenant` (nécessite serveur dev + Postgres lancés).

---

## Fichiers modifiés / créés

```
server/middleware/auth.ts           modifié
server/middleware/rbac.ts           nouveau
server/routes/crud.ts               modifié
supabase/migrations/012_…sql        nouvelle migration
src/App.tsx                         modifié (import queryClient)
src/lib/api.ts                      modifié
src/lib/authToken.ts                nouveau
src/lib/queryClient.ts              nouveau
src/lib/session.ts                  nouveau
src/lib/offline/db.ts               modifié
src/hooks/useAuth.ts                modifié
src/hooks/useAlerts.ts              modifié
src/hooks/useAutomations.ts         modifié
src/hooks/useClients.ts             modifié
src/hooks/useDepenses.ts            modifié
src/hooks/useDevis.ts               modifié
src/hooks/useFactures.ts            modifié
src/hooks/usePaiements.ts           modifié
src/hooks/useProspects.ts           modifié
src/hooks/useTeam.ts                modifié
src/hooks/useClientSubscriptions.ts modifié
src/hooks/useTenant.ts              réécrit (plus de supabase)
src/contexts/TenantContext.tsx      modifié (plus de démo fallback)
src/components/auth/ProtectedRoute.tsx modifié (validation slug)
tests/tenant-isolation.test.ts      nouveau
package.json                        nouveau script test:tenant
```

## Ce qui n'a PAS été modifié (intentionnellement)

- **Schéma DB des tables existantes** — les migrations 001-010 ont déjà
  tout retrofité (tenant_id NOT NULL, RLS FORCE, policies, triggers).
  Seule `personal_tasks` a été ajoutée via 012.
- **La ligne `owner_id` de tenants** — infra, garde sa FK vers `users`.
- **`login_attempts` / `refresh_tokens` / `password_reset_codes`** —
  tables d'infra, isolées par `user_id`/IP/hash, pas par tenant.
- **`useRealtime.ts`** — dead code gated par `IS_DEMO`, non nuisible ;
  un futur retrofit Express-SSE serait un travail séparé.
