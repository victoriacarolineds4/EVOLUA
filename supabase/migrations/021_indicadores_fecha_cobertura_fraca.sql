-- ============================================================
-- EVOLUA — Indicadores: fecha cobertura dos 18 indicadores que nunca
-- atingiam confiança "alta" (achado da auditoria de aceitação)
-- ============================================================
-- AUDITORIA_ACEITACAO_PILOTO.md §4.2: 18 dos 35 indicadores tinham
-- cobertura de 0-2 situações — abaixo de MIN_EVIDENCE_SITUATIONS=3 —
-- e por isso NUNCA poderiam mostrar confiança "alta", para ninguém,
-- independente das respostas.
--
-- Esta migration adiciona uma 3ª (ou 2ª/3ª, no caso de I20 que tinha
-- zero) situação a 16 desses 18 indicadores, reaproveitando alternativas
-- que já existem no questionário e que genuinamente evidenciam aquele
-- indicador (mesmo teste de especificidade das migrations anteriores —
-- várias alternativas já carregam vínculo com OUTRO indicador/dimensão;
-- adicionar um segundo vínculo de indicador é uma prática já usada no
-- mapeamento original, ex.: '...0002-000000000001' já apontava para
-- 2 indicadores diferentes antes desta migration).
--
-- I06 (Assunção de Erros) e I18 (Mediação de Conflitos) NÃO foram
-- fechados — não encontrei, no conteúdo atual das 40 situações, uma
-- 3ª alternativa que evidenciasse esses dois construtos com
-- especificidade suficiente sem forçar. Ficam documentados como
-- limitação real, a resolver só com conteúdo novo (fora do escopo
-- desta correção).
--
-- I20 (Construção de Confiança) merece nota separada: o construto é
-- "ao longo do tempo" — nenhuma situação isolada evidencia isso com
-- força. As 3 adicionadas são as mais defensáveis encontradas, todas
-- com força 1 (secundária) — o indicador passa de "nunca tem score"
-- para "sempre baixa/moderada confiança", não para "boa cobertura".
-- ============================================================

begin;

do $$
declare v_total int;
begin
  select count(*) into v_total from public.alternative_indicators;
  if v_total != 192 then
    raise exception 'Estado atual (% vínculos) diverge do esperado (192) — script não é mais válido, não prosseguir.', v_total;
  end if;
end $$;

create table if not exists public._backup_alternative_indicators_20260918 as
  select * from public.alternative_indicators;

-- I01 (Gestão do Tempo) — S31-B "Já parto para o próximo": não deixa o tempo livre ocioso após concluir.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0031-000000000002', '20000000-0000-0000-0000-000000000001', 1) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

-- I04 (Consistência na Rotina) — S3-B "Escrevo os passos antes de agir": mantém método mesmo sem ser pedido.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0003-000000000002', '20000000-0000-0000-0000-000000000004', 1) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;
-- I04 — S40-A "Estruturo com metas claras" (autonomia total): mantém padrão de organização mesmo sem ninguém definir.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0040-000000000001', '20000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;
-- I04 — S40-D "Reviso e ajusto periodicamente": mantém rotina de revisão por conta própria.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0040-000000000004', '20000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

-- I05 (Fechamento de Ciclos) — S1-B "Revejo o que já entreguei, procurando algo para melhorar": revisão antes de considerar concluído.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0001-000000000002', '20000000-0000-0000-0000-000000000005', 2) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

-- I08 (Transparência sobre Atrasos) — S22-C "Negocio os prazos" (várias demandas ao mesmo tempo): comunica risco de atraso em vez de escondê-lo.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0022-000000000003', '20000000-0000-0000-0000-000000000008', 2) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

-- I11 (Abertura a Mudança) — S34-A "Mudo de abordagem rápido" (método parou de funcionar): adaptação, não resistência.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0034-000000000001', '20000000-0000-0000-0000-000000000011', 2) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

