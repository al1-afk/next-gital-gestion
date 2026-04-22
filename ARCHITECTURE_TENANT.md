# ARCHITECTURE_TENANT — Comment fonctionne l'isolation multi-tenant

Document vivant. À lire avant de toucher à un hook data, une route
CRUD, ou le schéma DB. Si tu modifies l'un des 3 niveaux d'isolation
ci-dessous, **mets à jour ce document**.

---

## 1. Principe fondateur

> Une requête DB ne peut pas s'exécuter sans filtre `tenant_id`.

L'isolation s'applique à **3 niveaux indépendants** (défense en
profondeur). Si l'un saute, les deux autres continuent de protéger.

```
┌────────────────────────────────────────────────────────────┐
│  Navigateur                                                │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Niveau 0 : UI / cache client                       │    │
│  │ - queryKey: [table, tenantId]                      │    │
│  │ - IndexedDB: gestiq_offline_<tenantId>             │    │
│  │ - localStorage: gestiq_*_<tenantId>                │    │
│  │ - ProtectedRoute: URL slug ≡ JWT slug              │    │
│  └────────────────────────────────────────────────────┘    │
└──────────────────────────┬─────────────────────────────────┘
                           │ JWT { userId, tenantId, role }
┌──────────────────────────▼─────────────────────────────────┐
│ Niveau 1 : Express (server/)                               │
│ - requireAuth → vérifie signature + expiration             │
│ - tableRbac   → matrice role × table × action (403 si ko)  │
│ - tenantQuery → BEGIN; SET LOCAL app.current_tenant = …;  │
│                 <SQL> ; COMMIT                             │
└──────────────────────────┬─────────────────────────────────┘
                           │ pg_connect(user=gestiq_api)
┌──────────────────────────▼─────────────────────────────────┐
│ Niveau 2 : PostgreSQL                                      │
│ - Colonne tenant_id NOT NULL + FK CASCADE                  │
│ - RLS FORCE + 4 policies SELECT/INSERT/UPDATE/DELETE       │
│   USING (tenant_id = current_tenant_id())                  │
│ - Trigger prevent_tenant_id_change (immuable)              │
│ - Rôle gestiq_api : NOSUPERUSER, NOBYPASSRLS (vérifié 012) │
└────────────────────────────────────────────────────────────┘
```

## 2. Le JWT est la source de vérité

- `server/middleware/auth.ts` signe un access token HS256 de 15 min
  qui porte `{ userId, email, tenantId, role }`.
- Le `tenantId` est choisi au **login** (lookup dans `tenant_users`,
  option `tenantSlug` au body) et ne peut pas être modifié par un
  autre endpoint.
- Côté client, `src/lib/authToken.ts` décode le JWT uniquement pour
  nommer les caches (queryKey, IndexedDB) — la signature n'est pas
  vérifiée ici, le serveur reste l'unique garant.

**Règle d'or :**
`const tenantId = req.user!.tenantId`  — TOUJOURS.
`const tenantId = req.body.tenant_id`  — JAMAIS.

## 3. Comment une requête CRUD est exécutée

```
Client                            Express                       Postgres
  │  GET /api/clients?…            │                              │
  │  Authorization: Bearer <jwt>   │                              │
  │──────────────────────────────▶│                              │
  │                                │ requireAuth                  │
  │                                │   decode JWT, set req.user   │
  │                                │ tableRbac                    │
  │                                │   canTableAction(role,…)     │
  │                                │ tenantQuery(tenantId, SQL)   │
  │                                │   BEGIN                      │
  │                                │   SET LOCAL "app.current_te…"│──▶│
  │                                │   SELECT * FROM clients …    │──▶│ RLS filtre par tenant_id
  │                                │   COMMIT                     │──▶│
  │                                │◀ rows                        │
  │◀── 200 [rows] ─────────────────│                              │
```

`SET LOCAL` est transactionnel : à la fin du `COMMIT`/`ROLLBACK`, la
variable de session est effacée. La connexion retourne au pool propre,
impossible de contaminer la requête suivante.

## 4. Matrice RBAC (serveur)

Définie dans [server/middleware/rbac.ts](server/middleware/rbac.ts) —
extrait représentatif, voir le fichier pour la liste complète :

| Table                | admin | manager | commercial | comptable | viewer |
|----------------------|:-----:|:-------:|:----------:|:---------:|:------:|
| clients / prospects  | CRUD  | CRUD    | CRU        | R         | R      |
| devis                | CRUD  | CRU     | CRU        | R         | R      |
| factures             | CRUD  | CRU     | CR         | CRUD      | R      |
| paiements            | CRUD  | CRU     | R          | CRUD      | R      |
| depenses / finances  | CRUD  | R       | —          | CRUD      | —      |
| team_members         | CRUD  | R       | —          | R         | —      |
| automation_*         | CRUD  | CRU     | —          | —         | —      |

