-- ============================================================
-- EVOLUA — Motivador: fechamento parcial de cobertura
-- ============================================================
-- Motivador ("o que move a pessoa") tem hoje só 11 vínculos, cobrindo
-- 9 das 40 situações (22,5%) — a camada mais pobre em evidência das
-- 4 dimensões complementares. As 12 situações mais novas (S29-S40)
-- não têm nenhum vínculo, mesmo problema já corrigido para DISC na
-- migration 016.
--
-- IMPORTANTE — por que a cobertura fica bem mais baixa aqui do que em
-- DISC mesmo aplicando o mesmo rigor: DISC mede COMO a pessoa age —
-- o comportamento escolhido já É o sinal. Motivador mede POR QUE ela
-- agiria assim — o motivo raramente é implícito numa escolha de ação
-- (ex.: "revisar com cuidado antes de entregar" não revela se a
-- pessoa é movida por qualidade, medo de errar, ou nada disso). Por
-- isso a maioria das 40 situações NÃO recebeu vínculo nesta migration
-- — não é lacuna, é o teto real do que este tipo de instrumento
-- consegue inferir com honestidade a partir de "como você reagiria".
-- Ver recomendação correspondente na investigação anexa.
--
-- Consequência prática: REC (Reconhecimento), FIN (Recompensa
-- Financeira), DEV (Desenvolvimento) e OUT (Outras formas) continuam
-- sem nenhum vínculo depois desta migration — nenhuma situação atual
-- revela com especificidade suficiente que a pessoa é movida
-- especificamente por esses motivadores (ver nota final).
-- ============================================================

begin;

do $$
declare v_total int;
begin
  select count(*) into v_total from public.alternative_motivators;
  if v_total != 11 then
    raise exception 'Estado atual (% vínculos) diverge do esperado (11) — script não é mais válido, não prosseguir.', v_total;
  end if;
end $$;

create table if not exists public._backup_alternative_motivators_20260918 as
  select * from public.alternative_motivators;

-- S19-B "Tento sozinho primeiro" (antes de pedir ajuda): autonomia — quer resolver por conta própria. AUT.
insert into public.alternative_motivators (alternative_id, motivator_id, evidence_strength) values ('40000000-0000-0000-0019-000000000002', '70000000-0000-0000-0000-000000000005', 2) on conflict (alternative_id, motivator_id) do update set evidence_strength = excluded.evidence_strength;

-- S21-A "Decido sozinho e informo depois" (líder ausente): decide sem esperar aprovação = autonomia, AUT.
insert into public.alternative_motivators (alternative_id, motivator_id, evidence_strength) values ('40000000-0000-0000-0021-000000000001', '70000000-0000-0000-0000-000000000005', 2) on conflict (alternative_id, motivator_id) do update set evidence_strength = excluded.evidence_strength;

-- S24-C "Peço a opinião de alguém" (decidir com poucas informações): busca apoio de quem confia = CNF.
insert into public.alternative_motivators (alternative_id, motivator_id, evidence_strength) values ('40000000-0000-0000-0024-000000000003', '70000000-0000-0000-0000-000000000010', 1) on conflict (alternative_id, motivator_id) do update set evidence_strength = excluded.evidence_strength;

-- S25-D "Já penso em quem pode me ajudar" (oportunidade de crescimento): mobiliza rede de confiança = CNF.
insert into public.alternative_motivators (alternative_id, motivator_id, evidence_strength) values ('40000000-0000-0000-0025-000000000004', '70000000-0000-0000-0000-000000000010', 1) on conflict (alternative_id, motivator_id) do update set evidence_strength = excluded.evidence_strength;

-- S28-C "Envolvo o time mesmo assim" (com autonomia total): escolhe envolver o time mesmo podendo decidir só = valoriza confiança coletiva, CNF.
insert into public.alternative_motivators (alternative_id, motivator_id, evidence_strength) values ('40000000-0000-0000-0028-000000000003', '70000000-0000-0000-0000-000000000010', 1) on conflict (alternative_id, motivator_id) do update set evidence_strength = excluded.evidence_strength;

