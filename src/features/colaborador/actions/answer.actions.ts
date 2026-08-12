"use server";

import { redirect } from "next/navigation";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";

// Formato UUID leniente (8-4-4-4-12 hex). Aceita tanto os UUIDs v4 reais
// (responses) quanto os IDs fixos da metodologia (ex.: 30000000-...-000000000001),
// que são válidos no Postgres mas rejeitados pelo z.string().uuid() estrito do Zod v4.
const uuidLike = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const schema = z.object({
  responseId: z.string().regex(uuidLike, "ID de resposta inválido."),
  questionId: z.string().regex(uuidLike, "ID de questão inválido."),
  alternativeId: z.string().regex(uuidLike, "ID de alternativa inválido."),
  token: z.string().min(1),
});

export async function saveAnswerAction(
  responseId: string,
  questionId: string,
  alternativeId: string,
  token: string,
): Promise<{ error: string } | never> {
  const parsed = schema.safeParse({ responseId, questionId, alternativeId, token });
  if (!parsed.success) {
    return { error: parsed.error.issues[0]?.message ?? "Dados inválidos." };
  }

  const supabase = await createClient();

  // Carrega a resposta via RPC security definer — `anon` não tem mais
  // SELECT direto em `responses` (ver migration 011_rls_hardening.sql).
  const { data: responseRow, error: rErr } = await supabase
    .rpc("get_response_by_id", { p_id: responseId })
    .single();

  if (rErr || !responseRow) return { error: "Sessão não encontrada." };

  const response = responseRow as {
    application_id: string;
    status: string;
    current_question: number;
    progress: number;
  };

  if (response.status !== "started") return { error: "Esta jornada já foi concluída." };

  // Valida que o token pertence à mesma aplicação da resposta
  const { data: appDataRow } = await supabase
    .rpc("get_application_by_token", { p_token: token })
    .single();

  const appData = appDataRow as { id: string } | null;

  if (!appData || appData.id !== response.application_id) {
    return { error: "Link inválido." };
  }

  // Salva a resposta via RPC security definer — valida por dentro que a
  // alternativa pertence à questão e insere (idempotente). A validação
  // de FK (answers → responses) exige que quem insere "enxergue" a
  // linha referenciada sob RLS; como `anon` não tem mais SELECT em
  // `responses`, o INSERT direto passou a falhar (42501) — ver
  // migration 012_rls_hardening_insert_fix.sql.
  const { error: saveErr } = await supabase.rpc("save_answer", {
    p_response_id: responseId,
    p_question_id: questionId,
    p_alternative_id: alternativeId,
  });

  if (saveErr) {
    if (saveErr.message?.includes("invalid_alternative")) {
      return { error: "Alternativa inválida." };
    }
    return { error: "Erro ao salvar. Tente novamente." };
  }

  // Total de questões ativas
  const { count: totalCount } = await supabase
    .from("questions")
    .select("*", { count: "exact", head: true })
    .eq("active", true);
  const total = totalCount ?? 0;

  const isFirstAnswer = response.progress === 0;
  const isLastQuestion = response.current_question >= total;

  // Primeira resposta: consome a licença
  if (isFirstAnswer) {
    await supabase.rpc("increment_application_responses_count", {
      app_id: response.application_id,
    });
  }

  // Atualiza progresso
  const newProgress = response.current_question; // número de questões respondidas após este save
  const newCurrentQuestion = response.current_question + 1;

  // Atualiza via RPC security definer — `anon` não tem mais UPDATE
  // direto em `responses` (ver migration 011_rls_hardening.sql).
  if (isLastQuestion) {
    await supabase.rpc("update_response_progress", {
      p_id: responseId,
      p_progress: newProgress,
      p_current_question: newCurrentQuestion,
      p_status: "completed",
      p_completed_at: new Date().toISOString(),
    });
  } else {
    await supabase.rpc("update_response_progress", {
      p_id: responseId,
      p_progress: newProgress,
      p_current_question: newCurrentQuestion,
    });
  }

  redirect(`/e/${token}/questionario`);
}
