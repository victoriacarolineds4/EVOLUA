"use client";

import { useState, useTransition } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { ArrowLeft, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { createResponseAction } from "@/features/colaborador/actions/response.actions";

const schema = z.object({
  name: z
    .string()
    .min(5, "Nome deve ter no mínimo 5 caracteres")
    .max(120, "Nome muito longo")
    .regex(/[^0-9]/, "Nome não pode conter apenas números"),
  role: z
    .string()
    .min(2, "Cargo deve ter no mínimo 2 caracteres")
    .max(80, "Cargo muito longo")
    .regex(/[^0-9]/, "Cargo não pode conter apenas números"),
});

type FormData = z.infer<typeof schema>;

interface ParticipantFormProps {
  applicationId: string;
  token: string;
  onBack: () => void;
}

export function ParticipantForm({
  applicationId,
  token,
  onBack,
}: ParticipantFormProps) {
  const [isPending, startTransition] = useTransition();
  const [serverError, setServerError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormData>({ resolver: zodResolver(schema) });

  function onSubmit(data: FormData) {
    setServerError(null);
    startTransition(async () => {
      const result = await createResponseAction(
        applicationId,
        token,
        data.name,
        data.role,
      );
      if (result?.error) setServerError(result.error);
      // em caso de sucesso, o Server Action faz redirect — sem código aqui
    });
  }

  return (
    <div className="w-full max-w-lg space-y-8">
      {/* Branding */}
      <div className="text-center">
        <p className="text-2xl font-semibold tracking-tight text-primary">EVOLUA</p>
      </div>

      {/* Form card */}
      <div className="rounded-2xl border border-border bg-card p-8 shadow-elevated">
        <div className="mb-6 space-y-1">
          <h2 className="text-lg font-semibold text-foreground">
            Antes de começar
          </h2>
          <p className="text-sm text-muted-foreground">
            Precisamos de algumas informações básicas.
          </p>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          {/* Nome */}
          <div className="space-y-1.5">
            <label
              className="text-sm font-medium text-foreground"
              htmlFor="participant-name"
            >
              Nome completo
            </label>
            <Input
              id="participant-name"
              placeholder="Seu nome completo"
              autoComplete="name"
              autoFocus
              disabled={isPending}
              {...register("name")}
              className={errors.name ? "border-destructive" : ""}
            />
            {errors.name && (
              <p className="text-xs text-destructive">{errors.name.message}</p>
            )}
          </div>

          {/* Cargo */}
          <div className="space-y-1.5">
            <label
              className="text-sm font-medium text-foreground"
              htmlFor="participant-role"
            >
              Cargo
            </label>
            <Input
              id="participant-role"
              placeholder="Ex: Analista de Marketing"
              autoComplete="organization-title"
              disabled={isPending}
              {...register("role")}
              className={errors.role ? "border-destructive" : ""}
            />
            {errors.role && (
              <p className="text-xs text-destructive">{errors.role.message}</p>
            )}
          </div>

          {serverError && (
            <p className="rounded-lg bg-destructive/10 px-3 py-2.5 text-sm text-destructive">
              {serverError}
            </p>
          )}

          <div className="flex gap-3 pt-1">
            <Button
              type="button"
              variant="ghost"
              onClick={onBack}
              disabled={isPending}
              className="gap-1.5"
            >
              <ArrowLeft className="size-4" />
              Voltar
            </Button>
            <Button type="submit" className="flex-1" disabled={isPending}>
              {isPending && <Loader2 className="mr-2 size-4 animate-spin" />}
              Continuar
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
