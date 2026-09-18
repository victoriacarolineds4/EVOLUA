-- Limpeza do teste do relatório real com a metodologia v2 (11/09/2026):
-- gestor de teste "Gestor Teste V2" + empresa "Empresa Teste Mapeamento V2"
-- + aplicação "Teste Mapeamento V2" + resposta real de "Rafael Teste
-- Mapeamento" usada para verificar o motor de confiança em produção.
begin;

delete from public.answers where response_id = '2fdbdac2-ddee-444a-92c2-2d05a69e71d9';
delete from public.responses where id = '2fdbdac2-ddee-444a-92c2-2d05a69e71d9';
delete from public.applications where id = '7d04aa75-7d15-4ec4-8083-7b95c5bd62f2';
delete from public.profiles where id = '206b5ca7-eb4d-4d99-9a10-3b506fa447e9';
delete from public.companies where id = '3641e8e4-6ab4-4a46-8d18-1e15b2930537';

-- confirmação: deve retornar 0 em todas
select 'answers' t, count(*) from public.answers where response_id = '2fdbdac2-ddee-444a-92c2-2d05a69e71d9'
union all select 'responses', count(*) from public.responses where id = '2fdbdac2-ddee-444a-92c2-2d05a69e71d9'
union all select 'applications', count(*) from public.applications where id = '7d04aa75-7d15-4ec4-8083-7b95c5bd62f2'
union all select 'profiles', count(*) from public.profiles where id = '206b5ca7-eb4d-4d99-9a10-3b506fa447e9'
union all select 'companies', count(*) from public.companies where id = '3641e8e4-6ab4-4a46-8d18-1e15b2930537';

commit;
