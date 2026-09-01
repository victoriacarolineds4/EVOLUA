"use client";

import { useState, useTransition } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Loader2 } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { updateProfileNameAction } from "@/features/configuracoes/actions/profile.actions";

const schema = z.object({
  fullName: z.string().min(2, "Informe um nome com pelo menos 2 caracteres"),
});

type FormData = z.infer<typeof schema>;

interface ProfileNameFormProps {
  initialFullName: string;
}

export function ProfileNameForm({ initialFullName }: ProfileNameFormProps) {
  const [isPending, startTransition] = useTransition();
  const [serverError, setServerError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isDirty },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: { fullName: initialFullName },
  });

  function onSubmit(data: FormData) {
    setServerError(null);
    startTransition(async () => {
      const result = await updateProfileNameAction(data.fullName);
      if (result?.error) {
        setServerError(result.error);
      } else {
        toast.success("Nome atualizado.");
      }
    });
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-1.5">
      <label className="text-sm font-medium text-foreground" htmlFor="fullName">
        Nome
      </label>
      <div className="flex gap-2">
        <Input
          id="fullName"
          disabled={isPending}
          {...register("fullName")}
          className={errors.fullName ? "border-destructive" : ""}
        />
        <Button type="submit" variant="outline" disabled={isPending || !isDirty}>
          {isPending && <Loader2 className="mr-1.5 size-4 animate-spin" />}
          Salvar
        </Button>
      </div>
      {errors.fullName && (
        <p className="text-xs text-destructive">{errors.fullName.message}</p>
      )}
      {serverError && <p className="text-xs text-destructive">{serverError}</p>}
    </form>
  );
}
