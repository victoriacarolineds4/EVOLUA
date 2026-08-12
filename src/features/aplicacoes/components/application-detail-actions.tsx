"use client";

import { useState } from "react";
import { Copy, Check, X } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { CloseApplicationDialog } from "@/features/aplicacoes/components/close-application-dialog";
import type { Application } from "@/types/database.types";

interface ApplicationDetailActionsProps {
  application: Application;
  appUrl: string;
}

export function ApplicationDetailActions({ application, appUrl }: ApplicationDetailActionsProps) {
  const [closeOpen, setCloseOpen] = useState(false);
  const [copied, setCopied] = useState(false);

  const publicLink = `${appUrl}/e/${application.token}`;

  async function handleCopyLink() {
    try {
      await navigator.clipboard.writeText(publicLink);
      setCopied(true);
      toast.success("Link copiado com sucesso.");
      setTimeout(() => setCopied(false), 2000);
    } catch {
      toast.error("Não foi possível copiar o link.");
    }
  }

  return (
    <>
      <div className="flex shrink-0 items-center gap-2">
        <Button variant="outline" size="sm" onClick={handleCopyLink}>
          {copied ? (
            <Check className="mr-1.5 size-3.5 text-success" />
          ) : (
            <Copy className="mr-1.5 size-3.5" />
          )}
          {copied ? "Copiado" : "Copiar link"}
        </Button>

        {application.status === "active" && (
          <Button
            variant="ghost"
            size="sm"
            className="text-destructive hover:bg-destructive/10 hover:text-destructive"
            onClick={() => setCloseOpen(true)}
          >
            <X className="mr-1.5 size-3.5" />
            Encerrar
          </Button>
        )}
      </div>

      <CloseApplicationDialog
        applicationId={application.id}
        applicationName={application.name}
        open={closeOpen}
        onOpenChange={setCloseOpen}
      />
    </>
  );
}
