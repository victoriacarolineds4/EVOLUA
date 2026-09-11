# EVOLUA — Proposta de Expansão para 40 Situações (28 + 12)

**Versão:** 2 — refinamento metodológico (11/09/2026), a partir da rodada de revisão solicitada sobre a v1.
**Status:** aprovada como **base de trabalho**, **não aprovada para implementação**.
**Natureza:** proposta metodológica para revisão. **Nada foi aplicado ao banco, ao motor, ao relatório ou ao frontend.** As 28 situações, 112 alternativas, 7 pilares e 35 indicadores existentes não foram alterados — nem no conteúdo, nem no mapeamento.
**Fonte diagnóstica:** `EVOLUA_METODOLOGIA_V2.md` e `ANALISE_PROFUNDA_SINAL_COMPORTAMENTAL.md`. Cobertura **reconferida diretamente em produção** nesta rodada (ver Seção 2) — não assumida a partir da v1.

---

## 1. Objetivo da expansão

Sem mudança em relação à v1: 21 dos 35 indicadores têm evidência genuína em 2 situações ou menos porque cada um depende de uma única situação "dedicada", sem uma segunda oportunidade de observar o mesmo comportamento em outro contexto. As 12 novas situações existem para dar essa segunda oportunidade — não para fechar número.

**O que mudou nesta rodada:** o padrão de rigor na hora de decidir se um vínculo secundário "sobrevive" foi elevado. Vários vínculos secundários da v1 foram cortados por não passarem no teste "isso é comportamento específico e independente, ou é só proximidade temática disfarçada de link?". O resultado é uma proposta com **menos cobertura nominal, mas mais defensável** — exatamente o trade-off pedido.

---

## 2. Reconferência numérica (direto da produção, não assumido da v1)

Reconsultei a tabela `alternative_indicators` ao vivo em produção nesta rodada (via sessão autenticada — a tabela é bloqueada para `anon` por RLS) e comparei, vínculo a vínculo, contra os dados usados na análise anterior.

**Total de vínculos em produção: 140.** Comparação byte-a-byte (alternativa + indicador + força) contra o conjunto usado na v1: **0 divergências** — os 140 vínculos são idênticos aos já analisados. Não houve mudança no banco entre a v1 e esta rodada (esperado, já que nada foi aplicado). Reconto a cobertura por indicador (situações distintas) diretamente desse conjunto:

| Indicador | Situações atuais | Grupo atual |
|---|---:|---|
| I01 Gestão do Tempo | 1 | C |
| I02 Priorização | 4 | A |
| I03 Planejamento | 4 | A |
| I04 Consistência na Rotina | 0 | C |
| I05 Fechamento de Ciclos | 1 | C |
| I06 Assunção de Erros | 1 | C |
| I07 Proatividade diante de Falhas | 4 | A |
| I08 Transparência sobre Atrasos | 1 | C |
| I09 Aceitação de Responsabilidade | 3 | A |
| I10 Cuidado com Impacto no Outro | 2 | B |
| I11 Abertura a Mudança | 2 | B |
| I12 Disposição para o Novo | 4 | A |
| I13 Receptividade a Feedback | 2 | B |
| I14 Autodesenvolvimento | 4 | A |
| I15 Flexibilidade Cognitiva | 1 | C |
| I16 Disposição para Ajudar | 3 | A |
| I17 Acolhimento | 2 | B |
| I18 Mediação de Conflitos | 1 | C |
| I19 Tolerância à Diferença | 2 | B |
| I20 Construção de Confiança | 0 | D |
| I21 Iniciativa de Comunicação | 3 | A |
| I22 Transparência com Liderança | 2 | B |
| I23 Pedido de Ajuda | 6 | A |
| I24 Clareza na Orientação | 3 | A |
| I25 Adaptação da Mensagem | 3 | A |
| I26 Autonomia sob Pressão | 1 | C |
| I27 Gestão de Múltiplas Demandas | 3 | A |
| I28 Lida com Insatisfação | 1 | C |
| I29 Decisão com Informação Limitada | 2 | B |
| I30 Estabilidade sob Pressão | 3 | A |
| I31 Busca por Crescimento | 1 | C |
| I32 Disposição para Ensinar | 1 | C |
| I33 Integridade | 3 | A |
| I34 Uso da Autonomia | 1 | C |
| I35 Compromisso com Evolução | 1 | D |

**Resumo atual: Grupo A = 14 · Grupo B = 7 · Grupo C = 12 · Grupo D = 2.** Idêntico à v1 — confirmado, não assumido.

**Prioridades (inalteradas):** Prioridade 1 (0-1 situação) = I01, I04, I05, I06, I08, I15, I18, I26, I28, I31, I32, I34 (12, um alvo principal por situação nova). Prioridade 2 (2 situações) = I10, I11, I13, I17, I19, I22, I29. I20/I35 tratados à parte (Seção 6).

---

## 3. O que mudou nesta rodada — resumo

| Situação | Alterada? | O que mudou |
|---|---|---|
| S29 | ✅ Reescrita | Contexto trocado de "reunião cancelada" (ainda muito próximo de S1) para "semana com tarefas travadas esperando terceiros" — gatilho estrutural/sustentado, não mais um evento pontual de tempo livre. Vínculo opcional a I03 removido. Agora só I01. |
| S30 | ✅ Reescrita | Alternativa C trocada: não mede mais I15 (Flexibilidade Cognitiva) — agora as 4 alternativas são 4 graus/padrões diferentes de consistência (manter / relaxar de imediato / relaxar progressivamente / manter o essencial). Único indicador: I04. |
| S31 | ✅ Ajustada | Vínculo secundário a I14 (Autodesenvolvimento) removido da alternativa D — não era necessário (I14 já é Grupo A robusto) e não sobrevivia ao teste de precisão. Único indicador: I05. |
| S32 | Mantida | Sem alteração — I06 principal + I13 secundário na alternativa D já sobreviviam ao teste de construto. |
| S33 | Mantida | Sem alteração — I08 principal + I10 secundário na alternativa A já sobreviviam ao teste. |
| S34 | ✅ Ajustada | Vínculo secundário a I11 (Abertura a Mudança) removido da alternativa A — mudar de método de trabalho e "abrir-se a uma mudança de processo" são próximos demais para contar como evidência independente; não sobrevivia ao teste. Único indicador: I15. |
| S35 | Mantida | Sem alteração — I18 principal + I19 secundário na alternativa C já sobreviviam ao teste. |
| S36 | Mantida | Sem alteração — já era só I26. |
| S37 | ✅ Ajustada | **I22 (Transparência com Liderança) removido da alternativa A**, conforme instrução explícita. Mantidos I28 (principal) e I13 (secundário) — "perguntar o que esperava diferente" segue sendo evidência de receptividade a feedback por si só, independente de quem está dando o feedback ser o líder. |
| S38 | ✅ Ajustada | **Vínculo secundário a I35 removido da alternativa A.** Reavaliado com rigor: mesmo sendo a melhor aproximação possível, continua sendo um único ponto de dado, não um padrão contínuo — não sobrevive ao teste de construto para o que I35 realmente exige. Único indicador: I31. |
| S39 | Mantida | Sem alteração — já era só I32. |
| S40 | ✅ Redesenhada por completo | Trocado o construto do gatilho: não é mais "autonomia ambígua/não concedida" (misturava uso de autonomia com necessidade de autorização) — agora é autonomia **já estabelecida e inquestionável** (gestão do próprio tempo de trabalho), testando graus de uso responsável dela. As 4 alternativas foram reescritas para serem comportamentalmente distintas (estruturado / dia-a-dia sem plano / foco seletivo no que rende mais rápido / revisão e ajuste periódico) — nenhuma duplicata tipo "pergunto antes" vs. "espero confirmação". Vínculo secundário a I29 removido — não há decisão com informação limitada nesta situação, só uso continuado de autonomia já garantida. Único indicador: I34. |

