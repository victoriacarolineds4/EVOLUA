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
  score: number; // 0-100
  level: Level;
  evidenceCount: number; // nº de situações que contribuíram
  sufficient: boolean; // atingiu o piso de evidência?
}

export interface PillarScore {
  number: number;
  name: string;
  score: number; // 0-100 (média dos indicadores)
  level: Level;
  indicators: IndicatorScore[];
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
  ranking: DimensionRank[]; // ordenado desc por raw
  sufficient: boolean;
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
