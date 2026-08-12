-- ============================================================
-- EVOLUA — Sprint 07 — Motor Oficial: evidence_strength
-- ============================================================
-- Adiciona o campo evidence_strength à tabela alternative_indicators.
-- Este campo representa a força com que cada alternativa evidencia
-- um indicador comportamental:
--
--   3 = evidência forte
--   2 = evidência clara
--   1 = evidência secundária
--   0 = ausência de evidência
--
-- A tabela ficará vazia até o mapeamento oficial ser importado.
-- ============================================================

alter table public.alternative_indicators
  add column evidence_strength smallint not null
  constraint alternative_indicators_evidence_strength_range
    check (evidence_strength in (0, 1, 2, 3));

comment on column public.alternative_indicators.evidence_strength is
  '3=forte | 2=clara | 1=secundária | 0=ausente';
