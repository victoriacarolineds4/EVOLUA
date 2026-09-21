-- ============================================================
-- EVOLUA 40 → EVOLUA 42 — 2 situações novas para fechar I06 e I18
-- ============================================================
-- A auditoria de aceitação (AUDITORIA_ACEITACAO_PILOTO.md §4.2 e §17)
-- encontrou 18 indicadores sem cobertura suficiente para confiança
-- "alta". A migration 021 fechou 16 reaproveitando conteúdo já
-- existente. Sobraram 2 — I06 (Assunção de Erros) e I18 (Mediação de
-- Conflitos) — para os quais NÃO havia, nas 40 situações atuais,
-- nenhuma 3ª alternativa genuinamente específica sem forçar.
--
-- Esta migration resolve isso com conteúdo novo, revisado e aprovado
-- pela Victoria: 2 situações (S41, S42), 8 alternativas, cobrindo
-- deliberadamente um ÂNGULO DIFERENTE do já testado por S6/S32 (I06)
-- e S15/S35 (I18) — não uma repetição disfarçada.
--
-- Estritamente aditivo — nenhuma linha existente é alterada. O total
-- de situações passa de 40 para 42 (nada no código depende do número
-- 40: contagem de perguntas, validação de conclusão e barra de
-- progresso já são dinâmicas — count(*) from questions where
-- active=true — conferido antes de escrever esta migration).
-- ============================================================

begin;

do $$
declare v_q int; v_a int;
begin
  select count(*) into v_q from public.questions;
  select count(*) into v_a from public.alternatives;
  if v_q != 40 or v_a != 160 then
    raise exception 'Estado atual (questions=%, alternatives=%) diverge do esperado (40, 160) — script não é mais válido, não prosseguir.', v_q, v_a;
  end if;
end $$;

create table if not exists public._backup_questions_20260921 as select * from public.questions;
create table if not exists public._backup_alternatives_20260921 as select * from public.alternatives;

-- ------------------------------------------------------------
-- Situações
-- ------------------------------------------------------------
insert into public.questions (id, order_index, pillar_number, title, active) values
  ('30000000-0000-0000-0000-000000000041', 41, 2, 'Você percebe, sozinho(a), um erro que cometeu num trabalho já entregue. Ninguém mais notou ainda.', true),
  ('30000000-0000-0000-0000-000000000042', 42, 4, 'Dois colegas do seu time vêm evitando falar um com o outro há semanas, depois de um desentendimento. O clima da equipe está pesado.', true);

-- ------------------------------------------------------------
-- Alternativas
-- ------------------------------------------------------------
insert into public.alternatives (id, question_id, order_index, letter, title, description) values
  ('40000000-0000-0000-0041-000000000001', '30000000-0000-0000-0000-000000000041', 1, 'A', 'Aviso imediatamente', 'Aviso imediatamente, mesmo sem ninguém ter percebido o erro.'),
  ('40000000-0000-0000-0041-000000000002', '30000000-0000-0000-0000-000000000041', 2, 'B', 'Corrijo silenciosamente', 'Corrijo o erro sem comentar com ninguém sobre o que aconteceu.'),
  ('40000000-0000-0000-0041-000000000003', '30000000-0000-0000-0000-000000000041', 3, 'C', 'Espero ver se alguém percebe', 'Espero para ver se alguém percebe antes de fazer alguma coisa.'),
  ('40000000-0000-0000-0041-000000000004', '30000000-0000-0000-0000-000000000041', 4, 'D', 'Avalio o impacto antes', 'Avalio o impacto antes de decidir se aviso ou não.'),
  ('40000000-0000-0000-0042-000000000001', '30000000-0000-0000-0000-000000000042', 1, 'A', 'Chamo os dois numa conversa', 'Chamo os dois numa conversa para colocar o desentendimento na mesa.'),
  ('40000000-0000-0000-0042-000000000002', '30000000-0000-0000-0000-000000000042', 2, 'B', 'Falo com cada um separadamente', 'Falo com cada um separadamente antes de tentar juntar os dois.'),
  ('40000000-0000-0000-0042-000000000003', '30000000-0000-0000-0000-000000000042', 3, 'C', 'Deixo o tempo resolver', 'Deixo o tempo resolver, sem intervir diretamente.'),
  ('40000000-0000-0000-0042-000000000004', '30000000-0000-0000-0000-000000000042', 4, 'D', 'Peço para alguém mediar', 'Peço para alguém do time mediar em vez de fazer isso eu mesmo(a).');