---

## 4. As 12 novas situações (versão refinada)

### S29 — Semana com tarefas travadas
**Situação:** Boa parte das suas tarefas desta semana está travada, esperando retorno de outras pessoas.

A) Uso o tempo livre para adiantar outras entregas que não dependem de ninguém.
B) Fico de olho esperando as respostas chegarem, sem começar mais nada.
C) Aproveito para resolver pendências pequenas que vinha adiando.
D) Aproveito para descansar, já que a semana ficou mais leve mesmo.

**Justificativa comportamental (teste de construto por alternativa) — revisada na Rodada 3 (Seção 16)**
- A → *O que a pessoa está fazendo?* Canaliza o tempo disponível para entregas substantivas que já existiam. *Observável a partir da escolha?* Sim. *Indicador?* **I01 Gestão do Tempo** (principal, força 3) — uso produtivo direto do tempo disponível.
- B → *O que faz?* Permanece parado esperando, sem redirecionar o tempo. *Indicador?* **I01** (força 1) — polo inverso direto da definição ("sem deixá-lo ocioso").
- C → *O que faz?* Também canaliza o tempo para trabalho real (pendências que já existiam), só que de escopo menor. *Indicador?* **I01** (força 2) — **nota de revisão:** a diferença de força em relação a A não é "C produz menos valor" (a definição de I01 não fala de valor/importância, só de uso produtivo vs. ocioso) — é que A endereça entregas centrais e C endereça backlog secundário já adiado; ambas são canalização real do tempo, a diferença é de escopo/intencionalidade, não de mérito.
- D → *O que faz?* Escolhe conscientemente não canalizar o tempo disponível para produção. *Indicador?* **I01** (força 1) — leitura estritamente definicional (tempo não convertido em produção, que é exatamente o que a definição de I01 descreve como "mal aproveitado"), não um julgamento sobre descansar ser uma escolha ruim em geral.

**Diferença real em relação a S1:** S1 testa uma reação pontual e auto-gerada ("terminei uma tarefa e sobrou tempo, o que faço agora, nesse instante?"). S29 testa um padrão sustentado ao longo de uma semana, com o bloqueio vindo de fora (dependência de terceiros), não da própria produtividade da pessoa — é um cenário de auto-gestão sob um tipo de restrição diferente, não uma paráfrase do mesmo gatilho.

**Indicadores priorizados:** I01 (1 situação → alvo principal para uma segunda).
**Ganho de cobertura:** I01 passa de 1 para 2 situações (S1 + S29) — Grupo C→B.

---

### S30 — Semana sem supervisão
**Situação:** Seu gestor viaja por uma semana e ninguém vai acompanhar de perto o seu dia a dia.

A) Sigo exatamente a mesma rotina, nos mesmos horários, como se meu gestor estivesse presente.
B) Relaxo o padrão desde o início, já que ninguém vai notar.
C) Mantenho a rotina no começo da semana, mas ela vai ficando mais solta perto do fim.
D) Mantenho os compromissos e prazos em dia, mas sou mais livre em como e quando organizo o resto do meu dia.

**Justificativa comportamental (teste de construto por alternativa) — revisada na Rodada 3 (Seção 16)**
- A → *O que faz?* Sustenta o padrão de organização integralmente, sem cobrança externa — nenhuma diferença perceptível em relação a uma semana supervisionada. *Indicador?* **I04 Consistência na Rotina** (principal, força 3) — é a própria definição.
- B → *O que faz?* Abandona o padrão assim que a cobrança externa desaparece. *Indicador?* **I04** (força 1) — polo inverso direto.
- C → *O que faz?* Começa consistente e degrada ao longo do tempo — padrão distinto de B (que já começa relaxado). *Indicador?* **I04** (força 1-2) — **nota de revisão:** reformulado para descrever um padrão comportamental neutro ("vai ficando mais solta"), não uma confissão de falha — a alternativa não é mais desenhada como autoacusação, é uma descrição de um padrão real e comum, tão válida quanto as demais.
- D → *O que faz?* Garante especificamente os compromissos e prazos (o resultado que mais importa externamente), flexibilizando só o "como" e "quando" do resto — consistência seletiva e ancorada em entregas, distinta de A (nenhuma flexibilização) por ter um critério claro do que é negociável e do que não é. *Indicador?* **I04** (força 2) — **nota de revisão:** reescrita para diferenciar de A de forma mais concreta (A = zero variação; D = variação só no que não afeta compromissos/prazos), evitando que as duas leiam como praticamente a mesma coisa.

**Por que a versão anterior foi corrigida:** a alternativa C da v1 ("testar um jeito diferente de se organizar") media um comportamento distinto — ajuste cognitivo diante do novo — que não é sobre manter ou não manter um padrão, é sobre mudar de método. Isso fazia a situação testar dois construtos diferentes ao mesmo tempo (I04 em 3 alternativas + I15 numa 4ª), o que dilui o que a situação realmente mede. A C atual mantém as 4 alternativas inteiramente dentro do mesmo construto (consistência sem cobrança), com 4 padrões reais e distintos de manutenção de rotina — nenhum indicador além de I04.

**Indicadores priorizados:** I04 (0 situações → alvo principal).
**Ganho de cobertura:** I04 sai de **0** para **1** situação genuína — ainda Grupo C (ver nota na Seção 7), mas deixa de ser zero absoluto.

---

### S31 — Fechamento de um projeto longo
**Situação:** Um projeto que você acompanhou por semanas está chegando ao fim.

A) Faço uma revisão completa antes de considerar encerrado.
B) Assim que a entrega principal sai, já parto para o próximo projeto.
C) Peço um fechamento formal com quem participou antes de considerar concluído.
D) Registro o que aprendi com o projeto antes de arquivar.

**Justificativa comportamental (teste de construto por alternativa)**
- A → *O que faz?* Revisão cuidadosa antes de concluir. *Indicador?* **I05 Fechamento de Ciclos** (principal, força 3) — match direto.
- B → *O que faz?* Avança sem fechar o ciclo. *Indicador?* **I05** (força 1) — polo inverso.
- C → *O que faz?* Busca fechamento formal via validação de terceiros. *Indicador?* **I05** (força 2).
- D → *O que faz?* Registra aprendizado antes de arquivar — ainda é um ato de fechamento consciente (marca o fim formalmente, com reflexão), não uma atividade de estudo à parte. *Indicador?* **I05** (força 2).

**Por que o vínculo secundário da v1 foi removido:** a alternativa D tinha um vínculo secundário a I14 Autodesenvolvimento ("registrar aprendizado" ≈ "buscar aprender"). No teste de construto, esse vínculo não sobrevive como independente — I14 já está robustamente coberto (Grupo A, 4 situações) e o comportamento central de D continua sendo sobre **fechar o ciclo**, não sobre buscar desenvolvimento ativamente. Era reforço de cobertura sem necessidade, cortado.

