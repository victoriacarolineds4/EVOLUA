import { Loader2 } from "lucide-react";
import { cn } from "@/lib/utils";

interface LoadingProps {
  label?: string;
  size?: "sm" | "md" | "lg";
  className?: string;
}

const sizeMap = {
  sm: "size-4",
  md: "size-6",
  lg: "size-8",
} as const;

export function Loading({ label, size = "md", className }: LoadingProps) {
  return (
    <div className={cn("flex items-center justify-center gap-2 text-muted-foreground", className)}>
      <Loader2 className={cn("animate-spin", sizeMap[size])} />
      {label && <span className="text-sm">{label}</span>}
    </div>
  );
}
