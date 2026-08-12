-- ============================================================
-- EVOLUA — Seed Oficial da Metodologia
-- Sprint 06 — Versão 1.0
--
-- Estrutura:
--   7  pilares     (IDs: 1000...0001 a 1000...0007)
--   35 indicadores (IDs: 2000...0001 a 2000...0035)
--   28 situações   (IDs: 3000...0001 a 3000...0028)
--  112 alternativas (IDs: 4000...QQQQ-000L onde QQQQ=situação L=1-4)
--
-- Idempotência:
--   • Envolto em transação
--   • Remove questões e alternativas fora do conjunto oficial
--     (limpa seed de teste antes de inserir dados oficiais)
--   • INSERT ... ON CONFLICT (id) DO UPDATE para re-execuções seguras
-- ============================================================

begin;

-- ============================================================
-- LIMPEZA: remove dados de desenvolvimento fora do conjunto oficial
-- Necessário pois questões de teste usam gen_random_uuid() e
-- conflitam com order_index UNIQUE das questões oficiais.
-- ON DELETE CASCADE propaga para alternatives e answers.
-- ============================================================

delete from public.questions
where id not in (
  '30000000-0000-0000-0000-000000000001',
  '30000000-0000-0000-0000-000000000002',
  '30000000-0000-0000-0000-000000000003',
  '30000000-0000-0000-0000-000000000004',
  '30000000-0000-0000-0000-000000000005',
  '30000000-0000-0000-0000-000000000006',
  '30000000-0000-0000-0000-000000000007',
  '30000000-0000-0000-0000-000000000008',
  '30000000-0000-0000-0000-000000000009',
  '30000000-0000-0000-0000-000000000010',
  '30000000-0000-0000-0000-000000000011',
  '30000000-0000-0000-0000-000000000012',
  '30000000-0000-0000-0000-000000000013',
  '30000000-0000-0000-0000-000000000014',
  '30000000-0000-0000-0000-000000000015',
  '30000000-0000-0000-0000-000000000016',
  '30000000-0000-0000-0000-000000000017',
  '30000000-0000-0000-0000-000000000018',
  '30000000-0000-0000-0000-000000000019',
  '30000000-0000-0000-0000-000000000020',
  '30000000-0000-0000-0000-000000000021',
  '30000000-0000-0000-0000-000000000022',
  '30000000-0000-0000-0000-000000000023',
  '30000000-0000-0000-0000-000000000024',
  '30000000-0000-0000-0000-000000000025',
  '30000000-0000-0000-0000-000000000026',
  '30000000-0000-0000-0000-000000000027',
  '30000000-0000-0000-0000-000000000028'
);

-- ============================================================
-- PILARES (7)
-- ============================================================

insert into public.pillars (id, number, name, description, active) values
  ('10000000-0000-0000-0000-000000000001', 1, 'Autogestão',
   'Capacidade de gerenciar a si mesmo com responsabilidade, equilíbrio e disciplina.', true),

  ('10000000-0000-0000-0000-000000000002', 2, 'Comunicação',
   'Habilidade de se expressar com clareza, ouvir com profundidade e se adaptar ao interlocutor.', true),

  ('10000000-0000-0000-0000-000000000003', 3, 'Relacionamento',
   'Qualidade das conexões interpessoais, gestão de conflitos e construção de confiança.', true),

  ('10000000-0000-0000-0000-000000000004', 4, 'Orientação a Resultados',
   'Foco consistente em metas, entregas e qualidade mesmo sob pressão.', true),

  ('10000000-0000-0000-0000-000000000005', 5, 'Liderança',
   'Capacidade de influenciar, tomar decisões e desenvolver pessoas ao redor.', true),

  ('10000000-0000-0000-0000-000000000006', 6, 'Inovação e Adaptação',
   'Abertura ao novo, criatividade prática e resiliência diante de mudanças.', true),

  ('10000000-0000-0000-0000-000000000007', 7, 'Desenvolvimento Contínuo',
   'Compromisso com o crescimento próprio, aprendizado constante e compartilhamento de conhecimento.', true)

on conflict (id) do update set
  number      = excluded.number,
  name        = excluded.name,
  description = excluded.description,
  active      = excluded.active;

-- ============================================================
-- INDICADORES (35 — 5 por pilar)
-- ============================================================

