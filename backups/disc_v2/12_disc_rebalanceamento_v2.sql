-- ============================================================
-- EVOLUA — DISC v2: rebalanceamento de vínculos alternativa→DISC
-- REVISADO após auditoria de rigor (2ª rodada) — corrige S27-D
-- (não auditada na v1) e remove 3 vínculos I fracos que não
-- passaram no teste de especificidade comportamental.
-- ============================================================
-- PREPARADO, NÃO EXECUTADO. One-shot: aborta se o estado atual
-- do banco não bater com o esperado (40 vínculos, D12/I7/S15/C6),
-- para nunca rodar duas vezes por engano nem sobre um banco que
-- já mudou desde que este script foi escrito.
-- ============================================================

begin;

-- Guarda de segurança: aborta se o estado atual não for exatamente
-- o esperado (protege contra reexecução e contra rodar sobre uma
-- base que já mudou desde a escrita deste script).
do $$
declare
  v_total int;
  v_d int; v_i int; v_s int; v_c int;
begin
  select count(*) into v_total from public.alternative_disc;
  select count(*) filter (where dp.code='D') into v_d from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  select count(*) filter (where dp.code='I') into v_i from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  select count(*) filter (where dp.code='S') into v_s from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  select count(*) filter (where dp.code='C') into v_c from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  if v_total != 40 or v_d != 12 or v_i != 7 or v_s != 15 or v_c != 6 then
    raise exception 'Estado atual do banco (total=%, D=%, I=%, S=%, C=%) diverge do esperado (40, D12/I7/S15/C6) — script não é mais válido para o estado atual, não prosseguir.', v_total, v_d, v_i, v_s, v_c;
  end if;
end $$;

create table if not exists public._backup_alternative_disc_20260913 as
  select * from public.alternative_disc;

-- 5 remoções — vínculo não passou no teste de especificidade
-- (item 2 da revisão: validade comportamental > balanceamento numérico)
-- S15-B "Não me envolvo": Não se envolver a menos que afete o trabalho não discrimina claramente nenhuma das 4 dimensões — mais sobre limite de escopo do que estilo comportamental DISC.
delete from public.alternative_disc where alternative_id = '40000000-0000-0000-0015-000000000002' and disc_id = '50000000-0000-0000-0000-000000000004';
-- S15-C "Sugiro que conversem entre si": Sugerir que conversem entre si é delegação/baixo envolvimento, não decisão assertiva (D) no sentido do construto.
delete from public.alternative_disc where alternative_id = '40000000-0000-0000-0015-000000000003' and disc_id = '50000000-0000-0000-0000-000000000001';
-- S19-D "Sinto receio, mas peço": Sentir receio mas pedir quando necessário não discrimina claramente nenhuma das 4 dimensões.
delete from public.alternative_disc where alternative_id = '40000000-0000-0000-0019-000000000004' and disc_id = '50000000-0000-0000-0000-000000000003';
-- S22-B "Alterno entre elas": Alternar entre tarefas ao mesmo tempo não é comunicação/persuasão (I) — é estilo de execução (Estilo Operacional), não DISC.
delete from public.alternative_disc where alternative_id = '40000000-0000-0000-0022-000000000002' and disc_id = '50000000-0000-0000-0000-000000000002';
-- S27-D "Sinto a tentação, mas volto atrás": Resistir à tentação e se autocorrigir é integridade geral, não discrimina D/I/S/C — qualquer perfil pode exibir esse comportamento. Não passa no teste de especificidade (item 2 da revisão).
delete from public.alternative_disc where alternative_id = '40000000-0000-0000-0027-000000000004' and disc_id = '50000000-0000-0000-0000-000000000003';

-- 4 reclassificações — dimensão incorreta corrigida (mesma força)
-- S02-A "Ordeno pelas mais urgentes": Ordenar por urgência é critério/organização (C), não enfrentamento/assertividade (D). Já mede I02 como indicador de priorização.
delete from public.alternative_disc where alternative_id = '40000000-0000-0000-0002-000000000001' and disc_id = '50000000-0000-0000-0000-000000000001';
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0002-000000000001', '50000000-0000-0000-0000-000000000004', 3) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S06-C "Peço desculpas primeiro": Pedir desculpas primeiro é reparo relacional/construção de confiança (S), não persuasão/mobilização (I).
delete from public.alternative_disc where alternative_id = '40000000-0000-0000-0006-000000000003' and disc_id = '50000000-0000-0000-0000-000000000002';
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0006-000000000003', '50000000-0000-0000-0000-000000000003', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S13-A "Ajudo na hora": Ajudar na hora é suporte/colaboração (S), não comunicação/persuasão/mobilização (I).
delete from public.alternative_disc where alternative_id = '40000000-0000-0000-0013-000000000001' and disc_id = '50000000-0000-0000-0000-000000000002';
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0013-000000000001', '50000000-0000-0000-0000-000000000003', 3) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S19-B "Tento sozinho primeiro": Tentar sozinho antes de pedir ajuda é autonomia (D), não critério/análise (C).
delete from public.alternative_disc where alternative_id = '40000000-0000-0000-0019-000000000002' and disc_id = '50000000-0000-0000-0000-000000000004';
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0019-000000000002', '50000000-0000-0000-0000-000000000001', 1) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;

