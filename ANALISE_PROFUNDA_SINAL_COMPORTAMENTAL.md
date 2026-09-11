# Análise Profunda do Sinal Comportamental — EVOLUA

**Data:** 10/09/2026
**Escopo:** diagnóstico puro, sem alteração de código, banco, mapeamentos ou conteúdo.
**Fonte dos dados:** leitura ao vivo do banco de produção (pillars, indicators, questions, alternatives via `anon key`, RLS permite) + o script SQL que define o mapeamento `alternative_indicators` atualmente vigente (`backups/metodologia_reconstruida/11_remap_alternative_indicators.sql`, aprovado em 10/09/2026 — a tabela em si não é legível por `anon key` devido a RLS `authenticated`, mas seu conteúdo corresponde exatamente ao que foi aplicado em produção).

---

## 1. Visão geral

O que foi analisado:

- **28 situações**, 4 alternativas cada = **112 alternativas comportamentais**.
- **35 indicadores**, 5 por pilar, distribuídos em **7 pilares**: Organização e Rotina, Responsabilidade, Aprendizagem e Mudança, Relacionamentos, Comunicação, Pressão e Decisão, Crescimento e Ética.
- O mapeamento atual (`166` vínculos `alternative_indicators`) foi tratado como **hipótese a ser reexaminada**, não como verdade — cada vínculo foi reavaliado do zero perguntando "o que este comportamento específico revela, e sobre qual indicador, entre os 35?", sem me limitar aos 5 indicadores do pilar da situação.

**Descoberta metodológica prévia, confirmada no código, que molda todo o resto desta análise:**
Em `src/lib/motor/engine.ts`, `evidenceCount` é incrementado uma vez por alternativa **escolhida** que aponta para um indicador. Como cada situação permite escolher **exatamente uma** entre suas 4 alternativas, uma pessoa **nunca pode gerar mais de 1 ponto de evidência por situação** para um mesmo indicador — não importa quantas das 4 alternativas daquela situação estejam vinculadas a ele.

Isso significa que **o piso `MIN_EVIDENCE_SITUATIONS = 3` só é estruturalmente atingível se o indicador tiver vínculos genuínos espalhados em pelo menos 3 situações diferentes** — não em 3 alternativas da mesma situação. Um indicador com "4 vínculos" mas todos dentro de uma única situação está, na prática, **matematicamente limitado a `evidenceCount ≤ 1`** para qualquer pessoa. Esse ponto — que é a Regra 9 do prompt original, mas também um fato verificável no código — é o eixo central dos achados abaixo.

---

## 2. Análise das 112 alternativas

Nota de leitura: quando um vínculo do mapeamento atual não resistiu a uma justificativa comportamental defensável, isso está marcado como **⚠️ questionável** com a razão. Quando encontrei uma leitura mais precisa (outro indicador, ou reclassificação de principal↔secundário), isso está marcado como **→ recomendação**. Nada disso foi aplicado — são achados para sua revisão.

### Situação 1 — Termino uma atividade e ainda tenho tempo disponível. (Pilar 1)

**A — Adianto a próxima tarefa da minha lista.**
- Indicador: I01 Gestão do Tempo — Principal — Força: CLARA
- Justificativa: usar tempo ocioso para adiantar trabalho é o comportamento central que I01 descreve.
- Qualidade: esta é a alternativa "obviamente produtiva" da situação — tende a reduzir o poder de discriminação, já que é a resposta socialmente esperada.

**B — Reviso o que já entreguei, procurando algo para melhorar.**
- Indicador: I05 Fechamento de Ciclos — Secundário — Força: SECUNDÁRIA ⚠️ questionável
- Justificativa: I05 é definido como "revisar **antes** de considerar concluído" — aqui a entrega já aconteceu. O comportamento real é mais próximo de busca contínua por melhoria, que não tem indicador próprio entre os 35.
- Observação: comportamento relevante (orientação a qualidade pós-entrega) não claramente capturado pela estrutura atual.

**C — Aproveito para organizar minhas próximas atividades.**
- Indicador: I03 Planejamento — Principal — Força: CLARA
- Justificativa: estruturar o que vem a seguir antes de executar é comportamento central de planejamento.

**D — Pergunto ao time se alguém precisa de apoio.**
- Indicador: I16 Disposição para Ajudar — Principal — Força: CLARA (mapeamento atual usa força 1; comportamento é bastante direto — oferecer ajuda sem ser cobrado)
- Justificativa: oferta espontânea de apoio é exatamente a definição de I16.

---

### Situação 2 — Inicio meu turno e existem várias tarefas para começar. (Pilar 1)

**A — Ordeno pelas mais urgentes primeiro.**
- Indicador: I02 Priorização — Principal — Força: FORTE
- Secundário defensável: I27 Gestão de Múltiplas Demandas — Força: SECUNDÁRIA (organizar diante de várias demandas simultâneas também é o núcleo de I27; risco de redundância com a Situação 22, que é dedicada a I27).

**B — Faço uma lista rápida antes de começar.**
- Indicador: I03 Planejamento — Principal — Força: CLARA

**C — Começo pela que me parece mais simples, para ganhar ritmo.**
- Indicador atual: I01 Gestão do Tempo ⚠️ questionável — "começar pelo mais simples para ganhar ritmo" não é sobre uso produtivo do tempo ocioso (definição de I01), é uma estratégia de sequenciamento de tarefas.
- → recomendação: leitura mais defensável é um vínculo fraco/secundário a I02 Priorização (é uma forma alternativa — por facilidade, não por urgência — de decidir por onde começar), ou nenhum vínculo genuíno claro.

**D — Confirmo com o time o que é mais importante antes de decidir.**
- Indicador: I02 Priorização — Secundário — Força: SECUNDÁRIA (defensável: alinhamento colaborativo sobre prioridade).

---

### Situação 3 — Preciso definir por onde começar o trabalho. (Pilar 1)

**A — Começo pela parte que trava as demais.**
- Indicador: I02 Priorização — Principal — Força: CLARA

**B — Escrevo os passos antes de agir.**
- Indicador: I03 Planejamento — Principal — Força: FORTE

