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
