-- ============================================================
-- EVOLUA — Tipo Psicológico: fechamento de cobertura e rebalanceamento
-- ============================================================
-- Tipo Psicológico ("como a pessoa pensa") tinha 17 vínculos cobrindo
-- 14/40 situações (35%), com GUA (Guardião) respondendo por mais da
-- metade (9 de 17) e IDE/ART com só 2 cada — mesmo padrão de
-- desbalanceamento já identificado no DISC (ver migration 016 e
-- INVESTIGACAO_DISC_ALLAN_PIRES.md): um código com teto muito maior
-- que os outros deixa o `share` normalizado sensível demais a poucas
-- respostas nos códigos escassos.
--
-- Esta migration prioriza IDE e ART (os mais escassos) e cobre as
-- situações novas (S29-S40, sem nenhum vínculo). Vínculos existentes
-- não foram tocados/reauditados — só adição, mesmo critério de
-- especificidade das demais migrations desta rodada.
-- ============================================================

begin;

do $$
declare v_total int;
begin
  select count(*) into v_total from public.alternative_psychological_types;
  if v_total != 17 then
    raise exception 'Estado atual (% vínculos) diverge do esperado (17) — script não é mais válido, não prosseguir.', v_total;
  end if;
end $$;

create table if not exists public._backup_alternative_psychological_types_20260918 as
  select * from public.alternative_psychological_types;

-- S6-C "Peço desculpas primeiro" (ao cometer um erro): valoriza o impacto humano antes do processo = IDE (potencial humano/conexão). Já é S no DISC (reparo relacional) — coerente, mesma leitura em duas dimensões.
insert into public.alternative_psychological_types (alternative_id, psychological_type_id, evidence_strength) values ('40000000-0000-0000-0006-000000000003', '60000000-0000-0000-0000-000000000002', 2) on conflict (alternative_id, psychological_type_id) do update set evidence_strength = excluded.evidence_strength;

-- S12-A "Vou testando direto" (aprender ferramenta nova): aprende fazendo, concreto e imediato = ART.
insert into public.alternative_psychological_types (alternative_id, psychological_type_id, evidence_strength) values ('40000000-0000-0000-0012-000000000001', '60000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, psychological_type_id) do update set evidence_strength = excluded.evidence_strength;

-- S17-C "Testo antes de propor" (ideia de melhoria): valida na prática antes de formalizar = ART.
insert into public.alternative_psychological_types (alternative_id, psychological_type_id, evidence_strength) values ('40000000-0000-0000-0017-000000000003', '60000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, psychological_type_id) do update set evidence_strength = excluded.evidence_strength;

-- S23-D "Explico com transparência" (cliente insatisfeito): valoriza honestidade/conexão genuína com o outro = IDE (fraco).
insert into public.alternative_psychological_types (alternative_id, psychological_type_id, evidence_strength) values ('40000000-0000-0000-0023-000000000004', '60000000-0000-0000-0000-000000000002', 1) on conflict (alternative_id, psychological_type_id) do update set evidence_strength = excluded.evidence_strength;

-- S24-B "Busco mais informação rápido" (decidir com poucas informações): quer base lógica antes de decidir = EST (fraco).
insert into public.alternative_psychological_types (alternative_id, psychological_type_id, evidence_strength) values ('40000000-0000-0000-0024-000000000002', '60000000-0000-0000-0000-000000000001', 1) on conflict (alternative_id, psychological_type_id) do update set evidence_strength = excluded.evidence_strength;

-- S29-A "Adianto outras entregas" (tarefas travadas): ação concreta e imediata com o tempo livre = ART.
insert into public.alternative_psychological_types (alternative_id, psychological_type_id, evidence_strength) values ('40000000-0000-0000-0029-000000000001', '60000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, psychological_type_id) do update set evidence_strength = excluded.evidence_strength;

-- S31-B "Já parto para o próximo" (projeto terminando): foco no presente/próxima ação, não se detém = ART (fraco).
insert into public.alternative_psychological_types (alternative_id, psychological_type_id, evidence_strength) values ('40000000-0000-0000-0031-000000000002', '60000000-0000-0000-0000-000000000004', 1) on conflict (alternative_id, psychological_type_id) do update set evidence_strength = excluded.evidence_strength;

-- S34-D "Busco entender antes de mudar" (método parou de funcionar): quer entender o sistema/causa antes de agir = EST. Já é C no DISC (análise) — coerente.
insert into public.alternative_psychological_types (alternative_id, psychological_type_id, evidence_strength) values ('40000000-0000-0000-0034-000000000004', '60000000-0000-0000-0000-000000000001', 2) on conflict (alternative_id, psychological_type_id) do update set evidence_strength = excluded.evidence_strength;

-- S36-D "Decido de forma reversível" (oportunidade, líder inacessível): pensa nas consequências de longo prazo/mitiga risco estrategicamente = EST.
insert into public.alternative_psychological_types (alternative_id, psychological_type_id, evidence_strength) values ('40000000-0000-0000-0036-000000000004', '60000000-0000-0000-0000-000000000001', 2) on conflict (alternative_id, psychological_type_id) do update set evidence_strength = excluded.evidence_strength;

-- S37-A "Ouço com calma e pergunto o que ele esperava diferente" (líder insatisfeito): busca conexão genuína para entender o outro = IDE.
insert into public.alternative_psychological_types (alternative_id, psychological_type_id, evidence_strength) values ('40000000-0000-0000-0037-000000000001', '60000000-0000-0000-0000-000000000002', 2) on conflict (alternative_id, psychological_type_id) do update set evidence_strength = excluded.evidence_strength;

-- S38-A "Já começo a estudar" (lacuna de conhecimento): ação concreta e imediata diante da lacuna = ART.
insert into public.alternative_psychological_types (alternative_id, psychological_type_id, evidence_strength) values ('40000000-0000-0000-0038-000000000001', '60000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, psychological_type_id) do update set evidence_strength = excluded.evidence_strength;

-- S39-A "Ofereço ensinar mesmo sem pedido" (colega precisa mas não pediu): quer ajudar o outro a crescer = IDE (potencial humano).
insert into public.alternative_psychological_types (alternative_id, psychological_type_id, evidence_strength) values ('40000000-0000-0000-0039-000000000001', '60000000-0000-0000-0000-000000000002', 2) on conflict (alternative_id, psychological_type_id) do update set evidence_strength = excluded.evidence_strength;

do $$
declare v_total int;
begin
  select count(*) into v_total from public.alternative_psychological_types;
  if v_total != 29 then
    raise exception 'Resultado final (% vínculos) diverge do esperado (29) — abortando commit.', v_total;
  end if;
  raise notice 'OK: % vínculos finais — 26/40 situações agora com cobertura de Tipo Psicológico.', v_total;
end $$;

commit;
