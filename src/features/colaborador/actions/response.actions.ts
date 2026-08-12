"use server";

import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";

const participantSchema = z.object({
  name: z
    .string()
    .min(5, "Nome deve ter no mínimo 5 caracteres")
    .max(120, "Nome muito longo")
    .regex(/[^0-9]/, "Nome não pode conter apenas números"),
  role: z
    .string()
    .min(2, "Cargo deve ter no mínimo 2 caracteres")
    .max(80, "Cargo muito longo")
    .regex(/[^0-9]/, "Cargo não pode conter apenas números"),
});

export async function createResponseAction(
  applicationId: string,
  token: string,
  name: string,
  role: string,
) {
  // validação no servidor — nunca confiar apenas no navegador
  const parsed = participantSchema.safeParse({ name: name.trim(), role: role.trim() });
  if (!parsed.success) {
    const first = parsed.error.issues[0];
    return { error: first?.message ?? "Dados inválidos." };
  }

  const supabase = await createClient();

  // re-valida a aplicação (segunda camada de segurança) via RPC
  // security definer — `anon` não tem mais SELECT direto em
  // `applications` (ver migration 011_rls_hardening.sql).
  const { data: appRow, error: appError } = await supabase
    .rpc("get_application_by_id", { p_id: applicationId })
    .single();

  if (appError || !appRow) {
    return { error: "Aplicação não encontrada." };
  }

  const application = appRow as {
    status: string;
    license_limit: number;
    responses_count: number;
  };

  if (application.status !== "active") {
    return { error: "Esta aplicação foi encerrada." };
  }

  if (application.responses_count >= application.license_limit) {
    return { error: "O limite de participantes desta aplicação foi atingido." };
  }

  // INSERT via RPC security definer — a validação de FK (responses →
  // applications) exige que quem insere "enxergue" a linha referenciada
  // sob RLS; como `anon` não tem mais SELECT em `applications`, o
  // INSERT direto passou a falhar (42501). A função roda com privilégio
  // do dono e reaplica as mesmas regras de negócio internamente (ver
  // migration 012_rls_hardening_insert_fix.sql).
  const { data: newResponse, error: insertError } = await supabase
    .rpc("create_response", {
      p_application_id: applicationId,
      p_name: parsed.data.name,
      p_role: parsed.data.role,
    })
    .select("id")
    .single();

  if (insertError || !newResponse) {
    return { error: "Não foi possível registrar sua participação. Tente novamente." };
  }

  // Cookie httpOnly para identificar a jornada no questionário sem expor o ID na URL
  const cookieStore = await cookies();
  cookieStore.set("evolua_rid", newResponse.id, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    maxAge: 60 * 60 * 24 * 7, // 7 dias
    path: "/",
  });

  redirect(`/e/${token}/questionario`);
}
