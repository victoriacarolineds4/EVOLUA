"use client";

import { useEffect, useState } from "react";
import { cn } from "@/lib/utils";

export type ScoreTone = "success" | "warning" | "critical";

export function scoreTone(value: number): ScoreTone {
  if (value >= 80) return "success";
  if (value >= 65) return "warning";
  return "critical";
}

const TONE_STROKE: Record<ScoreTone, string> = {
  success: "stroke-success",
  warning: "stroke-warning",
  critical: "stroke-critical",
};

const TONE_TEXT: Record<ScoreTone, string> = {
  success: "text-success",
  warning: "text-warning",
  critical: "text-critical",
};

interface ScoreRingProps {
  value: number;
  size?: number;
  strokeWidth?: number;
  tone?: ScoreTone;
  showValue?: boolean;
  className?: string;
}

/** Assinatura visual do EVOLUA — arco de progresso fino que acompanha todo score. */
export function ScoreRing({
  value,
  size = 56,
  strokeWidth = 3,
  tone,
  showValue = true,
  className,
}: ScoreRingProps) {
  const [mounted, setMounted] = useState(false);
  useEffect(() => {
    const raf = requestAnimationFrame(() => setMounted(true));
    return () => cancelAnimationFrame(raf);
  }, []);

  const clamped = Math.max(0, Math.min(100, value));
  const resolvedTone = tone ?? scoreTone(clamped);
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const offset = circumference * (1 - (mounted ? clamped : 0) / 100);

  return (
    <div
      className={cn("relative inline-flex shrink-0 items-center justify-center", className)}
      style={{ width: size, height: size }}
    >
      <svg width={size} height={size} className="-rotate-90">
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          strokeWidth={strokeWidth}
          className="stroke-border"
        />
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          strokeWidth={strokeWidth}
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
          className={cn(
            "transition-[stroke-dashoffset] duration-700 ease-out motion-reduce:transition-none",
            TONE_STROKE[resolvedTone],
          )}
        />
      </svg>
      {showValue && (
        <span
          className={cn(
            "absolute font-heading tabular-nums font-medium",
            TONE_TEXT[resolvedTone],
          )}
          style={{ fontSize: size * 0.32 }}
        >
          {clamped}
        </span>
      )}
    </div>
  );
}
