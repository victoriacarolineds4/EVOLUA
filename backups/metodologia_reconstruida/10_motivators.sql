-- 10_motivators.sql — realinhamento para as 10 categorias oficiais

-- Renomeações (mantém código e vínculo, ajusta rótulo para bater com a especificação oficial):
update public.motivators set name = 'Reconhecimento Financeiro', description = 'É movido por ganho financeiro e retorno material pelo que entrega.' where code = 'FIN';
update public.motivators set name = 'Reconhecimento Verbal', description = 'É movido por ser visto, elogiado e reconhecido verbalmente pelo que entrega.' where code = 'REC';

-- Novas categorias oficiais que faltavam:
insert into public.motivators (id, code, name, description, active) values
  ('70000000-0000-0000-0000-000000000009', 'DEV', 'Desenvolvimento', 'É movido por evoluir suas competências e se desenvolver profissionalmente.', true),
  ('70000000-0000-0000-0000-000000000010', 'CNF', 'Confiança', 'É movido por ambientes de confiança, onde pode contar com as pessoas ao redor.', true),
  ('70000000-0000-0000-0000-000000000011', 'TQV', 'Tempo e Qualidade de Vida', 'É movido por ter tempo livre e equilíbrio entre vida pessoal e profissional.', true),
  ('70000000-0000-0000-0000-000000000012', 'OUT', 'Outras Formas de Reconhecimento', 'É movido por formas de reconhecimento que não se encaixam nas categorias anteriores.', true);

-- Categorias que não constam nas 10 oficiais — desativadas (não apagadas; alternative_motivators está vazia, sem vínculo a preservar):
update public.motivators set active = false where code in ('PRO', 'SEG');