**C — Começo pela parte mais simples para pegar embalo.**
- Indicador atual: I01 Gestão do Tempo ⚠️ questionável — mesmo problema da Situação 2-C. Este texto é quase idêntico ao de S2-C — **duas situações diferentes contendo a mesma alternativa comportamental mapeada (de forma imprecisa) para o mesmo indicador** é um sinal de redundância na construção.

**D — Peço uma referência de como já foi feito antes.**
- Indicador atual: I04 Consistência na Rotina ⚠️ questionável — buscar uma referência de como algo já foi feito é busca de orientação/precedente, não manutenção de padrão pessoal de organização sem cobrança externa (definição de I04). Não encontrei justificativa comportamental defensável para nenhum dos 35 indicadores aqui de forma clara; o mais próximo seria um vínculo fraco a I23 Pedido de Ajuda, mas o texto não é exatamente um pedido de ajuda, é uma busca de exemplo.
- Indicadores: nenhum vínculo genuíno forte identificado; I04 não se sustenta.

---

### Situação 4 — Estou finalizando uma atividade importante. (Pilar 1)

**A — Reviso tudo com cuidado antes de entregar.**
- Indicador: I05 Fechamento de Ciclos — Principal — Força: FORTE (match textual quase literal com a definição).

**B — Entrego assim que fica pronta, sem revisar muito.**
- Indicador: I05 Fechamento de Ciclos — Secundário — Força: SECUNDÁRIA (polo inverso/fraco do mesmo indicador — correto manter força baixa).

**C — Peço para alguém revisar comigo antes de finalizar.**
- Indicador atual: I04 Consistência na Rotina ⚠️ questionável — esta alternativa envolve explicitamente **outra pessoa**, o que contradiz a definição de I04 ("mantém padrão... sem cobrança externa"). O comportamento observável é fechamento cuidadoso via revisão colaborativa.
- → recomendação: I05 Fechamento de Ciclos (secundário, força baixa) é leitura mais defensável que I04.

**D — Confiro se atendi tudo que foi pedido, ponto a ponto.**
- Indicador atual: I04 Consistência na Rotina ⚠️ questionável — "conferir ponto a ponto se atendi tudo" é revisão cuidadosa antes de concluir, ou seja, é a própria definição de I05, não de I04.
- → recomendação: reclassificar para I05 Fechamento de Ciclos (secundário/claro).

**Observação sobre a Situação 4 como um todo:** se C e D forem de fato I05 (como a análise comportamental sugere), então **as 4 alternativas desta situação evidenciam o mesmo indicador (I05)** e nenhuma evidencia genuinamente I04. Isso reduz a cobertura real de I04 e concentra ainda mais a cobertura de I05 dentro de uma única situação — ver Seção 3.

---

### Situação 5 — Percebo um erro que pode afetar um cliente. (Pilar 2)

**A — Aviso imediatamente, mesmo sem ter a solução pronta.**
- Indicador: I10 Cuidado com Impacto no Outro — Principal — Força: FORTE.
- Secundário atual I08 Transparência sobre Atrasos ⚠️ questionável — I08 é especificamente sobre **atrasos**; aqui o gatilho é um **erro**, não necessariamente um atraso. Vínculo por proximidade temática, não por comportamento específico.

**B — Busco entender o erro por completo antes de avisar.**
- Indicador: I07 Proatividade diante de Falhas — Principal — Força: CLARA (entender a causa é pré-requisito de mitigação, ainda que atrase a comunicação — trade-off genuíno).

**C — Aviso e já sugiro uma forma de contornar.**
- Indicador atual: I09 Aceitação de Responsabilidade ⚠️ questionável — este comportamento não é sobre aceitar uma responsabilidade inesperada, é sobre comunicar + propor mitigação.
- → recomendação: I07 Proatividade diante de Falhas (principal, propor solução = mitigar) + I21 Iniciativa de Comunicação (secundário, já mapeado corretamente).

**D — Converso com o time antes de decidir o que fazer.**
- Indicador: I07 Proatividade diante de Falhas — Secundário — Força: SECUNDÁRIA (polo mais lento/coletivo, ainda relevante por contraste).

---

### Situação 6 — Eu cometo um erro. (Pilar 2)

**A — Assumo na hora, sem justificar demais.**
- Indicador: I06 Assunção de Erros — Principal — Força: FORTE.
- Secundário: I33 Integridade — Força: SECUNDÁRIA (escolher o caminho honesto em vez do mais fácil é genuinamente integridade).

**B — Explico o que levou ao erro, para evitar que se repita.**
- Indicador atual: I04 Consistência na Rotina ⚠️ questionável — não é sobre manter rotina, é uma forma analítica de lidar com o próprio erro.
- → recomendação: vínculo fraco/secundário a I06 Assunção de Erros (ainda está assumindo e processando o erro, só que com foco em causa-raiz), ou nenhum vínculo genuíno claro — comportamento de "aprendizado com erro" não tem indicador dedicado entre os 35.

**C — Peço desculpas a quem foi afetado antes de tudo.**
- Indicador: I10 Cuidado com Impacto no Outro — Principal — Força: CLARA.

**D — Corrijo o quanto antes e só depois comento o que houve.**
- Indicador: I07 Proatividade diante de Falhas — Principal — Força: CLARA.

---

### Situação 7 — Percebo que vou atrasar uma entrega. (Pilar 2)

**A — Aviso assim que percebo, com nova estimativa.**
- Indicador: I08 Transparência sobre Atrasos — Principal — Força: FORTE (match textual quase literal).
- Secundário: I22 Transparência com Liderança — Força: SECUNDÁRIA (defensável, mas situação não especifica destinatário — vínculo genérico).

**B — Tento recuperar o atraso sozinho antes de avisar.**
- Indicador: I08 Transparência sobre Atrasos — Secundário — Força: SECUNDÁRIA (polo inverso, correto).

**C — Aviso e pergunto se alguém pode ajudar a recuperar o prazo.**
- Indicador atual: I10 Cuidado com Impacto no Outro ⚠️ questionável — o comportamento central aqui é pedir ajuda, não considerar o impacto sobre terceiros.
- → recomendação: I23 Pedido de Ajuda (principal) + I08 Transparência sobre Atrasos (secundário, já comunica o atraso).

