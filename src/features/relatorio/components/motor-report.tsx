import Link from "next/link";
import {
  ArrowLeft,
  Clock,
  CheckCircle2,
  AlertTriangle,
  Target,
} from "lucide-react";
import { Container } from "@/components/layout/container";
import { PillarCard } from "@/features/relatorio/components/pillar-card";
import { ReportSection } from "@/features/relatorio/components/report-section";
import { RadarChartWrapper } from "@/features/relatorio/components/radar-chart-wrapper";
import type { GeneratedReport } from "@/lib/motor/report-builder";
import { cn } from "@/lib/utils";

const PERIOD_STYLES: Record<string, string> = {
  "30 dias": "bg-primary/10 text-primary border-primary/20",
  "60 dias": "bg-violet-400/10 text-violet-400 border-violet-400/20",
  "90 dias": "bg-sky-400/10 text-sky-400 border-sky-400/20",
};

export function MotorReport({ report: r }: { report: GeneratedReport }) {
  return (
    <Container>
      <div className="py-8 space-y-12">
        <Link
          href="/relatorio"
          className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
        >
          <ArrowLeft className="size-4" />
          Voltar para Relatórios
        </Link>

        {/* ── CABEÇALHO ── */}
        <div className="rounded-2xl border border-border bg-card p-8 space-y-6">
          <div className="flex items-start justify-between gap-6">
            <div className="space-y-1">
              <p className="text-xs font-medium uppercase tracking-widest text-primary">
                Mapa de Desenvolvimento — EVOLUA
              </p>
              <h1 className="text-3xl font-bold text-foreground">{r.collaborator.name}</h1>
              <p className="text-base text-muted-foreground">{r.collaborator.role}</p>
            </div>
            <div className="text-right shrink-0">
              <p className="text-xs text-muted-foreground">Concluído em</p>
              <p className="text-sm font-medium text-foreground">{r.collaborator.completedAt}</p>
            </div>
          </div>
          <div className="flex flex-wrap items-center gap-4 border-t border-border pt-6">
            <span className="rounded-full bg-primary/10 px-4 py-1.5 text-sm font-semibold text-primary border border-primary/20">
              {r.profile.label}
            </span>
            <div className="flex items-center gap-2 ml-auto">
              <span className="text-xs text-muted-foreground">Score geral</span>
              <span className="text-4xl font-bold text-foreground tabular-nums">
                {r.profile.overall}
              </span>
              <span className="text-lg text-muted-foreground">/100</span>
            </div>
          </div>
          <p className="text-sm leading-relaxed text-muted-foreground border-t border-border pt-4">
            {r.profile.summary}
          </p>
        </div>

        {/* ── ESSENCIAL (30s) ── */}
        <div className="rounded-2xl border border-primary/30 bg-primary/[0.04] p-8 space-y-5">
          <div className="inline-flex items-center gap-2 rounded-full border border-primary/25 bg-primary/10 px-3 py-1 text-xs font-semibold uppercase tracking-wide text-primary">
            <Clock className="size-3.5" />
            O essencial em 30 segundos
          </div>
          <p className="text-lg font-medium leading-relaxed text-foreground">
            {r.essential.headline}
          </p>
          <ol className="divide-y divide-border border-t border-border">
            {r.essential.actions.map((a, i) => (
              <li key={i} className="flex gap-4 py-4">
                <span className="text-sm font-bold text-primary tabular-nums">{i + 1}</span>
                <span className="text-sm text-foreground/90">{a}</span>
              </li>
            ))}
          </ol>
        </div>

        {/* ── COMO AGIR ── */}
        <ReportSection
          title="Como agir com essa pessoa"
          subtitle="Orientações práticas — o que fazer, sem termos técnicos."
        >
          <div className="grid gap-4 sm:grid-cols-2">
            {r.howTo.map((b) => (
              <div key={b.key} className="rounded-xl border border-border bg-card p-6 space-y-3">
                <h3 className="text-sm font-semibold text-foreground">{b.title}</h3>
                <ul className="space-y-2.5">
                  {b.items.map((item, i) => (
                    <li key={i} className="flex items-start gap-2.5 text-sm text-foreground/90">
                      <span className="mt-1.5 size-1.5 shrink-0 rounded-full bg-primary" />
                      {item}
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </ReportSection>

        {/* ── PILARES ── */}
        <ReportSection
          title="Visão por Pilares"
          subtitle="Resultado consolidado em cada dimensão comportamental avaliada."
        >
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
            {r.pillars.map((pillar) => (
              <PillarCard key={pillar.number} pillar={pillar} />
            ))}
          </div>
        </ReportSection>

        {/* ── RADAR ── */}
        <ReportSection title="Radar Comportamental" subtitle="Distribuição visual dos scores por pilar.">
          <div className="rounded-xl border border-border bg-card p-8">
            <RadarChartWrapper pillars={r.pillars} />
          </div>
        </ReportSection>

        {/* ── DIMENSÕES ── */}
        <ReportSection
          title="Leituras Complementares"
          subtitle="Como a pessoa age, pensa, o que a move e como trabalha — cada uma com o que fazer."
        >
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            {r.dimensions.map((d) => (
              <div key={d.key} className="rounded-xl border border-border bg-card p-5">
                <p className="text-[11px] uppercase tracking-widest text-muted-foreground">{d.label}</p>
                <p className="mt-1 text-base font-semibold text-primary">
                  {d.value}
                  {!d.confident && (
                    <span className="ml-1.5 text-[10px] font-medium text-muted-foreground">tendência</span>
                  )}
                </p>
                <p className="mt-2.5 border-t border-dashed border-border pt-2.5 text-xs leading-relaxed text-muted-foreground">
                  <span className="font-semibold text-primary">→ </span>
                  {d.doThis}
                </p>
              </div>
            ))}
          </div>
        </ReportSection>

        {/* ── FORTES / ATENÇÃO ── */}
        <ReportSection
          title="Pontos Fortes e Pontos de Atenção"
          subtitle="Destaques positivos e oportunidades de crescimento."
        >
          <div className="grid gap-6 md:grid-cols-2">
            <div className="rounded-xl border border-emerald-400/20 bg-emerald-400/5 p-6 space-y-4">
              <div className="flex items-center gap-2">
                <CheckCircle2 className="size-5 text-emerald-400" />
                <h3 className="text-sm font-semibold text-foreground">Pontos Fortes</h3>
              </div>
              <div className="space-y-4">
                {r.strengths.map((s, i) => (
                  <div key={i}>
                    <p className="text-sm font-semibold text-foreground">{s.title}</p>
                    <p className="mt-1 text-sm leading-relaxed text-muted-foreground">{s.description}</p>
                  </div>
                ))}
              </div>
            </div>
            <div className="rounded-xl border border-amber-400/20 bg-amber-400/5 p-6 space-y-4">
              <div className="flex items-center gap-2">
                <AlertTriangle className="size-5 text-amber-400" />
                <h3 className="text-sm font-semibold text-foreground">Pontos de Atenção</h3>
              </div>
              <div className="space-y-4">
                {r.attentionPoints.map((a, i) => (
                  <div key={i}>
                    <p className="text-sm font-semibold text-foreground">{a.title}</p>
                    <p className="mt-1 text-sm leading-relaxed text-muted-foreground">{a.description}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </ReportSection>

        {/* ── PLANO 30/60/90 ── */}
        <ReportSection
          title="Plano de Desenvolvimento"
          subtitle="Ações recomendadas para os próximos 90 dias."
        >
          <div className="grid gap-6 md:grid-cols-3">
            {r.plan.map((plan) => (
              <div key={plan.period} className="rounded-xl border border-border bg-card p-6 space-y-4">
                <span
                  className={cn(
                    "inline-flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs font-semibold",
                    PERIOD_STYLES[plan.period],
                  )}
                >
                  <Target className="size-3" />
                  {plan.period}
                </span>
                <ul className="space-y-3">
                  {plan.actions.map((action, i) => (
                    <li key={i} className="flex items-start gap-3">
                      <span className="mt-1 text-xs font-bold text-primary shrink-0">{i + 1}.</span>
                      <p className="text-sm leading-relaxed text-muted-foreground">{action}</p>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </ReportSection>

        <div className="border-t border-border pt-8 text-center">
          <p className="text-xs text-muted-foreground/60">
            Gerado por EVOLUA · Neon Conecta · Diagnóstico comportamental por situações reais
          </p>
        </div>
      </div>
    </Container>
  );
}
