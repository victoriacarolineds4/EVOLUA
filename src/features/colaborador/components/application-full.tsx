import { Users } from "lucide-react";

export function ApplicationFull() {
  return (
    <div className="flex min-h-dvh flex-col items-center justify-center bg-background px-4">
      <div className="w-full max-w-md space-y-6 text-center">
        <div className="mx-auto flex size-16 items-center justify-center rounded-2xl border border-dashed border-border bg-muted/40">
          <Users className="size-7 text-muted-foreground" />
        </div>
        <div className="space-y-2">
          <h1 className="text-xl font-semibold text-foreground">
            Limite atingido
          </h1>
          <p className="text-sm text-muted-foreground">
            Esta aplicação já atingiu o número máximo de participantes. Entre em contato com o responsável caso acredite que isto seja um engano.
          </p>
        </div>
      </div>
    </div>
  );
}
