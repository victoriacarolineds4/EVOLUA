import type { Metadata } from "next";
import Link from "next/link";
import { ArrowLeft, FileBarChart2 } from "lucide-react";
import { Container } from "@/components/layout/container";
import { createClient } from "@/lib/supabase/server";
import { getReportForResponse } from "@/services/motor/motor.service";
import { MotorReport } from "@/features/relatorio/components/motor-report";

export const metadata: Metadata = {
  title: "Mapa de Desenvolvimento — EVOLUA",
};

interface PageProps {
  params: Promise<{ id: string }>;
}

export default async function RelatorioPage({ params }: PageProps) {
  const { id } = await params;
  const supabase = await createClient();
  const report = await getReportForResponse(supabase, id);

  if (!report) {
    return (
      <Container>
        <div className="py-8 space-y-8">
          <Link
            href="/relatorio"
            className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
          >
            <ArrowLeft className="size-4" />
            Voltar para Relatórios
          </Link>
          <div className="rounded-2xl border border-dashed border-border p-12 text-center">
            <FileBarChart2 className="mx-auto mb-3 size-8 text-muted-foreground/50" />
            <p className="text-sm font-medium text-foreground">
              Relatório indisponível
            </p>
            <p className="mt-1 text-sm text-muted-foreground">
              Este colaborador ainda não concluiu o diagnóstico, ou o link não é válido.
            </p>
          </div>
        </div>
      </Container>
    );
  }

  return <MotorReport report={report} />;
}
