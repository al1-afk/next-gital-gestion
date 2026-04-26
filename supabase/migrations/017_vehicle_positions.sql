-- ================================================================
--  GestiQ — Migration 017: GPS positions for vehicles
--  Date: 2026-04-26
--
--  Records timestamped GPS positions for each vehicle. Sources:
--    - 'browser'  : navigator.geolocation from the driver's phone
--    - 'device'   : external GPS tracker via webhook (future)
--    - 'manual'   : admin entered a checkpoint manually
--
--  Tenant-scoped, FORCE RLS, standard 4 policies, gestiq_app grants.
-- ================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.vehicle_positions (
  id           uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    uuid         NOT NULL REFERENCES public.tenants(id)          ON DELETE CASCADE,
  vehicle_id   uuid         NOT NULL REFERENCES public.service_vehicles(id) ON DELETE CASCADE,
  recorded_at  timestamptz  NOT NULL DEFAULT now(),
  lat          numeric(9,6) NOT NULL CHECK (lat  BETWEEN -90  AND 90),
  lng          numeric(9,6) NOT NULL CHECK (lng  BETWEEN -180 AND 180),
  accuracy     numeric(8,2),  -- meters (GPS accuracy)
  speed        numeric(6,2),  -- km/h
  heading      numeric(5,2),  -- degrees (0-360)
  altitude     numeric(8,2),  -- meters
  source       text         NOT NULL DEFAULT 'browser'
                            CHECK (source IN ('browser','device','manual')),
  driver       text,
  created_at   timestamptz  NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_positions_tenant       ON public.vehicle_positions (tenant_id);
CREATE INDEX IF NOT EXISTS idx_positions_vehicle_time ON public.vehicle_positions (vehicle_id, recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_positions_recent       ON public.vehicle_positions (tenant_id, recorded_at DESC);

ALTER TABLE public.vehicle_positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicle_positions FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rls_select_vehicle_positions ON public.vehicle_positions;
DROP POLICY IF EXISTS rls_insert_vehicle_positions ON public.vehicle_positions;
DROP POLICY IF EXISTS rls_update_vehicle_positions ON public.vehicle_positions;
DROP POLICY IF EXISTS rls_delete_vehicle_positions ON public.vehicle_positions;

CREATE POLICY rls_select_vehicle_positions ON public.vehicle_positions
  FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY rls_insert_vehicle_positions ON public.vehicle_positions
  FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_update_vehicle_positions ON public.vehicle_positions
  FOR UPDATE USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_delete_vehicle_positions ON public.vehicle_positions
  FOR DELETE USING (tenant_id = current_tenant_id());

GRANT SELECT, INSERT, UPDATE, DELETE ON public.vehicle_positions TO gestiq_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.vehicle_positions TO gestiq_api;

COMMIT;
