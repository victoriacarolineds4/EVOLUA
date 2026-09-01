"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export async function updateProfileNameAction(fullName: string) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) return { error: "Não autenticado." };

  const trimmed = fullName.trim();
  if (trimmed.length < 2) {
    return { error: "Informe um nome com pelo menos 2 caracteres." };
  }

  const { error } = await supabase
    .from("profiles")
    .update({ full_name: trimmed })
    .eq("id", user.id);

  if (error) return { error: "Não foi possível salvar. Tente novamente." };

  revalidatePath("/configuracoes");
  revalidatePath("/dashboard");

  return { success: true };
}
