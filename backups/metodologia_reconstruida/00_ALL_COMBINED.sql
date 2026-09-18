-- Reconstrução completa da metodologia EVOLUA (nova taxonomia oficial) — 08/09/2026
-- Tudo ou nada: se qualquer linha falhar, o ROLLBACK abaixo garante que nada fica aplicado
-- parcialmente. A metodologia anterior permanece intacta até o COMMIT final ter sucesso.
begin;

-- 01_pillars.sql — UPDATE dos 7 pilares (mantém IDs)

update public.pillars set name = 'Organização e Rotina', description = 'Como a pessoa organiza suas atividades, administra seu tempo, estabelece prioridades e conduz sua rotina profissional.' where id = '10000000-0000-0000-0000-000000000001'; -- era: Autogestão
update public.pillars set name = 'Responsabilidade', description = 'Como a pessoa reage diante de erros, atrasos, consequências e responsabilidades.' where id = '10000000-0000-0000-0000-000000000002'; -- era: Comunicação
update public.pillars set name = 'Aprendizagem e Mudança', description = 'Como a pessoa reage a mudanças, novas tarefas, feedbacks e processos de aprendizagem.' where id = '10000000-0000-0000-0000-000000000003'; -- era: Relacionamento
update public.pillars set name = 'Relacionamentos', description = 'Como a pessoa se relaciona com colegas, diferenças, conflitos e situações de colaboração.' where id = '10000000-0000-0000-0000-000000000004'; -- era: Orientação a Resultados
update public.pillars set name = 'Comunicação', description = 'Como a pessoa transmite informações, apresenta ideias, comunica problemas, pede ajuda e orienta outras pessoas.' where id = '10000000-0000-0000-0000-000000000005'; -- era: Liderança
update public.pillars set name = 'Pressão e Decisão', description = 'Como a pessoa reage diante de pressão, múltiplas demandas, problemas e decisões.' where id = '10000000-0000-0000-0000-000000000006'; -- era: Inovação e Adaptação
update public.pillars set name = 'Crescimento e Ética', description = 'Como a pessoa reage diante de oportunidades de crescimento, autonomia, desenvolvimento de outras pessoas e situações que envolvem escolhas éticas.' where id = '10000000-0000-0000-0000-000000000007'; -- era: Desenvolvimento Contínuo
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

-- Categorias que não constam nas 10 oficiais — desativadas (não apagadas). Os vínculos antigos de alternative_motivators
-- (129 linhas, que a RLS escondia) já foram apagados antes do INSERT novo, então não há vínculo a preservar aqui.
update public.motivators set active = false where code in ('PRO', 'SEG');

-- 02_indicators.sql — UPDATE dos 35 indicadores (mantém IDs e pillar_number)

