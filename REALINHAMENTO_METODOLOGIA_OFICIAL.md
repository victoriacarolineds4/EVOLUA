# Realinhamento à Especificação Oficial EVOLUA

**Data:** 08/09/2026
**Status:** Fase 1 (comparação) e Fase 2 (proposta) concluídas. **Nenhuma alteração foi feita no banco.**
**Fonte oficial usada:** documento `prompt-claude-code-realinhamento-oficial.md` enviado por Victoria em 08/09/2026, confirmado por ela como nova fonte de verdade da metodologia (substitui a resolução anterior registrada em memória, que apontava o conjunto de pilares já presente no código — "Autogestão...Desenvolvimento Contínuo" — como canônico).

---

## 0. Achado crítico que muda o risco do realinhamento

A tabela `alternative_indicators` — o elo real entre as 112 alternativas e os 35 indicadores/7 pilares que o Motor usa para pontuar — está **vazia (0 registros)**. O mesmo vale para as quatro tabelas de leitura complementar: `alternative_disc`, `alternative_psychological_types`, `alternative_motivators`, `alternative_operational_styles` — **todas com 0 registros**.

Ou seja: apesar do `MAPEAMENTO_REVISAO.md` já documentar, linha a linha, a proposta de vínculo de cada alternativa a indicador/DISC/tipo/motivador/estilo, esse mapeamento **nunca foi de fato inserido no banco**. A fase de "enriquecer o Motor" (mapear as 112 alternativas) ainda está pendente por completo — consistente com o que já estava registrado em memória como fase atual do projeto.

**Consequência prática:** não existe nenhuma pontuação real em produção que dependa da estrutura atual de pilares/situações/indicadores. Isso significa que **agora é o momento de menor custo possível** para realinhar a metodologia — qualquer mudança feita depois que o mapeamento for populado exigiria refazer o trabalho de vínculo já feito. O único "custo afundado" é que as propostas de vínculo já escritas no `MAPEAMENTO_REVISAO.md` foram pensadas em cima das 28 situações atuais e ficarão obsoletas se as situações mudarem — esse documento precisará ser refeito do zero, não apenas ajustado.

---

## 1. Pilares — 100% divergentes (nome e ordem)

| # | Banco (atual) | Oficial (novo) | Classificação |
|---|---|---|---|
| 1 | Autogestão | Organização e Rotina | Divergente |
| 2 | Comunicação | Responsabilidade | Divergente |
| 3 | Relacionamento | Aprendizagem e Mudança | Divergente |
| 4 | Orientação a Resultados | Relacionamentos | Divergente |
| 5 | Liderança | Comunicação | Divergente |
| 6 | Inovação e Adaptação | Pressão e Decisão | Divergente |
| 7 | Desenvolvimento Contínuo | Crescimento e Ética | Divergente |

Nenhum pilar bate em nome ou posição. Note que "Comunicação" existe nas duas listas, mas em posições diferentes (2 no banco, 5 no oficial) — reforça que não é um simples ajuste de nome, é reordenação estrutural.

**Proposta:** renomear as 7 linhas da tabela `pillars` (`number` continua 1–7, `name`/`description` passam a refletir a especificação oficial). Sem custo de migração de dados vinculados, pois nenhuma pontuação real depende disso hoje (ver seção 0).

---

## 2. Indicadores (35) — precisam ser recriados

O documento oficial não lista os 35 indicadores nominalmente (ele descreve o conceito de indicador na seção 4, não os nomes). Os 35 indicadores atuais no banco (5 por pilar, ex.: "Responsabilidade Pessoal", "Gestão Emocional", "Autoconfiança"...) foram escritos para os pilares antigos e não têm correspondência direta e automática com os 7 pilares oficiais.

**Proposta:** esta é uma decisão de conteúdo que exige a Victoria — não uma tradução mecânica. Recomendo tratar como uma extensão desta mesma tarefa: definir 5 indicadores por pilar oficial, preservando o espírito dos indicadores atuais onde fizer sentido (ex.: "Assertividade" e "Escuta Ativa" continuam relevantes sob o novo pilar "Comunicação"), mas com a Victoria validando o conjunto final antes de qualquer criação no banco. **Não gerei essa lista aqui** para não decidir sozinho um ponto que a especificação oficial deixou em aberto.

---

## 3. As 28 situações

**Nenhuma das 28 situações do banco é uma versão "elaborada" da situação oficial equivalente — todas testam uma cena diferente.** O padrão apontado no prompt original (exemplo da diretoria) se repete nas 28: a versão implementada sempre adiciona um cenário específico, um personagem, e — na maioria dos casos — pressupõe explicitamente cargo de liderança/gestão ("Você assumiu a liderança...", "delegar uma tarefa estratégica...", "Como você age como líder?"), o que a especificação oficial diz textualmente que a situação não deve pressupor.

A proposta de realinhamento abaixo adota o texto oficial diretamente (ele já está pronto, curto e no formato-alvo — não há necessidade de reescrever, apenas de adotar).

