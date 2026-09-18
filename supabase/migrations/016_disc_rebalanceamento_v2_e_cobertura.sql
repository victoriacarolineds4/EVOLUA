-- ============================================================
-- EVOLUA — DISC: fechamento de cobertura (S1,S3,S10,S15,S25,S27)
-- ============================================================
-- A v2.1 (backups/disc_v2/12_disc_rebalanceamento_v2.sql) já estava
-- aplicada em produção quando esta migration foi escrita (confirmado
-- pela guarda de segurança abaixo, que checa o estado ATUAL do banco:
-- 54 vínculos, D17/I8/S19/C10 — o estado final da v2.1). Por isso este
-- arquivo não repete a v2.1 (isso causaria erro de guarda/duplicidade)
-- — só aplica o que falta: fechar a cobertura das 6 situações que
-- ficam SEM NENHUM vínculo DISC mesmo com a v2.1 aplicada — S1, S3,
-- S10, S25, S27 (nunca tiveram vínculo) e S15 (perdeu os 2 únicos
-- vínculos que tinha, removidos pela v2.1 por não passarem no teste
-- de especificidade, sem substituto).
--
-- Mesmo critério de rigor da v2.1 ("validade > balanceamento"): só
-- vínculo onde o comportamento é específico o bastante para aquela
-- dimensão — nunca forçado para fechar número. Cada adição tem
-- justificativa e, quando existe, o par análogo já classificado que
-- sustenta a decisão por precedente (mesmo princípio usado pela v2.1
-- para S33-A/S39-A).
--
-- IMPORTANTE — achado desta investigação (ver INVESTIGACAO_DISC_
-- ALLAN_PIRES.md): fechar esta cobertura NÃO necessariamente resolve
-- ambiguidades D/C existentes — em pelo menos um caso real testado,
-- a evidência nova adicionada favoreceu C, não D. As adições abaixo
-- foram decididas pela especificidade comportamental de cada
-- alternativa, nunca para produzir um resultado esperado para
-- nenhuma pessoa específica.
-- ============================================================

begin;

-- Guarda de segurança: aborta se o estado atual não for exatamente o
-- esperado (54 vínculos, D17/I8/S19/C10 — o estado final da v2.1, já
-- aplicada em produção) — protege contra reexecução e contra rodar
-- sobre uma base que já mudou desde a escrita deste script.
do $$
declare
  v_total int; v_d int; v_i int; v_s int; v_c int;
begin
  select count(*) into v_total from public.alternative_disc;
  select count(*) filter (where dp.code='D') into v_d from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  select count(*) filter (where dp.code='I') into v_i from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  select count(*) filter (where dp.code='S') into v_s from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  select count(*) filter (where dp.code='C') into v_c from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  if v_total != 54 or v_d != 17 or v_i != 8 or v_s != 19 or v_c != 10 then
    raise exception 'Estado atual do banco (total=%, D=%, I=%, S=%, C=%) diverge do esperado (54, D17/I8/S19/C10 — estado final da v2.1) — script não é mais válido para o estado atual, não prosseguir.', v_total, v_d, v_i, v_s, v_c;
  end if;
end $$;

create table if not exists public._backup_alternative_disc_20260918 as
  select * from public.alternative_disc;

-- ------------------------------------------------------------
-- Fechamento de cobertura (S1, S3, S10, S15, S25, S27)
-- ------------------------------------------------------------

-- S1 "Termino uma atividade e ainda tenho tempo disponível"
-- S1-A "Adianto a próxima tarefa": análoga a S29-A/S38-A (já D) — usa o tempo livre para avançar por iniciativa própria.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0001-000000000001', '50000000-0000-0000-0000-000000000001', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S1-D "Pergunto se o time precisa de apoio": suporte espontâneo diante de tempo livre = colaboração/estabilidade, S.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0001-000000000004', '50000000-0000-0000-0000-000000000003', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;

