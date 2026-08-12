"use client";

import { useState, useTransition } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { ArrowLeft, CheckCircle2, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { recoverPasswordAction } from "@/features/auth/actions/auth.actions";

const schema = z.object({
  email: z.string().email("E-mail inválido"),
});

type FormData = z.infer<typeof schema>;

export function RecoverForm() {
  const searchParams = useSearchParams();
  const expired = searchParams.get("expirado") === "1";
  const [isPending, startTransition] = useTransition();
  const [serverError, setServerError] = useState<string | null>(null);
  const [sent, setSent] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormData>({ resolver: zodResolver(schema) });

  function onSubmit(data: FormData) {
    setServerError(null);
    startTransition(async () => {
      const result = await recoverPasswordAction(data.email);
      if (result?.error) {
        setServerError(result.error);
      } else {
        setSent(true);
      }
    });
  }

  if (sent) {
    return (
      <div className="space-y-4 text-center">
        <div className="flex justify-center">
          <CheckCircle2 className="size-12 text-primary" />
        </div>
        <div>
          <p className="font-medium">E-mail enviado</p>
          <p className="mt-1 text-sm text-muted-foreground">
            Verifique sua caixa de entrada e siga as instruções para redefinir sua senha.
          </p>
        </div>
        <Link href="/login">
          <Button variant="outline" className="w-full">
            <ArrowLeft className="mr-2 size-4" />
            Voltar para o login
          </Button>
        </Link>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      {expired && (
        <p className="rounded-lg bg-amber-500/10 px-3 py-2.5 text-sm text-amber-600 dark:text-amber-400">
          Esse link de recuperação expirou ou já foi usado. Solicite um novo abaixo.
        </p>
      )}

      <div className="space-y-1.5">
        <label className="text-sm font-medium text-foreground" htmlFor="email">
          E-mail
        </label>
        <Input
          id="email"
          type="email"
          placeholder="voce@empresa.com"
          autoComplete="email"
          autoFocus
          disabled={isPending}
          {...register("email")}
          className={errors.email ? "border-destructive" : ""}
        />
        {errors.email && (
          <p className="text-xs text-destructive">{errors.email.message}</p>
        )}
      </div>

      {serverError && (
        <p className="rounded-lg bg-destructive/10 px-3 py-2.5 text-sm text-destructive">
          {serverError}
        </p>
      )}

      <Button type="submit" className="w-full" disabled={isPending}>
        {isPending && <Loader2 className="mr-2 size-4 animate-spin" />}
        Enviar link de recuperação
      </Button>

      <div className="text-center">
        <Link
          href="/login"
          className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
        >
          <ArrowLeft className="size-3.5" />
          Voltar para o login
        </Link>
      </div>
    </form>
  );
}