-- I15 (Flexibilidade Cognitiva) — S16-A "Procuro entender a lógica dela" (pensa muito diferente de mim): ajusta a própria forma de pensar diante do novo.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0016-000000000001', '20000000-0000-0000-0000-000000000015', 2) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

-- I17 (Acolhimento) — S16-C "Ajusto minha comunicação": acolhe a diferença adaptando-se a ela.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0016-000000000003', '20000000-0000-0000-0000-000000000017', 2) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

-- I20 (Construção de Confiança) — construto "ao longo do tempo"; as 3 abaixo são as mais defensáveis
-- disponíveis no conteúdo atual, todas com força secundária (1). Ver nota no cabeçalho.
-- S13-B "Pergunto o que ele precisa" (colega precisa de ajuda): atenção genuína antes de agir constrói confiança.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0013-000000000002', '20000000-0000-0000-0000-000000000020', 1) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;
-- S21-B "Reúno o time para decidir" (líder ausente): decisão inclusiva constrói confiança coletiva.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0021-000000000002', '20000000-0000-0000-0000-000000000020', 1) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;
-- S32-D "Agradeço e corrijo depois" (erro apontado na frente do time): recebe a correção com humildade, reforça confiança do time.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0032-000000000004', '20000000-0000-0000-0000-000000000020', 1) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

-- I22 (Transparência com Liderança) — S21-C "Tento contato com o líder" (líder ausente): busca comunicação direta com a liderança.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0021-000000000003', '20000000-0000-0000-0000-000000000022', 2) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

-- I26 (Autonomia sob Pressão) — S40-B "Vou decidindo dia a dia" (autonomia total): decide por conta própria continuamente.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0040-000000000002', '20000000-0000-0000-0000-000000000026', 2) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

-- I28 (Lida com Insatisfação) — S32-D "Agradeço e corrijo depois": constrói construtivamente diante da crítica pública do time.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0032-000000000004', '20000000-0000-0000-0000-000000000028', 2) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

-- I29 (Decisão com Informação Limitada) — S36-A "Decido e aproveito sozinho" (líder inacessível, janela curta): decide sem o contexto completo que o líder teria.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0036-000000000001', '20000000-0000-0000-0000-000000000029', 1) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

-- I31 (Busca por Crescimento) — S12-A "Vou testando direto" (aprender ferramenta nova): aproveita a oportunidade de aprender imediatamente.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0012-000000000001', '20000000-0000-0000-0000-000000000031', 2) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

-- I32 (Disposição para Ensinar) — S13-A "Ajudo na hora" (colega precisa de ajuda): compartilha conhecimento/apoio sem ser cobrado.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0013-000000000001', '20000000-0000-0000-0000-000000000032', 1) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

-- I34 (Uso da Autonomia) — S21-D "Resolvo só o essencial" (líder ausente): usa a autonomia de forma comedida/responsável.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0021-000000000004', '20000000-0000-0000-0000-000000000034', 2) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

-- I35 (Compromisso com Evolução) — S31-D "Registro o aprendizado" (projeto terminando): compromisso contínuo, não pontual, com o próprio desenvolvimento.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0031-000000000004', '20000000-0000-0000-0000-000000000035', 2) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;
-- I35 — S12-D "Aprendo aos poucos" (ferramenta nova): persiste no próprio desenvolvimento mesmo sem pressa.
insert into public.alternative_indicators (alternative_id, indicator_id, evidence_strength) values ('40000000-0000-0000-0012-000000000004', '20000000-0000-0000-0000-000000000035', 1) on conflict (alternative_id, indicator_id) do update set evidence_strength = excluded.evidence_strength;

do $$
declare v_total int;
begin
  select count(*) into v_total from public.alternative_indicators;
  if v_total != 213 then
    raise exception 'Resultado final (% vínculos) diverge do esperado (213) — abortando commit.', v_total;
  end if;
  raise notice 'OK: % vínculos finais. 16 dos 18 indicadores fracos agora têm >=3 situações (I06 e I18 permanecem, ver nota no cabeçalho).', v_total;
end $$;

commit;
