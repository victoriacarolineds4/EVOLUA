import { createClient } from "@/lib/supabase/server";
import type { Application } from "@/types/database.types";

export type ApplicationValidationResult =
  | { status: "valid"; application: Application }
  | { status: "not_found" }
  | { status: "closed" }
  | { status: "full" };

export async function validateApplicationToken(
  token: string,
): Promise<ApplicationValidationResult> {
  const supabase = await createClient();

  // RPC security definer: evita expor SELECT direto de `applications`
  // a `anon` (que permitiria dump de todas as aplicações/tokens — ver
  // migration 011_rls_hardening.sql).
  const { data, error } = await supabase
    .rpc("get_application_by_token", { p_token: token })
    .single();

  if (error || !data) return { status: "not_found" };

  const application = data as Application;

  if (application.status === "closed" || application.status === "draft") {
    return { status: "closed" };
  }

  if (application.responses_count >= application.license_limit) {
    return { status: "full" };
  }

  return { status: "valid", application };
}
