import { createClient } from "@/lib/supabase/server";
import type { Company } from "@/types/database.types";

export async function getCompany(companyId: string): Promise<Company | null> {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("companies")
    .select("*")
    .eq("id", companyId)
    .single();

  if (error || !data) return null;

  return data as Company;
}
