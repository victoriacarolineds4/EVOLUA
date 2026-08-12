import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

/**
 * Troca o `code` da query string pela sessão (padrão oficial do Supabase
 * Auth Helpers para Next.js App Router — PKCE flow, usado pelo cliente
 * `@supabase/ssr` deste projeto).
 *
 * O destino após o login é definido pelo parâmetro `next`, embutido no
 * `redirectTo` de quem disparou o e-mail (ver `recoverPasswordAction`).
 * Sem `next`, o padrão é `/dashboard`. Em caso de erro, nunca expõe
 * detalhe técnico — redireciona para a tela de recuperação com um aviso
 * amigável para o usuário solicitar um novo link.
 */
export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");
  const next = searchParams.get("next") ?? "/dashboard";

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) {
      return NextResponse.redirect(`${origin}${next}`);
    }
  }

  return NextResponse.redirect(`${origin}/recuperar-senha?expirado=1`);
}