**Indicadores priorizados:** I05 (1 situação → alvo principal).
**Ganho de cobertura:** I05 passa de 1 para 2 situações (S4 + S31) — Grupo C→B.

---

### S32 — Erro apontado por outra pessoa
**Situação:** Alguém aponta, na frente do time, um erro que você cometeu.

A) Assumo na hora, mesmo sendo desconfortável.
B) Explico o contexto que levou ao erro antes de admitir.
C) Minimizo, dizendo que não foi bem assim.
D) Agradeço por terem apontado e corrijo depois.

**Justificativa comportamental (teste de construto por alternativa)**
- A → *O que faz?* Reconhece o erro sem se esconder, sob constrangimento público. *Indicador?* **I06 Assunção de Erros** (principal, força 3).
- B → *O que faz?* Justifica antes de assumir — forma mais defensiva de reconhecer. *Indicador?* **I06** (força 2).
- C → *O que faz?* Nega/minimiza o apontamento de terceiro. *Indicador?* **I06** (força 1) — polo inverso.
- D → *O que faz?* Aceita o apontamento com abertura e corrige depois. *Indicador?* **I06** (força 2, principal) — secundário **I13 Receptividade a Feedback** (força 2): ser confrontado com um erro por outra pessoa e reagir com "agradeço, vou corrigir" é, especificamente, o comportamento central de receber bem um feedback — não é proximidade temática, é o mesmo gesto observado por dois ângulos (assumir o erro / processar bem a crítica).

**Diferença real em relação a S6:** S6 é erro autodescoberto, sem testemunha. S32 é erro apontado por terceiro, publicamente, diante do time — pressão social distinta, testando se a reação muda quando o erro vem à tona por fora.

**Indicadores priorizados:** I06 (1 situação → alvo principal); I13 (2 situações, Grupo B → reforço secundário).
**Ganho de cobertura:** I06 passa de 1 para 2 (Grupo C→B). I13 ganha uma situação a mais (ver total combinado na Seção 7, considerando também S37).

---

### S33 — Atraso causado por outra etapa
**Situação:** No meio de um projeto, você percebe que uma etapa anterior — que não dependia de você — vai atrasar tudo.

A) Aviso imediatamente todos os afetados, com uma nova estimativa.
B) Tento absorver o atraso sozinho, sem avisar ninguém.
C) Aviso só a pessoa responsável direta, não o grupo todo.
D) Espero para ver se ainda dá tempo de recuperar antes de avisar.

**Justificativa comportamental (teste de construto por alternativa)**
- A → *O que faz?* Comunica proativamente, especificamente para **todos os afetados**. *Indicador?* **I08 Transparência sobre Atrasos** (principal, força 3) — secundário **I10 Cuidado com Impacto no Outro** (força 1): o detalhe "todos os afetados" (em vez de só "avisa") é o que torna esse vínculo defensável — a alternativa explicitamente descreve considerar quem sofre o efeito, não só cumprir o protocolo de avisar.
- B → *O que faz?* Absorve sozinho, sem comunicar. *Indicador?* **I08** (força 1) — polo inverso.
- C → *O que faz?* Comunica parcialmente (só o responsável direto). *Indicador?* **I08** (força 2).
- D → *O que faz?* Adia o aviso para ver se recupera. *Indicador?* **I08** (força 2).

**Diferença real em relação a S7:** S7 é atraso causado pela própria pessoa. S33 é atraso causado por terceiros, que ela decide (ou não) comunicar mesmo sem culpa própria — testa a disposição à transparência quando não há constrangimento pessoal envolvido, um ângulo genuinamente diferente.

**Indicadores priorizados:** I08 (1 situação → alvo principal); I10 (2 situações, Grupo B → reforço secundário).
**Ganho de cobertura:** I08 passa de 1 para 2 (Grupo C→B). I10 passa de 2 para 3 (Grupo B→A).

---

### S34 — Uma forma de trabalhar que parou de funcionar
**Situação:** Um jeito de trabalhar que sempre deu certo para você para de funcionar bem num contexto novo (outro time, outro tipo de projeto).

A) Mudo de abordagem rapidamente para me adaptar.
B) Insisto na mesma abordagem, tentando fazer funcionar.
C) Misturo o jeito antigo com elementos novos, testando aos poucos.
D) Busco entender por que não está funcionando antes de mudar qualquer coisa.

**Justificativa comportamental (teste de construto por alternativa)**
- A → *O que faz?* Ajusta rapidamente a própria forma de trabalhar diante do novo. *Indicador?* **I15 Flexibilidade Cognitiva** (principal, força 3) — definição central.
- B → *O que faz?* Insiste no método antigo, mesmo sem funcionar. *Indicador?* **I15** (força 1) — polo inverso.
- C → *O que faz?* Ajusta de forma gradual, misturando velho e novo. *Indicador?* **I15** (força 2).
- D → *O que faz?* Investiga antes de mudar — ajuste mais analítico. *Indicador?* **I15** (força 2).

**Por que o vínculo secundário da v1 foi removido:** a alternativa A tinha um vínculo secundário a I11 Abertura a Mudança. No teste de construto, esse vínculo não sobrevive como independente: "mudar de abordagem rapidamente diante de um método que parou de funcionar" e "reagir a mudanças de processo com adaptação" (definição de I11) estão medindo essencialmente o mesmo tipo de reação — a diferença de gatilho (método próprio vs. mudança imposta pela empresa) não é suficiente para tratar como evidência independente quando é a MESMA alternativa gerando os dois sinais. Era proximidade temática disfarçada de vínculo, cortado.

**Indicadores priorizados:** I15 (1 situação → alvo principal).
**Ganho de cobertura:** I15 passa de 1 para 2 (Grupo C→B).

---

### S35 — Conflito de ideias numa reunião
**Situação:** Duas pessoas do seu time discordam fortemente sobre como resolver um problema, e a discussão está esquentando numa reunião.

A) Intervenho na hora, propondo um jeito de decidir.
B) Deixo esfriar e volto ao assunto depois.
C) Peço que cada um explique o ponto de vista antes de decidirmos juntos.
D) Decido por conta própria para encerrar a discussão.

**Justificativa comportamental (teste de construto por alternativa)**
- A → *O que faz?* Age construtivamente no momento do conflito. *Indicador?* **I18 Mediação de Conflitos** (principal, força 3).
- B → *O que faz?* Adia a mediação. *Indicador?* **I18** (força 1).
- C → *O que faz?* Estrutura a mediação pedindo que cada lado explique antes de decidir junto. *Indicador?* **I18** (força 3, principal) — secundário **I19 Tolerância à Diferença** (força 1): pedir explicitamente para ouvir os dois pontos de vista divergentes antes de agir é o comportamento central dessa definição, não proximidade — a alternativa descreve especificamente o ato de acolher a diferença de raciocínio antes de decidir.
- D → *O que faz?* Decide sozinho para encerrar, sem mediar de fato. *Indicador?* **I18** (força 1).

