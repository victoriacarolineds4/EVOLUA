-- Limpeza das 3 respostas de teste (Persona D/S/C) usadas para validar o
-- remapeamento de indicadores em sistema real (10/09/2026). Escopado só a
-- esses IDs específicos.
begin;

delete from public.answers where response_id in (
  '884a8e3b-52c9-47ae-9037-d6fd521b9836',
  '0668a1cf-3732-4e8a-a525-fbde264d25c7',
  'dc75e08e-6c7c-4747-8bcb-c3d372080212'
);
delete from public.responses where id in (
  '884a8e3b-52c9-47ae-9037-d6fd521b9836',
  '0668a1cf-3732-4e8a-a525-fbde264d25c7',
  'dc75e08e-6c7c-4747-8bcb-c3d372080212'
);
delete from public.applications where id in (
  '4b2db980-3990-4592-8c72-c4f04581213a',
  '358887ed-a21e-46fb-82ea-cdba0b2601dc',
  '8643012b-3a8e-47a4-8db6-ed47c4d719dd'
);
delete from public.profiles where id = '8f56ba6f-cec6-46b5-8c0d-fb0319420c25';
delete from public.companies where id = '4f9c78ad-1873-4fe5-a6d2-e5f221a3865a';

-- confirmação: deve retornar 0 em todas
select 'answers' t, count(*) from public.answers where response_id in ('884a8e3b-52c9-47ae-9037-d6fd521b9836','0668a1cf-3732-4e8a-a525-fbde264d25c7','dc75e08e-6c7c-4747-8bcb-c3d372080212')
union all select 'responses', count(*) from public.responses where id in ('884a8e3b-52c9-47ae-9037-d6fd521b9836','0668a1cf-3732-4e8a-a525-fbde264d25c7','dc75e08e-6c7c-4747-8bcb-c3d372080212')
union all select 'applications', count(*) from public.applications where id in ('4b2db980-3990-4592-8c72-c4f04581213a','358887ed-a21e-46fb-82ea-cdba0b2601dc','8643012b-3a8e-47a4-8db6-ed47c4d719dd')
union all select 'companies', count(*) from public.companies where id = '4f9c78ad-1873-4fe5-a6d2-e5f221a3865a';

commit;
