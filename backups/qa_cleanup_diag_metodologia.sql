-- ============================================================
-- EVOLUA — Limpeza: diagnóstico read-only da metodologia (13/09/2026)
-- ============================================================
-- Remove a conta descartável criada só para ler (nunca escrever)
-- as tabelas de metodologia/mapeamento em produção via REST autenticado.
-- ============================================================

begin;

delete from public.profiles where id = 'e0379de1-8f94-4692-817b-a6fd08ffbfdd';
delete from public.companies where id = '766e133a-1953-45da-bf87-5a654fbebfc6';

select 'profiles' t, count(*) from public.profiles where id = 'e0379de1-8f94-4692-817b-a6fd08ffbfdd'
union all select 'companies', count(*) from public.companies where id = '766e133a-1953-45da-bf87-5a654fbebfc6';

commit;

-- Usuário de Auth a apagar manualmente em Authentication → Users:
--   diag.metodologia.20260913@evolua-qa.local