-- ------------------------------------------------------------
-- Indicadores — I06 (Assunção de Erros) e I18 (Mediação de Conflitos),
-- o motivo desta migration existir.
-- ------------------------------------------------------------
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values
  ('40000000-0000-0000-0041-000000000001', '20000000-0000-0000-0000-000000000006', 3),
  ('40000000-0000-0000-0041-000000000002', '20000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0041-000000000003', '20000000-0000-0000-0000-000000000006', 1),
  ('40000000-0000-0000-0041-000000000004', '20000000-0000-0000-0000-000000000006', 2),
  ('40000000-0000-0000-0042-000000000001', '20000000-0000-0000-0000-000000000018', 3),
  ('40000000-0000-0000-0042-000000000002', '20000000-0000-0000-0000-000000000018', 2),
  ('40000000-0000-0000-0042-000000000003', '20000000-0000-0000-0000-000000000018', 1),
  ('40000000-0000-0000-0042-000000000004', '20000000-0000-0000-0000-000000000018', 1);

-- ------------------------------------------------------------
-- DISC — S41 (I06) fica SEM vínculo, de propósito: é integridade geral,
-- o mesmo tipo de comportamento que a v2.1 já removeu (S27-D) por não
-- discriminar D/I/S/C — qualquer perfil pode agir assim.
-- S42-A reforça I, a dimensão mais escassa.
-- ------------------------------------------------------------
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values
  ('40000000-0000-0000-0042-000000000001', '50000000-0000-0000-0000-000000000002', 2), -- A: mobilização de pessoas = I
  ('40000000-0000-0000-0042-000000000002', '50000000-0000-0000-0000-000000000003', 1); -- B: paciência/estabilidade = S

-- ------------------------------------------------------------
-- Tipo Psicológico
-- ------------------------------------------------------------
insert into public.alternative_psychological_types (alternative_id, psychological_type_id, evidence_strength) values
  ('40000000-0000-0000-0041-000000000001', '60000000-0000-0000-0000-000000000003', 1), -- S41-A: responsabilidade/continuidade = Guardião
  ('40000000-0000-0000-0042-000000000001', '60000000-0000-0000-0000-000000000002', 1); -- S42-A: conexão/potencial humano = Idealista

-- ------------------------------------------------------------
-- Estilo Operacional
-- ------------------------------------------------------------
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values
  ('40000000-0000-0000-0041-000000000004', '80000000-0000-0000-0000-000000000003', 1), -- S41-D: avalia antes de agir = Analítico
  ('40000000-0000-0000-0042-000000000001', '80000000-0000-0000-0000-000000000004', 2), -- S42-A: articula pessoas = Colaborativo
  ('40000000-0000-0000-0042-000000000002', '80000000-0000-0000-0000-000000000003', 1); -- S42-B: investiga antes de juntar os dois = Analítico

-- Motivador: nenhum vínculo — nenhuma das 8 alternativas revela com
-- especificidade o "porquê" (motivo), só o "como" (estilo/indicador).

do $$
declare v_q int; v_a int; v_ind_i06 int; v_ind_i18 int;
begin
  select count(*) into v_q from public.questions;
  select count(*) into v_a from public.alternatives;
  select count(*) into v_ind_i06 from public.alternative_indicators where indicator_id = '20000000-0000-0000-0000-000000000006';
  select count(*) into v_ind_i18 from public.alternative_indicators where indicator_id = '20000000-0000-0000-0000-000000000018';
  if v_q != 42 or v_a != 168 then
    raise exception 'Resultado final (questions=%, alternatives=%) diverge do esperado (42, 168) — abortando commit.', v_q, v_a;
  end if;
  if v_ind_i06 < 6 or v_ind_i18 < 6 then
    raise exception 'I06 ou I18 não chegaram ao total esperado de vínculos (I06=%, I18=%, esperado >=6 cada: 2 situações antigas + 4 novas) — abortando commit.', v_ind_i06, v_ind_i18;
  end if;
  raise notice 'OK: % situações, % alternativas. I06 com % vínculos, I18 com % vínculos — ambos agora com 3 situações distintas.', v_q, v_a, v_ind_i06, v_ind_i18;
end $$;

commit;
