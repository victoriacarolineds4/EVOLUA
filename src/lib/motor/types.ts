// ============================================================
// EVOLUA — Motor de Interpretação — Tipos
// ============================================================
// O Motor transforma as respostas de um colaborador em um
// diagnóstico bruto (scores por indicador, pilar e dimensões
// complementares). É determinístico: mesma entrada → mesma saída.
// A IA nunca entra aqui; ela só traduz a saída em texto depois.
// ============================================================

/** Níveis da escala oficial de desenvolvimento (4 níveis). */
export type Level =
  | "atencao" // Precisa de atenção
  | "evoluindo" // Está evoluindo
  | "desenvolvido" // Bem desenvolvido
  | "muito_desenvolvido"; // Muito desenvolvido

/** Intensidade da evidência de uma alternativa para um atributo. */
export type EvidenceStrength = 0 | 1 | 2 | 3;

/**
 * Confiança da medição — independente do score. Baseada em quantas
 * situações DISTINTAS geraram evidência genuína (não em quantas
 * alternativas apontam para o indicador — dentro de uma situação só
 * se escolhe uma alternativa, então o piso real é por situação).
 *   insuficiente → 0 situações: não há score para mostrar, só "dados insuficientes".
 *   baixa        → 1 situação.
 *   moderada     → 2 situações.
 *   alta         → 3+ situações (piso MIN_EVIDENCE_SITUATIONS atingido).
 */
export type Confidence = "insuficiente" | "baixa" | "moderada" | "alta";

// ---------- Entrada do Motor ----------

/** Um vínculo alternativa → atributo, com intensidade. */
export interface EvidenceLink {
  alternativeId: string;
  attributeId: string;
  strength: EvidenceStrength;
}

export interface AttributeRef {
  id: string;
  code: string;
  name: string;
}

export interface IndicatorRef extends AttributeRef {
  pillarNumber: number;
}

export interface PillarRef {
  number: number;
  name: string;
}

/** Todas as alternativas de uma situação (para calcular o máximo atingível). */
export interface SituationAlternatives {
  situationOrder: number;
  alternativeIds: string[];
}

/** Entrada completa: respostas escolhidas + metodologia + mapeamento. */
export interface MotorInput {
  /** IDs das alternativas escolhidas (uma por situação respondida). */
  chosenAlternativeIds: string[];
  /** Todas as alternativas por situação (denominador do score). */
  situations: SituationAlternatives[];
  indicators: IndicatorRef[];
  pillars: PillarRef[];
  disc: AttributeRef[];
  psychologicalTypes: AttributeRef[];
  motivators: AttributeRef[];
  operationalStyles: AttributeRef[];
  links: {
    indicators: EvidenceLink[];
    disc: EvidenceLink[];
    psychologicalTypes: EvidenceLink[];
    motivators: EvidenceLink[];
    operationalStyles: EvidenceLink[];
  };
}

// ---------- Saída do Motor ----------

export interface IndicatorScore {
  code: string;
  name: string;
  pillarNumber: number;
  score: number; // 0-100 (0 quando confidence = "insuficiente"; ver hasScore)
  level: Level;
  evidenceCount: number; // nº de situações distintas que contribuíram
  confidence: Confidence;
  /** true quando há evidência real (evidenceCount ≥ 1) e `score` deve ser exibido. */
  hasScore: boolean;
  /** @deprecated use `confidence === "alta"`. Mantido para não quebrar leitores antigos. */
  sufficient: boolean;
}

export interface PillarScore {
  number: number;
  name: string;
  score: number; // 0-100 — média SÓ dos indicadores com hasScore=true
  level: Level;
  indicators: IndicatorScore[];
  confidence: Confidence; // a mais fraca entre os indicadores considerados na média
  /** true quando pelo menos 1 dos 5 indicadores tem evidência real. */
  hasScore: boolean;
  /** quantos dos 5 indicadores entraram na média (hasScore=true). */
  indicatorsWithScore: number;
}

/** Um atributo de uma dimensão categórica (DISC, Tipo, etc.). */
export interface DimensionRank {
  code: string;
  name: string;
  raw: number; // soma bruta de evidência
  share: number; // 0-100 relativo ao total da dimensão
  evidenceCount: number;
}

export interface DimensionResult {
  /** Atributo predominante, se houver evidência suficiente. */
  top: DimensionRank | null;
  ranking: DimensionRank[]; // ordenado desc por raw, com desempate explícito (ver engine.ts)
  sufficient: boolean;
  /**
   * true quando o 1º e o 2º colocado estão a ≤ DISC_PROXIMITY_MARGIN pontos
   * percentuais de share um do outro — o predominante não deve ser lido como
   * uma diferença clara. Ver `scoring.ts`.
   */
  isClose: boolean;
}

export interface RawDiagnosis {
  answeredCount: number;
  overall: number; // 0-100 (média dos pilares)
  pillars: PillarScore[];
  disc: DimensionResult;
  psychologicalType: DimensionResult;
  motivators: DimensionResult;
  operationalStyle: DimensionResult;
}
