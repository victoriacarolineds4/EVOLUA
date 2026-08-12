// ============================================================
// EVOLUA — Serviço do Dashboard
// ============================================================
// Estatísticas reais da empresa (colaboradores, testes concluídos
// e pendentes) a partir das aplicações e respostas.
//
// NOTA — semântica de licenças (decisão de produto, Opção A):
// `totalCollaborators` aqui conta PESSOAS que efetivamente iniciaram a
// jornada (linhas em `responses`). Isso é diferente de `licenses_used`
// em `companies`, que conta a RESERVA feita na criação da aplicação
// (`license_limit`, debitado integralmente no ato de criar — ver
// `createApplicationAction`). Os dois números podem divergir de propósito
// (ex.: aplicação de 5 vagas com só 2 respostas ainda reserva 5 licenças).
// O card "Colaboradores" do Dashboard usa `licensesUsed` (a métrica de
// consumo real) como valor principal; este `totalCollaborators` serve
// como informação complementar (quantas pessoas de fato responderam).
// ============================================================

import type { SupabaseClient } from "@supabase/supabase-js";

type Db = SupabaseClient;

export interface DashboardStats {
  totalCollaborators: number; // pessoas que iniciaram a jornada (real, não é a métrica de consumo)
  completedTests: number; // jornadas concluídas
  pendingTests: number; // iniciadas e ainda não concluídas
}

export async function getDashboardStats(
  db: Db,
  companyId: string,
): Promise<DashboardStats> {
  const { data: apps } = await db
    .from("applications")
    .select("id")
    .eq("company_id", companyId);
  const appIds = (apps ?? []).map((a) => a.id as string);

  if (appIds.length === 0) {
    return { totalCollaborators: 0, completedTests: 0, pendingTests: 0 };
  }

  const [{ count: total }, { count: completed }] = await Promise.all([
    db
      .from("responses")
      .select("id", { count: "exact", head: true })
      .in("application_id", appIds),
    db
      .from("responses")
      .select("id", { count: "exact", head: true })
      .in("application_id", appIds)
      .eq("status", "completed"),
  ]);

  const totalCollaborators = total ?? 0;
  const completedTests = completed ?? 0;

  return {
    totalCollaborators,
    completedTests,
    pendingTests: Math.max(0, totalCollaborators - completedTests),
  };
}