insert into public.indicators (id, code, name, description, pillar_number, active) values

  -- Pilar 1 — Autogestão
  ('20000000-0000-0000-0000-000000000001', 'I01', 'Responsabilidade Pessoal',
   'Assume compromissos, responde pelos próprios resultados e não transfere a culpa.', 1, true),
  ('20000000-0000-0000-0000-000000000002', 'I02', 'Gestão Emocional',
   'Regula as próprias emoções diante de situações de pressão, conflito ou adversidade.', 1, true),
  ('20000000-0000-0000-0000-000000000003', 'I03', 'Autoconfiança',
   'Age com segurança e convicção nas próprias capacidades, mesmo em contextos desafiadores.', 1, true),
  ('20000000-0000-0000-0000-000000000004', 'I04', 'Disciplina e Consistência',
   'Mantém foco e comprometimento com regularidade ao longo do tempo, sem supervisão constante.', 1, true),
  ('20000000-0000-0000-0000-000000000005', 'I05', 'Clareza de Propósito',
   'Conhece seus valores e os utiliza como guia para decisões e ações cotidianas.', 1, true),

  -- Pilar 2 — Comunicação
  ('20000000-0000-0000-0000-000000000006', 'I06', 'Clareza na Expressão',
   'Transmite ideias de forma objetiva, estruturada e compreensível para diferentes públicos.', 2, true),
  ('20000000-0000-0000-0000-000000000007', 'I07', 'Escuta Ativa',
   'Ouve com atenção genuína e busca compreender antes de responder ou julgar.', 2, true),
  ('20000000-0000-0000-0000-000000000008', 'I08', 'Assertividade',
   'Posiciona-se com clareza e respeito, sem passividade nem agressividade.', 2, true),
  ('20000000-0000-0000-0000-000000000009', 'I09', 'Feedback Construtivo',
   'Oferece e recebe feedbacks de forma objetiva e orientada ao crescimento.', 2, true),
  ('20000000-0000-0000-0000-000000000010', 'I10', 'Comunicação Adaptada',
   'Ajusta linguagem e estilo de acordo com o interlocutor e o contexto da conversa.', 2, true),

  -- Pilar 3 — Relacionamento
  ('20000000-0000-0000-0000-000000000011', 'I11', 'Empatia',
   'Compreende e considera a perspectiva e o estado emocional do outro antes de agir.', 3, true),
  ('20000000-0000-0000-0000-000000000012', 'I12', 'Colaboração',
   'Contribui ativamente para o sucesso coletivo, além das próprias metas individuais.', 3, true),
  ('20000000-0000-0000-0000-000000000013', 'I13', 'Gestão de Conflitos',
   'Administra divergências de forma construtiva, preservando o relacionamento.', 3, true),
  ('20000000-0000-0000-0000-000000000014', 'I14', 'Construção de Confiança',
   'Age com consistência, transparência e integridade nas relações interpessoais.', 3, true),
  ('20000000-0000-0000-0000-000000000015', 'I15', 'Influência Positiva',
   'Gera impacto no comportamento e motivação dos outros de forma ética e genuína.', 3, true),

  -- Pilar 4 — Orientação a Resultados
  ('20000000-0000-0000-0000-000000000016', 'I16', 'Planejamento e Organização',
   'Estrutura tarefas e recursos de forma eficiente para atingir os objetivos definidos.', 4, true),
  ('20000000-0000-0000-0000-000000000017', 'I17', 'Foco e Priorização',
   'Identifica o que é essencial e direciona o esforço para o que gera maior impacto.', 4, true),
  ('20000000-0000-0000-0000-000000000018', 'I18', 'Gestão do Tempo',
   'Utiliza o tempo com intencionalidade e eficiência, respeitando prazos e compromissos.', 4, true),
  ('20000000-0000-0000-0000-000000000019', 'I19', 'Qualidade nas Entregas',
   'Mantém padrão elevado de qualidade mesmo sob pressão e com recursos limitados.', 4, true),
  ('20000000-0000-0000-0000-000000000020', 'I20', 'Resiliência sob Pressão',
   'Mantém desempenho e equilíbrio diante de adversidades, prazos e frustrações.', 4, true),

  -- Pilar 5 — Liderança
  ('20000000-0000-0000-0000-000000000021', 'I21', 'Visão Estratégica',
   'Compreende o cenário amplo e conecta as ações cotidianas ao propósito maior da organização.', 5, true),
  ('20000000-0000-0000-0000-000000000022', 'I22', 'Tomada de Decisão',
   'Decide com critério, agilidade e responsabilidade mesmo sob incerteza ou pressão.', 5, true),
  ('20000000-0000-0000-0000-000000000023', 'I23', 'Desenvolvimento de Pessoas',
   'Investe ativamente no crescimento e evolução dos outros ao seu redor.', 5, true),
  ('20000000-0000-0000-0000-000000000024', 'I24', 'Delegação Eficaz',
   'Distribui responsabilidades com clareza, confiança e acompanhamento adequado.', 5, true),
  ('20000000-0000-0000-0000-000000000025', 'I25', 'Inspiração e Motivação',
   'Mobiliza pessoas ao redor de um propósito com entusiasmo e coerência de comportamento.', 5, true),

  -- Pilar 6 — Inovação e Adaptação
  ('20000000-0000-0000-0000-000000000026', 'I26', 'Mentalidade de Crescimento',
   'Vê desafios e erros como oportunidades de aprender e evoluir continuamente.', 6, true),
  ('20000000-0000-0000-0000-000000000027', 'I27', 'Criatividade Prática',
   'Gera soluções originais e aplicáveis para problemas reais do cotidiano.', 6, true),
  ('20000000-0000-0000-0000-000000000028', 'I28', 'Tolerância à Ambiguidade',
   'Opera com eficiência mesmo em cenários incertos, mal definidos ou em constante mudança.', 6, true),
  ('20000000-0000-0000-0000-000000000029', 'I29', 'Abertura ao Feedback',
   'Recebe perspectivas externas com receptividade e as utiliza para crescer.', 6, true),
  ('20000000-0000-0000-0000-000000000030', 'I30', 'Adaptabilidade',
   'Ajusta comportamentos e estratégias frente a mudanças com agilidade e sem resistência.', 6, true),

  -- Pilar 7 — Desenvolvimento Contínuo
  ('20000000-0000-0000-0000-000000000031', 'I31', 'Autocrítica Construtiva',
   'Avalia seus próprios resultados com honestidade e sem autossabotagem ou excesso de autocrítica.', 7, true),
  ('20000000-0000-0000-0000-000000000032', 'I32', 'Busca por Aprendizado',
   'Procura ativamente novos conhecimentos, habilidades e perspectivas de forma contínua.', 7, true),
  ('20000000-0000-0000-0000-000000000033', 'I33', 'Aplicação do Conhecimento',
   'Transforma o que aprende em ação prática e resultados concretos no dia a dia.', 7, true),
  ('20000000-0000-0000-0000-000000000034', 'I34', 'Compartilhamento de Conhecimento',
   'Multiplica o que sabe, contribuindo ativamente para o crescimento dos outros.', 7, true),
  ('20000000-0000-0000-0000-000000000035', 'I35', 'Visão de Futuro',
   'Pensa no longo prazo e age hoje para construir uma trajetória profissional sustentável.', 7, true)

on conflict (id) do update set
  code          = excluded.code,
  name          = excluded.name,
  description   = excluded.description,
  pillar_number = excluded.pillar_number,
  active        = excluded.active;

-- ============================================================
-- SITUAÇÕES (28 — 4 por pilar)
-- ============================================================

