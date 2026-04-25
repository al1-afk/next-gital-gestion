-- ================================================================
--  GestiQ — Migration 014: Stock module (plug & play)
--  Date: 2026-04-24
--
--  Adds a self-contained stock management subsystem:
--    - stock_categories       (catégories produits)
--    - stock_suppliers        (fournisseurs spécifiques au stock)
--    - stock_products         (produits avec SKU, prix, stock actuel)
--    - stock_movements        (entrées, sorties, ajustements)
--    - stock_invoice_links    (lien optionnel facture_line ↔ produit)
--
--  Nothing in existing tables is touched. The optional Factures link
--  lives in its own join table `stock_invoice_links`; a trigger there
--  auto-creates a stock_movement (exit) so the current stock stays in
--  sync without changing the invoice code path.
--
--  Fully tenant-scoped (RLS FORCE) + standard 4 policies per table.
--  Grants for `gestiq_app` (runtime role — see migration 013).
--
--  Idempotent. Safe to re-run. Fully transactional.
-- ================================================================

BEGIN;

-- ── Helper: touch updated_at on update ──────────────────────────
CREATE OR REPLACE FUNCTION public._stock_touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

-- ── 1. stock_categories ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.stock_categories (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  nom         text        NOT NULL,
  description text,
  color       text        DEFAULT '#3B82F6',
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, nom)
);
CREATE INDEX IF NOT EXISTS idx_stock_categories_tenant ON public.stock_categories (tenant_id);

-- ── 2. stock_suppliers ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.stock_suppliers (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  nom         text        NOT NULL,
  email       text,
  telephone   text,
  adresse     text,
  notes       text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_stock_suppliers_tenant ON public.stock_suppliers (tenant_id);

-- ── 3. stock_products ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.stock_products (
  id             uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid         NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  sku            text         NOT NULL,
  nom            text         NOT NULL,
  description    text,
  category_id    uuid         REFERENCES public.stock_categories(id) ON DELETE SET NULL,
  supplier_id    uuid         REFERENCES public.stock_suppliers(id)  ON DELETE SET NULL,
  prix_achat     numeric(12,2) NOT NULL DEFAULT 0,
  prix_vente     numeric(12,2) NOT NULL DEFAULT 0,
  tva            numeric(5,2)  NOT NULL DEFAULT 20,
  stock_actuel   numeric(12,2) NOT NULL DEFAULT 0,
  stock_minimum  numeric(12,2) NOT NULL DEFAULT 0,
  image_url      text,
  is_active      boolean      NOT NULL DEFAULT true,
  created_at     timestamptz  NOT NULL DEFAULT now(),
  updated_at     timestamptz  NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, sku)
);
CREATE INDEX IF NOT EXISTS idx_stock_products_tenant    ON public.stock_products (tenant_id);
CREATE INDEX IF NOT EXISTS idx_stock_products_category  ON public.stock_products (category_id);
CREATE INDEX IF NOT EXISTS idx_stock_products_supplier  ON public.stock_products (supplier_id);
CREATE INDEX IF NOT EXISTS idx_stock_products_low_stock ON public.stock_products (tenant_id)
  WHERE stock_actuel <= stock_minimum;