**Diferença real em relação a S15:** S15 é conflito interpessoal já instalado, observado de fora entre dois colegas. S35 é conflito de ideias ao vivo, numa reunião, com uma decisão pendente — testa mediação sob pressão de tempo e com stake na decisão, ângulo distinto.

**Indicadores priorizados:** I18 (1 situação → alvo principal); I19 (2 situações, Grupo B → reforço secundário).
**Ganho de cobertura:** I18 passa de 1 para 2 (Grupo C→B). I19 passa de 2 para 3 (Grupo B→A).

---

### S36 — Oportunidade com o líder inacessível
**Situação:** Surge uma boa oportunidade (fechar algo importante com um cliente, por exemplo), mas seu líder está inacessível e a janela de tempo é curta.

A) Decido e aproveito a oportunidade sozinho.
B) Deixo passar por não ter aval.
C) Tento adiar a decisão até conseguir falar com o líder, mesmo que isso signifique perder a chance.
D) Decido sozinho, mas de um jeito que dá pra desfazer se não der certo.

**Justificativa comportamental (teste de construto por alternativa) — revisada na Rodada 3 (Seção 16)**
- A → *O que faz?* Decide e age sem liderança presente. *Indicador?* **I26 Autonomia sob Pressão** (principal, força 3).
- B → *O que faz?* Deixa passar por falta de aval — não age. *Indicador?* **I26** (força 1) — polo inverso.
- C → *O que faz?* Evita explicitamente a ação autônoma, priorizando esperar o aval mesmo ao custo reconhecido de perder a oportunidade. *Indicador?* **I26** (força 1) — **nota de revisão:** o texto foi reforçado para deixar claro que o comportamento central é *não decidir sozinho* (o núcleo do polo baixo de I26), e não "prudência" como qualidade de julgamento — a alternativa explicita o custo assumido (perder a chance) para não deixar dúvida de que a pessoa optou por não exercer autonomia, e não que fez uma escolha estratégica superior.
- D → *O que faz?* Ainda decide sozinho — o verbo central continua sendo "decidir", a condição reversível é só um qualificador de como a autonomia é exercida, não uma ação diferente. *Indicador?* **I26** (força 2) — **nota de revisão:** reescrito para manter "decido sozinho" como sujeito da frase (não "decido, mas com uma condição..."), evitando que o foco pareça estar na gestão de risco da decisão em vez de no ato de decidir sem o líder. A força permanece menor que A porque o grau de autonomia plenamente exercida é menor (decide com uma salvaguarda), não porque a decisão em si seja "melhor ou pior".

**Diferença real em relação a S21:** S21 é um *problema* a resolver sem líder presente. S36 é uma *oportunidade* a aproveitar — mesmo construto (autonomia sob pressão, sem liderança acessível), gatilho emocional e prático diferente (evitar prejuízo vs. capturar ganho), independente o suficiente.

**Indicadores priorizados:** I26 (1 situação → alvo principal).
**Ganho de cobertura:** I26 passa de 1 para 2 (Grupo C→B).

---

### S37 — Líder insatisfeito com uma entrega
**Situação:** Seu líder diz que não ficou satisfeito com uma entrega sua.

A) Ouço com calma e pergunto o que ele esperava diferente.
B) Fico na defensiva, justificando antes de ouvir tudo.
C) Concordo rápido demais só para encerrar o desconforto.
D) Peço um tempo para processar e volto depois com uma resposta.

**Justificativa comportamental (teste de construto por alternativa)**
- A → *O que faz?* Ouve com calma e busca entender especificamente o que se esperava. *Indicador?* **I28 Lida com Insatisfação** (principal, força 3) — secundário **I13 Receptividade a Feedback** (força 2): perguntar "o que esperava diferente" é, no conteúdo do gesto, buscar entender uma crítica para aplicá-la — o mesmo comportamento central de I13, independente de quem está dando o feedback. **Removido nesta rodada:** o vínculo secundário a I22 Transparência com Liderança que existia na v1. Reavaliado com rigor: "engajar bem com uma crítica" não é, por si, um ato de *transparência* (que é sobre a pessoa comunicar algo proativamente) — era vínculo por proximidade temática ("é com o líder, então conta pra I22"), não por comportamento específico. Cortado.
- B → *O que faz?* Fica na defensiva. *Indicador?* **I28** (força 1) — polo inverso.
- C → *O que faz?* Concorda rápido para evitar o desconforto, sem processar de verdade. *Indicador?* **I28** (força 1).
- D → *O que faz?* Pede tempo e volta com uma resposta processada. *Indicador?* **I28** (força 2).

**Diferença real em relação a S23:** S23 é cliente externo insatisfeito. S37 é o próprio líder — dinâmica de poder e vulnerabilidade diferentes, testando o mesmo construto (lidar com insatisfação) num contexto onde a pessoa também depende dessa relação para crescer na empresa.

**Indicadores priorizados:** I28 (1 situação → alvo principal); I13 (2 situações, Grupo B → reforço secundário).
**Ganho de cobertura:** I28 passa de 1 para 2 (Grupo C→B). I13 ganha reforço (ver total combinado com S32 na Seção 7).

---

### S38 — Lacuna de conhecimento percebida por conta própria
**Situação:** Você percebe uma lacuna de conhecimento que está te limitando, mas ninguém pediu para você resolver isso.

A) Já começo a estudar por conta própria.
B) Espero surgir um treinamento oferecido pela empresa para resolver isso.
C) Busco alguém que domina o assunto para me orientar nos estudos.
D) Anoto para resolver quando "tiver mais tempo".

**Justificativa comportamental (teste de construto por alternativa) — revisada na Rodada 3 (Seção 16)**
- A → *O que faz?* Busca crescimento por iniciativa própria, sem esperar que a oportunidade seja oferecida. *Indicador?* **I31 Busca por Crescimento** (principal, força 3). **Removido na rodada anterior:** o vínculo secundário a I35 Compromisso com Evolução que existia na v1 — um único ponto de dado não evidencia um padrão contínuo.
- B → *O que faz?* Espera uma oportunidade formal. *Indicador?* **I31** (força 1) — polo passivo.
- C → *O que faz?* Busca alguém experiente para orientar seu processo de aprendizado — busca crescimento por via mediada. *Indicador?* **I31** (força 2). **Análise de sobreposição com I23 Pedido de Ajuda (Rodada 3):** o texto anterior ("peço orientação de alguém que já sabe") era lexicalmente muito próximo de "pedir ajuda", correndo o risco real de evidenciar I23 em vez de/além de I31. Reescrevi para deslocar o foco para o mecanismo de aprendizado ("buscar alguém pra me orientar nos estudos") em vez do ato de pedir em si. Ainda assim, reconheço a sobreposição conceitual como parcialmente inevitável — buscar um mentor sempre envolve, no nível mais literal, solicitar algo de alguém. A diferença que sustento como metodologicamente válida: **I23** (S19, "Preciso pedir ajuda") descreve reconhecer um limite que está **bloqueando uma tarefa em andamento** e pedir para destravá-la — um gatilho reativo, de necessidade imediata. **S38-C** descreve buscar um guia de aprendizado para uma lacuna que a pessoa **identificou proativamente**, sem estar travada em nada agora — um gatilho de iniciativa de crescimento, não de necessidade urgente. Por essa distinção de gatilho e de função do comportamento (resolver um bloqueio vs. investir em desenvolvimento), **não adiciono o vínculo a I23** — mas registro a sobreposição explicitamente em vez de ignorá-la, conforme pedido.
- D → *O que faz?* Adia por falta de tempo. *Indicador?* **I31** (força 1).