insert into public.questions (id, order_index, pillar_number, title, dimension, active) values

  -- ── PILAR 1 — AUTOGESTÃO (Q01–Q04) ──────────────────────

  ('30000000-0000-0000-0000-000000000001', 1, 1,
   'Você cometeu um erro em uma entrega importante que causou retrabalho para o seu time. Como você reage?',
   'Responsabilidade Pessoal', true),

  ('30000000-0000-0000-0000-000000000002', 2, 1,
   'Em uma reunião, um colega faz uma crítica direta e incisiva ao seu trabalho na frente de todos. Como você age?',
   'Gestão Emocional', true),

  ('30000000-0000-0000-0000-000000000003', 3, 1,
   'Você tem um projeto estratégico de longo prazo sem prazo fixo e com pouca visibilidade do gestor. Como você garante o avanço?',
   'Disciplina e Consistência', true),

  ('30000000-0000-0000-0000-000000000004', 4, 1,
   'Você é convidado para representar seu time em uma apresentação para uma diretoria que você não conhece. Como você se prepara?',
   'Autoconfiança', true),

  -- ── PILAR 2 — COMUNICAÇÃO (Q05–Q08) ──────────────────────

  ('30000000-0000-0000-0000-000000000005', 5, 2,
   'Você precisa comunicar uma mudança de processo complexa para um time com perfis muito diferentes — técnicos e operacionais. Como você age?',
   'Clareza na Expressão', true),

  ('30000000-0000-0000-0000-000000000006', 6, 2,
   'Em uma conversa com um colaborador que está passando por dificuldades, você percebe que ele está omitindo parte do problema. O que você faz?',
   'Escuta Ativa', true),

  ('30000000-0000-0000-0000-000000000007', 7, 2,
   'Você discorda de uma decisão do seu gestor e acredita que ela vai impactar negativamente o resultado da área. O que você faz?',
   'Assertividade', true),

  ('30000000-0000-0000-0000-000000000008', 8, 2,
   'Você precisa dar um feedback difícil a um colega sobre um comportamento recorrente que está afetando a dinâmica do time. Como você age?',
   'Feedback Construtivo', true),

  -- ── PILAR 3 — RELACIONAMENTO (Q09–Q12) ───────────────────

  ('30000000-0000-0000-0000-000000000009', 9, 3,
   'Seu time está sobrecarregado e você concluiu todas as suas entregas antes do prazo. O que você faz com o tempo disponível?',
   'Colaboração', true),

  ('30000000-0000-0000-0000-000000000010', 10, 3,
   'Dois membros do seu time estão em conflito aberto e isso está afetando o ambiente e as entregas. Como você age?',
   'Gestão de Conflitos', true),

  ('30000000-0000-0000-0000-000000000011', 11, 3,
   'Um colega está passando por um momento pessoal muito difícil e sua performance caiu visivelmente. Como você age?',
   'Empatia', true),

  ('30000000-0000-0000-0000-000000000012', 12, 3,
   'Um novo membro entra no time e demonstra insegurança para tomar iniciativas ou compartilhar ideias. Como você age?',
   'Construção de Confiança', true),

  -- ── PILAR 4 — ORIENTAÇÃO A RESULTADOS (Q13–Q16) ──────────

  ('30000000-0000-0000-0000-000000000013', 13, 4,
   'Você assumiu a liderança de um projeto sem documentação disponível e com prazo apertado. Como você começa?',
   'Planejamento e Organização', true),

  ('30000000-0000-0000-0000-000000000014', 14, 4,
   'Você tem muito mais tarefas do que consegue entregar no dia. Como você decide o que fazer?',
   'Foco e Priorização', true),

  ('30000000-0000-0000-0000-000000000015', 15, 4,
   'Um projeto importante no qual você investiu meses de trabalho falhou e precisou ser encerrado. Como você reage?',
   'Resiliência sob Pressão', true),

  ('30000000-0000-0000-0000-000000000016', 16, 4,
   'Você está sob pressão para entregar rápido, mas percebe que a qualidade da entrega está claramente comprometida. O que faz?',
   'Qualidade nas Entregas', true),

  -- ── PILAR 5 — LIDERANÇA (Q17–Q20) ────────────────────────

  ('30000000-0000-0000-0000-000000000017', 17, 5,
   'Você precisa tomar uma decisão importante com informações incompletas e sem tempo para consultar seu gestor. O que faz?',
   'Tomada de Decisão', true),

  ('30000000-0000-0000-0000-000000000018', 18, 5,
   'Você precisa delegar uma tarefa estratégica para um colaborador que ainda não a realizou antes. Como você conduz esse processo?',
   'Delegação Eficaz', true),

  ('30000000-0000-0000-0000-000000000019', 19, 5,
   'Um colaborador do seu time tem potencial claro, mas ainda não entrega de forma consistente e previsível. Como você age?',
   'Desenvolvimento de Pessoas', true),

  ('30000000-0000-0000-0000-000000000020', 20, 5,
   'Seu time está visivelmente desmotivado após um período de mudanças e incertezas. Como você age como líder?',
   'Inspiração e Motivação', true),

  -- ── PILAR 6 — INOVAÇÃO E ADAPTAÇÃO (Q21–Q24) ─────────────

  ('30000000-0000-0000-0000-000000000021', 21, 6,
   'A empresa anuncia uma reestruturação significativa que impacta diretamente a sua área e o seu papel. Como você reage?',
   'Adaptabilidade', true),

  ('30000000-0000-0000-0000-000000000022', 22, 6,
   'Você identifica um problema recorrente no processo do seu time que ninguém ainda endereçou de forma definitiva. O que você faz?',
   'Criatividade Prática', true),

  ('30000000-0000-0000-0000-000000000023', 23, 6,
   'Você recebe uma nova responsabilidade importante sem descrição clara do que se espera de você nesse papel. Como você age?',
   'Tolerância à Ambiguidade', true),

  ('30000000-0000-0000-0000-000000000024', 24, 6,
   'Você é alocado em um projeto estratégico fora da sua área de especialidade. Como você reage?',
   'Mentalidade de Crescimento', true),

  -- ── PILAR 7 — DESENVOLVIMENTO CONTÍNUO (Q25–Q28) ─────────

  ('30000000-0000-0000-0000-000000000025', 25, 7,
   'Você percebe que sua área está evoluindo rapidamente e seu conhecimento atual está ficando defasado. O que faz?',
   'Busca por Aprendizado', true),

  ('30000000-0000-0000-0000-000000000026', 26, 7,
   'Após um período de trabalho intenso, você percebe que seus resultados ficaram abaixo das suas próprias expectativas. Como você reage?',
   'Autocrítica Construtiva', true),

  ('30000000-0000-0000-0000-000000000027', 27, 7,
   'Você desenvolveu uma solução que gerou resultados concretos para um desafio recorrente do seu trabalho. O que faz?',
   'Compartilhamento de Conhecimento', true),

  ('30000000-0000-0000-0000-000000000028', 28, 7,
   'Você está em uma carreira que valoriza, mas percebe que o mercado está mudando e seu perfil pode perder relevância nos próximos anos. O que faz?',
   'Visão de Futuro', true)

