-- ============================================================
-- EVOLUA — Sprint 14 — Validação de estado em update_response_progress
-- ============================================================
-- Corrige achado da Auditoria de Prontidão v2.0 (11/09/2026, Problema 1):
-- a função SECURITY DEFINER update_response_progress (migration 011)
-- aceitava, sem nenhuma validação:
--   - marcar uma resposta como "completed" sem nenhuma linha em `answers`;
--   - progress negativo ou acima do total de situações;
--   - reverter uma resposta já "completed" de volta para "started".
--
-- Esta migration reescreve a função para:
--   1. Rejeitar qualquer update numa resposta já `completed` (imutável
--      após concluída — nenhum caminho legítimo do fluxo normal chama
--      esta função de novo depois disso).
--   2. Validar p_progress e p_current_question contra o total real de
--      questões ativas.
--   3. Validar p_status contra os únicos valores aceitos pela CHECK
--      constraint de `responses.status` ('started'/'completed').
--   4. Só permitir a transição para 'completed' se o número de linhas
--      em `answers` para esta resposta for igual ao total de questões
--      ativas — ou seja, todas as situações realmente têm resposta.
--
-- Não muda a assinatura da função nem o fluxo normal de
-- answer.actions.ts (que já chama respeitando essas regras).
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