| # | Pilar oficial | Implementado hoje (banco) | Proposta de realinhamento | Risco |
|---|---|---|---|---|
| 1 | Organização e Rotina | "Você cometeu um erro em uma entrega importante que causou retrabalho para o seu time. Como você reage?" | Termino uma atividade e ainda tenho tempo disponível. | Divergente |
| 2 | Organização e Rotina | "Em uma reunião, um colega faz uma crítica direta e incisiva ao seu trabalho na frente de todos. Como você age?" | Inicio meu turno e existem várias tarefas para começar. | Divergente |
| 3 | Organização e Rotina | "Você tem um projeto estratégico de longo prazo, sem prazo fixo, e o gestor acompanha pouco o que você está fazendo. Como você garante o avanço?" | Preciso definir por onde começar o trabalho. | Divergente |
| 4 | Organização e Rotina | "Você é convidado para representar seu time em uma apresentação para uma diretoria que você não conhece. Como você se prepara?" | Estou finalizando uma atividade importante. | Divergente |
| 5 | Responsabilidade | "Você precisa comunicar uma mudança de processo complexa para um time com perfis muito diferentes — técnicos e operacionais. Como você age?" | Percebo um erro que pode afetar um cliente. | Divergente |
| 6 | Responsabilidade | "Em uma conversa com um colaborador que está passando por dificuldades, você percebe que ele está omitindo parte do problema. O que você faz?" | Eu cometo um erro. | Divergente |
| 7 | Responsabilidade | "Você discorda de uma decisão do seu gestor e acredita que ela vai impactar negativamente o resultado da área. O que você faz?" | Percebo que vou atrasar uma entrega. | Divergente |
| 8 | Responsabilidade | "Você precisa dar um feedback difícil a um colega sobre um comportamento recorrente que está afetando o clima do time. Como você age?" | Recebo uma responsabilidade inesperada. | Divergente |
| 9 | Aprendizagem e Mudança | "Seu time está sobrecarregado e você concluiu todas as suas entregas antes do prazo. O que você faz com o tempo disponível?" | A empresa muda um processo. | Divergente |
| 10 | Aprendizagem e Mudança | "Dois membros do seu time estão em conflito aberto e isso está afetando o ambiente e as entregas." | Recebo uma tarefa que nunca fiz. | Divergente |
| 11 | Aprendizagem e Mudança | "Um colega está passando por um momento pessoal muito difícil e o rendimento dele caiu visivelmente. Como você age?" | Recebo um feedback. | Divergente |
| 12 | Aprendizagem e Mudança | "Um novo membro entra no time e demonstra insegurança para tomar iniciativas ou compartilhar ideias. Como você age?" | Preciso aprender uma ferramenta nova. | Divergente |
| 13 | Relacionamentos | "Você assumiu a liderança de um projeto sem documentação disponível e com prazo apertado. Como você começa?" | Um colega precisa de ajuda. | Divergente |
| 14 | Relacionamentos | "Você tem muito mais tarefas do que consegue entregar no dia. Como você decide o que fazer?" | Chega um novo colaborador na equipe. | Divergente |
| 15 | Relacionamentos | "Um projeto importante no qual você investiu meses de trabalho falhou e precisou ser encerrado. Como você reage?" | Existe um conflito entre dois colegas. | Divergente |
| 16 | Relacionamentos | "Você está sob pressão para entregar rápido, mas percebe que a qualidade da entrega está claramente comprometida. O que faz?" | Preciso trabalhar com alguém que pensa muito diferente de mim. | Divergente |
| 17 | Comunicação | "Você precisa tomar uma decisão importante com informações incompletas e sem tempo para consultar seu gestor. O que faz?" | Tenho uma ideia para melhorar um processo. | Divergente |
| 18 | Comunicação | "Você precisa delegar uma tarefa estratégica para um colaborador que ainda não a realizou antes. Como você conduz esse processo?" | Preciso comunicar um problema ao meu líder. | Divergente |
| 19 | Comunicação | "Um colaborador do seu time tem potencial claro, mas ainda não entrega de forma consistente e previsível. Como você age?" | Preciso pedir ajuda. | Divergente |
| 20 | Comunicação | "Seu time está visivelmente desmotivado após um período de mudanças e incertezas. Como você age como líder?" | Preciso transmitir uma orientação importante para outra pessoa. | Divergente |
| 21 | Pressão e Decisão | "A empresa anuncia uma reestruturação significativa que impacta diretamente a sua área e o seu papel. Como você reage?" | Surge um problema e o líder não está presente. | Divergente |
| 22 | Pressão e Decisão | "Você identifica um problema recorrente no processo do seu time que ninguém ainda resolveu de vez. O que você faz?" | Recebo várias demandas ao mesmo tempo. | Divergente |
| 23 | Pressão e Decisão | "Você recebe uma nova responsabilidade importante sem descrição clara do que se espera de você nesse papel. Como você age?" | Um cliente está muito insatisfeito. | Divergente |
| 24 | Pressão e Decisão | "Você é alocado em um projeto estratégico fora da sua área de especialidade. Como você reage?" | Preciso decidir com poucas informações. | Divergente |
| 25 | Crescimento e Ética | "Você percebe que sua área está evoluindo rapidamente e seu conhecimento atual está ficando defasado. O que faz?" | Surge uma oportunidade de crescimento. | Divergente |
| 26 | Crescimento e Ética | "Após um período de trabalho intenso, você percebe que seus resultados ficaram abaixo das suas próprias expectativas. Como você reage?" | Preciso ensinar alguém. | Divergente |
| 27 | Crescimento e Ética | "Você desenvolveu uma solução que gerou resultados concretos para um desafio recorrente do seu trabalho. O que faz?" | Fazer o que é correto parece mais difícil do que fazer o mais fácil. | Divergente |
| 28 | Crescimento e Ética | "Você está em uma carreira que valoriza, mas percebe que o mercado está mudando e seu perfil pode perder relevância nos próximos anos. O que faz?" | Recebo autonomia para tomar decisões importantes. | Divergente |

