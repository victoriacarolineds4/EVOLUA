import type { Metadata } from "next";
import Image from "next/image";
import { LoginForm } from "@/features/auth/components/login-form";

export const metadata: Metadata = {
  title: "Entrar — EVOLUA",
};

export default function LoginPage() {
  return (
    <div className="space-y-8">
      <div className="flex justify-center">
        <Image src="/logoevolua.png" alt="EVOLUA" width={1774} height={887} className="h-auto w-64" priority />
      </div>

      <div className="rounded-2xl border border-border bg-card p-8 shadow-elevated">
        <div className="mb-6 space-y-1">
          <h2 className="font-heading text-lg font-medium">Bem-vindo de volta</h2>
          <p className="text-sm text-muted-foreground">
            Acesse sua conta para continuar
          </p>
        </div>

        <LoginForm />
      </div>
    </div>
  );
}
