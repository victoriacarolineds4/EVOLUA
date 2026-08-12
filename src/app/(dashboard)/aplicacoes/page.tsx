import type { Metadata } from "next";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getProfileWithCompany } from "@/services/profile.service";
import { getApplicationsByCompany } from "@/services/applications.service";
import { Container } from "@/components/layout/container";
import { Section } from "@/components/layout/section";
import { ApplicationsSection } from "@/features/aplicacoes/components/applications-section";

export const metadata: Metadata = {
  title: "Aplicações — EVOLUA",
};

export default async function AplicacoesPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  const profile = await getProfileWithCompany(user.id);
  const company = profile?.company;

  const applications = company
    ? await getApplicationsByCompany(company.id)
    : [];

  const availableLicenses = company
    ? company.licenses_total - company.licenses_used
    : 0;

  const appUrl = process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000";

  return (
    <Container>
      <Section>
        <ApplicationsSection
          applications={applications}
          availableLicenses={availableLicenses}
          appUrl={appUrl}
        />
      </Section>
    </Container>
  );
}
