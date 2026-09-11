// ============================================================
// EVOLUA — Motor — Política de Pontuação (ajustável)
// ============================================================
// Isola as decisões metodológicas de pontuação num único lugar,
// para a Victoria validar/ajustar sem tocar no algoritmo.
// ============================================================

import type { Confidence, Level } from "./types";

/**
 * Piso de evidência: nº mínimo de situações que precisam apontar para
 * um atributo antes de afirmá-lo com confiança. Abaixo disso, o Motor
 * marca como "não suficiente" (evita concluir a partir de pouca evidência).
 */
export const MIN_EVIDENCE_SITUATIONS = 3;

/**
 * Cortes da escala de 4 níveis (0-100). Ajustáveis.
 *   0–39  → Precisa de atenção
 *   40–64 → Está evoluindo
 *   65–84 → Bem desenvolvido
 *   85–100→ Muito desenvolvido
 */
export const LEVEL_THRESHOLDS: { maxScore: number; level: Level }[] = [
  { maxScore: 39, level: "atencao" },
  { maxScore: 64, level: "evoluindo" },
  { maxScore: 84, level: "desenvolvido" },
  { maxScore: 100, level: "muito_desenvolvido" },
];

export const LEVEL_LABELS: Record<Level, string> = {
  atencao: "Precisa de atenção",
  evoluindo: "Está evoluindo",
  desenvolvido: "Bem desenvolvido",
  muito_desenvolvido: "Muito desenvolvido",
};

export function scoreToLevel(score: number): Level {
  const clamped = Math.max(0, Math.min(100, score));
  for (const t of LEVEL_THRESHOLDS) {
    if (clamped <= t.maxScore) return t.level;
  }
  return "muito_desenvolvido";
}

/** Ordem de força da confiança, do mais fraco ao mais forte. */
const CONFIDENCE_ORDER: Confidence[] = ["insuficiente", "baixa", "moderada", "alta"];

/**
 * Confiança a partir de nº de situações distintas com evidência.
 * evidenceCount aqui já é, por construção do Motor, nº de situações
 * (uma escolha por situação) — não nº de alternativas vinculadas.
 */
export function evidenceCountToConfidence(evidenceCount: number): Confidence {
  if (evidenceCount <= 0) return "insuficiente";
  if (evidenceCount === 1) return "baixa";
  if (evidenceCount === 2) return "moderada";
  return "alta"; // ≥ MIN_EVIDENCE_SITUATIONS
}

/** A confiança mais fraca entre uma lista (usada para agregar em pilar). */
export function weakestConfidence(list: Confidence[]): Confidence {
  if (list.length === 0) return "insuficiente";
  return list.reduce((weakest, c) =>
    CONFIDENCE_ORDER.indexOf(c) < CONFIDENCE_ORDER.indexOf(weakest) ? c : weakest,
  );
}
