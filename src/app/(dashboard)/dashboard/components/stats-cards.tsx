import { Users, Clock } from "lucide-react";
import { ScoreRing } from "@/components/ui/score-ring";
import type { DashboardStats } from "@/services/dashboard.service";

interface StatsCardsProps {
  stats: DashboardStats;
  licensesUsed: number;
}

export function StatsCards({ stats, licensesUsed }: StatsCardsProps) {
  const completionRate =
    stats.completedTests > 0
      ? Math.round((stats.completedTests / (stats.completedTests + stats.pendingTests)) * 100)
      : 0;

  return (
    <div className="grid gap-4 sm:grid-cols-3">
      <div className="rounded-xl border border-border bg-card p-5">
        <div className="flex items-center justify-between">
          <p className="text-sm font-medium text-muted-foreground">Colaboradores</p>
          <div className="flex size-8 items-center justify-center rounded-md bg-chip-violet/12">
            <Users className="size-4 text-chip-violet" />
          </div>
        </div>
        {/* Valor principal = métrica de CONSUMO (licenças reservadas na criação
            da aplicação, Opção A) — não a contagem de respostas, para não
            divergir do saldo de licenças mostrado no card de Plano. */}
        <p className="mt-3 font-heading text-3xl font-medium tabular-nums text-foreground">
          {licensesUsed}
        </p>
        <p className="mt-1 text-xs text-muted-foreground">
          {stats.totalCollaborators === 1
            ? "1 pessoa respondeu"
            : `${stats.totalCollaborators} pessoas responderam`}
        </p>
      </div>

      <div className="rounded-xl border border-border bg-card p-5">
        <div className="flex items-center justify-between gap-3">
          <div>
            <p className="text-sm font-medium text-muted-foreground">Testes Realizados</p>
            <p className="mt-3 font-heading text-3xl font-medium tabular-nums text-foreground">
              {stats.completedTests}
            </p>
          </div>
          <ScoreRing value={completionRate} size={48} strokeWidth={3} />
        </div>
        <p className="mt-1 text-xs text-muted-foreground">{completionRate}% de conclusão</p>
      </div>

      <div className="rounded-xl border border-border bg-card p-5">
        <div className="flex items-center justify-between">
          <p className="text-sm font-medium text-muted-foreground">Testes Pendentes</p>
          <div className="flex size-8 items-center justify-center rounded-md bg-chip-amber/12">
            <Clock className="size-4 text-chip-amber" />
          </div>
        </div>
        <p className="mt-3 font-heading text-3xl font-medium tabular-nums text-foreground">
          {stats.pendingTests}
        </p>
        <p className="mt-1 text-xs text-muted-foreground">Aguardando resposta</p>
      </div>
    </div>
  );
}
