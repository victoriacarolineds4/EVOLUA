-- ============================================================
-- EVOLUA — Limpeza consolidada de dados de teste
-- Auditoria de Prontidão para Operação Real v2.0 (11/09/2026)
-- ============================================================
-- Inclui, de forma IDEMPOTENTE (seguro rodar mesmo que algo já
-- tenha sido apagado antes):
--   1. Dados da Auditoria de Prontidão (tenants A/B para teste de
--      isolamento multi-tenant + response de teste de forjamento
--      de estado via update_response_progress).
--   2. Reforço do cleanup pendente da sessão anterior (empresa/
--      aplicação/resposta "Teste Mapeamento V2" — só remove se
--      ainda existir).
-- ============================================================

begin;

-- --- 1. Auditoria de Prontidão v2 — Tenants A/B (teste de isolamento) ---
delete from public.answers where response_id = '72cb9ca7-facb-424c-9917-00fd29041f37';
delete from public.responses where id = '72cb9ca7-facb-424c-9917-00fd29041f37';
delete from public.applications where id in (
  'cfaf5f59-dc4a-44cc-af6f-b0da849a8524',  -- IDOR Test App A
  '7c66b34f-b25a-4933-aa55-125907b381cf'   -- IDOR Test App B
);
delete from public.profiles where id in (
  'abc6f403-7096-4922-9434-54843921c9c2',  -- Auditor A
  'f7465561-a01f-4535-bf0e-0a683207fe28'   -- Auditor B
);
delete from public.companies where id in (
  'bf019fc5-7c69-4f71-b888-5688cdbcc7e3',  -- Empresa Auditoria A
  '860d0da4-2734-4b0a-a262-130ad2145828'   -- Empresa Auditoria B
);

-- --- 2. Reforço: cleanup pendente da consolidação v2 (sessão anterior) ---
delete from public.answers where response_id = '2fdbdac2-ddee-444a-92c2-2d05a69e71d9';
delete from public.responses where id = '2fdbdac2-ddee-444a-92c2-2d05a69e71d9';
delete from public.applications where id = '7d04aa75-7d15-4ec4-8083-7b95c5bd62f2';
delete from public.profiles where id = '206b5ca7-eb4d-4d99-9a10-3b506fa447e9';
delete from public.companies where id = '3641e8e4-6ab4-4a46-8d18-1e15b2930537';

-- --- confirmação: deve retornar 0 em todas as linhas abaixo ---
select 'answers (A)' t, count(*) from public.answers where response_id = '72cb9ca7-facb-424c-9917-00fd29041f37'
union all select 'responses (A)', count(*) from public.responses where id = '72cb9ca7-facb-424c-9917-00fd29041f37'
union all select 'applications (A/B)', count(*) from public.applications where id in ('cfaf5f59-dc4a-44cc-af6f-b0da849a8524','7c66b34f-b25a-4933-aa55-125907b381cf')
union all select 'profiles (A/B)', count(*) from public.profiles where id in ('abc6f403-7096-4922-9434-54843921c9c2','f7465561-a01f-4535-bf0e-0a683207fe28')
union all select 'companies (A/B)', count(*) from public.companies where id in ('bf019fc5-7c69-4f71-b888-5688cdbcc7e3','860d0da4-2734-4b0a-a262-130ad2145828')
union all select 'answers (mapeamento v2)', count(*) from public.answers where response_id = '2fdbdac2-ddee-444a-92c2-2d05a69e71d9'
union all select 'responses (mapeamento v2)', count(*) from public.responses where id = '2fdbdac2-ddee-444a-92c2-2d05a69e71d9'
union all select 'applications (mapeamento v2)', count(*) from public.applications where id = '7d04aa75-7d15-4ec4-8083-7b95c5bd62f2'
union all select 'profiles (mapeamento v2)', count(*) from public.profiles where id = '206b5ca7-eb4d-4d99-9a10-3b506fa447e9'
union all select 'companies (mapeamento v2)', count(*) from public.companies where id = '3641e8e4-6ab4-4a46-8d18-1e15b2930537';

commit;

-- ============================================================
-- Usuários Auth de teste a apagar manualmente em
-- Authentication → Users no painel do Supabase (não removível via SQL/RLS):
--   - auditoria.tenant.a.20260911@evolua-qa.local
--   - auditoria.tenant.b.20260911@evolua-qa.local
--   - gestor.teste.mapeamentov2.20260911@evolua-qa.local  (se ainda existir)
-- ============================================================