**D — Reorganizo minhas prioridades para tentar cumprir o prazo original.**
- Indicador: I02 Priorização — Principal — Força: SECUNDÁRIA (comportamento de repriorização é genuíno, ainda que — como B — não envolva comunicar o atraso).

---

### Situação 8 — Recebo uma responsabilidade inesperada. (Pilar 2)

Situação bem construída — as 4 alternativas evidenciam genuinamente I09 Aceitação de Responsabilidade, com nuances distintas.

**A — Aceito e já penso em como organizar para dar conta.**
- I09 — Principal — Força: FORTE. Secundário I27 Gestão de Múltiplas Demandas — SECUNDÁRIA (defensável, fraco).

**B — Aceito, mas pergunto o que exatamente se espera de mim.**
- I09 — Principal — Força: CLARA. Secundário I23 Pedido de Ajuda — SECUNDÁRIA (defensável).
- Secundário atual I13 Receptividade a Feedback ⚠️ questionável — perguntar o que se espera **antes** de agir não é receber feedback, é buscar clareza inicial. Comportamentos diferentes.

**C — Aceito e busco quem já passou por isso para aprender rápido.**
- I09 — Principal — Força: CLARA. Secundário I12 Disposição para o Novo — SECUNDÁRIA (defensável).
- Secundário atual I31 Busca por Crescimento ⚠️ questionável — buscar orientação de alguém experiente é aprendizagem/onboarding, não é "aproveitar uma oportunidade de crescimento" no sentido do indicador. → recomendação: I14 Autodesenvolvimento se algum segundo vínculo for mantido.

**D — Aceito, mesmo sentindo insegurança, e vou ajustando no caminho.**
- I09 — Principal — Força: CLARA, sem vínculo secundário forçado. Bom exemplo de mapeamento sóbrio.

---

### Situação 9 — A empresa muda um processo. (Pilar 3)

**A — Me adapto e sigo, mesmo sem entender todos os motivos.**
- I11 Abertura a Mudança — Principal — Força: FORTE.
- Secundário atual I26 Autonomia sob Pressão ⚠️ questionável — aceitar uma mudança de processo não é decidir sob pressão sem liderança presente; são construtos diferentes.

**B — Pergunto o porquê da mudança antes de me adaptar.**
- Indicador atual: I15 Flexibilidade Cognitiva — leitura plausível, mas ambígua: este comportamento também pode ser lido como um polo mais cauteloso do próprio I11 (ainda se adapta, só que depois de entender). Mapeamento defensável, mas vale revisão da Victoria.

**C — Procuro entender o novo processo testando por conta própria.**
- I14 Autodesenvolvimento — Principal — Força: CLARA.

**D — Sinto resistência no início, mas me ajusto aos poucos.**
- I11 Abertura a Mudança — Secundário — Força: SECUNDÁRIA (polo mais lento, correto).

---

### Situação 10 — Recebo uma tarefa que nunca fiz. (Pilar 3)

**A — Topo e vou aprendendo na prática.**
- I12 Disposição para o Novo — Principal — Força: FORTE.
- Secundário atual I34 Uso da Autonomia ⚠️ questionável — I34 pressupõe que autonomia foi **concedida**; aqui só chegou uma tarefa nova, não há concessão explícita de autonomia (esse construto tem situação própria: S28).

**B — Pesquiso e estudo antes de começar.**
- I14 Autodesenvolvimento — Principal — Força: CLARA.

**C — Pergunto a alguém que já fez para me orientar.**
- I12 Disposição para o Novo — Secundário — Força: SECUNDÁRIA. Secundário: I23 Pedido de Ajuda — SECUNDÁRIA (ambos defensáveis).

**D — Aceito, mas peço um prazo maior por ser novidade.**
- I12 Disposição para o Novo — Secundário — Força: SECUNDÁRIA (polo mais cauteloso, correto).

---

### Situação 11 — Recebo um feedback. (Pilar 3)

**A — Ouço tudo antes de reagir ou explicar.**
- I13 Receptividade a Feedback — Principal — Força: FORTE.

**B — Agradeço e já penso em como aplicar.**
- Indicador atual: I14 Autodesenvolvimento — leitura defensável, mas mais precisa seria I13 (uma forma ainda mais engajada de receptividade — não apenas ouvir, mas já processar para aplicar). → recomendação: considerar I13 como principal aqui, I14 no máximo secundário fraco.

**C — Peço exemplos concretos para entender melhor.**
- I13 Receptividade a Feedback — Principal — Força: CLARA.

**D — No momento fico incomodado, mas repenso depois com calma.**
- I13 Receptividade a Feedback — Secundário — Força: SECUNDÁRIA (polo mais lento, correto).
- Secundário atual I06 Assunção de Erros ⚠️ questionável — desconforto com feedback não é assumir um erro; feedback nem sempre é sobre um erro.

---

### Situação 12 — Preciso aprender uma ferramenta nova. (Pilar 3)

**A — Vou direto testando, sem ler manual antes.**
- I12 Disposição para o Novo — Principal — Força: CLARA.

**B — Procuro um curso ou material antes de usar.**
- I14 Autodesenvolvimento — Principal — Força: FORTE.
- Secundário atual I35 Compromisso com Evolução ⚠️ questionável/frágil — I35 implica um padrão contínuo; um único ato de buscar um curso é evidência fraca demais para um construto definido como "contínuo".

**C — Peço para alguém me mostrar na prática.**
- I12 Disposição para o Novo — Principal — Força: SECUNDÁRIA. Vínculo adicional defensável não presente hoje: I23 Pedido de Ajuda (secundário).

**D — Vou aprendendo aos poucos, no ritmo das tarefas do dia a dia.**
- Indicador atual: I15 Flexibilidade Cognitiva ⚠️ questionável — aprender aos poucos é uma questão de ritmo/ordem, não claramente "ajustar a própria forma de pensar". → recomendação: leitura mais defensável é um vínculo fraco a I14 Autodesenvolvimento.

---

### Situação 13 — Um colega precisa de ajuda. (Pilar 4)

**A — Ajudo na hora, mesmo interrompendo o que eu fazia.**
- I16 Disposição para Ajudar — Principal — Força: FORTE.
- Secundário atual I32 Disposição para Ensinar ⚠️ questionável — a situação não especifica que a ajuda envolve ensinar algo; é uma inferência não sustentada pelo texto.

