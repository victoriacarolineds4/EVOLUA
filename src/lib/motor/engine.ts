// ============================================================
// EVOLUA — Motor de Interpretação — Motor de Cálculo
// ============================================================
// Função pura: recebe as respostas + a metodologia + o mapeamento
// e devolve o diagnóstico bruto. Sem IO, sem IA, sem aleatoriedade.
//
// MODELO DE PONTUAÇÃO (indicadores/pilares):
//   Para cada indicador, olha SÓ as situações que conseguem evidenciá-lo:
//     • raw  = soma das intensidades das alternativas ESCOLHIDAS
//     • max  = soma da MAIOR intensidade disponível em cada uma dessas
//              situações (o melhor que a pessoa poderia ter demonstrado)
//     • score = raw / max × 100
//   Assim o score mede "do quanto de evidência era possível mostrar,
//   quanto a pessoa mostrou" — sempre 0-100 e comparável entre pessoas.
//   O score do pilar é a média dos seus indicadores.
//
// DIMENSÕES (DISC, Tipo, Motivadores, Estilo):
//   Categóricas → soma bruta de evidência por atributo; o "share" é a
//   participação relativa (%), e o "top" é o predominante (se houver
//   evidência suficiente). Não usam a escala de 4 níveis.
// ============================================================

import {
  DIMENSION_PROXIMITY_MARGIN,
  MIN_EVIDENCE_SITUATIONS,
  evidenceCountToConfidence,
  scoreToLevel,
  weakestConfidence,
} from "./scoring";
import type {
  AttributeRef,
  DimensionRank,
  DimensionResult,
  EvidenceLink,
  IndicatorScore,
  MotorInput,
  PillarScore,
  RawDiagnosis,
} from "./types";

/** Índice: alternativa → (atributo → intensidade). */
function indexLinks(links: EvidenceLink[]): Map<string, Map<string, number>> {
  const byAlt = new Map<string, Map<string, number>>();
  for (const l of links) {
    let m = byAlt.get(l.alternativeId);
    if (!m) {
      m = new Map();
      byAlt.set(l.alternativeId, m);
    }
    // se houver duplicado, mantém a maior intensidade
    m.set(l.attributeId, Math.max(m.get(l.attributeId) ?? 0, l.strength));
  }
  return byAlt;
}

/** Situação → (atributo → maior intensidade disponível entre suas alternativas). */
function maxPerSituation(
  situations: MotorInput["situations"],
  linkIndex: Map<string, Map<string, number>>,
): Map<string, number>[] {
  return situations.map((sit) => {
    const best = new Map<string, number>();
    for (const altId of sit.alternativeIds) {
      const m = linkIndex.get(altId);
      if (!m) continue;
      for (const [attrId, strength] of m) {
        best.set(attrId, Math.max(best.get(attrId) ?? 0, strength));
      }
    }
    return best;
  });
}

interface AttrAgg {
  raw: number;
  max: number;
  evidenceCount: number;
}

/** Agrega raw/max/evidência por atributo para os indicadores. */
function aggregateIndicatorLike(
  chosenAlternativeIds: string[],
  situationsMax: Map<string, number>[],
  linkIndex: Map<string, Map<string, number>>,
): Map<string, AttrAgg> {
  const agg = new Map<string, AttrAgg>();
  const ensure = (id: string) => {
    let a = agg.get(id);
    if (!a) {
      a = { raw: 0, max: 0, evidenceCount: 0 };
      agg.set(id, a);
    }
    return a;
  };

  // raw + contagem de evidência (das alternativas escolhidas)
  for (const altId of chosenAlternativeIds) {
    const m = linkIndex.get(altId);
    if (!m) continue;
    for (const [attrId, strength] of m) {
      if (strength <= 0) continue;
      const a = ensure(attrId);
      a.raw += strength;
      a.evidenceCount += 1;
    }
  }

  // max atingível (das situações que conseguem evidenciar o atributo)
  for (const sitBest of situationsMax) {
    for (const [attrId, best] of sitBest) {
      if (best <= 0) continue;
      ensure(attrId).max += best;
    }
  }

  return agg;
}

function toScore(a: AttrAgg | undefined): number {
  if (!a || a.max <= 0) return 0;
  return Math.round((a.raw / a.max) * 100);
}

