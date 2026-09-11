import type { PillarScore } from "@/lib/motor/types";
import { ScoreRing } from "@/components/ui/score-ring";

interface PillarCardProps {
  pillar: PillarScore;
}

export function PillarCard({ pillar }: PillarCardProps) {
  return (
    <div className="rounded-xl border border-border bg-card p-5">
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
    </div>
  );
}