**B — Pergunto o que ele precisa antes de agir.**
- Indicador atual: I20 Construção de Confiança ⚠️ questionável — construção de confiança é um padrão de longo prazo; uma pergunta pontual antes de ajudar não estabelece isso.
- → recomendação: I16 Disposição para Ajudar (secundário — forma mais cuidadosa de ajudar, ainda é ajuda).

**C — Ajudo, mas combino um horário para não atrasar meu trabalho.**
- I16 Disposição para Ajudar — Secundário — Força: SECUNDÁRIA (polo com limite, correto).

**D — Indico alguém ou algo que pode ajudar melhor do que eu.**
- I16 Disposição para Ajudar — Força: SECUNDÁRIA, mas com **ambiguidade de direção**: pode ser lido como resolutividade (encontrar a melhor solução) ou como baixa disposição pessoal (repassar a tarefa). O texto não deixa claro qual leitura é a pretendida — problema de construção da alternativa, não só de mapeamento.

---

### Situação 14 — Chega um novo colaborador na equipe. (Pilar 4)

**A — Me aproximo e me apresento logo no início.**
- I17 Acolhimento — Principal — Força: FORTE.

**B — Explico como as coisas funcionam por aqui, sem esperar perguntarem.**
- I17 Acolhimento — Principal — Força: CLARA. Secundário I24 Clareza na Orientação — SECUNDÁRIA (defensável).

**C — Deixo que ele se ambiente no próprio ritmo, mas fico disponível.**
- Indicador atual: I20 Construção de Confiança ⚠️ questionável — um único gesto de disponibilidade não estabelece "confiança construída ao longo do tempo".
- → recomendação: I17 Acolhimento (secundário — forma mais discreta/passiva de acolher).

**D — Apresento as pessoas e processos mais importantes primeiro.**
- I17 Acolhimento — Secundário — Força: SECUNDÁRIA.

---

### Situação 15 — Existe um conflito entre dois colegas. (Pilar 4)

**A — Converso com os dois separadamente para entender os lados.**
- I18 Mediação de Conflitos — Principal — Força: FORTE.
- Secundário atual I28 Lida com Insatisfação ⚠️ questionável — I28 é sobre lidar com **alguém insatisfeito com você/a empresa**, não sobre mediar um conflito entre terceiros.

**B — Não me envolvo, a menos que afete o trabalho.**
- I18 Mediação de Conflitos — Secundário — Força: SECUNDÁRIA (polo de baixa evidência, correto).

**C — Sugiro que conversem diretamente entre si.**
- I18 Mediação de Conflitos — Principal — Força: CLARA.

**D — Aviso alguém de confiança se percebo que está afetando o time.**
- I18 Mediação de Conflitos — Força: CLARA no mapeamento atual, mas com **ambiguidade de direção**: escalar para outra pessoa pode ser lido como NÃO estar mediando pessoalmente. Vale revisão de força/direção.

---

### Situação 16 — Preciso trabalhar com alguém que pensa muito diferente de mim. (Pilar 4)

**A — Procuro entender a lógica da pessoa antes de discordar.**
- I19 Tolerância à Diferença — Principal — Força: FORTE.
- Secundário atual I18 Mediação de Conflitos ⚠️ questionável — não há conflito declarado na situação, apenas diferença de raciocínio.

**B — Foco no resultado comum, mesmo com estilos diferentes.**
- I19 Tolerância à Diferença — Principal — Força: CLARA.

**C — Ajusto minha forma de me comunicar para facilitar o trabalho.**
- Indicador atual principal: I19 (secundário) + I15 + I25 — três vínculos simultâneos, provável supermapeamento.
- → recomendação: **I25 Adaptação da Mensagem** é o vínculo mais preciso e deveria ser o principal ("ajustar a comunicação conforme quem está ouvindo" é a própria definição de I25). Manter I19 como secundário é defensável. I15 Flexibilidade Cognitiva é redundante — recomendo remover.

**D — No início é difícil, mas encontro um jeito de conviver.**
- I19 Tolerância à Diferença — Secundário — Força: SECUNDÁRIA (polo lento, correto). Secundário I11 Abertura a Mudança é fraco/opcional — adaptar-se a uma pessoa não é o mesmo que adaptar-se a uma mudança de processo; manteria como vínculo cruzado opcional, não essencial.

---

### Situação 17 — Tenho uma ideia para melhorar um processo. (Pilar 5)

**A — Compartilho assim que a ideia surge.**
- I21 Iniciativa de Comunicação — Principal — Força: FORTE.
- Secundário atual I31 Busca por Crescimento ⚠️ questionável — propor uma melhoria de processo não é sobre aproveitar uma oportunidade de crescimento pessoal.

**B — Estruturo a ideia antes de apresentar.**
- I21 Iniciativa de Comunicação — Principal — Força: CLARA. Vínculo adicional defensável não presente hoje: I03 Planejamento (secundário — estruturar antes de agir).

**C — Testo por conta própria antes de propor para os outros.**
- I21 Iniciativa de Comunicação — Secundário — Força: SECUNDÁRIA (polo mais cauteloso).
- Secundário atual I29 Decisão com Informação Limitada ⚠️ questionável, possivelmente invertido — testar antes de propor é buscar **mais** evidência antes de agir, o oposto do comportamento que I29 descreve.

**D — Comento informalmente com alguém antes de levar adiante.**
- I21 Iniciativa de Comunicação — Secundário — Força: SECUNDÁRIA.

---

### Situação 18 — Preciso comunicar um problema ao meu líder. (Pilar 5)

**A — Vou direto ao ponto, sem enrolar.**
- I22 Transparência com Liderança — Principal — Força: FORTE.
- Secundário atual I08 Transparência sobre Atrasos ⚠️ questionável — a situação fala de "um problema" genérico, não necessariamente um atraso.

**B — Levo o problema já com uma sugestão de solução.**
- I22 Transparência com Liderança — Principal — Força: CLARA. Vínculo adicional defensável não presente hoje: I07 Proatividade diante de Falhas (secundário — propor solução é mitigação).

**C — Escolho um bom momento para não pegar de surpresa.**
- I22 Transparência com Liderança — Principal — Força: CLARA.
- Secundário atual I28 Lida com Insatisfação ⚠️ questionável — escolher um bom momento para falar com o próprio líder não é sobre lidar com a insatisfação de terceiros.

