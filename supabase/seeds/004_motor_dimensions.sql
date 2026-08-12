-- ============================================================
-- EVOLUA — Seed do Motor de Interpretação — Dimensões Complementares
-- Sprint 09 — Versão 1.0
--
-- Popula as CATEGORIAS das quatro dimensões (estruturais, definidas
-- na metodologia). Os VÍNCULOS alternativa→atributo permanecem vazios,
-- aguardando o mapeamento oficial.
--
-- Nenhum vínculo é gerado ou deduzido automaticamente.
-- Idempotente: INSERT ... ON CONFLICT (id) DO UPDATE.
-- ============================================================

begin;

-- ------------------------------------------------------------
-- DISC — como a pessoa age
-- IDs: 50000000-0000-0000-0000-00000000000X
-- ------------------------------------------------------------
insert into public.disc_profiles (id, code, name, description, active) values
  ('50000000-0000-0000-0000-000000000001', 'D', 'Dominância',
   'Foco em resultados, decisão e controle. Direto, assertivo e orientado à ação.', true),
  ('50000000-0000-0000-0000-000000000002', 'I', 'Influência',
   'Foco em pessoas e persuasão. Comunicativo, entusiasta e sociável.', true),
  ('50000000-0000-0000-0000-000000000003', 'S', 'Estabilidade',
   'Foco em cooperação e constância. Paciente, confiável e conciliador.', true),
  ('50000000-0000-0000-0000-000000000004', 'C', 'Conformidade',
   'Foco em precisão, regras e qualidade. Analítico, cuidadoso e metódico.', true)
on conflict (id) do update set
  code = excluded.code, name = excluded.name,
  description = excluded.description, active = excluded.active;

-- ------------------------------------------------------------
-- TIPO PSICOLÓGICO — como a pessoa pensa
-- IDs: 60000000-0000-0000-0000-00000000000X
-- ------------------------------------------------------------
insert into public.psychological_types (id, code, name, description, active) values
  ('60000000-0000-0000-0000-000000000001', 'EST', 'Estrategista',
   'Pensa em sistemas, lógica e longo prazo. Busca eficiência e visão de conjunto.', true),
  ('60000000-0000-0000-0000-000000000002', 'IDE', 'Idealista',
   'Pensa em propósito, valores e potencial humano. Busca significado e conexão.', true),
  ('60000000-0000-0000-0000-000000000003', 'GUA', 'Guardião',
   'Pensa em ordem, responsabilidade e continuidade. Busca estrutura e confiança.', true),
  ('60000000-0000-0000-0000-000000000004', 'ART', 'Artesão',
   'Pensa no concreto, no prático e no presente. Busca ação e resultado imediato.', true)
on conflict (id) do update set
  code = excluded.code, name = excluded.name,
  description = excluded.description, active = excluded.active;

-- ------------------------------------------------------------
-- MOTIVADORES — o que move a pessoa
-- IDs: 70000000-0000-0000-0000-00000000000X
-- ------------------------------------------------------------
insert into public.motivators (id, code, name, description, active) values
  ('70000000-0000-0000-0000-000000000001', 'REC', 'Reconhecimento',
   'É movido por ser visto, valorizado e reconhecido pelo que entrega.', true),
  ('70000000-0000-0000-0000-000000000002', 'CRE', 'Crescimento',
   'É movido por evoluir, assumir mais e progredir na carreira.', true),
  ('70000000-0000-0000-0000-000000000003', 'PRO', 'Propósito',
   'É movido por contribuir para algo maior e com significado.', true),
  ('70000000-0000-0000-0000-000000000004', 'FIN', 'Recompensa Financeira',
   'É movido por ganho financeiro e retorno material.', true),
  ('70000000-0000-0000-0000-000000000005', 'AUT', 'Autonomia',
   'É movido por liberdade para decidir e trabalhar do seu jeito.', true),
  ('70000000-0000-0000-0000-000000000006', 'APR', 'Aprendizado',
   'É movido por aprender coisas novas e dominar competências.', true),
  ('70000000-0000-0000-0000-000000000007', 'SEG', 'Segurança',
   'É movido por estabilidade, previsibilidade e proteção.', true),
  ('70000000-0000-0000-0000-000000000008', 'DES', 'Desafios',
   'É movido por metas difíceis e problemas complexos para resolver.', true)
on conflict (id) do update set
  code = excluded.code, name = excluded.name,
  description = excluded.description, active = excluded.active;

-- ------------------------------------------------------------
-- ESTILO OPERACIONAL — como a pessoa trabalha
-- IDs: 80000000-0000-0000-0000-00000000000X
-- ------------------------------------------------------------
insert into public.operational_styles (id, code, name, description, active) values
  ('80000000-0000-0000-0000-000000000001', 'EXE', 'Executor',
   'Coloca em prática rapidamente. Foco em fazer acontecer.', true),
  ('80000000-0000-0000-0000-000000000002', 'PLA', 'Planejador',
   'Organiza, estrutura e antecipa antes de agir.', true),
  ('80000000-0000-0000-0000-000000000003', 'ANA', 'Analítico',
   'Investiga e avalia dados e riscos antes de decidir.', true),
  ('80000000-0000-0000-0000-000000000004', 'COL', 'Colaborativo',
   'Trabalha junto, articula pessoas e constrói em equipe.', true)
on conflict (id) do update set
  code = excluded.code, name = excluded.name,
  description = excluded.description, active = excluded.active;

commit;

-- ============================================================
-- VÍNCULOS ALTERNATIVA → ATRIBUTO (a preencher)
--
-- STATUS: AGUARDANDO MAPEAMENTO OFICIAL
--
-- Tabelas: alternative_disc, alternative_psychological_types,
--          alternative_motivators, alternative_operational_styles
--
-- REFERÊNCIA DE IDs — ALTERNATIVAS
--   Formato: 40000000-0000-0000-QQQQ-00000000000L
--   QQQQ = número da situação (0001–0028) | L = 1=A 2=B 3=C 4=D
--
-- REFERÊNCIA DE IDs — ATRIBUTOS
--   DISC:              50000000-...-0000000000(01–04)  D, I, S, C
--   Tipo Psicológico:  60000000-...-0000000000(01–04)  EST, IDE, GUA, ART
--   Motivadores:       70000000-...-0000000000(01–08)  REC, CRE, PRO, FIN, AUT, APR, SEG, DES
--   Estilo Operacional:80000000-...-0000000000(01–04)  EXE, PLA, ANA, COL
--
-- FORMATO DO INSERT (exemplo com DISC — mesmo padrão nas demais):
--   insert into public.alternative_disc
--     (alternative_id, disc_id, evidence_strength)
--   values
--     ('<ID_ALTERNATIVA>', '<ID_DISC>', <0|1|2|3>)
--   on conflict (alternative_id, disc_id) do update set
--     evidence_strength = excluded.evidence_strength;
--
-- REGRAS:
--   • evidence_strength sempre explícito (0, 1, 2 ou 3)
--   • Apenas IDs fixos — nunca texto para relacionamento
--   • Idempotente: re-execuções atualizam sem duplicar
--   • Nenhum vínculo deve ser deduzido ou interpretado
-- ============================================================

-- O mapeamento oficial das 112 alternativas será inserido aqui quando disponível.
-- Nenhum vínculo foi gerado automaticamente.