-- 1 desdobramento em dupla dimensão (comportamento combina 2 construtos genuínos)
-- S22-C "Negocio os prazos": Negociar prazo é decisão assertiva (D) E persuasão/negociação social (I) — caso legítimo de dupla dimensão.
delete from public.alternative_disc where alternative_id = '40000000-0000-0000-0022-000000000003' and disc_id = '50000000-0000-0000-0000-000000000001';
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0022-000000000003', '50000000-0000-0000-0000-000000000001', 1) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0022-000000000003', '50000000-0000-0000-0000-000000000002', 1) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;

-- 16 adições — evidência comportamental nova identificada, teste de especificidade aplicado
-- S14-B "Explico como as coisas funcionam": Explicar proativamente como as coisas funcionam, sem esperar perguntarem = comunicação proativa/mobilização, I.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0014-000000000002', '50000000-0000-0000-0000-000000000002', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S26-D "Uso exemplos reais": Usar exemplos reais para facilitar entendimento = expressão/comunicação persuasiva, I.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0026-000000000004', '50000000-0000-0000-0000-000000000002', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S29-A "Adianto outras entregas": Adiantar entregas que não dependem de ninguém diante de bloqueio = iniciativa/autonomia sob impedimento, D.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0029-000000000001', '50000000-0000-0000-0000-000000000001', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S30-A "Sigo a mesma rotina": Seguir exatamente a mesma rotina sem supervisão = constância/previsibilidade, S textual.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0030-000000000001', '50000000-0000-0000-0000-000000000003', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S31-A "Faço revisão completa": Revisão completa antes de encerrar = precisão/qualidade, C.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0031-000000000001', '50000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S32-A "Assumo na hora": Assumir na hora mesmo desconfortável, na frente do time = enfrentamento direto, D.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0032-000000000001', '50000000-0000-0000-0000-000000000001', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S32-D "Agradeço e corrijo depois": Agradecer por apontarem e corrigir depois = resiliência relacional/construção de confiança, S.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0032-000000000004', '50000000-0000-0000-0000-000000000003', 1) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S33-A "Aviso todos os afetados": Estruturalmente análoga a S07-A (já C): comunicar atraso com nova estimativa é precisão/estrutura, não persuasão. 'Todos os afetados' não é motivo suficiente para dimensão diferente do par análogo.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0033-000000000001', '50000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S34-D "Busco entender antes de mudar": Entender por que não funciona antes de mudar = análise antes da ação, C.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0034-000000000004', '50000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S35-A "Intervenho na hora": Intervir na hora propondo decisão = enfrentamento direto de conflito, D forte.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0035-000000000001', '50000000-0000-0000-0000-000000000001', 3) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S35-C "Peço que expliquem antes": Pedir que cada um explique antes de decidir juntos é facilitação/mobilização de diálogo — mais I (mobilização de pessoas, interação) do que S (colaboração passiva/paciência).
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0035-000000000003', '50000000-0000-0000-0000-000000000002', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S36-A "Decido e aproveito sozinho": Decidir e aproveitar sozinho = autonomia/decisão, D.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0036-000000000001', '50000000-0000-0000-0000-000000000001', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S37-A "Ouço com calma e pergunto": Ouvir com calma e perguntar o que esperava diferente = paciência/receptividade, S.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0037-000000000001', '50000000-0000-0000-0000-000000000003', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S38-A "Já começo a estudar": Começar a estudar por conta própria sem ninguém pedir = iniciativa/autonomia, D.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0038-000000000001', '50000000-0000-0000-0000-000000000001', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S39-A "Ofereço ensinar": Mesmo padrão de S13-A (já reclassificado I->S nesta auditoria): oferecer ajuda espontânea é suporte/colaboração (S), não persuasão/mobilização (I). Mantido como I seria inconsistente com o critério aplicado a S13-A.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0039-000000000001', '50000000-0000-0000-0000-000000000003', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
-- S40-A "Estruturo com metas claras": Estruturar o tempo com metas claras = organização/estrutura, C.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0040-000000000001', '50000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;

-- S36-D "Decido de forma reversível": decisão reversível combina D (decisão) e C (cautela) — dupla dimensão genuína
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0036-000000000004', '50000000-0000-0000-0000-000000000001', 1) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0036-000000000004', '50000000-0000-0000-0000-000000000004', 1) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;

-- Verificação final: aborta o commit se a contagem não bater com o
-- esperado (54 vínculos: D17/I8/S19/C10).
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
    raise exception 'Resultado final (total=%, D=%, I=%, S=%, C=%) diverge do esperado (54, D17/I8/S19/C10) — abortando commit.', v_total, v_d, v_i, v_s, v_c;
  end if;
  raise notice 'OK: % vínculos finais (D=%, I=%, S=%, C=%) conferem com o esperado.', v_total, v_d, v_i, v_s, v_c;
end $$;

commit;