**D — Explico o contexto todo antes de chegar ao ponto.**
- Indicador atual: I24 Clareza na Orientação ⚠️ questionável — I24 é sobre transmitir **instruções/orientações** a alguém; aqui a pessoa está reportando um problema ao líder, não orientando ninguém. Comportamento é mais próximo de um polo menos direto/mais verboso de I22.
- → recomendação: I22 Transparência com Liderança (secundário, polo mais indireto).

---

### Situação 19 — Preciso pedir ajuda. (Pilar 5)

Situação limpa — todas as 4 alternativas evidenciam genuinamente I23 Pedido de Ajuda, sem supermapeamento.

**A** Peço direto, sem constrangimento. — I23, FORTE.
**B** Tento sozinho primeiro. — I23 (polo fraco), SECUNDÁRIA.
**C** Explico onde travei. — I23, CLARA.
**D** Sinto receio, mas peço quando necessário. — I23 (polo fraco), SECUNDÁRIA.

---

### Situação 20 — Preciso transmitir uma orientação importante para outra pessoa. (Pilar 5)

**A — Explico de forma direta e objetiva.**
- I24 Clareza na Orientação — Principal — Força: FORTE.
- Secundário atual I32 Disposição para Ensinar ⚠️ questionável, situacional — transmitir uma orientação de trabalho não é necessariamente "ensinar" no sentido de compartilhar conhecimento/mentoria.

**B — Confirmo se a pessoa entendeu, pedindo para repetir com as próprias palavras.**
- I24 Clareza na Orientação — Principal — Força: FORTE (recomendo elevar a força atual — checar compreensão é uma das evidências mais diretas possíveis de clareza na orientação).
- Secundário atual I05 Fechamento de Ciclos ⚠️ questionável — confirmar entendimento de uma comunicação não é o mesmo que revisar uma entrega antes de concluir.

**C — Uso um exemplo prático para facilitar o entendimento.**
- I25 Adaptação da Mensagem — Principal — Força: CLARA.

**D — Ajusto a explicação conforme percebo a reação da pessoa.**
- I25 Adaptação da Mensagem — Principal — Força: FORTE.
- Secundário atual I19 Tolerância à Diferença ⚠️ questionável — ajustar-se à reação de alguém em tempo real é responsividade comunicativa, não é sobre trabalhar bem com quem pensa diferente.

---

### Situação 21 — Surge um problema e o líder não está presente. (Pilar 6)

**A — Decido sozinho e informo depois.**
- I26 Autonomia sob Pressão — Principal — Força: FORTE. Secundário I09 Aceitação de Responsabilidade — SECUNDÁRIA (defensável — assumir a decisão é assumir responsabilidade).
- Secundário atual I34 Uso da Autonomia ⚠️ questionável/redundante — I34 pressupõe autonomia **concedida**; aqui a pessoa está preenchendo um vácuo de liderança, comportamento definicionalmente mais próximo do próprio I26.

**B — Reúno o time para decidir juntos.**
- I26 Autonomia sob Pressão — Principal — Força: CLARA.
- Secundário atual I20 Construção de Confiança ⚠️ questionável — uma decisão coletiva pontual não estabelece um padrão de confiança construído ao longo do tempo.

**C — Tento contato com o líder antes de agir, se der tempo.**
- I26 Autonomia sob Pressão — Secundário — Força: SECUNDÁRIA (polo mais cauteloso, correto).
- Secundário atual I22 Transparência com Liderança ⚠️ questionável — tentar contato não é, por si, um ato de transparência (não há informação sendo compartilhada ainda).

**D — Ajo com cautela, resolvendo só o essencial até o líder voltar.**
- Indicador atual: I30 Estabilidade sob Pressão — leitura possível, mas o comportamento descrito (agir com cautela, resolver só o essencial) é mais diretamente uma 4ª variação do espectro de I26 Autonomia sob Pressão do que especificamente sobre equilíbrio emocional.
- → recomendação: considerar I26 (secundário) além de/no lugar de I30.

---

### Situação 22 — Recebo várias demandas ao mesmo tempo. (Pilar 6)

Situação bem construída — I27 Gestão de Múltiplas Demandas como eixo central, com secundários defensáveis.

**A** Organizo por prioridade antes de começar qualquer uma. — I27, FORTE. Secundário I02 Priorização, SECUNDÁRIA (defensável).
**B** Toco várias ao mesmo tempo, alternando entre elas. — I27 (polo fraco), SECUNDÁRIA.
**C** Negocio prazos com quem pediu, se for preciso. — I27, CLARA. Secundário I21 Iniciativa de Comunicação, SECUNDÁRIA (defensável — negociar é um ato de comunicação).
**D** Foco em uma de cada vez, do início ao fim. — I27, CLARA.

---

### Situação 23 — Um cliente está muito insatisfeito. (Pilar 6)

**A — Ouço tudo antes de responder qualquer coisa.**
- I28 Lida com Insatisfação — Principal — Força: FORTE.
- Secundário atual I17 Acolhimento ⚠️ questionável — Acolhimento é definido no contexto de pessoas novas/diferentes na equipe, não de um cliente externo insatisfeito. Escopo do indicador não cobre esta situação.

**B — Reconheço o problema e já busco uma solução.**
- I28 Lida com Insatisfação — Principal — Força: CLARA. Secundário I07 Proatividade diante de Falhas — SECUNDÁRIA (defensável).

**C — Mantenho o tom calmo, mesmo se o cliente estiver alterado.**
- I30 Estabilidade sob Pressão — Principal — Força: CLARA (match direto com a definição).
- Secundário atual I18 Mediação de Conflitos ⚠️ questionável — não há conflito entre pares aqui, é uma situação de atendimento sob estresse.

**D — Explico com transparência o que pode e o que não pode ser feito.**
- I28 Lida com Insatisfação — Principal — Força: CLARA. Secundário I33 Integridade — SECUNDÁRIA (defensável — transparência mesmo quando desconfortável é integridade).

---

### Situação 24 — Preciso decidir com poucas informações. (Pilar 6)

Situação limpa — todas as 4 evidenciam I29 Decisão com Informação Limitada de forma direta.

