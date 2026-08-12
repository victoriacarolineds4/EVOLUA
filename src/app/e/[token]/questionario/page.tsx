import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import type { Metadata } from "next";
import {
  getResponseById,
  getQuestionByOrderIndex,
  getAlternativesByQuestion,
  getTotalActiveQuestions,
  getApplicationIdByToken,
} from "@/services/questionnaire.service";
import { QuestionnaireView } from "@/features/colaborador/components/questionnaire-view";
import { CompletionScreen } from "@/features/colaborador/components/completion-screen";

export const metadata: Metadata = {
  title: "Questionário — EVOLUA",
};

interface Props {
  params: Promise<{ token: string }>;
}

export default async function QuestionarioPage({ params }: Props) {
  const { token } = await params;

  // Identifica a jornada via cookie httpOnly (sem expor ID na URL)
  const cookieStore = await cookies();
  const responseId = cookieStore.get("evolua_rid")?.value;

  if (!responseId) {
    redirect(`/e/${token}`);
  }

  const response = await getResponseById(responseId);

  if (!response) {
    redirect(`/e/${token}`);
  }

  // Garante que o cookie pertence à mesma aplicação deste link
  const applicationId = await getApplicationIdByToken(token);
  if (!applicationId || response.application_id !== applicationId) {
    redirect(`/e/${token}`);
  }

  // Jornada concluída
  if (response.status === "completed") {
    return <CompletionScreen />;
  }

  const [totalQuestions, question] = await Promise.all([
    getTotalActiveQuestions(),
    getQuestionByOrderIndex(response.current_question),
  ]);

  // Sem questões disponíveis (banco vazio ou todas inativas)
  if (!question || totalQuestions === 0) {
    return <CompletionScreen />;
  }

  const alternatives = await getAlternativesByQuestion(question.id);

  return (
    // key força remount do Client Component a cada questão, resetando a seleção
    <QuestionnaireView
      key={question.id}
      responseId={response.id}
      currentQuestion={response.current_question}
      answeredCount={response.progress}
      question={question}
      alternatives={alternatives}
      totalQuestions={totalQuestions}
      token={token}
    />
  );
}
