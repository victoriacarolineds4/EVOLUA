"use client";

import { useState, useTransition } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Plus, Loader2, Info } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { createApplicationAction } from "@/features/aplicacoes/actions/applications.actions";

interface NewApplicationModalProps {
  availableLicenses: number;
}

function buildSchema(max: number) {
  return z.object({
    name: z
      .string()
      .min(2, "Mínimo de 2 caracteres")
      .max(80, "Máximo de 80 caracteres"),
    licenseLimit: z
      .number({ message: "Informe um número" })
      .int("Deve ser um número inteiro")
      .min(1, "Mínimo de 1 colaborador")
      .max(max > 0 ? max : 1, `Máximo de ${max} licença${max !== 1 ? "s" : ""} ${max !== 1 ? "disponíveis" : "disponível"}`),
  });
}

type FormData = z.infer<ReturnType<typeof buildSchema>>;

export function NewApplicationModal({ availableLicenses }: NewApplicationModalProps) {
  const [open, setOpen] = useState(false);
  const [isPending, startTransition] = useTransition();
  const [serverError, setServerError] = useState<string | null>(null);

  const schema = buildSchema(availableLicenses);

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: { licenseLimit: undefined },
  });

  function handleOpen() {
    reset();
    setServerError(null);
    setOpen(true);
  }

  function handleClose() {
    if (isPending) return;
    setOpen(false);
    reset();
    setServerError(null);
  }

  function onSubmit(data: FormData) {
    setServerError(null);
    startTransition(async () => {
      const result = await createApplicationAction(data.name, data.licenseLimit);
      if (result?.error) {
        setServerError(result.error);
      } else {
        setOpen(false);
        reset();
      }
    });
  }

  return (
    <>
      <Button onClick={handleOpen}>
        <Plus className="mr-1.5 size-4" />
        Nova Aplicação
      </Button>

      <Dialog open={open} onOpenChange={(v) => !isPending && setOpen(v)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Nova Aplicação</DialogTitle>
          </DialogHeader>

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
            {/* Nome */}
            <div className="space-y-1.5">
              <label className="text-sm font-medium text-foreground" htmlFor="app-name">
                Nome da aplicação
              </label>
              <Input
                id="app-name"
                placeholder="Ex: Cultura Julho"
                autoComplete="off"
                autoFocus
                disabled={isPending}
                {...register("name")}
                className={errors.name ? "border-destructive" : ""}
              />
              {errors.name && (
                <p className="text-xs text-destructive">{errors.name.message}</p>
              )}
            </div>

            {/* Licenças */}
            <div className="space-y-1.5">
              <label className="text-sm font-medium text-foreground" htmlFor="license-limit">
                Quantidade de colaboradores
              </label>
              <Input
                id="license-limit"
                type="number"
                min={1}
                max={availableLicenses}
                placeholder={`Máximo: ${availableLicenses}`}
                disabled={isPending || availableLicenses === 0}
                {...register("licenseLimit", { valueAsNumber: true })}
                className={errors.licenseLimit ? "border-destructive" : ""}
              />
              {errors.licenseLimit ? (
                <p className="text-xs text-destructive">{errors.licenseLimit.message}</p>
              ) : (
                <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                  <Info className="size-3.5 shrink-0" />
                  <span>
                    {availableLicenses === 0
                      ? "Nenhuma licença disponível. Atualize seu plano."
                      : `${availableLicenses} licença${availableLicenses !== 1 ? "s" : ""} ${availableLicenses !== 1 ? "disponíveis" : "disponível"} no seu plano.`}
                  </span>
                </div>
              )}
            </div>

            {serverError && (
              <p className="rounded-lg bg-destructive/10 px-3 py-2.5 text-sm text-destructive">
                {serverError}
              </p>
            )}

            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={handleClose}
                disabled={isPending}
              >
                Cancelar
              </Button>
              <Button
                type="submit"
                disabled={isPending || availableLicenses === 0}
              >
                {isPending && <Loader2 className="mr-2 size-4 animate-spin" />}
                Criar aplicação
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </>
  );
}
