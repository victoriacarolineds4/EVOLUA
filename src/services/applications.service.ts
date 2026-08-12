import { createClient } from "@/lib/supabase/server";
import type { Application } from "@/types/database.types";

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
