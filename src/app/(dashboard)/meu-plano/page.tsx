import type { Metadata } from "next";
import { Container } from "@/components/layout/container";
import { Section } from "@/components/layout/section";
import { PageHeader } from "@/components/layout/page-header";
import { EmptyState } from "@/components/layout/empty-state";
import { CreditCard } from "lucide-react";

export const metadata: Metadata = {
  title: "Meu Plano — EVOLUA",
};

export default function MeuPlanoPage() {
  return (
    <Container>
      <Section>
        <PageHeader
          title="Meu Plano"
          description="Visualize e gerencie sua assinatura."
        />
        <div className="mt-8">
          <EmptyState
            icon={CreditCard}
            title="Em breve"
            description="O módulo de gestão de plano será implementado em uma Sprint futura."
          />
        </div>
      </Section>
    </Container>
  );
}