**A** Decido com o que tenho, mesmo com risco de errar. — I29, FORTE.
**B** Busco rapidamente mais alguma informação antes de decidir. — I29, CLARA.
**C** Peço a opinião de alguém antes de decidir. — I29, CLARA. Secundários I13 Receptividade a Feedback e I23 Pedido de Ajuda, ambos SECUNDÁRIA (defensáveis).
**D** Decido pela opção mais segura entre as possíveis. — I29, CLARA.

---

### Situação 25 — Surge uma oportunidade de crescimento. (Pilar 7)

**A — Abraço, mesmo sem me sentir 100% pronto.**
- I31 Busca por Crescimento — Principal — Força: FORTE. Secundários I29 Decisão com Informação Limitada e I12 Disposição para o Novo, ambos SECUNDÁRIA — defensáveis individualmente, mas três vínculos simultâneos numa única alternativa é o limite do razoável; watch para não inflar.

**B — Avalio com calma se faz sentido antes de aceitar.**
- I31 Busca por Crescimento — Principal — Força: CLARA (polo mais deliberado).

**C — Pergunto o que vai mudar na prática antes de decidir.**
- I31 Busca por Crescimento — Secundário — Força: SECUNDÁRIA (polo cauteloso, correto).

**D — Aceito e já penso em quem pode me ajudar no caminho.**
- Indicador atual: I35 Compromisso com Evolução ⚠️ questionável — este é essencialmente ainda um "abraçar a oportunidade" (I31), com um ângulo prático de buscar apoio; não estabelece claramente um "compromisso contínuo" (definição de I35), que por natureza exige evidência ao longo do tempo, não uma escolha pontual.
- → recomendação: I31 Busca por Crescimento (secundário), em vez de I35 como único vínculo.

---

### Situação 26 — Preciso ensinar alguém. (Pilar 7)

Situação bem construída — I32 Disposição para Ensinar como eixo, com secundários precisos.

**A** Explico e já deixo a pessoa praticar. — I32, FORTE. Secundário I16 Disposição para Ajudar, SECUNDÁRIA (defensável).
**B** Preparo um passo a passo antes de ensinar. — I32, CLARA. Secundários I17 Acolhimento e I24 Clareza na Orientação, SECUNDÁRIA (ambos defensáveis).
**C** Ensino no ritmo da pessoa, com paciência. — I32, CLARA. Secundário I19 Tolerância à Diferença, SECUNDÁRIA (defensável).
**D** Uso exemplos reais para facilitar o entendimento. — I32, CLARA. Secundário I25 Adaptação da Mensagem, SECUNDÁRIA (defensável — mesmo comportamento-tipo da Situação 20-C).

---

### Situação 27 — Fazer o que é correto parece mais difícil do que fazer o mais fácil. (Pilar 7)

Situação limpa — todas as 4 evidenciam I33 Integridade de forma direta.

**A** Escolho o caminho correto, mesmo custando mais esforço. — I33, FORTE.
**B** Penso nas consequências antes de decidir. — I33, CLARA. Secundário I30 Estabilidade sob Pressão, SECUNDÁRIA (defensável, fraco).
**C** Busco uma forma de fazer certo que não seja tão custosa. — I33, CLARA.
**D — Sinto a tentação, mas volto atrás e faço certo.**
- I33 Integridade — Secundário — Força: SECUNDÁRIA.
- Secundário atual I06 Assunção de Erros ⚠️ questionável — resistir a uma tentação prospectivamente não é assumir um erro já cometido.

---

### Situação 28 — Recebo autonomia para tomar decisões importantes. (Pilar 7)

**A — Decido com confiança, assumindo o risco.**
- I34 Uso da Autonomia — Principal — Força: FORTE (esta é a situação-referência para I34 — autonomia explicitamente concedida). Secundário I09 Aceitação de Responsabilidade — SECUNDÁRIA (defensável).
- Secundário atual I26 Autonomia sob Pressão ⚠️ questionável/redundante — I26 é especificamente sobre decidir **sem liderança presente**; aqui a autonomia foi formalmente concedida, construto distinto que corre o risco de ser confundido com I26.

**B — Uso a autonomia com cautela, validando pontos críticos.**
- I34 Uso da Autonomia — Secundário — Força: SECUNDÁRIA (polo cauteloso, correto).

**C — Envolvo o time nas decisões, mesmo tendo autonomia sozinho.**
- I34 Uso da Autonomia — Secundário — Força: SECUNDÁRIA.

**D — Aproveito para propor algo diferente do que já era feito.**
- I34 Uso da Autonomia — Principal — Força: CLARA. Secundário I35 Compromisso com Evolução — SECUNDÁRIA (defensável, fraco).
- Secundário atual I11 Abertura a Mudança ⚠️ questionável, possivelmente invertido — I11 é sobre **reagir** a mudanças de processo com adaptação; aqui a pessoa está **iniciando** a mudança, o comportamento oposto ao que I11 mede.

---

## 3. Análise dos 35 indicadores

Tabela de cobertura **genuína** (após reavaliação comportamental), contando apenas **situações distintas** — pelo motivo explicado na Seção 1: dentro de uma situação só se escolhe uma alternativa, então vínculos concentrados numa única situação nunca superam `evidenceCount = 1`, mesmo que pareçam robustos no mapeamento nominal.

