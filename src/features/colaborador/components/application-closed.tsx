import { LockKeyhole } from "lucide-react";

export function ApplicationClosed() {
  return (
    <div className="flex min-h-dvh flex-col items-center justify-center bg-background px-4">
      <div className="w-full max-w-md space-y-6 text-center">
        <div className="mx-auto flex size-16 items-center justify-center rounded-2xl border border-dashed border-border bg-muted/40">
          <LockKeyhole className="size-7 text-muted-foreground" />
        </div>
        <div className="space-y-2">
          <h1 className="text-xl font-semibold text-foreground">
            Aplicação encerrada
          </h1>
          <p className="text-sm text-muted-foreground">
            Esta aplicação foi encerrada e não está aceitando novas respostas. Entre em contato com o responsável para mais informações.
          </p>
        </div>
      </div>
    </div>
  );
}