(C = create · R = read · U = update · D = delete)

La matrice doit rester **cohérente** avec le frontend
`src/lib/permissions.ts` qui cache les boutons correspondants.

## 5. Frontend — pourquoi on scope les caches par tenant

Le bug initial (« tous les users voient les mêmes données ») venait
des caches client qui survivaient au changement d'utilisateur :

- **TanStack Query cache** en mémoire — persiste dans l'onglet.
- **IndexedDB** (`gestiq_offline`) — persiste au fermeture du navigateur.
- **localStorage** (`gestiq_token`, `alerts_read_*`, `automation_*`) — idem.

Un user A qui se déconnecte laissait son cache ; le user B qui se
connectait ensuite voyait brièvement les données de A (le temps du
refetch). Les données restaient lisibles offline via IndexedDB.

**Correctifs appliqués :**

1. `queryKey: [KEY, currentTenantIdForCache()]` — le cache React Query
   est physiquement séparé par tenant. Changer de tenant → 0 hit.
2. Dexie ouvre `gestiq_offline_<tenantId>` — chaque tenant a sa propre
   IndexedDB. Le user B sur le même navigateur n'a accès à rien de A.
3. `purgeClientSession()` dans `src/lib/session.ts` vide tout
   (token + queryClient + localStorage scopé + sessionStorage +
   IndexedDB) sur logout, sur login (pré-clear), et sur échec de
   refresh. Appelé par `useAuth().signIn / signOut` et par
   l'intercepteur 401 de `src/lib/api.ts`.
4. `ProtectedRoute` vérifie que l'URL `:tenantSlug` correspond au
   slug du JWT ; sinon il redirige vers la bonne URL pour éliminer
   toute ambiguïté d'affichage.

## 6. Ajouter une nouvelle table métier — check-list

Quand tu crées une nouvelle table :

1. **Migration SQL** :
   - `tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE`
   - Index `(tenant_id)` et idéalement `(tenant_id, created_at DESC)`
   - Trigger `prevent_tenant_id_change` sur UPDATE OF tenant_id
   - `ENABLE ROW LEVEL SECURITY` + `FORCE ROW LEVEL SECURITY`
   - 4 policies (`rls_select_*`, `rls_insert_*`, `rls_update_*`,
     `rls_delete_*`) avec `tenant_id = current_tenant_id()`
   - `GRANT SELECT, INSERT, UPDATE, DELETE ON <table> TO gestiq_api`

2. **Backend** :
   - Ajouter la table à `ALLOWED_TABLES` dans
     [server/routes/crud.ts](server/routes/crud.ts).
   - Ajouter une entrée dans `TABLE_ACL` de
     [server/middleware/rbac.ts](server/middleware/rbac.ts) (ne PAS
     laisser par défaut : le middleware renvoie 403 si inconnu).

3. **Frontend** :
   - Créer un hook `useXxx.ts` sur le même modèle que `useClients.ts` :
     - `queryKey: ['xxx', currentTenantIdForCache()]`
     - `queryFn: () => xxxApi.list(...)`
     - utilise `tableApi('xxx')` depuis `src/lib/api.ts`.
   - Ne JAMAIS inclure `tenant_id` dans le body d'un `create` —
     le serveur l'écrase.

4. **Tests** :
   - Ajouter le cas à [tests/tenant-isolation.test.ts](tests/tenant-isolation.test.ts)
     si la table porte des données sensibles (ou rendre le test 1
     paramétrique par table).

## 7. Multi-workspace (roadmap)

Le modèle DB supporte un user dans N workspaces (`tenant_users` UNIQUE
`(tenant_id, user_id)`), et le login accepte un `tenantSlug` pour
choisir lequel. En revanche :

- Il n'y a pas d'endpoint `/api/auth/switch-tenant` qui re-signe un
  JWT pour un autre workspace sans remote de mot de passe.
- L'UI n'a pas de switcher de workspace.

Ajouter ces deux éléments ne change RIEN à l'isolation — il suffit de
ré-émettre un JWT avec un `tenantId` différent, tout le reste suit.

## 8. Points d'attention pour la code review

- ✅ Le code appelle `tenantQuery` / `tableApi(...)` — OK.
- ❌ Le code fait `pool.query('SELECT … FROM clients …')` sans
   `SET LOCAL` → RLS tire `current_tenant_id() = NULL` → 0 ligne.
   C'est sûr mais muet ; préfère toujours `tenantQuery`.
- ❌ Le code interpole une valeur user dans `tenant_id = '...'` →
   interdit. Seule source : le JWT via `req.user!.tenantId`.
- ❌ Une route renvoie 403 sur une ressource d'un autre tenant →
   renvoyer 404 (non-disclosure) ; 403 est réservé à
   « authentifié mais pas le bon rôle ».
