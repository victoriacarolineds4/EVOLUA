import { Unlink } from "lucide-react";

export function InvalidApplication() {
  return (
    <div className="flex min-h-dvh flex-col items-center justify-center bg-background px-4">
      <div className="w-full max-w-md space-y-6 text-center">
        <div className="mx-auto flex size-16 items-center justify-center rounded-2xl border border-dashed border-border bg-muted/40">
          <Unlink className="size-7 text-muted-foreground" />
        </div>
        <div className="space-y-2">
          <h1 className="text-xl font-semibold text-foreground">
            Link não encontrado
          </h1>
          <p className="text-sm text-muted-foreground">
            Este link não existe ou foi removido. Verifique se o endereço está correto e tente novamente.
          </p>
        </div>
      </div>
    </div>
  );
}
