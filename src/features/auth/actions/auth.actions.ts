"use server";

import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

/**
 * Traduz erros do Supabase Auth para mensagens amigáveis em PT-BR.
 * NUNCA repassa `error.message` cru ao usuário — a plataforma não expõe
 * erro técnico. Usa `error.code` (estruturado) quando disponível; cai
 * para checagem de texto só como último recurso.
 *
 * Erros conhecidos aqui incluem `over_email_send_rate_limit`: o Supabase,
 * sem SMTP customizado configurado, limita o envio de e-mails (confirmação
 * de cadastro, recuperação de senha) a um teto baixo por hora, COMPARTILHADO
 * entre todo o projeto — não é um problema por domínio de e-mail. Correção
 * definitiva é configurar SMTP próprio ou desativar "Confirm email" no
 * painel (Authentication → Providers → Email); não é ajustável por código.
 */
function friendlyAuthError(error: { code?: string; message: string }): string {
  switch (error.code) {
    case "invalid_credentials":
      return "E-mail ou senha incorretos.";
    case "user_already_exists":
    case "email_exists":
    case "identity_already_exists":
      return "Já existe uma conta com este e-mail.";
    case "over_email_send_rate_limit":
    case "over_request_rate_limit":
      return "Muitas tentativas em pouco tempo. Aguarde alguns minutos e tente novamente.";
    case "email_address_invalid":
    case "validation_failed":
      return "Não foi possível usar este e-mail. Verifique se ele está correto.";
    case "weak_password":
      return "A senha é muito fraca. Use ao menos 8 caracteres, misturando letras e números.";
    case "signup_disabled":
    case "email_provider_disabled":
      return "Novos cadastros estão temporariamente indisponíveis. Tente novamente em breve.";
  }
  // Fallback por texto (versões antigas do auth-js podem não trazer `code`).
  const msg = error.message.toLowerCase();
  if (msg.includes("invalid login credentials")) return "E-mail ou senha incorretos.";
  if (msg.includes("already registered") || msg.includes("already exists")) {
    return "Já existe uma conta com este e-mail.";
  }
  if (msg.includes("rate limit")) {
    return "Muitas tentativas em pouco tempo. Aguarde alguns minutos e tente novamente.";
  }
  return "Não foi possível concluir. Tente novamente em instantes.";
}

export async function loginAction(email: string, password: string) {
  const supabase = await createClient();

  const { error } = await supabase.auth.signInWithPassword({ email, password });

  if (error) {
    return { error: friendlyAuthError(error) };
  }

  redirect("/dashboard");
}

export async function signUpAction(
  fullName: string,
  companyName: string,
  email: string,
  password: string,
) {
  const supabase = await createClient();

  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: { full_name: fullName, company_name: companyName },
    },
  });

  if (error) {
    return { error: friendlyAuthError(error) };
  }

  // Confirmação de e-mail ativa: signUp não retorna sessão.
  if (!data.session) {
    return { needsConfirmation: true };
  }

  redirect("/dashboard");
}

export async function logoutAction() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect("/login");
}

export async function recoverPasswordAction(email: string) {
  const supabase = await createClient();

  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${process.env.NEXT_PUBLIC_APP_URL}/auth/callback?next=/redefinir-senha`,
  });

  if (error) return { error: friendlyAuthError(error) };

  return { success: true };
}

export async function updatePasswordAction(password: string) {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { error: "Link expirado ou inválido. Solicite uma nova recuperação de senha." };
  }

  const { error } = await supabase.auth.updateUser({ password });

  if (error) return { error: friendlyAuthError(error) };

  redirect("/dashboard");
}
