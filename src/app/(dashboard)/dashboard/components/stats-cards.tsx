import { Users, CheckCircle2, Clock } from "lucide-react";
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

  const items = [
    {
      // Valor principal = métrica de CONSUMO (licenças reservadas na criação
      // da aplicação, Opção A) — não a contagem de respostas, para não
      // divergir do saldo de licenças mostrado no card de Plano.
      label: "Colaboradores",
      value: licensesUsed,
      icon: Users,
      sub:
        stats.totalCollaborators === 1
          ? "1 pessoa respondeu"
          : `${stats.totalCollaborators} pessoas responderam`,
    },
    {
      label: "Testes Realizados",
      value: stats.completedTests,
      icon: CheckCircle2,
      sub: `${completionRate}% de conclusão`,
    },
    {
      label: "Testes Pendentes",
      value: stats.pendingTests,
      icon: Clock,
      sub: "Aguardando resposta",
    },
  ];

  return (
    <div className="grid gap-4 sm:grid-cols-3">
      {items.map((item) => {
        const Icon = item.icon;
        return (
          <div
            key={item.label}
            className="rounded-xl border border-border bg-card p-5 space-y-3"
          >
            <div className="flex items-center justify-between">
              <p className="text-sm font-medium text-muted-foreground">{item.label}</p>
              <div className="flex size-8 items-center justify-center rounded-lg bg-primary/10">
                <Icon className="size-4 text-primary" />
              </div>
            </div>
            <p className="text-3xl font-bold tabular-nums text-foreground">{item.value}</p>
            <p className="text-xs text-muted-foreground">{item.sub}</p>
          </div>
        );
      })}
    </div>
  );
}
