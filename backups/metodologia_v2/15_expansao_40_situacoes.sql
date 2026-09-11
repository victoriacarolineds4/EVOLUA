-- ============================================================
-- EVOLUA — Expansão de 28 para 40 situações
-- Aplicação em produção (11/09/2026)
-- ============================================================
-- PASSO 1 — backup das tabelas afetadas antes de qualquer mudança.
-- ============================================================

begin;

create table if not exists public._backup_questions_20260911 as
  select * from public.questions;
create table if not exists public._backup_alternatives_20260911 as
  select * from public.alternatives;
create table if not exists public._backup_alternative_indicators_20260911_expansao as
  select * from public.alternative_indicators;

-- ============================================================
-- PASSO 2 — insere as 12 novas situações (S29-S40), 48
-- alternativas e 52 vínculos. Não toca nenhuma linha existente.
-- ============================================================

-- Situações 29-40
insert into public.questions (id, order_index, pillar_number, title, active) values
  ('30000000-0000-0000-0000-000000000029', 29, 1, 'Boa parte das suas tarefas desta semana está travada, esperando retorno de outras pessoas.', true),
  ('30000000-0000-0000-0000-000000000030', 30, 1, 'Seu gestor viaja por uma semana e ninguém vai acompanhar de perto o seu dia a dia.', true),
  ('30000000-0000-0000-0000-000000000031', 31, 1, 'Um projeto que você acompanhou por semanas está chegando ao fim.', true),
  ('30000000-0000-0000-0000-000000000032', 32, 2, 'Alguém aponta, na frente do time, um erro que você cometeu.', true),
  ('30000000-0000-0000-0000-000000000033', 33, 2, 'No meio de um projeto, você percebe que uma etapa anterior — que não dependia de você — vai atrasar tudo.', true),
  ('30000000-0000-0000-0000-000000000034', 34, 3, 'Um jeito de trabalhar que sempre deu certo para você para de funcionar bem num contexto novo (outro time, outro tipo de projeto).', true),
  ('30000000-0000-0000-0000-000000000035', 35, 4, 'Duas pessoas do seu time discordam fortemente sobre como resolver um problema, e a discussão está esquentando numa reunião.', true),
  ('30000000-0000-0000-0000-000000000036', 36, 6, 'Surge uma boa oportunidade (fechar algo importante com um cliente, por exemplo), mas seu líder está inacessível e a janela de tempo é curta.', true),
  ('30000000-0000-0000-0000-000000000037', 37, 6, 'Seu líder diz que não ficou satisfeito com uma entrega sua.', true),
  ('30000000-0000-0000-0000-000000000038', 38, 7, 'Você percebe uma lacuna de conhecimento que está te limitando, mas ninguém pediu para você resolver isso.', true),
  ('30000000-0000-0000-0000-000000000039', 39, 7, 'Você domina algo que seria útil para um colega de outra área, mas ele não pediu ajuda.', true),
  ('30000000-0000-0000-0000-000000000040', 40, 7, 'Você tem total autonomia para decidir como organizar seu próprio tempo de trabalho ao longo da semana — ninguém define isso por você.', true);

