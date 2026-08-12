interface WelcomeCardProps {
  companyName?: string;
}

export function WelcomeCard({ companyName }: WelcomeCardProps) {
  const greeting = companyName ? `Olá, ${companyName}` : "Bem-vindo ao EVOLUA";

  return (
    <div className="rounded-2xl border border-border bg-card p-8 shadow-ambient">
      <p className="text-xs font-medium tracking-wide text-muted-foreground uppercase">
        Dashboard
      </p>
      <h1 className="mt-2 font-heading text-3xl font-medium tracking-tight text-foreground">
        {greeting}
      </h1>
      <p className="mt-3 text-sm leading-relaxed text-muted-foreground/80 italic">
        &ldquo;Toda pessoa pode evoluir quando recebe a direção certa.&rdquo;
      </p>
    </div>
  );
}