update public.indicators set name = 'Gestão do Tempo', description = 'Usa o tempo disponível de forma produtiva, sem deixá-lo ocioso ou mal aproveitado.' where id = '20000000-0000-0000-0000-000000000001'; -- I01, era: Responsabilidade Pessoal
update public.indicators set name = 'Priorização', description = 'Consegue decidir por onde começar diante de várias demandas.' where id = '20000000-0000-0000-0000-000000000002'; -- I02, era: Gestão Emocional
update public.indicators set name = 'Planejamento', description = 'Estrutura o trabalho antes de executar, em vez de agir por impulso.' where id = '20000000-0000-0000-0000-000000000003'; -- I03, era: Autoconfiança
update public.indicators set name = 'Consistência na Rotina', description = 'Mantém padrão de organização mesmo sem cobrança externa.' where id = '20000000-0000-0000-0000-000000000004'; -- I04, era: Disciplina e Consistência
update public.indicators set name = 'Fechamento de Ciclos', description = 'Finaliza atividades com cuidado, revisando antes de considerar concluído.' where id = '20000000-0000-0000-0000-000000000005'; -- I05, era: Clareza de Propósito
update public.indicators set name = 'Assunção de Erros', description = 'Reconhece e assume erros próprios sem se esconder ou culpar terceiros.' where id = '20000000-0000-0000-0000-000000000006'; -- I06, era: Clareza na Expressão
update public.indicators set name = 'Proatividade diante de Falhas', description = 'Age para corrigir ou mitigar um problema antes que ele escale.' where id = '20000000-0000-0000-0000-000000000007'; -- I07, era: Escuta Ativa
update public.indicators set name = 'Transparência sobre Atrasos', description = 'Comunica atrasos e riscos com antecedência, em vez de esconder até o último momento.' where id = '20000000-0000-0000-0000-000000000008'; -- I08, era: Assertividade
update public.indicators set name = 'Aceitação de Responsabilidade', description = 'Aceita e se apropria de responsabilidades inesperadas, mesmo fora do previsto.' where id = '20000000-0000-0000-0000-000000000009'; -- I09, era: Feedback Construtivo
update public.indicators set name = 'Cuidado com Impacto no Outro', description = 'Considera o efeito do próprio erro ou atraso sobre clientes e colegas.' where id = '20000000-0000-0000-0000-000000000010'; -- I10, era: Comunicação Adaptada
update public.indicators set name = 'Abertura a Mudança', description = 'Reage a mudanças de processo com adaptação, não resistência.' where id = '20000000-0000-0000-0000-000000000011'; -- I11, era: Empatia
update public.indicators set name = 'Disposição para o Novo', description = 'Aceita tarefas desconhecidas com disposição para aprender.' where id = '20000000-0000-0000-0000-000000000012'; -- I12, era: Colaboração
update public.indicators set name = 'Receptividade a Feedback', description = 'Recebe feedback sem se fechar ou se defender.' where id = '20000000-0000-0000-0000-000000000013'; -- I13, era: Gestão de Conflitos
update public.indicators set name = 'Autodesenvolvimento', description = 'Busca aprender ferramentas e conteúdos novos por iniciativa própria.' where id = '20000000-0000-0000-0000-000000000014'; -- I14, era: Construção de Confiança
update public.indicators set name = 'Flexibilidade Cognitiva', description = 'Ajusta a própria forma de pensar ou trabalhar diante do novo.' where id = '20000000-0000-0000-0000-000000000015'; -- I15, era: Influência Positiva
update public.indicators set name = 'Disposição para Ajudar', description = 'Se dispõe a ajudar colegas mesmo sem ser cobrado.' where id = '20000000-0000-0000-0000-000000000016'; -- I16, era: Planejamento e Organização
update public.indicators set name = 'Acolhimento', description = 'Acolhe pessoas novas ou diferentes no ambiente de trabalho.' where id = '20000000-0000-0000-0000-000000000017'; -- I17, era: Foco e Priorização
update public.indicators set name = 'Mediação de Conflitos', description = 'Age construtivamente diante de conflito entre colegas.' where id = '20000000-0000-0000-0000-000000000018'; -- I18, era: Gestão do Tempo
update public.indicators set name = 'Tolerância à Diferença', description = 'Trabalha bem com quem pensa de forma muito diferente.' where id = '20000000-0000-0000-0000-000000000019'; -- I19, era: Qualidade nas Entregas
update public.indicators set name = 'Construção de Confiança', description = 'Constrói relações de confiança ao longo do tempo.' where id = '20000000-0000-0000-0000-000000000020'; -- I20, era: Resiliência sob Pressão
update public.indicators set name = 'Iniciativa de Comunicação', description = 'Comunica ideias e melhorias por iniciativa própria.' where id = '20000000-0000-0000-0000-000000000021'; -- I21, era: Visão Estratégica
update public.indicators set name = 'Transparência com Liderança', description = 'Comunica problemas ao líder de forma clara e direta.' where id = '20000000-0000-0000-0000-000000000022'; -- I22, era: Tomada de Decisão
update public.indicators set name = 'Pedido de Ajuda', description = 'Reconhece o próprio limite e pede ajuda quando necessário.' where id = '20000000-0000-0000-0000-000000000023'; -- I23, era: Desenvolvimento de Pessoas
update public.indicators set name = 'Clareza na Orientação', description = 'Transmite instruções e orientações de forma compreensível para o outro.' where id = '20000000-0000-0000-0000-000000000024'; -- I24, era: Delegação Eficaz
update public.indicators set name = 'Adaptação da Mensagem', description = 'Ajusta a comunicação conforme quem está ouvindo.' where id = '20000000-0000-0000-0000-000000000025'; -- I25, era: Inspiração e Motivação
update public.indicators set name = 'Autonomia sob Pressão', description = 'Age e decide mesmo sem liderança presente.' where id = '20000000-0000-0000-0000-000000000026'; -- I26, era: Mentalidade de Crescimento
update public.indicators set name = 'Gestão de Múltiplas Demandas', description = 'Organiza-se diante de várias demandas simultâneas.' where id = '20000000-0000-0000-0000-000000000027'; -- I27, era: Criatividade Prática
update public.indicators set name = 'Lida com Insatisfação', description = 'Mantém-se construtivo diante de alguém insatisfeito.' where id = '20000000-0000-0000-0000-000000000028'; -- I28, era: Tolerância à Ambiguidade
update public.indicators set name = 'Decisão com Informação Limitada', description = 'Decide mesmo com informação incompleta.' where id = '20000000-0000-0000-0000-000000000029'; -- I29, era: Abertura ao Feedback
update public.indicators set name = 'Estabilidade sob Pressão', description = 'Mantém-se equilibrado emocionalmente sob pressão.' where id = '20000000-0000-0000-0000-000000000030'; -- I30, era: Adaptabilidade
update public.indicators set name = 'Busca por Crescimento', description = 'Aproveita oportunidades de crescimento quando surgem.' where id = '20000000-0000-0000-0000-000000000031'; -- I31, era: Autocrítica Construtiva
update public.indicators set name = 'Disposição para Ensinar', description = 'Se dispõe a ensinar e compartilhar conhecimento com outros.' where id = '20000000-0000-0000-0000-000000000032'; -- I32, era: Busca por Aprendizado
update public.indicators set name = 'Integridade', description = 'Escolhe o caminho correto mesmo quando é mais difícil.' where id = '20000000-0000-0000-0000-000000000033'; -- I33, era: Aplicação do Conhecimento
update public.indicators set name = 'Uso da Autonomia', description = 'Usa autonomia recebida de forma responsável.' where id = '20000000-0000-0000-0000-000000000034'; -- I34, era: Compartilhamento de Conhecimento
update public.indicators set name = 'Compromisso com Evolução', description = 'Demonstra compromisso contínuo com o próprio desenvolvimento.' where id = '20000000-0000-0000-0000-000000000035'; -- I35, era: Visão de Futuro
-- 03_questions.sql — UPDATE das 28 situações (mantém IDs)

update public.questions set title = 'Termino uma atividade e ainda tenho tempo disponível.', dimension = null where id = '30000000-0000-0000-0000-000000000001'; -- ordem 1
update public.questions set title = 'Inicio meu turno e existem várias tarefas para começar.', dimension = null where id = '30000000-0000-0000-0000-000000000002'; -- ordem 2
update public.questions set title = 'Preciso definir por onde começar o trabalho.', dimension = null where id = '30000000-0000-0000-0000-000000000003'; -- ordem 3
update public.questions set title = 'Estou finalizando uma atividade importante.', dimension = null where id = '30000000-0000-0000-0000-000000000004'; -- ordem 4
update public.questions set title = 'Percebo um erro que pode afetar um cliente.', dimension = null where id = '30000000-0000-0000-0000-000000000005'; -- ordem 5
update public.questions set title = 'Eu cometo um erro.', dimension = null where id = '30000000-0000-0000-0000-000000000006'; -- ordem 6
update public.questions set title = 'Percebo que vou atrasar uma entrega.', dimension = null where id = '30000000-0000-0000-0000-000000000007'; -- ordem 7
update public.questions set title = 'Recebo uma responsabilidade inesperada.', dimension = null where id = '30000000-0000-0000-0000-000000000008'; -- ordem 8
update public.questions set title = 'A empresa muda um processo.', dimension = null where id = '30000000-0000-0000-0000-000000000009'; -- ordem 9
update public.questions set title = 'Recebo uma tarefa que nunca fiz.', dimension = null where id = '30000000-0000-0000-0000-000000000010'; -- ordem 10
update public.questions set title = 'Recebo um feedback.', dimension = null where id = '30000000-0000-0000-0000-000000000011'; -- ordem 11
update public.questions set title = 'Preciso aprender uma ferramenta nova.', dimension = null where id = '30000000-0000-0000-0000-000000000012'; -- ordem 12
update public.questions set title = 'Um colega precisa de ajuda.', dimension = null where id = '30000000-0000-0000-0000-000000000013'; -- ordem 13
update public.questions set title = 'Chega um novo colaborador na equipe.', dimension = null where id = '30000000-0000-0000-0000-000000000014'; -- ordem 14
update public.questions set title = 'Existe um conflito entre dois colegas.', dimension = null where id = '30000000-0000-0000-0000-000000000015'; -- ordem 15
update public.questions set title = 'Preciso trabalhar com alguém que pensa muito diferente de mim.', dimension = null where id = '30000000-0000-0000-0000-000000000016'; -- ordem 16
update public.questions set title = 'Tenho uma ideia para melhorar um processo.', dimension = null where id = '30000000-0000-0000-0000-000000000017'; -- ordem 17
update public.questions set title = 'Preciso comunicar um problema ao meu líder.', dimension = null where id = '30000000-0000-0000-0000-000000000018'; -- ordem 18
update public.questions set title = 'Preciso pedir ajuda.', dimension = null where id = '30000000-0000-0000-0000-000000000019'; -- ordem 19
update public.questions set title = 'Preciso transmitir uma orientação importante para outra pessoa.', dimension = null where id = '30000000-0000-0000-0000-000000000020'; -- ordem 20
update public.questions set title = 'Surge um problema e o líder não está presente.', dimension = null where id = '30000000-0000-0000-0000-000000000021'; -- ordem 21
update public.questions set title = 'Recebo várias demandas ao mesmo tempo.', dimension = null where id = '30000000-0000-0000-0000-000000000022'; -- ordem 22
update public.questions set title = 'Um cliente está muito insatisfeito.', dimension = null where id = '30000000-0000-0000-0000-000000000023'; -- ordem 23
update public.questions set title = 'Preciso decidir com poucas informações.', dimension = null where id = '30000000-0000-0000-0000-000000000024'; -- ordem 24
update public.questions set title = 'Surge uma oportunidade de crescimento.', dimension = null where id = '30000000-0000-0000-0000-000000000025'; -- ordem 25
update public.questions set title = 'Preciso ensinar alguém.', dimension = null where id = '30000000-0000-0000-0000-000000000026'; -- ordem 26
update public.questions set title = 'Fazer o que é correto parece mais difícil do que fazer o mais fácil.', dimension = null where id = '30000000-0000-0000-0000-000000000027'; -- ordem 27
update public.questions set title = 'Recebo autonomia para tomar decisões importantes.', dimension = null where id = '30000000-0000-0000-0000-000000000028'; -- ordem 28
-- 04_alternatives.sql — UPDATE das 112 alternativas (mantém IDs)

