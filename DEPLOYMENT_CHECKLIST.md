# DEPLOYMENT CHECKLIST — GestiQ multi-tenant

À cocher AVANT chaque déploiement en production.

## 1. Environnement — variables OBLIGATOIRES

- [ ] `JWT_SECRET` — ≥ 32 caractères, aléatoire cryptographique
      (`openssl rand -hex 64`). Le serveur refuse de démarrer sinon.
- [ ] `JWT_REFRESH_SECRET` — idem, **différent** de `JWT_SECRET`.
- [ ] `PG_HOST`, `PG_PORT`, `PG_DATABASE`, `PG_USER`, `PG_PASSWORD` —
      pointent sur la base prod, utilisateur `gestiq_api`.
- [ ] `CORS_ORIGINS` — liste stricte, pas de wildcard, pas de
      `localhost` en prod.
- [ ] `NODE_ENV=production` — active HSTS, masque les 500 DB,
      force HTTPS sur le refresh cookie.
- [ ] `VITE_API_URL` — URL publique de l'API Express (HTTPS).

## 2. Base de données — invariants

- [ ] Migrations `001` → `012` appliquées dans l'ordre.
- [ ] `SELECT rolname, rolsuper, rolbypassrls FROM pg_roles WHERE
      rolname='gestiq_api';` → `rolsuper=false`, `rolbypassrls=false`.
- [ ] `SELECT tablename, COUNT(*) FROM pg_policies
      WHERE schemaname='public' GROUP BY tablename;` → **chaque
      table métier a ≥ 4 policies**.
- [ ] Vérifier qu'aucune table n'a `tenant_id IS NULL` :
      ```sql
      DO $$ DECLARE t text; n int; BEGIN
        FOR t IN SELECT _gestiq_business_tables() LOOP
          EXECUTE format('SELECT COUNT(*) FROM %I WHERE tenant_id IS NULL', t) INTO n;
          IF n > 0 THEN RAISE WARNING '% has % NULL tenant_id', t, n; END IF;
        END LOOP;
      END $$;
      ```
- [ ] Backup complet pris juste avant la mise en prod.
- [ ] Postgres `ssl = on` si la DB est distante.

## 3. Tests automatisés

- [ ] `npm run lint` → 0 warning.
- [ ] `npm run build` → succès (typage).
- [ ] Terminal 1 : `npm run server` (pointant sur une DB de test).
- [ ] Terminal 2 : `npm run test:tenant` → **7 tests verts** :
  - [ ] 1. Isolation basique
  - [ ] 2. GET cross-tenant → 404
  - [ ] 3. UPDATE cross-tenant → 404 + ressource intacte
  - [ ] 4. DELETE cross-tenant → 404 + ligne conservée
  - [ ] 5. Forge de `tenant_id` ignorée
  - [ ] 6. RBAC viewer bloqué sur DELETE
  - [ ] 7. CASCADE : supprimer tenant A efface ses données, B intact
- [ ] Exécuter à nouveau `npm run test:tenant` contre la staging finale.

## 4. Smoke tests manuels (staging)

- [ ] Créer 2 workspaces différents (A et B) avec 2 utilisateurs
      distincts.
- [ ] Dans A, créer 2 clients + 1 facture.
- [ ] Se connecter en B dans un **autre navigateur / fenêtre privée** :
      listes vides.
- [ ] Dans le même navigateur, déconnecter A puis se connecter en B :
      **listes vides** (vérifier IndexedDB vidée, localStorage scopée).
- [ ] Tenter d'accéder à `/<slugB>/clients/<id-client-A>` avec le token
      de B → 404 rendu par le fetch, pas de fuite.
- [ ] Modifier l'URL vers `/<slugA>/clients` avec un token de B → le
      `ProtectedRoute` redirige vers `/<slugB>/clients`.

## 5. Sécurité en production

- [ ] HTTPS end-to-end, certificat valide, HSTS actif.
- [ ] Refresh cookie `httpOnly`, `secure`, `sameSite=strict` vérifié
      dans les DevTools.
- [ ] Rate-limit `authLimiter` (10 tentatives / 15 min) observable.
- [ ] Pas de secret en clair dans les logs (`grep -i secret logs/…`).
- [ ] `helmet` envoie bien les headers CSP / HSTS (tester avec
      `curl -I https://api.example.com`).

## 6. Procédure de rollback

1. Révoquer la release applicative précédente (re-déployer l'image
   d'avant).
2. **NE PAS rollback la migration 012** sauf investigation —
   l'aborter ne laisserait que des WARNING, la DB reste safe.
3. Si compromission suspectée :
   ```sql
   UPDATE refresh_tokens SET revoked = true;
   ```
   (force tous les utilisateurs à se reconnecter).
4. Tourner `JWT_SECRET` + `JWT_REFRESH_SECRET` si fuite probable,
   redéployer, tous les tokens existants deviennent invalides.