on conflict (id) do update set
  order_index   = excluded.order_index,
  pillar_number = excluded.pillar_number,
  title         = excluded.title,
  dimension     = excluded.dimension,
  active        = excluded.active;

-- ============================================================
-- ALTERNATIVAS (112 — 4 por situação)
-- ID: 40000000-0000-0000-QQQQ-00000000000L
--     QQQQ = número da situação (0001–0028)
--     L    = ordem da alternativa (1–4)
-- ============================================================

insert into public.alternatives (id, question_id, order_index, letter, title, description) values

  -- ── Q01 — Responsabilidade Pessoal ───────────────────────
  ('40000000-0000-0000-0001-000000000001','30000000-0000-0000-0000-000000000001',1,'A',
   'Assumo e proponho solução',
   'Comunico o erro imediatamente ao time, peço desculpas e proponho uma solução concreta para corrigir o impacto causado.'),
  ('40000000-0000-0000-0001-000000000002','30000000-0000-0000-0000-000000000001',2,'B',
   'Corrijo em silêncio',
   'Resolvo o que precisa ser corrigido sem chamar atenção para o erro, focando em minimizar o impacto o mais rápido possível.'),
  ('40000000-0000-0000-0001-000000000003','30000000-0000-0000-0000-000000000001',3,'C',
   'Contextualizo o problema',
   'Explico os fatores que contribuíram para o erro e apresento um plano claro para que a situação não se repita.'),
  ('40000000-0000-0000-0001-000000000004','30000000-0000-0000-0000-000000000001',4,'D',
   'Reporto e peço orientação',
   'Reporto a situação ao gestor e peço orientação sobre como proceder para causar o menor impacto possível no time.'),

  -- ── Q02 — Gestão Emocional ────────────────────────────────
  ('40000000-0000-0000-0002-000000000001','30000000-0000-0000-0000-000000000002',1,'A',
   'Respondo com calma na hora',
   'Ouço a crítica, respondo com calma apresentando minha perspectiva e proponho uma conversa mais detalhada depois da reunião.'),
  ('40000000-0000-0000-0002-000000000002','30000000-0000-0000-0000-000000000002',2,'B',
   'Aguardo o momento certo',
   'Absorvo a crítica sem reagir na reunião e busco uma conversa privada com o colega depois para tratar o ponto com mais qualidade.'),
  ('40000000-0000-0000-0002-000000000003','30000000-0000-0000-0000-000000000002',3,'C',
   'Redireciono o espaço',
   'Agradeço o feedback e sugiro que o assunto seja tratado em um fórum mais adequado para não comprometer o andamento da reunião.'),
  ('40000000-0000-0000-0002-000000000004','30000000-0000-0000-0000-000000000002',4,'D',
   'Aceito e avalio depois',
   'Aceito a crítica publicamente para não criar conflito e avalio internamente se ela procede antes de qualquer reação.'),

  -- ── Q03 — Disciplina e Consistência ──────────────────────
  ('40000000-0000-0000-0003-000000000001','30000000-0000-0000-0000-000000000003',1,'A',
   'Crio meu próprio ritmo',
   'Defino marcos semanais, bloqueio tempo fixo na agenda para o projeto e monitoro meu próprio progresso com regularidade.'),
  ('40000000-0000-0000-0003-000000000002','30000000-0000-0000-0000-000000000003',2,'B',
   'Avanço nas brechas',
   'Avanço no projeto nos intervalos entre as tarefas urgentes, aproveitando os momentos de menor demanda do dia.'),
  ('40000000-0000-0000-0003-000000000003','30000000-0000-0000-0000-000000000003',3,'C',
   'Estruturo formalmente',
   'Crio um cronograma detalhado e apresento ao gestor para validação antes de começar qualquer execução.'),
  ('40000000-0000-0000-0003-000000000004','30000000-0000-0000-0000-000000000003',4,'D',
   'Envolvo o time',
   'Compartilho o projeto com colegas e crio rituais coletivos de acompanhamento para manter o foco do grupo.'),

  -- ── Q04 — Autoconfiança ───────────────────────────────────
  ('40000000-0000-0000-0004-000000000001','30000000-0000-0000-0000-000000000004',1,'A',
   'Preparo com profundidade',
   'Estudo o tema e o público a fundo, preparo uma apresentação clara e estruturada e pratico antes de forma disciplinada.'),
  ('40000000-0000-0000-0004-000000000002','30000000-0000-0000-0000-000000000004',2,'B',
   'Foco no que domino',
   'Me concentro nos pontos que domino com mais segurança e me preparo para responder a perguntas de forma direta e objetiva.'),
  ('40000000-0000-0000-0004-000000000003','30000000-0000-0000-0000-000000000004',3,'C',
   'Busco parceria',
   'Solicito apoio de um colega mais experiente para realizarmos a apresentação juntos e dividirmos os pontos entre nós.'),
  ('40000000-0000-0000-0004-000000000004','30000000-0000-0000-0000-000000000004',4,'D',
   'Ensaio com feedback',
   'Preparo o material e ensaio com pessoas de confiança para receber críticas e ajustar antes da apresentação real.'),

  -- ── Q05 — Clareza na Expressão ────────────────────────────
  ('40000000-0000-0000-0005-000000000001','30000000-0000-0000-0000-000000000005',1,'A',
   'Adapto para todos os perfis',
   'Preparo uma comunicação estruturada com linguagem acessível e exemplos práticos que funcionem para todos os perfis do time.'),
  ('40000000-0000-0000-0005-000000000002','30000000-0000-0000-0000-000000000005',2,'B',
   'Segmento a comunicação',
   'Explico tecnicamente para o time técnico e simplifico para o time operacional em momentos ou formatos separados.'),
  ('40000000-0000-0000-0005-000000000003','30000000-0000-0000-0000-000000000005',3,'C',
   'Documento e disponibilizo',
   'Envio um documento completo com todos os detalhes e me coloco à disposição para tirar dúvidas individualmente.'),
  ('40000000-0000-0000-0005-000000000004','30000000-0000-0000-0000-000000000005',4,'D',
   'Comunico ao vivo',
   'Reúno o time, faço a explicação oral em uma única sessão coletiva e abro para perguntas em tempo real.'),

  -- ── Q06 — Escuta Ativa ────────────────────────────────────
  ('40000000-0000-0000-0006-000000000001','30000000-0000-0000-0000-000000000006',1,'A',
   'Aprofundo com perguntas',
   'Faço perguntas abertas e específicas para ajudá-lo a explorar o cenário completo antes de sugerir qualquer solução.'),
  ('40000000-0000-0000-0006-000000000002','30000000-0000-0000-0000-000000000006',2,'B',
   'Reflito e confirmo',
   'Ouço atentamente sem interromper e ao final resumo o que entendi, perguntando se capturei tudo corretamente.'),
  ('40000000-0000-0000-0006-000000000003','30000000-0000-0000-0000-000000000006',3,'C',
   'Dou espaço total',
   'Fico em silêncio e deixo o colaborador falar até o fim, sinalizando minha presença apenas com linguagem não-verbal.'),
  ('40000000-0000-0000-0006-000000000004','30000000-0000-0000-0000-000000000006',4,'D',
   'Ofereço minha leitura',
   'Compartilho minha percepção da situação e pergunto se faz sentido para ele como ponto de partida para a conversa.'),

  -- ── Q07 — Assertividade ───────────────────────────────────
  ('40000000-0000-0000-0007-000000000001','30000000-0000-0000-0000-000000000007',1,'A',
   'Me posiciono com dados',
   'Solicito uma conversa, apresento minha perspectiva com argumentos objetivos e dados concretos, e ouço a resposta do gestor.'),
  ('40000000-0000-0000-0007-000000000002','30000000-0000-0000-0000-000000000007',2,'B',
   'Registro formalmente',
   'Manifesto minha discordância por escrito e sigo com a execução, respeitando a decisão da liderança.'),
  ('40000000-0000-0000-0007-000000000003','30000000-0000-0000-0000-000000000007',3,'C',
   'Busco entendimento antes',
   'Peço ao gestor uma conversa informal para entender melhor o raciocínio por trás da decisão antes de me posicionar.'),
  ('40000000-0000-0000-0007-000000000004','30000000-0000-0000-0000-000000000007',4,'D',
   'Aceito e mitigo',
   'Aceito a decisão e direciono minha energia para minimizar os possíveis impactos negativos durante a execução.'),

  -- ── Q08 — Feedback Construtivo ────────────────────────────
  ('40000000-0000-0000-0008-000000000001','30000000-0000-0000-0000-000000000008',1,'A',
   'Feedback direto e privado',
   'Escolho um momento privado, sou específico sobre o comportamento e seu impacto, e proponho mudanças concretas.'),
  ('40000000-0000-0000-0008-000000000002','30000000-0000-0000-0000-000000000008',2,'B',
   'Abordagem coletiva',
   'Levanto o tema de forma geral em uma reunião de time sem expor o colega diretamente.'),
  ('40000000-0000-0000-0008-000000000003','30000000-0000-0000-0000-000000000008',3,'C',
   'Solicito mediação',
   'Peço ao gestor para mediar a conversa e garantir que o feedback seja dado da forma mais construtiva possível.'),
  ('40000000-0000-0000-0008-000000000004','30000000-0000-0000-0000-000000000008',4,'D',
   'Conversa indireta',
   'Abordo o tema de forma indireta em uma conversa informal, tentando sensibilizar o colega sem criar desconforto.'),

  -- ── Q09 — Colaboração ─────────────────────────────────────
  ('40000000-0000-0000-0009-000000000001','30000000-0000-0000-0000-000000000009',1,'A',
   'Me ofereço ativamente',
   'Identifico onde posso contribuir mais, ofereço ajuda diretamente aos colegas e me engajo nos projetos deles.'),
  ('40000000-0000-0000-0009-000000000002','30000000-0000-0000-0000-000000000009',2,'B',
   'Sinalizo disponibilidade',
   'Informo ao gestor que estou com capacidade disponível e aguardo redirecionamento formal para onde sou mais útil.'),
  ('40000000-0000-0000-0009-000000000003','30000000-0000-0000-0000-000000000009',3,'C',
   'Avanço nas minhas metas',
   'Aproveito o tempo para antecipar minhas próximas entregas e fortalecer meu próprio planejamento futuro.'),
  ('40000000-0000-0000-0009-000000000004','30000000-0000-0000-0000-000000000009',4,'D',
   'Pergunto diretamente',
   'Abordo os colegas individualmente, pergunto se precisam de suporte e de que forma específica posso ajudar.'),

  -- ── Q10 — Gestão de Conflitos ─────────────────────────────
  ('40000000-0000-0000-0010-000000000001','30000000-0000-0000-0000-000000000010',1,'A',
   'Ouço separado e medío juntos',
   'Converso individualmente com cada um para entender cada perspectiva e depois facilito uma conversa conjunta e estruturada.'),
  ('40000000-0000-0000-0010-000000000002','30000000-0000-0000-0000-000000000010',2,'B',
   'Enfrento diretamente',
   'Reúno os dois e trato o problema de forma direta, estabelecendo regras claras de convivência e expectativas para o time.'),
  ('40000000-0000-0000-0010-000000000003','30000000-0000-0000-0000-000000000010',3,'C',
   'Escalo o caso',
   'Levo a situação ao gestor responsável para que ele tome a decisão de como resolver o conflito.'),
  ('40000000-0000-0000-0010-000000000004','30000000-0000-0000-0000-000000000010',4,'D',
   'Separo as interações',
   'Reorganizo as responsabilidades para que os dois não precisem interagir diretamente até que o conflito se resolva.'),

  -- ── Q11 — Empatia ─────────────────────────────────────────
  ('40000000-0000-0000-0011-000000000001','30000000-0000-0000-0000-000000000011',1,'A',
   'Ofereço apoio genuíno',
   'Abordo o colega com cuidado, ofereço suporte real sem pressionar por resultados e verifico o que ele precisa nesse momento.'),
  ('40000000-0000-0000-0011-000000000002','30000000-0000-0000-0000-000000000011',2,'B',
   'Combino um plano juntos',
   'Converso com ele sobre o impacto no trabalho e construímos juntos um plano realista e respeitoso para o período.'),
  ('40000000-0000-0000-0011-000000000003','30000000-0000-0000-0000-000000000011',3,'C',
   'Aciono o gestor',
   'Comunico ao gestor a situação para que ele possa dar o suporte institucional necessário ao colaborador.'),
  ('40000000-0000-0000-0011-000000000004','30000000-0000-0000-0000-000000000011',4,'D',
   'Absorvo e protejo',
   'Assumo parte das responsabilidades dele temporariamente sem comentar, para preservar seu espaço de recuperação.'),

  -- ── Q12 — Construção de Confiança ─────────────────────────
  ('40000000-0000-0000-0012-000000000001','30000000-0000-0000-0000-000000000012',1,'A',
   'Crio oportunidades ativamente',
   'Busco criar espaços para que ele contribua, demonstro confiança no seu potencial e ofereço suporte direto e constante.'),
  ('40000000-0000-0000-0012-000000000002','30000000-0000-0000-0000-000000000012',2,'B',
   'Observo antes de agir',
   'Acompanho como ele se sai nas primeiras entregas antes de envolvê-lo em iniciativas de maior visibilidade.'),
  ('40000000-0000-0000-0012-000000000003','30000000-0000-0000-0000-000000000012',3,'C',
   'Apresento as expectativas',
   'Apresento o novo membro ao time e esclareço claramente as expectativas sobre seu papel e sua autonomia.'),
  ('40000000-0000-0000-0012-000000000004','30000000-0000-0000-0000-000000000012',4,'D',
   'Convido à observação',
   'Incluo-o como observador em projetos em andamento para que absorva a cultura e o ritmo antes de assumir iniciativas.'),

  -- ── Q13 — Planejamento e Organização ─────────────────────
  ('40000000-0000-0000-0013-000000000001','30000000-0000-0000-0000-000000000013',1,'A',
   'Estruturo antes de executar',
   'Levanto o histórico disponível, mapeio o escopo, estimo o esforço e crio um plano básico antes de qualquer execução.'),
  ('40000000-0000-0000-0013-000000000002','30000000-0000-0000-0000-000000000013',2,'B',
   'Executo e documento',
   'Começo pela entrega mais crítica e documento o processo conforme avanço para não perder tempo com estrutura prévia.'),
  ('40000000-0000-0000-0013-000000000003','30000000-0000-0000-0000-000000000013',3,'C',
   'Alinhos com stakeholders',
   'Reúno as partes envolvidas para alinhar expectativas e definir coletivamente o que é essencial para o prazo.'),
  ('40000000-0000-0000-0013-000000000004','30000000-0000-0000-0000-000000000013',4,'D',
   'Negocio o prazo',
   'Proponho uma extensão de prazo para garantir que o projeto seja estruturado de forma adequada antes de ser executado.'),

  -- ── Q14 — Foco e Priorização ──────────────────────────────
  ('40000000-0000-0000-0014-000000000001','30000000-0000-0000-0000-000000000014',1,'A',
   'Priorizo com critério',
   'Classifico por urgência e impacto, comunico o que não entregarei e ofereço alternativas para as partes afetadas.'),
  ('40000000-0000-0000-0014-000000000002','30000000-0000-0000-0000-000000000014',2,'B',
   'Sigo a ordem de chegada',
   'Começo pelo que chegou primeiro e avanço pela sequência cronológica das demandas recebidas.'),
  ('40000000-0000-0000-0014-000000000003','30000000-0000-0000-0000-000000000014',3,'C',
   'Valido com o gestor',
   'Consulto o gestor para validar as prioridades antes de executar qualquer tarefa do dia.'),
  ('40000000-0000-0000-0014-000000000004','30000000-0000-0000-0000-000000000014',4,'D',
   'Foco no que concluo',
   'Priorizo o que consigo finalizar no dia para não deixar nada pela metade e manter ritmo de entrega.'),

  -- ── Q15 — Resiliência sob Pressão ────────────────────────
  ('40000000-0000-0000-0015-000000000001','30000000-0000-0000-0000-000000000015',1,'A',
   'Documento e proponho',
   'Registro os aprendizados, analiso o que deu errado e apresento proativamente uma proposta de próximo passo.'),
  ('40000000-0000-0000-0015-000000000002','30000000-0000-0000-0000-000000000015',2,'B',
   'Processo e recomeço',
   'Dou tempo para processar o impacto, recupero o foco e recomeço com base nos aprendizados do processo.'),
  ('40000000-0000-0000-0015-000000000003','30000000-0000-0000-0000-000000000015',3,'C',
   'Faço retrospecto coletivo',
   'Reúno o time para uma retrospectiva e construímos juntos o que faríamos de diferente na próxima vez.'),
  ('40000000-0000-0000-0015-000000000004','30000000-0000-0000-0000-000000000015',4,'D',
   'Solicito avaliação externa',
   'Peço ao gestor uma avaliação externa do que aconteceu antes de tomar qualquer ação ou posicionamento público.'),

  -- ── Q16 — Qualidade nas Entregas ──────────────────────────
  ('40000000-0000-0000-0016-000000000001','30000000-0000-0000-0000-000000000016',1,'A',
   'Negocio o trade-off',
   'Comunico o dilema ao stakeholder e negocio o escopo ou o prazo para conseguir manter a qualidade da entrega.'),
  ('40000000-0000-0000-0016-000000000002','30000000-0000-0000-0000-000000000016',2,'B',
   'Entrego e sinalizo',
   'Entrego o que está pronto e registro claramente os pontos que precisam de refinamento em um segundo momento.'),
  ('40000000-0000-0000-0016-000000000003','30000000-0000-0000-0000-000000000016',3,'C',
   'Otimizo no tempo disponível',
   'Reviso o que é possível ajustar dentro do prazo e entrego o melhor resultado alcançável com os recursos atuais.'),
  ('40000000-0000-0000-0016-000000000004','30000000-0000-0000-0000-000000000016',4,'D',
   'Peço reforço',
   'Solicito apoio de outro membro do time para ganhar qualidade e velocidade ao mesmo tempo dentro do prazo.'),

  -- ── Q17 — Tomada de Decisão ───────────────────────────────
  ('40000000-0000-0000-0017-000000000001','30000000-0000-0000-0000-000000000017',1,'A',
   'Decido com o que tenho',
   'Avalio os dados disponíveis, tomo a decisão mais fundamentada possível e comunico com transparência os critérios usados.'),
  ('40000000-0000-0000-0017-000000000002','30000000-0000-0000-0000-000000000017',2,'B',
   'Busco mais dados rapidamente',
   'Coleto o máximo de informações possível em tempo reduzido antes de me posicionar formalmente.'),
  ('40000000-0000-0000-0017-000000000003','30000000-0000-0000-0000-000000000017',3,'C',
   'Consulto alguém de confiança',
   'Peço uma segunda opinião rápida de um colega experiente e decido com esse suporte adicional.'),
  ('40000000-0000-0000-0017-000000000004','30000000-0000-0000-0000-000000000017',4,'D',
   'Escolho o caminho mais seguro',
   'Opto pela alternativa mais conservadora para minimizar o risco e ajusto conforme surgem mais informações.'),

  -- ── Q18 — Delegação Eficaz ────────────────────────────────
  ('40000000-0000-0000-0018-000000000001','30000000-0000-0000-0000-000000000018',1,'A',
   'Explico, defino e acompanho',
   'Explico o objetivo e as expectativas, defino checkpoints periódicos e deixo espaço para ele executar com autonomia.'),
  ('40000000-0000-0000-0018-000000000002','30000000-0000-0000-0000-000000000018',2,'B',
   'Detalho o como',
   'Descrevo exatamente como quero que a tarefa seja feita e acompanho de perto cada etapa da execução.'),
  ('40000000-0000-0000-0018-000000000003','30000000-0000-0000-0000-000000000018',3,'C',
   'Delego com abertura total',
   'Explico o que precisa ser feito, digo que estou disponível para dúvidas e não imponho nenhum monitoramento.'),
  ('40000000-0000-0000-0018-000000000004','30000000-0000-0000-0000-000000000018',4,'D',
   'Fracionando a entrega',
   'Divido a tarefa em partes menores, entrego uma de cada vez e avalio o resultado antes de passar a próxima etapa.'),

  -- ── Q19 — Desenvolvimento de Pessoas ─────────────────────
  ('40000000-0000-0000-0019-000000000001','30000000-0000-0000-0000-000000000019',1,'A',
   'Acompanho de perto',
   'Ofereço feedbacks frequentes, co-crio um plano de desenvolvimento com ele e monitoro a evolução regularmente.'),
  ('40000000-0000-0000-0019-000000000002','30000000-0000-0000-0000-000000000019',2,'B',
   'Ofereço desafios progressivos',
   'Crio desafios graduais para que ele desenvolva confiança e consistência através da prática real e do erro seguro.'),
  ('40000000-0000-0000-0019-000000000003','30000000-0000-0000-0000-000000000019',3,'C',
   'Removo os obstáculos',
   'Identifico o que está travando a entrega e trabalho para eliminar esses bloqueios antes de cobrar mais resultados.'),
  ('40000000-0000-0000-0019-000000000004','30000000-0000-0000-0000-000000000019',4,'D',
   'Tenho a conversa direta',
   'Tenho uma conversa franca sobre expectativas e alinhamos juntos o que precisa mudar e em que prazo.'),

  -- ── Q20 — Inspiração e Motivação ─────────────────────────
  ('40000000-0000-0000-0020-000000000001','30000000-0000-0000-0000-000000000020',1,'A',
   'Reconheço e redireciono',
   'Reúno o time, reconheço o esforço de todos, reforço o propósito do trabalho e apresento o caminho à frente com clareza.'),
  ('40000000-0000-0000-0020-000000000002','30000000-0000-0000-0000-000000000020',2,'B',
   'Ouço individualmente',
   'Tenho conversas individuais com cada membro para entender a raiz da desmotivação antes de tomar qualquer ação coletiva.'),
  ('40000000-0000-0000-0020-000000000003','30000000-0000-0000-0000-000000000020',3,'C',
   'Crio um momento de celebração',
   'Proponho uma pausa estratégica para celebrar as conquistas do time e reconectar o grupo ao propósito do trabalho.'),
  ('40000000-0000-0000-0020-000000000004','30000000-0000-0000-0000-000000000020',4,'D',
   'Estabeleço metas de curto prazo',
   'Crio desafios e metas de curto prazo para resgatar o senso de progresso e a sensação concreta de conquista.'),

  -- ── Q21 — Adaptabilidade ──────────────────────────────────
  ('40000000-0000-0000-0021-000000000001','30000000-0000-0000-0000-000000000021',1,'A',
   'Me adapto proativamente',
   'Busco entender o racional da mudança, identifico as oportunidades nela e me reposiciono antes que me peçam.'),
  ('40000000-0000-0000-0021-000000000002','30000000-0000-0000-0000-000000000021',2,'B',
   'Aguardo mais clareza',
   'Espero por mais informações antes de me posicionar para ter clareza real sobre o impacto no meu trabalho.'),
  ('40000000-0000-0000-0021-000000000003','30000000-0000-0000-0000-000000000021',3,'C',
   'Compartilho e proponho',
   'Comunico minhas preocupações ao gestor e proponho maneiras concretas de facilitar a transição para a área.'),
  ('40000000-0000-0000-0021-000000000004','30000000-0000-0000-0000-000000000021',4,'D',
   'Foco no que controlo',
   'Concentro esforço no que está sob meu controle e adapto minha rotina ao que já foi oficialmente comunicado.'),

  -- ── Q22 — Criatividade Prática ────────────────────────────
  ('40000000-0000-0000-0022-000000000001','30000000-0000-0000-0000-000000000022',1,'A',
   'Proponho uma solução',
   'Mapeio o problema, desenvolvo uma proposta de solução e apresento ao gestor com dados e argumentos concretos.'),
  ('40000000-0000-0000-0022-000000000002','30000000-0000-0000-0000-000000000022',2,'B',
   'Testo em pequena escala',
   'Desenvolvo e testo uma solução piloto antes de propor formalmente para o time e a liderança.'),
  ('40000000-0000-0000-0022-000000000003','30000000-0000-0000-0000-000000000022',3,'C',
   'Facilito uma sessão coletiva',
   'Levanto o problema em uma reunião de time e conduzo uma sessão de ideação com todos os envolvidos.'),
  ('40000000-0000-0000-0022-000000000004','30000000-0000-0000-0000-000000000022',4,'D',
   'Pesquiso referências',
   'Investigo como outras equipes ou empresas resolvem o mesmo tipo de problema e trago as referências para o time.'),

  -- ── Q23 — Tolerância à Ambiguidade ───────────────────────
  ('40000000-0000-0000-0023-000000000001','30000000-0000-0000-0000-000000000023',1,'A',
   'Defino e começo',
   'Clarifica os objetivos com o gestor, estruturo meu próprio entendimento do papel e começo a operar com autonomia.'),
  ('40000000-0000-0000-0023-000000000002','30000000-0000-0000-0000-000000000023',2,'B',
   'Observo referências',
   'Acompanho como colegas com responsabilidades similares atuam e uso isso como referência para calibrar meu papel.'),
  ('40000000-0000-0000-0023-000000000003','30000000-0000-0000-0000-000000000023',3,'C',
   'Valido antes de executar',
   'Documento minha interpretação do papel e compartilho com o gestor para validar formalmente antes de qualquer ação.'),
  ('40000000-0000-0000-0023-000000000004','30000000-0000-0000-0000-000000000023',4,'D',
   'Avanço e ajusto',
   'Começo a atuar com o que faz sentido para o contexto e vou calibrando meu papel conforme recebo sinais e feedbacks.'),

  -- ── Q24 — Mentalidade de Crescimento ─────────────────────
  ('40000000-0000-0000-0024-000000000001','30000000-0000-0000-0000-000000000024',1,'A',
   'Encaro como oportunidade',
   'Vejo como oportunidade de crescimento, me dedico a aprender o necessário e assumo o compromisso de entregar.'),
  ('40000000-0000-0000-0024-000000000002','30000000-0000-0000-0000-000000000024',2,'B',
   'Aprendo com especialistas',
   'Aceito o desafio e busco ativamente um colega especialista para aprender enquanto contribuo com o que sei.'),
  ('40000000-0000-0000-0024-000000000003','30000000-0000-0000-0000-000000000024',3,'C',
   'Alinho as lacunas com o gestor',
   'Tenho uma conversa com o gestor sobre minhas limitações e juntos definimos como cobrir as lacunas do projeto.'),
  ('40000000-0000-0000-0024-000000000004','30000000-0000-0000-0000-000000000024',4,'D',
   'Contribuo no que sei',
   'Foco no que posso contribuir com segurança dentro do projeto e peço apoio para o que está fora do meu domínio.'),

  -- ── Q25 — Busca por Aprendizado ───────────────────────────
  ('40000000-0000-0000-0025-000000000001','30000000-0000-0000-0000-000000000025',1,'A',
   'Crio um plano de atualização',
   'Defino um plano pessoal de desenvolvimento com recursos específicos, metas claras e tempo dedicado na agenda.'),
  ('40000000-0000-0000-0025-000000000002','30000000-0000-0000-0000-000000000025',2,'B',
   'Busco apoio institucional',
   'Converso com o gestor sobre as necessidades de atualização e busco suporte formal da empresa para me desenvolver.'),
  ('40000000-0000-0000-0025-000000000003','30000000-0000-0000-0000-000000000025',3,'C',
   'Aprendo aplicando',
   'Acompanho referências da área, aplico o conhecimento no trabalho no dia a dia e avalio o que gera impacto real.'),
  ('40000000-0000-0000-0025-000000000004','30000000-0000-0000-0000-000000000025',4,'D',
   'Aprendo com os colegas',
   'Identifico colegas mais atualizados e cria oportunidades de aprendizado através da troca e da mentoria interna.'),

  -- ── Q26 — Autocrítica Construtiva ─────────────────────────
  ('40000000-0000-0000-0026-000000000001','30000000-0000-0000-0000-000000000026',1,'A',
   'Analiso com honestidade',
   'Faço uma análise honesta do que contribuiu para isso e defino ações concretas e mensuráveis de melhoria.'),
  ('40000000-0000-0000-0026-000000000002','30000000-0000-0000-0000-000000000026',2,'B',
   'Alinho com o gestor',
   'Converso com o gestor para entender se minha percepção está correta e calibrar expectativas para o próximo período.'),
  ('40000000-0000-0000-0026-000000000003','30000000-0000-0000-0000-000000000026',3,'C',
   'Foco nos pontos críticos',
   'Identifico um ou dois pontos prioritários de melhoria e concentro esforço neles antes de ampliar o escopo.'),
  ('40000000-0000-0000-0026-000000000004','30000000-0000-0000-0000-000000000026',4,'D',
   'Busco perspectiva externa',
   'Peço feedback de pessoas próximas e de confiança para ter uma leitura externa antes de tirar conclusões.'),

  -- ── Q27 — Compartilhamento de Conhecimento ────────────────
  ('40000000-0000-0000-0027-000000000001','30000000-0000-0000-0000-000000000027',1,'A',
   'Documento e proponho o padrão',
   'Documento o processo de forma clara, compartilho com o time e proponho que seja adotado como prática padrão.'),
  ('40000000-0000-0000-0027-000000000002','30000000-0000-0000-0000-000000000027',2,'B',
   'Apresento e co-evoluo',
   'Apresento a solução em uma reunião de time e convido os colegas a contribuírem com melhorias e adaptações.'),
  ('40000000-0000-0000-0027-000000000003','30000000-0000-0000-0000-000000000027',3,'C',
   'Compartilho diretamente',
   'Compartilho a solução com quem mais se beneficiaria dela de forma direta, sem forçar adoção em massa.'),
  ('40000000-0000-0000-0027-000000000004','30000000-0000-0000-0000-000000000027',4,'D',
   'Disponibilizo para quem quiser',
   'Registro a solução internamente e deixo disponível para quem tiver interesse, sem promover ativamente.'),

  -- ── Q28 — Visão de Futuro ─────────────────────────────────
  ('40000000-0000-0000-0028-000000000001','30000000-0000-0000-0000-000000000028',1,'A',
   'Planejo o futuro',
   'Defino uma estratégia de desenvolvimento de médio e longo prazo alinhada com a direção para onde o mercado caminha.'),
  ('40000000-0000-0000-0028-000000000002','30000000-0000-0000-0000-000000000028',2,'B',
   'Evoluo gradualmente',
   'Mantenho o foco no presente, mas começo a explorar novas habilidades aos poucos, sem grandes rupturas.'),
  ('40000000-0000-0000-0028-000000000003','30000000-0000-0000-0000-000000000028',3,'C',
   'Busco orientação de referências',
   'Converso com referências da área para entender as tendências e como me posicionar de forma estratégica.'),
  ('40000000-0000-0000-0028-000000000004','30000000-0000-0000-0000-000000000028',4,'D',
   'Avalio uma transição',
   'Considero seriamente se é o momento de uma mudança mais significativa de carreira ou área de atuação.')

on conflict (id) do update set
  question_id = excluded.question_id,
  order_index = excluded.order_index,
  letter      = excluded.letter,
  title       = excluded.title,
  description = excluded.description;

commit;