-- S3 "Preciso definir por onde começar o trabalho"
-- S3-B "Escrevo os passos antes de agir": planejamento estruturado antes de agir = C (organização/estrutura), sem ambiguidade com D como S3-A teria (ver nota abaixo).
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0003-000000000002', '50000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S3-D "Peço uma referência de como já foi feito": busca de padrão/precedente = respeito a padrões, C (fraco).
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0003-000000000004', '50000000-0000-0000-0000-000000000004', 1) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- NOTA: S3-A ("Começo pelo que trava o resto") não foi classificada — mistura priorização por
-- critério (C, como o par análogo S2-A já reclassificado pela v2.1) e foco em resultado (D);
-- não passa no teste de especificidade com convicção suficiente. Deixada sem vínculo.

-- S10 "Recebo uma tarefa que nunca fiz"
-- S10-A "Topo e aprendo na prática": assume o desafio sem hesitar = enfrentamento/iniciativa, D.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0010-000000000001', '50000000-0000-0000-0000-000000000001', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S10-B "Pesquiso antes de começar": análise antes de agir, mesmo padrão de S34-D ("busco entender antes de mudar", já C) — C.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0010-000000000002', '50000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S10-D "Peço mais prazo, por ser novidade": cautela diante do desconhecido, quer fazer com segurança = C (fraco).
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0010-000000000004', '50000000-0000-0000-0000-000000000004', 1) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;

-- S15 "Existe um conflito entre dois colegas" (ficou sem NENHUM vínculo após a v2.1 remover os 2 que tinha)
-- S15-A "Converso com os dois": mediação ativa via diálogo = mobilização de pessoas, I. Reforça a dimensão de menor cobertura (ver §12 da EVOLUA_DISC_ESPECIFICACAO.md).
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0015-000000000001', '50000000-0000-0000-0000-000000000002', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S15-D "Aviso alguém de confiança": busca discreta de apoio relacional = construção de confiança, S (fraco).
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0015-000000000004', '50000000-0000-0000-0000-000000000003', 1) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- NOTA: S15-B/S15-C são as duas alternativas já removidas pela v2.1 por não discriminarem
-- (baixo envolvimento / delegação, não estilo comportamental) — não recriadas.

-- S25 "Surge uma oportunidade de crescimento"
-- S25-A "Abraço mesmo sem estar 100% pronto": decide agir sob incerteza = enfrentamento/iniciativa, D (paralelo a S28-A "decido com confiança", já D3).
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0025-000000000001', '50000000-0000-0000-0000-000000000001', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S25-B "Avalio com calma antes de aceitar": análise cautelosa antes de decidir = C.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0025-000000000002', '50000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S25-D "Já penso em quem pode me ajudar no caminho": mobiliza rede de apoio = interação social, I (fraco).
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0025-000000000004', '50000000-0000-0000-0000-000000000002', 1) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;

-- S27 "Fazer o que é correto parece mais difícil do que fazer o mais fácil"
-- S27-B "Penso nas consequências antes de decidir": análise antes de agir = C (fraco).
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0027-000000000002', '50000000-0000-0000-0000-000000000004', 1) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- NOTA: S27-A, S27-C e S27-D (removida pela v2.1) são sobre integridade/ética geral, não sobre
-- estilo DISC — qualquer perfil pode agir assim. Pelo mesmo critério que já removeu S27-D,
-- não classificadas. Esta situação permanece com sinal fraco por desenho, não por lacuna.

-- Verificação final: total esperado 67 vínculos (D20/I10/S21/C16).
do $$
declare v_total int; v_d int; v_i int; v_s int; v_c int;
begin
  select count(*) into v_total from public.alternative_disc;
  select count(*) filter (where dp.code='D') into v_d from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  select count(*) filter (where dp.code='I') into v_i from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  select count(*) filter (where dp.code='S') into v_s from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  select count(*) filter (where dp.code='C') into v_c from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  if v_total != 67 or v_d != 20 or v_i != 10 or v_s != 21 or v_c != 16 then
    raise exception 'Resultado final (total=%, D=%, I=%, S=%, C=%) diverge do esperado (67, D20/I10/S21/C16) — abortando commit.', v_total, v_d, v_i, v_s, v_c;
  end if;
  raise notice 'OK: % vínculos finais (D=%, I=%, S=%, C=%) — 40/40 situações agora com cobertura DISC.', v_total, v_d, v_i, v_s, v_c;
end $$;

commit;
