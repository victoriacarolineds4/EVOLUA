import type { Confidence, PillarScore } from "@/lib/motor/types";
import { ScoreRing } from "@/components/ui/score-ring";

interface PillarCardProps {
  pillar: PillarScore;
}

const CONFIDENCE_LABEL: Record<Confidence, string> = {
  insuficiente: "Dados insuficientes",
  baixa: "Confiança baixa",
  moderada: "Confiança moderada",
  alta: "Confiança alta",
};

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
        {pillar.hasScore ? (
          <ScoreRing value={pillar.score} size={44} strokeWidth={3} />
        ) : (
          <div className="flex size-11 shrink-0 items-center justify-center rounded-full border border-dashed border-border text-[9px] leading-tight text-muted-foreground text-center px-1">
            sem dados
          </div>
        )}
      </div>
      {pillar.confidence !== "alta" && (
        <p className="mt-3 border-t border-dashed border-border pt-2 text-[11px] text-muted-foreground">
          {CONFIDENCE_LABEL[pillar.confidence]}
          {pillar.hasScore && ` · ${pillar.indicatorsWithScore}/5 indicadores com evidência`}
        </p>
      )}
    </div>
  );
}
