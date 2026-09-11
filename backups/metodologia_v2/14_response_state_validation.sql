-- ============================================================
-- EVOLUA — Correção do Problema 1 (Auditoria de Prontidão v2.0)
-- update_response_progress passa a validar estado/limites
-- ============================================================
-- PASSO 1 — backup: guarda a definição atual da função antes de substituir,
-- para permitir rollback (basta rodar `select definition from
-- public._backup_update_response_progress_20260911;` e reexecutar o texto).
-- ============================================================

begin;

create table if not exists public._backup_update_response_progress_20260911 (
  captured_at timestamptz not null default now(),
  definition text not null
);

insert into public._backup_update_response_progress_20260911 (definition)
select pg_get_functiondef('public.update_response_progress(uuid, integer, integer, text, timestamptz)'::regprocedure);

-- ============================================================
-- PASSO 2 — substitui a função com as validações novas.
-- ============================================================

create or replace function public.update_response_progress(
  p_id uuid,
  p_progress integer,
  p_current_question integer,
  p_status text default null,
  p_completed_at timestamptz default null
)
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  v_status text;
  v_total_questions integer;
  v_answered_count integer;
begin
  select status into v_status from public.responses where id = p_id;
  if not found then
    raise exception 'response_not_found';
  end if;

  -- imutável após concluída: nenhuma chamada legítima acontece depois disso
  if v_status = 'completed' then
    raise exception 'response_already_completed';
  end if;

  select count(*) into v_total_questions from public.questions where active = true;

  if p_progress < 0 or p_progress > v_total_questions then
    raise exception 'invalid_progress';
  end if;

  if p_current_question < 1 or p_current_question > v_total_questions + 1 then
    raise exception 'invalid_current_question';
  end if;

  if p_status is not null and p_status not in ('started', 'completed') then
    raise exception 'invalid_status';
  end if;

  if p_status = 'completed' then
    select count(*) into v_answered_count
      from public.answers
     where response_id = p_id;

    if v_answered_count < v_total_questions then
      raise exception 'cannot_complete_without_all_answers';
    end if;
  end if;

  update public.responses
     set progress          = p_progress,
         current_question  = p_current_question,
         status            = coalesce(p_status, status),
         completed_at      = case when p_status = 'completed'
                                   then coalesce(p_completed_at, now())
                                   else completed_at
                              end
   where id = p_id;
end;
$$;

grant execute on function public.update_response_progress(uuid, integer, integer, text, timestamptz) to anon, authenticated;

-- ============================================================
-- PASSO 3 — verificação: a função deve existir com a nova definição.
-- ============================================================
select proname, pg_get_functiondef(oid) like '%response_already_completed%' as tem_validacao_nova
  from pg_proc where proname = 'update_response_progress';

commit;
