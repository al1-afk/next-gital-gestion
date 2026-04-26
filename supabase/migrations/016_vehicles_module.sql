-- ================================================================
--  GestiQ — Migration 016: Véhicules de service module
--  Date: 2026-04-25
--
--  Adds a fleet-management subsystem so the user can track:
--    - service_vehicles      (parc auto: marque, immat, kilométrage…)
--    - vehicle_fuel_logs     (pleins de carburant + consommation)
--    - vehicle_maintenance   (vidanges, révisions, réparations)
--    - vehicle_documents     (assurance, vignette, visite technique)
--    - vehicle_trips         (trajets attribuables à un client)
--
--  Triggers:
--    - update kilometrage on fuel log / trip insert
--    - touch updated_at
--
--  Tenant-scoped FORCE RLS + 4 policies/table + grants for gestiq_app.
-- ================================================================

BEGIN;

CREATE OR REPLACE FUNCTION public._vehicles_touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := now(); RETURN NEW; END;
$$;

-- ── 1. service_vehicles ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.service_vehicles (
  id                  uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           uuid         NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  immatriculation     text         NOT NULL,
  marque              text         NOT NULL,
  modele              text         NOT NULL,
  type                text         NOT NULL DEFAULT 'voiture'
                                   CHECK (type IN ('voiture','utilitaire','fourgon','moto','camion','autre')),
  annee               integer,
  vin                 text,
  carburant_type      text         NOT NULL DEFAULT 'diesel'
                                   CHECK (carburant_type IN ('diesel','essence','hybride','electrique','autre')),
  date_achat          date,
  prix_achat          numeric(12,2),
  kilometrage         integer      NOT NULL DEFAULT 0,
  conducteur_principal text,
  image_url           text,
  notes               text,
  statut              text         NOT NULL DEFAULT 'actif'
                                   CHECK (statut IN ('actif','panne','vendu','reforme')),
  created_at          timestamptz  NOT NULL DEFAULT now(),
  updated_at          timestamptz  NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, immatriculation)
);
CREATE INDEX IF NOT EXISTS idx_service_vehicles_tenant ON public.service_vehicles (tenant_id);
CREATE INDEX IF NOT EXISTS idx_service_vehicles_statut ON public.service_vehicles (tenant_id, statut);

