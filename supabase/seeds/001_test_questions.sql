-- ============================================================
-- EVOLUA — Seed de Teste — 3 situações × 4 alternativas
-- Usado em desenvolvimento/staging para validar o fluxo do questionário
-- antes de inserir as 41 questões oficiais.
-- ============================================================

-- Situação 1: Organização sob incerteza
with q1 as (
  insert into public.questions (order_index, title)
  values (
    1,
    'Um novo projeto chega ao seu time com prazo apertado e escopo pouco definido. O que você faz primeiro?'
  )
  returning id
)
insert into public.alternatives (question_id, order_index, title, description)
select q1.id, s.order_index, s.title, s.description
from q1,
  (values
    (1, 'Assumo a organização',   'Proponho uma reunião de alinhamento, defino as prioridades e distribuo as responsabilidades para o time começar de forma coordenada.'),
    (2, 'Começo a executar',      'Identifico a entrega mais rápida possível e começo a trabalhar para gerar resultado enquanto o restante se organiza.'),
    (3, 'Mapeio os riscos',       'Levanto os pontos de indefinição, identifico os riscos e busco mais informações antes de dar qualquer passo para evitar retrabalho.'),
    (4, 'Apoio quem precisa',     'Pergunto aos colegas como posso ajudar e fico disponível para resolver os bloqueios que surgirem durante a execução.')
  ) as s(order_index, title, description);

-- Situação 2: Conflito e consenso
with q2 as (
  insert into public.questions (order_index, title)
  values (
    2,
    'Você e um colega discordam sobre qual solução adotar para um problema urgente. Como você age?'
  )
  returning id
)
insert into public.alternatives (question_id, order_index, title, description)
select q2.id, s.order_index, s.title, s.description
from q2,
  (values
    (1, 'Apresento minha visão',  'Defendo minha posição com argumentos claros e busco convencer o colega de que minha abordagem é a mais adequada para o momento.'),
    (2, 'Busco um consenso',      'Escuto a perspectiva do colega, apresento a minha e proponho encontrarmos juntos uma solução que absorva o melhor das duas ideias.'),
    (3, 'Analiso os dados',       'Peço tempo para comparar as duas abordagens com critérios objetivos antes de tomar qualquer decisão sobre qual caminho seguir.'),
    (4, 'Cedo para avançar',      'Deixo o colega seguir com a ideia dele para não atrasar a entrega e assumo que podemos corrigir o caminho se necessário.')
  ) as s(order_index, title, description);

-- Situação 3: Priorização sob pressão
with q3 as (
  insert into public.questions (order_index, title)
  values (
    3,
    'Três demandas urgentes chegam ao mesmo tempo e você sabe que não conseguirá entregar todas. O que você faz?'
  )
  returning id
)
insert into public.alternatives (question_id, order_index, title, description)
select q3.id, s.order_index, s.title, s.description
from q3,
  (values
    (1, 'Priorizo e decido',      'Avalio o impacto de cada demanda, defino a ordem de prioridade por conta própria e comunico minha decisão às partes envolvidas.'),
    (2, 'Entrego o que der',      'Começo pela tarefa mais rápida para gerar resultados imediatos e vou avançando nas demais conforme o tempo permite.'),
    (3, 'Peço orientação',        'Levo o problema para meu gestor e peço ajuda para definir o que é mais importante dado o contexto e os objetivos do momento.'),
    (4, 'Negocio os prazos',      'Entro em contato com os solicitantes, explico a situação e negocio novas datas para conseguir entregar tudo com a qualidade esperada.')
  ) as s(order_index, title, description);
