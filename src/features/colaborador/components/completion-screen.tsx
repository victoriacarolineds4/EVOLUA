import { CheckCircle2 } from "lucide-react";

export function CompletionScreen() {
  return (
    <div className="flex min-h-dvh flex-col items-center justify-center bg-background px-4">
      <div className="w-full max-w-lg space-y-8">
        <div className="text-center">
          <p className="text-2xl font-semibold tracking-tight text-primary">
            EVOLUA
          </p>
        </div>

        <div className="rounded-2xl border border-border bg-card p-10 shadow-elevated text-center">
          <div className="mx-auto mb-6 flex size-16 items-center justify-center rounded-full bg-primary/15">
            <CheckCircle2 className="size-8 text-primary" />
          </div>
          <h1 className="text-2xl font-semibold text-foreground">
            Jornada Concluída!
          </h1>
          <p className="mt-3 text-sm leading-relaxed text-muted-foreground">
            Suas respostas foram registradas com sucesso.
          </p>
          <p className="mt-1.5 text-sm leading-relaxed text-muted-foreground">
            Aguarde o processamento do relatório.
          </p>
          <p className="mt-4 text-xs text-muted-foreground/50">
            Seu Mapa de Desenvolvimento estará disponível em breve.
          </p>
        </div>
      </div>
    </div>
  );
}
