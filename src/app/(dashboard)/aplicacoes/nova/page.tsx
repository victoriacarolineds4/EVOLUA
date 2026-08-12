import type { Metadata } from "next";
import { Container } from "@/components/layout/container";
import { Section } from "@/components/layout/section";
import { PageHeader } from "@/components/layout/page-header";
import { EmptyState } from "@/components/layout/empty-state";
import { Plus } from "lucide-react";

export const metadata: Metadata = {
  title: "Nova Aplicação — EVOLUA",
};

export default function NovaAplicacaoPage() {
  return (
    <Container>
      <Section>
        <PageHeader
          title="Nova Aplicação"
          description="Crie e configure uma nova aplicação de questionário."
        />
        <div className="mt-8">
          <EmptyState
            icon={Plus}
            title="Em breve"
            description="A criação de aplicações será implementada na próxima Sprint."
          />
        </div>
      </Section>
    </Container>
  );
}
