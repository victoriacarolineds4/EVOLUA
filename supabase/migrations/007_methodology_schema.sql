-- ============================================================
-- EVOLUA — Sprint 06 — Schema da Metodologia Oficial
-- ============================================================

-- -----------------------------------------------------------
-- TABELA: pillars (7 pilares da metodologia)
-- -----------------------------------------------------------
create table public.pillars (
  id          uuid        primary key,
  number      integer     not null unique,
  name        text        not null,
  description text,
  active      boolean     not null default true,
  created_at  timestamptz not null default now()
);

-- -----------------------------------------------------------
-- TABELA: indicators (35 indicadores comportamentais)
-- -----------------------------------------------------------
create table public.indicators (
  id            uuid        primary key,
  code          text        not null unique,
  name          text        not null,
  description   text,
  pillar_number integer     not null,
  active        boolean     not null default true,
  created_at    timestamptz not null default now()
);

-- -----------------------------------------------------------
-- TABELA: alternative_indicators
-- Relaciona alternativas com os indicadores que mede.
-- Permanece vazia nesta Sprint — preenchida após validação final.
-- -----------------------------------------------------------
create table public.alternative_indicators (
  id             uuid        primary key default gen_random_uuid(),
  alternative_id uuid        not null references public.alternatives(id) on delete cascade,
  indicator_id   uuid        not null references public.indicators(id) on delete cascade,
  created_at     timestamptz not null default now(),
  unique (alternative_id, indicator_id)
);

-- -----------------------------------------------------------
-- CAMPO: pillar_number em questions
-- Nullable — questões de teste existentes não possuem pilar.
-- -----------------------------------------------------------
alter table public.questions
  add column pillar_number integer;

-- -----------------------------------------------------------
-- CAMPO: letter em alternatives (A, B, C, D)
-- Nullable — alternativas de teste existentes não possuem letra.
-- -----------------------------------------------------------
alter table public.alternatives
  add column letter text;

-- -----------------------------------------------------------
-- RLS: pillars — leitura pública
-- -----------------------------------------------------------
alter table public.pillars enable row level security;

create policy "pillars_select_public"
  on public.pillars for select
  using (true);

-- -----------------------------------------------------------
-- RLS: indicators — leitura pública
-- -----------------------------------------------------------
alter table public.indicators enable row level security;

create policy "indicators_select_public"
  on public.indicators for select
  using (true);

-- -----------------------------------------------------------
-- RLS: alternative_indicators — leitura para gestores autenticados
-- -----------------------------------------------------------
alter table public.alternative_indicators enable row level security;

create policy "alternative_indicators_select_authenticated"
  on public.alternative_indicators for select
  to authenticated
  using (true);
