-- ============================================================
-- EVOLUA — Sprint 12 — RLS Hardening (correção de regressão da 011)
-- ============================================================
-- ACHADO ao validar a migration 011: remover TODO SELECT de `anon`
-- em `applications` e `responses` quebrou os INSERTs anônimos em
-- `responses` (FK para applications) e `answers` (FK para responses).
--
-- Motivo: a validação de chave estrangeira do Postgres, ao inserir
-- uma linha que referencia outra tabela, precisa "enxergar" a linha
-- referenciada sob a ótica de RLS do papel que está inserindo. Sem
-- nenhuma policy de SELECT para `anon` nas tabelas referenciadas
-- (applications, responses), o Postgres não consegue confirmar a FK
-- e rejeita o INSERT com "new row violates row-level security
-- policy" (42501) — mesmo a tabela sendo a de destino do INSERT.
--
-- Reproduzido e confirmado via teste direto contra a API REST antes
-- desta correção.
--
-- CORREÇÃO: move as duas escritas para funções SECURITY DEFINER
-- (mesmo padrão da 011). Rodando com privilégio do dono, a validação
-- de FK enxerga as tabelas referenciadas independentemente do RLS do
-- chamador — sem reabrir nenhum SELECT em massa para `anon`.
-- As regras de negócio (aplicação ativa, licença disponível, resposta
-- em andamento, alternativa pertence à questão) passam a ser
-- garantidas dentro da própria função, como camada extra de defesa.
-- ============================================================

-- Cria a resposta do colaborador, validando a aplicação por dentro
-- (mesmas regras que já existiam em response.actions.ts).
create or replace function public.create_response(
  p_application_id uuid,
  p_name text,
  p_role text
)
  returns setof public.responses
  language plpgsql
  security definer set search_path = public
as $$
declare
  v_app public.applications;
  v_new_id uuid;
begin
  select * into v_app from public.applications where id = p_application_id;

  if not found then
    raise exception 'application_not_found';
  end if;
  if v_app.status <> 'active' then
    raise exception 'application_not_active';
  end if;
  if v_app.responses_count >= v_app.license_limit then
    raise exception 'application_full';
  end if;

  insert into public.responses (application_id, name, role, status, started_at)
  values (p_application_id, p_name, p_role, 'started', now())
  returning id into v_new_id;

  return query select * from public.responses where id = v_new_id;
end;
$$;

-- Salva a resposta de uma situação, validando por dentro que a
-- resposta está em andamento e que a alternativa pertence à questão.
-- Idempotente (ON CONFLICT DO NOTHING) — questão já respondida não é erro.
create or replace function public.save_answer(
  p_response_id uuid,
  p_question_id uuid,
  p_alternative_id uuid
)
  returns void
  language plpgsql
  security definer set search_path = public
as $$
declare
  v_response public.responses;
  v_alt_ok boolean;
begin
  select * into v_response from public.responses where id = p_response_id;

  if not found then
    raise exception 'response_not_found';
  end if;
  if v_response.status <> 'started' then
    raise exception 'response_already_completed';
  end if;

  select exists(
    select 1 from public.alternatives
     where id = p_alternative_id and question_id = p_question_id
  ) into v_alt_ok;

  if not v_alt_ok then
    raise exception 'invalid_alternative';
  end if;

  insert into public.answers (response_id, question_id, alternative_id)
  values (p_response_id, p_question_id, p_alternative_id)
  on conflict (response_id, question_id) do nothing;
end;
$$;

grant execute on function public.create_response(uuid, text, text) to anon, authenticated;
grant execute on function public.save_answer(uuid, uuid, uuid) to anon, authenticated;
