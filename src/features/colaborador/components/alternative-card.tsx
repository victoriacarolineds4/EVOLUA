import { cn } from "@/lib/utils";

interface AlternativeCardProps {
  title: string;
  description?: string | null;
  isSelected: boolean;
  disabled: boolean;
  onClick: () => void;
}

export function AlternativeCard({
  title,
  description,
  isSelected,
  disabled,
  onClick,
}: AlternativeCardProps) {
  return (
    <button
      type="button"
      disabled={disabled}
      onClick={onClick}
      className={cn(
        "w-full rounded-xl border p-5 text-left transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
        isSelected
          ? "border-primary bg-primary/10"
          : "border-border bg-card hover:border-primary/40 hover:bg-muted/40",
        disabled && "cursor-not-allowed opacity-60",
      )}
    >
      <p className="font-medium text-foreground">{title}</p>
      {description && (
        <p className="mt-1.5 text-sm leading-relaxed text-muted-foreground">
          {description}
        </p>
      )}
    </button>
  );
}
