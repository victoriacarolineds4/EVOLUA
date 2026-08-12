import { createClient } from "@/lib/supabase/server";
import type { Question, Alternative, Response } from "@/types/database.types";

export async function getQuestionByOrderIndex(
  orderIndex: number,
): Promise<Question | null> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("questions")
    .select("*")
    .eq("order_index", orderIndex)
    .eq("active", true)
    .single();
  if (error || !data) return null;
  return data as Question;
}

export async function getAlternativesByQuestion(
  questionId: string,
): Promise<Alternative[]> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("alternatives")
    .select("*")
    .eq("question_id", questionId)
    .order("order_index", { ascending: true });
  return (data ?? []) as Alternative[];
}

export async function getTotalActiveQuestions(): Promise<number> {
  const supabase = await createClient();
  const { count } = await supabase
    .from("questions")
    .select("*", { count: "exact", head: true })
    .eq("active", true);
  return count ?? 0;
}

export async function getResponseById(
  responseId: string,
): Promise<Response | null> {
  const supabase = await createClient();
  // RPC security definer: `anon` não tem mais SELECT direto em
  // `responses` (ver migration 011_rls_hardening.sql).
  const { data, error } = await supabase
    .rpc("get_response_by_id", { p_id: responseId })
    .single();
  if (error || !data) return null;
  return data as Response;
}

export async function getApplicationIdByToken(
  token: string,
): Promise<string | null> {
  const supabase = await createClient();
  const { data } = await supabase
    .rpc("get_application_by_token", { p_token: token })
    .single();
  return (data as { id: string } | null)?.id ?? null;
}
