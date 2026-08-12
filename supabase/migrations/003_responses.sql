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
