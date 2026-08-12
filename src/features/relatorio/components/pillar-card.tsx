import type { PillarScore } from "@/lib/motor/types";
import { ScoreRing } from "@/components/ui/score-ring";

interface PillarCardProps {
  pillar: PillarScore;
}

export function PillarCard({ pillar }: PillarCardProps) {
  return (
    <div className="rounded-xl border border-border bg-card p-5 space-y-4">
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="text-xs font-medium uppercase tracking-widest text-primary mb-0.5">
            Pilar {pillar.number}
          </p>
          <h3 className="text-sm font-semibold text-foreground leading-snug">
            {pillar.name}
          </h3>
        </div>
        <ScoreRing value={pillar.score} size={44} strokeWidth={3} />
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
