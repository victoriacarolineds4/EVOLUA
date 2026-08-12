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