update public.alternatives set title = 'Adianto a próxima tarefa', description = 'Adianto a próxima tarefa da minha lista.' where id = '40000000-0000-0000-0001-000000000001';
update public.alternatives set title = 'Revejo o que já entreguei', description = 'Reviso o que já entreguei, procurando algo para melhorar.' where id = '40000000-0000-0000-0001-000000000002';
update public.alternatives set title = 'Organizo as próximas atividades', description = 'Aproveito para organizar minhas próximas atividades.' where id = '40000000-0000-0000-0001-000000000003';
update public.alternatives set title = 'Pergunto se o time precisa de apoio', description = 'Pergunto ao time se alguém precisa de apoio.' where id = '40000000-0000-0000-0001-000000000004';
update public.alternatives set title = 'Ordeno pelas mais urgentes', description = 'Ordeno pelas mais urgentes primeiro.' where id = '40000000-0000-0000-0002-000000000001';
update public.alternatives set title = 'Faço uma lista antes de começar', description = 'Faço uma lista rápida antes de começar.' where id = '40000000-0000-0000-0002-000000000002';
update public.alternatives set title = 'Começo pela mais simples', description = 'Começo pela que me parece mais simples, para ganhar ritmo.' where id = '40000000-0000-0000-0002-000000000003';
update public.alternatives set title = 'Confirmo prioridades com o time', description = 'Confirmo com o time o que é mais importante antes de decidir.' where id = '40000000-0000-0000-0002-000000000004';
update public.alternatives set title = 'Começo pelo que trava o resto', description = 'Começo pela parte que trava as demais.' where id = '40000000-0000-0000-0003-000000000001';
update public.alternatives set title = 'Escrevo os passos antes de agir', description = 'Escrevo os passos antes de agir.' where id = '40000000-0000-0000-0003-000000000002';
update public.alternatives set title = 'Começo pela parte mais simples', description = 'Começo pela parte mais simples para pegar embalo.' where id = '40000000-0000-0000-0003-000000000003';
update public.alternatives set title = 'Peço uma referência', description = 'Peço uma referência de como já foi feito antes.' where id = '40000000-0000-0000-0003-000000000004';
update public.alternatives set title = 'Reviso com cuidado antes de entregar', description = 'Reviso tudo com cuidado antes de entregar.' where id = '40000000-0000-0000-0004-000000000001';
update public.alternatives set title = 'Entrego assim que fica pronta', description = 'Entrego assim que fica pronta, sem revisar muito.' where id = '40000000-0000-0000-0004-000000000002';
update public.alternatives set title = 'Peço para alguém revisar comigo', description = 'Peço para alguém revisar comigo antes de finalizar.' where id = '40000000-0000-0000-0004-000000000003';
update public.alternatives set title = 'Confiro item por item', description = 'Confiro se atendi tudo que foi pedido, ponto a ponto.' where id = '40000000-0000-0000-0004-000000000004';
update public.alternatives set title = 'Aviso imediatamente', description = 'Aviso imediatamente, mesmo sem ter a solução pronta.' where id = '40000000-0000-0000-0005-000000000001';
update public.alternatives set title = 'Busco entender o erro por completo', description = 'Busco entender o erro por completo antes de avisar.' where id = '40000000-0000-0000-0005-000000000002';
update public.alternatives set title = 'Aviso e já sugiro solução', description = 'Aviso e já sugiro uma forma de contornar.' where id = '40000000-0000-0000-0005-000000000003';
update public.alternatives set title = 'Converso com o time antes de decidir', description = 'Converso primeiro com o time antes de decidir o que fazer.' where id = '40000000-0000-0000-0005-000000000004';
update public.alternatives set title = 'Assumo na hora', description = 'Assumo na hora, sem justificar demais.' where id = '40000000-0000-0000-0006-000000000001';
update public.alternatives set title = 'Explico o que levou ao erro', description = 'Explico o que levou ao erro, para evitar que se repita.' where id = '40000000-0000-0000-0006-000000000002';
update public.alternatives set title = 'Peço desculpas primeiro', description = 'Peço desculpas a quem foi afetado antes de tudo.' where id = '40000000-0000-0000-0006-000000000003';
update public.alternatives set title = 'Corrijo antes de comentar', description = 'Corrijo o quanto antes e só depois comento o que houve.' where id = '40000000-0000-0000-0006-000000000004';
update public.alternatives set title = 'Aviso com nova estimativa', description = 'Aviso assim que percebo, com uma nova estimativa.' where id = '40000000-0000-0000-0007-000000000001';
update public.alternatives set title = 'Tento recuperar sozinho', description = 'Tento recuperar o atraso sozinho antes de avisar.' where id = '40000000-0000-0000-0007-000000000002';
update public.alternatives set title = 'Aviso e peço apoio', description = 'Aviso e pergunto se alguém pode ajudar a recuperar o prazo.' where id = '40000000-0000-0000-0007-000000000003';
update public.alternatives set title = 'Reorganizo minhas prioridades', description = 'Reorganizo minhas prioridades para tentar cumprir o prazo original.' where id = '40000000-0000-0000-0007-000000000004';
update public.alternatives set title = 'Aceito e já me organizo', description = 'Aceito e já penso em como organizar para dar conta.' where id = '40000000-0000-0000-0008-000000000001';
update public.alternatives set title = 'Aceito e pergunto o que se espera', description = 'Aceito, mas pergunto o que exatamente se espera de mim.' where id = '40000000-0000-0000-0008-000000000002';
update public.alternatives set title = 'Aceito e busco quem já fez', description = 'Aceito e busco quem já passou por isso para aprender rápido.' where id = '40000000-0000-0000-0008-000000000003';
update public.alternatives set title = 'Aceito e ajusto no caminho', description = 'Aceito, mesmo sentindo insegurança, e vou ajustando no caminho.' where id = '40000000-0000-0000-0008-000000000004';
update public.alternatives set title = 'Me adapto e sigo', description = 'Me adapto e sigo, mesmo sem entender todos os motivos.' where id = '40000000-0000-0000-0009-000000000001';
update public.alternatives set title = 'Pergunto o porquê antes', description = 'Pergunto o porquê da mudança antes de me adaptar.' where id = '40000000-0000-0000-0009-000000000002';
update public.alternatives set title = 'Testo por conta própria', description = 'Procuro entender o novo processo testando por conta própria.' where id = '40000000-0000-0000-0009-000000000003';
update public.alternatives set title = 'Sinto resistência, mas me ajusto', description = 'Sinto resistência no início, mas me ajusto aos poucos.' where id = '40000000-0000-0000-0009-000000000004';
update public.alternatives set title = 'Topo e aprendo na prática', description = 'Topo e vou aprendendo na prática.' where id = '40000000-0000-0000-0010-000000000001';
update public.alternatives set title = 'Pesquiso antes de começar', description = 'Pesquiso e estudo antes de começar.' where id = '40000000-0000-0000-0010-000000000002';
update public.alternatives set title = 'Pergunto a quem já fez', description = 'Pergunto a alguém que já fez para me orientar.' where id = '40000000-0000-0000-0010-000000000003';
update public.alternatives set title = 'Peço mais prazo', description = 'Aceito, mas peço um prazo maior por ser novidade.' where id = '40000000-0000-0000-0010-000000000004';
update public.alternatives set title = 'Ouço tudo antes de reagir', description = 'Ouço tudo antes de reagir ou explicar.' where id = '40000000-0000-0000-0011-000000000001';
update public.alternatives set title = 'Agradeço e já aplico', description = 'Agradeço e já penso em como aplicar.' where id = '40000000-0000-0000-0011-000000000002';
update public.alternatives set title = 'Peço exemplos concretos', description = 'Peço exemplos concretos para entender melhor.' where id = '40000000-0000-0000-0011-000000000003';
update public.alternatives set title = 'Fico incomodado, mas repenso depois', description = 'No momento fico incomodado, mas repenso depois com calma.' where id = '40000000-0000-0000-0011-000000000004';
update public.alternatives set title = 'Vou testando direto', description = 'Vou direto testando, sem ler manual antes.' where id = '40000000-0000-0000-0012-000000000001';
update public.alternatives set title = 'Procuro um curso antes', description = 'Procuro um curso ou material antes de usar.' where id = '40000000-0000-0000-0012-000000000002';
update public.alternatives set title = 'Peço para me mostrarem', description = 'Peço para alguém me mostrar na prática.' where id = '40000000-0000-0000-0012-000000000003';
update public.alternatives set title = 'Aprendo aos poucos', description = 'Vou aprendendo aos poucos, no ritmo das tarefas do dia a dia.' where id = '40000000-0000-0000-0012-000000000004';
update public.alternatives set title = 'Ajudo na hora', description = 'Ajudo na hora, mesmo interrompendo o que eu fazia.' where id = '40000000-0000-0000-0013-000000000001';
update public.alternatives set title = 'Pergunto o que ele precisa', description = 'Pergunto o que exatamente ele precisa antes de agir.' where id = '40000000-0000-0000-0013-000000000002';
update public.alternatives set title = 'Ajudo, mas combino um horário', description = 'Ajudo, mas combino um horário para não atrasar meu trabalho.' where id = '40000000-0000-0000-0013-000000000003';
update public.alternatives set title = 'Indico quem pode ajudar melhor', description = 'Indico alguém ou algo que pode ajudar melhor do que eu.' where id = '40000000-0000-0000-0013-000000000004';
update public.alternatives set title = 'Me aproximo e me apresento', description = 'Me aproximo e me apresento logo no início.' where id = '40000000-0000-0000-0014-000000000001';
update public.alternatives set title = 'Explico como as coisas funcionam', description = 'Explico como as coisas funcionam por aqui, sem esperar perguntarem.' where id = '40000000-0000-0000-0014-000000000002';
update public.alternatives set title = 'Deixo no ritmo dele', description = 'Deixo que ele se ambiente no próprio ritmo, mas fico disponível.' where id = '40000000-0000-0000-0014-000000000003';
update public.alternatives set title = 'Apresento o mais importante primeiro', description = 'Apresento as pessoas e processos mais importantes primeiro.' where id = '40000000-0000-0000-0014-000000000004';
update public.alternatives set title = 'Converso com os dois', description = 'Converso com os dois separadamente para entender os lados.' where id = '40000000-0000-0000-0015-000000000001';
update public.alternatives set title = 'Não me envolvo', description = 'Não me envolvo, a menos que afete o trabalho.' where id = '40000000-0000-0000-0015-000000000002';
update public.alternatives set title = 'Sugiro que conversem entre si', description = 'Sugiro que conversem diretamente entre si.' where id = '40000000-0000-0000-0015-000000000003';
update public.alternatives set title = 'Aviso alguém de confiança', description = 'Aviso alguém de confiança se percebo que está afetando o time.' where id = '40000000-0000-0000-0015-000000000004';
update public.alternatives set title = 'Procuro entender a lógica dela', description = 'Procuro entender a lógica da pessoa antes de discordar.' where id = '40000000-0000-0000-0016-000000000001';
update public.alternatives set title = 'Foco no resultado comum', description = 'Foco no resultado comum, mesmo com estilos diferentes.' where id = '40000000-0000-0000-0016-000000000002';
update public.alternatives set title = 'Ajusto minha comunicação', description = 'Ajusto minha forma de me comunicar para facilitar o trabalho.' where id = '40000000-0000-0000-0016-000000000003';
update public.alternatives set title = 'É difícil, mas encontro um jeito', description = 'No início é difícil, mas encontro um jeito de conviver.' where id = '40000000-0000-0000-0016-000000000004';
update public.alternatives set title = 'Compartilho assim que surge', description = 'Compartilho assim que a ideia surge.' where id = '40000000-0000-0000-0017-000000000001';
update public.alternatives set title = 'Estruturo antes de apresentar', description = 'Estruturo a ideia antes de apresentar.' where id = '40000000-0000-0000-0017-000000000002';
update public.alternatives set title = 'Testo antes de propor', description = 'Testo por conta própria antes de propor para os outros.' where id = '40000000-0000-0000-0017-000000000003';
update public.alternatives set title = 'Comento informalmente antes', description = 'Comento informalmente com alguém antes de levar adiante.' where id = '40000000-0000-0000-0017-000000000004';
update public.alternatives set title = 'Vou direto ao ponto', description = 'Vou direto ao ponto, sem enrolar.' where id = '40000000-0000-0000-0018-000000000001';
update public.alternatives set title = 'Já levo uma sugestão', description = 'Levo o problema já com uma sugestão de solução.' where id = '40000000-0000-0000-0018-000000000002';
update public.alternatives set title = 'Escolho um bom momento', description = 'Escolho um bom momento para não pegar de surpresa.' where id = '40000000-0000-0000-0018-000000000003';
update public.alternatives set title = 'Explico o contexto todo', description = 'Explico o contexto todo antes de chegar ao ponto.' where id = '40000000-0000-0000-0018-000000000004';
update public.alternatives set title = 'Peço direto', description = 'Peço direto, sem constrangimento.' where id = '40000000-0000-0000-0019-000000000001';
update public.alternatives set title = 'Tento sozinho primeiro', description = 'Tento resolver sozinho primeiro, e só depois peço.' where id = '40000000-0000-0000-0019-000000000002';
update public.alternatives set title = 'Explico onde travei', description = 'Peço ajuda explicando exatamente onde travei.' where id = '40000000-0000-0000-0019-000000000003';
update public.alternatives set title = 'Sinto receio, mas peço', description = 'Sinto receio, mas peço quando percebo que não vou conseguir sozinho.' where id = '40000000-0000-0000-0019-000000000004';
update public.alternatives set title = 'Explico de forma direta', description = 'Explico de forma direta e objetiva.' where id = '40000000-0000-0000-0020-000000000001';
update public.alternatives set title = 'Confirmo se entendeu', description = 'Confirmo se a pessoa entendeu, pedindo para repetir com as próprias palavras.' where id = '40000000-0000-0000-0020-000000000002';
update public.alternatives set title = 'Uso um exemplo prático', description = 'Uso um exemplo prático para facilitar o entendimento.' where id = '40000000-0000-0000-0020-000000000003';
update public.alternatives set title = 'Ajusto conforme a reação', description = 'Ajusto a explicação conforme percebo a reação da pessoa.' where id = '40000000-0000-0000-0020-000000000004';
update public.alternatives set title = 'Decido sozinho e informo depois', description = 'Decido sozinho e informo depois.' where id = '40000000-0000-0000-0021-000000000001';
update public.alternatives set title = 'Reúno o time para decidir', description = 'Reúno o time para decidir juntos.' where id = '40000000-0000-0000-0021-000000000002';
update public.alternatives set title = 'Tento contato com o líder', description = 'Tento contato com o líder antes de agir, se der tempo.' where id = '40000000-0000-0000-0021-000000000003';
update public.alternatives set title = 'Resolvo só o essencial', description = 'Ajo com cautela, resolvendo só o essencial até o líder voltar.' where id = '40000000-0000-0000-0021-000000000004';
update public.alternatives set title = 'Organizo por prioridade', description = 'Organizo por prioridade antes de começar qualquer uma.' where id = '40000000-0000-0000-0022-000000000001';
update public.alternatives set title = 'Alterno entre elas', description = 'Toco várias ao mesmo tempo, alternando entre elas.' where id = '40000000-0000-0000-0022-000000000002';
update public.alternatives set title = 'Negocio os prazos', description = 'Negocio prazos com quem pediu, se for preciso.' where id = '40000000-0000-0000-0022-000000000003';
update public.alternatives set title = 'Foco em uma de cada vez', description = 'Foco em uma de cada vez, do início ao fim.' where id = '40000000-0000-0000-0022-000000000004';
update public.alternatives set title = 'Ouço tudo antes de responder', description = 'Ouço tudo antes de responder qualquer coisa.' where id = '40000000-0000-0000-0023-000000000001';
update public.alternatives set title = 'Já busco uma solução', description = 'Reconheço o problema e já busco uma solução.' where id = '40000000-0000-0000-0023-000000000002';
update public.alternatives set title = 'Mantenho o tom calmo', description = 'Mantenho o tom calmo, mesmo se o cliente estiver alterado.' where id = '40000000-0000-0000-0023-000000000003';
update public.alternatives set title = 'Explico com transparência', description = 'Explico com transparência o que pode e o que não pode ser feito.' where id = '40000000-0000-0000-0023-000000000004';
update public.alternatives set title = 'Decido com o que tenho', description = 'Decido com o que tenho, mesmo com risco de errar.' where id = '40000000-0000-0000-0024-000000000001';
update public.alternatives set title = 'Busco mais informação rápido', description = 'Busco rapidamente mais alguma informação antes de decidir.' where id = '40000000-0000-0000-0024-000000000002';
update public.alternatives set title = 'Peço a opinião de alguém', description = 'Peço a opinião de alguém antes de decidir.' where id = '40000000-0000-0000-0024-000000000003';
update public.alternatives set title = 'Escolho a opção mais segura', description = 'Decido pela opção mais segura entre as possíveis.' where id = '40000000-0000-0000-0024-000000000004';
update public.alternatives set title = 'Abraço mesmo sem estar pronto', description = 'Abraço, mesmo sem me sentir 100% pronto.' where id = '40000000-0000-0000-0025-000000000001';
update public.alternatives set title = 'Avalio com calma antes', description = 'Avalio com calma se faz sentido antes de aceitar.' where id = '40000000-0000-0000-0025-000000000002';
update public.alternatives set title = 'Pergunto o que vai mudar', description = 'Pergunto o que vai mudar na prática antes de decidir.' where id = '40000000-0000-0000-0025-000000000003';
update public.alternatives set title = 'Já penso em quem pode ajudar', description = 'Aceito e já penso em quem pode me ajudar no caminho.' where id = '40000000-0000-0000-0025-000000000004';
update public.alternatives set title = 'Explico e deixo praticar', description = 'Explico e já deixo a pessoa praticar.' where id = '40000000-0000-0000-0026-000000000001';
update public.alternatives set title = 'Preparo um passo a passo', description = 'Preparo um passo a passo antes de ensinar.' where id = '40000000-0000-0000-0026-000000000002';
update public.alternatives set title = 'Ensino no ritmo dela', description = 'Ensino no ritmo da pessoa, com paciência.' where id = '40000000-0000-0000-0026-000000000003';
update public.alternatives set title = 'Uso exemplos reais', description = 'Uso exemplos reais para facilitar o entendimento.' where id = '40000000-0000-0000-0026-000000000004';
update public.alternatives set title = 'Escolho o caminho correto', description = 'Escolho o caminho correto, mesmo custando mais esforço.' where id = '40000000-0000-0000-0027-000000000001';
update public.alternatives set title = 'Penso nas consequências antes', description = 'Penso nas consequências antes de decidir o que fazer.' where id = '40000000-0000-0000-0027-000000000002';
update public.alternatives set title = 'Busco um jeito menos custoso', description = 'Busco uma forma de fazer certo que não seja tão custosa.' where id = '40000000-0000-0000-0027-000000000003';
update public.alternatives set title = 'Sinto a tentação, mas volto atrás', description = 'Sinto a tentação do caminho fácil, mas volto atrás e faço certo.' where id = '40000000-0000-0000-0027-000000000004';
update public.alternatives set title = 'Decido com confiança', description = 'Decido com confiança, assumindo o risco.' where id = '40000000-0000-0000-0028-000000000001';
update public.alternatives set title = 'Uso a autonomia com cautela', description = 'Uso a autonomia com cautela, validando pontos críticos.' where id = '40000000-0000-0000-0028-000000000002';
update public.alternatives set title = 'Envolvo o time mesmo assim', description = 'Envolvo o time nas decisões, mesmo tendo autonomia sozinho.' where id = '40000000-0000-0000-0028-000000000003';
update public.alternatives set title = 'Proponho algo diferente', description = 'Aproveito para propor algo diferente do que já era feito.' where id = '40000000-0000-0000-0028-000000000004';
-- 05_alternative_indicators.sql — INSERT dos vínculos alternativa -> indicador
-- ATENÇÃO: a tabela tinha 316 vínculos antigos (seed 005, taxonomia anterior) que a RLS
-- escondia das minhas leituras — apaga antes de inserir os novos, senão colide por PK duplicada.
delete from public.alternative_indicators;

insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values
  ('40000000-0000-0000-0001-000000000001', '20000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0001-000000000002', '20000000-0000-0000-0000-000000000005', 2),
  ('40000000-0000-0000-0001-000000000003', '20000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0001-000000000004', '20000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0002-000000000001', '20000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0002-000000000002', '20000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0002-000000000003', '20000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0002-000000000004', '20000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0003-000000000001', '20000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0003-000000000002', '20000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0003-000000000003', '20000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0003-000000000004', '20000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0004-000000000001', '20000000-0000-0000-0000-000000000005', 3),
  ('40000000-0000-0000-0004-000000000002', '20000000-0000-0000-0000-000000000005', 1),
  ('40000000-0000-0000-0004-000000000003', '20000000-0000-0000-0000-000000000005', 2),
  ('40000000-0000-0000-0004-000000000004', '20000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0005-000000000001', '20000000-0000-0000-0000-000000000010', 3),
  ('40000000-0000-0000-0005-000000000002', '20000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0005-000000000003', '20000000-0000-0000-0000-000000000007', 3),
  ('40000000-0000-0000-0005-000000000004', '20000000-0000-0000-0000-000000000010', 1),
  ('40000000-0000-0000-0006-000000000001', '20000000-0000-0000-0000-000000000006', 3),
  ('40000000-0000-0000-0006-000000000002', '20000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0006-000000000003', '20000000-0000-0000-0000-000000000010', 2),
  ('40000000-0000-0000-0006-000000000004', '20000000-0000-0000-0000-000000000007', 2),
  ('40000000-0000-0000-0007-000000000001', '20000000-0000-0000-0000-000000000008', 3),
  ('40000000-0000-0000-0007-000000000002', '20000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0007-000000000003', '20000000-0000-0000-0000-000000000008', 2),
  ('40000000-0000-0000-0007-000000000004', '20000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0008-000000000001', '20000000-0000-0000-0000-000000000009', 3),
  ('40000000-0000-0000-0008-000000000002', '20000000-0000-0000-0000-000000000009', 2),
  ('40000000-0000-0000-0008-000000000003', '20000000-0000-0000-0000-000000000009', 2),
  ('40000000-0000-0000-0008-000000000004', '20000000-0000-0000-0000-000000000009', 2),
  ('40000000-0000-0000-0009-000000000001', '20000000-0000-0000-0000-000000000011', 3),
  ('40000000-0000-0000-0009-000000000002', '20000000-0000-0000-0000-000000000011', 2),
  ('40000000-0000-0000-0009-000000000003', '20000000-0000-0000-0000-000000000014', 2),
  ('40000000-0000-0000-0009-000000000004', '20000000-0000-0000-0000-000000000011', 1),
  ('40000000-0000-0000-0010-000000000001', '20000000-0000-0000-0000-000000000012', 3),
  ('40000000-0000-0000-0010-000000000002', '20000000-0000-0000-0000-000000000012', 2),
  ('40000000-0000-0000-0010-000000000003', '20000000-0000-0000-0000-000000000012', 2),
  ('40000000-0000-0000-0010-000000000004', '20000000-0000-0000-0000-000000000012', 1),
  ('40000000-0000-0000-0011-000000000001', '20000000-0000-0000-0000-000000000013', 3),
  ('40000000-0000-0000-0011-000000000002', '20000000-0000-0000-0000-000000000013', 3),
  ('40000000-0000-0000-0011-000000000003', '20000000-0000-0000-0000-000000000013', 2),
  ('40000000-0000-0000-0011-000000000004', '20000000-0000-0000-0000-000000000013', 1),
  ('40000000-0000-0000-0012-000000000001', '20000000-0000-0000-0000-000000000014', 2),
  ('40000000-0000-0000-0012-000000000002', '20000000-0000-0000-0000-000000000014', 3),
  ('40000000-0000-0000-0012-000000000003', '20000000-0000-0000-0000-000000000014', 2),
  ('40000000-0000-0000-0012-000000000004', '20000000-0000-0000-0000-000000000014', 1),
  ('40000000-0000-0000-0013-000000000001', '20000000-0000-0000-0000-000000000016', 3),
  ('40000000-0000-0000-0013-000000000002', '20000000-0000-0000-0000-000000000016', 2),
  ('40000000-0000-0000-0013-000000000003', '20000000-0000-0000-0000-000000000016', 2),
  ('40000000-0000-0000-0013-000000000004', '20000000-0000-0000-0000-000000000016', 1),
  ('40000000-0000-0000-0014-000000000001', '20000000-0000-0000-0000-000000000017', 3),
  ('40000000-0000-0000-0014-000000000002', '20000000-0000-0000-0000-000000000017', 3),
  ('40000000-0000-0000-0014-000000000003', '20000000-0000-0000-0000-000000000017', 1),
  ('40000000-0000-0000-0014-000000000004', '20000000-0000-0000-0000-000000000017', 2),
  ('40000000-0000-0000-0015-000000000001', '20000000-0000-0000-0000-000000000018', 3),
  ('40000000-0000-0000-0015-000000000002', '20000000-0000-0000-0000-000000000018', 1),
  ('40000000-0000-0000-0015-000000000003', '20000000-0000-0000-0000-000000000018', 2),
  ('40000000-0000-0000-0015-000000000004', '20000000-0000-0000-0000-000000000018', 2),
  ('40000000-0000-0000-0016-000000000001', '20000000-0000-0000-0000-000000000019', 3),
  ('40000000-0000-0000-0016-000000000002', '20000000-0000-0000-0000-000000000019', 2),
  ('40000000-0000-0000-0016-000000000003', '20000000-0000-0000-0000-000000000019', 3),
  ('40000000-0000-0000-0016-000000000004', '20000000-0000-0000-0000-000000000019', 1),
  ('40000000-0000-0000-0017-000000000001', '20000000-0000-0000-0000-000000000021', 3),
  ('40000000-0000-0000-0017-000000000002', '20000000-0000-0000-0000-000000000021', 2),
  ('40000000-0000-0000-0017-000000000003', '20000000-0000-0000-0000-000000000021', 1),
  ('40000000-0000-0000-0017-000000000004', '20000000-0000-0000-0000-000000000021', 1),
  ('40000000-0000-0000-0018-000000000001', '20000000-0000-0000-0000-000000000022', 3),
  ('40000000-0000-0000-0018-000000000002', '20000000-0000-0000-0000-000000000022', 3),
  ('40000000-0000-0000-0018-000000000003', '20000000-0000-0000-0000-000000000022', 2),
  ('40000000-0000-0000-0018-000000000004', '20000000-0000-0000-0000-000000000022', 2),
  ('40000000-0000-0000-0019-000000000001', '20000000-0000-0000-0000-000000000023', 3),
  ('40000000-0000-0000-0019-000000000002', '20000000-0000-0000-0000-000000000023', 1),
  ('40000000-0000-0000-0019-000000000003', '20000000-0000-0000-0000-000000000023', 3),
  ('40000000-0000-0000-0019-000000000004', '20000000-0000-0000-0000-000000000023', 1),
  ('40000000-0000-0000-0020-000000000001', '20000000-0000-0000-0000-000000000024', 3),
  ('40000000-0000-0000-0020-000000000002', '20000000-0000-0000-0000-000000000024', 3),
  ('40000000-0000-0000-0020-000000000003', '20000000-0000-0000-0000-000000000025', 2),
  ('40000000-0000-0000-0020-000000000004', '20000000-0000-0000-0000-000000000025', 3),
  ('40000000-0000-0000-0021-000000000001', '20000000-0000-0000-0000-000000000026', 3),
  ('40000000-0000-0000-0021-000000000002', '20000000-0000-0000-0000-000000000026', 2),
  ('40000000-0000-0000-0021-000000000003', '20000000-0000-0000-0000-000000000026', 1),
  ('40000000-0000-0000-0021-000000000004', '20000000-0000-0000-0000-000000000026', 1),
  ('40000000-0000-0000-0022-000000000001', '20000000-0000-0000-0000-000000000027', 3),
  ('40000000-0000-0000-0022-000000000002', '20000000-0000-0000-0000-000000000027', 1),
  ('40000000-0000-0000-0022-000000000003', '20000000-0000-0000-0000-000000000027', 2),
  ('40000000-0000-0000-0022-000000000004', '20000000-0000-0000-0000-000000000027', 2),
  ('40000000-0000-0000-0023-000000000001', '20000000-0000-0000-0000-000000000028', 3),
  ('40000000-0000-0000-0023-000000000002', '20000000-0000-0000-0000-000000000028', 3),
  ('40000000-0000-0000-0023-000000000003', '20000000-0000-0000-0000-000000000028', 2),
  ('40000000-0000-0000-0023-000000000004', '20000000-0000-0000-0000-000000000028', 2),
  ('40000000-0000-0000-0024-000000000001', '20000000-0000-0000-0000-000000000029', 3),
  ('40000000-0000-0000-0024-000000000002', '20000000-0000-0000-0000-000000000029', 2),
  ('40000000-0000-0000-0024-000000000003', '20000000-0000-0000-0000-000000000029', 1),
  ('40000000-0000-0000-0024-000000000004', '20000000-0000-0000-0000-000000000029', 2),
  ('40000000-0000-0000-0025-000000000001', '20000000-0000-0000-0000-000000000031', 3),
  ('40000000-0000-0000-0025-000000000002', '20000000-0000-0000-0000-000000000031', 2),
  ('40000000-0000-0000-0025-000000000003', '20000000-0000-0000-0000-000000000031', 1),
  ('40000000-0000-0000-0025-000000000004', '20000000-0000-0000-0000-000000000031', 2),
  ('40000000-0000-0000-0026-000000000001', '20000000-0000-0000-0000-000000000032', 3),
  ('40000000-0000-0000-0026-000000000002', '20000000-0000-0000-0000-000000000032', 2),
  ('40000000-0000-0000-0026-000000000003', '20000000-0000-0000-0000-000000000032', 3),
  ('40000000-0000-0000-0026-000000000004', '20000000-0000-0000-0000-000000000032', 2),
  ('40000000-0000-0000-0027-000000000001', '20000000-0000-0000-0000-000000000033', 3),
  ('40000000-0000-0000-0027-000000000002', '20000000-0000-0000-0000-000000000033', 2),
  ('40000000-0000-0000-0027-000000000003', '20000000-0000-0000-0000-000000000033', 2),
  ('40000000-0000-0000-0027-000000000004', '20000000-0000-0000-0000-000000000033', 1),
  ('40000000-0000-0000-0028-000000000001', '20000000-0000-0000-0000-000000000034', 3),
  ('40000000-0000-0000-0028-000000000002', '20000000-0000-0000-0000-000000000034', 2),
  ('40000000-0000-0000-0028-000000000003', '20000000-0000-0000-0000-000000000034', 1),
  ('40000000-0000-0000-0028-000000000004', '20000000-0000-0000-0000-000000000034', 2);
