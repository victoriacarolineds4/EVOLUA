// ============================================================
// EVOLUA — Motor — Camada de Tradução (RASCUNHO p/ validação)
// ============================================================
// Traduz os atributos do diagnóstico em AÇÕES de gestão, na
// linguagem do empresário. É conteúdo determinístico (regra, não IA):
// dado o atributo predominante, entrega o texto correspondente.
//
// Redigido em linguagem NEUTRA de gênero (adjetivos ligados a "perfil",
// sem pronomes "ela/dela"), para servir a qualquer colaborador.
// Rascunho para a Victoria validar e ajustar. Todo item responde
// "o que fazer" — nunca só descreve.
// ============================================================

export interface DiscGuidance {
  age: string; // frase-substantivo neutra: "um perfil ..."
  liderar: string;
  cobrar: string;
  feedback: string;
}
export const DISC_GUIDANCE: Record<string, DiscGuidance> = {
  D: {
    age: "um perfil direto, decidido e focado em resultado",
    liderar: "Dê metas claras e autonomia; evite microgerenciar — o que importa é o resultado, não o processo.",
    cobrar: "Cobre por resultado e prazo, de forma objetiva; discussões longas desgastam.",
    feedback: "Seja direto e vá ao ponto, com exemplos concretos; franqueza é respeitada.",
  },
  I: {
    age: "um perfil comunicativo, entusiasta e movido por pessoas",
    liderar: "Dê visibilidade e espaço para influenciar; reconheça o trabalho diante do time.",
    cobrar: "Cobre com energia e proximidade; combine metas em conversa, não por mensagem fria.",
    feedback: "Comece pelo positivo e mantenha o tom leve; críticas duras paralisam.",
  },
  S: {
    age: "um perfil paciente, colaborativo e que evita conflito",
    liderar: "Dê segurança e previsibilidade; avise mudanças com antecedência.",
    cobrar: "Cobre com apoio, não com pressão; o rendimento vem de um ambiente estável.",
    feedback: "Seja gentil e específico; pergunte a opinião — nem sempre o incômodo é dito.",
  },
  C: {
    age: "um perfil analítico, preciso e orientado a critérios",
    liderar: "Dê contexto, dados e critérios claros; deixe dominar o assunto antes de executar.",
    cobrar: "Use prazos e critérios objetivos; evite pedir improviso de última hora.",
    feedback: "Baseie em fatos e dados; evite vaguidão — o porquê precisa ficar claro.",
  },
};

export interface MotivatorGuidance {
  motivar: string;
  reconhecer: string;
}
export const MOTIVATOR_GUIDANCE: Record<string, MotivatorGuidance> = {
  REC: {
    motivar: "Ligue o trabalho a visibilidade e valorização; mostre que o esforço é notado.",
    reconhecer: "Reconheça em público e de forma específica — elogio genérico não sustenta.",
  },
  CRE: {
    motivar: "Ofereça desafios que ampliem o papel e conectem à evolução na carreira.",
    reconhecer: "Reconheça abrindo o próximo passo — mais responsabilidade vale mais que elogio.",
  },
  PRO: {
    motivar: "Conecte as tarefas ao impacto e ao sentido maior do trabalho.",
    reconhecer: "Reconheça o impacto concreto que a entrega gerou em pessoas ou resultado.",
  },
  FIN: {
    motivar: "Ligue metas a retorno concreto e transparente; deixe a recompensa clara.",
    reconhecer: "Reconheça com retorno tangível (bônus, benefícios), não só com palavras.",
  },
  AUT: {
    motivar: "Dê liberdade para decidir e trabalhar do próprio jeito; evite controle excessivo.",
    reconhecer: "Reconheça ampliando a autonomia e a confiança em decisões.",
  },
  APR: {
    motivar: "Ofereça oportunidades de aprender e dominar coisas novas.",
    reconhecer: "Reconheça com acesso a conhecimento, mentoria ou projetos que ensinem.",
  },
  SEG: {
    motivar: "Ofereça estabilidade, clareza de expectativas e previsibilidade.",
    reconhecer: "Reconheça reforçando a confiança e a segurança no trabalho.",
  },
  DES: {
    motivar: "Dê metas difíceis e problemas complexos para resolver — é o que gera energia.",
    reconhecer: "Reconheça propondo o próximo desafio maior.",
  },
};

