interface QuestionCardProps {
  orderIndex: number;
  title: string;
}

export function QuestionCard({ orderIndex, title }: QuestionCardProps) {
  return (
    <div className="rounded-2xl border border-border bg-card p-8">
      <p className="text-xs font-medium uppercase tracking-widest text-primary">
        Situação {orderIndex}
      </p>
      <h2 className="mt-3 text-lg font-semibold leading-relaxed text-foreground">
        {title}
      </h2>
    </div>
  );
}
