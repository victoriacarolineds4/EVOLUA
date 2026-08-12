-- ============================================================
-- EVOLUA — Sprint 04.1 — Consolidação Arquitetural
-- ============================================================

-- -----------------------------------------------------------
-- AJUSTE 01: novos campos em responses
-- progress e current_question para rastrear avanço na Sprint 05
-- -----------------------------------------------------------
alter table public.responses
  add column progress         integer not null default 0,
  add column current_question integer not null default 1;

-- -----------------------------------------------------------
-- AJUSTE 02: adicionar status 'abandoned'
-- Remove o check existente e recria com o novo valor
-- -----------------------------------------------------------
do $$
declare
  v_constraint text;
begin
  select conname
    into v_constraint
    from pg_constraint
   where conrelid = 'public.responses'::regclass
     and contype  = 'c'
     and pg_get_constraintdef(oid) like '%started%';

  if v_constraint is not null then
    execute 'alter table public.responses drop constraint ' || quote_ident(v_constraint);
  end if;
end $$;

alter table public.responses
  add constraint responses_status_check
  check (status in ('started', 'completed', 'abandoned'));

-- -----------------------------------------------------------
-- AJUSTE 03: remover SELECT anon de responses
-- Colaborador anônimo só precisa de INSERT, não de SELECT.
-- -----------------------------------------------------------
drop policy if exists "responses_insert_anon" on public.responses;

-- -----------------------------------------------------------
-- AJUSTE 04: remover trigger de incremento automático
-- responses_count será incrementado apenas na primeira resposta (Sprint 05).
-- Até lá, o campo ficará em 0 para respostas recém-criadas.
-- ATENÇÃO: a validação "full" em validateApplicationToken ficará inativa
-- até a Sprint 05 reimplementar o incremento.
-- -----------------------------------------------------------
drop trigger if exists on_response_created on public.responses;
drop function if exists public.increment_responses_count();