-- ── 4. stock_movements ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.stock_movements (
  id          uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid         NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  product_id  uuid         NOT NULL REFERENCES public.stock_products(id) ON DELETE CASCADE,
  type        text         NOT NULL CHECK (type IN ('entree','sortie','ajustement')),
  quantite    numeric(12,2) NOT NULL,
  reference   text,
  note        text,
  source      text         NOT NULL DEFAULT 'manual'
                            CHECK (source IN ('manual','facture','ajustement_auto')),
  source_id   uuid,
  created_at  timestamptz  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_stock_movements_tenant  ON public.stock_movements (tenant_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_product ON public.stock_movements (product_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_created ON public.stock_movements (created_at DESC);

-- ── 5. stock_invoice_links ──────────────────────────────────────
--  Links an existing facture_line to a stock product + quantity
--  consumed. Exists separately so facture_lines stays untouched.
--  Deleting the facture (and cascading its lines) cascades here too.
CREATE TABLE IF NOT EXISTS public.stock_invoice_links (
  id               uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id        uuid         NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  facture_line_id  uuid         NOT NULL REFERENCES public.facture_lines(id) ON DELETE CASCADE,
  product_id       uuid         NOT NULL REFERENCES public.stock_products(id) ON DELETE CASCADE,
  quantite         numeric(12,2) NOT NULL DEFAULT 1,
  created_at       timestamptz  NOT NULL DEFAULT now(),
  UNIQUE (facture_line_id)
);
CREATE INDEX IF NOT EXISTS idx_stock_invoice_links_tenant  ON public.stock_invoice_links (tenant_id);
CREATE INDEX IF NOT EXISTS idx_stock_invoice_links_product ON public.stock_invoice_links (product_id);

-- ── updated_at triggers ─────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_touch_stock_categories ON public.stock_categories;
CREATE TRIGGER trg_touch_stock_categories BEFORE UPDATE ON public.stock_categories
  FOR EACH ROW EXECUTE FUNCTION public._stock_touch_updated_at();

DROP TRIGGER IF EXISTS trg_touch_stock_suppliers ON public.stock_suppliers;
CREATE TRIGGER trg_touch_stock_suppliers BEFORE UPDATE ON public.stock_suppliers
  FOR EACH ROW EXECUTE FUNCTION public._stock_touch_updated_at();

DROP TRIGGER IF EXISTS trg_touch_stock_products ON public.stock_products;
CREATE TRIGGER trg_touch_stock_products BEFORE UPDATE ON public.stock_products
  FOR EACH ROW EXECUTE FUNCTION public._stock_touch_updated_at();

-- ── Auto-update stock_actuel on movement insert ─────────────────
CREATE OR REPLACE FUNCTION public._stock_apply_movement()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  delta numeric(12,2);
BEGIN
  IF NEW.type = 'entree' THEN
    delta := NEW.quantite;
  ELSIF NEW.type = 'sortie' THEN
    delta := -NEW.quantite;
  ELSE -- ajustement: absolute value, set stock to quantite
    UPDATE public.stock_products
       SET stock_actuel = NEW.quantite
     WHERE id = NEW.product_id AND tenant_id = NEW.tenant_id;
    RETURN NEW;
  END IF;

  UPDATE public.stock_products
     SET stock_actuel = stock_actuel + delta
   WHERE id = NEW.product_id AND tenant_id = NEW.tenant_id;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_stock_apply_movement ON public.stock_movements;
CREATE TRIGGER trg_stock_apply_movement
  AFTER INSERT ON public.stock_movements
  FOR EACH ROW EXECUTE FUNCTION public._stock_apply_movement();

-- ── Auto-create sortie movement from invoice line link ──────────
CREATE OR REPLACE FUNCTION public._stock_on_invoice_link()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.stock_movements
    (tenant_id, product_id, type, quantite, reference, source, source_id, note)
  VALUES
    (NEW.tenant_id, NEW.product_id, 'sortie', NEW.quantite,
     'Facture', 'facture', NEW.facture_line_id,
     'Décrément auto via facture');
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_stock_on_invoice_link ON public.stock_invoice_links;
CREATE TRIGGER trg_stock_on_invoice_link
  AFTER INSERT ON public.stock_invoice_links
  FOR EACH ROW EXECUTE FUNCTION public._stock_on_invoice_link();

-- ── RLS ─────────────────────────────────────────────────────────
ALTER TABLE public.stock_categories     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_suppliers      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_products       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_movements      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_invoice_links  ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.stock_categories     FORCE ROW LEVEL SECURITY;
ALTER TABLE public.stock_suppliers      FORCE ROW LEVEL SECURITY;
ALTER TABLE public.stock_products       FORCE ROW LEVEL SECURITY;
ALTER TABLE public.stock_movements      FORCE ROW LEVEL SECURITY;
ALTER TABLE public.stock_invoice_links  FORCE ROW LEVEL SECURITY;

-- Standard 4-policy set per table (SELECT/INSERT/UPDATE/DELETE)
DO $$
DECLARE
  t text;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
    'stock_categories', 'stock_suppliers', 'stock_products',
    'stock_movements', 'stock_invoice_links'
  ]) LOOP
    EXECUTE format('DROP POLICY IF EXISTS rls_select_%1$s ON public.%1$I', t);
    EXECUTE format('DROP POLICY IF EXISTS rls_insert_%1$s ON public.%1$I', t);
    EXECUTE format('DROP POLICY IF EXISTS rls_update_%1$s ON public.%1$I', t);
    EXECUTE format('DROP POLICY IF EXISTS rls_delete_%1$s ON public.%1$I', t);

    EXECUTE format(
      'CREATE POLICY rls_select_%1$s ON public.%1$I FOR SELECT USING (tenant_id = current_tenant_id())', t);
    EXECUTE format(
      'CREATE POLICY rls_insert_%1$s ON public.%1$I FOR INSERT WITH CHECK (tenant_id = current_tenant_id())', t);
    EXECUTE format(
      'CREATE POLICY rls_update_%1$s ON public.%1$I FOR UPDATE USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id())', t);
    EXECUTE format(
      'CREATE POLICY rls_delete_%1$s ON public.%1$I FOR DELETE USING (tenant_id = current_tenant_id())', t);
  END LOOP;
END $$;

-- ── Grants for runtime role ─────────────────────────────────────
GRANT SELECT, INSERT, UPDATE, DELETE ON public.stock_categories     TO gestiq_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.stock_suppliers      TO gestiq_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.stock_products       TO gestiq_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.stock_movements      TO gestiq_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.stock_invoice_links  TO gestiq_app;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.stock_categories     TO gestiq_api;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.stock_suppliers      TO gestiq_api;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.stock_products       TO gestiq_api;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.stock_movements      TO gestiq_api;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.stock_invoice_links  TO gestiq_api;

COMMIT;
