-- Limpeza da conta/empresa/aplicação/resposta de teste usada para validar
-- a metodologia reconstruída (08/09/2026). Escopado só a esses IDs específicos.
begin;

delete from public.answers where response_id = '639e8927-1012-4c2f-9984-d1f4c84f07e4';
delete from public.responses where id = '639e8927-1012-4c2f-9984-d1f4c84f07e4';
delete from public.applications where id = 'b1c11fd5-2080-4fce-b68d-75af189c3d65';
delete from public.profiles where id = '3fdd40ff-d2fc-4e3e-aeb7-ecd591fd6181';
delete from public.companies where id = '49c7ca8d-e40f-42e5-9320-9e2440dda0b4';

-- confirmação: deve retornar 0 nas 5
select 'answers' t, count(*) from public.answers where response_id = '639e8927-1012-4c2f-9984-d1f4c84f07e4'
union all select 'responses', count(*) from public.responses where id = '639e8927-1012-4c2f-9984-d1f4c84f07e4'
union all select 'applications', count(*) from public.applications where id = 'b1c11fd5-2080-4fce-b68d-75af189c3d65'
union all select 'profiles', count(*) from public.profiles where id = '3fdd40ff-d2fc-4e3e-aeb7-ecd591fd6181'
union all select 'companies', count(*) from public.companies where id = '49c7ca8d-e40f-42e5-9320-9e2440dda0b4';

commit;
