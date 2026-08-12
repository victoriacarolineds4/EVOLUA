"use client";

import { useState } from "react";
import { Copy, ExternalLink, X, Check } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { CloseApplicationDialog } from "@/features/aplicacoes/components/close-application-dialog";
import type { Application } from "@/types/database.types";

const STATUS_CONFIG = {
  draft: {
    label: "Rascunho",
    className: "bg-muted text-muted-foreground border-muted",
  },
  active: {
    label: "Ativa",
    className: "bg-primary/15 text-primary border-primary/30",
  },
  closed: {
    label: "Encerrada",
    className: "bg-destructive/15 text-destructive border-destructive/30",
  },
} as const;

interface ApplicationCardProps {
  application: Application;
  appUrl: string;
}

export function ApplicationCard({ application, appUrl }: ApplicationCardProps) {
  const [closeOpen, setCloseOpen] = useState(false);
  const [copied, setCopied] = useState(false);

  const progress =
    application.license_limit > 0
      ? Math.round((application.responses_count / application.license_limit) * 100)
      : 0;

  const publicLink = `${appUrl}/e/${application.token}`;
  const status = STATUS_CONFIG[application.status];

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
      <div className="group flex flex-col gap-5 rounded-2xl border border-border bg-card p-6 transition-shadow hover:shadow-elevated">
        {/* Header */}
        <div className="flex items-start justify-between gap-3">
          <h3 className="font-semibold leading-tight text-foreground">
            {application.name}
          </h3>
          <span
            className={`inline-flex shrink-0 items-center rounded-full border px-2 py-0.5 text-xs font-medium ${status.className}`}
          >
            {status.label}
          </span>
        </div>

        {/* Stats */}
        <div className="space-y-3">
          <div className="flex items-center justify-between text-sm">
            <span className="text-muted-foreground">Respostas</span>
            <span className="font-medium text-foreground">
              {application.responses_count}{" "}
              <span className="text-muted-foreground">
                / {application.license_limit}
              </span>
            </span>
          </div>
          <Progress value={progress} className="h-1.5" />
        </div>

        {/* Meta */}
        <p className="text-xs text-muted-foreground">
          Criado em{" "}
          {new Date(application.created_at).toLocaleDateString("pt-BR", {
            day: "2-digit",
            month: "long",
            year: "numeric",
          })}
        </p>

        {/* Actions */}
        <div className="flex flex-wrap items-center gap-2 border-t border-border pt-4">
          <Button
            variant="outline"
            size="sm"
            onClick={() => { window.location.href = `/aplicacoes/${application.id}`; }}
          >
            <ExternalLink className="mr-1.5 size-3.5" />
            Abrir
          </Button>

          <Button variant="outline" size="sm" onClick={handleCopyLink}>
            {copied ? (
              <Check className="mr-1.5 size-3.5 text-primary" />
            ) : (
              <Copy className="mr-1.5 size-3.5" />
            )}
            {copied ? "Copiado" : "Copiar link"}
          </Button>

          {application.status === "active" && (
            <Button
              variant="ghost"
              size="sm"
              className="ml-auto text-destructive hover:bg-destructive/10 hover:text-destructive"
              onClick={() => setCloseOpen(true)}
            >
              <X className="mr-1.5 size-3.5" />
              Encerrar
            </Button>
          )}
        </div>
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