**Diferença real em relação a S25:** S25 é uma oportunidade de crescimento *oferecida* a ela. S38 exige que ela mesma *identifique* a lacuna e decida agir sem que ninguém peça — testa o mesmo construto num gatilho mais autônomo e mais exigente.

**Indicadores priorizados:** I31 (1 situação → alvo principal).
**Ganho de cobertura:** I31 passa de 1 para 2 (Grupo C→B). **I35 não ganha nenhum reforço nesta versão** (ver Seção 6).

---

### S39 — Ensinar sem ser pedido
**Situação:** Você domina algo que seria útil para um colega de outra área, mas ele não pediu ajuda.

A) Ofereço ensinar mesmo sem ele ter pedido.
B) Espero ele pedir — não quero parecer intrometido.
C) Mando um material ou link em vez de ensinar pessoalmente.
D) Menciono que sei fazer aquilo, mas só ensino se ele insistir.

**Justificativa comportamental (teste de construto por alternativa)**
- A → *O que faz?* Se dispõe a ensinar por iniciativa própria. *Indicador?* **I32 Disposição para Ensinar** (principal, força 3).
- B → *O que faz?* Espera ser solicitado. *Indicador?* **I32** (força 1) — polo passivo.
- C → *O que faz?* Oferece um caminho indireto (material, não ensino pessoal). *Indicador?* **I32** (força 2).
- D → *O que faz?* Menciona, mas condiciona o ensino à insistência do outro. *Indicador?* **I32** (força 2).

**Diferença real em relação a S26:** S26 parte de um pedido explícito para ensinar. S39 testa a disposição quando ninguém pede — ângulo genuinamente distinto do mesmo construto.

**Indicadores priorizados:** I32 (1 situação → alvo principal).
**Ganho de cobertura:** I32 passa de 1 para 2 (Grupo C→B).

---

### S40 — Uso contínuo de uma autonomia já estabelecida (REDESENHADA)
**Situação:** Você tem total autonomia para decidir como organizar seu próprio tempo de trabalho ao longo da semana — ninguém define isso por você.

A) Estruturo meu tempo com metas claras para cada dia.
B) Vou decidindo dia a dia, conforme surge, sem um plano fixo.
C) Uso a liberdade para me dedicar mais ao que gosto de fazer, mesmo deixando outras partes do trabalho de lado.
D) Reviso periodicamente como estou usando esse tempo e ajusto o que não está funcionando.

**Justificativa comportamental (teste de construto por alternativa) — revisada na Rodada 3 (Seção 16)**
- A → *O que a pessoa está fazendo?* Usa a autonomia já garantida de forma estruturada e planejada. *Indicador?* **I34 Uso da Autonomia** (principal, força 3). *Por que este e não outro?* Não há decisão sob incerteza, não há dilema ético, não há questão de permissão — a autonomia já é dada, o que se observa é só como ela é exercida.
- B → *O que faz?* Usa a mesma autonomia de forma mais fluida, sem plano fixo. *Indicador?* **I34** (força 2) — estilo diferente de exercício da mesma autonomia, não "errado".
- C → *O que faz?* Usa a liberdade para restringir o escopo do que faz, guiado por preferência pessoal, deixando outras partes do trabalho sem a mesma atenção. *Indicador?* **I34** (força 1) — **nota de revisão:** o texto anterior ("focar no que rende resultado mais rápido") usava linguagem de critério de prioridade/velocidade de resultado, que se aproxima perigosamente de I02 Priorização ou I01 Gestão do Tempo — o risco era estar testando uma técnica de produtividade disfarçada de uso de autonomia. Reescrevi trocando o critério de escolha de "o que rende mais rápido" (prioritização) para "o que eu gosto de fazer" (preferência pessoal) — o comportamento observado passa a ser exclusivamente sobre *como a liberdade é usada* (de forma auto-centrada, cobrindo menos do escopo completo), sem nenhum vocabulário de ordenação de tarefas ou gestão de tempo. Único indicador: I34.
- D → *O que faz?* Usa a autonomia de forma reflexiva, revisando e ajustando periodicamente. *Indicador?* **I34** (força 3) — **confirmação de revisão:** verificado que A (estruturar com metas) e D (revisar e ajustar) são dois mecanismos genuinamente distintos de uso responsável — um é planejamento antecipado, o outro é monitoramento contínuo — e ambos merecem força alta por representarem, cada um à sua maneira, uso completo e responsável da autonomia. Mantidos como estavam.

**Por que a versão anterior foi completamente redesenhada:** a v1 testava autonomia *ambígua/não formalmente concedida* ("ninguém disse nem que sim, nem que não"), o que misturava I34 com a necessidade de autorização/permissão — um construto diferente (mais próximo de assertividade ou de tolerância à ambiguidade de papel do que de "uso responsável de uma autonomia que já se tem"). A instrução foi explícita: observar o uso responsável de uma autonomia que a pessoa **efetivamente possui**. A nova versão remove qualquer ambiguidade sobre se a autonomia existe — ela é dada como fato no enunciado — e as 4 alternativas passam a variar exclusivamente no *como* ela é usada (estruturada / fluida / seletiva-parcial / reflexiva-ajustável), sem tocar em integridade, regras, obediência, autorização, coragem ou risco.

**Por que o vínculo secundário a I29 foi removido:** a v1 linkava a alternativa "testa a mudança de um jeito pequeno e reversível" a I29 Decisão com Informação Limitada. Essa alternativa não existe mais no redesenho — e mesmo revisando o novo conjunto de 4 alternativas, nenhuma delas envolve decidir com informação incompleta; todas são sobre um padrão contínuo de uso de uma autonomia já certa, sem elemento de incerteza informacional. Vínculo não recriado.

**Diferença real em relação a S28:** S28 testa a reação a **receber** uma autonomia nova para uma decisão importante pontual (evento único). S40 testa o uso **continuado** de uma autonomia que já é parte do dia a dia da pessoa (padrão de comportamento sustentado) — construtos relacionados, mas comportamentalmente distintos (reação a um evento vs. hábito estabelecido).

**Indicadores priorizados:** I34 (1 situação → alvo principal).
**Ganho de cobertura:** I34 passa de 1 para 2 (Grupo C→B). **I29 não ganha reforço nesta versão** (diferença em relação à v1 — ver Seção 8).

---

## 5. Situações descartadas ou não usadas dessa forma

Nenhuma das 12 situações foi descartada por inteiro. Seis vínculos secundários foram removidos (ver Seção 3 e cada situação acima) por não sobreviverem ao teste de construto reforçado desta rodada: I03 (S29), I15 (S30), I14 (S31), I11 (S34), I22 (S37), I35 (S38), e o par I29/toda a S40 anterior foi substituído no redesenho.

---

## 6. I20 e I35 — reavaliação

**I20 Construção de Confiança** — inalterado. Nenhuma das 12 situações (incluindo as refinadas) tenta medir este indicador. O raciocínio da v1 permanece válido: qualquer situação de escolha única mediria "disposição a comportamentos que geram confiança", não "confiança de fato construída ao longo do tempo". Continua Grupo D, 0 situações, sem tentativa de correção via situação nova.

