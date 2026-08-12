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
