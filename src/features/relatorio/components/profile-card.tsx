import Image from "next/image";

/**
 * Mapeamento visual dos 4 perfis DISC já calculados pelo motor
 * (código vem de report.profile.code, mesma fonte que já gera
 * profile.label via PROFILE_LABEL em lib/motor/translation.ts —
 * não é uma segunda identificação de perfil, só a camada visual).
 */
const PROFILE_IMAGE: Record<string, { src: string; alt: string }> = {
  D: { src: "/images/perfis/realizador.png", alt: "Ilustração do perfil Dominante" },
  I: { src: "/images/perfis/comunicador.png", alt: "Ilustração do perfil Influente" },
  S: { src: "/images/perfis/colaborativo.png", alt: "Ilustração do perfil Estável" },
  C: { src: "/images/perfis/analitico.png", alt: "Ilustração do perfil Conforme" },
};

interface ProfileCardProps {
  code: string;
  label: string;
  confident: boolean;
  summary: string;
}

export function ProfileCard({ code, label, confident, summary }: ProfileCardProps) {
  const image = PROFILE_IMAGE[code];
  if (!image) return null;

  return (
    <div className="overflow-hidden rounded-2xl border border-border bg-card">
      <div className="flex flex-col sm:flex-row">
        <div className="relative aspect-square w-full shrink-0 bg-primary/[0.03] sm:aspect-auto sm:w-[38%]">
          <Image
            src={image.src}
            alt={image.alt}
            fill
            sizes="(min-width: 640px) 38vw, 100vw"
            className="object-contain p-6"
            priority={false}
          />
        </div>
        <div className="flex flex-1 flex-col justify-center gap-3 p-8">
          <p className="text-xs font-medium uppercase tracking-widest text-primary">
            Seu perfil
          </p>
          <h2 className="font-heading text-2xl font-medium text-foreground">{label}</h2>
          <p className="text-sm leading-relaxed text-muted-foreground">
            {confident
              ? `Seu perfil predominante é ${label.replace("Perfil ", "")}.`
              : `Seu resultado aponta para um perfil ${label.replace("Perfil ", "")}, ainda com poucas evidências.`}
          </p>
          <p className="text-sm leading-relaxed text-foreground/90 border-t border-dashed border-border pt-3">
            {summary}
          </p>
        </div>
      </div>
    </div>
  );
}