**I35 Compromisso com Evolução** — **nesta rodada, decidi remover completamente a tentativa de vínculo (S38-A) que existia na v1.** Reavaliei com o rigor pedido e a resposta honesta é: não encontrei, entre as 12 situações (nem mesmo com ajustes), um comportamento que evidencie um padrão *contínuo* de comprometimento com o próprio desenvolvimento a partir de uma única escolha. O que qualquer situação consegue capturar é, no máximo, "nesta situação específica, a pessoa optou por investir em aprender" — que é uma boa evidência para I31 Busca por Crescimento (que já está sendo fortalecido), mas não para I35, cuja definição exige continuidade que uma única resposta não pode demonstrar. **I35 permanece exatamente como estava: 1 situação, Grupo D, sem nenhum reforço desta expansão.**

---

## 7. Matriz final de cobertura (projeção — nada aplicado)

| Indicador | Antes | Depois (projeção) | Grupo antes | Grupo projetado | Situações adicionadas | Observação |
|---|---:|---:|---|---|---|---|
| I01 Gestão do Tempo | 1 | 2 | C | B | S29 | |
| I04 Consistência na Rotina | 0 | 1 | C | C | S30 | sai de zero, mas 1 situação ainda é Grupo C — ver nota |
| I05 Fechamento de Ciclos | 1 | 2 | C | B | S31 | |
| I06 Assunção de Erros | 1 | 2 | C | B | S32 | |
| I08 Transparência sobre Atrasos | 1 | 2 | C | B | S33 | |
| I10 Cuidado com Impacto no Outro | 2 | 3 | B | A | S33 (secundário) | |
| I13 Receptividade a Feedback | 2 | 4 | B | A | S32 + S37 (secundários) | reforço duplo, ambos sobreviveram ao teste de construto |
| I15 Flexibilidade Cognitiva | 1 | 2 | C | B | S34 | |
| I18 Mediação de Conflitos | 1 | 2 | C | B | S35 | |
| I19 Tolerância à Diferença | 2 | 3 | B | A | S35 (secundário) | |
| I26 Autonomia sob Pressão | 1 | 2 | C | B | S36 | |
| I28 Lida com Insatisfação | 1 | 2 | C | B | S37 | |
| I31 Busca por Crescimento | 1 | 2 | C | B | S38 | |
| I32 Disposição para Ensinar | 1 | 2 | C | B | S39 | |
| I34 Uso da Autonomia | 1 | 2 | C | B | S40 | |
| I11 Abertura a Mudança | 2 | 2 | B | B | nenhuma | reforço da v1 (via S34) removido — não sobreviveu ao teste |
| I22 Transparência com Liderança | 2 | 2 | B | B | nenhuma | reforço da v1 (via S37) removido — não sobreviveu ao teste |
| I29 Decisão com Informação Limitada | 2 | 2 | B | B | nenhuma | reforço da v1 (via S40) removido — situação redesenhada não gera mais esse vínculo |
| I17 Acolhimento | 2 | 2 | B | B | nenhuma | não coube em nenhuma das 12 situações, igual à v1 |
| I35 Compromisso com Evolução | 1 | 1 | D | D | nenhuma | reforço da v1 (via S38) removido — ver Seção 6 |
| I20 Construção de Confiança | 0 | 0 | D | D | nenhuma | inalterado — ver Seção 6 |
| **Todos os demais 14 indicadores** (I02,I03,I07,I09,I12,I14,I16,I21,I23,I24,I25,I27,I30,I33) | — | — | inalterado | inalterado | nenhuma | fora do escopo desta rodada |

**Nota sobre I04:** mesma observação da v1 — 1 situação nova ainda não é suficiente para Grupo B (que exige 2). Continua tecnicamente Grupo C, com uma primeira evidência real em vez de zero absoluto.

---

## 8. Diferença objetiva em relação à v1

A v1 projetava **6 indicadores** subindo de Grupo B para Grupo A via reforço secundário (I10, I11, I13, I19, I22, I29). Após o refinamento, **apenas 3 sobrevivem** (I10, I13, I19) — **I11, I22 e I29 tiveram seus vínculos secundários removidos** por não passarem no teste de construto mais rigoroso pedido nesta rodada:

- **I11** (via S34): o vínculo dependia da mesma alternativa que já evidenciava I15, com definição conceitualmente sobreposta — proximidade temática, não independência real.
- **I22** (via S37): o vínculo existia só porque "o feedback vem do líder", não porque o comportamento descrito fosse especificamente sobre transparência com a liderança.
- **I29** (via S40): a situação que sustentava esse vínculo foi completamente redesenhada por instrução explícita (misturava I34 com necessidade de autorização) e o novo desenho não contém nenhum comportamento de decisão com informação limitada.

Isso significa que a projeção final é **mais conservadora** que a v1: 17 indicadores em Grupo A projetado (14 atuais + 3), não 20. É o resultado esperado de aplicar "prefira menos vínculos e maior precisão" de forma consistente — menos cobertura, mais defensável.

---

## 9. Resultado esperado (atualizado)

- **Total atual:** 28 situações, 112 alternativas.
- **Novas situações propostas:** 12 (S29-S40), 48 novas alternativas.
- **Total projetado:** 40 situações, 160 alternativas.
- **Indicadores fortalecidos:** 15 dos 35 — 12 com situação dedicada como alvo principal (I01, I04, I05, I06, I08, I15, I18, I26, I28, I31, I32, I34) + 3 com reforço secundário genuíno que os leva de Grupo B a Grupo A (I10, I13, I19).
- **Indicadores que passam a ter 3+ situações (Grupo A):** sobe de 14 para 17 (14 atuais + I10, I13, I19) — **40% → 49%** dos 35 indicadores.
- **Indicadores que saem do Grupo C:** 11 dos 12 alvos primários (todos exceto I04, que sai de 0 mas fica em C com 1).
- **Indicadores que continuam abaixo de 3 situações mesmo após a expansão:** I04 (1, ainda C), I11, I17, I22, I29 (todos com 2, Grupo B, sem reforço nesta rodada).
- **Indicadores que continuam com confiança estruturalmente limitada (Grupo D):** I20 (0, inalterado) e I35 (1, inalterado — nenhum vínculo sobreviveu ao teste desta rodada).
- **Situações que fortalecem mais de um indicador:** S32 (I06 + I13), S33 (I08 + I10), S35 (I18 + I19), S37 (I28 + I13). As demais 8 situações (S29, S30, S31, S34, S36, S38, S39, S40) evidenciam **um único indicador cada**, depois da remoção dos vínculos que não sobreviveram ao teste.
- **Situações descartadas por duplicidade ou supermapping:** nenhuma situação inteira — 6 vínculos secundários pontuais foram removidos (ver Seção 3).

---

## 10. Teste de qualidade obrigatório (revalidado)

