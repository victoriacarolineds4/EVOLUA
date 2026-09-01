import type { badgeVariants } from "@/components/ui/badge";
import type { Application } from "@/types/database.types";
import type { VariantProps } from "class-variance-authority";

// Módulo neutro (sem "use client") — importar uma constante de um arquivo
// "use client" para dentro de um Server Component quebra em runtime
// (limitação do React Server Components: TypeScript não acusa, mas o
// valor chega `undefined` no servidor). Ver gotcha no HANDOFF.md.
export const STATUS_CONFIG: Record<
  Application["status"],
  { label: string; variant: VariantProps<typeof badgeVariants>["variant"] }
> = {
  draft: { label: "Rascunho", variant: "neutral" },
  active: { label: "Ativa", variant: "success" },
  closed: { label: "Encerrada", variant: "critical" },
};
