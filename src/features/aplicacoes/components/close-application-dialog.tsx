"use client";

import { useState, useTransition } from "react";
import { Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { closeApplicationAction } from "@/features/aplicacoes/actions/applications.actions";

interface CloseApplicationDialogProps {
  applicationId: string;
  applicationName: string;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function CloseApplicationDialog({
  applicationId,
  applicationName,
  open,
  onOpenChange,
}: CloseApplicationDialogProps) {
  const [isPending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);

  function handleConfirm() {
    setError(null);
    startTransition(async () => {
      const result = await closeApplicationAction(applicationId);
      if (result?.error) {
        setError(result.error);
      } else {
        onOpenChange(false);
      }
    });
  }

  return (
    <Dialog open={open} onOpenChange={(v) => !isPending && onOpenChange(v)}>
      <DialogContent className="sm:max-w-sm">
        <DialogHeader>
          <DialogTitle>Encerrar aplicação</DialogTitle>
        </DialogHeader>

        <div className="space-y-3">
          <p className="text-sm text-muted-foreground">
            Tem certeza que deseja encerrar{" "}
            <span className="font-medium text-foreground">{applicationName}</span>?
          </p>
          <p className="text-sm text-muted-foreground">
            O link deixará de aceitar novas respostas. Esta ação não pode ser desfeita.
          </p>
        </div>

        {error && (
          <p className="rounded-lg bg-destructive/10 px-3 py-2.5 text-sm text-destructive">
            {error}
          </p>
        )}

        <DialogFooter>
          <Button
            variant="outline"
            onClick={() => onOpenChange(false)}
            disabled={isPending}
          >
            Cancelar
          </Button>
          <Button
            variant="destructive"
            onClick={handleConfirm}
            disabled={isPending}
          >
            {isPending && <Loader2 className="mr-2 size-4 animate-spin" />}
            Encerrar
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
