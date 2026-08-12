import Link from "next/link";
import { ArrowRight } from "lucide-react";
import type { ReportListItem } from "@/services/motor/motor.service";
import { cn } from "@/lib/utils";

function overallColor(score: number) {
  if (score >= 80) return "text-emerald-400";
  if (score >= 65) return "text-amber-400";
  return "text-rose-400";
}

export function RecentResults({ results }: { results: ReportListItem[] }) {
  return (
    <div className="rounded-2xl border border-border bg-card overflow-hidden">
      <div className="flex items-center justify-between border-b border-border px-6 py-4">
        <div>
          <h3 className="text-sm font-semibold text-foreground">Últimos Resultados</h3>
          <p className="text-xs text-muted-foreground mt-0.5">Mapas de Desenvolvimento concluídos</p>
        </div>
        <Link
          href="/relatorio"
          className="flex items-center gap-1.5 text-xs font-medium text-primary hover:text-primary/80 transition-colors"
        >
          Ver todos
          <ArrowRight className="size-3.5" />
        </Link>
      </div>

      {results.length === 0 ? (
        <div className="px-6 py-8 text-center">
          <p className="text-sm text-muted-foreground">
            Nenhum resultado ainda — os mapas aparecem aqui quando os colaboradores concluem.
          </p>
        </div>
      ) : (
        <div className="divide-y divide-border">
          {results.map((r) => (
            <div key={r.responseId} className="flex items-center gap-4 px-6 py-4">
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-foreground truncate">{r.name}</p>
                <p className="text-xs text-muted-foreground truncate">{r.role}</p>
              </div>

              <p className="hidden sm:block text-xs text-muted-foreground whitespace-nowrap">
                {r.completedAt}
              </p>

              <span className={cn("text-lg font-bold tabular-nums shrink-0", overallColor(r.overall))}>
                {r.overall}
              </span>

              <Link
                href={`/relatorio/${r.responseId}`}
                className="shrink-0 rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-muted-foreground hover:border-primary/40 hover:text-primary transition-colors"
              >
                Ver mapa
              </Link>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
