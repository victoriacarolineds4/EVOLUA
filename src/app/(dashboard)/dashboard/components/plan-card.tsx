import { Progress } from "@/components/ui/progress";
import type { Company } from "@/types/database.types";

export const PLAN_LABELS: Record<string, string> = {
  starter: "Starter",
  growth: "Growth",
  enterprise: "Enterprise",
};

interface PlanCardProps {
  company?: Company | null;
}

export function PlanCard({ company }: PlanCardProps) {
  const planLabel = PLAN_LABELS[company?.plan ?? ""] ?? (company?.plan ?? "—");
  const total = company?.licenses_total ?? 0;
  const used = company?.licenses_used ?? 0;
  const available = total - used;
  const percent = total > 0 ? Math.round((used / total) * 100) : 0;

  return (
    <div className="rounded-2xl border border-border bg-card p-8">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-sm font-medium text-muted-foreground">Plano atual</p>
          <p className="mt-1 font-heading text-xl font-medium text-foreground">{planLabel}</p>
        </div>
        <span className="rounded-full bg-success/10 px-3 py-1 text-xs font-medium text-success">
          Ativo
        </span>
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
  );
}
