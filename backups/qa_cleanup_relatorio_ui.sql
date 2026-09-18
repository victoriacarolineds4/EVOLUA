-- Limpeza dos 3 cenários de teste usados para validar a nova apresentação
-- dos indicadores no relatório (10/09/2026): Cenario A (com padrões),
-- Cenario B e Cenario B v2 (zero padrões).
begin;

delete from public.answers where response_id in (
  '8e1fd695-a0bb-4640-a92d-10720b54e6a7',
  'c5977e8c-71ac-4759-b2f3-b79da2dda73f',
  'b918d098-db3c-4201-8df1-69593e31635c'
);
delete from public.responses where id in (
  '8e1fd695-a0bb-4640-a92d-10720b54e6a7',
  'c5977e8c-71ac-4759-b2f3-b79da2dda73f',
  'b918d098-db3c-4201-8df1-69593e31635c'
);
delete from public.applications where id in (
  '9b504905-8fc7-4ac9-a547-6449469eee61',
  '950ba19f-9e67-4b6c-b2a8-3c540bfa72ab',
  'e4685817-0464-47b2-90ff-beacb2e3b4ef'
);
delete from public.profiles where id = '556ad5fb-75f6-46c5-9856-069a83638d76';
delete from public.companies where id = 'de6c9aec-54ca-4713-b849-aab55bcaa0cd';

-- confirmação: deve retornar 0 em todas
select 'answers' t, count(*) from public.answers where response_id in ('8e1fd695-a0bb-4640-a92d-10720b54e6a7','c5977e8c-71ac-4759-b2f3-b79da2dda73f','b918d098-db3c-4201-8df1-69593e31635c')
union all select 'responses', count(*) from public.responses where id in ('8e1fd695-a0bb-4640-a92d-10720b54e6a7','c5977e8c-71ac-4759-b2f3-b79da2dda73f','b918d098-db3c-4201-8df1-69593e31635c')
union all select 'applications', count(*) from public.applications where id in ('9b504905-8fc7-4ac9-a547-6449469eee61','950ba19f-9e67-4b6c-b2a8-3c540bfa72ab','e4685817-0464-47b2-90ff-beacb2e3b4ef')
union all select 'companies', count(*) from public.companies where id = 'de6c9aec-54ca-4713-b849-aab55bcaa0cd';

commit;
