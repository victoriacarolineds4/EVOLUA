"use client";

import {
  Radar,
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  ResponsiveContainer,
} from "recharts";
import type { PillarScore } from "@/lib/motor/types";

interface ReportRadarChartProps {
  pillars: PillarScore[];
}

export function ReportRadarChart({ pillars }: ReportRadarChartProps) {
  const data = pillars.map((p) => ({
    pilar: p.name.length > 12 ? p.name.split(" ")[0] : p.name,
    score: p.score,
    fullMark: 100,
  }));

  return (
    <ResponsiveContainer width="100%" height={360}>
      <RadarChart data={data} margin={{ top: 16, right: 32, bottom: 16, left: 32 }}>
        {/* Cores acompanham os tokens de globals.css (--border, --muted-foreground, --primary) */}
        <PolarGrid stroke="#e7e9ed" />
        <PolarAngleAxis
          dataKey="pilar"
          tick={{ fill: "#6b7280", fontSize: 12, fontWeight: 500 }}
        />
        <Radar
          name="Score"
          dataKey="score"
          stroke="#1fa98c"
          fill="#1fa98c"
          fillOpacity={0.12}
          strokeWidth={2}
          dot={{ fill: "#1fa98c", r: 4 }}
        />
      </RadarChart>
    </ResponsiveContainer>
  );
}
