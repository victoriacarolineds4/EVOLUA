interface WelcomeCardProps {
  companyName?: string;
}

export function WelcomeCard({ companyName }: WelcomeCardProps) {
  const greeting = companyName ? `Olá, ${companyName}` : "Bem-vindo ao EVOLUA";

  return (
    <div className="rounded-2xl border border-border bg-card p-8">
      <p className="text-sm font-medium text-primary">Dashboard</p>
      <h2 className="mt-2 text-2xl font-semibold tracking-tight text-foreground">
        {greeting}
      </h2>
      <p className="mt-3 text-sm text-muted-foreground italic">
        &ldquo;Toda pessoa pode evoluir quando recebe a direção certa.&rdquo;
      </p>
    </div>
  );
}
