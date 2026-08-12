import type { Metadata } from "next";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getProfileWithCompany } from "@/services/profile.service";
import { getApplicationsByCompany } from "@/services/applications.service";
import { Container } from "@/components/layout/container";
import { Section } from "@/components/layout/section";
import { WelcomeCard } from "./components/welcome-card";
import { PlanCard } from "./components/plan-card";
import { StatsCards } from "./components/stats-cards";
import { RecentResults } from "./components/recent-results";
import { ApplicationsSection } from "@/features/aplicacoes/components/applications-section";
import { getDashboardStats } from "@/services/dashboard.service";
import { getCompletedReportsForCompany } from "@/services/motor/motor.service";

export const metadata: Metadata = {
  title: "Dashboard — EVOLUA",
};

export default async function DashboardPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  const profile = await getProfileWithCompany(user.id);
  const company = profile?.company;

  const [applications, stats, recentResults] = company
    ? await Promise.all([
        getApplicationsByCompany(company.id),
        getDashboardStats(supabase, company.id),
        getCompletedReportsForCompany(supabase, company.id),
      ])
    : [[], { totalCollaborators: 0, completedTests: 0, pendingTests: 0 }, []];

  const availableLicenses = company
    ? company.licenses_total - company.licenses_used
    : 0;

  const appUrl = process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000";

  return (
    <Container>
      <Section>
        <div className="space-y-6">
          <WelcomeCard companyName={company?.name} />

          <StatsCards
            stats={stats}
            licensesUsed={company?.licenses_used ?? 0}
          />

          <div className="grid gap-6 md:grid-cols-2">
            <PlanCard company={company} />
          </div>

          <RecentResults results={recentResults.slice(0, 4)} />

          <ApplicationsSection
            applications={applications}
            availableLicenses={availableLicenses}
            appUrl={appUrl}
          />
        </div>
      </Section>
    </Container>
  );
}
