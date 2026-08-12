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
        <PolarGrid stroke="rgba(255,255,255,0.08)" />
        <PolarAngleAxis
          dataKey="pilar"
          tick={{ fill: "#94a3b8", fontSize: 12, fontWeight: 500 }}
        />
        <Radar
          name="Score"
          dataKey="score"
          stroke="#4ade80"
          fill="#4ade80"
          fillOpacity={0.15}
          strokeWidth={2}
          dot={{ fill: "#4ade80", r: 4 }}
        />
      </RadarChart>
    </ResponsiveContainer>
  );
}
