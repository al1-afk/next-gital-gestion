-- ================================================================
--  GestiQ — Add 'type' column to produits (produit | service)
--  The Produits.tsx form, the import/export schema and the
--  prestation library all reference a "type" classifier that was
--  missing from the original schema. Adding it now so INSERTs that
--  include the field stop returning DB 42703 (column does not exist).
-- ================================================================

ALTER TABLE produits
  ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'service';

-- Backfill any pre-existing rows so the new NOT NULL default applies
UPDATE produits SET type = 'service' WHERE type IS NULL;
