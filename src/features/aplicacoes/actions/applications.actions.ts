"use server";

import { randomBytes } from "crypto";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export async function createApplicationAction(
  name: string,
  licenseLimit: number,
) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) return { error: "Não autenticado." };

  // busca profile + empresa para validar licenças
  const { data: profile } = await supabase
    .from("profiles")
    .select("company_id, company:companies(licenses_total, licenses_used)")
    .eq("id", user.id)
    .single();

  if (!profile?.company_id) {
    return { error: "Nenhuma empresa associada à sua conta." };
  }

  const company = profile.company as unknown as {
    licenses_total: number;
    licenses_used: number;
  } | null;

  if (!company) return { error: "Empresa não encontrada." };

  const available = company.licenses_total - company.licenses_used;

  if (licenseLimit < 1) {
    return { error: "A quantidade mínima é 1 colaborador." };
  }

  if (licenseLimit > available) {
    return {
      error: `Você possui apenas ${available} licença${available !== 1 ? "s" : ""} ${available !== 1 ? "disponíveis" : "disponível"}.`,
    };
  }

  // token criptograficamente seguro e não sequencial
  const token = randomBytes(20).toString("base64url");

  const { data, error } = await supabase
    .from("applications")
    .insert({
      company_id: profile.company_id,
      name: name.trim(),
      token,
      status: "active",
      license_limit: licenseLimit,
    })
    .select()
    .single();

  if (error) return { error: error.message };

  // atualiza licenças utilizadas na empresa
  await supabase
    .from("companies")
    .update({ licenses_used: company.licenses_used + licenseLimit })
    .eq("id", profile.company_id);

  revalidatePath("/dashboard");
  revalidatePath("/aplicacoes");

  return { data };
}

export async function closeApplicationAction(id: string) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) return { error: "Não autenticado." };

  // Decisão de produto (semântica de licenças, Opção A): as licenças são
  // reservadas integralmente na CRIAÇÃO da aplicação (license_limit), não
  // por resposta individual. Ao encerrar uma aplicação com respostas
  // incompletas, a sobra reservada NÃO volta ao saldo da empresa — é
  // deliberado, não um bug. Por isso não há ajuste de `licenses_used` aqui.
  const { error } = await supabase
    .from("applications")
    .update({ status: "closed" })
    .eq("id", id);

  if (error) return { error: error.message };

  revalidatePath("/dashboard");
  revalidatePath("/aplicacoes");

  return { success: true };
}
