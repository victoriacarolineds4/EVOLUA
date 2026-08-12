-- ============================================================
-- EVOLUA — Sprint 11 — RLS Hardening
-- ============================================================
-- ACHADO (auditoria de RLS, item 7 do plano de melhorias):
-- As migrations 003 e 005 concederam a `anon` policies de SELECT/UPDATE
-- com `using(true)` nas tabelas `responses` e `applications` — ou seja,
-- QUALQUER requisição anônima (usando a chave `anon`, que é pública e
-- vai no bundle do navegador) podia:
--   • listar TODAS as respostas de TODAS as empresas (nome, cargo,
--     progresso de cada colaborador) via GET .../responses?select=*
--   • alterar QUALQUER resposta via PATCH .../responses?id=eq.<qualquer>
--   • listar TODAS as aplicações de TODAS as empresas, incluindo o
--     `token` de cada uma — o "segredo" que protege o link do
--     colaborador — via GET .../applications?select=*
-- Havia ainda uma policy duplicada e com nome trocado
-- ("responses_insert_anon" que na verdade era FOR SELECT).
--
-- Isso NÃO é um problema teórico: com `using(true)`, o Postgres
-- devolve todas as linhas independentemente do filtro que o cliente
-- envie — filtrar por token/id no app não impede um dump completo
-- direto contra a API REST do Supabase.
--
-- CORREÇÃO: troca as policies "abertas" por funções SECURITY DEFINER
-- (mesmo padrão já usado em increment_application_responses_count).
-- O `anon` deixa de ter SELECT/UPDATE direto nessas tabelas — só pode
-- chamar as funções abaixo, que exigem o ID/token específico (o
-- "segredo" que o colaborador já possui via link/cookie httpOnly) e
-- devolvem/alteram no máximo 1 linha. Não é possível listar nem
-- alterar em lote.
--
-- O INSERT anônimo em `responses`/`answers` permanece aberto
-- (with check(true)) — inserir uma linha nova não expõe nem permite
-- ler/alterar dados de terceiros, e o fluxo do colaborador depende
-- disso para criar a própria jornada.
-- ============================================================

-- -----------------------------------------------------------
-- 1. Remove as policies abertas (o problema)
-- -----------------------------------------------------------
drop policy if exists "responses_insert_anon" on public.responses; -- nome errado: era FOR SELECT, duplicava a de baixo
drop policy if exists "responses_select_anon_questionnaire" on public.responses;
drop policy if exists "responses_update_anon_questionnaire" on public.responses;
drop policy if exists "applications_select_anon" on public.applications;

-- -----------------------------------------------------------
-- 2. Funções SECURITY DEFINER — leitura/escrita pontual por segredo
-- -----------------------------------------------------------

-- Busca 1 aplicação pelo token (o link público do colaborador).
create or replace function public.get_application_by_token(p_token text)
  returns setof public.applications
  language sql
  security definer set search_path = public
  stable
as $$
  select * from public.applications where token = p_token limit 1;
$$;

-- Busca 1 aplicação pelo id (usada após a validação inicial por token,
-- ex.: ao criar a resposta do colaborador).
create or replace function public.get_application_by_id(p_id uuid)
  returns setof public.applications
  language sql
  security definer set search_path = public
  stable
as $$
  select * from public.applications where id = p_id limit 1;
$$;

-- Busca 1 resposta pelo id (o segredo do cookie httpOnly evolua_rid).
create or replace function public.get_response_by_id(p_id uuid)
  returns setof public.responses
  language sql
  security definer set search_path = public
  stable
as $$
  select * from public.responses where id = p_id limit 1;
$$;

-- Atualiza o progresso da própria resposta (id = o segredo que o
-- colaborador já possui). Não permite alterar outras colunas nem
-- outras linhas.
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
begin
  update public.responses
     set progress = p_progress,
         current_question = p_current_question,
         status = coalesce(p_status, status),
         completed_at = coalesce(p_completed_at, completed_at)
   where id = p_id;
end;
$$;

-- Execução liberada para anon e authenticated (gestor também pode usar).
grant execute on function public.get_application_by_token(text) to anon, authenticated;
grant execute on function public.get_application_by_id(uuid) to anon, authenticated;
grant execute on function public.get_response_by_id(uuid) to anon, authenticated;
grant execute on function public.update_response_progress(uuid, integer, integer, text, timestamptz) to anon, authenticated;

-- -----------------------------------------------------------
-- NOTA: com as policies abertas removidas e nenhuma outra policy de
-- SELECT/UPDATE para `anon` restando em `responses`/`applications`,
-- o RLS passa a negar por padrão qualquer SELECT/UPDATE direto de
-- `anon` nessas duas tabelas — só as funções acima (que rodam com
-- privilégio do dono, ignorando RLS internamente) conseguem ler/
-- escrever, sempre limitadas a 1 linha específica.
-- `responses_insert_public` (INSERT anon) permanece intacta.
-- -----------------------------------------------------------
