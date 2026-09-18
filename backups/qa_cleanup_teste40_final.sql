-- ============================================================
-- EVOLUA — Limpeza: teste real das 40 situações (11/09/2026)
-- ============================================================
-- Remove a empresa/aplicação/resposta de teste usada para verificar
-- ponta a ponta a expansão de 28 para 40 situações (jornada real via
-- UI + relatório real via sessão de teste).
-- ============================================================

begin;

delete from public.answers where response_id = 'b526039a-7e73-4a7b-a891-041947bafec0';
delete from public.responses where id = 'b526039a-7e73-4a7b-a891-041947bafec0';
delete from public.applications where id = 'bfe2828e-d451-412d-b0ea-ad7720c3a1d3';
delete from public.profiles where id = 'f99d7570-6435-473e-a4a0-ae1a5307b5bc';
delete from public.companies where id = '83695b7a-eccf-4bb5-a33c-3f6b76b4fce0';

-- confirmação: deve retornar 0 em todas
select 'answers' t, count(*) from public.answers where response_id = 'b526039a-7e73-4a7b-a891-041947bafec0'
union all select 'responses', count(*) from public.responses where id = 'b526039a-7e73-4a7b-a891-041947bafec0'
union all select 'applications', count(*) from public.applications where id = 'bfe2828e-d451-412d-b0ea-ad7720c3a1d3'
union all select 'profiles', count(*) from public.profiles where id = 'f99d7570-6435-473e-a4a0-ae1a5307b5bc'
union all select 'companies', count(*) from public.companies where id = '83695b7a-eccf-4bb5-a33c-3f6b76b4fce0';

commit;

-- ============================================================
-- Usuários Auth de teste a apagar manualmente em
-- Authentication → Users no painel do Supabase:
--   - gestor.teste40.20260911@evolua-qa.local
--   - verif.expansao40.20260911@evolua-qa.local (checagem de contagem anterior)
-- ============================================================