-- 06_alternative_disc.sql
-- ATENÇÃO: tinha 195 vínculos antigos escondidos pela RLS — apaga antes de inserir.
delete from public.alternative_disc;

insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values
  ('40000000-0000-0000-0002-000000000001', '50000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0004-000000000002', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0005-000000000001', '50000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0006-000000000001', '50000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0006-000000000003', '50000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0007-000000000001', '50000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0007-000000000002', '50000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0008-000000000004', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0009-000000000001', '50000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0009-000000000004', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0011-000000000001', '50000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0011-000000000004', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0012-000000000004', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0013-000000000001', '50000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0014-000000000001', '50000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0014-000000000003', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0015-000000000002', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0015-000000000003', '50000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0016-000000000002', '50000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0016-000000000004', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0017-000000000001', '50000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0018-000000000001', '50000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0018-000000000003', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0019-000000000001', '50000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0019-000000000002', '50000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0019-000000000004', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0020-000000000001', '50000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0020-000000000004', '50000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0021-000000000001', '50000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0021-000000000004', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0022-000000000002', '50000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0022-000000000003', '50000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0022-000000000004', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0023-000000000001', '50000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0023-000000000003', '50000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0023-000000000004', '50000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0024-000000000001', '50000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0026-000000000003', '50000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0027-000000000004', '50000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0028-000000000002', '50000000-0000-0000-0000-000000000004', 2);