| Situação | Diferenciada? | 4 alternativas plausíveis? | Sem resposta óbvia? | Sem duplicidade com S01-S28? | Links defensáveis? | Contexto independente? |
|---|---|---|---|---|---|---|
| S29 Semana com tarefas travadas | ✅ | ✅ | ✅ | ✅ (gatilho sustentado/externo, distinto do momento pontual de S1) | ✅ | ✅ rotina |
| S30 Semana sem supervisão | ✅ | ✅ | ✅ | ✅ | ✅ (link único, sem I15) | ✅ rotina/autonomia |
| S31 Fechamento de projeto longo | ✅ | ✅ | ✅ | ✅ | ✅ (link único, sem I14) | ✅ responsabilidade |
| S32 Erro apontado por outro | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ erro/feedback |
| S33 Atraso por etapa externa | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ responsabilidade |
| S34 Abordagem que parou de funcionar | ✅ | ✅ | ✅ | ✅ | ✅ (link único, sem I11) | ✅ mudança |
| S35 Conflito de ideias em reunião | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ conflito |
| S36 Oportunidade com líder inacessível | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ pressão/autonomia |
| S37 Líder insatisfeito | ✅ | ✅ | ✅ | ✅ | ✅ (I22 removido) | ✅ liderança |
| S38 Lacuna de conhecimento autoidentificada | ✅ | ✅ | ✅ | ✅ | ✅ (link único, sem I35) | ✅ crescimento |
| S39 Ensinar sem ser pedido | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ colaboração |
| S40 Uso contínuo de autonomia estabelecida | ✅ | ✅ | ✅ (nenhum "certo vs. errado"; C é uma faceta legítima, não um erro) | ✅ (redesenhada, distinta de S28) | ✅ (link único, sem I29; sem mistura com integridade/permissão) | ✅ autonomia |

Nenhuma pendência restante — a única ressalva da v1 (S37 com 3 vínculos) foi resolvida removendo I22.

---

## 11. Teste de supermapeamento (revalidado)

- Nenhuma situação foi criada exclusivamente para aumentar score.
- **6 vínculos secundários que não sobreviviam ao teste de "comportamento específico vs. proximidade temática" foram removidos** (I03/S29, I15/S30, I14/S31, I11/S34, I22/S37, I35/S38) — listados na íntegra na Seção 3.
- Nenhuma alternativa restante tem mais de 2 vínculos simultâneos (o caso de 3 vínculos da v1, em S37, foi resolvido cortando para 2).
- Dos 12 links secundários remanescentes na proposta (I13 em S32, I10 em S33, I19 em S35, I13 em S37), todos passaram no teste dos 5 critérios (o que a pessoa faz / é observável / qual indicador / por que este / é só proximidade) descrito junto a cada situação na Seção 4.

---

## 12. Teste de "resposta socialmente desejável" (revalidado)

- Situações revisadas com atenção redobrada para risco de moralização: S30 (o que faço quando ninguém está olhando) e S40 (como uso uma liberdade que já tenho).
- Em S40 especificamente, a alternativa C ("foco no que rende mais rápido, deixando outras coisas de lado") foi escrita deliberadamente para **não soar como "a resposta errada"** — é reescrita como uma escolha de critério de priorização plausível e comum, não como negligência.
- Nas demais situações, mantido o mesmo padrão das 28 originais: nenhuma alternativa "óbvia certa" versus alternativas "obviamente erradas".

---

## 13. Comparação final: S01-S28 vs. S29-S40

> **As S01–S28 não foram alteradas.**

Nenhum texto de situação, alternativa, indicador, pilar ou vínculo `alternative_indicators` existente foi tocado nesta proposta, em nenhuma das duas rodadas.

## OBSERVAÇÕES FUTURAS — NÃO ALTERADAS

- Mesma nota da v1 sobre S16-C (promoção de I25 a principal, recomendação da auditoria anterior) — decisão da consolidação v2, não desta proposta, não mexida.
- Nenhum problema novo identificado nas 28 situações existentes durante esta rodada de refinamento.

---

## 14. Confirmações finais

- ✅ Nenhuma situação, pilar ou indicador novo foi criado além das 12 já propostas — nenhuma 13ª situação.
- ✅ As 28 situações, 112 alternativas, 35 indicadores e 7 pilares existentes permanecem exatamente como estão.
- ✅ O motor, o relatório, o banco de dados e a produção **não foram alterados** — nenhuma migration, seed, ou mudança de código foi criada nesta rodada.
- ✅ Nenhuma fórmula, threshold ou lógica de agregação foi tocada ou proposta para mudar.
- ✅ Cobertura atual reconferida diretamente em produção nesta rodada (140 vínculos, idênticos byte-a-byte aos usados na v1 — sem divergência a explicar).

## 15. Limitações que continuam

1. **I04 Consistência na Rotina** — mesmo após S30, fica com 1 situação (Grupo C tecnicamente, não Grupo B). Resolver exigiria uma 13ª situação, fora do escopo aprovado.
2. **I17 Acolhimento** — não coube em nenhuma das 12 situações de forma genuína. Permanece em 2 situações (Grupo B), sem reforço.
3. **I11, I22, I29** — tinham reforço na v1, perderam nesta rodada por não sobreviverem ao teste de construto mais rigoroso. Permanecem em 2 situações (Grupo B) cada.
4. **I20** — permanece Grupo D, 0 situações, sem tentativa nesta ou em nenhuma rodada.
5. **I35** — permanece Grupo D, 1 situação, sem nenhum reforço (o único vínculo tentado foi removido por não sobreviver ao teste).

Nenhuma implementação foi feita. Aguardando decisão sobre os pontos acima antes de qualquer migration, seed ou mudança de código.

---

## 16. Rodada 3 — Validação final metodológica (11/09/2026)

Revisão solicitada especificamente sobre S29, S30, S36, S38 e S40, checando moralização, resposta obviamente correta e mistura de construto. As alternativas já refletidas na Seção 4 (acima) são a versão final; esta seção documenta o raciocínio de cada mudança no formato pedido.

### S29
- **Problema identificado:** a justificativa original de C e D presumia implicitamente que "produzir mais/em algo maior" é o que torna o uso do tempo melhor — a definição de I01 não fala de valor, só de uso produtivo vs. ocioso.
- **Risco metodológico:** pontuar C mais baixo que A só por endereçar tarefas "pequenas" introduziria um critério de julgamento (importância do trabalho) que não está na definição do indicador.
- **Alteração mínima proposta:** nenhuma alteração no texto das alternativas. Reescrita da justificativa para explicitar que a diferença A vs. C é de escopo/intencionalidade (entregas centrais vs. backlog secundário já adiado), não de valor/mérito. D também reescrita para deixar explícito que a leitura é definicional (tempo não convertido em produção), não um julgamento sobre descansar ser ruim.
- **Construto principal preservado:** I01 Gestão do Tempo, exclusivamente.
- **Indicadores afetados:** nenhuma mudança de indicador — só de justificativa.
- **Justificativa comportamental:** ver Seção 4, S29 (texto revisado).

### S30
- **Problema identificado:** (1) A e D podiam ler como praticamente a mesma coisa ("mesma rotina" vs. "essencial da rotina"); (2) C ("vou relaxando conforme a semana passa") tinha tom de confissão/autoacusação, mais que descrição neutra de padrão.
- **Risco metodológico:** baixa diferenciação real entre A/D reduz o poder discriminativo da situação; C moralizada pode gerar viés de resposta (pessoa evita escolher por parecer "admitir uma falha").
- **Alteração mínima proposta:** A reescrita para enfatizar ausência total de variação ("nos mesmos horários, como se o gestor estivesse presente"); D reescrita para ancorar a flexibilização especificamente no que não afeta compromissos/prazos (critério concreto, distinto de A); C reescrita para tom neutro/descritivo ("vai ficando mais solta perto do fim", sem linguagem de confissão).
- **Construto principal preservado:** I04 Consistência na Rotina, exclusivamente — nenhum outro indicador introduzido.
- **Indicadores afetados:** nenhum — mudança é só de texto/redação.
- **Justificativa comportamental:** ver Seção 4, S30 (texto revisado).

