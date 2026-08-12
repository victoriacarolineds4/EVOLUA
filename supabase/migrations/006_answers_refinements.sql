-- ============================================================
-- EVOLUA — Sprint 05 (ajustes pré-aprovação)
-- ============================================================

-- -----------------------------------------------------------
-- AJUSTE 01: answered_at em answers
-- Registra o momento exato em que o colaborador escolheu a
-- alternativa. Distinto de created_at para futuros analytics
-- de tempo por situação.
-- -----------------------------------------------------------
alter table public.answers
  add column answered_at timestamptz not null default now();

-- -----------------------------------------------------------
-- AJUSTE 02: dimension em questions
-- Categoriza cada situação por dimensão comportamental.
-- Nullable: as 3 questões de teste ficam sem dimensão.
-- Usado na Sprint de IA para agrupar resultados no
-- Mapa de Desenvolvimento.
-- -----------------------------------------------------------
alter table public.questions
  add column dimension text;
