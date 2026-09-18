-- ============================================================
-- EVOLUA — Limpeza final: verificação das correções P1/P2
-- (Problema 1: update_response_progress / Problema 2: linguagem hedged)
-- 11/09/2026
-- ============================================================
-- Remove a empresa/aplicações/respostas de teste "Empresa Teste Correcao V2"
-- criada para verificar ao vivo em produção as duas correções aprovadas.
-- ============================================================

begin;

delete from public.answers where response_id in (
  'c2eb12a5-b4c8-41ad-8ca9-aa20b33a0f54',  -- Persona Mista Correcao (28 respostas reais)
  '2b5b6e9c-c330-483f-b4bf-131646c42de4'   -- Teste Forjar Completed (0 respostas)
);
delete from public.responses where id in (
  'c2eb12a5-b4c8-41ad-8ca9-aa20b33a0f54',
  '2b5b6e9c-c330-483f-b4bf-131646c42de4'
);
delete from public.applications where id in (
  'f253684e-abf3-48cd-b7ee-defb7369aba4',  -- Teste Correcao Problema 2
  'a8d7e9ce-cffd-4b4d-b851-9fbfbc5e2854'   -- Teste Problema1 Reproducao
);
delete from public.profiles where id = '5f3fd9c4-afd1-4ef9-b6a2-fa15bf2e4371';
delete from public.companies where id = '6ef55c31-03bb-4171-99bc-41f8dd2ac9f0';

-- confirmação: deve retornar 0 em todas
select 'answers' t, count(*) from public.answers where response_id in ('c2eb12a5-b4c8-41ad-8ca9-aa20b33a0f54','2b5b6e9c-c330-483f-b4bf-131646c42de4')
union all select 'responses', count(*) from public.responses where id in ('c2eb12a5-b4c8-41ad-8ca9-aa20b33a0f54','2b5b6e9c-c330-483f-b4bf-131646c42de4')
union all select 'applications', count(*) from public.applications where id in ('f253684e-abf3-48cd-b7ee-defb7369aba4','a8d7e9ce-cffd-4b4d-b851-9fbfbc5e2854')
union all select 'profiles', count(*) from public.profiles where id = '5f3fd9c4-afd1-4ef9-b6a2-fa15bf2e4371'
union all select 'companies', count(*) from public.companies where id = '6ef55c31-03bb-4171-99bc-41f8dd2ac9f0';

commit;

-- ============================================================
-- Usuário Auth de teste a apagar manualmente em
-- Authentication → Users no painel do Supabase:
--   - gestor.teste.correcaov2.20260911@evolua-qa.local
-- ============================================================
