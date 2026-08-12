import type { Metadata } from "next";
import Link from "next/link";
import { redirect } from "next/navigation";
import { ArrowLeft, Users } from "lucide-react";
import { Container } from "@/components/layout/container";
import { Section } from "@/components/layout/section";
import { EmptyState } from "@/components/layout/empty-state";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { createClient } from "@/lib/supabase/server";
import { getApplicationById, getResponsesByApplication } from "@/services/applications.service";
import { STATUS_CONFIG } from "@/features/aplicacoes/lib/status";
import { ApplicationDetailActions } from "@/features/aplicacoes/components/application-detail-actions";
import { ResponseRow } from "@/features/aplicacoes/components/response-row";

export const metadata: Metadata = {
  title: "Detalhe da Aplicação — EVOLUA",
};

interface PageProps {
  params: Promise<{ id: string }>;
}

export default async function ApplicationDetailPage({ params }: PageProps) {
  const { id } = await params;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  const application = await getApplicationById(id);

  if (!application) {
    return (
      <Container>
        <Section>
          <div className="space-y-8">
            <Link
              href="/aplicacoes"
              className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
            >
              <ArrowLeft className="size-4" />
              Voltar para Aplicações
            </Link>
            <EmptyState
              icon={Users}
              title="Aplicação não encontrada"
              description="Ela pode ter sido removida, ou o link não é válido."
            />
          </div>
        </Section>
      </Container>
    );
  }

  const responses = await getResponsesByApplication(id);
  const appUrl = process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000";
  const status = STATUS_CONFIG[application.status];
  const progress =
    application.license_limit > 0
      ? Math.round((application.responses_count / application.license_limit) * 100)
      : 0;

  return (
    <Container>
      <Section>
        <div className="space-y-8">
          <Link
            href="/aplicacoes"
            className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
          >
            <ArrowLeft className="size-4" />
            Voltar para Aplicações
          </Link>

          {/* ── CABEÇALHO ── */}
          <div className="rounded-2xl border border-border bg-card p-8 space-y-6">
            <div className="flex flex-col items-start justify-between gap-4 sm:flex-row">
              <div className="space-y-1.5">
                <div className="flex items-center gap-3">
                  <h1 className="font-heading text-2xl font-medium text-foreground">
                    {application.name}
                  </h1>
                  <Badge variant={status.variant}>{status.label}</Badge>
                </div>
                <p className="text-sm text-muted-foreground">
                  Criado em{" "}
                  {new Date(application.created_at).toLocaleDateString("pt-BR", {
                    day: "2-digit",
                    month: "long",
                    year: "numeric",
                  })}
                </p>
              </div>

              <ApplicationDetailActions application={application} appUrl={appUrl} />
            </div>

            <div className="space-y-3 border-t border-border pt-6">
              <div className="flex items-center justify-between text-sm">
                <span className="text-muted-foreground">Licenças utilizadas</span>
                <span className="font-medium text-foreground">
                  {application.responses_count}{" "}
                  <span className="text-muted-foreground">/ {application.license_limit}</span>
                </span>
              </div>
              <Progress value={progress} className="h-1.5" />
            </div>
          </div>

          {/* ── COLABORADORES ── */}
          <div className="space-y-4">
            <div>
              <h2 className="text-lg font-semibold text-foreground">Colaboradores</h2>
              <p className="mt-0.5 text-sm text-muted-foreground">
                {responses.length === 0
                  ? "Ninguém iniciou a jornada ainda."
                  : `${responses.length} ${responses.length === 1 ? "pessoa iniciou" : "pessoas iniciaram"} a jornada.`}
              </p>
            </div>

            {responses.length === 0 ? (
              <EmptyState
                icon={Users}
                title="Nenhum colaborador ainda"
                description="Assim que alguém abrir o link e começar a responder, essa pessoa aparece aqui."
              />
            ) : (
              <div className="rounded-2xl border border-border bg-card overflow-hidden">
                {responses.map((r, i) => (
                  <ResponseRow key={r.id} response={r} isLast={i === responses.length - 1} />
                ))}
              </div>
            )}
          </div>
        </div>
      </Section>
    </Container>
  );
}
