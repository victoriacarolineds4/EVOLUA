-- ============================================================
-- EVOLUA — Sprint 13 — RLS: restringe o INSERT anônimo às regras de negócio
-- ============================================================
-- ACHADO ao testar a 012: `responses_insert_public` e `answers_insert_anon`
-- sempre tiveram `with check(true)` (desde a migration 003/005) — ou seja,
-- o INSERT direto via API sempre foi IRRESTRITO para `anon`, com ou sem
-- as funções create_response/save_answer. Confirmado empiricamente: um
-- INSERT direto contra a tabela `responses` (sem passar pela RPC)
-- retornou HTTP 201 e a linha foi persistida — mesmo para uma aplicação
-- fechada ou lotada, pois `with check(true)` nunca validou nada.
--
-- As regras de negócio (aplicação ativa, licença disponível, resposta em
-- andamento, alternativa pertence à questão) só existiam no código
-- TypeScript das Server Actions — útil para a UX, mas não é uma barreira
-- real, já que qualquer requisição direta à API REST (com a chave `anon`,
-- pública) contorna esse código.
--
-- CORREÇÃO: move a validação de negócio para o WITH CHECK da própria
-- policy de INSERT, via função SECURITY DEFINER (mesmo padrão das
-- migrations anteriores) — assim a regra vale mesmo para quem insere
-- direto pela API, sem depender do app respeitar o fluxo.
-- ============================================================

-- Aplicação está ativa e tem licença disponível?
create or replace function public.application_accepts_responses(p_application_id uuid)
  returns boolean
  language sql
  security definer set search_path = public
  stable
as $$
  select exists (
    select 1 from public.applications
     where id = p_application_id
       and status = 'active'
       and responses_count < license_limit
  );
$$;

-- A resposta está em andamento E a alternativa pertence à questão?
create or replace function public.answer_is_valid_for_insert(
  p_response_id uuid,
  p_question_id uuid,
  p_alternative_id uuid
)
  returns boolean
  language sql
  security definer set search_path = public
  stable
as $$
  select
    exists (
      select 1 from public.responses
       where id = p_response_id and status = 'started'
    )
    and exists (
      select 1 from public.alternatives
       where id = p_alternative_id and question_id = p_question_id
    );
$$;

grant execute on function public.application_accepts_responses(uuid) to anon, authenticated;
grant execute on function public.answer_is_valid_for_insert(uuid, uuid, uuid) to anon, authenticated;

-- Recria as policies de INSERT com a validação real no WITH CHECK.
drop policy if exists "responses_insert_public" on public.responses;
create policy "responses_insert_public"
  on public.responses for insert
  to anon
  with check ( public.application_accepts_responses(application_id) );

drop policy if exists "answers_insert_anon" on public.answers;
create policy "answers_insert_anon"
  on public.answers for insert
  to anon
  with check ( public.answer_is_valid_for_insert(response_id, question_id, alternative_id) );

-- -----------------------------------------------------------
-- NOTA: create_response()/save_answer() (migration 012) continuam
-- funcionando sem alteração — rodam como SECURITY DEFINER (dono da
-- tabela, que tem BYPASSRLS), então esta nova checagem no WITH CHECK
-- não as afeta. O que muda é que, agora, um INSERT direto contra a
-- tabela (contornando as funções) também precisa satisfazer a mesma
-- regra de negócio — não é mais `with check(true)`.
-- -----------------------------------------------------------
