-- ============================================================
-- EVOLUA — DISC: aumenta o teto de C e I (achado da auditoria de aceitação)
-- ============================================================
-- A auditoria de 18/09/2026 (AUDITORIA_ACEITACAO_PILOTO.md, §4.3) provou
-- com uma persona sintética que mesmo o comportamento MAIS puramente C
-- possível no instrumento atual nunca sai confiante (isClose=true) —
-- porque o teto de C (soma de evidência máxima) é pequeno demais frente
-- ao de D. I tem o mesmo problema, documentado desde a v2.1.
--
-- Esta migration NÃO resolve isso por completo (exigiria reescrever
-- alternativas, fora de escopo aqui) — só adiciona vínculos genuinamente
-- específicos que já existiam no conteúdo e ainda não tinham sido
-- marcados, aumentando o teto real de C e I sem tocar em D/S.
-- Mesmo critério de rigor das migrations anteriores: nunca forçar vínculo
-- genérico só para fechar número.
-- ============================================================

begin;

do $$
declare v_total int; v_d int; v_i int; v_s int; v_c int;
begin
  select count(*) into v_total from public.alternative_disc;
  select count(*) filter (where dp.code='D') into v_d from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  select count(*) filter (where dp.code='I') into v_i from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  select count(*) filter (where dp.code='S') into v_s from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  select count(*) filter (where dp.code='C') into v_c from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  if v_total != 67 or v_d != 20 or v_i != 10 or v_s != 21 or v_c != 16 then
    raise exception 'Estado atual do banco (total=%, D=%, I=%, S=%, C=%) diverge do esperado (67, D20/I10/S21/C16) — script não é mais válido, não prosseguir.', v_total, v_d, v_i, v_s, v_c;
  end if;
end $$;

create table if not exists public._backup_alternative_disc_20260918b as
  select * from public.alternative_disc;

-- S2-B "Faço uma lista antes de começar": organização/estrutura antes de agir = C.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0002-000000000002', '50000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;

-- S4-D "Confiro item por item": atenção a detalhes/precisão = C forte.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0004-000000000004', '50000000-0000-0000-0000-000000000004', 3) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;

-- S17-B "Estruturo antes de apresentar" (ideia de melhoria): organização/estrutura = C.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0017-000000000002', '50000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;

-- S24-D "Escolho a opção mais segura" (decidir com poucas informações): critério de cautela = C.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0024-000000000004', '50000000-0000-0000-0000-000000000004', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;

-- S16-C "Ajusto minha comunicação" (trabalhar com quem pensa muito diferente): adaptação persuasiva = I.
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0016-000000000003', '50000000-0000-0000-0000-000000000002', 2) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;

-- S20-C "Uso um exemplo prático" (transmitir orientação importante): técnica persuasiva de comunicação = I (fraco).
insert into public.alternative_disc (alternative_id, disc_id, evidence_strength) values ('40000000-0000-0000-0020-000000000003', '50000000-0000-0000-0000-000000000002', 1) on conflict (alternative_id, disc_id) do update set evidence_strength = excluded.evidence_strength;

do $$
declare v_total int; v_d int; v_i int; v_s int; v_c int;
begin
  select count(*) into v_total from public.alternative_disc;
  select count(*) filter (where dp.code='D') into v_d from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  select count(*) filter (where dp.code='I') into v_i from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  select count(*) filter (where dp.code='S') into v_s from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  select count(*) filter (where dp.code='C') into v_c from public.alternative_disc ad join public.disc_profiles dp on dp.id=ad.disc_id;
  if v_total != 73 or v_d != 20 or v_i != 12 or v_s != 21 or v_c != 20 then
    raise exception 'Resultado final (total=%, D=%, I=%, S=%, C=%) diverge do esperado (73, D20/I12/S21/C20) — abortando commit.', v_total, v_d, v_i, v_s, v_c;
  end if;
  raise notice 'OK: % vínculos finais (D=%, I=%, S=%, C=%).', v_total, v_d, v_i, v_s, v_c;
end $$;

commit;