export interface StyleGuidance {
  trabalha: string;
  delegar: string;
}
export const STYLE_GUIDANCE: Record<string, StyleGuidance> = {
  EXE: {
    trabalha: "coloca em prática rapidamente, com foco em fazer acontecer",
    delegar: "Delegue entregas concretas com prazo — vira ação rápido.",
  },
  PLA: {
    trabalha: "organiza, estrutura e antecipa antes de agir",
    delegar: "Delegue com objetivo e dê espaço para estruturar; reserve tempo para planejar.",
  },
  ANA: {
    trabalha: "investiga e avalia dados e riscos antes de decidir",
    delegar: "Delegue com dados e contexto; não peça decisão sem informação.",
  },
  COL: {
    trabalha: "constrói junto e articula pessoas",
    delegar: "Delegue o que envolve o time — o rendimento vem de articular pessoas.",
  },
};

export interface TypeGuidance {
  pensa: string;
  comunicar: string;
  desenvolver: string;
}
export const TYPE_GUIDANCE: Record<string, TypeGuidance> = {
  EST: {
    pensa: "em sistema, lógica e longo prazo",
    comunicar: "Explique o porquê e a visão de conjunto antes dos detalhes.",
    desenvolver: "Envolva em decisões de rumo e problemas amplos.",
  },
  IDE: {
    pensa: "em propósito, valores e no potencial das pessoas",
    comunicar: "Conecte a mensagem a valores e ao impacto humano.",
    desenvolver: "Dê papéis que desenvolvam pessoas e conectem propósito.",
  },
  GUA: {
    pensa: "em ordem, responsabilidade e continuidade",
    comunicar: "Seja claro, estruturado e consistente.",
    desenvolver: "Dê responsabilidade sobre processos e reconheça a confiabilidade.",
  },
  ART: {
    pensa: "no concreto, no prático e no presente",
    comunicar: "Seja direto e prático; mostre o resultado tangível.",
    desenvolver: "Dê tarefas mãos-à-obra com retorno rápido; evite excesso de teoria.",
  },
};

/** Por pilar, quando é PONTO FORTE (score alto). */
export const PILLAR_STRENGTH: Record<number, string> = {
  1: "Demonstra responsabilidade e equilíbrio — conte com essa pessoa em situações que exigem maturidade.",
  2: "Comunica-se com clareza — pode ser sua ponte com o time e com outras áreas.",
  3: "Constrói bons relacionamentos — acione para unir o time e mediar tensões.",
  4: "Entrega com foco e qualidade — confie metas exigentes.",
  5: "Tem perfil de liderança — dê espaço para influenciar e desenvolver pessoas.",
  6: "Adapta-se e propõe melhorias — envolva em mudanças e novos desafios.",
  7: "Busca evoluir constantemente — dê acesso a aprendizado e novos projetos.",
};

/** Por pilar, quando é PONTO DE ATENÇÃO (score baixo) — como desenvolver. */
export const PILLAR_ATTENTION: Record<number, string> = {
  1: "Trabalhe a autogestão: combine rotinas, prazos e momentos de autoavaliação.",
  2: "Desenvolva a comunicação: dê espaço seguro para se expressar e feedback sobre clareza.",
  3: "Fortaleça o relacionamento: incentive colaboração e construção de confiança no time.",
  4: "Apoie foco e organização: ajude a priorizar e a proteger a qualidade sob pressão.",
  5: "Desenvolva liderança: dê pequenas decisões e delegações com suporte próximo.",
  6: "Estimule a adaptação: exponha a mudanças de baixo risco e a novas formas de fazer.",
  7: "Incentive o desenvolvimento: combine um plano de aprendizado com metas claras.",
};

/** Rótulos de perfil por DISC predominante (nome amigável do perfil). */
export const PROFILE_LABEL: Record<string, string> = {
  D: "Perfil Realizador",
  I: "Perfil Comunicador",
  S: "Perfil Colaborativo",
  C: "Perfil Analítico",
};
