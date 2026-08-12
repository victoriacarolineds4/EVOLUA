import type { Metadata } from "next";
import { validateApplicationToken } from "@/services/public-application.service";
import { InvalidApplication } from "@/features/colaborador/components/invalid-application";
import { ApplicationClosed } from "@/features/colaborador/components/application-closed";
import { ApplicationFull } from "@/features/colaborador/components/application-full";
import { EntryFlow } from "@/features/colaborador/components/entry-flow";

export const metadata: Metadata = {
  title: "EVOLUA — Jornada de Desenvolvimento",
};

interface PageProps {
  params: Promise<{ token: string }>;
}

export default async function PublicApplicationPage({ params }: PageProps) {
  const { token } = await params;

  const result = await validateApplicationToken(token);

  if (result.status === "not_found") return <InvalidApplication />;
  if (result.status === "closed") return <ApplicationClosed />;
  if (result.status === "full") return <ApplicationFull />;

  return <EntryFlow application={result.application} token={token} />;
}