| Indicador | Pilar | Situações com evidência genuína | Piso de 3 |
|---|---|---|---|
| I01 Gestão do Tempo | 1 | S1 (1) | ❌ não atingido |
| I02 Priorização | 1 | S2, S3, S7, S22 (4) | ✅ atingido |
| I03 Planejamento | 1 | S1, S2, S3 (3) | ✅ atingido (sem margem) |
| I04 Consistência na Rotina | 1 | — (0; os 4 vínculos atuais não resistem à análise) | ❌ ausente |
| I05 Fechamento de Ciclos | 1 | S4 (1, mesmo com 2–4 alternativas internas) | ❌ não atingido |
| I06 Assunção de Erros | 2 | S6 (1) | ❌ não atingido |
| I07 Proatividade diante de Falhas | 2 | S5, S6, S23 (3) | ✅ atingido (sem margem) |
| I08 Transparência sobre Atrasos | 2 | S7 (1) | ❌ não atingido |
| I09 Aceitação de Responsabilidade | 2 | S8, S21, S28 (3) | ✅ atingido (sem margem) |
| I10 Cuidado com Impacto no Outro | 2 | S5, S6 (2) | ⚠️ parcial |
| I11 Abertura a Mudança | 3 | S9 (1, +S16 frágil) | ❌ não atingido |
| I12 Disposição para o Novo | 3 | S8, S10, S12, S25 (4) | ✅ atingido |
| I13 Receptividade a Feedback | 3 | S11, S24 (2) | ⚠️ parcial |
| I14 Autodesenvolvimento | 3 | S9, S10, S11, S12 (até 4) | ✅ atingido |
| I15 Flexibilidade Cognitiva | 3 | S9 (1, frágil/ambíguo) | ❌ não atingido |
| I16 Disposição para Ajudar | 4 | S1, S13, S26 (3) | ✅ atingido (sem margem) |
| I17 Acolhimento | 4 | S14, S26 (2) | ⚠️ parcial |
| I18 Mediação de Conflitos | 4 | S15 (1) | ❌ não atingido |
| I19 Tolerância à Diferença | 4 | S16, S26 (2) | ⚠️ parcial |
| I20 Construção de Confiança | 4 | — (0; nenhum dos 3 vínculos atuais resiste à análise) | ❌ ausente |
| I21 Iniciativa de Comunicação | 5 | S5, S17, S22 (3) | ✅ atingido (sem margem) |
| I22 Transparência com Liderança | 5 | S7, S18 (2) | ⚠️ parcial |
| I23 Pedido de Ajuda | 5 | S8, S10, S19, S24 (4) | ✅ atingido |
| I24 Clareza na Orientação | 5 | S14, S20 (2) | ⚠️ parcial |
| I25 Adaptação da Mensagem | 5 | S16, S20 (2) | ⚠️ parcial |
| I26 Autonomia sob Pressão | 6 | S21 (1, apesar de 4 alternativas internas) | ❌ não atingido |
| I27 Gestão de Múltiplas Demandas | 6 | S2, S8, S22 (3) | ✅ atingido (sem margem) |
| I28 Lida com Insatisfação | 6 | S23 (1) | ❌ não atingido |
| I29 Decisão com Informação Limitada | 6 | S24, S25 (2) | ⚠️ parcial |
| I30 Estabilidade sob Pressão | 6 | S23 (1, +S21 frágil) | ⚠️ parcial/frágil |
| I31 Busca por Crescimento | 7 | S25 (1, apesar de 3–4 alternativas internas) | ❌ não atingido |
| I32 Disposição para Ensinar | 7 | S26 (1, apesar de 4 alternativas internas) | ❌ não atingido |
| I33 Integridade | 7 | S6, S23, S27 (3) | ✅ atingido (sem margem) |
| I34 Uso da Autonomia | 7 | S28 (1, apesar de 4 alternativas internas) | ❌ não atingido |
| I35 Compromisso com Evolução | 7 | — (0–1; os 2 vínculos existentes são individualmente frágeis) | ❌ ausente/frágil |

**Observação metodológica geral:** o padrão mais recorrente nesta tabela não é "indicador sem nenhum vínculo" — é o **indicador com muitos vínculos nominais, todos presos a uma única situação-referência** (I05, I08, I26, I28, I31, I32, I34, I18, I06). Cada um desses tem uma situação muito bem construída e claramente dedicada a ele — mas justamente por ser tão dedicada e específica, nenhuma outra situação do questionário oferece uma segunda oportunidade genuína de observar o mesmo comportamento em outro contexto. Estruturalmente, `evidenceCount` para esses indicadores está travado em 1, não importa quantas pessoas respondam.

---

## 4. Classificação dos 35 indicadores

### A — Evidência genuína suficiente (≥3 situações distintas defensáveis)
I02, I03, I07, I09, I12, I14, I16, I21, I23, I27, I33
**11 de 35 (31%).** Note que a maioria está "no limite" (exatamente 3, sem margem) — qualquer reclassificação adicional (como as sugeridas acima) pode empurrar alguns destes para o grupo B.

### B — Evidência genuína parcial (1–2 situações distintas defensáveis)
I01, I05, I06, I08, I10, I11, I13, I15, I17, I18, I19, I22, I24, I25, I26, I28, I29, I30, I31, I32, I34
**21 de 35 (60%).**

### C — Evidência genuína insuficiente ou ausente
**I04 Consistência na Rotina** — limitação de mapeamento: os 4 vínculos atuais (S3-D, S4-C, S4-D, S6-B) não resistem a uma justificativa comportamental estrita; em pelo menos 2 casos (S4-C, S4-D) o comportamento descrito é mais precisamente I05. Não há evidência de que a construção das alternativas seja o problema — o problema é o mapeamento apontar para o indicador errado.

**I20 Construção de Confiança** — limitação estrutural mais profunda: "confiança construída ao longo do tempo" é, por definição, um padrão observado em múltiplas interações repetidas — não algo que uma única escolha hipotética consiga evidenciar bem. Os 3 vínculos atuais (S13-B, S14-C, S21-B) são, cada um, leituras mais defensáveis de outro indicador (I16, I17, I26 respectivamente). Este provavelmente exigiria um desenho de situação fundamentalmente diferente (ex.: comparar comportamento em momento 1 vs. momento 2) para ser medido de verdade — algo que o formato de 28 situações isoladas não comporta.

**I35 Compromisso com Evolução** — mesma limitação estrutural de I20: "compromisso contínuo" não é observável numa escolha pontual. Os 2 vínculos existentes (S12-B, S25-D) são individualmente frágeis por essa mesma razão.

---

## 5. Análise da qualidade das 28 situações

**Situações fortes (evidência clara, alternativas bem discriminadas):**
S4, S6, S8, S11, S15, S19, S20, S22, S24, S26, S27, S28 — nestas, as 4 alternativas representam escolhas comportamentais genuinamente diferentes e o vínculo principal é defensável sem esforço.

