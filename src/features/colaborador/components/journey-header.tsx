import { ProgressBar } from "./progress-bar";

interface JourneyHeaderProps {
  currentQuestion: number;
  totalQuestions: number;
  answeredCount: number; // número de questões já respondidas (0..total)
}

export function JourneyHeader({
  currentQuestion,
  totalQuestions,
  answeredCount,
}: JourneyHeaderProps) {
  const percent =
    totalQuestions > 0
      ? Math.round((answeredCount / totalQuestions) * 100)
      : 0;

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <p className="text-sm font-semibold text-foreground">
          Sua Jornada de Desenvolvimento
        </p>
        <span className="text-sm text-muted-foreground">
          {currentQuestion} de {totalQuestions}
        </span>
      </div>
      <ProgressBar value={percent} />
    </div>
  );
}