/** Calcula uma dimensão categórica (DISC, Tipo, Motivadores, Estilo). */
function computeDimension(
  attrs: AttributeRef[],
  chosenAlternativeIds: string[],
  links: EvidenceLink[],
): DimensionResult {
  const linkIndex = indexLinks(links);
  const raw = new Map<string, number>();
  const count = new Map<string, number>();

  for (const altId of chosenAlternativeIds) {
    const m = linkIndex.get(altId);
    if (!m) continue;
    for (const [attrId, strength] of m) {
      if (strength <= 0) continue;
      raw.set(attrId, (raw.get(attrId) ?? 0) + strength);
      count.set(attrId, (count.get(attrId) ?? 0) + 1);
    }
  }

  const total = [...raw.values()].reduce((s, v) => s + v, 0);

  const ranking: DimensionRank[] = attrs
    .map((attr) => {
      const r = raw.get(attr.id) ?? 0;
      return {
        code: attr.code,
        name: attr.name,
        raw: r,
        share: total > 0 ? Math.round((r / total) * 100) : 0,
        evidenceCount: count.get(attr.id) ?? 0,
      };
    })
    // Desempate explícito quando `raw` empata: mais situações distintas
    // corroborando (evidenceCount) vence — evidência repetida em contextos
    // diferentes é um sinal mais forte do que a mesma soma concentrada em
    // menos situações. Se também empatar em evidenceCount, mantém a ordem
    // original (attrs) como último critério, documentado aqui em vez de
    // ser um acidente de ordenação estável do array.
    .sort((a, b) => b.raw - a.raw || b.evidenceCount - a.evidenceCount);

  const leader = ranking[0];
  const runnerUp = ranking[1];
  const sufficient =
    !!leader &&
    leader.raw > 0 &&
    leader.evidenceCount >= MIN_EVIDENCE_SITUATIONS;
  const isClose =
    !!leader &&
    !!runnerUp &&
    runnerUp.raw > 0 &&
    leader.share - runnerUp.share <= DIMENSION_PROXIMITY_MARGIN;

  return {
    top: sufficient ? leader : null,
    ranking,
    sufficient,
    isClose,
  };
}

/**
 * Calcula o diagnóstico bruto a partir das respostas e do mapeamento.
 * Determinístico e puro.
 */
export function computeDiagnosis(input: MotorInput): RawDiagnosis {
  const indLinkIndex = indexLinks(input.links.indicators);
  const situationsMax = maxPerSituation(input.situations, indLinkIndex);
  const indAgg = aggregateIndicatorLike(
    input.chosenAlternativeIds,
    situationsMax,
    indLinkIndex,
  );

  // Indicadores
  const indicatorScores: IndicatorScore[] = input.indicators.map((ind) => {
    const a = indAgg.get(ind.id);
    const score = toScore(a);
    const evidenceCount = a?.evidenceCount ?? 0;
    const confidence = evidenceCountToConfidence(evidenceCount);
    return {
      code: ind.code,
      name: ind.name,
      pillarNumber: ind.pillarNumber,
      score,
      level: scoreToLevel(score),
      evidenceCount,
      confidence,
      hasScore: confidence !== "insuficiente",
      sufficient: evidenceCount >= MIN_EVIDENCE_SITUATIONS,
    };
  });

  // Pilares — média SÓ dos indicadores com evidência real (hasScore=true).
  // Indicadores sem nenhuma evidência (confidence="insuficiente") não entram
  // no cálculo: não há dado nenhum ali, então não há o que promediar — é
  // diferente de "excluir quem pontuou baixo" (isso continuaria incluído).
  const pillars: PillarScore[] = input.pillars
    .map((p) => {
      const inds = indicatorScores.filter((i) => i.pillarNumber === p.number);
      const withScore = inds.filter((i) => i.hasScore);
      const score =
        withScore.length > 0
          ? Math.round(withScore.reduce((s, i) => s + i.score, 0) / withScore.length)
          : 0;
      return {
        number: p.number,
        name: p.name,
        score,
        level: scoreToLevel(score),
        indicators: inds,
        confidence: weakestConfidence(withScore.map((i) => i.confidence)),
        hasScore: withScore.length > 0,
        indicatorsWithScore: withScore.length,
      };
    })
    .sort((a, b) => a.number - b.number);

  // Geral — média só dos pilares que têm score (mesmo princípio).
  const pillarsWithScore = pillars.filter((p) => p.hasScore);
  const overall =
    pillarsWithScore.length > 0
      ? Math.round(
          pillarsWithScore.reduce((s, p) => s + p.score, 0) / pillarsWithScore.length,
        )
      : 0;

  return {
    answeredCount: input.chosenAlternativeIds.length,
    overall,
    pillars,
    disc: computeDimension(input.disc, input.chosenAlternativeIds, input.links.disc),
    psychologicalType: computeDimension(
      input.psychologicalTypes,
      input.chosenAlternativeIds,
      input.links.psychologicalTypes,
    ),
    motivators: computeDimension(
      input.motivators,
      input.chosenAlternativeIds,
      input.links.motivators,
    ),
    operationalStyle: computeDimension(
      input.operationalStyles,
      input.chosenAlternativeIds,
      input.links.operationalStyles,
    ),
  };
}
