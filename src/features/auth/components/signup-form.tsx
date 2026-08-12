"use client";

import { useState, useTransition } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import Link from "next/link";
import { Eye, EyeOff, Loader2, MailCheck } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { signUpAction } from "@/features/auth/actions/auth.actions";

const schema = z.object({
  fullName: z.string().min(2, "Informe seu nome"),
  companyName: z.string().min(2, "Informe o nome da empresa"),
  email: z.string().email("E-mail inválido"),
  password: z.string().min(8, "A senha deve ter ao menos 8 caracteres"),
});

type FormData = z.infer<typeof schema>;

export function SignUpForm() {
  const [isPending, startTransition] = useTransition();
  const [serverError, setServerError] = useState<string | null>(null);
  const [showPassword, setShowPassword] = useState(false);
  const [confirmationEmail, setConfirmationEmail] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormData>({ resolver: zodResolver(schema) });

  function onSubmit(data: FormData) {
    setServerError(null);
    startTransition(async () => {
      const result = await signUpAction(
        data.fullName,
        data.companyName,
        data.email,
        data.password,
      );
      if (result?.error) setServerError(result.error);
      else if (result?.needsConfirmation) setConfirmationEmail(data.email);
      // em sucesso com sessão, a Server Action faz redirect para /dashboard
    });
  }

  if (confirmationEmail) {
    return (
      <div className="space-y-4 text-center">
        <div className="mx-auto flex size-14 items-center justify-center rounded-full bg-success/15">
          <MailCheck className="size-7 text-success" />
        </div>
        <div className="space-y-1.5">
          <h3 className="font-heading text-base font-medium text-foreground">
            Confirme seu e-mail
          </h3>
          <p className="text-sm text-muted-foreground">
            Enviamos um link de confirmação para{" "}
            <span className="font-medium text-foreground">{confirmationEmail}</span>.
            Acesse-o para ativar sua conta e entrar.
          </p>
        </div>
        <Link
          href="/login"
          className="inline-block text-sm text-primary hover:underline"
        >
          Voltar para o login
        </Link>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div className="space-y-1.5">
        <label className="text-sm font-medium text-foreground" htmlFor="fullName">
          Seu nome
        </label>
        <Input
          id="fullName"
          type="text"
          placeholder="Como podemos te chamar"
          autoComplete="name"
          autoFocus
          disabled={isPending}
          {...register("fullName")}
          className={errors.fullName ? "border-destructive" : ""}
        />
        {errors.fullName && (
          <p className="text-xs text-destructive">{errors.fullName.message}</p>
        )}
      </div>

      <div className="space-y-1.5">
        <label className="text-sm font-medium text-foreground" htmlFor="companyName">
          Nome da empresa
        </label>
        <Input
          id="companyName"
          type="text"
          placeholder="Sua empresa"
          autoComplete="organization"
          disabled={isPending}
          {...register("companyName")}
          className={errors.companyName ? "border-destructive" : ""}
        />
        {errors.companyName && (
          <p className="text-xs text-destructive">{errors.companyName.message}</p>
        )}
      </div>

      <div className="space-y-1.5">
        <label className="text-sm font-medium text-foreground" htmlFor="email">
          E-mail
        </label>
        <Input
          id="email"
          type="email"
          placeholder="voce@empresa.com"
          autoComplete="email"
          disabled={isPending}
          {...register("email")}
          className={errors.email ? "border-destructive" : ""}
        />
        {errors.email && (
          <p className="text-xs text-destructive">{errors.email.message}</p>
        )}
      </div>

      <div className="space-y-1.5">
        <label className="text-sm font-medium text-foreground" htmlFor="password">
          Senha
        </label>
        <div className="relative">
          <Input
            id="password"
            type={showPassword ? "text" : "password"}
            placeholder="Mínimo de 8 caracteres"
            autoComplete="new-password"
            disabled={isPending}
            {...register("password")}
            className={errors.password ? "border-destructive pr-10" : "pr-10"}
          />
          <button
            type="button"
            tabIndex={-1}
            onClick={() => setShowPassword((v) => !v)}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
          >
            {showPassword ? <EyeOff className="size-4" /> : <Eye className="size-4" />}
          </button>
        </div>
        {errors.password && (
          <p className="text-xs text-destructive">{errors.password.message}</p>
        )}
      </div>

      {serverError && (
        <p className="rounded-lg bg-destructive/10 px-3 py-2.5 text-sm text-destructive">
          {serverError}
        </p>
      )}

      <Button type="submit" className="w-full" disabled={isPending}>
        {isPending && <Loader2 className="mr-2 size-4 animate-spin" />}
        Criar conta
      </Button>

      <div className="text-center">
        <span className="text-sm text-muted-foreground">Já tem conta? </span>
        <Link
          href="/login"
          className="text-sm text-primary hover:underline"
        >
          Entrar
        </Link>
      </div>
    </form>
  );
}