**Resultado da classificação: 0 Fiel, 0 Elaborada, 28 Divergente.**

---

## 4. As 112 alternativas — vínculo requer reavaliação humana completa

Como nenhuma das 28 situações-mãe é preservada (todas trocam de cena), **as 4 alternativas de cada situação também precisam ser totalmente reescritas**, não apenas reavaliadas — elas foram escritas para responder a um cenário que deixará de existir. Isso é diferente do que a Fase 2 do prompt original previa (situações "elaboradas" cujas alternativas talvez ainda sirvam) — aqui a situação muda de essência em 100% dos casos, então marco a totalidade das 112 alternativas como **"requer reavaliação humana"**, em vez de propor reescritas — a Victoria precisa decidir o conteúdo de cada uma para as novas 28 situações, mantendo o princípio de que nenhuma alternativa deve ser "certa" e as outras "erradas".

---

## 5. Motivadores — 8 no banco vs. 10 na especificação

| Categoria oficial | Existe no banco? | Código banco |
|---|---|---|
| Reconhecimento financeiro | Sim (parcial: "Recompensa Financeira") | FIN |
| Reconhecimento verbal | **Não** — banco só tem "Reconhecimento" genérico | — |
| Autonomia | Sim | AUT |
| Aprendizado | Sim | APR |
| Desenvolvimento | **Não** — banco só tem "Crescimento" | — |
| Crescimento | Sim | CRE |
| Desafios | Sim | DES |
| Confiança | **Não** | — |
| Tempo e qualidade de vida | **Não** — banco tem "Segurança" (SEG), que é um conceito próximo mas não idêntico | — |
| Outras formas de reconhecimento | **Não** (banco tem "Propósito" (PRO), que não está na lista oficial) | — |

O banco tem 8 categorias, a especificação lista 10. Faltam "reconhecimento verbal" (separado do reconhecimento geral), "desenvolvimento" (separado de crescimento), "confiança" e "tempo/qualidade de vida". "Propósito" (PRO) existe no banco mas não consta na lista oficial de 10.

**Proposta:** ajustar a tabela `motivators` para as 10 categorias oficiais é uma decisão de conteúdo — sinalizando aqui, sem propor os textos, para validação da Victoria. Como `alternative_motivators` está vazia (seção 0), não há vínculo a refazer, só a tabela-base a ajustar.

---

## 6. Níveis de desenvolvimento — sem divergência

[`scoring.ts:19-35`](src/lib/motor/scoring.ts:19) e [`types.ts:10-15`](src/lib/motor/types.ts:10) usam exatamente "Precisa de atenção / Está evoluindo / Bem desenvolvido / Muito desenvolvido", com os mesmos cortes conceituais da especificação. Nenhuma ação necessária aqui.

---

## Resumo final

- **Situações:** 0 fiéis, 0 elaboradas, **28 divergentes** — a implementação atual é um conjunto de situações diferente do oficial, não uma variação estilística dele.
- **Pilares:** 7 de 7 divergentes em nome e ordem.
- **Indicadores:** os 35 atuais estão presos aos pilares antigos e precisam ser recriados sob os pilares oficiais — conteúdo pendente de definição pela Victoria (não gerado aqui).
- **Alternativas:** as 112 precisam de reescrita completa (não simples reavaliação), já que toda situação-mãe muda.
- **Motivadores:** 8 de 10 categorias oficiais presentes; faltam 4 conceitos, sobra 1 (Propósito) que não está na lista oficial.
- **Níveis de desenvolvimento:** sem divergência.
- **Achado crítico:** nenhuma das camadas de evidência (`alternative_indicators`, `alternative_disc`, `alternative_psychological_types`, `alternative_motivators`, `alternative_operational_styles`) está populada — 0 registros em todas. Isso significa que o realinhamento completo da metodologia pode ser feito agora sem quebrar nenhuma pontuação real em produção, mas também significa que o `MAPEAMENTO_REVISAO.md` existente ficará obsoleto e precisará ser refeito do zero contra as novas 28 situações.

Nenhuma alteração foi feita no banco. Este documento é somente a base de decisão para os próximos passos.
