import type { Metadata } from "next";
import { Suspense } from "react";
import { RecoverForm } from "@/features/auth/components/recover-form";

export const metadata: Metadata = {
  title: "Recuperar senha — EVOLUA",
};

export default function RecoverPage() {
  return (
    <div className="space-y-8">
      <div className="space-y-2 text-center">
        <h1 className="font-heading text-2xl font-medium tracking-tight text-primary">EVOLUA</h1>
        <p className="text-sm text-muted-foreground">
          Diagnóstico e desenvolvimento humano
        </p>
      </div>

      <div className="rounded-2xl border border-border bg-card p-8 shadow-elevated">
        <div className="mb-6 space-y-1">
          <h2 className="font-heading text-lg font-medium">Recuperar senha</h2>
          <p className="text-sm text-muted-foreground">
            Enviaremos um link para redefinir sua senha
          </p>
        </div>

        <Suspense fallback={null}>
          <RecoverForm />
        </Suspense>
      </div>
    </div>
  );
}
