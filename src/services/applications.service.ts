import { createClient } from "@/lib/supabase/server";
import type { Application, Response } from "@/types/database.types";

export async function getApplicationsByCompany(
  companyId: string,
): Promise<Application[]> {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("applications")
    .select("*")
    .eq("company_id", companyId)
    .order("created_at", { ascending: false });

  if (error || !data) return [];

  return data as Application[];
}

/**
 * Uma aplicação por id, escopada à empresa do gestor logado via RLS
 * (`applications_select_own_company`) — se pertencer a outra empresa,
 * retorna null como se não existisse (nunca vaza dado de terceiros).
 */
export async function getApplicationById(
  id: string,
): Promise<Application | null> {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("applications")
    .select("*")
    .eq("id", id)
    .single();

  if (error || !data) return null;

  return data as Application;
}

/**
 * Colaboradores (respostas) de uma aplicação — escopado via
 * `responses_select_authenticated` (join com profiles.company_id).
 */
export async function getResponsesByApplication(
  applicationId: string,
): Promise<Response[]> {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("responses")
    .select("*")
    .eq("application_id", applicationId)
    .order("created_at", { ascending: false });

  if (error || !data) return [];

  return data as Response[];
}