### S36
- **Problema identificado:** D ("condição segura/reversível") corria o risco de medir qualidade/gestão de risco da decisão, não autonomia em si; C ("tentar esticar o prazo") podia ler como prudência legítima, não como baixa autonomia.
- **Risco metodológico:** se D estivesse de fato medindo gestão de risco, isso introduziria um construto não declarado (próximo de julgamento/qualidade de decisão) dentro de uma situação rotulada como I26. Se C fosse lido como "sabedoria" em vez de "evitar decidir", a força atribuída (baixa) ficaria injustificada.
- **Alteração mínima proposta:** D reescrita para manter "decido sozinho" como sujeito explícito da frase, com a condição reversível como qualificador secundário, não o foco. C reescrita para tornar explícito o custo assumido ("mesmo que isso signifique perder a chance"), deixando claro que o comportamento central é evitar a ação autônoma, não fazer uma escolha estrategicamente superior.
- **Construto principal preservado:** I26 Autonomia sob Pressão, exclusivamente.
- **Indicadores afetados:** nenhum — mudança é só de texto/redação.
- **Justificativa comportamental:** ver Seção 4, S36 (texto revisado).

### S38
- **Problema identificado:** a alternativa C ("peço orientação de alguém que já sabe") tem sobreposição lexical real com I23 Pedido de Ajuda.
- **Risco metodológico:** deixar o texto como estava poderia gerar um vínculo defensável a I23 que eu não havia declarado — ambiguidade de construto não resolvida.
- **Alteração mínima proposta:** reescrita de C para deslocar o foco do "pedir" para o mecanismo de aprendizado mediado ("busco alguém que domina o assunto para me orientar nos estudos"). **Vínculo a I23 avaliado e não adicionado** — sobreposição reconhecida e documentada explicitamente na Seção 4 (não ignorada): a diferença sustentada é de gatilho (S19/I23 = bloqueio reativo numa tarefa em andamento; S38-C = iniciativa proativa de crescimento, sem bloqueio atual).
- **Construto principal preservado:** I31 Busca por Crescimento.
- **Indicadores afetados:** nenhum vínculo novo adicionado; I23 explicitamente considerado e descartado, com justificativa registrada.
- **Justificativa comportamental:** ver Seção 4, S38 (texto revisado, com nota de sobreposição).

### S40
- **Problema identificado:** a alternativa C ("focar no que rende resultado mais rápido") usava linguagem de priorização/gestão de tempo, arriscando medir I01/I02/I03 em vez de I34.
- **Risco metodológico:** se o comportamento central fosse "escolher a tarefa de retorno mais rápido", isso é literalmente a definição operacional de I02 Priorização — a situação estaria testando dois construtos com um rótulo só.
- **Alteração mínima proposta:** C reescrita trocando o critério de escolha de "o que rende mais rápido" (linguagem de priorização) para "o que eu gosto de fazer" (preferência pessoal) — o comportamento evidenciado passa a ser exclusivamente sobre *como a autonomia é usada* (de forma auto-centrada e parcial), sem vocabulário de ordenação de tarefas.
- **A e D:** verificados como dois mecanismos genuinamente distintos e igualmente válidos de uso responsável (estrutura antecipada vs. monitoramento contínuo) — **mantidos sem alteração**, ambos força 3.
- **Construto principal preservado:** I34 Uso da Autonomia, exclusivamente — situação segue observando autonomia já estabelecida (não ambígua), sem tocar integridade, regras, obediência, autorização, coragem ou risco.
- **Indicadores afetados:** nenhum — mudança é só de texto na alternativa C.
- **Justificativa comportamental:** ver Seção 4, S40 (texto revisado).

### Resumo da Rodada 3

| Situação | Alteração |
|---|---|
| S29 | Mantida (texto) — justificativa reescrita para remover pressuposto de "produzir mais = melhor" |
| S30 | Alternativas A, C, D reescritas — diferenciação A/D reforçada, C desmoralizada |
| S36 | Alternativas C, D reescritas — C explicita custo de não decidir, D mantém "decidir" como foco central |
| S38 | Alternativa C reescrita — sobreposição com I23 avaliada e documentada, vínculo não adicionado |
| S40 | Alternativa C reescrita — removida linguagem de priorização/gestão de tempo, mantido só I34 |
| S31, S32, S33, S34, S35, S37, S39 | Mantidas sem alteração nesta rodada |

**Nenhum vínculo indicador↔alternativa foi adicionado ou removido nesta rodada** — todas as mudanças foram de redação (texto das alternativas e/ou justificativa), não de mapeamento. A matriz de cobertura da Seção 7 permanece válida e inalterada.

---

## 17. Entrega final consolidada

**1. Versão final S29-S40:** ver Seção 4 (já atualizada com todas as revisões da Rodada 3 incorporadas).

**2. Matriz final de cobertura:** idêntica à da Seção 7 — nenhuma mudança de vínculo nesta rodada, só de redação.

**3. Lista exata dos vínculos novos (48 alternativas, S29-S40):**

| Situação | A | B | C | D |
|---|---|---|---|---|
| S29 | I01 (3) | I01 (1) | I01 (2) | I01 (1) |
| S30 | I04 (3) | I04 (1) | I04 (1-2) | I04 (2) |
| S31 | I05 (3) | I05 (1) | I05 (2) | I05 (2) |
| S32 | I06 (3) | I06 (2) | I06 (1) | I06 (2) + I13 (2) |
| S33 | I08 (3) + I10 (1) | I08 (1) | I08 (2) | I08 (2) |
| S34 | I15 (3) | I15 (1) | I15 (2) | I15 (2) |
| S35 | I18 (3) | I18 (1) | I18 (3) + I19 (1) | I18 (1) |
| S36 | I26 (3) | I26 (1) | I26 (1) | I26 (2) |
| S37 | I28 (3) + I13 (2) | I28 (1) | I28 (1) | I28 (2) |
| S38 | I31 (3) | I31 (1) | I31 (2) | I31 (1) |
| S39 | I32 (3) | I32 (1) | I32 (2) | I32 (2) |
| S40 | I34 (3) | I34 (2) | I34 (1) | I34 (3) |

Total: 48 alternativas, 52 vínculos indicador↔alternativa (4 alternativas com vínculo duplo: S32-D, S33-A, S35-C, S37-A).

**4. Confirmação — S01-S28 intocadas:** confirmado. Nenhum texto de situação, alternativa, indicador, pilar ou vínculo `alternative_indicators` existente foi alterado em nenhuma das 3 rodadas desta proposta.

**5. Confirmação — nada aplicado:** confirmado. Nenhuma migration, seed, mudança de código, alteração de banco, motor, relatório ou frontend foi feita. Esta continua sendo uma proposta puramente metodológica, em arquivo `.md`, aguardando decisão de implementação.
