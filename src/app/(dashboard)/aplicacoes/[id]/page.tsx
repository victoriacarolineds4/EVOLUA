import type { Metadata } from "next";
import { Container } from "@/components/layout/container";
import { Section } from "@/components/layout/section";
import { PageHeader } from "@/components/layout/page-header";
import { EmptyState } from "@/components/layout/empty-state";
import { FileBarChart } from "lucide-react";

export const metadata: Metadata = {
  title: "Aplicação — EVOLUA",
};

export default function ApplicationDetailPage() {
  return (
    <Container>
      <Section>
        <PageHeader
          title="Detalhe da aplicação"
          description="Visualize respostas e resultados desta aplicação."
        />
        <div className="mt-8">
          <EmptyState
            icon={FileBarChart}
            title="Em breve"
            description="O detalhe da aplicação com respostas e mapas de desenvolvimento será implementado em uma Sprint futura."
          />
        </div>
      </Section>
    </Container>
  );
}
