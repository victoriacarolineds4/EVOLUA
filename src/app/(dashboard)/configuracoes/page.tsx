import type { Metadata } from "next";
import Link from "next/link";
import { redirect } from "next/navigation";
import { KeyRound, ArrowRight } from "lucide-react";
import { Container } from "@/components/layout/container";
import { Section } from "@/components/layout/section";
import { PageHeader } from "@/components/layout/page-header";
import { createClient } from "@/lib/supabase/server";
import { getProfileWithCompany } from "@/services/profile.service";
import { ProfileNameForm } from "@/features/configuracoes/components/profile-name-form";

export const metadata: Metadata = {
  title: "Configurações — EVOLUA",
};

export default async function ConfiguracoesPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  const profile = await getProfileWithCompany(user.id);

  return (
    <Container>
      <Section>
        <div className="space-y-8">
          <PageHeader
            title="Configurações"
            description="Gerencie os dados da sua conta e empresa."
          />

          {/* ── SEU PERFIL ── */}
          <div className="rounded-2xl border border-border bg-card p-8 space-y-6">
            <div>
              <h2 className="text-lg font-semibold text-foreground">Seu perfil</h2>
              <p className="mt-0.5 text-sm text-muted-foreground">
                Como seu nome aparece para os colaboradores e no seu Mapa de Desenvolvimento.
              </p>
            </div>

            <div className="space-y-5">
              <ProfileNameForm initialFullName={profile?.full_name ?? ""} />

              <div className="space-y-1.5">
                <p className="text-sm font-medium text-foreground">E-mail</p>
                <p className="text-sm text-muted-foreground">{user.email}</p>
              </div>
            </div>
          </div>

          {/* ── EMPRESA ── */}
          <div className="rounded-2xl border border-border bg-card p-8 space-y-1.5">
            <h2 className="text-lg font-semibold text-foreground">Empresa</h2>
            <p className="mt-0.5 text-sm text-muted-foreground">
              {profile?.company?.name ?? "Nenhuma empresa associada à sua conta."}
            </p>
          </div>

          {/* ── SEGURANÇA ── */}
          <div className="rounded-2xl border border-border bg-card p-8">
            <h2 className="text-lg font-semibold text-foreground">Segurança</h2>
            <p className="mt-0.5 text-sm text-muted-foreground">
              Precisa trocar sua senha? Enviamos um link seguro para o seu e-mail.
            </p>
            <Link
              href="/recuperar-senha"
              className="mt-4 inline-flex items-center gap-1.5 rounded-lg bg-primary/10 px-3 py-1.5 text-sm font-medium text-primary transition-colors hover:bg-primary/20"
            >
              <KeyRound className="size-3.5" />
              Alterar senha
              <ArrowRight className="size-3" />
            </Link>
          </div>
        </div>
      </Section>
    </Container>
  );
}