-- 07_alternative_psychological_types.sql
-- ATENÇÃO: tinha 150 vínculos antigos escondidos pela RLS — apaga antes de inserir.
delete from public.alternative_psychological_types;

insert into public.alternative_psychological_types (alternative_id, psychological_type_id, evidence_strength) values
  ('40000000-0000-0000-0001-000000000002', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0003-000000000001', '60000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0004-000000000001', '60000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0008-000000000002', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0009-000000000002', '60000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0010-000000000004', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0013-000000000002', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0013-000000000004', '60000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0015-000000000001', '60000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0015-000000000004', '60000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0016-000000000001', '60000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0020-000000000002', '60000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0020-000000000003', '60000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0021-000000000003', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0025-000000000003', '60000000-0000-0000-0000-000000000003', 1),
  ('40000000-0000-0000-0026-000000000004', '60000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0027-000000000003', '60000000-0000-0000-0000-000000000001', 2);
-- 08_alternative_motivators.sql
-- ATENÇÃO: tinha 129 vínculos antigos escondidos pela RLS — apaga antes de inserir.
delete from public.alternative_motivators;

insert into public.alternative_motivators (alternative_id, motivator_id, evidence_strength) values
  ('40000000-0000-0000-0008-000000000003', '70000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0009-000000000003', '70000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0010-000000000001', '70000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0010-000000000002', '70000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0011-000000000002', '70000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0012-000000000002', '70000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0021-000000000002', '70000000-0000-0000-0000-000000000010', 1),
  ('40000000-0000-0000-0024-000000000001', '70000000-0000-0000-0000-000000000008', 1),
  ('40000000-0000-0000-0025-000000000001', '70000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0028-000000000001', '70000000-0000-0000-0000-000000000005', 3),
  ('40000000-0000-0000-0028-000000000004', '70000000-0000-0000-0000-000000000002', 2);
-- 09_alternative_operational_styles.sql
-- ATENÇÃO: tinha 151 vínculos antigos escondidos pela RLS — apaga antes de inserir.
delete from public.alternative_operational_styles;

insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values
  ('40000000-0000-0000-0001-000000000001', '80000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0001-000000000003', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0001-000000000004', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0002-000000000002', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0002-000000000003', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0002-000000000004', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0003-000000000002', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0003-000000000003', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0004-000000000003', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0004-000000000004', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0005-000000000002', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0005-000000000003', '80000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0005-000000000004', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0006-000000000002', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0006-000000000004', '80000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0007-000000000003', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0007-000000000004', '80000000-0000-0000-0000-000000000002', 1),
  ('40000000-0000-0000-0008-000000000001', '80000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0010-000000000001', '80000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0010-000000000002', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0010-000000000003', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0011-000000000003', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0012-000000000001', '80000000-0000-0000-0000-000000000001', 2),
  ('40000000-0000-0000-0012-000000000002', '80000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0012-000000000003', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0013-000000000003', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0014-000000000002', '80000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0014-000000000004', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0016-000000000003', '80000000-0000-0000-0000-000000000004', 3),
  ('40000000-0000-0000-0017-000000000002', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0017-000000000003', '80000000-0000-0000-0000-000000000001', 1),
  ('40000000-0000-0000-0017-000000000004', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0018-000000000002', '80000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0018-000000000004', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0019-000000000003', '80000000-0000-0000-0000-000000000003', 3),
  ('40000000-0000-0000-0021-000000000002', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0022-000000000001', '80000000-0000-0000-0000-000000000002', 3),
  ('40000000-0000-0000-0023-000000000002', '80000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0024-000000000002', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0024-000000000003', '80000000-0000-0000-0000-000000000004', 1),
  ('40000000-0000-0000-0025-000000000002', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0025-000000000004', '80000000-0000-0000-0000-000000000004', 2),
  ('40000000-0000-0000-0026-000000000001', '80000000-0000-0000-0000-000000000001', 3),
  ('40000000-0000-0000-0026-000000000002', '80000000-0000-0000-0000-000000000002', 2),
  ('40000000-0000-0000-0027-000000000002', '80000000-0000-0000-0000-000000000003', 2),
  ('40000000-0000-0000-0028-000000000003', '80000000-0000-0000-0000-000000000004', 1);

-- Se chegou até aqui sem erro, aplica tudo de uma vez. Se qualquer linha acima falhou,
-- a transação já foi abortada pelo Postgres e este COMMIT não terá efeito algum.
commit;
