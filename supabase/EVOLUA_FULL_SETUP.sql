-- ============================================================
-- EVOLUA — SETUP COMPLETO DO BANCO (Supabase)
-- Cole este arquivo inteiro no Supabase → SQL Editor → Run.
-- Ordem: migrations 001–009 + seed metodologia + seed motor.
-- Idempotente nos seeds; rode em um projeto novo/limpo.
-- ============================================================


-- ============================================================
-- >>> migrations/001_initial_schema.sql
-- ============================================================
-- ============================================================
-- EVOLUA — Schema inicial
-- Sprint 02: companies + profiles
-- ============================================================

-- -----------------------------------------------------------
-- COMPANIES
-- -----------------------------------------------------------
create table public.companies (
  id              uuid        primary key default gen_random_uuid(),
  name            text        not null,
  plan            text        not null default 'starter',
  licenses_total  integer     not null default 10,
  licenses_used   integer     not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- -----------------------------------------------------------
-- PROFILES (extends auth.users 1:1)
-- -----------------------------------------------------------
create table public.profiles (
  id          uuid        primary key references auth.users(id) on delete cascade,
  company_id  uuid        references public.companies(id) on delete set null,
  full_name   text,
  role        text        not null default 'gestor',
  avatar_url  text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- -----------------------------------------------------------
-- UPDATED_AT trigger
-- -----------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger companies_updated_at
  before update on public.companies
  for each row execute procedure public.set_updated_at();

create trigger profiles_updated_at
  before update on public.profiles
  for each row execute procedure public.set_updated_at();

-- -----------------------------------------------------------
-- AUTO-CRIAR PROFILE NO SIGNUP
-- -----------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1))
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- -----------------------------------------------------------
-- ROW LEVEL SECURITY
-- -----------------------------------------------------------
alter table public.companies enable row level security;
alter table public.profiles  enable row level security;

-- profiles: usuário vê e edita apenas o próprio perfil
create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id);

-- companies: usuário acessa apenas a empresa à qual pertence
create policy "companies_select_own"
  on public.companies for select
  using (
    id in (
      select company_id
      from   public.profiles
      where  id = auth.uid()
    )
  );

create policy "companies_update_own"
  on public.companies for update
  using (
    id in (
      select company_id
      from   public.profiles
      where  id = auth.uid()
    )
  );

-- -----------------------------------------------------------
-- DADOS DE DESENVOLVIMENTO (opcional — remover em produção)
-- -----------------------------------------------------------
-- Para testar sem passar pelo fluxo de convite, crie uma empresa
-- manualmente e associe ao profile após o primeiro login.
--
-- insert into public.companies (name, plan, licenses_total)
-- values ('Empresa Demo', 'starter', 50);


-- ============================================================
-- >>> migrations/002_applications.sql
-- ============================================================
-- ============================================================
-- EVOLUA — Sprint 03
-- Tabela: applications
-- ============================================================