-- S29-D "Aproveito para descansar" (tarefas travadas, tempo livre): sinal direto e específico de TQV — o mais limpo desta migration.
insert into public.alternative_motivators (alternative_id, motivator_id, evidence_strength) values ('40000000-0000-0000-0029-000000000004', '70000000-0000-0000-0000-000000000011', 3) on conflict (alternative_id, motivator_id) do update set evidence_strength = excluded.evidence_strength;

-- S30-D "Mantenho prazos, flexibilizo o resto" (sem supervisão): mantém compromisso mas no seu próprio jeito = AUT (fraco).
insert into public.alternative_motivators (alternative_id, motivator_id, evidence_strength) values ('40000000-0000-0000-0030-000000000004', '70000000-0000-0000-0000-000000000005', 1) on conflict (alternative_id, motivator_id) do update set evidence_strength = excluded.evidence_strength;

-- S31-B "Já parto para o próximo" (projeto terminando): busca o próximo desafio em vez de descansar no encerramento = DES.
insert into public.alternative_motivators (alternative_id, motivator_id, evidence_strength) values ('40000000-0000-0000-0031-000000000002', '70000000-0000-0000-0000-000000000008', 2) on conflict (alternative_id, motivator_id) do update set evidence_strength = excluded.evidence_strength;

-- S31-D "Registro o aprendizado": consolida o que aprendeu no projeto = APR.
insert into public.alternative_motivators (alternative_id, motivator_id, evidence_strength) values ('40000000-0000-0000-0031-000000000004', '70000000-0000-0000-0000-000000000006', 2) on conflict (alternative_id, motivator_id) do update set evidence_strength = excluded.evidence_strength;

-- S32-D "Agradeço e corrijo depois" (erro apontado na frente do time): recebe a correção como aprendizado, não como ameaça = APR (fraco).
insert into public.alternative_motivators (alternative_id, motivator_id, evidence_strength) values ('40000000-0000-0000-0032-000000000004', '70000000-0000-0000-0000-000000000006', 1) on conflict (alternative_id, motivator_id) do update set evidence_strength = excluded.evidence_strength;

-- S36-A "Decido e aproveito sozinho" (oportunidade, líder inacessível): aproveita a autonomia da situação para agir = AUT.
insert into public.alternative_motivators (alternative_id, motivator_id, evidence_strength) values ('40000000-0000-0000-0036-000000000001', '70000000-0000-0000-0000-000000000005', 2) on conflict (alternative_id, motivator_id) do update set evidence_strength = excluded.evidence_strength;

-- S38-A "Já começo a estudar" (lacuna de conhecimento, sem ser cobrado): aprender por iniciativa própria, sem cobrança externa — um dos sinais mais limpos de APR em todo o instrumento.
insert into public.alternative_motivators (alternative_id, motivator_id, evidence_strength) values ('40000000-0000-0000-0038-000000000001', '70000000-0000-0000-0000-000000000006', 3) on conflict (alternative_id, motivator_id) do update set evidence_strength = excluded.evidence_strength;

-- S38-C "Busco quem me oriente": recorre a mentoria/orientação de alguém de confiança = CNF.
insert into public.alternative_motivators (alternative_id, motivator_id, evidence_strength) values ('40000000-0000-0000-0038-000000000003', '70000000-0000-0000-0000-000000000010', 1) on conflict (alternative_id, motivator_id) do update set evidence_strength = excluded.evidence_strength;

-- NOTA — REC, FIN, DEV e OUT continuam sem vínculo algum após esta migration.
-- Não é uma omissão: nenhuma das 40 situações atuais pede uma escolha entre formas de
-- recompensa (visibilidade vs. dinheiro vs. plano de carreira formal vs. algo fora do padrão)
-- — todas pedem "como você reagiria a X", que não revela isso. Para medir esses 4 motivadores
-- com a mesma honestidade aplicada aqui, provavelmente é necessário um tipo de pergunta
-- diferente (preferência explícita entre recompensas), não mais situações de reação.

do $$
declare v_total int;
begin
  select count(*) into v_total from public.alternative_motivators;
  if v_total != 24 then
    raise exception 'Resultado final (% vínculos) diverge do esperado (24) — abortando commit.', v_total;
  end if;
  raise notice 'OK: % vínculos finais — 16/40 situações agora com cobertura de Motivador.', v_total;
end $$;

commit;
