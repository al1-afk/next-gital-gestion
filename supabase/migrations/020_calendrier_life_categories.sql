-- ─────────────────────────────────────────────────────────────
-- 020_calendrier_life_categories.sql
-- Expands calendrier_events.type CHECK to include personal/life
-- categories used by the new "Routine hebdomadaire" feature.
-- Idempotent: safe to re-run.
-- ─────────────────────────────────────────────────────────────

BEGIN;

-- Drop the old CHECK if it exists (auto-named <table>_<column>_check)
DO $$
DECLARE
  c_name text;
BEGIN
  SELECT conname INTO c_name
  FROM pg_constraint
  WHERE conrelid = 'public.calendrier_events'::regclass
    AND contype  = 'c'
    AND pg_get_constraintdef(oid) ILIKE '%type%IN%';
  IF c_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE public.calendrier_events DROP CONSTRAINT %I', c_name);
  END IF;
END $$;

ALTER TABLE public.calendrier_events
  ADD CONSTRAINT calendrier_events_type_check
  CHECK (type IN (
    -- business
    'rdv','demo','appel','interne','echeance','relance','autre',
    -- life / wellbeing
    'sport','repos','apprentissage','repas','voyage','reflexion','famille','routine'
  ));

COMMIT;
