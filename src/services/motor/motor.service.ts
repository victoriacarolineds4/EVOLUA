// ============================================================
// EVOLUA — Motor — Loader (ponte Supabase → Motor de Cálculo)
// ============================================================
// Carrega a metodologia + o mapeamento + as respostas de um
// colaborador e devolve o diagnóstico bruto. É a camada de IO;
// a lógica de cálculo vive em src/lib/motor (pura).
// ============================================================

import type { SupabaseClient } from "@supabase/supabase-js";
import { computeDiagnosis } from "@/lib/motor/engine";
import { buildReport, type GeneratedReport } from "@/lib/motor/report-builder";
import { PROFILE_LABEL } from "@/lib/motor/translation";
import type {
  EvidenceLink,
  MotorInput,
  RawDiagnosis,
} from "@/lib/motor/types";

function formatDate(value: string | null): string {
  if (!value) return "—";
  return new Date(value).toLocaleDateString("pt-BR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });
}

// Aceita tanto o client do servidor (@/lib/supabase/server) quanto um
// client de service_role usado em scripts — ambos são um SupabaseClient.
// Sem o generic `Database`, as linhas retornadas são tipadas como `any`
// pela própria lib (não escrevemos `any` aqui, então o lint não acusa);
// por isso as funções abaixo não anotam os parâmetros dos `.map()`.
type Db = SupabaseClient;

function toLinks(rows: { alternative_id: string; evidence_strength: EvidenceLink["strength"]; [key: string]: unknown }[] | null, fk: string): EvidenceLink[] {
  return (rows ?? []).map((r) => ({
    alternativeId: r.alternative_id,
    attributeId: r[fk] as string,
    strength: r.evidence_strength,
  }));
}

/**
 * Carrega as partes ESTÁTICAS do Motor (metodologia + mapeamento).
 * Não dependem do colaborador — podem ser cacheadas.
 */
export async function loadMotorMethodology(db: Db) {
  const [
    questions,
    pillars,
    indicators,
    disc,
    tipo,
    mot,
    est,
    aInd,
    aDisc,
    aTipo,
    aMot,
    aEst,
  ] = await Promise.all([
    db.from("questions").select("order_index, alternatives(id, letter)").order("order_index"),
    db.from("pillars").select("number, name").order("number"),
    db.from("indicators").select("id, code, name, pillar_number").order("code"),
    db.from("disc_profiles").select("id, code, name"),
    db.from("psychological_types").select("id, code, name"),
    db.from("motivators").select("id, code, name"),
    db.from("operational_styles").select("id, code, name"),
    db.from("alternative_indicators").select("alternative_id, indicator_id, evidence_strength"),
    db.from("alternative_disc").select("alternative_id, disc_id, evidence_strength"),
    db.from("alternative_psychological_types").select("alternative_id, psychological_type_id, evidence_strength"),
    db.from("alternative_motivators").select("alternative_id, motivator_id, evidence_strength"),
    db.from("alternative_operational_styles").select("alternative_id, operational_style_id, evidence_strength"),
  ]);

  return {
    situations: (questions.data ?? []).map((q) => ({
      situationOrder: q.order_index as number,
      alternativeIds: (q.alternatives ?? []).map((a) => a.id as string),
    })),
    pillars: (pillars.data ?? []).map((p) => ({ number: p.number, name: p.name })),
    indicators: (indicators.data ?? []).map((i) => ({
      id: i.id,
      code: i.code,
      name: i.name,
      pillarNumber: i.pillar_number,
    })),
    disc: (disc.data ?? []).map((d) => ({ id: d.id, code: d.code, name: d.name })),
    psychologicalTypes: (tipo.data ?? []).map((d) => ({ id: d.id, code: d.code, name: d.name })),
    motivators: (mot.data ?? []).map((d) => ({ id: d.id, code: d.code, name: d.name })),
    operationalStyles: (est.data ?? []).map((d) => ({ id: d.id, code: d.code, name: d.name })),
    links: {
      indicators: toLinks(aInd.data, "indicator_id"),
      disc: toLinks(aDisc.data, "disc_id"),
      psychologicalTypes: toLinks(aTipo.data, "psychological_type_id"),
      motivators: toLinks(aMot.data, "motivator_id"),
      operationalStyles: toLinks(aEst.data, "operational_style_id"),
    },
  };
}

/** IDs das alternativas escolhidas por uma resposta (uma por situação). */
export async function getChosenAlternatives(
  db: Db,
  responseId: string,
): Promise<string[]> {
  const { data } = await db
    .from("answers")
    .select("alternative_id")
    .eq("response_id", responseId);
  return (data ?? []).map((a) => a.alternative_id as string);
}

/**
 * Calcula o diagnóstico bruto de uma resposta específica.
 * Junta metodologia + mapeamento + escolhas e chama o motor puro.
 */
export async function computeDiagnosisForResponse(
  db: Db,
  responseId: string,
): Promise<RawDiagnosis> {
  const [methodology, chosenAlternativeIds] = await Promise.all([
    loadMotorMethodology(db),
    getChosenAlternatives(db, responseId),
  ]);

  const input: MotorInput = {
    chosenAlternativeIds,
    ...methodology,
  };

  return computeDiagnosis(input);
}

/** Relatório "ação primeiro" completo de uma resposta concluída. */
export async function getReportForResponse(
  db: Db,
  responseId: string,
): Promise<GeneratedReport | null> {
  const { data: resp } = await db
    .from("responses")
    .select("id, name, role, status, completed_at")
    .eq("id", responseId)
    .single();

  if (!resp || resp.status !== "completed") return null;

  const diagnosis = await computeDiagnosisForResponse(db, responseId);
  return buildReport(diagnosis, {
    name: resp.name,
    role: resp.role,
    completedAt: formatDate(resp.completed_at),
  });
}

export interface ReportListItem {
  responseId: string;
  name: string;
  role: string;
  overall: number;
  profile: string;
  completedAt: string;
}

/** Lista os relatórios concluídos da empresa (para a tela de Relatórios). */
export async function getCompletedReportsForCompany(
  db: Db,
  companyId: string,
): Promise<ReportListItem[]> {
  const { data: apps } = await db
    .from("applications")
    .select("id")
    .eq("company_id", companyId);
  const appIds = (apps ?? []).map((a) => a.id as string);
  if (appIds.length === 0) return [];

  const { data: responses } = await db
    .from("responses")
    .select("id, name, role, completed_at")
    .in("application_id", appIds)
    .eq("status", "completed")
    .order("completed_at", { ascending: false });
  if (!responses || responses.length === 0) return [];

  // Carrega a metodologia uma vez e reaproveita entre as respostas.
  const methodology = await loadMotorMethodology(db);

  const items: ReportListItem[] = [];
  for (const r of responses) {
    const chosenAlternativeIds = await getChosenAlternatives(db, r.id);
    const diagnosis = computeDiagnosis({ chosenAlternativeIds, ...methodology });
    const discCode =
      diagnosis.disc.top?.code ?? diagnosis.disc.ranking[0]?.code ?? "";
    items.push({
      responseId: r.id,
      name: r.name,
      role: r.role,
      overall: diagnosis.overall,
      profile: PROFILE_LABEL[discCode] ?? "Perfil comportamental",
      completedAt: formatDate(r.completed_at),
    });
  }
  return items;
}