-- Alternativas
insert into public.alternatives (id, question_id, order_index, letter, title, description) values
  ('40000000-0000-0000-0029-000000000001', '30000000-0000-0000-0000-000000000029', 1, 'A', 'Adianto outras entregas', 'Uso o tempo livre para adiantar outras entregas que não dependem de ninguém.'),
  ('40000000-0000-0000-0029-000000000002', '30000000-0000-0000-0000-000000000029', 2, 'B', 'Fico esperando as respostas', 'Fico de olho esperando as respostas chegarem, sem começar mais nada.'),
  ('40000000-0000-0000-0029-000000000003', '30000000-0000-0000-0000-000000000029', 3, 'C', 'Resolvo pendências pequenas', 'Aproveito para resolver pendências pequenas que vinha adiando.'),
  ('40000000-0000-0000-0029-000000000004', '30000000-0000-0000-0000-000000000029', 4, 'D', 'Aproveito para descansar', 'Aproveito para descansar, já que a semana ficou mais leve mesmo.'),
  ('40000000-0000-0000-0030-000000000001', '30000000-0000-0000-0000-000000000030', 1, 'A', 'Sigo a mesma rotina', 'Sigo exatamente a mesma rotina, nos mesmos horários, como se meu gestor estivesse presente.'),
  ('40000000-0000-0000-0030-000000000002', '30000000-0000-0000-0000-000000000030', 2, 'B', 'Relaxo o padrão', 'Relaxo o padrão desde o início, já que ninguém vai notar.'),
  ('40000000-0000-0000-0030-000000000003', '30000000-0000-0000-0000-000000000030', 3, 'C', 'Vou relaxando com o tempo', 'Mantenho a rotina no começo da semana, mas ela vai ficando mais solta perto do fim.'),
  ('40000000-0000-0000-0030-000000000004', '30000000-0000-0000-0000-000000000030', 4, 'D', 'Mantenho prazos, flexibilizo o resto', 'Mantenho os compromissos e prazos em dia, mas sou mais livre em como e quando organizo o resto do meu dia.'),
  ('40000000-0000-0000-0031-000000000001', '30000000-0000-0000-0000-000000000031', 1, 'A', 'Faço revisão completa', 'Faço uma revisão completa antes de considerar encerrado.'),
  ('40000000-0000-0000-0031-000000000002', '30000000-0000-0000-0000-000000000031', 2, 'B', 'Já parto para o próximo', 'Assim que a entrega principal sai, já parto para o próximo projeto.'),
  ('40000000-0000-0000-0031-000000000003', '30000000-0000-0000-0000-000000000031', 3, 'C', 'Peço fechamento formal', 'Peço um fechamento formal com quem participou antes de considerar concluído.'),
  ('40000000-0000-0000-0031-000000000004', '30000000-0000-0000-0000-000000000031', 4, 'D', 'Registro o aprendizado', 'Registro o que aprendi com o projeto antes de arquivar.'),
  ('40000000-0000-0000-0032-000000000001', '30000000-0000-0000-0000-000000000032', 1, 'A', 'Assumo na hora', 'Assumo na hora, mesmo sendo desconfortável.'),
  ('40000000-0000-0000-0032-000000000002', '30000000-0000-0000-0000-000000000032', 2, 'B', 'Explico o contexto antes', 'Explico o contexto que levou ao erro antes de admitir.'),
  ('40000000-0000-0000-0032-000000000003', '30000000-0000-0000-0000-000000000032', 3, 'C', 'Minimizo o ocorrido', 'Minimizo, dizendo que não foi bem assim.'),
  ('40000000-0000-0000-0032-000000000004', '30000000-0000-0000-0000-000000000032', 4, 'D', 'Agradeço e corrijo depois', 'Agradeço por terem apontado e corrijo depois.'),
  ('40000000-0000-0000-0033-000000000001', '30000000-0000-0000-0000-000000000033', 1, 'A', 'Aviso todos os afetados', 'Aviso imediatamente todos os afetados, com uma nova estimativa.'),
  ('40000000-0000-0000-0033-000000000002', '30000000-0000-0000-0000-000000000033', 2, 'B', 'Tento absorver sozinho', 'Tento absorver o atraso sozinho, sem avisar ninguém.'),
  ('40000000-0000-0000-0033-000000000003', '30000000-0000-0000-0000-000000000033', 3, 'C', 'Aviso só o responsável direto', 'Aviso só a pessoa responsável direta, não o grupo todo.'),
  ('40000000-0000-0000-0033-000000000004', '30000000-0000-0000-0000-000000000033', 4, 'D', 'Espero antes de avisar', 'Espero para ver se ainda dá tempo de recuperar antes de avisar.'),
  ('40000000-0000-0000-0034-000000000001', '30000000-0000-0000-0000-000000000034', 1, 'A', 'Mudo de abordagem rápido', 'Mudo de abordagem rapidamente para me adaptar.'),
  ('40000000-0000-0000-0034-000000000002', '30000000-0000-0000-0000-000000000034', 2, 'B', 'Insisto na mesma abordagem', 'Insisto na mesma abordagem, tentando fazer funcionar.'),
  ('40000000-0000-0000-0034-000000000003', '30000000-0000-0000-0000-000000000034', 3, 'C', 'Misturo o antigo com o novo', 'Misturo o jeito antigo com elementos novos, testando aos poucos.'),
  ('40000000-0000-0000-0034-000000000004', '30000000-0000-0000-0000-000000000034', 4, 'D', 'Busco entender antes de mudar', 'Busco entender por que não está funcionando antes de mudar qualquer coisa.'),
  ('40000000-0000-0000-0035-000000000001', '30000000-0000-0000-0000-000000000035', 1, 'A', 'Intervenho na hora', 'Intervenho na hora, propondo um jeito de decidir.'),
  ('40000000-0000-0000-0035-000000000002', '30000000-0000-0000-0000-000000000035', 2, 'B', 'Deixo esfriar', 'Deixo esfriar e volto ao assunto depois.'),
  ('40000000-0000-0000-0035-000000000003', '30000000-0000-0000-0000-000000000035', 3, 'C', 'Peço que expliquem antes', 'Peço que cada um explique o ponto de vista antes de decidirmos juntos.'),
  ('40000000-0000-0000-0035-000000000004', '30000000-0000-0000-0000-000000000035', 4, 'D', 'Decido sozinho para encerrar', 'Decido por conta própria para encerrar a discussão.'),
  ('40000000-0000-0000-0036-000000000001', '30000000-0000-0000-0000-000000000036', 1, 'A', 'Decido e aproveito sozinho', 'Decido e aproveito a oportunidade sozinho.'),
  ('40000000-0000-0000-0036-000000000002', '30000000-0000-0000-0000-000000000036', 2, 'B', 'Deixo passar', 'Deixo passar por não ter aval.'),
  ('40000000-0000-0000-0036-000000000003', '30000000-0000-0000-0000-000000000036', 3, 'C', 'Tento adiar até falar com o líder', 'Tento adiar a decisão até conseguir falar com o líder, mesmo que isso signifique perder a chance.'),
  ('40000000-0000-0000-0036-000000000004', '30000000-0000-0000-0000-000000000036', 4, 'D', 'Decido de forma reversível', 'Decido sozinho, mas de um jeito que dá pra desfazer se não der certo.'),
  ('40000000-0000-0000-0037-000000000001', '30000000-0000-0000-0000-000000000037', 1, 'A', 'Ouço com calma e pergunto', 'Ouço com calma e pergunto o que ele esperava diferente.'),
  ('40000000-0000-0000-0037-000000000002', '30000000-0000-0000-0000-000000000037', 2, 'B', 'Fico na defensiva', 'Fico na defensiva, justificando antes de ouvir tudo.'),
  ('40000000-0000-0000-0037-000000000003', '30000000-0000-0000-0000-000000000037', 3, 'C', 'Concordo rápido demais', 'Concordo rápido demais só para encerrar o desconforto.'),
  ('40000000-0000-0000-0037-000000000004', '30000000-0000-0000-0000-000000000037', 4, 'D', 'Peço um tempo para processar', 'Peço um tempo para processar e volto depois com uma resposta.'),
  ('40000000-0000-0000-0038-000000000001', '30000000-0000-0000-0000-000000000038', 1, 'A', 'Já começo a estudar', 'Já começo a estudar por conta própria.'),
  ('40000000-0000-0000-0038-000000000002', '30000000-0000-0000-0000-000000000038', 2, 'B', 'Espero um treinamento oferecido', 'Espero surgir um treinamento oferecido pela empresa para resolver isso.'),
  ('40000000-0000-0000-0038-000000000003', '30000000-0000-0000-0000-000000000038', 3, 'C', 'Busco quem me oriente', 'Busco alguém que domina o assunto para me orientar nos estudos.'),
  ('40000000-0000-0000-0038-000000000004', '30000000-0000-0000-0000-000000000038', 4, 'D', 'Anoto para depois', 'Anoto para resolver quando "tiver mais tempo".'),
  ('40000000-0000-0000-0039-000000000001', '30000000-0000-0000-0000-000000000039', 1, 'A', 'Ofereço ensinar', 'Ofereço ensinar mesmo sem ele ter pedido.'),
  ('40000000-0000-0000-0039-000000000002', '30000000-0000-0000-0000-000000000039', 2, 'B', 'Espero ele pedir', 'Espero ele pedir — não quero parecer intrometido.'),
  ('40000000-0000-0000-0039-000000000003', '30000000-0000-0000-0000-000000000039', 3, 'C', 'Mando material', 'Mando um material ou link em vez de ensinar pessoalmente.'),
  ('40000000-0000-0000-0039-000000000004', '30000000-0000-0000-0000-000000000039', 4, 'D', 'Menciono, mas só se insistir', 'Menciono que sei fazer aquilo, mas só ensino se ele insistir.'),
  ('40000000-0000-0000-0040-000000000001', '30000000-0000-0000-0000-000000000040', 1, 'A', 'Estruturo com metas claras', 'Estruturo meu tempo com metas claras para cada dia.'),
  ('40000000-0000-0000-0040-000000000002', '30000000-0000-0000-0000-000000000040', 2, 'B', 'Vou decidindo dia a dia', 'Vou decidindo dia a dia, conforme surge, sem um plano fixo.'),
  ('40000000-0000-0000-0040-000000000003', '30000000-0000-0000-0000-000000000040', 3, 'C', 'Foco no que gosto de fazer', 'Uso a liberdade para me dedicar mais ao que gosto de fazer, mesmo deixando outras partes do trabalho de lado.'),
  ('40000000-0000-0000-0040-000000000004', '30000000-0000-0000-0000-000000000040', 4, 'D', 'Reviso e ajusto periodicamente', 'Reviso periodicamente como estou usando esse tempo e ajusto o que não está funcionando.');