create table public.applications (
  id               uuid        primary key default gen_random_uuid(),
  company_id       uuid        not null references public.companies(id) on delete cascade,
  name             text        not null,
  token            text        not null unique,
  status           text        not null default 'active'
                               check (status in ('draft', 'active', 'closed')),
  license_limit    integer     not null,
  responses_count  integer     not null default 0,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- índice no token para lookup da rota pública /e/{token}
create unique index applications_token_idx on public.applications (token);

-- trigger de updated_at (reutiliza a função criada na migration 001)
create trigger applications_updated_at
  before update on public.applications
  for each row execute procedure public.set_updated_at();

-- -----------------------------------------------------------
-- ROW LEVEL SECURITY
-- -----------------------------------------------------------
alter table public.applications enable row level security;

-- select: empresa só enxerga suas próprias aplicações
create policy "applications_select_own_company"
  on public.applications for select
  using (
    company_id in (
      select company_id from public.profiles where id = auth.uid()
    )
  );

-- insert: empresa só insere em si mesma
create policy "applications_insert_own_company"
  on public.applications for insert
  with check (
    company_id in (
      select company_id from public.profiles where id = auth.uid()
    )
  );

-- update: empresa só atualiza as suas
create policy "applications_update_own_company"
  on public.applications for update
  using (
    company_id in (
      select company_id from public.profiles where id = auth.uid()
    )
  );


-- ============================================================
-- >>> migrations/003_responses.sql
-- ============================================================
-- ============================================================
-- EVOLUA — Sprint 04
-- Tabela: responses + políticas públicas
-- ============================================================

-- -----------------------------------------------------------
-- RESPONSES
-- -----------------------------------------------------------
create table public.responses (
  id             uuid        primary key default gen_random_uuid(),
  application_id uuid        not null references public.applications(id) on delete cascade,
  name           text        not null,
  role           text        not null,
  status         text        not null default 'started'
                             check (status in ('started', 'completed')),
  started_at     timestamptz not null default now(),
  completed_at   timestamptz,
  created_at     timestamptz not null default now()
);

-- -----------------------------------------------------------
-- RLS — responses
-- -----------------------------------------------------------
alter table public.responses enable row level security;

-- colaborador anônimo pode inserir sua resposta
create policy "responses_insert_anon"
  on public.responses for select
  to anon
  using (true);

create policy "responses_insert_public"
  on public.responses for insert
  to anon
  with check (true);

-- gestores autenticados enxergam respostas das suas aplicações
create policy "responses_select_authenticated"
  on public.responses for select
  to authenticated
  using (
    application_id in (
      select a.id
      from   public.applications a
      join   public.profiles    p on p.company_id = a.company_id
      where  p.id = auth.uid()
    )
  );

create policy "responses_update_authenticated"
  on public.responses for update
  to authenticated
  using (
    application_id in (
      select a.id
      from   public.applications a
      join   public.profiles    p on p.company_id = a.company_id
      where  p.id = auth.uid()
    )
  );

-- -----------------------------------------------------------
-- RLS — applications (leitura pública por token)
-- A ser adicionada à tabela criada em 002.
-- Colaboradores anônimos precisam ler a aplicação para validar.
-- -----------------------------------------------------------
create policy "applications_select_anon"
  on public.applications for select
  to anon
  using (true);

-- -----------------------------------------------------------
-- TRIGGER: incrementar responses_count de forma atômica
-- Roda com security definer (como dono da tabela) para contornar RLS.
-- -----------------------------------------------------------
create or replace function public.increment_responses_count()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  update public.applications
  set    responses_count = responses_count + 1
  where  id = new.application_id;
  return new;
end;
$$;

create trigger on_response_created
  after insert on public.responses
  for each row execute procedure public.increment_responses_count();


-- ============================================================
-- >>> migrations/004_consolidation.sql
-- ============================================================
-- ============================================================
-- EVOLUA — Sprint 04.1 — Consolidação Arquitetural
-- ============================================================

-- -----------------------------------------------------------
-- AJUSTE 01: novos campos em responses
-- progress e current_question para rastrear avanço na Sprint 05
-- -----------------------------------------------------------
alter table public.responses
  add column progress         integer not null default 0,
  add column current_question integer not null default 1;

-- -----------------------------------------------------------
-- AJUSTE 02: adicionar status 'abandoned'
-- Remove o check existente e recria com o novo valor
-- -----------------------------------------------------------
do $$
declare
  v_constraint text;
begin
  select conname
    into v_constraint
    from pg_constraint
   where conrelid = 'public.responses'::regclass
     and contype  = 'c'
     and pg_get_constraintdef(oid) like '%started%';

  if v_constraint is not null then
    execute 'alter table public.responses drop constraint ' || quote_ident(v_constraint);
  end if;
end $$;

alter table public.responses
  add constraint responses_status_check
  check (status in ('started', 'completed', 'abandoned'));

-- -----------------------------------------------------------
-- AJUSTE 03: remover SELECT anon de responses
-- Colaborador anônimo só precisa de INSERT, não de SELECT.
-- -----------------------------------------------------------
drop policy if exists "responses_insert_anon" on public.responses;

-- -----------------------------------------------------------
-- AJUSTE 04: remover trigger de incremento automático
-- responses_count será incrementado apenas na primeira resposta (Sprint 05).
-- Até lá, o campo ficará em 0 para respostas recém-criadas.
-- ATENÇÃO: a validação "full" em validateApplicationToken ficará inativa
-- até a Sprint 05 reimplementar o incremento.
-- -----------------------------------------------------------
drop trigger if exists on_response_created on public.responses;
drop function if exists public.increment_responses_count();


-- ============================================================
-- >>> migrations/005_questions.sql
-- ============================================================
-- ============================================================
-- EVOLUA — Sprint 05 — Questionário: Perguntas, Alternativas e Respostas
-- ============================================================

-- -----------------------------------------------------------
-- TABELA: questions
-- -----------------------------------------------------------
create table public.questions (
  id          uuid        primary key default gen_random_uuid(),
  order_index integer     not null unique,
  title       text        not null,
  active      boolean     not null default true,
  created_at  timestamptz not null default now()
);

-- -----------------------------------------------------------
-- TABELA: alternatives
-- -----------------------------------------------------------
create table public.alternatives (
  id          uuid        primary key default gen_random_uuid(),
  question_id uuid        not null references public.questions(id) on delete cascade,
  order_index integer     not null,
  title       text        not null,
  description text,
  created_at  timestamptz not null default now(),
  unique (question_id, order_index)
);

-- -----------------------------------------------------------
-- TABELA: answers
-- -----------------------------------------------------------
create table public.answers (
  id             uuid        primary key default gen_random_uuid(),
  response_id    uuid        not null references public.responses(id) on delete cascade,
  question_id    uuid        not null references public.questions(id) on delete cascade,
  alternative_id uuid        not null references public.alternatives(id) on delete cascade,
  created_at     timestamptz not null default now(),
  unique (response_id, question_id)
);

-- -----------------------------------------------------------
-- RLS: questions — leitura pública
-- -----------------------------------------------------------
alter table public.questions enable row level security;

create policy "questions_select_public"
  on public.questions for select
  using (true);

-- -----------------------------------------------------------
-- RLS: alternatives — leitura pública
-- -----------------------------------------------------------
alter table public.alternatives enable row level security;

create policy "alternatives_select_public"
  on public.alternatives for select
  using (true);

-- -----------------------------------------------------------
-- RLS: answers
-- -----------------------------------------------------------
alter table public.answers enable row level security;

create policy "answers_insert_anon"
  on public.answers for insert
  to anon
  with check (true);

create policy "answers_select_authenticated"
  on public.answers for select
  to authenticated
  using (
    response_id in (
      select r.id
        from public.responses r
        join public.applications a on a.id = r.application_id
        join public.profiles p on p.company_id = a.company_id
       where p.id = auth.uid()
    )
  );

-- -----------------------------------------------------------
-- RLS: responses — políticas adicionais para o questionário
-- O colaborador é anônimo; o Server Action precisa ler e atualizar
-- o registro da sua jornada para exibir a questão correta e
-- salvar o progresso.
-- -----------------------------------------------------------
create policy "responses_select_anon_questionnaire"
  on public.responses for select
  to anon
  using (true);

create policy "responses_update_anon_questionnaire"
  on public.responses for update
  to anon
  using (true);

-- -----------------------------------------------------------
-- FUNÇÃO: increment_application_responses_count
-- Incremento atômico de responses_count na primeira resposta.
-- Usa security definer para bypassar RLS em applications.
-- -----------------------------------------------------------
create or replace function public.increment_application_responses_count(app_id uuid)
  returns void
  language sql
  security definer set search_path = public
as $$
  update public.applications
     set responses_count = responses_count + 1
   where id = app_id;
$$;


-- ============================================================
-- >>> migrations/006_answers_refinements.sql
-- ============================================================
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


-- ============================================================
-- >>> migrations/007_methodology_schema.sql
-- ============================================================
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


-- ============================================================
-- >>> migrations/008_alternative_indicators_strength.sql
-- ============================================================
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


-- ============================================================
-- >>> migrations/009_motor_dimensions.sql
-- ============================================================
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


-- ============================================================

-- ============================================================
-- >>> migrations/010_gestor_company_signup.sql
-- ============================================================
-- ============================================================
-- EVOLUA — Sprint 10 — Auto-cadastro do Gestor + criação da Empresa
-- ============================================================
-- Estende handle_new_user: no signup do gestor, além do profile,
-- cria automaticamente a EMPRESA e já vincula o profile a ela como
-- 'gestor'. Roda como SECURITY DEFINER, então cria a empresa sem
-- esbarrar na RLS (não há policy de INSERT em companies — proposital,
-- toda criação de empresa passa por aqui).
--
-- Metadados esperados no signup (options.data):
--   full_name    -> nome do gestor
--   company_name -> nome da empresa
-- ============================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  new_company_id uuid;
  v_company_name text;
  v_full_name    text;
begin
  v_company_name := coalesce(
    nullif(trim(new.raw_user_meta_data->>'company_name'), ''),
    'Minha Empresa'
  );
  v_full_name := coalesce(
    nullif(trim(new.raw_user_meta_data->>'full_name'), ''),
    split_part(new.email, '@', 1)
  );

  -- cria a empresa do gestor (plano/licenças usam os defaults da tabela)
  insert into public.companies (name)
  values (v_company_name)
  returning id into new_company_id;

  -- cria o profile já vinculado à empresa, como gestor
  insert into public.profiles (id, company_id, full_name, role)
  values (new.id, new_company_id, v_full_name, 'gestor');

  return new;
end;
$$;


-- ============================================================
-- >>> migrations/011_rls_hardening.sql
-- ============================================================
-- ============================================================
-- EVOLUA — Sprint 11 — RLS Hardening
-- ============================================================
-- ACHADO (auditoria de RLS, item 7 do plano de melhorias):
-- As migrations 003 e 005 concederam a `anon` policies de SELECT/UPDATE
-- com `using(true)` nas tabelas `responses` e `applications` — ou seja,
-- QUALQUER requisição anônima (usando a chave `anon`, que é pública e
-- vai no bundle do navegador) podia:
--   • listar TODAS as respostas de TODAS as empresas (nome, cargo,
--     progresso de cada colaborador) via GET .../responses?select=*
--   • alterar QUALQUER resposta via PATCH .../responses?id=eq.<qualquer>
--   • listar TODAS as aplicações de TODAS as empresas, incluindo o
--     `token` de cada uma — o "segredo" que protege o link do
--     colaborador — via GET .../applications?select=*
-- Havia ainda uma policy duplicada e com nome trocado
-- ("responses_insert_anon" que na verdade era FOR SELECT).
--
-- Isso NÃO é um problema teórico: com `using(true)`, o Postgres
-- devolve todas as linhas independentemente do filtro que o cliente
-- envie — filtrar por token/id no app não impede um dump completo
-- direto contra a API REST do Supabase.
--
-- CORREÇÃO: troca as policies "abertas" por funções SECURITY DEFINER
-- (mesmo padrão já usado em increment_application_responses_count).
-- O `anon` deixa de ter SELECT/UPDATE direto nessas tabelas — só pode
-- chamar as funções abaixo, que exigem o ID/token específico (o
-- "segredo" que o colaborador já possui via link/cookie httpOnly) e
-- devolvem/alteram no máximo 1 linha. Não é possível listar nem
-- alterar em lote.
--
-- O INSERT anônimo em `responses`/`answers` permanece aberto
-- (with check(true)) — inserir uma linha nova não expõe nem permite
-- ler/alterar dados de terceiros, e o fluxo do colaborador depende
-- disso para criar a própria jornada.
-- ============================================================

-- -----------------------------------------------------------
-- 1. Remove as policies abertas (o problema)
-- -----------------------------------------------------------
drop policy if exists "responses_insert_anon" on public.responses; -- nome errado: era FOR SELECT, duplicava a de baixo
drop policy if exists "responses_select_anon_questionnaire" on public.responses;
drop policy if exists "responses_update_anon_questionnaire" on public.responses;
drop policy if exists "applications_select_anon" on public.applications;

-- -----------------------------------------------------------
-- 2. Funções SECURITY DEFINER — leitura/escrita pontual por segredo
-- -----------------------------------------------------------

-- Busca 1 aplicação pelo token (o link público do colaborador).
create or replace function public.get_application_by_token(p_token text)
  returns setof public.applications
  language sql
  security definer set search_path = public
  stable
as $$
  select * from public.applications where token = p_token limit 1;
$$;

-- Busca 1 aplicação pelo id (usada após a validação inicial por token,
-- ex.: ao criar a resposta do colaborador).
create or replace function public.get_application_by_id(p_id uuid)
  returns setof public.applications
  language sql
  security definer set search_path = public
  stable
as $$
  select * from public.applications where id = p_id limit 1;
$$;

-- Busca 1 resposta pelo id (o segredo do cookie httpOnly evolua_rid).
create or replace function public.get_response_by_id(p_id uuid)
  returns setof public.responses
  language sql
  security definer set search_path = public
  stable
as $$
  select * from public.responses where id = p_id limit 1;
$$;

-- Atualiza o progresso da própria resposta (id = o segredo que o
-- colaborador já possui). Não permite alterar outras colunas nem
-- outras linhas.
create or replace function public.update_response_progress(
  p_id uuid,
  p_progress integer,
  p_current_question integer,
  p_status text default null,
  p_completed_at timestamptz default null
)
  returns void
  language plpgsql
  security definer set search_path = public
as $$
begin
  update public.responses
     set progress = p_progress,
         current_question = p_current_question,
         status = coalesce(p_status, status),
         completed_at = coalesce(p_completed_at, completed_at)
   where id = p_id;
end;
$$;

-- Execução liberada para anon e authenticated (gestor também pode usar).
grant execute on function public.get_application_by_token(text) to anon, authenticated;
grant execute on function public.get_application_by_id(uuid) to anon, authenticated;
grant execute on function public.get_response_by_id(uuid) to anon, authenticated;
grant execute on function public.update_response_progress(uuid, integer, integer, text, timestamptz) to anon, authenticated;

-- -----------------------------------------------------------
-- NOTA: com as policies abertas removidas e nenhuma outra policy de
-- SELECT/UPDATE para `anon` restando em `responses`/`applications`,
-- o RLS passa a negar por padrão qualquer SELECT/UPDATE direto de
-- `anon` nessas duas tabelas — só as funções acima (que rodam com
-- privilégio do dono, ignorando RLS internamente) conseguem ler/
-- escrever, sempre limitadas a 1 linha específica.
-- `responses_insert_public` (INSERT anon) permanece intacta.
-- -----------------------------------------------------------


-- ============================================================
-- >>> migrations/012_rls_hardening_insert_fix.sql
-- ============================================================
-- ============================================================
-- EVOLUA — Sprint 12 — RLS Hardening (correção de regressão da 011)
-- ============================================================
-- ACHADO ao validar a migration 011: remover TODO SELECT de `anon`
-- em `applications` e `responses` quebrou os INSERTs anônimos em
-- `responses` (FK para applications) e `answers` (FK para responses).
--
-- Motivo: a validação de chave estrangeira do Postgres, ao inserir
-- uma linha que referencia outra tabela, precisa "enxergar" a linha
-- referenciada sob a ótica de RLS do papel que está inserindo. Sem
-- nenhuma policy de SELECT para `anon` nas tabelas referenciadas
-- (applications, responses), o Postgres não consegue confirmar a FK
-- e rejeita o INSERT com "new row violates row-level security
-- policy" (42501) — mesmo a tabela sendo a de destino do INSERT.
--
-- Reproduzido e confirmado via teste direto contra a API REST antes
-- desta correção.
--
-- CORREÇÃO: move as duas escritas para funções SECURITY DEFINER
-- (mesmo padrão da 011). Rodando com privilégio do dono, a validação
-- de FK enxerga as tabelas referenciadas independentemente do RLS do
-- chamador — sem reabrir nenhum SELECT em massa para `anon`.
-- As regras de negócio (aplicação ativa, licença disponível, resposta
-- em andamento, alternativa pertence à questão) passam a ser
-- garantidas dentro da própria função, como camada extra de defesa.
-- ============================================================

-- Cria a resposta do colaborador, validando a aplicação por dentro
-- (mesmas regras que já existiam em response.actions.ts).
create or replace function public.create_response(
  p_application_id uuid,
  p_name text,
  p_role text
)
  returns setof public.responses
  language plpgsql
  security definer set search_path = public
as $$
declare
  v_app public.applications;
  v_new_id uuid;
begin
  select * into v_app from public.applications where id = p_application_id;

  if not found then
    raise exception 'application_not_found';
  end if;
  if v_app.status <> 'active' then
    raise exception 'application_not_active';
  end if;
  if v_app.responses_count >= v_app.license_limit then
    raise exception 'application_full';
  end if;

  insert into public.responses (application_id, name, role, status, started_at)
  values (p_application_id, p_name, p_role, 'started', now())
  returning id into v_new_id;

  return query select * from public.responses where id = v_new_id;
end;
$$;

-- Salva a resposta de uma situação, validando por dentro que a
-- resposta está em andamento e que a alternativa pertence à questão.
-- Idempotente (ON CONFLICT DO NOTHING) — questão já respondida não é erro.
create or replace function public.save_answer(
  p_response_id uuid,
  p_question_id uuid,
  p_alternative_id uuid
)
  returns void
  language plpgsql
  security definer set search_path = public
as $$
declare
  v_response public.responses;
  v_alt_ok boolean;
begin
  select * into v_response from public.responses where id = p_response_id;

  if not found then
    raise exception 'response_not_found';
  end if;
  if v_response.status <> 'started' then
    raise exception 'response_already_completed';
  end if;

  select exists(
    select 1 from public.alternatives
     where id = p_alternative_id and question_id = p_question_id
  ) into v_alt_ok;

  if not v_alt_ok then
    raise exception 'invalid_alternative';
  end if;

  insert into public.answers (response_id, question_id, alternative_id)
  values (p_response_id, p_question_id, p_alternative_id)
  on conflict (response_id, question_id) do nothing;
end;
$$;

grant execute on function public.create_response(uuid, text, text) to anon, authenticated;
grant execute on function public.save_answer(uuid, uuid, uuid) to anon, authenticated;


-- ============================================================
-- >>> migrations/013_rls_insert_constraints.sql
-- ============================================================
-- ============================================================
-- EVOLUA — Sprint 13 — RLS: restringe o INSERT anônimo às regras de negócio
-- ============================================================
-- ACHADO ao testar a 012: `responses_insert_public` e `answers_insert_anon`
-- sempre tiveram `with check(true)` (desde a migration 003/005) — ou seja,
-- o INSERT direto via API sempre foi IRRESTRITO para `anon`, com ou sem
-- as funções create_response/save_answer. Confirmado empiricamente: um
-- INSERT direto contra a tabela `responses` (sem passar pela RPC)
-- retornou HTTP 201 e a linha foi persistida — mesmo para uma aplicação
-- fechada ou lotada, pois `with check(true)` nunca validou nada.
--
-- As regras de negócio (aplicação ativa, licença disponível, resposta em
-- andamento, alternativa pertence à questão) só existiam no código
-- TypeScript das Server Actions — útil para a UX, mas não é uma barreira
-- real, já que qualquer requisição direta à API REST (com a chave `anon`,
-- pública) contorna esse código.
--
-- CORREÇÃO: move a validação de negócio para o WITH CHECK da própria
-- policy de INSERT, via função SECURITY DEFINER (mesmo padrão das
-- migrations anteriores) — assim a regra vale mesmo para quem insere
-- direto pela API, sem depender do app respeitar o fluxo.
-- ============================================================

-- Aplicação está ativa e tem licença disponível?
create or replace function public.application_accepts_responses(p_application_id uuid)
  returns boolean
  language sql
  security definer set search_path = public
  stable
as $$
  select exists (
    select 1 from public.applications
     where id = p_application_id
       and status = 'active'
       and responses_count < license_limit
  );
$$;

-- A resposta está em andamento E a alternativa pertence à questão?
create or replace function public.answer_is_valid_for_insert(
  p_response_id uuid,
  p_question_id uuid,
  p_alternative_id uuid
)
  returns boolean
  language sql
  security definer set search_path = public
  stable
as $$
  select
    exists (
      select 1 from public.responses
       where id = p_response_id and status = 'started'
    )
    and exists (
      select 1 from public.alternatives
       where id = p_alternative_id and question_id = p_question_id
    );
$$;

grant execute on function public.application_accepts_responses(uuid) to anon, authenticated;
grant execute on function public.answer_is_valid_for_insert(uuid, uuid, uuid) to anon, authenticated;

-- Recria as policies de INSERT com a validação real no WITH CHECK.
drop policy if exists "responses_insert_public" on public.responses;
create policy "responses_insert_public"
  on public.responses for insert
  to anon
  with check ( public.application_accepts_responses(application_id) );

drop policy if exists "answers_insert_anon" on public.answers;
create policy "answers_insert_anon"
  on public.answers for insert
  to anon
  with check ( public.answer_is_valid_for_insert(response_id, question_id, alternative_id) );

-- -----------------------------------------------------------
-- NOTA: create_response()/save_answer() (migration 012) continuam
-- funcionando sem alteração — rodam como SECURITY DEFINER (dono da
-- tabela, que tem BYPASSRLS), então esta nova checagem no WITH CHECK
-- não as afeta. O que muda é que, agora, um INSERT direto contra a
-- tabela (contornando as funções) também precisa satisfazer a mesma
-- regra de negócio — não é mais `with check(true)`.
-- -----------------------------------------------------------

-- >>> seeds/002_official_methodology.sql
-- ============================================================
-- ============================================================
-- EVOLUA — Seed Oficial da Metodologia
-- Sprint 06 — Versão 1.0
--
-- Estrutura:
--   7  pilares     (IDs: 1000...0001 a 1000...0007)
--   35 indicadores (IDs: 2000...0001 a 2000...0035)
--   28 situações   (IDs: 3000...0001 a 3000...0028)
--  112 alternativas (IDs: 4000...QQQQ-000L onde QQQQ=situação L=1-4)
--
-- Idempotência:
--   • Envolto em transação
--   • Remove questões e alternativas fora do conjunto oficial
--     (limpa seed de teste antes de inserir dados oficiais)
--   • INSERT ... ON CONFLICT (id) DO UPDATE para re-execuções seguras
-- ============================================================

begin;

-- ============================================================
-- LIMPEZA: remove dados de desenvolvimento fora do conjunto oficial
-- Necessário pois questões de teste usam gen_random_uuid() e
-- conflitam com order_index UNIQUE das questões oficiais.
-- ON DELETE CASCADE propaga para alternatives e answers.
-- ============================================================

delete from public.questions
where id not in (
  '30000000-0000-0000-0000-000000000001',
  '30000000-0000-0000-0000-000000000002',
  '30000000-0000-0000-0000-000000000003',
  '30000000-0000-0000-0000-000000000004',
  '30000000-0000-0000-0000-000000000005',
  '30000000-0000-0000-0000-000000000006',
  '30000000-0000-0000-0000-000000000007',
  '30000000-0000-0000-0000-000000000008',
  '30000000-0000-0000-0000-000000000009',
  '30000000-0000-0000-0000-000000000010',
  '30000000-0000-0000-0000-000000000011',
  '30000000-0000-0000-0000-000000000012',
  '30000000-0000-0000-0000-000000000013',
  '30000000-0000-0000-0000-000000000014',
  '30000000-0000-0000-0000-000000000015',
  '30000000-0000-0000-0000-000000000016',
  '30000000-0000-0000-0000-000000000017',
  '30000000-0000-0000-0000-000000000018',
  '30000000-0000-0000-0000-000000000019',
  '30000000-0000-0000-0000-000000000020',
  '30000000-0000-0000-0000-000000000021',
  '30000000-0000-0000-0000-000000000022',
  '30000000-0000-0000-0000-000000000023',
  '30000000-0000-0000-0000-000000000024',
  '30000000-0000-0000-0000-000000000025',
  '30000000-0000-0000-0000-000000000026',
  '30000000-0000-0000-0000-000000000027',
  '30000000-0000-0000-0000-000000000028'
);

-- ============================================================
-- PILARES (7)
-- ============================================================

insert into public.pillars (id, number, name, description, active) values
  ('10000000-0000-0000-0000-000000000001', 1, 'Autogestão',
   'Capacidade de gerenciar a si mesmo com responsabilidade, equilíbrio e disciplina.', true),

  ('10000000-0000-0000-0000-000000000002', 2, 'Comunicação',
   'Habilidade de se expressar com clareza, ouvir com profundidade e se adaptar ao interlocutor.', true),

  ('10000000-0000-0000-0000-000000000003', 3, 'Relacionamento',
   'Qualidade das conexões interpessoais, gestão de conflitos e construção de confiança.', true),

  ('10000000-0000-0000-0000-000000000004', 4, 'Orientação a Resultados',
   'Foco consistente em metas, entregas e qualidade mesmo sob pressão.', true),

  ('10000000-0000-0000-0000-000000000005', 5, 'Liderança',
   'Capacidade de influenciar, tomar decisões e desenvolver pessoas ao redor.', true),

  ('10000000-0000-0000-0000-000000000006', 6, 'Inovação e Adaptação',
   'Abertura ao novo, criatividade prática e resiliência diante de mudanças.', true),

  ('10000000-0000-0000-0000-000000000007', 7, 'Desenvolvimento Contínuo',
   'Compromisso com o crescimento próprio, aprendizado constante e compartilhamento de conhecimento.', true)

on conflict (id) do update set
  number      = excluded.number,
  name        = excluded.name,
  description = excluded.description,
  active      = excluded.active;

-- ============================================================
-- INDICADORES (35 — 5 por pilar)
-- ============================================================

insert into public.indicators (id, code, name, description, pillar_number, active) values

  -- Pilar 1 — Autogestão
  ('20000000-0000-0000-0000-000000000001', 'I01', 'Responsabilidade Pessoal',
   'Assume compromissos, responde pelos próprios resultados e não transfere a culpa.', 1, true),
  ('20000000-0000-0000-0000-000000000002', 'I02', 'Gestão Emocional',
   'Regula as próprias emoções diante de situações de pressão, conflito ou adversidade.', 1, true),
  ('20000000-0000-0000-0000-000000000003', 'I03', 'Autoconfiança',
   'Age com segurança e convicção nas próprias capacidades, mesmo em contextos desafiadores.', 1, true),
  ('20000000-0000-0000-0000-000000000004', 'I04', 'Disciplina e Consistência',
   'Mantém foco e comprometimento com regularidade ao longo do tempo, sem supervisão constante.', 1, true),
  ('20000000-0000-0000-0000-000000000005', 'I05', 'Clareza de Propósito',
   'Conhece seus valores e os utiliza como guia para decisões e ações cotidianas.', 1, true),

  -- Pilar 2 — Comunicação
  ('20000000-0000-0000-0000-000000000006', 'I06', 'Clareza na Expressão',
   'Transmite ideias de forma objetiva, estruturada e compreensível para diferentes públicos.', 2, true),
  ('20000000-0000-0000-0000-000000000007', 'I07', 'Escuta Ativa',
   'Ouve com atenção genuína e busca compreender antes de responder ou julgar.', 2, true),
  ('20000000-0000-0000-0000-000000000008', 'I08', 'Assertividade',
   'Posiciona-se com clareza e respeito, sem passividade nem agressividade.', 2, true),
  ('20000000-0000-0000-0000-000000000009', 'I09', 'Feedback Construtivo',
   'Oferece e recebe feedbacks de forma objetiva e orientada ao crescimento.', 2, true),
  ('20000000-0000-0000-0000-000000000010', 'I10', 'Comunicação Adaptada',
   'Ajusta linguagem e estilo de acordo com o interlocutor e o contexto da conversa.', 2, true),

  -- Pilar 3 — Relacionamento
  ('20000000-0000-0000-0000-000000000011', 'I11', 'Empatia',
   'Compreende e considera a perspectiva e o estado emocional do outro antes de agir.', 3, true),
  ('20000000-0000-0000-0000-000000000012', 'I12', 'Colaboração',
   'Contribui ativamente para o sucesso coletivo, além das próprias metas individuais.', 3, true),
  ('20000000-0000-0000-0000-000000000013', 'I13', 'Gestão de Conflitos',
   'Administra divergências de forma construtiva, preservando o relacionamento.', 3, true),
  ('20000000-0000-0000-0000-000000000014', 'I14', 'Construção de Confiança',
   'Age com consistência, transparência e integridade nas relações interpessoais.', 3, true),
  ('20000000-0000-0000-0000-000000000015', 'I15', 'Influência Positiva',
   'Gera impacto no comportamento e motivação dos outros de forma ética e genuína.', 3, true),

  -- Pilar 4 — Orientação a Resultados
  ('20000000-0000-0000-0000-000000000016', 'I16', 'Planejamento e Organização',
   'Estrutura tarefas e recursos de forma eficiente para atingir os objetivos definidos.', 4, true),
  ('20000000-0000-0000-0000-000000000017', 'I17', 'Foco e Priorização',
   'Identifica o que é essencial e direciona o esforço para o que gera maior impacto.', 4, true),
  ('20000000-0000-0000-0000-000000000018', 'I18', 'Gestão do Tempo',
   'Utiliza o tempo com intencionalidade e eficiência, respeitando prazos e compromissos.', 4, true),
  ('20000000-0000-0000-0000-000000000019', 'I19', 'Qualidade nas Entregas',
   'Mantém padrão elevado de qualidade mesmo sob pressão e com recursos limitados.', 4, true),
  ('20000000-0000-0000-0000-000000000020', 'I20', 'Resiliência sob Pressão',
   'Mantém desempenho e equilíbrio diante de adversidades, prazos e frustrações.', 4, true),

  -- Pilar 5 — Liderança
  ('20000000-0000-0000-0000-000000000021', 'I21', 'Visão Estratégica',
   'Compreende o cenário amplo e conecta as ações cotidianas ao propósito maior da organização.', 5, true),
  ('20000000-0000-0000-0000-000000000022', 'I22', 'Tomada de Decisão',
   'Decide com critério, agilidade e responsabilidade mesmo sob incerteza ou pressão.', 5, true),
  ('20000000-0000-0000-0000-000000000023', 'I23', 'Desenvolvimento de Pessoas',
   'Investe ativamente no crescimento e evolução dos outros ao seu redor.', 5, true),
  ('20000000-0000-0000-0000-000000000024', 'I24', 'Delegação Eficaz',
   'Distribui responsabilidades com clareza, confiança e acompanhamento adequado.', 5, true),
  ('20000000-0000-0000-0000-000000000025', 'I25', 'Inspiração e Motivação',
   'Mobiliza pessoas ao redor de um propósito com entusiasmo e coerência de comportamento.', 5, true),

  -- Pilar 6 — Inovação e Adaptação
  ('20000000-0000-0000-0000-000000000026', 'I26', 'Mentalidade de Crescimento',
   'Vê desafios e erros como oportunidades de aprender e evoluir continuamente.', 6, true),
  ('20000000-0000-0000-0000-000000000027', 'I27', 'Criatividade Prática',
   'Gera soluções originais e aplicáveis para problemas reais do cotidiano.', 6, true),
  ('20000000-0000-0000-0000-000000000028', 'I28', 'Tolerância à Ambiguidade',
   'Opera com eficiência mesmo em cenários incertos, mal definidos ou em constante mudança.', 6, true),
  ('20000000-0000-0000-0000-000000000029', 'I29', 'Abertura ao Feedback',
   'Recebe perspectivas externas com receptividade e as utiliza para crescer.', 6, true),
  ('20000000-0000-0000-0000-000000000030', 'I30', 'Adaptabilidade',
   'Ajusta comportamentos e estratégias frente a mudanças com agilidade e sem resistência.', 6, true),

  -- Pilar 7 — Desenvolvimento Contínuo
  ('20000000-0000-0000-0000-000000000031', 'I31', 'Autocrítica Construtiva',
   'Avalia seus próprios resultados com honestidade e sem autossabotagem ou excesso de autocrítica.', 7, true),
  ('20000000-0000-0000-0000-000000000032', 'I32', 'Busca por Aprendizado',
   'Procura ativamente novos conhecimentos, habilidades e perspectivas de forma contínua.', 7, true),
  ('20000000-0000-0000-0000-000000000033', 'I33', 'Aplicação do Conhecimento',
   'Transforma o que aprende em ação prática e resultados concretos no dia a dia.', 7, true),
  ('20000000-0000-0000-0000-000000000034', 'I34', 'Compartilhamento de Conhecimento',
   'Multiplica o que sabe, contribuindo ativamente para o crescimento dos outros.', 7, true),
  ('20000000-0000-0000-0000-000000000035', 'I35', 'Visão de Futuro',
   'Pensa no longo prazo e age hoje para construir uma trajetória profissional sustentável.', 7, true)

on conflict (id) do update set
  code          = excluded.code,
  name          = excluded.name,
  description   = excluded.description,
  pillar_number = excluded.pillar_number,
  active        = excluded.active;

-- ============================================================
-- SITUAÇÕES (28 — 4 por pilar)
-- ============================================================

insert into public.questions (id, order_index, pillar_number, title, dimension, active) values

  -- ── PILAR 1 — AUTOGESTÃO (Q01–Q04) ──────────────────────

  ('30000000-0000-0000-0000-000000000001', 1, 1,
   'Você cometeu um erro em uma entrega importante que causou retrabalho para o seu time. Como você reage?',
   'Responsabilidade Pessoal', true),

  ('30000000-0000-0000-0000-000000000002', 2, 1,
   'Em uma reunião, um colega faz uma crítica direta e incisiva ao seu trabalho na frente de todos. Como você age?',
   'Gestão Emocional', true),

  ('30000000-0000-0000-0000-000000000003', 3, 1,
   'Você tem um projeto estratégico de longo prazo sem prazo fixo e com pouca visibilidade do gestor. Como você garante o avanço?',
   'Disciplina e Consistência', true),

  ('30000000-0000-0000-0000-000000000004', 4, 1,
   'Você é convidado para representar seu time em uma apresentação para uma diretoria que você não conhece. Como você se prepara?',
   'Autoconfiança', true),

  -- ── PILAR 2 — COMUNICAÇÃO (Q05–Q08) ──────────────────────

  ('30000000-0000-0000-0000-000000000005', 5, 2,
   'Você precisa comunicar uma mudança de processo complexa para um time com perfis muito diferentes — técnicos e operacionais. Como você age?',
   'Clareza na Expressão', true),

  ('30000000-0000-0000-0000-000000000006', 6, 2,
   'Em uma conversa com um colaborador que está passando por dificuldades, você percebe que ele está omitindo parte do problema. O que você faz?',
   'Escuta Ativa', true),

  ('30000000-0000-0000-0000-000000000007', 7, 2,
   'Você discorda de uma decisão do seu gestor e acredita que ela vai impactar negativamente o resultado da área. O que você faz?',
   'Assertividade', true),

  ('30000000-0000-0000-0000-000000000008', 8, 2,
   'Você precisa dar um feedback difícil a um colega sobre um comportamento recorrente que está afetando a dinâmica do time. Como você age?',
   'Feedback Construtivo', true),

  -- ── PILAR 3 — RELACIONAMENTO (Q09–Q12) ───────────────────

  ('30000000-0000-0000-0000-000000000009', 9, 3,
   'Seu time está sobrecarregado e você concluiu todas as suas entregas antes do prazo. O que você faz com o tempo disponível?',
   'Colaboração', true),

  ('30000000-0000-0000-0000-000000000010', 10, 3,
   'Dois membros do seu time estão em conflito aberto e isso está afetando o ambiente e as entregas. Como você age?',
   'Gestão de Conflitos', true),

  ('30000000-0000-0000-0000-000000000011', 11, 3,
   'Um colega está passando por um momento pessoal muito difícil e sua performance caiu visivelmente. Como você age?',
   'Empatia', true),

  ('30000000-0000-0000-0000-000000000012', 12, 3,
   'Um novo membro entra no time e demonstra insegurança para tomar iniciativas ou compartilhar ideias. Como você age?',
   'Construção de Confiança', true),

  -- ── PILAR 4 — ORIENTAÇÃO A RESULTADOS (Q13–Q16) ──────────

  ('30000000-0000-0000-0000-000000000013', 13, 4,
   'Você assumiu a liderança de um projeto sem documentação disponível e com prazo apertado. Como você começa?',
   'Planejamento e Organização', true),

  ('30000000-0000-0000-0000-000000000014', 14, 4,
   'Você tem muito mais tarefas do que consegue entregar no dia. Como você decide o que fazer?',
   'Foco e Priorização', true),

  ('30000000-0000-0000-0000-000000000015', 15, 4,
   'Um projeto importante no qual você investiu meses de trabalho falhou e precisou ser encerrado. Como você reage?',
   'Resiliência sob Pressão', true),

  ('30000000-0000-0000-0000-000000000016', 16, 4,
   'Você está sob pressão para entregar rápido, mas percebe que a qualidade da entrega está claramente comprometida. O que faz?',
   'Qualidade nas Entregas', true),

  -- ── PILAR 5 — LIDERANÇA (Q17–Q20) ────────────────────────

  ('30000000-0000-0000-0000-000000000017', 17, 5,
   'Você precisa tomar uma decisão importante com informações incompletas e sem tempo para consultar seu gestor. O que faz?',
   'Tomada de Decisão', true),

  ('30000000-0000-0000-0000-000000000018', 18, 5,
   'Você precisa delegar uma tarefa estratégica para um colaborador que ainda não a realizou antes. Como você conduz esse processo?',
   'Delegação Eficaz', true),

  ('30000000-0000-0000-0000-000000000019', 19, 5,
   'Um colaborador do seu time tem potencial claro, mas ainda não entrega de forma consistente e previsível. Como você age?',
   'Desenvolvimento de Pessoas', true),

  ('30000000-0000-0000-0000-000000000020', 20, 5,
   'Seu time está visivelmente desmotivado após um período de mudanças e incertezas. Como você age como líder?',
   'Inspiração e Motivação', true),

  -- ── PILAR 6 — INOVAÇÃO E ADAPTAÇÃO (Q21–Q24) ─────────────

  ('30000000-0000-0000-0000-000000000021', 21, 6,
   'A empresa anuncia uma reestruturação significativa que impacta diretamente a sua área e o seu papel. Como você reage?',
   'Adaptabilidade', true),

  ('30000000-0000-0000-0000-000000000022', 22, 6,
   'Você identifica um problema recorrente no processo do seu time que ninguém ainda endereçou de forma definitiva. O que você faz?',
   'Criatividade Prática', true),

  ('30000000-0000-0000-0000-000000000023', 23, 6,
   'Você recebe uma nova responsabilidade importante sem descrição clara do que se espera de você nesse papel. Como você age?',
   'Tolerância à Ambiguidade', true),

  ('30000000-0000-0000-0000-000000000024', 24, 6,
   'Você é alocado em um projeto estratégico fora da sua área de especialidade. Como você reage?',
   'Mentalidade de Crescimento', true),

  -- ── PILAR 7 — DESENVOLVIMENTO CONTÍNUO (Q25–Q28) ─────────

  ('30000000-0000-0000-0000-000000000025', 25, 7,
   'Você percebe que sua área está evoluindo rapidamente e seu conhecimento atual está ficando defasado. O que faz?',
   'Busca por Aprendizado', true),

  ('30000000-0000-0000-0000-000000000026', 26, 7,
   'Após um período de trabalho intenso, você percebe que seus resultados ficaram abaixo das suas próprias expectativas. Como você reage?',
   'Autocrítica Construtiva', true),

  ('30000000-0000-0000-0000-000000000027', 27, 7,
   'Você desenvolveu uma solução que gerou resultados concretos para um desafio recorrente do seu trabalho. O que faz?',
   'Compartilhamento de Conhecimento', true),

  ('30000000-0000-0000-0000-000000000028', 28, 7,
   'Você está em uma carreira que valoriza, mas percebe que o mercado está mudando e seu perfil pode perder relevância nos próximos anos. O que faz?',
   'Visão de Futuro', true)

on conflict (id) do update set
  order_index   = excluded.order_index,
  pillar_number = excluded.pillar_number,
  title         = excluded.title,
  dimension     = excluded.dimension,
  active        = excluded.active;

-- ============================================================
-- ALTERNATIVAS (112 — 4 por situação)
-- ID: 40000000-0000-0000-QQQQ-00000000000L
--     QQQQ = número da situação (0001–0028)
--     L    = ordem da alternativa (1–4)
-- ============================================================

insert into public.alternatives (id, question_id, order_index, letter, title, description) values

  -- ── Q01 — Responsabilidade Pessoal ───────────────────────
  ('40000000-0000-0000-0001-000000000001','30000000-0000-0000-0000-000000000001',1,'A',
   'Assumo e proponho solução',
   'Comunico o erro imediatamente ao time, peço desculpas e proponho uma solução concreta para corrigir o impacto causado.'),
  ('40000000-0000-0000-0001-000000000002','30000000-0000-0000-0000-000000000001',2,'B',
   'Corrijo em silêncio',
   'Resolvo o que precisa ser corrigido sem chamar atenção para o erro, focando em minimizar o impacto o mais rápido possível.'),
  ('40000000-0000-0000-0001-000000000003','30000000-0000-0000-0000-000000000001',3,'C',
   'Contextualizo o problema',
   'Explico os fatores que contribuíram para o erro e apresento um plano claro para que a situação não se repita.'),
  ('40000000-0000-0000-0001-000000000004','30000000-0000-0000-0000-000000000001',4,'D',
   'Reporto e peço orientação',
   'Reporto a situação ao gestor e peço orientação sobre como proceder para causar o menor impacto possível no time.'),

  -- ── Q02 — Gestão Emocional ────────────────────────────────
  ('40000000-0000-0000-0002-000000000001','30000000-0000-0000-0000-000000000002',1,'A',
   'Respondo com calma na hora',
   'Ouço a crítica, respondo com calma apresentando minha perspectiva e proponho uma conversa mais detalhada depois da reunião.'),
  ('40000000-0000-0000-0002-000000000002','30000000-0000-0000-0000-000000000002',2,'B',
   'Aguardo o momento certo',
   'Absorvo a crítica sem reagir na reunião e busco uma conversa privada com o colega depois para tratar o ponto com mais qualidade.'),
  ('40000000-0000-0000-0002-000000000003','30000000-0000-0000-0000-000000000002',3,'C',
   'Redireciono o espaço',
   'Agradeço o feedback e sugiro que o assunto seja tratado em um fórum mais adequado para não comprometer o andamento da reunião.'),
  ('40000000-0000-0000-0002-000000000004','30000000-0000-0000-0000-000000000002',4,'D',
   'Aceito e avalio depois',
   'Aceito a crítica publicamente para não criar conflito e avalio internamente se ela procede antes de qualquer reação.'),

  -- ── Q03 — Disciplina e Consistência ──────────────────────
  ('40000000-0000-0000-0003-000000000001','30000000-0000-0000-0000-000000000003',1,'A',
   'Crio meu próprio ritmo',
   'Defino marcos semanais, bloqueio tempo fixo na agenda para o projeto e monitoro meu próprio progresso com regularidade.'),
  ('40000000-0000-0000-0003-000000000002','30000000-0000-0000-0000-000000000003',2,'B',
   'Avanço nas brechas',
   'Avanço no projeto nos intervalos entre as tarefas urgentes, aproveitando os momentos de menor demanda do dia.'),
  ('40000000-0000-0000-0003-000000000003','30000000-0000-0000-0000-000000000003',3,'C',
   'Estruturo formalmente',
   'Crio um cronograma detalhado e apresento ao gestor para validação antes de começar qualquer execução.'),
  ('40000000-0000-0000-0003-000000000004','30000000-0000-0000-0000-000000000003',4,'D',
   'Envolvo o time',
   'Compartilho o projeto com colegas e crio rituais coletivos de acompanhamento para manter o foco do grupo.'),

  -- ── Q04 — Autoconfiança ───────────────────────────────────
  ('40000000-0000-0000-0004-000000000001','30000000-0000-0000-0000-000000000004',1,'A',
   'Preparo com profundidade',
   'Estudo o tema e o público a fundo, preparo uma apresentação clara e estruturada e pratico antes de forma disciplinada.'),
  ('40000000-0000-0000-0004-000000000002','30000000-0000-0000-0000-000000000004',2,'B',
   'Foco no que domino',
   'Me concentro nos pontos que domino com mais segurança e me preparo para responder a perguntas de forma direta e objetiva.'),
  ('40000000-0000-0000-0004-000000000003','30000000-0000-0000-0000-000000000004',3,'C',
   'Busco parceria',
   'Solicito apoio de um colega mais experiente para realizarmos a apresentação juntos e dividirmos os pontos entre nós.'),
  ('40000000-0000-0000-0004-000000000004','30000000-0000-0000-0000-000000000004',4,'D',
   'Ensaio com feedback',
   'Preparo o material e ensaio com pessoas de confiança para receber críticas e ajustar antes da apresentação real.'),

  -- ── Q05 — Clareza na Expressão ────────────────────────────
  ('40000000-0000-0000-0005-000000000001','30000000-0000-0000-0000-000000000005',1,'A',
   'Adapto para todos os perfis',
   'Preparo uma comunicação estruturada com linguagem acessível e exemplos práticos que funcionem para todos os perfis do time.'),
  ('40000000-0000-0000-0005-000000000002','30000000-0000-0000-0000-000000000005',2,'B',
   'Segmento a comunicação',
   'Explico tecnicamente para o time técnico e simplifico para o time operacional em momentos ou formatos separados.'),
  ('40000000-0000-0000-0005-000000000003','30000000-0000-0000-0000-000000000005',3,'C',
   'Documento e disponibilizo',
   'Envio um documento completo com todos os detalhes e me coloco à disposição para tirar dúvidas individualmente.'),
  ('40000000-0000-0000-0005-000000000004','30000000-0000-0000-0000-000000000005',4,'D',
   'Comunico ao vivo',
   'Reúno o time, faço a explicação oral em uma única sessão coletiva e abro para perguntas em tempo real.'),

  -- ── Q06 — Escuta Ativa ────────────────────────────────────
  ('40000000-0000-0000-0006-000000000001','30000000-0000-0000-0000-000000000006',1,'A',
   'Aprofundo com perguntas',
   'Faço perguntas abertas e específicas para ajudá-lo a explorar o cenário completo antes de sugerir qualquer solução.'),
  ('40000000-0000-0000-0006-000000000002','30000000-0000-0000-0000-000000000006',2,'B',
   'Reflito e confirmo',
   'Ouço atentamente sem interromper e ao final resumo o que entendi, perguntando se capturei tudo corretamente.'),
  ('40000000-0000-0000-0006-000000000003','30000000-0000-0000-0000-000000000006',3,'C',
   'Dou espaço total',
   'Fico em silêncio e deixo o colaborador falar até o fim, sinalizando minha presença apenas com linguagem não-verbal.'),
  ('40000000-0000-0000-0006-000000000004','30000000-0000-0000-0000-000000000006',4,'D',
   'Ofereço minha leitura',
   'Compartilho minha percepção da situação e pergunto se faz sentido para ele como ponto de partida para a conversa.'),

  -- ── Q07 — Assertividade ───────────────────────────────────
  ('40000000-0000-0000-0007-000000000001','30000000-0000-0000-0000-000000000007',1,'A',
   'Me posiciono com dados',
   'Solicito uma conversa, apresento minha perspectiva com argumentos objetivos e dados concretos, e ouço a resposta do gestor.'),
  ('40000000-0000-0000-0007-000000000002','30000000-0000-0000-0000-000000000007',2,'B',
   'Registro formalmente',
   'Manifesto minha discordância por escrito e sigo com a execução, respeitando a decisão da liderança.'),
  ('40000000-0000-0000-0007-000000000003','30000000-0000-0000-0000-000000000007',3,'C',
   'Busco entendimento antes',
   'Peço ao gestor uma conversa informal para entender melhor o raciocínio por trás da decisão antes de me posicionar.'),
  ('40000000-0000-0000-0007-000000000004','30000000-0000-0000-0000-000000000007',4,'D',
   'Aceito e mitigo',
   'Aceito a decisão e direciono minha energia para minimizar os possíveis impactos negativos durante a execução.'),

  -- ── Q08 — Feedback Construtivo ────────────────────────────
  ('40000000-0000-0000-0008-000000000001','30000000-0000-0000-0000-000000000008',1,'A',
   'Feedback direto e privado',
   'Escolho um momento privado, sou específico sobre o comportamento e seu impacto, e proponho mudanças concretas.'),
  ('40000000-0000-0000-0008-000000000002','30000000-0000-0000-0000-000000000008',2,'B',
   'Abordagem coletiva',
   'Levanto o tema de forma geral em uma reunião de time sem expor o colega diretamente.'),
  ('40000000-0000-0000-0008-000000000003','30000000-0000-0000-0000-000000000008',3,'C',
   'Solicito mediação',
   'Peço ao gestor para mediar a conversa e garantir que o feedback seja dado da forma mais construtiva possível.'),
  ('40000000-0000-0000-0008-000000000004','30000000-0000-0000-0000-000000000008',4,'D',
   'Conversa indireta',
   'Abordo o tema de forma indireta em uma conversa informal, tentando sensibilizar o colega sem criar desconforto.'),

  -- ── Q09 — Colaboração ─────────────────────────────────────
  ('40000000-0000-0000-0009-000000000001','30000000-0000-0000-0000-000000000009',1,'A',
   'Me ofereço ativamente',
   'Identifico onde posso contribuir mais, ofereço ajuda diretamente aos colegas e me engajo nos projetos deles.'),
  ('40000000-0000-0000-0009-000000000002','30000000-0000-0000-0000-000000000009',2,'B',
   'Sinalizo disponibilidade',
   'Informo ao gestor que estou com capacidade disponível e aguardo redirecionamento formal para onde sou mais útil.'),
  ('40000000-0000-0000-0009-000000000003','30000000-0000-0000-0000-000000000009',3,'C',
   'Avanço nas minhas metas',
   'Aproveito o tempo para antecipar minhas próximas entregas e fortalecer meu próprio planejamento futuro.'),
  ('40000000-0000-0000-0009-000000000004','30000000-0000-0000-0000-000000000009',4,'D',
   'Pergunto diretamente',
   'Abordo os colegas individualmente, pergunto se precisam de suporte e de que forma específica posso ajudar.'),

  -- ── Q10 — Gestão de Conflitos ─────────────────────────────
  ('40000000-0000-0000-0010-000000000001','30000000-0000-0000-0000-000000000010',1,'A',
   'Ouço separado e medío juntos',
   'Converso individualmente com cada um para entender cada perspectiva e depois facilito uma conversa conjunta e estruturada.'),
  ('40000000-0000-0000-0010-000000000002','30000000-0000-0000-0000-000000000010',2,'B',
   'Enfrento diretamente',
   'Reúno os dois e trato o problema de forma direta, estabelecendo regras claras de convivência e expectativas para o time.'),
  ('40000000-0000-0000-0010-000000000003','30000000-0000-0000-0000-000000000010',3,'C',
   'Escalo o caso',
   'Levo a situação ao gestor responsável para que ele tome a decisão de como resolver o conflito.'),
  ('40000000-0000-0000-0010-000000000004','30000000-0000-0000-0000-000000000010',4,'D',
   'Separo as interações',
   'Reorganizo as responsabilidades para que os dois não precisem interagir diretamente até que o conflito se resolva.'),

  -- ── Q11 — Empatia ─────────────────────────────────────────
  ('40000000-0000-0000-0011-000000000001','30000000-0000-0000-0000-000000000011',1,'A',
   'Ofereço apoio genuíno',
   'Abordo o colega com cuidado, ofereço suporte real sem pressionar por resultados e verifico o que ele precisa nesse momento.'),
  ('40000000-0000-0000-0011-000000000002','30000000-0000-0000-0000-000000000011',2,'B',
   'Combino um plano juntos',
   'Converso com ele sobre o impacto no trabalho e construímos juntos um plano realista e respeitoso para o período.'),
  ('40000000-0000-0000-0011-000000000003','30000000-0000-0000-0000-000000000011',3,'C',
   'Aciono o gestor',
   'Comunico ao gestor a situação para que ele possa dar o suporte institucional necessário ao colaborador.'),
  ('40000000-0000-0000-0011-000000000004','30000000-0000-0000-0000-000000000011',4,'D',
   'Absorvo e protejo',
   'Assumo parte das responsabilidades dele temporariamente sem comentar, para preservar seu espaço de recuperação.'),

  -- ── Q12 — Construção de Confiança ─────────────────────────
  ('40000000-0000-0000-0012-000000000001','30000000-0000-0000-0000-000000000012',1,'A',
   'Crio oportunidades ativamente',
   'Busco criar espaços para que ele contribua, demonstro confiança no seu potencial e ofereço suporte direto e constante.'),
  ('40000000-0000-0000-0012-000000000002','30000000-0000-0000-0000-000000000012',2,'B',
   'Observo antes de agir',
   'Acompanho como ele se sai nas primeiras entregas antes de envolvê-lo em iniciativas de maior visibilidade.'),
  ('40000000-0000-0000-0012-000000000003','30000000-0000-0000-0000-000000000012',3,'C',
   'Apresento as expectativas',
   'Apresento o novo membro ao time e esclareço claramente as expectativas sobre seu papel e sua autonomia.'),
  ('40000000-0000-0000-0012-000000000004','30000000-0000-0000-0000-000000000012',4,'D',
   'Convido à observação',
   'Incluo-o como observador em projetos em andamento para que absorva a cultura e o ritmo antes de assumir iniciativas.'),

  -- ── Q13 — Planejamento e Organização ─────────────────────
  ('40000000-0000-0000-0013-000000000001','30000000-0000-0000-0000-000000000013',1,'A',
   'Estruturo antes de executar',
   'Levanto o histórico disponível, mapeio o escopo, estimo o esforço e crio um plano básico antes de qualquer execução.'),
  ('40000000-0000-0000-0013-000000000002','30000000-0000-0000-0000-000000000013',2,'B',
   'Executo e documento',
   'Começo pela entrega mais crítica e documento o processo conforme avanço para não perder tempo com estrutura prévia.'),
  ('40000000-0000-0000-0013-000000000003','30000000-0000-0000-0000-000000000013',3,'C',
   'Alinhos com stakeholders',
   'Reúno as partes envolvidas para alinhar expectativas e definir coletivamente o que é essencial para o prazo.'),
  ('40000000-0000-0000-0013-000000000004','30000000-0000-0000-0000-000000000013',4,'D',
   'Negocio o prazo',
   'Proponho uma extensão de prazo para garantir que o projeto seja estruturado de forma adequada antes de ser executado.'),

  -- ── Q14 — Foco e Priorização ──────────────────────────────
  ('40000000-0000-0000-0014-000000000001','30000000-0000-0000-0000-000000000014',1,'A',
   'Priorizo com critério',
   'Classifico por urgência e impacto, comunico o que não entregarei e ofereço alternativas para as partes afetadas.'),
  ('40000000-0000-0000-0014-000000000002','30000000-0000-0000-0000-000000000014',2,'B',
   'Sigo a ordem de chegada',
   'Começo pelo que chegou primeiro e avanço pela sequência cronológica das demandas recebidas.'),
  ('40000000-0000-0000-0014-000000000003','30000000-0000-0000-0000-000000000014',3,'C',
   'Valido com o gestor',
   'Consulto o gestor para validar as prioridades antes de executar qualquer tarefa do dia.'),
  ('40000000-0000-0000-0014-000000000004','30000000-0000-0000-0000-000000000014',4,'D',
   'Foco no que concluo',
   'Priorizo o que consigo finalizar no dia para não deixar nada pela metade e manter ritmo de entrega.'),

  -- ── Q15 — Resiliência sob Pressão ────────────────────────
  ('40000000-0000-0000-0015-000000000001','30000000-0000-0000-0000-000000000015',1,'A',
   'Documento e proponho',
   'Registro os aprendizados, analiso o que deu errado e apresento proativamente uma proposta de próximo passo.'),
  ('40000000-0000-0000-0015-000000000002','30000000-0000-0000-0000-000000000015',2,'B',
   'Processo e recomeço',
   'Dou tempo para processar o impacto, recupero o foco e recomeço com base nos aprendizados do processo.'),
  ('40000000-0000-0000-0015-000000000003','30000000-0000-0000-0000-000000000015',3,'C',
   'Faço retrospecto coletivo',
   'Reúno o time para uma retrospectiva e construímos juntos o que faríamos de diferente na próxima vez.'),
  ('40000000-0000-0000-0015-000000000004','30000000-0000-0000-0000-000000000015',4,'D',
   'Solicito avaliação externa',
   'Peço ao gestor uma avaliação externa do que aconteceu antes de tomar qualquer ação ou posicionamento público.'),

  -- ── Q16 — Qualidade nas Entregas ──────────────────────────
  ('40000000-0000-0000-0016-000000000001','30000000-0000-0000-0000-000000000016',1,'A',
   'Negocio o trade-off',
   'Comunico o dilema ao stakeholder e negocio o escopo ou o prazo para conseguir manter a qualidade da entrega.'),
  ('40000000-0000-0000-0016-000000000002','30000000-0000-0000-0000-000000000016',2,'B',
   'Entrego e sinalizo',
   'Entrego o que está pronto e registro claramente os pontos que precisam de refinamento em um segundo momento.'),
  ('40000000-0000-0000-0016-000000000003','30000000-0000-0000-0000-000000000016',3,'C',
   'Otimizo no tempo disponível',
   'Reviso o que é possível ajustar dentro do prazo e entrego o melhor resultado alcançável com os recursos atuais.'),
  ('40000000-0000-0000-0016-000000000004','30000000-0000-0000-0000-000000000016',4,'D',
   'Peço reforço',
   'Solicito apoio de outro membro do time para ganhar qualidade e velocidade ao mesmo tempo dentro do prazo.'),

  -- ── Q17 — Tomada de Decisão ───────────────────────────────
  ('40000000-0000-0000-0017-000000000001','30000000-0000-0000-0000-000000000017',1,'A',
   'Decido com o que tenho',
   'Avalio os dados disponíveis, tomo a decisão mais fundamentada possível e comunico com transparência os critérios usados.'),
  ('40000000-0000-0000-0017-000000000002','30000000-0000-0000-0000-000000000017',2,'B',
   'Busco mais dados rapidamente',
   'Coleto o máximo de informações possível em tempo reduzido antes de me posicionar formalmente.'),
  ('40000000-0000-0000-0017-000000000003','30000000-0000-0000-0000-000000000017',3,'C',
   'Consulto alguém de confiança',
   'Peço uma segunda opinião rápida de um colega experiente e decido com esse suporte adicional.'),
  ('40000000-0000-0000-0017-000000000004','30000000-0000-0000-0000-000000000017',4,'D',
   'Escolho o caminho mais seguro',
   'Opto pela alternativa mais conservadora para minimizar o risco e ajusto conforme surgem mais informações.'),

  -- ── Q18 — Delegação Eficaz ────────────────────────────────
  ('40000000-0000-0000-0018-000000000001','30000000-0000-0000-0000-000000000018',1,'A',
   'Explico, defino e acompanho',
   'Explico o objetivo e as expectativas, defino checkpoints periódicos e deixo espaço para ele executar com autonomia.'),
  ('40000000-0000-0000-0018-000000000002','30000000-0000-0000-0000-000000000018',2,'B',
   'Detalho o como',
   'Descrevo exatamente como quero que a tarefa seja feita e acompanho de perto cada etapa da execução.'),
  ('40000000-0000-0000-0018-000000000003','30000000-0000-0000-0000-000000000018',3,'C',
   'Delego com abertura total',
   'Explico o que precisa ser feito, digo que estou disponível para dúvidas e não imponho nenhum monitoramento.'),
  ('40000000-0000-0000-0018-000000000004','30000000-0000-0000-0000-000000000018',4,'D',
   'Fracionando a entrega',
   'Divido a tarefa em partes menores, entrego uma de cada vez e avalio o resultado antes de passar a próxima etapa.'),

  -- ── Q19 — Desenvolvimento de Pessoas ─────────────────────
  ('40000000-0000-0000-0019-000000000001','30000000-0000-0000-0000-000000000019',1,'A',
   'Acompanho de perto',
   'Ofereço feedbacks frequentes, co-crio um plano de desenvolvimento com ele e monitoro a evolução regularmente.'),
  ('40000000-0000-0000-0019-000000000002','30000000-0000-0000-0000-000000000019',2,'B',
   'Ofereço desafios progressivos',
   'Crio desafios graduais para que ele desenvolva confiança e consistência através da prática real e do erro seguro.'),
  ('40000000-0000-0000-0019-000000000003','30000000-0000-0000-0000-000000000019',3,'C',
   'Removo os obstáculos',
   'Identifico o que está travando a entrega e trabalho para eliminar esses bloqueios antes de cobrar mais resultados.'),
  ('40000000-0000-0000-0019-000000000004','30000000-0000-0000-0000-000000000019',4,'D',
   'Tenho a conversa direta',
   'Tenho uma conversa franca sobre expectativas e alinhamos juntos o que precisa mudar e em que prazo.'),

  -- ── Q20 — Inspiração e Motivação ─────────────────────────
  ('40000000-0000-0000-0020-000000000001','30000000-0000-0000-0000-000000000020',1,'A',
   'Reconheço e redireciono',
   'Reúno o time, reconheço o esforço de todos, reforço o propósito do trabalho e apresento o caminho à frente com clareza.'),
  ('40000000-0000-0000-0020-000000000002','30000000-0000-0000-0000-000000000020',2,'B',
   'Ouço individualmente',
   'Tenho conversas individuais com cada membro para entender a raiz da desmotivação antes de tomar qualquer ação coletiva.'),
  ('40000000-0000-0000-0020-000000000003','30000000-0000-0000-0000-000000000020',3,'C',
   'Crio um momento de celebração',
   'Proponho uma pausa estratégica para celebrar as conquistas do time e reconectar o grupo ao propósito do trabalho.'),
  ('40000000-0000-0000-0020-000000000004','30000000-0000-0000-0000-000000000020',4,'D',
   'Estabeleço metas de curto prazo',
   'Crio desafios e metas de curto prazo para resgatar o senso de progresso e a sensação concreta de conquista.'),

  -- ── Q21 — Adaptabilidade ──────────────────────────────────
  ('40000000-0000-0000-0021-000000000001','30000000-0000-0000-0000-000000000021',1,'A',
   'Me adapto proativamente',
   'Busco entender o racional da mudança, identifico as oportunidades nela e me reposiciono antes que me peçam.'),
  ('40000000-0000-0000-0021-000000000002','30000000-0000-0000-0000-000000000021',2,'B',
   'Aguardo mais clareza',
   'Espero por mais informações antes de me posicionar para ter clareza real sobre o impacto no meu trabalho.'),
  ('40000000-0000-0000-0021-000000000003','30000000-0000-0000-0000-000000000021',3,'C',
   'Compartilho e proponho',
   'Comunico minhas preocupações ao gestor e proponho maneiras concretas de facilitar a transição para a área.'),
  ('40000000-0000-0000-0021-000000000004','30000000-0000-0000-0000-000000000021',4,'D',
   'Foco no que controlo',
   'Concentro esforço no que está sob meu controle e adapto minha rotina ao que já foi oficialmente comunicado.'),

  -- ── Q22 — Criatividade Prática ────────────────────────────
  ('40000000-0000-0000-0022-000000000001','30000000-0000-0000-0000-000000000022',1,'A',
   'Proponho uma solução',
   'Mapeio o problema, desenvolvo uma proposta de solução e apresento ao gestor com dados e argumentos concretos.'),
  ('40000000-0000-0000-0022-000000000002','30000000-0000-0000-0000-000000000022',2,'B',
   'Testo em pequena escala',
   'Desenvolvo e testo uma solução piloto antes de propor formalmente para o time e a liderança.'),
  ('40000000-0000-0000-0022-000000000003','30000000-0000-0000-0000-000000000022',3,'C',
   'Facilito uma sessão coletiva',
   'Levanto o problema em uma reunião de time e conduzo uma sessão de ideação com todos os envolvidos.'),
  ('40000000-0000-0000-0022-000000000004','30000000-0000-0000-0000-000000000022',4,'D',
   'Pesquiso referências',
   'Investigo como outras equipes ou empresas resolvem o mesmo tipo de problema e trago as referências para o time.'),

  -- ── Q23 — Tolerância à Ambiguidade ───────────────────────
  ('40000000-0000-0000-0023-000000000001','30000000-0000-0000-0000-000000000023',1,'A',
   'Defino e começo',
   'Clarifica os objetivos com o gestor, estruturo meu próprio entendimento do papel e começo a operar com autonomia.'),
  ('40000000-0000-0000-0023-000000000002','30000000-0000-0000-0000-000000000023',2,'B',
   'Observo referências',
   'Acompanho como colegas com responsabilidades similares atuam e uso isso como referência para calibrar meu papel.'),
  ('40000000-0000-0000-0023-000000000003','30000000-0000-0000-0000-000000000023',3,'C',
   'Valido antes de executar',
   'Documento minha interpretação do papel e compartilho com o gestor para validar formalmente antes de qualquer ação.'),
  ('40000000-0000-0000-0023-000000000004','30000000-0000-0000-0000-000000000023',4,'D',
   'Avanço e ajusto',
   'Começo a atuar com o que faz sentido para o contexto e vou calibrando meu papel conforme recebo sinais e feedbacks.'),

  -- ── Q24 — Mentalidade de Crescimento ─────────────────────
  ('40000000-0000-0000-0024-000000000001','30000000-0000-0000-0000-000000000024',1,'A',
   'Encaro como oportunidade',
   'Vejo como oportunidade de crescimento, me dedico a aprender o necessário e assumo o compromisso de entregar.'),
  ('40000000-0000-0000-0024-000000000002','30000000-0000-0000-0000-000000000024',2,'B',
   'Aprendo com especialistas',
   'Aceito o desafio e busco ativamente um colega especialista para aprender enquanto contribuo com o que sei.'),
  ('40000000-0000-0000-0024-000000000003','30000000-0000-0000-0000-000000000024',3,'C',
   'Alinho as lacunas com o gestor',
   'Tenho uma conversa com o gestor sobre minhas limitações e juntos definimos como cobrir as lacunas do projeto.'),
  ('40000000-0000-0000-0024-000000000004','30000000-0000-0000-0000-000000000024',4,'D',
   'Contribuo no que sei',
   'Foco no que posso contribuir com segurança dentro do projeto e peço apoio para o que está fora do meu domínio.'),

  -- ── Q25 — Busca por Aprendizado ───────────────────────────
  ('40000000-0000-0000-0025-000000000001','30000000-0000-0000-0000-000000000025',1,'A',
   'Crio um plano de atualização',
   'Defino um plano pessoal de desenvolvimento com recursos específicos, metas claras e tempo dedicado na agenda.'),
  ('40000000-0000-0000-0025-000000000002','30000000-0000-0000-0000-000000000025',2,'B',
   'Busco apoio institucional',
   'Converso com o gestor sobre as necessidades de atualização e busco suporte formal da empresa para me desenvolver.'),
  ('40000000-0000-0000-0025-000000000003','30000000-0000-0000-0000-000000000025',3,'C',
   'Aprendo aplicando',
   'Acompanho referências da área, aplico o conhecimento no trabalho no dia a dia e avalio o que gera impacto real.'),
  ('40000000-0000-0000-0025-000000000004','30000000-0000-0000-0000-000000000025',4,'D',
   'Aprendo com os colegas',
   'Identifico colegas mais atualizados e cria oportunidades de aprendizado através da troca e da mentoria interna.'),

  -- ── Q26 — Autocrítica Construtiva ─────────────────────────
  ('40000000-0000-0000-0026-000000000001','30000000-0000-0000-0000-000000000026',1,'A',
   'Analiso com honestidade',
   'Faço uma análise honesta do que contribuiu para isso e defino ações concretas e mensuráveis de melhoria.'),
  ('40000000-0000-0000-0026-000000000002','30000000-0000-0000-0000-000000000026',2,'B',
   'Alinho com o gestor',
   'Converso com o gestor para entender se minha percepção está correta e calibrar expectativas para o próximo período.'),
  ('40000000-0000-0000-0026-000000000003','30000000-0000-0000-0000-000000000026',3,'C',
   'Foco nos pontos críticos',
   'Identifico um ou dois pontos prioritários de melhoria e concentro esforço neles antes de ampliar o escopo.'),
  ('40000000-0000-0000-0026-000000000004','30000000-0000-0000-0000-000000000026',4,'D',
   'Busco perspectiva externa',
   'Peço feedback de pessoas próximas e de confiança para ter uma leitura externa antes de tirar conclusões.'),

  -- ── Q27 — Compartilhamento de Conhecimento ────────────────
  ('40000000-0000-0000-0027-000000000001','30000000-0000-0000-0000-000000000027',1,'A',
   'Documento e proponho o padrão',
   'Documento o processo de forma clara, compartilho com o time e proponho que seja adotado como prática padrão.'),
  ('40000000-0000-0000-0027-000000000002','30000000-0000-0000-0000-000000000027',2,'B',
   'Apresento e co-evoluo',
   'Apresento a solução em uma reunião de time e convido os colegas a contribuírem com melhorias e adaptações.'),
  ('40000000-0000-0000-0027-000000000003','30000000-0000-0000-0000-000000000027',3,'C',
   'Compartilho diretamente',
   'Compartilho a solução com quem mais se beneficiaria dela de forma direta, sem forçar adoção em massa.'),
  ('40000000-0000-0000-0027-000000000004','30000000-0000-0000-0000-000000000027',4,'D',
   'Disponibilizo para quem quiser',
   'Registro a solução internamente e deixo disponível para quem tiver interesse, sem promover ativamente.'),

  -- ── Q28 — Visão de Futuro ─────────────────────────────────
  ('40000000-0000-0000-0028-000000000001','30000000-0000-0000-0000-000000000028',1,'A',
   'Planejo o futuro',
   'Defino uma estratégia de desenvolvimento de médio e longo prazo alinhada com a direção para onde o mercado caminha.'),
  ('40000000-0000-0000-0028-000000000002','30000000-0000-0000-0000-000000000028',2,'B',
   'Evoluo gradualmente',
   'Mantenho o foco no presente, mas começo a explorar novas habilidades aos poucos, sem grandes rupturas.'),
  ('40000000-0000-0000-0028-000000000003','30000000-0000-0000-0000-000000000028',3,'C',
   'Busco orientação de referências',
   'Converso com referências da área para entender as tendências e como me posicionar de forma estratégica.'),
  ('40000000-0000-0000-0028-000000000004','30000000-0000-0000-0000-000000000028',4,'D',
   'Avalio uma transição',
   'Considero seriamente se é o momento de uma mudança mais significativa de carreira ou área de atuação.')

on conflict (id) do update set
  question_id = excluded.question_id,
  order_index = excluded.order_index,
  letter      = excluded.letter,
  title       = excluded.title,
  description = excluded.description;

commit;


-- ============================================================
-- >>> seeds/004_motor_dimensions.sql
-- ============================================================
-- ============================================================
-- EVOLUA — Seed do Motor de Interpretação — Dimensões Complementares
-- Sprint 09 — Versão 1.0
--
-- Popula as CATEGORIAS das quatro dimensões (estruturais, definidas
-- na metodologia). Os VÍNCULOS alternativa→atributo permanecem vazios,
-- aguardando o mapeamento oficial.
--
-- Nenhum vínculo é gerado ou deduzido automaticamente.
-- Idempotente: INSERT ... ON CONFLICT (id) DO UPDATE.
-- ============================================================

begin;

-- ------------------------------------------------------------
-- DISC — como a pessoa age
-- IDs: 50000000-0000-0000-0000-00000000000X
-- ------------------------------------------------------------
insert into public.disc_profiles (id, code, name, description, active) values
  ('50000000-0000-0000-0000-000000000001', 'D', 'Dominância',
   'Foco em resultados, decisão e controle. Direto, assertivo e orientado à ação.', true),
  ('50000000-0000-0000-0000-000000000002', 'I', 'Influência',
   'Foco em pessoas e persuasão. Comunicativo, entusiasta e sociável.', true),
  ('50000000-0000-0000-0000-000000000003', 'S', 'Estabilidade',
   'Foco em cooperação e constância. Paciente, confiável e conciliador.', true),
  ('50000000-0000-0000-0000-000000000004', 'C', 'Conformidade',
   'Foco em precisão, regras e qualidade. Analítico, cuidadoso e metódico.', true)
on conflict (id) do update set
  code = excluded.code, name = excluded.name,
  description = excluded.description, active = excluded.active;

-- ------------------------------------------------------------
-- TIPO PSICOLÓGICO — como a pessoa pensa
-- IDs: 60000000-0000-0000-0000-00000000000X
-- ------------------------------------------------------------
insert into public.psychological_types (id, code, name, description, active) values
  ('60000000-0000-0000-0000-000000000001', 'EST', 'Estrategista',
   'Pensa em sistemas, lógica e longo prazo. Busca eficiência e visão de conjunto.', true),
  ('60000000-0000-0000-0000-000000000002', 'IDE', 'Idealista',
   'Pensa em propósito, valores e potencial humano. Busca significado e conexão.', true),
  ('60000000-0000-0000-0000-000000000003', 'GUA', 'Guardião',
   'Pensa em ordem, responsabilidade e continuidade. Busca estrutura e confiança.', true),
  ('60000000-0000-0000-0000-000000000004', 'ART', 'Artesão',
   'Pensa no concreto, no prático e no presente. Busca ação e resultado imediato.', true)
on conflict (id) do update set
  code = excluded.code, name = excluded.name,
  description = excluded.description, active = excluded.active;

-- ------------------------------------------------------------
-- MOTIVADORES — o que move a pessoa
-- IDs: 70000000-0000-0000-0000-00000000000X
-- ------------------------------------------------------------
insert into public.motivators (id, code, name, description, active) values
  ('70000000-0000-0000-0000-000000000001', 'REC', 'Reconhecimento',
   'É movido por ser visto, valorizado e reconhecido pelo que entrega.', true),
  ('70000000-0000-0000-0000-000000000002', 'CRE', 'Crescimento',
   'É movido por evoluir, assumir mais e progredir na carreira.', true),
  ('70000000-0000-0000-0000-000000000003', 'PRO', 'Propósito',
   'É movido por contribuir para algo maior e com significado.', true),
  ('70000000-0000-0000-0000-000000000004', 'FIN', 'Recompensa Financeira',
   'É movido por ganho financeiro e retorno material.', true),
  ('70000000-0000-0000-0000-000000000005', 'AUT', 'Autonomia',
   'É movido por liberdade para decidir e trabalhar do seu jeito.', true),
  ('70000000-0000-0000-0000-000000000006', 'APR', 'Aprendizado',
   'É movido por aprender coisas novas e dominar competências.', true),
  ('70000000-0000-0000-0000-000000000007', 'SEG', 'Segurança',
   'É movido por estabilidade, previsibilidade e proteção.', true),
  ('70000000-0000-0000-0000-000000000008', 'DES', 'Desafios',
   'É movido por metas difíceis e problemas complexos para resolver.', true)
on conflict (id) do update set
  code = excluded.code, name = excluded.name,
  description = excluded.description, active = excluded.active;

-- ------------------------------------------------------------
-- ESTILO OPERACIONAL — como a pessoa trabalha
-- IDs: 80000000-0000-0000-0000-00000000000X
-- ------------------------------------------------------------
insert into public.operational_styles (id, code, name, description, active) values
  ('80000000-0000-0000-0000-000000000001', 'EXE', 'Executor',
   'Coloca em prática rapidamente. Foco em fazer acontecer.', true),
  ('80000000-0000-0000-0000-000000000002', 'PLA', 'Planejador',
   'Organiza, estrutura e antecipa antes de agir.', true),
  ('80000000-0000-0000-0000-000000000003', 'ANA', 'Analítico',
   'Investiga e avalia dados e riscos antes de decidir.', true),
  ('80000000-0000-0000-0000-000000000004', 'COL', 'Colaborativo',
   'Trabalha junto, articula pessoas e constrói em equipe.', true)
on conflict (id) do update set
  code = excluded.code, name = excluded.name,
  description = excluded.description, active = excluded.active;

commit;

-- ============================================================
-- VÍNCULOS ALTERNATIVA → ATRIBUTO (a preencher)
--
-- STATUS: AGUARDANDO MAPEAMENTO OFICIAL
--
-- Tabelas: alternative_disc, alternative_psychological_types,
--          alternative_motivators, alternative_operational_styles
--
-- REFERÊNCIA DE IDs — ALTERNATIVAS
--   Formato: 40000000-0000-0000-QQQQ-00000000000L
--   QQQQ = número da situação (0001–0028) | L = 1=A 2=B 3=C 4=D
--
-- REFERÊNCIA DE IDs — ATRIBUTOS
--   DISC:              50000000-...-0000000000(01–04)  D, I, S, C
--   Tipo Psicológico:  60000000-...-0000000000(01–04)  EST, IDE, GUA, ART
--   Motivadores:       70000000-...-0000000000(01–08)  REC, CRE, PRO, FIN, AUT, APR, SEG, DES
--   Estilo Operacional:80000000-...-0000000000(01–04)  EXE, PLA, ANA, COL
--
-- FORMATO DO INSERT (exemplo com DISC — mesmo padrão nas demais):
--   insert into public.alternative_disc
--     (alternative_id, disc_id, evidence_strength)
--   values
--     ('<ID_ALTERNATIVA>', '<ID_DISC>', <0|1|2|3>)
--   on conflict (alternative_id, disc_id) do update set
--     evidence_strength = excluded.evidence_strength;
--
-- REGRAS:
--   • evidence_strength sempre explícito (0, 1, 2 ou 3)
--   • Apenas IDs fixos — nunca texto para relacionamento
--   • Idempotente: re-execuções atualizam sem duplicar
--   • Nenhum vínculo deve ser deduzido ou interpretado
-- ============================================================

-- O mapeamento oficial das 112 alternativas será inserido aqui quando disponível.
-- Nenhum vínculo foi gerado automaticamente.


-- ============================================================
-- >>> seeds/005_official_mapping.sql
-- ============================================================
-- ============================================================
-- EVOLUA — Seed do Mapeamento Oficial (alternativa -> atributos)
-- Exportado do banco em 2026-08-11 (projeto Supabase ref: rxtxsmvnjeasmawktonf)
-- RASCUNHO gerado por análise das alternativas; pendente de validação da Victoria.
-- Idempotente: ON CONFLICT (alternative_id, <fk>) DO UPDATE.
-- Depende de: seeds/002 (alternatives, indicators) e seeds/004 (dimensões).
-- ============================================================

begin;

-- alternative_indicators: 316 vínculos
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values
  ('40000000-0000-0000-0001-000000000001', '20000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0001-000000000001', '20000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0001-000000000001', '20000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0001-000000000002', '20000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0001-000000000002', '20000000-0000-0000-0000-000000000018', 1),
  ('40000000-0000-0000-0001-000000000002', '20000000-0000-0000-0000-000000000019', 2),
  ('40000000-0000-0000-0001-000000000003', '20000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0001-000000000003', '20000000-0000-0000-0000-000000000005', 1),
  ('40000000-0000-0000-0001-000000000003', '20000000-0000-0000-0000-000000000016', 2),
  ('40000000-0000-0000-0001-000000000003', '20000000-0000-0000-0000-000000000031', 2),
  ('40000000-0000-0000-0001-000000000004', '20000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0001-000000000004', '20000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0002-000000000001', '20000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0002-000000000001', '20000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0002-000000000001', '20000000-0000-0000-0000-000000000008', 2),
  ('40000000-0000-0000-0002-000000000001', '20000000-0000-0000-0000-000000000029', 2),
  ('40000000-0000-0000-0002-000000000002', '20000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0002-000000000002', '20000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0002-000000000002', '20000000-0000-0000-0000-000000000013', 2),
  ('40000000-0000-0000-0002-000000000002', '20000000-0000-0000-0000-000000000029', 2),
  ('40000000-0000-0000-0002-000000000003', '20000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0002-000000000003', '20000000-0000-0000-0000-000000000008', 2),
  ('40000000-0000-0000-0002-000000000003', '20000000-0000-0000-0000-000000000013', 2),
  ('40000000-0000-0000-0002-000000000003', '20000000-0000-0000-0000-000000000016', 1),
  ('40000000-0000-0000-0002-000000000004', '20000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0002-000000000004', '20000000-0000-0000-0000-000000000029', 1),
  ('40000000-0000-0000-0002-000000000004', '20000000-0000-0000-0000-000000000031', 2),
  ('40000000-0000-0000-0003-000000000001', '20000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0003-000000000001', '20000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0003-000000000001', '20000000-0000-0000-0000-000000000005', 1),
  ('40000000-0000-0000-0003-000000000001', '20000000-0000-0000-0000-000000000016', 2),
  ('40000000-0000-0000-0003-000000000001', '20000000-0000-0000-0000-000000000018', 2),
  ('40000000-0000-0000-0003-000000000002', '20000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0003-000000000002', '20000000-0000-0000-0000-000000000017', 1),
  ('40000000-0000-0000-0003-000000000002', '20000000-0000-0000-0000-000000000018', 1),
  ('40000000-0000-0000-0003-000000000003', '20000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0003-000000000003', '20000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0003-000000000003', '20000000-0000-0000-0000-000000000016', 3),
  ('40000000-0000-0000-0003-000000000004', '20000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0003-000000000004', '20000000-0000-0000-0000-000000000012', 3),
  ('40000000-0000-0000-0003-000000000004', '20000000-0000-0000-0000-000000000015', 2),
  ('40000000-0000-0000-0003-000000000004', '20000000-0000-0000-0000-000000000025', 1),
  ('40000000-0000-0000-0004-000000000001', '20000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0004-000000000001', '20000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0004-000000000001', '20000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0004-000000000001', '20000000-0000-0000-0000-000000000016', 2),
  ('40000000-0000-0000-0004-000000000002', '20000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0004-000000000002', '20000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0004-000000000002', '20000000-0000-0000-0000-000000000008', 2),
  ('40000000-0000-0000-0004-000000000003', '20000000-0000-0000-0000-000000000012', 3),
  ('40000000-0000-0000-0004-000000000003', '20000000-0000-0000-0000-000000000014', 1),
  ('40000000-0000-0000-0004-000000000004', '20000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0004-000000000004', '20000000-0000-0000-0000-000000000016', 1),
  ('40000000-0000-0000-0004-000000000004', '20000000-0000-0000-0000-000000000029', 3),
  ('40000000-0000-0000-0004-000000000004', '20000000-0000-0000-0000-000000000031', 1),
  ('40000000-0000-0000-0005-000000000001', '20000000-0000-0000-0000-000000000006', 3),
  ('40000000-0000-0000-0005-000000000001', '20000000-0000-0000-0000-000000000010', 3),
  ('40000000-0000-0000-0005-000000000002', '20000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0005-000000000002', '20000000-0000-0000-0000-000000000010', 3),
  ('40000000-0000-0000-0005-000000000002', '20000000-0000-0000-0000-000000000016', 1),
  ('40000000-0000-0000-0005-000000000003', '20000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0005-000000000003', '20000000-0000-0000-0000-000000000010', 1),
  ('40000000-0000-0000-0005-000000000003', '20000000-0000-0000-0000-000000000016', 1),
  ('40000000-0000-0000-0005-000000000004', '20000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0005-000000000004', '20000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0005-000000000004', '20000000-0000-0000-0000-000000000015', 1),
  ('40000000-0000-0000-0006-000000000001', '20000000-0000-0000-0000-000000000007', 3),
  ('40000000-0000-0000-0006-000000000001', '20000000-0000-0000-0000-000000000009', 1),
  ('40000000-0000-0000-0006-000000000001', '20000000-0000-0000-0000-000000000011', 2),
  ('40000000-0000-0000-0006-000000000002', '20000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0006-000000000002', '20000000-0000-0000-0000-000000000007', 3),
  ('40000000-0000-0000-0006-000000000002', '20000000-0000-0000-0000-000000000010', 1),
  ('40000000-0000-0000-0006-000000000002', '20000000-0000-0000-0000-000000000011', 2),
  ('40000000-0000-0000-0006-000000000003', '20000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0006-000000000003', '20000000-0000-0000-0000-000000000011', 3),
  ('40000000-0000-0000-0006-000000000004', '20000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0006-000000000004', '20000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0006-000000000004', '20000000-0000-0000-0000-000000000008', 2),
  ('40000000-0000-0000-0007-000000000001', '20000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0007-000000000001', '20000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0007-000000000001', '20000000-0000-0000-0000-000000000008', 3),
  ('40000000-0000-0000-0007-000000000001', '20000000-0000-0000-0000-000000000021', 1),
  ('40000000-0000-0000-0007-000000000002', '20000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0007-000000000002', '20000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0007-000000000003', '20000000-0000-0000-0000-000000000007', 3),
  ('40000000-0000-0000-0007-000000000003', '20000000-0000-0000-0000-000000000011', 1),
  ('40000000-0000-0000-0007-000000000004', '20000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0007-000000000004', '20000000-0000-0000-0000-000000000020', 1),
  ('40000000-0000-0000-0008-000000000001', '20000000-0000-0000-0000-000000000008', 2),
  ('40000000-0000-0000-0008-000000000001', '20000000-0000-0000-0000-000000000009', 3),
  ('40000000-0000-0000-0008-000000000001', '20000000-0000-0000-0000-000000000013', 1),
  ('40000000-0000-0000-0008-000000000002', '20000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0008-000000000002', '20000000-0000-0000-0000-000000000009', 1),
  ('40000000-0000-0000-0008-000000000003', '20000000-0000-0000-0000-000000000009', 1),
  ('40000000-0000-0000-0008-000000000003', '20000000-0000-0000-0000-000000000013', 1),
  ('40000000-0000-0000-0008-000000000004', '20000000-0000-0000-0000-000000000009', 1),
  ('40000000-0000-0000-0008-000000000004', '20000000-0000-0000-0000-000000000011', 2),
  ('40000000-0000-0000-0009-000000000001', '20000000-0000-0000-0000-000000000011', 1),
  ('40000000-0000-0000-0009-000000000001', '20000000-0000-0000-0000-000000000012', 3),
  ('40000000-0000-0000-0009-000000000001', '20000000-0000-0000-0000-000000000015', 1),
  ('40000000-0000-0000-0009-000000000002', '20000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0009-000000000002', '20000000-0000-0000-0000-000000000012', 1),
  ('40000000-0000-0000-0009-000000000003', '20000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0009-000000000003', '20000000-0000-0000-0000-000000000016', 2),
  ('40000000-0000-0000-0009-000000000003', '20000000-0000-0000-0000-000000000017', 1),
  ('40000000-0000-0000-0009-000000000004', '20000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0009-000000000004', '20000000-0000-0000-0000-000000000011', 2),
  ('40000000-0000-0000-0009-000000000004', '20000000-0000-0000-0000-000000000012', 3),
  ('40000000-0000-0000-0010-000000000001', '20000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0010-000000000001', '20000000-0000-0000-0000-000000000011', 2),
  ('40000000-0000-0000-0010-000000000001', '20000000-0000-0000-0000-000000000013', 3),
  ('40000000-0000-0000-0010-000000000002', '20000000-0000-0000-0000-000000000008', 2),
  ('40000000-0000-0000-0010-000000000002', '20000000-0000-0000-0000-000000000013', 2),
  ('40000000-0000-0000-0010-000000000002', '20000000-0000-0000-0000-000000000015', 1),
  ('40000000-0000-0000-0010-000000000003', '20000000-0000-0000-0000-000000000013', 1),
  ('40000000-0000-0000-0010-000000000004', '20000000-0000-0000-0000-000000000013', 1),
  ('40000000-0000-0000-0010-000000000004', '20000000-0000-0000-0000-000000000016', 1),
  ('40000000-0000-0000-0011-000000000001', '20000000-0000-0000-0000-000000000011', 3),
  ('40000000-0000-0000-0011-000000000001', '20000000-0000-0000-0000-000000000014', 2),
  ('40000000-0000-0000-0011-000000000002', '20000000-0000-0000-0000-000000000011', 2),
  ('40000000-0000-0000-0011-000000000002', '20000000-0000-0000-0000-000000000012', 2),
  ('40000000-0000-0000-0011-000000000002', '20000000-0000-0000-0000-000000000014', 1),
  ('40000000-0000-0000-0011-000000000002', '20000000-0000-0000-0000-000000000016', 1),
  ('40000000-0000-0000-0011-000000000003', '20000000-0000-0000-0000-000000000011', 1),
  ('40000000-0000-0000-0011-000000000004', '20000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0011-000000000004', '20000000-0000-0000-0000-000000000011', 2),
  ('40000000-0000-0000-0011-000000000004', '20000000-0000-0000-0000-000000000012', 2),
  ('40000000-0000-0000-0012-000000000001', '20000000-0000-0000-0000-000000000014', 2),
  ('40000000-0000-0000-0012-000000000001', '20000000-0000-0000-0000-000000000015', 3),
  ('40000000-0000-0000-0012-000000000001', '20000000-0000-0000-0000-000000000023', 1),
  ('40000000-0000-0000-0012-000000000001', '20000000-0000-0000-0000-000000000025', 2),
  ('40000000-0000-0000-0012-000000000002', '20000000-0000-0000-0000-000000000014', 1),
  ('40000000-0000-0000-0012-000000000003', '20000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0012-000000000003', '20000000-0000-0000-0000-000000000010', 1),
  ('40000000-0000-0000-0012-000000000003', '20000000-0000-0000-0000-000000000014', 1),
  ('40000000-0000-0000-0012-000000000003', '20000000-0000-0000-0000-000000000015', 1),
  ('40000000-0000-0000-0012-000000000004', '20000000-0000-0000-0000-000000000012', 1),
  ('40000000-0000-0000-0012-000000000004', '20000000-0000-0000-0000-000000000014', 1),
  ('40000000-0000-0000-0013-000000000001', '20000000-0000-0000-0000-000000000016', 3),
  ('40000000-0000-0000-0013-000000000001', '20000000-0000-0000-0000-000000000017', 1),
  ('40000000-0000-0000-0013-000000000001', '20000000-0000-0000-0000-000000000021', 1),
  ('40000000-0000-0000-0013-000000000002', '20000000-0000-0000-0000-000000000017', 2),
  ('40000000-0000-0000-0013-000000000002', '20000000-0000-0000-0000-000000000018', 2),
  ('40000000-0000-0000-0013-000000000002', '20000000-0000-0000-0000-000000000019', 2),
  ('40000000-0000-0000-0013-000000000003', '20000000-0000-0000-0000-000000000012', 2),
  ('40000000-0000-0000-0013-000000000003', '20000000-0000-0000-0000-000000000015', 1),
  ('40000000-0000-0000-0013-000000000003', '20000000-0000-0000-0000-000000000016', 1),
  ('40000000-0000-0000-0013-000000000003', '20000000-0000-0000-0000-000000000021', 1),
  ('40000000-0000-0000-0013-000000000003', '20000000-0000-0000-0000-000000000024', 1),
  ('40000000-0000-0000-0013-000000000004', '20000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0013-000000000004', '20000000-0000-0000-0000-000000000016', 1),
  ('40000000-0000-0000-0014-000000000001', '20000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0014-000000000001', '20000000-0000-0000-0000-000000000016', 2),
  ('40000000-0000-0000-0014-000000000001', '20000000-0000-0000-0000-000000000017', 3),
  ('40000000-0000-0000-0014-000000000001', '20000000-0000-0000-0000-000000000018', 1),
  ('40000000-0000-0000-0014-000000000002', '20000000-0000-0000-0000-000000000018', 1),
  ('40000000-0000-0000-0014-000000000003', '20000000-0000-0000-0000-000000000017', 1),
  ('40000000-0000-0000-0014-000000000004', '20000000-0000-0000-0000-000000000017', 2),
  ('40000000-0000-0000-0014-000000000004', '20000000-0000-0000-0000-000000000018', 1),
  ('40000000-0000-0000-0014-000000000004', '20000000-0000-0000-0000-000000000019', 2),
  ('40000000-0000-0000-0015-000000000001', '20000000-0000-0000-0000-000000000016', 1),
  ('40000000-0000-0000-0015-000000000001', '20000000-0000-0000-0000-000000000020', 2),
  ('40000000-0000-0000-0015-000000000001', '20000000-0000-0000-0000-000000000031', 2),
  ('40000000-0000-0000-0015-000000000001', '20000000-0000-0000-0000-000000000035', 1),
  ('40000000-0000-0000-0015-000000000002', '20000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0015-000000000002', '20000000-0000-0000-0000-000000000020', 3),
  ('40000000-0000-0000-0015-000000000002', '20000000-0000-0000-0000-000000000031', 1),
  ('40000000-0000-0000-0015-000000000003', '20000000-0000-0000-0000-000000000012', 2),
  ('40000000-0000-0000-0015-000000000003', '20000000-0000-0000-0000-000000000013', 1),
  ('40000000-0000-0000-0015-000000000003', '20000000-0000-0000-0000-000000000031', 2),
  ('40000000-0000-0000-0015-000000000003', '20000000-0000-0000-0000-000000000034', 2),
  ('40000000-0000-0000-0015-000000000004', '20000000-0000-0000-0000-000000000020', 1),
  ('40000000-0000-0000-0015-000000000004', '20000000-0000-0000-0000-000000000031', 1),
  ('40000000-0000-0000-0016-000000000001', '20000000-0000-0000-0000-000000000008', 2),
  ('40000000-0000-0000-0016-000000000001', '20000000-0000-0000-0000-000000000017', 1),
  ('40000000-0000-0000-0016-000000000001', '20000000-0000-0000-0000-000000000019', 3),
  ('40000000-0000-0000-0016-000000000002', '20000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0016-000000000002', '20000000-0000-0000-0000-000000000018', 1),
  ('40000000-0000-0000-0016-000000000002', '20000000-0000-0000-0000-000000000019', 1),
  ('40000000-0000-0000-0016-000000000003', '20000000-0000-0000-0000-000000000017', 1),
  ('40000000-0000-0000-0016-000000000003', '20000000-0000-0000-0000-000000000019', 2),
  ('40000000-0000-0000-0016-000000000003', '20000000-0000-0000-0000-000000000020', 2),
  ('40000000-0000-0000-0016-000000000003', '20000000-0000-0000-0000-000000000027', 1),
  ('40000000-0000-0000-0016-000000000004', '20000000-0000-0000-0000-000000000012', 2),
  ('40000000-0000-0000-0016-000000000004', '20000000-0000-0000-0000-000000000019', 1),
  ('40000000-0000-0000-0016-000000000004', '20000000-0000-0000-0000-000000000024', 2),
  ('40000000-0000-0000-0017-000000000001', '20000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0017-000000000001', '20000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0017-000000000001', '20000000-0000-0000-0000-000000000021', 1),
  ('40000000-0000-0000-0017-000000000001', '20000000-0000-0000-0000-000000000022', 3),
  ('40000000-0000-0000-0017-000000000002', '20000000-0000-0000-0000-000000000019', 1),
  ('40000000-0000-0000-0017-000000000002', '20000000-0000-0000-0000-000000000022', 1),
  ('40000000-0000-0000-0017-000000000003', '20000000-0000-0000-0000-000000000012', 1),
  ('40000000-0000-0000-0017-000000000003', '20000000-0000-0000-0000-000000000022', 1),
  ('40000000-0000-0000-0017-000000000004', '20000000-0000-0000-0000-000000000020', 1),
  ('40000000-0000-0000-0017-000000000004', '20000000-0000-0000-0000-000000000022', 1),
  ('40000000-0000-0000-0018-000000000001', '20000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0018-000000000001', '20000000-0000-0000-0000-000000000023', 2),
  ('40000000-0000-0000-0018-000000000001', '20000000-0000-0000-0000-000000000024', 3),
  ('40000000-0000-0000-0018-000000000002', '20000000-0000-0000-0000-000000000016', 2),
  ('40000000-0000-0000-0018-000000000002', '20000000-0000-0000-0000-000000000024', 1),
  ('40000000-0000-0000-0018-000000000003', '20000000-0000-0000-0000-000000000023', 1),
  ('40000000-0000-0000-0018-000000000003', '20000000-0000-0000-0000-000000000024', 2),
  ('40000000-0000-0000-0018-000000000004', '20000000-0000-0000-0000-000000000016', 2),
  ('40000000-0000-0000-0018-000000000004', '20000000-0000-0000-0000-000000000019', 1),
  ('40000000-0000-0000-0018-000000000004', '20000000-0000-0000-0000-000000000024', 2),
  ('40000000-0000-0000-0019-000000000001', '20000000-0000-0000-0000-000000000009', 2),
  ('40000000-0000-0000-0019-000000000001', '20000000-0000-0000-0000-000000000023', 3),
  ('40000000-0000-0000-0019-000000000001', '20000000-0000-0000-0000-000000000025', 1),
  ('40000000-0000-0000-0019-000000000002', '20000000-0000-0000-0000-000000000023', 3),
  ('40000000-0000-0000-0019-000000000002', '20000000-0000-0000-0000-000000000025', 2),
  ('40000000-0000-0000-0019-000000000002', '20000000-0000-0000-0000-000000000028', 1),
  ('40000000-0000-0000-0019-000000000003', '20000000-0000-0000-0000-000000000023', 2),
  ('40000000-0000-0000-0019-000000000003', '20000000-0000-0000-0000-000000000024', 1),
  ('40000000-0000-0000-0019-000000000004', '20000000-0000-0000-0000-000000000008', 3),
  ('40000000-0000-0000-0019-000000000004', '20000000-0000-0000-0000-000000000009', 2),
  ('40000000-0000-0000-0019-000000000004', '20000000-0000-0000-0000-000000000023', 1),
  ('40000000-0000-0000-0020-000000000001', '20000000-0000-0000-0000-000000000005', 2),
  ('40000000-0000-0000-0020-000000000001', '20000000-0000-0000-0000-000000000015', 1),
  ('40000000-0000-0000-0020-000000000001', '20000000-0000-0000-0000-000000000021', 1),
  ('40000000-0000-0000-0020-000000000001', '20000000-0000-0000-0000-000000000025', 3),
  ('40000000-0000-0000-0020-000000000002', '20000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0020-000000000002', '20000000-0000-0000-0000-000000000011', 2),
  ('40000000-0000-0000-0020-000000000002', '20000000-0000-0000-0000-000000000025', 1),
  ('40000000-0000-0000-0020-000000000003', '20000000-0000-0000-0000-000000000005', 1),
  ('40000000-0000-0000-0020-000000000003', '20000000-0000-0000-0000-000000000015', 2),
  ('40000000-0000-0000-0020-000000000003', '20000000-0000-0000-0000-000000000025', 2),
  ('40000000-0000-0000-0020-000000000004', '20000000-0000-0000-0000-000000000017', 1),
  ('40000000-0000-0000-0020-000000000004', '20000000-0000-0000-0000-000000000022', 1),
  ('40000000-0000-0000-0020-000000000004', '20000000-0000-0000-0000-000000000025', 2),
  ('40000000-0000-0000-0021-000000000001', '20000000-0000-0000-0000-000000000021', 1),
  ('40000000-0000-0000-0021-000000000001', '20000000-0000-0000-0000-000000000026', 2),
  ('40000000-0000-0000-0021-000000000001', '20000000-0000-0000-0000-000000000030', 3),
  ('40000000-0000-0000-0021-000000000002', '20000000-0000-0000-0000-000000000020', 1),
  ('40000000-0000-0000-0021-000000000002', '20000000-0000-0000-0000-000000000028', 1),
  ('40000000-0000-0000-0021-000000000003', '20000000-0000-0000-0000-000000000008', 2),
  ('40000000-0000-0000-0021-000000000003', '20000000-0000-0000-0000-000000000015', 1),
  ('40000000-0000-0000-0021-000000000003', '20000000-0000-0000-0000-000000000030', 2),
  ('40000000-0000-0000-0021-000000000004', '20000000-0000-0000-0000-000000000017', 1),
  ('40000000-0000-0000-0021-000000000004', '20000000-0000-0000-0000-000000000020', 2),
  ('40000000-0000-0000-0021-000000000004', '20000000-0000-0000-0000-000000000030', 2),
  ('40000000-0000-0000-0022-000000000001', '20000000-0000-0000-0000-000000000016', 1),
  ('40000000-0000-0000-0022-000000000001', '20000000-0000-0000-0000-000000000022', 1),
  ('40000000-0000-0000-0022-000000000001', '20000000-0000-0000-0000-000000000027', 3),
  ('40000000-0000-0000-0022-000000000002', '20000000-0000-0000-0000-000000000026', 2),
  ('40000000-0000-0000-0022-000000000002', '20000000-0000-0000-0000-000000000027', 3),
  ('40000000-0000-0000-0022-000000000002', '20000000-0000-0000-0000-000000000028', 1),
  ('40000000-0000-0000-0022-000000000003', '20000000-0000-0000-0000-000000000012', 3),
  ('40000000-0000-0000-0022-000000000003', '20000000-0000-0000-0000-000000000015', 2),
  ('40000000-0000-0000-0022-000000000003', '20000000-0000-0000-0000-000000000027', 1),
  ('40000000-0000-0000-0022-000000000004', '20000000-0000-0000-0000-000000000027', 1),
  ('40000000-0000-0000-0022-000000000004', '20000000-0000-0000-0000-000000000032', 3),
  ('40000000-0000-0000-0022-000000000004', '20000000-0000-0000-0000-000000000033', 1),
  ('40000000-0000-0000-0022-000000000004', '20000000-0000-0000-0000-000000000034', 1),
  ('40000000-0000-0000-0023-000000000001', '20000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0023-000000000001', '20000000-0000-0000-0000-000000000028', 3),
  ('40000000-0000-0000-0023-000000000001', '20000000-0000-0000-0000-000000000030', 1),
  ('40000000-0000-0000-0023-000000000002', '20000000-0000-0000-0000-000000000028', 1),
  ('40000000-0000-0000-0023-000000000002', '20000000-0000-0000-0000-000000000032', 2),
  ('40000000-0000-0000-0023-000000000003', '20000000-0000-0000-0000-000000000016', 1),
  ('40000000-0000-0000-0023-000000000003', '20000000-0000-0000-0000-000000000028', 1),
  ('40000000-0000-0000-0023-000000000004', '20000000-0000-0000-0000-000000000027', 1),
  ('40000000-0000-0000-0023-000000000004', '20000000-0000-0000-0000-000000000028', 3),
  ('40000000-0000-0000-0023-000000000004', '20000000-0000-0000-0000-000000000029', 1),
  ('40000000-0000-0000-0023-000000000004', '20000000-0000-0000-0000-000000000030', 2),
  ('40000000-0000-0000-0024-000000000001', '20000000-0000-0000-0000-000000000026', 3),
  ('40000000-0000-0000-0024-000000000001', '20000000-0000-0000-0000-000000000028', 1),
  ('40000000-0000-0000-0024-000000000001', '20000000-0000-0000-0000-000000000032', 2),
  ('40000000-0000-0000-0024-000000000002', '20000000-0000-0000-0000-000000000012', 1),
  ('40000000-0000-0000-0024-000000000002', '20000000-0000-0000-0000-000000000026', 2),
  ('40000000-0000-0000-0024-000000000002', '20000000-0000-0000-0000-000000000032', 3),
  ('40000000-0000-0000-0024-000000000003', '20000000-0000-0000-0000-000000000026', 1),
  ('40000000-0000-0000-0024-000000000003', '20000000-0000-0000-0000-000000000031', 1),
  ('40000000-0000-0000-0024-000000000004', '20000000-0000-0000-0000-000000000012', 1),
  ('40000000-0000-0000-0024-000000000004', '20000000-0000-0000-0000-000000000026', 1),
  ('40000000-0000-0000-0025-000000000001', '20000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0025-000000000001', '20000000-0000-0000-0000-000000000016', 1),
  ('40000000-0000-0000-0025-000000000001', '20000000-0000-0000-0000-000000000032', 3),
  ('40000000-0000-0000-0025-000000000001', '20000000-0000-0000-0000-000000000035', 1),
  ('40000000-0000-0000-0025-000000000002', '20000000-0000-0000-0000-000000000032', 2),
  ('40000000-0000-0000-0025-000000000003', '20000000-0000-0000-0000-000000000026', 1),
  ('40000000-0000-0000-0025-000000000003', '20000000-0000-0000-0000-000000000032', 2),
  ('40000000-0000-0000-0025-000000000003', '20000000-0000-0000-0000-000000000033', 3),
  ('40000000-0000-0000-0025-000000000004', '20000000-0000-0000-0000-000000000012', 1),
  ('40000000-0000-0000-0025-000000000004', '20000000-0000-0000-0000-000000000032', 2),
  ('40000000-0000-0000-0025-000000000004', '20000000-0000-0000-0000-000000000034', 2),
  ('40000000-0000-0000-0026-000000000001', '20000000-0000-0000-0000-000000000016', 1),
  ('40000000-0000-0000-0026-000000000001', '20000000-0000-0000-0000-000000000026', 1),
  ('40000000-0000-0000-0026-000000000001', '20000000-0000-0000-0000-000000000031', 3),
  ('40000000-0000-0000-0026-000000000002', '20000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0026-000000000002', '20000000-0000-0000-0000-000000000031', 1),
  ('40000000-0000-0000-0026-000000000003', '20000000-0000-0000-0000-000000000017', 2),
  ('40000000-0000-0000-0026-000000000003', '20000000-0000-0000-0000-000000000031', 2),
  ('40000000-0000-0000-0026-000000000004', '20000000-0000-0000-0000-000000000029', 2),
  ('40000000-0000-0000-0026-000000000004', '20000000-0000-0000-0000-000000000031', 2),
  ('40000000-0000-0000-0027-000000000001', '20000000-0000-0000-0000-000000000016', 1),
  ('40000000-0000-0000-0027-000000000001', '20000000-0000-0000-0000-000000000033', 2),
  ('40000000-0000-0000-0027-000000000001', '20000000-0000-0000-0000-000000000034', 3),
  ('40000000-0000-0000-0027-000000000002', '20000000-0000-0000-0000-000000000012', 2),
  ('40000000-0000-0000-0027-000000000002', '20000000-0000-0000-0000-000000000015', 1),
  ('40000000-0000-0000-0027-000000000002', '20000000-0000-0000-0000-000000000034', 3),
  ('40000000-0000-0000-0027-000000000003', '20000000-0000-0000-0000-000000000011', 1),
  ('40000000-0000-0000-0027-000000000003', '20000000-0000-0000-0000-000000000034', 2),
  ('40000000-0000-0000-0027-000000000004', '20000000-0000-0000-0000-000000000033', 1),
  ('40000000-0000-0000-0027-000000000004', '20000000-0000-0000-0000-000000000034', 1),
  ('40000000-0000-0000-0028-000000000001', '20000000-0000-0000-0000-000000000021', 2),
  ('40000000-0000-0000-0028-000000000001', '20000000-0000-0000-0000-000000000032', 1),
  ('40000000-0000-0000-0028-000000000001', '20000000-0000-0000-0000-000000000035', 3),
  ('40000000-0000-0000-0028-000000000002', '20000000-0000-0000-0000-000000000030', 1),
  ('40000000-0000-0000-0028-000000000002', '20000000-0000-0000-0000-000000000032', 2),
  ('40000000-0000-0000-0028-000000000002', '20000000-0000-0000-0000-000000000035', 1),
  ('40000000-0000-0000-0028-000000000003', '20000000-0000-0000-0000-000000000032', 2),
  ('40000000-0000-0000-0028-000000000003', '20000000-0000-0000-0000-000000000035', 2),
  ('40000000-0000-0000-0028-000000000004', '20000000-0000-0000-0000-000000000026', 1),
  ('40000000-0000-0000-0028-000000000004', '20000000-0000-0000-0000-000000000028', 2),
  ('40000000-0000-0000-0028-000000000004', '20000000-0000-0000-0000-000000000035', 2)
on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

-- alternative_disc: 195 vínculos
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values
  ('40000000-0000-0000-0001-000000000001', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0001-000000000001', '50000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0001-000000000002', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0001-000000000002', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0001-000000000003', '50000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0001-000000000004', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0001-000000000004', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0002-000000000001', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0002-000000000001', '50000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0002-000000000002', '50000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0002-000000000002', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0002-000000000003', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0002-000000000003', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0002-000000000004', '50000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0002-000000000004', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0003-000000000001', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0003-000000000001', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0003-000000000002', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0003-000000000003', '50000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0003-000000000004', '50000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0004-000000000001', '50000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0004-000000000002', '50000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0004-000000000003', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0004-000000000003', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0004-000000000004', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0004-000000000004', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0005-000000000001', '50000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0005-000000000001', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0005-000000000002', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0005-000000000003', '50000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0005-000000000004', '50000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0006-000000000001', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0006-000000000001', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0006-000000000002', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0006-000000000002', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0006-000000000003', '50000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0006-000000000004', '50000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0006-000000000004', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0007-000000000001', '50000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0007-000000000001', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0007-000000000002', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0007-000000000002', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0007-000000000003', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0007-000000000003', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0007-000000000004', '50000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0008-000000000001', '50000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0008-000000000001', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0008-000000000002', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0008-000000000002', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0008-000000000003', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0008-000000000003', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0008-000000000004', '50000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0009-000000000001', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0009-000000000001', '50000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0009-000000000002', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0009-000000000002', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0009-000000000003', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0009-000000000003', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0009-000000000004', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0009-000000000004', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0010-000000000001', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0010-000000000001', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0010-000000000002', '50000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0010-000000000003', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0010-000000000003', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0010-000000000004', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0010-000000000004', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0011-000000000001', '50000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0011-000000000002', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0011-000000000002', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0011-000000000003', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0011-000000000003', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0011-000000000004', '50000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0012-000000000001', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0012-000000000001', '50000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0012-000000000002', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0012-000000000002', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0012-000000000003', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0012-000000000003', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0012-000000000004', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0013-000000000001', '50000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0013-000000000002', '50000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0013-000000000003', '50000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0013-000000000003', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0013-000000000004', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0013-000000000004', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0014-000000000001', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0014-000000000001', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0014-000000000002', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0014-000000000003', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0014-000000000003', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0014-000000000004', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0014-000000000004', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0015-000000000001', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0015-000000000001', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0015-000000000002', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0015-000000000002', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0015-000000000003', '50000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0015-000000000004', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0015-000000000004', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0016-000000000001', '50000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0016-000000000001', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0016-000000000002', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0016-000000000002', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0016-000000000003', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0016-000000000003', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0016-000000000004', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0016-000000000004', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0017-000000000001', '50000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0017-000000000002', '50000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0017-000000000003', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0017-000000000003', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0017-000000000004', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0017-000000000004', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0018-000000000001', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0018-000000000001', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0018-000000000002', '50000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0018-000000000003', '50000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0018-000000000003', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0018-000000000004', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0018-000000000004', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0019-000000000001', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0019-000000000001', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0019-000000000002', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0019-000000000002', '50000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0019-000000000003', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0019-000000000003', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0019-000000000004', '50000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0020-000000000001', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0020-000000000001', '50000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0020-000000000002', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0020-000000000002', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0020-000000000003', '50000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0020-000000000004', '50000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0020-000000000004', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0021-000000000001', '50000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0021-000000000001', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0021-000000000002', '50000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0021-000000000002', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0021-000000000003', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0021-000000000003', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0021-000000000003', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0021-000000000004', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0021-000000000004', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0022-000000000001', '50000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0022-000000000001', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0022-000000000002', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0022-000000000002', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0022-000000000003', '50000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0022-000000000004', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0023-000000000001', '50000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0023-000000000001', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0023-000000000002', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0023-000000000002', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0023-000000000003', '50000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0023-000000000004', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0023-000000000004', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0024-000000000001', '50000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0024-000000000001', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0024-000000000002', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0024-000000000002', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0024-000000000003', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0024-000000000003', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0024-000000000004', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0024-000000000004', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0025-000000000001', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0025-000000000001', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0025-000000000002', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0025-000000000002', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0025-000000000003', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0025-000000000003', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0025-000000000004', '50000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0025-000000000004', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0026-000000000001', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0026-000000000001', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0026-000000000002', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0026-000000000002', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0026-000000000003', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0026-000000000003', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0026-000000000004', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0026-000000000004', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0027-000000000001', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0027-000000000001', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0027-000000000002', '50000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0027-000000000003', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0027-000000000003', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0027-000000000004', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0027-000000000004', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0028-000000000001', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0028-000000000001', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0028-000000000002', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0028-000000000002', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0028-000000000003', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0028-000000000003', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0028-000000000004', '50000000-0000-0000-0000-000000000001', 2)
on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;

-- alternative_psychological_types: 150 vínculos
insert into public.alternative_psychological_types (alternative_id, psychological_type_id, evidence_strength) values
  ('40000000-0000-0000-0001-000000000001', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0001-000000000001', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0001-000000000002', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0001-000000000002', '60000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0001-000000000003', '60000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0001-000000000004', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0002-000000000001', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0002-000000000001', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0002-000000000002', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0002-000000000003', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0002-000000000004', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0003-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0003-000000000002', '60000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0003-000000000003', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0003-000000000003', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0003-000000000004', '60000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0004-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0004-000000000002', '60000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0004-000000000003', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0004-000000000003', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0004-000000000004', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0004-000000000004', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0005-000000000001', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0005-000000000001', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0005-000000000002', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0005-000000000003', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0005-000000000004', '60000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0006-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0006-000000000002', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0006-000000000002', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0006-000000000003', '60000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0006-000000000004', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0007-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0007-000000000002', '60000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0007-000000000003', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0007-000000000003', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0007-000000000004', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0007-000000000004', '60000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0008-000000000001', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0008-000000000001', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0008-000000000002', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0008-000000000003', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0008-000000000004', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0009-000000000001', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0009-000000000002', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0009-000000000003', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0009-000000000004', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0010-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0010-000000000001', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0010-000000000002', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0010-000000000002', '60000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0010-000000000003', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0010-000000000004', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0010-000000000004', '60000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0011-000000000001', '60000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0011-000000000002', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0011-000000000002', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0011-000000000003', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0011-000000000004', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0011-000000000004', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0012-000000000001', '60000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0012-000000000002', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0012-000000000002', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0012-000000000003', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0012-000000000004', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0013-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0013-000000000002', '60000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0013-000000000003', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0013-000000000003', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0013-000000000004', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0013-000000000004', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0014-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0014-000000000002', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0014-000000000002', '60000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0014-000000000003', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0014-000000000004', '60000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0015-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0015-000000000002', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0015-000000000002', '60000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0015-000000000003', '60000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0015-000000000004', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0016-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0016-000000000002', '60000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0016-000000000003', '60000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0016-000000000004', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0017-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0017-000000000002', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0017-000000000003', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0017-000000000003', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0017-000000000004', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0018-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0018-000000000002', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0018-000000000003', '60000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0018-000000000004', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0018-000000000004', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0019-000000000001', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0019-000000000001', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0019-000000000002', '60000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0019-000000000003', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0019-000000000003', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0019-000000000004', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0020-000000000001', '60000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0020-000000000002', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0020-000000000002', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0020-000000000003', '60000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0020-000000000004', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0020-000000000004', '60000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0021-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0021-000000000002', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0021-000000000003', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0021-000000000003', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0021-000000000004', '60000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0022-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0022-000000000002', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0022-000000000002', '60000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0022-000000000003', '60000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0022-000000000004', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0023-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0023-000000000002', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0023-000000000003', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0023-000000000004', '60000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0024-000000000001', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0024-000000000001', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0024-000000000002', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0024-000000000002', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0024-000000000003', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0024-000000000004', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0024-000000000004', '60000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0025-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0025-000000000002', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0025-000000000003', '60000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0025-000000000004', '60000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0026-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0026-000000000002', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0026-000000000003', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0026-000000000003', '60000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0026-000000000004', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0027-000000000001', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0027-000000000001', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0027-000000000002', '60000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0027-000000000003', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0027-000000000004', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0027-000000000004', '60000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0028-000000000001', '60000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0028-000000000002', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0028-000000000002', '60000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0028-000000000003', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0028-000000000003', '60000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0028-000000000004', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0028-000000000004', '60000000-0000-0000-0000-000000000002', 1)
on conflict (alternative_id, psychological_type_id) do update set evidence_strength = excluded.evidence_strength;

-- alternative_motivators: 129 vínculos
insert into public.alternative_motivators (alternative_id, motivator_id, evidence_strength) values
  ('40000000-0000-0000-0001-000000000001', '70000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0001-000000000002', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0001-000000000003', '70000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0001-000000000004', '70000000-0000-0000-0000-000000000007', 3),
  ('40000000-0000-0000-0002-000000000001', '70000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0002-000000000001', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0002-000000000002', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0002-000000000002', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0002-000000000003', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0002-000000000004', '70000000-0000-0000-0000-000000000007', 3),
  ('40000000-0000-0000-0003-000000000001', '70000000-0000-0000-0000-000000000005', 3),
  ('40000000-0000-0000-0003-000000000002', '70000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0003-000000000003', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0003-000000000004', '70000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0003-000000000004', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0004-000000000001', '70000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0004-000000000001', '70000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0004-000000000002', '70000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0004-000000000003', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0004-000000000004', '70000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0005-000000000001', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0005-000000000002', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0005-000000000003', '70000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0005-000000000004', '70000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0006-000000000001', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0006-000000000002', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0006-000000000003', '70000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0006-000000000004', '70000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0007-000000000001', '70000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0007-000000000002', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0007-000000000003', '70000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0007-000000000004', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0008-000000000001', '70000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0008-000000000002', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0008-000000000003', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0008-000000000004', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0009-000000000001', '70000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0009-000000000002', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0009-000000000003', '70000000-0000-0000-0000-000000000005', 2),
  ('40000000-0000-0000-0009-000000000004', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0010-000000000001', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0010-000000000002', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0010-000000000003', '70000000-0000-0000-0000-000000000007', 3),
  ('40000000-0000-0000-0010-000000000004', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0011-000000000001', '70000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0011-000000000002', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0011-000000000003', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0011-000000000004', '70000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0012-000000000001', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0012-000000000002', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0012-000000000003', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0012-000000000004', '70000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0013-000000000001', '70000000-0000-0000-0000-000000000005', 1),
  ('40000000-0000-0000-0013-000000000002', '70000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0013-000000000003', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0013-000000000004', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0014-000000000001', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0014-000000000002', '70000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0014-000000000003', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0014-000000000004', '70000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0015-000000000001', '70000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0015-000000000002', '70000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0015-000000000003', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0015-000000000004', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0016-000000000001', '70000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0016-000000000002', '70000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0016-000000000003', '70000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0016-000000000004', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0017-000000000001', '70000000-0000-0000-0000-000000000005', 2),
  ('40000000-0000-0000-0017-000000000002', '70000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0017-000000000003', '70000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0017-000000000004', '70000000-0000-0000-0000-000000000007', 3),
  ('40000000-0000-0000-0018-000000000001', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0018-000000000002', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0018-000000000003', '70000000-0000-0000-0000-000000000005', 2),
  ('40000000-0000-0000-0018-000000000004', '70000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0019-000000000001', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0019-000000000002', '70000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0019-000000000002', '70000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0019-000000000003', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0019-000000000004', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0020-000000000001', '70000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0020-000000000001', '70000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0020-000000000002', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0020-000000000003', '70000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0020-000000000003', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0020-000000000004', '70000000-0000-0000-0000-000000000008', 2),
  ('40000000-0000-0000-0021-000000000001', '70000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0021-000000000002', '70000000-0000-0000-0000-000000000007', 3),
  ('40000000-0000-0000-0021-000000000003', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0021-000000000004', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0022-000000000001', '70000000-0000-0000-0000-000000000008', 2),
  ('40000000-0000-0000-0022-000000000002', '70000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0022-000000000002', '70000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0022-000000000003', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0022-000000000004', '70000000-0000-0000-0000-000000000006', 3),
  ('40000000-0000-0000-0023-000000000001', '70000000-0000-0000-0000-000000000005', 3),
  ('40000000-0000-0000-0023-000000000002', '70000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0023-000000000003', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0023-000000000004', '70000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0024-000000000001', '70000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0024-000000000001', '70000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0024-000000000002', '70000000-0000-0000-0000-000000000006', 3),
  ('40000000-0000-0000-0024-000000000003', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0024-000000000004', '70000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0025-000000000001', '70000000-0000-0000-0000-000000000005', 1),
  ('40000000-0000-0000-0025-000000000001', '70000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0025-000000000002', '70000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0025-000000000002', '70000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0025-000000000003', '70000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0025-000000000003', '70000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0025-000000000004', '70000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0026-000000000001', '70000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0026-000000000001', '70000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0026-000000000002', '70000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0026-000000000003', '70000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0026-000000000004', '70000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0027-000000000001', '70000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0027-000000000001', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0027-000000000002', '70000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0027-000000000002', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0027-000000000003', '70000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0027-000000000004', '70000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0028-000000000001', '70000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0028-000000000002', '70000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0028-000000000002', '70000000-0000-0000-0000-000000000007', 1),
  ('40000000-0000-0000-0028-000000000003', '70000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0028-000000000004', '70000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0028-000000000004', '70000000-0000-0000-0000-000000000008', 1)
on conflict (alternative_id, motivator_id) do update set evidence_strength = excluded.evidence_strength;

-- alternative_operational_styles: 151 vínculos
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values
  ('40000000-0000-0000-0001-000000000001', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0001-000000000001', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0001-000000000002', '80000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0001-000000000003', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0001-000000000003', '80000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0001-000000000004', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0002-000000000001', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0002-000000000002', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0002-000000000002', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0002-000000000003', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0002-000000000004', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0003-000000000001', '80000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0003-000000000002', '80000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0003-000000000003', '80000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0003-000000000003', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0003-000000000004', '80000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0004-000000000001', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0004-000000000001', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0004-000000000002', '80000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0004-000000000003', '80000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0004-000000000004', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0004-000000000004', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0005-000000000001', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0005-000000000001', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0005-000000000002', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0005-000000000002', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0005-000000000003', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0005-000000000003', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0005-000000000004', '80000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0005-000000000004', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0006-000000000001', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0006-000000000002', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0006-000000000002', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0006-000000000003', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0006-000000000004', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0007-000000000001', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0007-000000000002', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0007-000000000003', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0007-000000000003', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0007-000000000004', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0008-000000000001', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0008-000000000001', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0008-000000000002', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0008-000000000003', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0008-000000000004', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0009-000000000001', '80000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0009-000000000002', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0009-000000000003', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0009-000000000004', '80000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0010-000000000001', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0010-000000000001', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0010-000000000002', '80000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0010-000000000003', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0010-000000000004', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0011-000000000001', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0011-000000000002', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0011-000000000002', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0011-000000000003', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0011-000000000004', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0012-000000000001', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0012-000000000002', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0012-000000000003', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0012-000000000004', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0013-000000000001', '80000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0013-000000000001', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0013-000000000002', '80000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0013-000000000003', '80000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0013-000000000004', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0014-000000000001', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0014-000000000001', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0014-000000000002', '80000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0014-000000000003', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0014-000000000004', '80000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0015-000000000001', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0015-000000000001', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0015-000000000002', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0015-000000000003', '80000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0015-000000000004', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0016-000000000001', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0016-000000000001', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0016-000000000002', '80000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0016-000000000003', '80000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0016-000000000003', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0016-000000000004', '80000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0017-000000000001', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0017-000000000001', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0017-000000000002', '80000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0017-000000000003', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0017-000000000004', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0018-000000000001', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0018-000000000001', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0018-000000000002', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0018-000000000002', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0018-000000000003', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0018-000000000004', '80000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0019-000000000001', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0019-000000000001', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0019-000000000002', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0019-000000000003', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0019-000000000003', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0019-000000000004', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0020-000000000001', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0020-000000000002', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0020-000000000002', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0020-000000000003', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0020-000000000004', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0020-000000000004', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0021-000000000001', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0021-000000000001', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0021-000000000002', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0021-000000000003', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0021-000000000004', '80000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0022-000000000001', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0022-000000000001', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0022-000000000002', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0022-000000000002', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0022-000000000003', '80000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0022-000000000004', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0023-000000000001', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0023-000000000001', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0023-000000000002', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0023-000000000003', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0023-000000000003', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0023-000000000004', '80000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0024-000000000001', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0024-000000000002', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0024-000000000003', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0024-000000000003', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0024-000000000004', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0025-000000000001', '80000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0025-000000000002', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0025-000000000002', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0025-000000000003', '80000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0025-000000000003', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0025-000000000004', '80000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0026-000000000001', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0026-000000000001', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0026-000000000002', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0026-000000000003', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0026-000000000003', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0026-000000000004', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0027-000000000001', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0027-000000000001', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0027-000000000002', '80000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0027-000000000003', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0027-000000000004', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0028-000000000001', '80000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0028-000000000002', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0028-000000000003', '80000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0028-000000000003', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0028-000000000004', '80000000-0000-0000-0000-000000000003', 1)
on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;

commit;
