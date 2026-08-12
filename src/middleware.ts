import { NextResponse, type NextRequest } from "next/server";
import { updateSession } from "@/lib/supabase/middleware";

const PROTECTED_PREFIXES = ["/dashboard", "/aplicacoes", "/meu-plano", "/configuracoes", "/relatorio"];
const AUTH_PREFIXES = ["/login", "/cadastro", "/recuperar-senha"];

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  const result = await updateSession(request);

  // sem Supabase configurado: passa livre
  if (result instanceof NextResponse) return result;

  const { response, user } = result;

  const isProtected = PROTECTED_PREFIXES.some((p) => pathname.startsWith(p));
  const isAuthPage = AUTH_PREFIXES.some((p) => pathname.startsWith(p));
  const isRoot = pathname === "/";

  // usuário autenticado tentando acessar login ou raiz → dashboard
  if (user && (isAuthPage || isRoot)) {
    return NextResponse.redirect(new URL("/dashboard", request.url));
  }

  // usuário não autenticado tentando acessar área protegida → login
  if (!user && isProtected) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  return response;
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)"],
};
