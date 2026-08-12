"use client";

import dynamic from "next/dynamic";
import type { PillarScore } from "@/lib/motor/types";

const ReportRadarChart = dynamic(
  () =>
    import("@/features/relatorio/components/report-radar-chart").then(
      (m) => m.ReportRadarChart,
    ),
  { ssr: false },
);

interface RadarChartWrapperProps {
  pillars: PillarScore[];
}

export function RadarChartWrapper({ pillars }: RadarChartWrapperProps) {
  return <ReportRadarChart pillars={pillars} />;
}
