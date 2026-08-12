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
