import { AppWindow } from "lucide-react";
import { ApplicationCard } from "@/features/aplicacoes/components/application-card";
import { NewApplicationModal } from "@/features/aplicacoes/components/new-application-modal";
import type { Application } from "@/types/database.types";

interface ApplicationsSectionProps {
  applications: Application[];
  availableLicenses: number;
  appUrl: string;
  showHeader?: boolean;
}

export function ApplicationsSection({
  applications,
  availableLicenses,
  appUrl,
  showHeader = true,
}: ApplicationsSectionProps) {
  return (
    <div className="space-y-6">
      {showHeader && (
        <div className="flex items-center justify-between">
          <div>
            <h2 className="font-semibold text-foreground">Aplicações</h2>
            <p className="mt-0.5 text-sm text-muted-foreground">
              {applications.length === 0
                ? "Nenhuma aplicação criada ainda"
                : `${applications.length} ${applications.length === 1 ? "aplicação" : "aplicações"}`}
            </p>
          </div>
          <NewApplicationModal availableLicenses={availableLicenses} />
        </div>
      )}

      {applications.length === 0 ? (
        <div className="flex flex-col items-center justify-center gap-4 rounded-2xl border border-dashed border-border bg-card/50 py-16 text-center">
          <div className="flex size-14 items-center justify-center rounded-2xl border border-dashed border-border bg-muted/40">
            <AppWindow className="size-6 text-muted-foreground" />
          </div>
          <div>
            <p className="font-medium text-foreground">
              Nenhuma aplicação criada ainda
            </p>
            <p className="mt-1 text-sm text-muted-foreground">
              Crie sua primeira aplicação e envie para sua equipe.
            </p>
          </div>
          {!showHeader && (
            <NewApplicationModal availableLicenses={availableLicenses} />
          )}
        </div>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {applications.map((app) => (
            <ApplicationCard key={app.id} application={app} appUrl={appUrl} />
          ))}
        </div>
      )}
    </div>
  );
}
