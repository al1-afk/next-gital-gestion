-- ================================================================
--  GestiQ — Pure PostgreSQL Multi-Tenant Schema (no Supabase)
--  gestiq.com/:slug  →  chaque slug = une entreprise isolée
-- ================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================================================
--  TABLE : users
-- ================================================================
CREATE TABLE IF NOT EXISTS users (
  id            UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  email         TEXT        UNIQUE NOT NULL,
  password_hash TEXT        NOT NULL,
  name          TEXT,
  avatar_url    TEXT,
  is_active     BOOLEAN     DEFAULT TRUE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);

-- ================================================================
--  TABLE : tenants
-- ================================================================
CREATE TABLE IF NOT EXISTS tenants (
  id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug            TEXT        UNIQUE NOT NULL,
  name            TEXT        NOT NULL,
  email           TEXT,
  phone           TEXT,
  address         TEXT,
  logo_url        TEXT,
  primary_color   TEXT        DEFAULT '#2563EB',
  plan            TEXT        DEFAULT 'starter' CHECK (plan IN ('starter','pro','enterprise')),
  is_active       BOOLEAN     DEFAULT TRUE,
  trial_ends_at   TIMESTAMPTZ,
  max_users       INT         DEFAULT 5,
  owner_id        UUID        REFERENCES users(id) ON DELETE SET NULL,
  settings        JSONB       DEFAULT '{}',
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE tenants ADD CONSTRAINT IF NOT EXISTS tenants_slug_format
  CHECK (slug ~ '^[a-z0-9][a-z0-9\-]{0,61}[a-z0-9]$');
CREATE INDEX IF NOT EXISTS idx_tenants_slug ON tenants (slug);

-- ================================================================
--  TABLE : tenant_users
-- ================================================================
CREATE TABLE IF NOT EXISTS tenant_users (
  id           UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id    UUID        NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id      UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role         TEXT        DEFAULT 'viewer' CHECK (role IN ('admin','manager','commercial','comptable','viewer')),
  status       TEXT        DEFAULT 'active' CHECK (status IN ('pending','active','revoked')),
  invited_by   UUID        REFERENCES users(id),
  invited_at   TIMESTAMPTZ DEFAULT NOW(),
  accepted_at  TIMESTAMPTZ,
  UNIQUE (tenant_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_tu_tenant ON tenant_users (tenant_id);
CREATE INDEX IF NOT EXISTS idx_tu_user   ON tenant_users (user_id);

-- ================================================================
--  TABLE : clients
-- ================================================================
CREATE TABLE IF NOT EXISTS clients (
  id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id   UUID        NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  nom         TEXT        NOT NULL,
  email       TEXT,
  telephone   TEXT,
  entreprise  TEXT,
  adresse     TEXT,
  ville       TEXT,
  pays        TEXT        DEFAULT 'Maroc',
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_clients_tenant ON clients (tenant_id);

-- ================================================================
--  TABLE : prospects
-- ================================================================
CREATE TABLE IF NOT EXISTS prospects (
  id               UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id        UUID          NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  nom              TEXT          NOT NULL,
  email            TEXT,
  telephone        TEXT,
  entreprise       TEXT,
  statut           TEXT          DEFAULT 'nouveau' CHECK (statut IN ('nouveau','contacte','qualifie','proposition','negocie','gagne','perdu')),
  valeur_estimee   NUMERIC(12,2) DEFAULT 0,
  source           TEXT,
  notes            TEXT,
  responsable      TEXT,
  date_contact     DATE,
  date_relance     DATE,
  created_at       TIMESTAMPTZ   DEFAULT NOW(),
  updated_at       TIMESTAMPTZ   DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_prospects_tenant ON prospects (tenant_id);

-- ================================================================
--  TABLE : devis
-- ================================================================
CREATE TABLE IF NOT EXISTS devis (
  id               UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id        UUID          NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  numero           TEXT          NOT NULL,
  client_id        UUID          REFERENCES clients(id) ON DELETE SET NULL,
  client_nom       TEXT,
  statut           TEXT          DEFAULT 'brouillon' CHECK (statut IN ('brouillon','envoye','accepte','refuse','expire')),
  date_emission    DATE          NOT NULL DEFAULT CURRENT_DATE,
  date_expiration  DATE,
  montant_ht       NUMERIC(12,2) DEFAULT 0,
  tva              NUMERIC(5,2)  DEFAULT 20,
  montant_ttc      NUMERIC(12,2) DEFAULT 0,
  notes            TEXT,
  lignes           JSONB         DEFAULT '[]',
  created_at       TIMESTAMPTZ   DEFAULT NOW(),
  updated_at       TIMESTAMPTZ   DEFAULT NOW(),
  UNIQUE (tenant_id, numero)
);
CREATE INDEX IF NOT EXISTS idx_devis_tenant ON devis (tenant_id);

-- ================================================================
--  TABLE : factures
-- ================================================================
CREATE TABLE IF NOT EXISTS factures (
  id              UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id       UUID          NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  numero          TEXT          NOT NULL,
  client_id       UUID          REFERENCES clients(id) ON DELETE SET NULL,
  client_nom      TEXT,
  client_email    TEXT,
  statut          TEXT          DEFAULT 'brouillon' CHECK (statut IN ('brouillon','envoyee','impayee','partielle','payee','annulee','refusee')),
  date_emission   DATE          NOT NULL DEFAULT CURRENT_DATE,
  date_echeance   DATE,
  montant_ht      NUMERIC(12,2) DEFAULT 0,
  tva             NUMERIC(5,2)  DEFAULT 20,
  montant_ttc     NUMERIC(12,2) DEFAULT 0,
  montant_paye    NUMERIC(12,2) DEFAULT 0,
  notes           TEXT,
  lignes          JSONB         DEFAULT '[]',
  devis_id        UUID          REFERENCES devis(id) ON DELETE SET NULL,
  created_at      TIMESTAMPTZ   DEFAULT NOW(),
  updated_at      TIMESTAMPTZ   DEFAULT NOW(),
  UNIQUE (tenant_id, numero)
);
CREATE INDEX IF NOT EXISTS idx_factures_tenant ON factures (tenant_id);

-- ================================================================
--  TABLE : paiements
-- ================================================================
CREATE TABLE IF NOT EXISTS paiements (
  id              UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id       UUID          NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  facture_id      UUID          REFERENCES factures(id) ON DELETE SET NULL,
  montant         NUMERIC(12,2) NOT NULL,
  mode_paiement   TEXT          DEFAULT 'virement' CHECK (mode_paiement IN ('virement','especes','cheque','carte','autre')),
  date_paiement   DATE          NOT NULL DEFAULT CURRENT_DATE,
  reference       TEXT,
  notes           TEXT,
  created_at      TIMESTAMPTZ   DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_paiements_tenant ON paiements (tenant_id);

-- ================================================================
--  TABLE : depenses
-- ================================================================
CREATE TABLE IF NOT EXISTS depenses (
  id            UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id     UUID          NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  description   TEXT          NOT NULL,
  montant       NUMERIC(12,2) NOT NULL,
  categorie     TEXT          DEFAULT 'autre',
  type          TEXT          DEFAULT 'professionnel' CHECK (type IN ('personnel','professionnel')),
  date_depense  DATE          NOT NULL DEFAULT CURRENT_DATE,
  justificatif  TEXT,
  notes         TEXT,
  created_at    TIMESTAMPTZ   DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_depenses_tenant ON depenses (tenant_id);

-- ================================================================
--  TABLE : contrats
-- ================================================================
CREATE TABLE IF NOT EXISTS contrats (
  id          UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id   UUID          NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  numero      TEXT          NOT NULL,
  client_id   UUID          REFERENCES clients(id) ON DELETE SET NULL,
  client_nom  TEXT,
  titre       TEXT          NOT NULL,
  statut      TEXT          DEFAULT 'brouillon' CHECK (statut IN ('brouillon','actif','expire','resilie','renouvele')),
  date_debut  DATE,
  date_fin    DATE,
  montant     NUMERIC(12,2) DEFAULT 0,
  notes       TEXT,
  created_at  TIMESTAMPTZ   DEFAULT NOW(),
  updated_at  TIMESTAMPTZ   DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_contrats_tenant ON contrats (tenant_id);

-- ================================================================
--  TABLE : produits
-- ================================================================
CREATE TABLE IF NOT EXISTS produits (
  id          UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id   UUID          NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  nom         TEXT          NOT NULL,
  description TEXT,
  prix_ht     NUMERIC(12,2) DEFAULT 0,
  tva         NUMERIC(5,2)  DEFAULT 20,
  unite       TEXT          DEFAULT 'unité',
  categorie   TEXT,
  reference   TEXT,
  actif       BOOLEAN       DEFAULT TRUE,
  created_at  TIMESTAMPTZ   DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_produits_tenant ON produits (tenant_id);

-- ================================================================
--  TABLE : fournisseurs
-- ================================================================
CREATE TABLE IF NOT EXISTS fournisseurs (
  id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id   UUID        NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  nom         TEXT        NOT NULL,
  email       TEXT,
  telephone   TEXT,
  adresse     TEXT,
  categorie   TEXT,
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_fournisseurs_tenant ON fournisseurs (tenant_id);

-- ================================================================
--  TABLE : team_members
-- ================================================================
CREATE TABLE IF NOT EXISTS team_members (
  id             UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id      UUID          NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  nom            TEXT          NOT NULL,
  prenom         TEXT,
  email          TEXT,
  telephone      TEXT,
  poste          TEXT,
  departement    TEXT,
  salaire_base   NUMERIC(12,2) DEFAULT 0,
  date_embauche  DATE,
  statut         TEXT          DEFAULT 'actif' CHECK (statut IN ('actif','inactif','conge')),
  created_at     TIMESTAMPTZ   DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_team_tenant ON team_members (tenant_id);

-- ================================================================
--  TABLE : domaines
-- ================================================================
CREATE TABLE IF NOT EXISTS domaines (
  id                   UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id            UUID          NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  nom                  TEXT          NOT NULL,
  registrar            TEXT,
  date_expiration      DATE          NOT NULL,
  prix_renouvellement  NUMERIC(10,2) DEFAULT 0,
  client_id            UUID          REFERENCES clients(id) ON DELETE SET NULL,
  notes                TEXT,
  created_at           TIMESTAMPTZ   DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_domaines_tenant     ON domaines (tenant_id);
CREATE INDEX IF NOT EXISTS idx_domaines_expiration ON domaines (tenant_id, date_expiration);

-- ================================================================
--  TABLE : hebergements
-- ================================================================
CREATE TABLE IF NOT EXISTS hebergements (
  id               UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id        UUID          NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  nom              TEXT          NOT NULL,
  fournisseur      TEXT,
  date_expiration  DATE,
  prix_mensuel     NUMERIC(10,2) DEFAULT 0,
  client_id        UUID          REFERENCES clients(id) ON DELETE SET NULL,
  notes            TEXT,
  created_at       TIMESTAMPTZ   DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_hebergements_tenant ON hebergements (tenant_id);

-- ================================================================
--  TABLE : cheques_recus
-- ================================================================
CREATE TABLE IF NOT EXISTS cheques_recus (
  id                UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id         UUID          NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  numero            TEXT          NOT NULL,
  client_id         UUID          REFERENCES clients(id) ON DELETE SET NULL,
  client_nom        TEXT,
  montant           NUMERIC(12,2) NOT NULL,
  banque            TEXT,
  date_cheque       DATE          NOT NULL,
  date_encaissement DATE,
  statut            TEXT          DEFAULT 'en_attente' CHECK (statut IN ('en_attente','encaisse','rejete','annule')),
  notes             TEXT,
  created_at        TIMESTAMPTZ   DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_cheques_recus_tenant ON cheques_recus (tenant_id);

-- ================================================================
--  TABLE : cheques_emis
-- ================================================================
CREATE TABLE IF NOT EXISTS cheques_emis (
  id              UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id       UUID          NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  numero          TEXT          NOT NULL,
  fournisseur_id  UUID          REFERENCES fournisseurs(id) ON DELETE SET NULL,
  beneficiaire    TEXT,
  montant         NUMERIC(12,2) NOT NULL,
  banque          TEXT,
  date_cheque     DATE          NOT NULL,
  statut          TEXT          DEFAULT 'emis' CHECK (statut IN ('emis','compense','annule')),
  notes           TEXT,
  created_at      TIMESTAMPTZ   DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_cheques_emis_tenant ON cheques_emis (tenant_id);

-- ================================================================
--  TABLE : abonnements
-- ================================================================
CREATE TABLE IF NOT EXISTS abonnements (
  id                  UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id           UUID          NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  nom                 TEXT          NOT NULL,
  fournisseur         TEXT,
  montant             NUMERIC(10,2) NOT NULL,
  cycle               TEXT          DEFAULT 'mensuel' CHECK (cycle IN ('mensuel','trimestriel','annuel')),
  date_debut          DATE          NOT NULL,
  date_renouvellement DATE,
  statut              TEXT          DEFAULT 'actif' CHECK (statut IN ('actif','pause','annule')),
  notes               TEXT,
  created_at          TIMESTAMPTZ   DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_abonnements_tenant ON abonnements (tenant_id);

-- ================================================================
--  TABLE : client_subscriptions
-- ================================================================
CREATE TABLE IF NOT EXISTS client_subscriptions (
  id                         UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id                  UUID          NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  client_id                  UUID          REFERENCES clients(id) ON DELETE SET NULL,
  nom                        TEXT          NOT NULL,
  montant                    NUMERIC(12,2) NOT NULL,
  cycle                      TEXT          DEFAULT 'mensuel' CHECK (cycle IN ('mensuel','trimestriel','annuel')),
  montant_mensuel            NUMERIC(12,2) DEFAULT 0,
  date_debut                 DATE          NOT NULL,
  date_prochaine_facturation DATE,
  statut                     TEXT          DEFAULT 'actif' CHECK (statut IN ('actif','pause','annule','impaye')),
  facture_auto               BOOLEAN       DEFAULT FALSE,
  date_annulation            DATE,
  annulation_raison          TEXT,
  created_at                 TIMESTAMPTZ   DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_client_subs_tenant ON client_subscriptions (tenant_id);

-- ================================================================
--  TABLE : taches
-- ================================================================
CREATE TABLE IF NOT EXISTS taches (
  id            UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id     UUID        NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  titre         TEXT        NOT NULL,
  description   TEXT,
  statut        TEXT        DEFAULT 'todo' CHECK (statut IN ('todo','en_cours','done')),
  priorite      TEXT        DEFAULT 'important' CHECK (priorite IN ('urgent_important','important','urgent','low')),
  categorie     TEXT        DEFAULT 'admin',
  client_id     UUID        REFERENCES clients(id) ON DELETE SET NULL,
  client_nom    TEXT,
  assigned_to   UUID        REFERENCES users(id) ON DELETE SET NULL,
  date_echeance DATE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_taches_tenant ON taches (tenant_id);

-- ================================================================
--  TABLE : automation_rules
-- ================================================================
CREATE TABLE IF NOT EXISTS automation_rules (
  id             UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id      UUID        NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  label          TEXT        NOT NULL,
  description    TEXT,
  enabled        BOOLEAN     DEFAULT TRUE,
  trigger_type   TEXT        NOT NULL,
  trigger_config JSONB       DEFAULT '{}',
  conditions     JSONB       DEFAULT '[]',
  actions        JSONB       DEFAULT '[]',
  runs_total     INT         DEFAULT 0,
  last_run_at    TIMESTAMPTZ,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_auto_rules_tenant ON automation_rules (tenant_id);

-- ================================================================
--  TABLE : automation_logs
-- ================================================================
CREATE TABLE IF NOT EXISTS automation_logs (
  id            UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id     UUID        NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  rule_id       UUID        REFERENCES automation_rules(id) ON DELETE SET NULL,
  rule_label    TEXT,
  action_type   TEXT,
  status        TEXT        DEFAULT 'success' CHECK (status IN ('pending','success','failed')),
  entity_ref    TEXT,
  error_message TEXT,
  executed_at   TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_auto_logs_tenant ON automation_logs (tenant_id);

-- ================================================================
--  TABLE : alerts
-- ================================================================
CREATE TABLE IF NOT EXISTS alerts (
  id           UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id    UUID        NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  type         TEXT        NOT NULL,
  priority     TEXT        DEFAULT 'medium' CHECK (priority IN ('low','medium','critical')),
  title        TEXT        NOT NULL,
  message      TEXT,
  entity_id    UUID,
  entity_type  TEXT,
  is_read      BOOLEAN     DEFAULT FALSE,
  is_resolved  BOOLEAN     DEFAULT FALSE,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_alerts_tenant ON alerts (tenant_id);
CREATE INDEX IF NOT EXISTS idx_alerts_unread ON alerts (tenant_id, is_read) WHERE is_read = FALSE;

-- ================================================================
--  TRIGGER : updated_at automatique
-- ================================================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_tenants_updated_at')   THEN CREATE TRIGGER trg_tenants_updated_at   BEFORE UPDATE ON tenants   FOR EACH ROW EXECUTE FUNCTION set_updated_at(); END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_clients_updated_at')   THEN CREATE TRIGGER trg_clients_updated_at   BEFORE UPDATE ON clients   FOR EACH ROW EXECUTE FUNCTION set_updated_at(); END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_prospects_updated_at') THEN CREATE TRIGGER trg_prospects_updated_at BEFORE UPDATE ON prospects FOR EACH ROW EXECUTE FUNCTION set_updated_at(); END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_devis_updated_at')     THEN CREATE TRIGGER trg_devis_updated_at     BEFORE UPDATE ON devis     FOR EACH ROW EXECUTE FUNCTION set_updated_at(); END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_factures_updated_at')  THEN CREATE TRIGGER trg_factures_updated_at  BEFORE UPDATE ON factures  FOR EACH ROW EXECUTE FUNCTION set_updated_at(); END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_contrats_updated_at')  THEN CREATE TRIGGER trg_contrats_updated_at  BEFORE UPDATE ON contrats  FOR EACH ROW EXECUTE FUNCTION set_updated_at(); END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_taches_updated_at')    THEN CREATE TRIGGER trg_taches_updated_at    BEFORE UPDATE ON taches    FOR EACH ROW EXECUTE FUNCTION set_updated_at(); END IF;
END $$;

-- ================================================================
--  FUNCTION : numéro de document automatique
-- ================================================================
CREATE OR REPLACE FUNCTION next_doc_number(
  p_tenant_id UUID,
  p_prefix    TEXT,
  p_year      INT DEFAULT EXTRACT(YEAR FROM NOW())::INT
)
RETURNS TEXT LANGUAGE plpgsql AS $$
DECLARE
  _count INT;
  _table TEXT;
BEGIN
  _table := CASE p_prefix
    WHEN 'FAC' THEN 'factures'
    WHEN 'DEV' THEN 'devis'
    WHEN 'CTR' THEN 'contrats'
    ELSE 'factures'
  END;
  EXECUTE format(
    'SELECT COUNT(*) FROM %I WHERE tenant_id = $1 AND numero LIKE $2',
    _table
  ) INTO _count USING p_tenant_id, p_prefix || '-' || p_year || '-%';
  RETURN p_prefix || '-' || p_year || '-' || lpad((_count + 1)::text, 3, '0');
END;
$$;

-- ================================================================
--  SEED : demo tenant + admin user
-- ================================================================
INSERT INTO users (email, password_hash, name)
VALUES ('admin@demo.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J4bCf1.Oa', 'Admin Demo')
ON CONFLICT (email) DO NOTHING;

INSERT INTO tenants (slug, name, plan, is_active, owner_id)
SELECT 'demo', 'GestiQ Demo', 'pro', TRUE, id FROM users WHERE email = 'admin@demo.com'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO tenant_users (tenant_id, user_id, role, status, accepted_at)
SELECT t.id, u.id, 'admin', 'active', NOW()
FROM tenants t, users u
WHERE t.slug = 'demo' AND u.email = 'admin@demo.com'
ON CONFLICT (tenant_id, user_id) DO NOTHING;
