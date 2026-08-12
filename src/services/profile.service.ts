import { createClient } from "@/lib/supabase/server";
import type { ProfileWithCompany } from "@/types/database.types";

export async function getProfileWithCompany(
  userId: string,
): Promise<ProfileWithCompany | null> {
  const supabase = await createClient();

  const { data, error } = await supabase
    .from("profiles")
    .select("*, company:companies(*)")
    .eq("id", userId)
    .single();

  if (error || !data) return null;

  return data as ProfileWithCompany;
}
