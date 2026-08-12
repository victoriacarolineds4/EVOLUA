-- ============================================================
-- EVOLUA — Sprint 09 — Motor de Interpretação: Dimensões Complementares
-- ============================================================
-- Enriquece o Motor sem alterar situações/alternativas. Cada uma das
-- 112 alternativas passará a evidenciar, além dos indicadores/pilares,
-- quatro dimensões complementares extraídas das MESMAS respostas:
--
--   DISC               (como a pessoa age)
--   Tipo Psicológico   (como a pessoa pensa)
--   Motivadores        (o que move a pessoa)
--   Estilo Operacional (como a pessoa trabalha)
--
-- Esta migração cria apenas a ESTRUTURA. Os vínculos alternativa→atributo
-- permanecem vazios até o mapeamento oficial ser importado (seed 004).
-- Nenhum vínculo é gerado ou deduzido automaticamente.
-- ============================================================

-- ------------------------------------------------------------
-- TABELAS DE REFERÊNCIA (as dimensões e suas categorias)
-- ------------------------------------------------------------

-- DISC — Dominância, Influência, Estabilidade, Conformidade
create table public.disc_profiles (
  id          uuid        primary key,
  code        text        not null unique,
  name        text        not null,
  description text,
  active      boolean     not null default true,
  created_at  timestamptz not null default now()
);

-- Tipo Psicológico — Estrategista, Idealista, Guardião, Artesão
create table public.psychological_types (
  id          uuid        primary key,
  code        text        not null unique,
  name        text        not null,
  description text,
  active      boolean     not null default true,
  created_at  timestamptz not null default now()
);

-- Motivadores — o que move a pessoa (8 categorias)
create table public.motivators (
  id          uuid        primary key,
  code        text        not null unique,
  name        text        not null,
  description text,
  active      boolean     not null default true,
  created_at  timestamptz not null default now()
);

-- Estilo Operacional — Executor, Planejador, Analítico, Colaborativo
create table public.operational_styles (
  id          uuid        primary key,
  code        text        not null unique,
  name        text        not null,
  description text,
  active      boolean     not null default true,
  created_at  timestamptz not null default now()
);

-- ------------------------------------------------------------
-- TABELAS DE VÍNCULO (alternativa → atributo + intensidade)
-- Mesmo padrão de public.alternative_indicators.
-- evidence_strength: 3=forte | 2=clara | 1=secundária | 0=ausente
-- Permanecem vazias até o mapeamento oficial.
-- ------------------------------------------------------------

create table public.alternative_disc (
  id              uuid        primary key default gen_random_uuid(),
  alternative_id  uuid        not null references public.alternatives(id) on delete cascade,
  disc_id         uuid        not null references public.disc_profiles(id) on delete cascade,
  evidence_strength smallint  not null
    constraint alternative_disc_evidence_strength_range
      check (evidence_strength in (0, 1, 2, 3)),
  created_at      timestamptz not null default now(),
  unique (alternative_id, disc_id)
);

create table public.alternative_psychological_types (
  id                     uuid        primary key default gen_random_uuid(),
  alternative_id         uuid        not null references public.alternatives(id) on delete cascade,
  psychological_type_id  uuid        not null references public.psychological_types(id) on delete cascade,
  evidence_strength      smallint    not null
    constraint alternative_psychological_types_evidence_strength_range
      check (evidence_strength in (0, 1, 2, 3)),
  created_at             timestamptz not null default now(),
  unique (alternative_id, psychological_type_id)
);

create table public.alternative_motivators (
  id              uuid        primary key default gen_random_uuid(),
  alternative_id  uuid        not null references public.alternatives(id) on delete cascade,
  motivator_id    uuid        not null references public.motivators(id) on delete cascade,
  evidence_strength smallint  not null
    constraint alternative_motivators_evidence_strength_range
      check (evidence_strength in (0, 1, 2, 3)),
  created_at      timestamptz not null default now(),
  unique (alternative_id, motivator_id)
);

create table public.alternative_operational_styles (
  id                    uuid        primary key default gen_random_uuid(),
  alternative_id        uuid        not null references public.alternatives(id) on delete cascade,
  operational_style_id  uuid        not null references public.operational_styles(id) on delete cascade,
  evidence_strength     smallint    not null
    constraint alternative_operational_styles_evidence_strength_range
      check (evidence_strength in (0, 1, 2, 3)),
  created_at            timestamptz not null default now(),
  unique (alternative_id, operational_style_id)
);

comment on column public.alternative_disc.evidence_strength is
  '3=forte | 2=clara | 1=secundária | 0=ausente';
comment on column public.alternative_psychological_types.evidence_strength is
  '3=forte | 2=clara | 1=secundária | 0=ausente';
comment on column public.alternative_motivators.evidence_strength is
  '3=forte | 2=clara | 1=secundária | 0=ausente';
comment on column public.alternative_operational_styles.evidence_strength is
  '3=forte | 2=clara | 1=secundária | 0=ausente';

-- ------------------------------------------------------------
-- RLS — tabelas de referência: leitura pública
-- ------------------------------------------------------------
alter table public.disc_profiles        enable row level security;
alter table public.psychological_types  enable row level security;
alter table public.motivators           enable row level security;
alter table public.operational_styles   enable row level security;

create policy "disc_profiles_select_public"
  on public.disc_profiles for select using (true);
create policy "psychological_types_select_public"
  on public.psychological_types for select using (true);
create policy "motivators_select_public"
  on public.motivators for select using (true);
create policy "operational_styles_select_public"
  on public.operational_styles for select using (true);

-- ------------------------------------------------------------
-- RLS — tabelas de vínculo: leitura para gestores autenticados
-- ------------------------------------------------------------
alter table public.alternative_disc                  enable row level security;
alter table public.alternative_psychological_types   enable row level security;
alter table public.alternative_motivators            enable row level security;
alter table public.alternative_operational_styles    enable row level security;

create policy "alternative_disc_select_authenticated"
  on public.alternative_disc for select to authenticated using (true);
create policy "alternative_psychological_types_select_authenticated"
  on public.alternative_psychological_types for select to authenticated using (true);
create policy "alternative_motivators_select_authenticated"
  on public.alternative_motivators for select to authenticated using (true);
create policy "alternative_operational_styles_select_authenticated"
  on public.alternative_operational_styles for select to authenticated using (true);
