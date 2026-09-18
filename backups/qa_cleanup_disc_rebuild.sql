-- ============================================================
-- EVOLUA — Limpeza: contas descartáveis da reconstrução DISC (13/09/2026)
-- ============================================================
-- Três contas de leitura só para consultar metodologia (nunca escreveram nada).
-- Usa CTE para achar o company_id de cada uma antes de apagar o profile.
-- ============================================================

begin;

with removed_profiles as (
  delete from public.profiles
  where id in (
    '68ab07be-22f1-41cf-b65a-fb2ccb2bc418',
    '7860c9a1-f366-4a4d-ae94-adf95723b1c9',
    'fc952678-c91c-4b69-9955-ecc1ccd2a4a6'
  )
  returning company_id
)
delete from public.companies
where id in (select company_id from removed_profiles);

select 'profiles' t, count(*) from public.profiles where id in (
  '68ab07be-22f1-41cf-b65a-fb2ccb2bc418','7860c9a1-f366-4a4d-ae94-adf95723b1c9','fc952678-c91c-4b69-9955-ecc1ccd2a4a6'
);

commit;

-- Usuários de Auth a apagar manualmente em Authentication → Users:
--   buscar por "metodv3.", "discrebuild." e "allantrace." em evolua-qa.local
