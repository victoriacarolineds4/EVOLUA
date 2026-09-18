-- ============================================================
-- EVOLUA — Limpeza: conta de verificação final do DISC v2.1 (14/09/2026)
-- ============================================================
begin;

with removed_profiles as (
  delete from public.profiles where id = 'd2004224-bdc0-482b-898d-9995567e326d'
  returning company_id
)
delete from public.companies where id in (select company_id from removed_profiles);

select count(*) from public.profiles where id = 'd2004224-bdc0-482b-898d-9995567e326d';

commit;

-- Usuário de Auth a apagar manualmente: buscar "verifydisc." em evolua-qa.local
