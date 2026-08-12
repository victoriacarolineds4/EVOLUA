import { cn } from "@/lib/utils";
import type { PillarScore } from "@/lib/motor/types";

interface PillarCardProps {
  pillar: PillarScore;
}

function scoreColor(score: number) {
  if (score >= 80) return "text-emerald-400";
  if (score >= 65) return "text-amber-400";
  return "text-rose-400";
}

function barColor(score: number) {
  if (score >= 80) return "bg-emerald-400";
  if (score >= 65) return "bg-amber-400";
  return "bg-rose-400";
}

export function PillarCard({ pillar }: PillarCardProps) {
  return (
    <div className="rounded-xl border border-border bg-card p-5 space-y-4">
      <div className="flex items-start justify-between gap-2">
        <div>
          <p className="text-xs font-medium uppercase tracking-widest text-primary mb-0.5">
            Pilar {pillar.number}
          </p>
          <h3 className="text-sm font-semibold text-foreground leading-snug">
            {pillar.name}
          </h3>
        </div>
        <span className={cn("text-2xl font-bold tabular-nums", scoreColor(pillar.score))}>
          {pillar.score}
        </span>
      </div>

      {/* Barra principal */}
      <div className="h-1.5 rounded-full bg-muted overflow-hidden">
        <div
          className={cn("h-full rounded-full transition-all", barColor(pillar.score))}
          style={{ width: `${pillar.score}%` }}
        />
      </div>

      {/* Top indicadores */}
      <div className="space-y-2">
        {pillar.indicators.slice(0, 3).map((ind) => (
          <div key={ind.code} className="flex items-center gap-2">
            <div className="h-1 flex-1 rounded-full bg-muted overflow-hidden">
              <div
                className="h-full rounded-full bg-primary/40"
                style={{ width: `${ind.score}%` }}
              />
            </div>
            <span className="text-xs text-muted-foreground w-24 truncate shrink-0">
              {ind.name}
            </span>
            <span className="text-xs font-medium text-foreground w-7 text-right shrink-0">
              {ind.score}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
