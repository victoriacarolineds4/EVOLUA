import type { Metadata } from "next";
import { Container } from "@/components/layout/container";
import { Section } from "@/components/layout/section";
import { PageHeader } from "@/components/layout/page-header";
import { EmptyState } from "@/components/layout/empty-state";
import { Settings } from "lucide-react";

export const metadata: Metadata = {
  title: "Configurações — EVOLUA",
};

export default function ConfiguracoesPage() {
  return (
    <Container>
      <Section>
        <PageHeader
          title="Configurações"
          description="Gerencie as configurações da sua conta e empresa."
        />
        <div className="mt-8">
          <EmptyState
            icon={Settings}
            title="Em breve"
            description="As configurações de conta e empresa serão implementadas em uma Sprint futura."
          />
        </div>
      </Section>
    </Container>
  );
}
