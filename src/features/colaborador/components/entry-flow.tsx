"use client";

import { useState } from "react";
import { WelcomeCard } from "@/features/colaborador/components/welcome-card";
import { ParticipantForm } from "@/features/colaborador/components/participant-form";
import type { Application } from "@/types/database.types";

type Step = "welcome" | "form";

interface EntryFlowProps {
  application: Application;
  token: string;
}

export function EntryFlow({ application, token }: EntryFlowProps) {
  const [step, setStep] = useState<Step>("welcome");

  return (
    <div className="flex min-h-dvh items-center justify-center bg-background px-4 py-12">
      {step === "welcome" ? (
        <WelcomeCard onStart={() => setStep("form")} />
      ) : (
        <ParticipantForm
          applicationId={application.id}
          token={token}
          onBack={() => setStep("welcome")}
        />
      )}
    </div>
  );
}