-- Vínculos alternative_indicators
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values
  ('40000000-0000-0000-0029-000000000001', '20000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0029-000000000002', '20000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0029-000000000003', '20000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0029-000000000004', '20000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0030-000000000001', '20000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0030-000000000002', '20000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0030-000000000003', '20000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0030-000000000004', '20000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0031-000000000001', '20000000-0000-0000-0000-000000000005', 3),
  ('40000000-0000-0000-0031-000000000002', '20000000-0000-0000-0000-000000000005', 1),
  ('40000000-0000-0000-0031-000000000003', '20000000-0000-0000-0000-000000000005', 2),
  ('40000000-0000-0000-0031-000000000004', '20000000-0000-0000-0000-000000000005', 2),
  ('40000000-0000-0000-0032-000000000001', '20000000-0000-0000-0000-000000000006', 3),
  ('40000000-0000-0000-0032-000000000002', '20000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0032-000000000003', '20000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0032-000000000004', '20000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0032-000000000004', '20000000-0000-0000-0000-000000000013', 2),
  ('40000000-0000-0000-0033-000000000001', '20000000-0000-0000-0000-000000000008', 3),
  ('40000000-0000-0000-0033-000000000001', '20000000-0000-0000-0000-000000000010', 1),
  ('40000000-0000-0000-0033-000000000002', '20000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0033-000000000003', '20000000-0000-0000-0000-000000000008', 2),
  ('40000000-0000-0000-0033-000000000004', '20000000-0000-0000-0000-000000000008', 2),
  ('40000000-0000-0000-0034-000000000001', '20000000-0000-0000-0000-000000000015', 3),
  ('40000000-0000-0000-0034-000000000002', '20000000-0000-0000-0000-000000000015', 1),
  ('40000000-0000-0000-0034-000000000003', '20000000-0000-0000-0000-000000000015', 2),
  ('40000000-0000-0000-0034-000000000004', '20000000-0000-0000-0000-000000000015', 2),
  ('40000000-0000-0000-0035-000000000001', '20000000-0000-0000-0000-000000000018', 3),
  ('40000000-0000-0000-0035-000000000002', '20000000-0000-0000-0000-000000000018', 1),
  ('40000000-0000-0000-0035-000000000003', '20000000-0000-0000-0000-000000000018', 3),
  ('40000000-0000-0000-0035-000000000003', '20000000-0000-0000-0000-000000000019', 1),
  ('40000000-0000-0000-0035-000000000004', '20000000-0000-0000-0000-000000000018', 1),
  ('40000000-0000-0000-0036-000000000001', '20000000-0000-0000-0000-000000000026', 3),
  ('40000000-0000-0000-0036-000000000002', '20000000-0000-0000-0000-000000000026', 1),
  ('40000000-0000-0000-0036-000000000003', '20000000-0000-0000-0000-000000000026', 1),
  ('40000000-0000-0000-0036-000000000004', '20000000-0000-0000-0000-000000000026', 2),
  ('40000000-0000-0000-0037-000000000001', '20000000-0000-0000-0000-000000000028', 3),
  ('40000000-0000-0000-0037-000000000001', '20000000-0000-0000-0000-000000000013', 2),
  ('40000000-0000-0000-0037-000000000002', '20000000-0000-0000-0000-000000000028', 1),
  ('40000000-0000-0000-0037-000000000003', '20000000-0000-0000-0000-000000000028', 1),
  ('40000000-0000-0000-0037-000000000004', '20000000-0000-0000-0000-000000000028', 2),
  ('40000000-0000-0000-0038-000000000001', '20000000-0000-0000-0000-000000000031', 3),
  ('40000000-0000-0000-0038-000000000002', '20000000-0000-0000-0000-000000000031', 1),
  ('40000000-0000-0000-0038-000000000003', '20000000-0000-0000-0000-000000000031', 2),
  ('40000000-0000-0000-0038-000000000004', '20000000-0000-0000-0000-000000000031', 1),
  ('40000000-0000-0000-0039-000000000001', '20000000-0000-0000-0000-000000000032', 3),
  ('40000000-0000-0000-0039-000000000002', '20000000-0000-0000-0000-000000000032', 1),
  ('40000000-0000-0000-0039-000000000003', '20000000-0000-0000-0000-000000000032', 2),
  ('40000000-0000-0000-0039-000000000004', '20000000-0000-0000-0000-000000000032', 2),
  ('40000000-0000-0000-0040-000000000001', '20000000-0000-0000-0000-000000000034', 3),
  ('40000000-0000-0000-0040-000000000002', '20000000-0000-0000-0000-000000000034', 2),
  ('40000000-0000-0000-0040-000000000003', '20000000-0000-0000-0000-000000000034', 1),
  ('40000000-0000-0000-0040-000000000004', '20000000-0000-0000-0000-000000000034', 3);

-- ============================================================
-- PASSO 3 — verificação: deve retornar 40, 160 e 192
-- (140 vínculos já existentes + 52 novos).
-- ============================================================
select 'questions' t, count(*) from public.questions
union all select 'alternatives', count(*) from public.alternatives
union all select 'alternative_indicators', count(*) from public.alternative_indicators;

commit;