-- ── 2. vehicle_fuel_logs ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.vehicle_fuel_logs (
  id           uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    uuid         NOT NULL REFERENCES public.tenants(id)            ON DELETE CASCADE,
  vehicle_id   uuid         NOT NULL REFERENCES public.service_vehicles(id)   ON DELETE CASCADE,
  date         timestamptz  NOT NULL DEFAULT now(),
  kilometrage  integer      NOT NULL,
  litres       numeric(8,2) NOT NULL CHECK (litres > 0),
  prix_total   numeric(10,2) NOT NULL CHECK (prix_total >= 0),
  station      text,
  conducteur   text,
  is_full      boolean      NOT NULL DEFAULT true,
  notes        text,
  created_at   timestamptz  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_fuel_logs_tenant   ON public.vehicle_fuel_logs (tenant_id);
CREATE INDEX IF NOT EXISTS idx_fuel_logs_vehicle  ON public.vehicle_fuel_logs (vehicle_id, date DESC);

-- ── 3. vehicle_maintenance ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.vehicle_maintenance (
  id              uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid         NOT NULL REFERENCES public.tenants(id)          ON DELETE CASCADE,
  vehicle_id      uuid         NOT NULL REFERENCES public.service_vehicles(id) ON DELETE CASCADE,
  date            date         NOT NULL DEFAULT CURRENT_DATE,
  type            text         NOT NULL DEFAULT 'autre'
                               CHECK (type IN ('vidange','revision','reparation','pneus','freins','batterie','autre')),
  description     text         NOT NULL,
  garage          text,
  kilometrage     integer,
  montant         numeric(10,2) NOT NULL DEFAULT 0,
  prochaine_date  date,
  prochaine_km    integer,
  notes           text,
  created_at      timestamptz  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_maintenance_tenant   ON public.vehicle_maintenance (tenant_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_vehicle  ON public.vehicle_maintenance (vehicle_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_maintenance_due      ON public.vehicle_maintenance (tenant_id, prochaine_date)
  WHERE prochaine_date IS NOT NULL;

-- ── 4. vehicle_documents (assurance, vignette, VT…) ─────────────
CREATE TABLE IF NOT EXISTS public.vehicle_documents (
  id           uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    uuid         NOT NULL REFERENCES public.tenants(id)          ON DELETE CASCADE,
  vehicle_id   uuid         NOT NULL REFERENCES public.service_vehicles(id) ON DELETE CASCADE,
  type         text         NOT NULL
                            CHECK (type IN ('assurance','visite_technique','vignette','carte_grise','autre')),
  numero       text,
  emetteur     text,
  date_debut   date,
  date_fin     date         NOT NULL,
  montant      numeric(10,2),
  notes        text,
  created_at   timestamptz  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_docs_tenant      ON public.vehicle_documents (tenant_id);
CREATE INDEX IF NOT EXISTS idx_docs_vehicle     ON public.vehicle_documents (vehicle_id, date_fin);
CREATE INDEX IF NOT EXISTS idx_docs_expiry      ON public.vehicle_documents (tenant_id, date_fin);

-- ── 5. vehicle_trips ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.vehicle_trips (
  id            uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid         NOT NULL REFERENCES public.tenants(id)          ON DELETE CASCADE,
  vehicle_id    uuid         NOT NULL REFERENCES public.service_vehicles(id) ON DELETE CASCADE,
  client_id     uuid         REFERENCES public.clients(id)                   ON DELETE SET NULL,
  client_nom    text,
  date          timestamptz  NOT NULL DEFAULT now(),
  conducteur    text,
  km_depart     integer      NOT NULL,
  km_arrivee    integer      NOT NULL CHECK (km_arrivee >= km_depart),
  motif         text,
  notes         text,
  created_at    timestamptz  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_trips_tenant   ON public.vehicle_trips (tenant_id);
CREATE INDEX IF NOT EXISTS idx_trips_vehicle  ON public.vehicle_trips (vehicle_id, date DESC);

-- ── updated_at trigger on service_vehicles ──────────────────────
DROP TRIGGER IF EXISTS trg_touch_service_vehicles ON public.service_vehicles;
CREATE TRIGGER trg_touch_service_vehicles BEFORE UPDATE ON public.service_vehicles
  FOR EACH ROW EXECUTE FUNCTION public._vehicles_touch_updated_at();

-- ── Auto-update kilometrage when a higher reading is logged ─────
CREATE OR REPLACE FUNCTION public._vehicles_sync_km()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE public.service_vehicles
     SET kilometrage = NEW.kilometrage
   WHERE id = NEW.vehicle_id
     AND tenant_id = NEW.tenant_id
     AND NEW.kilometrage > kilometrage;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_fuel_sync_km ON public.vehicle_fuel_logs;
CREATE TRIGGER trg_fuel_sync_km
  AFTER INSERT ON public.vehicle_fuel_logs
  FOR EACH ROW EXECUTE FUNCTION public._vehicles_sync_km();

CREATE OR REPLACE FUNCTION public._vehicles_sync_km_trip()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE public.service_vehicles
     SET kilometrage = NEW.km_arrivee
   WHERE id = NEW.vehicle_id
     AND tenant_id = NEW.tenant_id
     AND NEW.km_arrivee > kilometrage;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_trip_sync_km ON public.vehicle_trips;
CREATE TRIGGER trg_trip_sync_km
  AFTER INSERT ON public.vehicle_trips
  FOR EACH ROW EXECUTE FUNCTION public._vehicles_sync_km_trip();

-- ── RLS + policies ──────────────────────────────────────────────
DO $$
DECLARE t text;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
    'service_vehicles','vehicle_fuel_logs','vehicle_maintenance',
    'vehicle_documents','vehicle_trips'
  ]) LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('ALTER TABLE public.%I FORCE  ROW LEVEL SECURITY', t);

    EXECUTE format('DROP POLICY IF EXISTS rls_select_%1$s ON public.%1$I', t);
    EXECUTE format('DROP POLICY IF EXISTS rls_insert_%1$s ON public.%1$I', t);
    EXECUTE format('DROP POLICY IF EXISTS rls_update_%1$s ON public.%1$I', t);
    EXECUTE format('DROP POLICY IF EXISTS rls_delete_%1$s ON public.%1$I', t);

    EXECUTE format('CREATE POLICY rls_select_%1$s ON public.%1$I FOR SELECT USING (tenant_id = current_tenant_id())', t);
    EXECUTE format('CREATE POLICY rls_insert_%1$s ON public.%1$I FOR INSERT WITH CHECK (tenant_id = current_tenant_id())', t);
    EXECUTE format('CREATE POLICY rls_update_%1$s ON public.%1$I FOR UPDATE USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id())', t);
    EXECUTE format('CREATE POLICY rls_delete_%1$s ON public.%1$I FOR DELETE USING (tenant_id = current_tenant_id())', t);

    EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON public.%I TO gestiq_app', t);
    EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON public.%I TO gestiq_api', t);
  END LOOP;
END $$;

COMMIT;
