-- ============================================================
-- EVOLUA — Estilo Operacional: cobertura das situações S29-S40
-- ============================================================
-- Estilo Operacional ("como a pessoa trabalha") já era a dimensão
-- complementar mais robusta e balanceada (46 vínculos, EXE=11/PLA=9/
-- ANA=12/COL=14), mas — como as outras 3 — não tinha NENHUM vínculo
-- para as 12 situações mais novas (S29-S40), pelo mesmo motivo:
-- quando o questionário foi expandido de 28 para 40 situações, só os
-- vínculos de indicadores foram criados para elas.
--
-- Esta migration fecha essa lacuna específica. Não toca nos 46
-- vínculos existentes de S1-28.
-- ============================================================

begin;

do $$
declare v_total int;
begin
  select count(*) into v_total from public.alternative_operational_styles;
  if v_total != 46 then
    raise exception 'Estado atual (% vínculos) diverge do esperado (46) — script não é mais válido, não prosseguir.', v_total;
  end if;
end $$;

create table if not exists public._backup_alternative_operational_styles_20260918 as
  select * from public.alternative_operational_styles;

-- S29 "tarefas travadas esperando retorno"
-- S29-A "Adianto outras entregas": foco em fazer acontecer = EXE.
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0029-000000000001', '80000000-0000-0000-0000-000000000001', 2) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;

-- S30 "gestor viaja, sem supervisão"
-- S30-A "Sigo a mesma rotina": mantém estrutura própria sem depender de supervisão = PLA.
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0030-000000000001', '80000000-0000-0000-0000-000000000002', 2) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;

-- S31 "projeto terminando"
-- S31-A "Faço revisão completa": investiga/avalia antes de considerar concluído = ANA.
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0031-000000000001', '80000000-0000-0000-0000-000000000003', 2) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;

-- S32 "erro apontado na frente do time"
-- S32-D "Agradeço e corrijo depois": ação corretiva rápida e prática = EXE.
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0032-000000000004', '80000000-0000-0000-0000-000000000001', 2) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;

-- S33 "etapa anterior vai atrasar tudo"
-- S33-A "Aviso todos os afetados": articula com o grupo = COL.
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0033-000000000001', '80000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;

-- S34 "método parou de funcionar"
-- S34-A "Mudo de abordagem rápido": ação rápida, adapta na prática = EXE.
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0034-000000000001', '80000000-0000-0000-0000-000000000001', 2) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;
-- S34-D "Busco entender antes de mudar": investiga a causa antes de agir = ANA.
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0034-000000000004', '80000000-0000-0000-0000-000000000003', 2) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;

-- S35 "conflito em reunião"
-- S35-A "Intervenho na hora": ação imediata = EXE.
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0035-000000000001', '80000000-0000-0000-0000-000000000001', 2) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;
-- S35-C "Peço que expliquem antes de decidirmos juntos": constrói a decisão em equipe = COL.
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0035-000000000003', '80000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;

-- S36 "oportunidade, líder inacessível"
-- S36-A "Decido e aproveito sozinho": decisão e ação rápidas = EXE.
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0036-000000000001', '80000000-0000-0000-0000-000000000001', 2) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;
-- S36-D "Decido de forma reversível": avalia o risco antes de comprometer = ANA.
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0036-000000000004', '80000000-0000-0000-0000-000000000003', 2) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;

-- S37 "líder insatisfeito com entrega"
-- S37-A "Ouço com calma e pergunto o que ele esperava diferente": constrói entendimento junto com o outro = COL (fraco).
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0037-000000000001', '80000000-0000-0000-0000-000000000004', 1) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;

-- S38 "lacuna de conhecimento"
-- S38-A "Já começo a estudar": ação prática imediata = EXE.
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0038-000000000001', '80000000-0000-0000-0000-000000000001', 2) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;
-- S38-C "Busco quem me oriente": articula com outra pessoa para aprender = COL.
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0038-000000000003', '80000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;

-- S39 "colega precisa mas não pediu"
-- S39-A "Ofereço ensinar mesmo sem pedido": trabalha junto, constrói com a outra pessoa = COL.
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0039-000000000001', '80000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;

-- S40 "autonomia total para organizar a semana" — as 3 primeiras alternativas mapeiam
-- limpo para 3 estilos distintos (caso ideal: cada opção discrimina um estilo diferente).
-- S40-A "Estruturo com metas claras": PLA (textual — organiza, estrutura, antecipa).
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0040-000000000001', '80000000-0000-0000-0000-000000000002', 3) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;
-- S40-B "Vou decidindo dia a dia": ação no momento, sem planejar à frente = EXE.
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0040-000000000002', '80000000-0000-0000-0000-000000000001', 2) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;
-- S40-D "Reviso e ajusto periodicamente": avalia e ajusta continuamente = ANA.
insert into public.alternative_operational_styles (alternative_id, operational_style_id, evidence_strength) values ('40000000-0000-0000-0040-000000000004', '80000000-0000-0000-0000-000000000003', 2) on conflict (alternative_id, operational_style_id) do update set evidence_strength = excluded.evidence_strength;

do $$
declare v_total int;
begin
  select count(*) into v_total from public.alternative_operational_styles;
  if v_total != 64 then
    raise exception 'Resultado final (% vínculos) diverge do esperado (64) — abortando commit.', v_total;
  end if;
  raise notice 'OK: % vínculos finais — 40/40 situações agora com cobertura de Estilo Operacional.', v_total;
end $$;

commit;
