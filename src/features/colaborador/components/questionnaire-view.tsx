"use client";

import { useState, useTransition } from "react";
import { Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { saveAnswerAction } from "@/features/colaborador/actions/answer.actions";
import { JourneyHeader } from "./journey-header";
import { QuestionCard } from "./question-card";
import { AlternativeCard } from "./alternative-card";
import type { Question, Alternative } from "@/types/database.types";

interface QuestionnaireViewProps {
  responseId: string;
  currentQuestion: number;
  answeredCount: number;
  question: Question;
  alternatives: Alternative[];
  totalQuestions: number;
  token: string;
}

export function QuestionnaireView({
  responseId,
  currentQuestion,
  answeredCount,
  question,
  alternatives,
  totalQuestions,
  token,
}: QuestionnaireViewProps) {
  const [selected, setSelected] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);

  function handleContinue() {
    if (!selected || isPending) return;
    setError(null);
    startTransition(async () => {
      const result = await saveAnswerAction(
        responseId,
        question.id,
        selected,
        token,
      );
      if (result?.error) setError(result.error);
      // em sucesso, o Server Action faz redirect → página re-renderiza com próxima questão
    });
  }

  return (
    <div className="min-h-dvh bg-background px-4 py-10">
      <div className="mx-auto max-w-2xl space-y-6">
        {/* Branding */}
        <p className="text-center text-sm font-semibold tracking-tight text-primary">
          EVOLUA
        </p>

        {/* Progresso */}
        <JourneyHeader
          currentQuestion={currentQuestion}
          totalQuestions={totalQuestions}
          answeredCount={answeredCount}
        />

        {/* Questão */}
        <QuestionCard orderIndex={question.order_index} title={question.title} />

        {/* Alternativas */}
        <div className="grid gap-3">
          {alternatives.map((alt) => (
            <AlternativeCard
              key={alt.id}
              title={alt.title}
              description={alt.description}
              isSelected={selected === alt.id}
              disabled={isPending}
              onClick={() => setSelected(alt.id)}
            />
          ))}
        </div>

        {error && (
          <p className="rounded-lg bg-destructive/10 px-3 py-2.5 text-sm text-destructive">
            {error}
          </p>
        )}

        {/* Navegação */}
        <div className="flex gap-3">
          <Button
            variant="outline"
            size="lg"
            disabled
            className="gap-2"
            title="Navegação retroativa disponível em breve"
          >
            ← Anterior
          </Button>
          <Button
            className="flex-1 gap-2"
            size="lg"
            disabled={!selected || isPending}
            onClick={handleContinue}
          >
            {isPending && <Loader2 className="size-4 animate-spin" />}
            Próxima →
          </Button>
        </div>
      </div>
    </div>
  );
}
