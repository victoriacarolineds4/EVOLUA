import type { Metadata } from "next";
import { redirect } from "next/navigation";
import { Mail, FileBarChart2 } from "lucide-react";
import { Container } from "@/components/layout/container";
import { Section } from "@/components/layout/section";
import { PageHeader } from "@/components/layout/page-header";
import { EmptyState } from "@/components/layout/empty-state";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { createClient } from "@/lib/supabase/server";
import { getProfileWithCompany } from "@/services/profile.service";
import { getApplicationsByCompany } from "@/services/applications.service";
import { PLAN_LABELS } from "@/app/(dashboard)/dashboard/components/plan-card";
import { STATUS_CONFIG } from "@/features/aplicacoes/lib/status";

export const metadata: Metadata = {
  title: "Meu Plano — EVOLUA",
};

const CONTACT_EMAIL = "victoriacarolineds4@gmail.com";

export default async function MeuPlanoPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  const profile = await getProfileWithCompany(user.id);
  const company = profile?.company;

  const applications = company ? await getApplicationsByCompany(company.id) : [];

  const planLabel = PLAN_LABELS[company?.plan ?? ""] ?? (company?.plan ?? "—");
  const total = company?.licenses_total ?? 0;
  const used = company?.licenses_used ?? 0;
  const available = total - used;
  const percent = total > 0 ? Math.round((used / total) * 100) : 0;

  return (
    <Container>
      <Section>
        <div className="space-y-8">
          <PageHeader
            title="Meu Plano"
            description="Seu plano atual e o uso das suas licenças."
          />

          {/* ── PLANO ATUAL ── */}
          <div className="rounded-2xl border border-border bg-card p-8">
            <div className="flex items-start justify-between">
              <div>
                <p className="text-sm font-medium text-muted-foreground">Plano atual</p>
                <p className="mt-1 font-heading text-2xl font-medium text-foreground">
                  {planLabel}
                </p>
              </div>
              <Badge variant="success">Ativo</Badge>
            </div>

            <div className="mt-6 space-y-3">
              <div className="flex items-center justify-between text-sm">
                <span className="text-muted-foreground">Licenças utilizadas</span>
                <span className="font-medium text-foreground">
                  {used} <span className="text-muted-foreground">de {total}</span>
                </span>
              </div>
              <Progress value={percent} className="h-2" />
              <p className="text-xs text-muted-foreground">
                {available} licença{available !== 1 ? "s" : ""}{" "}
                {available !== 1 ? "disponíveis" : "disponível"}
              </p>
            </div>
          </div>

          {/* ── FALE CONOSCO ── */}
          <div className="rounded-2xl border border-border bg-card p-6">
            <p className="text-sm font-medium text-foreground">Quer mudar de plano?</p>
            <p className="mt-1 text-sm text-muted-foreground">
              Ainda não temos upgrade automático — fale com a gente e ajustamos manualmente.
            </p>
            <a
              href={`mailto:${CONTACT_EMAIL}?subject=Alteração de plano — EVOLUA`}
              className="mt-4 inline-flex items-center gap-1.5 rounded-lg bg-primary/10 px-3 py-1.5 text-sm font-medium text-primary transition-colors hover:bg-primary/20"
            >
              <Mail className="size-3.5" />
              {CONTACT_EMAIL}
            </a>
          </div>

          {/* ── HISTÓRICO DE APLICAÇÕES ── */}
          <div className="space-y-4">
            <div>
              <h2 className="text-lg font-semibold text-foreground">Histórico de uso</h2>
              <p className="mt-0.5 text-sm text-muted-foreground">
                Licenças consumidas por cada aplicação criada.
              </p>
            </div>

            {applications.length === 0 ? (
              <EmptyState
                icon={FileBarChart2}
                title="Nenhuma aplicação ainda"
                description="Quando você criar aplicações, o consumo de licenças de cada uma aparece aqui."
              />
            ) : (
              <div className="rounded-2xl border border-border bg-card overflow-hidden">
                {applications.map((app, i) => {
                  const status = STATUS_CONFIG[app.status];
                  return (
                    <div
                      key={app.id}
                      className={
                        "flex items-center gap-4 px-6 py-4" +
                        (i === applications.length - 1 ? "" : " border-b border-border")
                      }
                    >
                      <div className="min-w-0 flex-1">
                        <p className="truncate text-sm font-medium text-foreground">
                          {app.name}
                        </p>
                        <p className="text-xs text-muted-foreground">
                          Criado em{" "}
                          {new Date(app.created_at).toLocaleDateString("pt-BR", {
                            day: "2-digit",
                            month: "long",
                            year: "numeric",
                          })}
                        </p>
                      </div>
                      <Badge variant={status.variant} className="shrink-0">
                        {status.label}
                      </Badge>
                      <span className="shrink-0 text-sm font-medium text-foreground">
                        {app.license_limit} licença{app.license_limit !== 1 ? "s" : ""}
                      </span>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </div>
      </Section>
    </Container>
  );
}
