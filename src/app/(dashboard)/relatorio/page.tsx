import type { Metadata } from "next";
import Link from "next/link";
import { redirect } from "next/navigation";
import { FileBarChart2, ArrowRight, TrendingUp } from "lucide-react";
import { Container } from "@/components/layout/container";
import { Section } from "@/components/layout/section";
import { createClient } from "@/lib/supabase/server";
import { getProfileWithCompany } from "@/services/profile.service";
import { getCompletedReportsForCompany } from "@/services/motor/motor.service";
import { cn } from "@/lib/utils";

export const metadata: Metadata = {
  title: "Relatórios — EVOLUA",
};

function overallColor(score: number) {
  if (score >= 80) return "text-emerald-400";
  if (score >= 65) return "text-amber-400";
  return "text-rose-400";
}
function overallBg(score: number) {
  if (score >= 80) return "bg-emerald-400/10 border-emerald-400/20";
  if (score >= 65) return "bg-amber-400/10 border-amber-400/20";
  return "bg-rose-400/10 border-rose-400/20";
}

export default async function RelatoriosPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const profile = await getProfileWithCompany(user.id);
  const reports = profile?.company
    ? await getCompletedReportsForCompany(supabase, profile.company.id)
    : [];

  return (
    <Container>
      <Section>
        <div className="space-y-8">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-semibold text-foreground">Relatórios</h1>
              <p className="mt-1 text-sm text-muted-foreground">
                Mapas de Desenvolvimento gerados para os colaboradores.
              </p>
            </div>
            <div className="flex items-center gap-2 rounded-lg border border-border bg-card px-4 py-2.5">
              <TrendingUp className="size-4 text-primary" />
              <span className="text-sm font-medium text-foreground">
                {reports.length} {reports.length === 1 ? "relatório" : "relatórios"}
              </span>
            </div>
          </div>

          {reports.length === 0 ? (
            <div className="rounded-2xl border border-dashed border-border p-12 text-center">
              <FileBarChart2 className="mx-auto mb-3 size-8 text-muted-foreground/50" />
              <p className="text-sm font-medium text-foreground">
                Nenhum relatório ainda
              </p>
              <p className="mt-1 text-sm text-muted-foreground">
                Os Mapas de Desenvolvimento aparecem aqui quando os colaboradores concluem o diagnóstico.
              </p>
            </div>
          ) : (
            <div className="rounded-2xl border border-border bg-card overflow-hidden">
              <div className="grid grid-cols-[1fr_1fr_auto_auto_auto] gap-4 border-b border-border px-6 py-3">
                <p className="text-xs font-medium uppercase tracking-wider text-muted-foreground">Colaborador</p>
                <p className="text-xs font-medium uppercase tracking-wider text-muted-foreground">Perfil</p>
                <p className="text-xs font-medium uppercase tracking-wider text-muted-foreground">Score</p>
                <p className="text-xs font-medium uppercase tracking-wider text-muted-foreground">Concluído</p>
                <span />
              </div>

              {reports.map((report, i) => (
                <div
                  key={report.responseId}
                  className={cn(
                    "grid grid-cols-[1fr_1fr_auto_auto_auto] items-center gap-4 px-6 py-4",
                    i < reports.length - 1 && "border-b border-border",
                  )}
                >
                  <div>
                    <p className="text-sm font-medium text-foreground">{report.name}</p>
                    <p className="text-xs text-muted-foreground">{report.role}</p>
                  </div>
                  <p className="text-sm text-muted-foreground">{report.profile}</p>
                  <span
                    className={cn(
                      "rounded-full border px-3 py-1 text-xs font-semibold tabular-nums",
                      overallBg(report.overall),
                      overallColor(report.overall),
                    )}
                  >
                    {report.overall}/100
                  </span>
                  <p className="text-xs text-muted-foreground whitespace-nowrap">{report.completedAt}</p>
                  <Link
                    href={`/relatorio/${report.responseId}`}
                    className="flex items-center gap-1.5 rounded-lg bg-primary/10 px-3 py-1.5 text-xs font-medium text-primary hover:bg-primary/20 transition-colors"
                  >
                    Ver Mapa
                    <ArrowRight className="size-3" />
                  </Link>
                </div>
              ))}
            </div>
          )}
        </div>
      </Section>
    </Container>
  );
}
