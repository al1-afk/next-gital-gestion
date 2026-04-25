-- ================================================================
--  GestiQ — Migration 015: Stock tickets (caisse / point of sale)
--  Date: 2026-04-25
--
--  Adds two tables (`stock_tickets`, `stock_ticket_lines`) so the
--  user can record over-the-counter sales. Each line auto-creates a
--  `sortie` stock movement so `stock_actuel` stays in sync.
--
--  Plug-and-play: the existing stock module is untouched.
-- ================================================================

BEGIN;

-- ── 1. stock_tickets ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.stock_tickets (
  id                uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid         NOT NULL REFERENCES public.tenants(id)  ON DELETE CASCADE,
  numero            text         NOT NULL,
  client_id         uuid         REFERENCES public.clients(id)           ON DELETE SET NULL,
  client_nom        text,
  date              timestamptz  NOT NULL DEFAULT now(),
  total_ht          numeric(12,2) NOT NULL DEFAULT 0,
  total_tva         numeric(12,2) NOT NULL DEFAULT 0,
  total_ttc         numeric(12,2) NOT NULL DEFAULT 0,
  methode_paiement  text         NOT NULL DEFAULT 'especes'
                                 CHECK (methode_paiement IN ('especes','carte','virement','cheque','autre')),
  statut            text         NOT NULL DEFAULT 'valide'
                                 CHECK (statut IN ('valide','annule')),
  notes             text,
  created_at        timestamptz  NOT NULL DEFAULT now(),
  updated_at        timestamptz  NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, numero)
);
CREATE INDEX IF NOT EXISTS idx_stock_tickets_tenant ON public.stock_tickets (tenant_id);
CREATE INDEX IF NOT EXISTS idx_stock_tickets_date   ON public.stock_tickets (date DESC);
CREATE INDEX IF NOT EXISTS idx_stock_tickets_client ON public.stock_tickets (client_id);

-- ── 2. stock_ticket_lines ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.stock_ticket_lines (
  id            uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid         NOT NULL REFERENCES public.tenants(id)         ON DELETE CASCADE,
  ticket_id     uuid         NOT NULL REFERENCES public.stock_tickets(id)   ON DELETE CASCADE,
  product_id    uuid         NOT NULL REFERENCES public.stock_products(id)  ON DELETE RESTRICT,
  product_nom   text         NOT NULL,
  product_sku   text         NOT NULL,
  quantite      numeric(12,2) NOT NULL CHECK (quantite > 0),
  prix_unitaire numeric(12,2) NOT NULL,
  tva           numeric(5,2)  NOT NULL DEFAULT 20,
  total_ht      numeric(12,2) NOT NULL,
  total_ttc     numeric(12,2) NOT NULL,
  created_at    timestamptz   NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_stock_ticket_lines_tenant  ON public.stock_ticket_lines (tenant_id);
CREATE INDEX IF NOT EXISTS idx_stock_ticket_lines_ticket  ON public.stock_ticket_lines (ticket_id);
CREATE INDEX IF NOT EXISTS idx_stock_ticket_lines_product ON public.stock_ticket_lines (product_id);

-- ── updated_at trigger on tickets ───────────────────────────────
DROP TRIGGER IF EXISTS trg_touch_stock_tickets ON public.stock_tickets;
CREATE TRIGGER trg_touch_stock_tickets BEFORE UPDATE ON public.stock_tickets
  FOR EACH ROW EXECUTE FUNCTION public._stock_touch_updated_at();

-- ── Auto stock decrement on ticket-line insert ──────────────────
CREATE OR REPLACE FUNCTION public._stock_on_ticket_line()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  ticket_statut text;
  ticket_numero text;
BEGIN
  SELECT statut, numero INTO ticket_statut, ticket_numero
  FROM public.stock_tickets
  WHERE id = NEW.ticket_id;

  -- Only consume stock when the ticket is validated
  IF ticket_statut = 'valide' THEN
    INSERT INTO public.stock_movements
      (tenant_id, product_id, type, quantite, reference, source, source_id, note)
    VALUES
      (NEW.tenant_id, NEW.product_id, 'sortie', NEW.quantite,
       ticket_numero, 'facture', NEW.ticket_id,
       'Vente — ticket ' || ticket_numero);
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_stock_on_ticket_line ON public.stock_ticket_lines;
CREATE TRIGGER trg_stock_on_ticket_line
  AFTER INSERT ON public.stock_ticket_lines
  FOR EACH ROW EXECUTE FUNCTION public._stock_on_ticket_line();

-- ── On ticket cancel, reverse the stock with `entree` movements ─
CREATE OR REPLACE FUNCTION public._stock_on_ticket_cancel()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF OLD.statut = 'valide' AND NEW.statut = 'annule' THEN
    INSERT INTO public.stock_movements
      (tenant_id, product_id, type, quantite, reference, source, source_id, note)
    SELECT NEW.tenant_id, l.product_id, 'entree', l.quantite,
           NEW.numero, 'ajustement_auto', NEW.id,
           'Annulation ticket ' || NEW.numero
    FROM public.stock_ticket_lines l
    WHERE l.ticket_id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_stock_on_ticket_cancel ON public.stock_tickets;
CREATE TRIGGER trg_stock_on_ticket_cancel
  AFTER UPDATE OF statut ON public.stock_tickets
  FOR EACH ROW EXECUTE FUNCTION public._stock_on_ticket_cancel();

-- ── RLS ─────────────────────────────────────────────────────────
ALTER TABLE public.stock_tickets       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_tickets       FORCE ROW LEVEL SECURITY;
ALTER TABLE public.stock_ticket_lines  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_ticket_lines  FORCE ROW LEVEL SECURITY;

DO $$
DECLARE t text;
BEGIN
  FOR t IN SELECT unnest(ARRAY['stock_tickets', 'stock_ticket_lines']) LOOP
    EXECUTE format('DROP POLICY IF EXISTS rls_select_%1$s ON public.%1$I', t);
    EXECUTE format('DROP POLICY IF EXISTS rls_insert_%1$s ON public.%1$I', t);
    EXECUTE format('DROP POLICY IF EXISTS rls_update_%1$s ON public.%1$I', t);
    EXECUTE format('DROP POLICY IF EXISTS rls_delete_%1$s ON public.%1$I', t);

    EXECUTE format('CREATE POLICY rls_select_%1$s ON public.%1$I FOR SELECT USING (tenant_id = current_tenant_id())', t);
    EXECUTE format('CREATE POLICY rls_insert_%1$s ON public.%1$I FOR INSERT WITH CHECK (tenant_id = current_tenant_id())', t);
    EXECUTE format('CREATE POLICY rls_update_%1$s ON public.%1$I FOR UPDATE USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id())', t);
    EXECUTE format('CREATE POLICY rls_delete_%1$s ON public.%1$I FOR DELETE USING (tenant_id = current_tenant_id())', t);
  END LOOP;
END $$;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.stock_tickets       TO gestiq_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.stock_ticket_lines  TO gestiq_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.stock_tickets       TO gestiq_api;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.stock_ticket_lines  TO gestiq_api;

COMMIT;
