import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { Badge, type badgeVariants } from "@/components/ui/badge";
import type { Response } from "@/types/database.types";
import type { VariantProps } from "class-variance-authority";

const RESPONSE_STATUS_CONFIG: Record<
  Response["status"],
  { label: string; variant: VariantProps<typeof badgeVariants>["variant"] }
> = {
  started: { label: "Em andamento", variant: "neutral" },
  completed: { label: "Completo", variant: "success" },
  abandoned: { label: "Abandonado", variant: "critical" },
};

interface ResponseRowProps {
  response: Response;
  isLast: boolean;
}

export function ResponseRow({ response, isLast }: ResponseRowProps) {
  const status = RESPONSE_STATUS_CONFIG[response.status];

  return (
    <div
      className={
        "flex items-center gap-4 px-6 py-4" + (isLast ? "" : " border-b border-border")
      }
    >
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-medium text-foreground">{response.name}</p>
        <p className="truncate text-xs text-muted-foreground">{response.role}</p>
      </div>

      <Badge variant={status.variant} className="shrink-0">
        {status.label}
      </Badge>

      {response.status === "completed" ? (
        <Link
          href={`/relatorio/${response.id}`}
          className="flex shrink-0 items-center gap-1.5 rounded-lg bg-primary/10 px-3 py-1.5 text-xs font-medium text-primary transition-colors hover:bg-primary/20"
        >
          Ver mapa
          <ArrowRight className="size-3" />
        </Link>
      ) : (
        <span className="w-[88px] shrink-0" />
      )}
    </div>
  );
}