**Situações com alternativas pouco discriminativas ou de direção ambígua:**
- **S1** (alternativa A é a resposta "obviamente produtiva").
- **S13-D** e **S15-D** (delegar/escalar pode ser lido como alta OU baixa evidência do indicador, dependendo da interpretação — a alternativa não deixa claro).
- **S2-C / S3-C** ("começar pelo mais simples, para ganhar ritmo") — texto quase idêntico em duas situações diferentes, ambas mapeadas (de forma frágil) para o mesmo indicador (I01). É redundância de conteúdo, não de medição.

**Situações que geram evidência muito ampla ou mal direcionada:**
- **S5** (percepção de erro que afeta cliente): mistura sinais de I10, I07, I09 e I21 dependendo da alternativa — tematicamente rica, mas o mapeamento atual usa vínculos secundários mais por proximidade temática do que por comportamento específico (ver S5-A, S5-C acima).
- **S18** (comunicar problema ao líder): a alternativa D foi mapeada para I24 Clareza na Orientação, indicador que na verdade descreve outra direção de comunicação (instruir alguém, não reportar a um superior) — sinal de que o pareamento situação↔indicador partiu da proximidade temática de "comunicação", não do comportamento específico.

**Situações praticamente dedicadas a um único indicador (o que é bom para precisão, mas cria o problema estrutural da Seção 3):**
S8→I09, S19→I23, S22→I27, S24→I29, S26→I32, S27→I33, S28→I34. Todas são situações de alta qualidade interna — o problema não está nelas, está na ausência de uma "segunda situação" em outro ponto do questionário capaz de gerar evidência do mesmo indicador em um contexto diferente.

**Comportamentos relevantes observados, mas não capturados pela estrutura atual de indicadores:**
- Orientação a melhoria contínua pós-entrega (S1-B) — buscar aperfeiçoar algo que já foi considerado pronto, distinto de "fechar com cuidado antes de entregar" (I05).
- Aprendizado a partir da causa-raiz de um erro (S6-B) — processar o "porquê" de uma falha para não repeti-la, distinto de simplesmente assumir o erro (I06).
- Resolutividade via delegação inteligente (S13-D) — reconhecer que outra pessoa/recurso serve melhor do que ajudar pessoalmente, comportamento que hoje é lido (de forma ambígua) como baixa disposição a ajudar.

---

## 6. Diagnóstico final

### A estrutura atual das 28 situações + 112 alternativas é capaz de produzir evidência comportamental suficientemente precisa para os 35 indicadores?

**Não, para a maioria dos indicadores — apenas 11 de 35 (31%) sustentam evidência genuína em ≥3 situações distintas de forma confortável, e mesmo esses estão majoritariamente "no limite exato", sem margem.**

### Classificação das hipóteses

**1. O problema principal está no mapeamento das alternativas para os indicadores.**
→ **Parcialmente confirmada.** Há um número relevante de vínculos que não resistem a uma justificativa comportamental estrita (aproximadamente 20 dos 166, listados acima com ⚠️), e algumas reclassificações claras (ex. S4-C/D pertencem a I05, não I04). Mas corrigir só isso não resolveria o problema central — ver hipótese 3.

**2. O problema está na construção de algumas alternativas.**
→ **Parcialmente confirmada.** Poucos casos de ambiguidade de direção (S13-D, S15-D) e um caso de redundância textual entre situações (S2-C/S3-C). Não é o fator dominante, mas existe.

**3. Existem indicadores com cobertura naturalmente insuficiente dentro das 28 situações.**
→ **Confirmada.** I20 e I35, por definição ("confiança ao longo do tempo", "compromisso contínuo"), não são o tipo de comportamento que uma única escolha hipotética consegue evidenciar bem — isso é uma limitação estrutural do formato, não um erro de mapeamento corrigível.

**4. Existem alternativas que estão atualmente supermapeadas.**
→ **Confirmada, em escala pequena.** S16-C (3 vínculos simultâneos) e S25-A (3 vínculos simultâneos) são os casos mais claros; nenhum caso de mapeamento claramente inflado para "fechar número", mas há tendência ocasional de vincular por proximidade temática em vez de comportamento específico.

**5. Existem comportamentos relevantes que o modelo atual não captura adequadamente.**
→ **Confirmada, em escala pequena.** Três comportamentos identificados na Seção 5 (melhoria contínua pós-entrega, aprendizado por causa-raiz, resolutividade via delegação) não têm indicador correspondente claro entre os 35.

**6. O piso de 3 situações é estruturalmente atingível para a maioria dos indicadores.**
→ **Não confirmada.** É o oposto: **apenas 31% dos indicadores** atingem 3 situações genuinamente distintas mesmo após a reanálise mais generosa possível. A causa raiz não é falta de vínculos nominais — muitos indicadores têm 3, 4 ou até 6 vínculos no mapeamento atual — é que esses vínculos estão concentrados numa única situação "dedicada", o que o mecanismo de `evidenceCount` (uma escolha por situação) torna estruturalmente incapaz de contar como 3 evidências.

**7. O problema dos scores baixos pode estar sendo causado pela qualidade/quantidade da evidência antes mesmo da etapa de agregação.**
→ **Confirmada.** Esta análise mostra que o problema começa antes da fórmula de agregação de pilares: **21 de 35 indicadores (60%) estruturalmente não conseguem, mesmo no melhor cenário de resposta, atingir o piso de suficiência** — porque sua evidência genuína está concentrada em uma única situação do questionário, e uma pessoa só pode responder a cada situação uma vez. Somado aos 3 indicadores do Grupo C (evidência ausente), isso significa que **24 de 35 indicadores (69%) partem de uma limitação de desenho, não de comportamento real da pessoa avaliada.**

---

### Nota final

Todos os vínculos "genuínos" identificados nesta análise — inclusive os que confirmam o mapeamento atual — devem ser tratados como propostas de leitura, não como verdade metodológica definitiva. A prioridade deste documento foi precisão, não cobertura: onde a evidência comportamental não foi defensável, isso foi registrado como tal, mesmo quando o resultado é um indicador (I04, I20, I35) sem cobertura genuína nenhuma.

A pergunta original — "o EVOLUA está realmente observando comportamentos, ou construindo associações entre respostas e indicadores?" — tem uma resposta mista: para os 11 indicadores do Grupo A, a resposta tende a "sim, com margem apertada". Para os 24 restantes (Grupos B e C), a estrutura atual de 28 situações está, em graus variados, mais próxima de associação temática do que de observação comportamental robusta e replicável.
