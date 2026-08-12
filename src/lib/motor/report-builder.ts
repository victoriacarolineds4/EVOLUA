// ============================================================
// EVOLUA — Motor — Montador do Relatório "Ação Primeiro"
// ============================================================
// Junta o diagnóstico bruto (números) com a camada de tradução
// (ações) e produz o conteúdo do relatório que o gestor lê.
// Determinístico: mesmo diagnóstico → mesmo relatório.
// ============================================================

import { LEVEL_LABELS } from "./scoring";
import {
  DISC_GUIDANCE,
  MOTIVATOR_GUIDANCE,
  PILLAR_ATTENTION,
  PILLAR_STRENGTH,
  PROFILE_LABEL,
  STYLE_GUIDANCE,
  TYPE_GUIDANCE,
} from "./translation";
import type { DimensionResult, PillarScore, RawDiagnosis } from "./types";

export interface GeneratedReport {
  collaborator: { name: string; role: string; completedAt: string };
  profile: { label: string; overall: number; overallLevel: string; summary: string };
  essential: { headline: string; actions: string[] };
  howTo: { key: string; title: string; items: string[] }[];
  pillars: PillarScore[];
  dimensions: {
    key: string;
    label: string;
    value: string;
    doThis: string;
    confident: boolean;
  }[];
  strengths: { title: string; description: string }[];
  attentionPoints: { title: string; description: string }[];
  plan: { period: string; actions: string[] }[];
}

/** Atributo líder de uma dimensão (usa o predominante; se pouca evidência, o mais votado). */
function leader(dim: DimensionResult) {
  const l = dim.top ?? dim.ranking[0] ?? null;
  return { code: l?.code ?? "", name: l?.name ?? "—", confident: dim.sufficient };
}

export function buildReport(
  d: RawDiagnosis,
  collaborator: { name: string; role: string; completedAt: string },
): GeneratedReport {
  const disc = leader(d.disc);
  const tipo = leader(d.psychologicalType);
  const est = leader(d.operationalStyle);
  const motRank = d.motivators.ranking.filter((m) => m.raw > 0);
  const topMots = motRank.slice(0, 2);
  const mot = leader(d.motivators);

  const discG = DISC_GUIDANCE[disc.code];
  const tipoG = TYPE_GUIDANCE[tipo.code];
  const estG = STYLE_GUIDANCE[est.code];

  const byScoreDesc = [...d.pillars].sort((a, b) => b.score - a.score);
  const strong = byScoreDesc.slice(0, 3);
  const weak = [...byScoreDesc].reverse().slice(0, 2);
  const topPillar = byScoreDesc[0];
  const bottomPillar = byScoreDesc[byScoreDesc.length - 1];

  const firstName = collaborator.name.split(" ")[0] || collaborator.name;

  // ---- Perfil ----
  const label = PROFILE_LABEL[disc.code] ?? "Perfil em construção";
  const summary =
    `${firstName} tem ${discG?.age ?? "um jeito próprio de agir"}. ` +
    `Pensa ${tipoG?.pensa ?? "à sua maneira"} e se move principalmente por ${mot.name.toLowerCase()}. ` +
    `Trabalha melhor quando ${estG?.trabalha ?? "atua no próprio estilo"}.`;

  // ---- Essencial (30s) ----
  const headline =
    `${firstName} entrega o melhor com direção clara. ` +
    `O ponto mais forte é ${topPillar.name}; o que mais precisa de direção é ${bottomPillar.name}.`;
  const essentialActions = [
    discG?.liderar,
    topMots[0] ? MOTIVATOR_GUIDANCE[topMots[0].code]?.reconhecer : undefined,
    PILLAR_ATTENTION[bottomPillar.number],
  ].filter(Boolean) as string[];

  // ---- Como agir (6 blocos) ----
  const howTo = [
    { key: "liderar", title: "Como liderar", items: [discG?.liderar, estG?.delegar] },
    { key: "cobrar", title: "Como cobrar", items: [discG?.cobrar, estG?.delegar] },
    { key: "feedback", title: "Como dar feedback", items: [discG?.feedback, tipoG?.comunicar] },
    { key: "motivar", title: "Como motivar", items: topMots.map((m) => MOTIVATOR_GUIDANCE[m.code]?.motivar) },
    { key: "reconhecer", title: "Como reconhecer", items: topMots.map((m) => MOTIVATOR_GUIDANCE[m.code]?.reconhecer) },
    { key: "desenvolver", title: "Como desenvolver", items: [PILLAR_ATTENTION[weak[0].number], tipoG?.desenvolver] },
  ].map((b) => ({ ...b, items: b.items.filter(Boolean) as string[] }));

  // ---- Dimensões (com "faça isso") ----
  const dimensions = [
    { key: "disc", label: "Como age", value: disc.name, doThis: discG?.liderar ?? "", confident: disc.confident },
    { key: "tipo", label: "Como pensa", value: tipo.name, doThis: tipoG?.comunicar ?? "", confident: tipo.confident },
    { key: "motivador", label: "O que move", value: mot.name, doThis: MOTIVATOR_GUIDANCE[mot.code]?.motivar ?? "", confident: d.motivators.sufficient },
    { key: "estilo", label: "Como trabalha", value: est.name, doThis: estG?.delegar ?? "", confident: est.confident },
  ];

  // ---- Pontos fortes / atenção ----
  const strengths = strong.map((p) => ({
    title: p.name,
    description: PILLAR_STRENGTH[p.number] ?? "",
  }));
  const attentionPoints = weak.map((p) => ({
    title: p.name,
    description: PILLAR_ATTENTION[p.number] ?? "",
  }));

  // ---- Plano 30/60/90 ----
  const plan = [
    {
      period: "30 dias",
      actions: [
        essentialActions[0] ?? discG?.liderar ?? "",
        `Combine expectativas e rotina alinhadas ao ponto de atenção: ${bottomPillar.name}.`,
        `Reconheça uma entrega ligada ao ponto forte: ${topPillar.name}.`,
      ].filter(Boolean),
    },
    {
      period: "60 dias",
      actions: [
        PILLAR_ATTENTION[weak[0].number] ?? "",
        `Dê uma responsabilidade que exercite ${bottomPillar.name} com suporte próximo.`,
        MOTIVATOR_GUIDANCE[mot.code]?.motivar ?? "",
      ].filter(Boolean),
    },
    {
      period: "90 dias",
      actions: [
        `Avalie a evolução em ${bottomPillar.name} e ajuste o plano.`,
        tipoG?.desenvolver ?? "",
        `Combine o próximo passo aproveitando ${topPillar.name}.`,
      ].filter(Boolean),
    },
  ];

  return {
    collaborator,
    profile: {
      label,
      overall: d.overall,
      overallLevel: LEVEL_LABELS[d.pillars[0]?.level ?? "evoluindo"],
      summary,
    },
    essential: { headline, actions: essentialActions },
    howTo,
    pillars: d.pillars,
    dimensions,
    strengths,
    attentionPoints,
    plan,
  };
}
