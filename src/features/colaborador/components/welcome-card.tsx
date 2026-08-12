import { Clock, ShieldCheck, ArrowRight } from "lucide-react";
import { Button } from "@/components/ui/button";

interface WelcomeCardProps {
  onStart: () => void;
}

export function WelcomeCard({ onStart }: WelcomeCardProps) {
  return (
    <div className="w-full max-w-lg space-y-8">
      {/* Branding */}
      <div className="text-center">
        <p className="font-heading text-2xl font-medium tracking-tight text-primary">EVOLUA</p>
      </div>

      {/* Main card */}
      <div className="rounded-2xl border border-border bg-card p-8 shadow-elevated">
        <div className="space-y-6">
          <div className="space-y-3">
            <h1 className="font-heading text-2xl font-medium tracking-tight text-foreground">
              Bem-vindo ao EVOLUA
            </h1>
            <p className="text-sm leading-relaxed text-muted-foreground">
              Toda pessoa pode evoluir quando recebe a direção certa.
            </p>
          </div>

          <p className="text-sm leading-relaxed text-muted-foreground">
            Hoje você iniciará uma breve jornada para compreender melhor sua
            forma de trabalhar. Ao final, você receberá seu{" "}
            <span className="font-medium text-foreground">
              Mapa de Desenvolvimento
            </span>
            .
          </p>

          {/* Info items */}
          <div className="space-y-3 rounded-xl border border-border bg-muted/30 p-4">
            <div className="flex items-center gap-3">
              <div className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-primary/10">
                <Clock className="size-4 text-primary" />
              </div>
              <p className="text-sm text-foreground">
                Tempo aproximado:{" "}
                <span className="font-medium">10 minutos</span>
              </p>
            </div>
            <div className="flex items-center gap-3">
              <div className="flex size-8 shrink-0 items-center justify-center rounded-lg bg-primary/10">
                <ShieldCheck className="size-4 text-primary" />
              </div>
              <p className="text-sm text-foreground">
                Suas respostas são{" "}
                <span className="font-medium">confidenciais</span>
              </p>
            </div>
          </div>

          <Button className="w-full" size="lg" onClick={onStart}>
            Iniciar minha jornada
            <ArrowRight className="ml-2 size-4" />
          </Button>
        </div>
      </div>
    </div>
  );
}
