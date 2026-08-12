interface ReportSectionProps {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
}

export function ReportSection({ title, subtitle, children }: ReportSectionProps) {
  return (
    <section className="space-y-6">
      <div className="border-b border-border pb-4">
        <h2 className="text-lg font-semibold text-foreground">{title}</h2>
        {subtitle && (
          <p className="mt-1 text-sm text-muted-foreground">{subtitle}</p>
        )}
      </div>
      {children}
    </section>
  );
}
