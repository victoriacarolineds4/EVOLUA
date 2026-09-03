# EVOLUA — Auditoria de Linguagem do Questionário (proposta para revisão)

> **Este documento é para leitura humana da Victoria** — mesmo padrão do `MAPEAMENTO_REVISAO.md`.
> Fonte: estado atual do banco de dados (lido via API em tempo real, não o arquivo de seed estático).
>
> **Nada aqui foi aplicado.** É uma auditoria + proposta. Cada item mostra o texto atual, uma reescrita
> proposta em português simples, e os termos trocados. Itens marcados **⚠️ REQUER DECISÃO HUMANA** não
> receberam proposta — expliquei o conflito para você decidir, em vez de arriscar mudar o que a alternativa
> está de fato evidenciando.
>
> **Princípio seguido em toda reescrita:** preservar exatamente o comportamento/atitude descrito, mudando
> só a forma de dizer. Nenhuma reescrita adiciona, remove ou generaliza o que a pessoa está fazendo na
> alternativa original.

---

## Resumo

- **28 situações e 112 alternativas** lidas do banco em produção.
- **25 itens** com problema de linguagem identificado (situação inteira ou 1 alternativa específica).
- **22 com reescrita direta proposta.**
- **3 marcados como "requer decisão humana"** — são os que eu destacaria com prioridade pra você levar à Victoria.
- Achei também **4 erros de digitação/concordância** nas alternativas atuais (não é sobre linguagem difícil, é erro mesmo) — listados à parte no final, porque valem correção independente desta pauta.

---

## Situação 02 — Pilar 1 (Autogestão)

**Alternativa C — "Redireciono o espaço"**

| | Texto |
|---|---|
| Atual | *Agradeço o feedback e sugiro que o assunto seja tratado em um **fórum** mais adequado para não comprometer o andamento da reunião.* |
| Proposto | *Agradeço a crítica e sugiro que o assunto seja tratado em outro momento, mais adequado, para não atrapalhar o andamento da reunião.* |
| Termo trocado | "fórum" (ambíguo — colaborador comum associa a fórum de internet ou jurídico, não a "outro momento/formato") |
| Status | ✅ Reescrita direta |

---

## Situação 03 — Pilar 1 (Autogestão)

**Título da situação**

| | Texto |
|---|---|
| Atual | *Você tem um projeto estratégico de longo prazo sem prazo fixo e com pouca **visibilidade** do gestor.* |
| Proposto | *Você tem um projeto estratégico de longo prazo, sem prazo fixo, e o gestor acompanha pouco o que você está fazendo.* |
| Termo trocado | "visibilidade" (jargão de gestão — "ter visibilidade de algo" não é uso natural do dia a dia) |
| Status | ✅ Reescrita direta |

**Alternativa A — "Crio meu próprio ritmo"**

| | Texto |
|---|---|
| Atual | *Defino **marcos** semanais, **bloqueio** tempo fixo na **agenda** para o projeto e monitoro meu próprio progresso com regularidade.* |
| Proposto | *Defino metas para cada semana, reservo um horário fixo pra trabalhar no projeto e acompanho meu próprio progresso com regularidade.* |
| Termos trocados | "marcos" → "metas"; "bloqueio... agenda" → "reservo um horário" |
| Status | ✅ Reescrita direta |

**Alternativa D — "Envolvo o time"**

| | Texto |
|---|---|
| Atual | *Compartilho o projeto com colegas e crio **rituais coletivos** de acompanhamento para manter o foco do grupo.* |
| Proposto | *Compartilho o projeto com colegas e crio encontros regulares para acompanharmos juntos e manter o foco do grupo.* |
| Termo trocado | "rituais coletivos" (jargão — colaborador comum associa "ritual" a algo religioso/cerimonial) |
| Status | ✅ Reescrita direta |

---

## Situação 07 — Pilar 2 (Comunicação)

**Alternativa D — "Aceito e mitigo"**

| | Texto |
|---|---|
| Atual | *Aceito a decisão e direciono minha energia para **mitigar** os possíveis impactos negativos durante a execução.* |
| Proposto | *Aceito a decisão e coloco minha energia em reduzir os possíveis problemas durante a execução.* |
| Termo trocado | "mitigo/mitigar" (jargão de gestão de risco) |
| Status | ✅ Reescrita direta (título também ajusta pra "Aceito e reduzo os riscos") |

---

## Situação 08 — Pilar 2 (Comunicação)

**Título da situação**

| | Texto |
|---|---|
| Atual | *...um comportamento recorrente que está afetando a **dinâmica** do time.* |
| Proposto | *...um comportamento recorrente que está afetando o clima do time.* |
| Termo trocado | "dinâmica" (jargão — "dinâmica do time" não é expressão natural fora do ambiente corporativo) |
| Status | ✅ Reescrita direta |

**Alternativa C — "Solicito mediação"**

| | Texto |
|---|---|
| Atual | *Peço ao gestor para **mediar** a conversa e garantir que o feedback seja dado da forma mais construtiva possível.* |
| Proposto | *Peço ao gestor para ajudar a conduzir a conversa, ficando neutro, pra garantir que a crítica seja dada da melhor forma possível.* |
| Termo trocado | "mediar/mediação" — mantive a ideia de neutralidade explicitamente, pra não perder essa nuance |
| Status | ✅ Reescrita direta |

---

## Situação 09 — Pilar 3 (Relacionamento)

**Alternativa A — "Me ofereço ativamente"**

| | Texto |
|---|---|
| Atual | *Identifico onde posso contribuir mais, ofereço ajuda diretamente aos colegas e me **engajo** nos **projetos** deles.* |
| Proposto | *Identifico onde posso contribuir mais, ofereço ajuda diretamente aos colegas e participo do que eles estão fazendo.* |
| Termos trocados | "me engajo" → "participo"; "projetos deles" → "do que eles estão fazendo" (uso incidental de "projeto" aqui — ver nota sobre esse termo no final do documento) |
| Status | ✅ Reescrita direta |

**Alternativa B — "Sinalizo disponibilidade"**

| | Texto |
|---|---|
| Atual | *Informo ao gestor que estou com capacidade disponível e aguardo **redirecionamento formal** para onde sou mais útil.* |
| Proposto | *(sem proposta — ver abaixo)* |
| Termo problemático | "sinalizo", "capacidade disponível", "redirecionamento formal" |
| Status | ⚠️ **REQUER DECISÃO HUMANA** |
| Conflito | A palavra "formal" aqui pode não ser só estilo — pode estar evidenciando especificamente um comportamento de **seguir processo/hierarquia** (esperar uma instrução oficial, não just "alguém me dizer"). Simplificar pra algo como "espero ele me dizer onde posso ajudar" pode enfraquecer exatamente o traço que essa alternativa evidencia (ex: Conformidade no DISC, ou Estilo Planejador). Prefiro que você e a Victoria decidam se essa nuance de formalidade/processo importa aqui. |

---

## Situação 10 — Pilar 3 (Relacionamento)

**Alternativa A — "Ouço separado e medío juntos"** *(nota: "medío" parece erro de digitação de "medeio" — ver seção de erros no final)*

| | Texto |
|---|---|
| Atual | *Converso individualmente com cada um para entender cada perspectiva e depois **facilito** uma conversa conjunta e estruturada.* |
| Proposto | *Converso individualmente com cada um para entender o lado de cada pessoa e depois converso com os dois juntos, de forma organizada.* |
| Termo trocado | "facilito" (jargão de gestão de reuniões) |
| Status | ✅ Reescrita direta |

**Alternativa C — "Escalo o caso"**

| | Texto |
|---|---|
| Atual | *Levo a situação ao gestor responsável para que ele tome a decisão de como resolver o conflito.* |
| Proposto | *Levo a situação ao gestor pra ele decidir como resolver o conflito.* |
| Termo trocado | Só o **título** precisa mudar — "Escalo o caso" → "Levo para o gestor". A descrição já estava em português simples. |
| Status | ✅ Reescrita direta |

---

## Situação 11 — Pilar 3 (Relacionamento)

**Título da situação**

| | Texto |
|---|---|
| Atual | *Um colega está passando por um momento pessoal muito difícil e sua **performance** caiu visivelmente.* |
| Proposto | *Um colega está passando por um momento pessoal muito difícil e o rendimento dele caiu visivelmente.* |
| Termo trocado | "performance" (estrangeirismo desnecessário) → "rendimento" |
| Status | ✅ Reescrita direta |

**Alternativa C — "Aciono o gestor"**

| | Texto |
|---|---|
| Atual | *Comunico ao gestor a situação para que ele possa dar o **suporte institucional** necessário ao colaborador.* |
| Proposto | *Comunico ao gestor a situação para que ele possa dar o apoio que a empresa oferece nesses casos.* |
| Termo trocado | "suporte institucional" → "apoio que a empresa oferece" |
| Status | ✅ Reescrita direta |

---

## Situação 12 — Pilar 3 (Relacionamento)

**Alternativa D — "Convido à observação"**

| | Texto |
|---|---|
| Atual | *Incluo-o como observador em **projetos** em andamento para que **absorva a cultura e o ritmo** antes de assumir iniciativas.* |
| Proposto | *(parcial — "projetos em andamento" pode virar "no que já está em andamento"; o resto, ver abaixo)* |
| Termo trocado (parte segura) | "projetos em andamento" → "no que já está em andamento" (uso incidental de "projeto" — ver nota no final do documento) |
| Termo problemático (parte pendente) | "absorva a cultura e o ritmo" |
| Status | ⚠️ **REQUER DECISÃO HUMANA** (só nessa parte) |
| Conflito | "Absorver a cultura" pode estar evidenciando algo mais específico que "aprender como o time trabalha" — a ideia de captar normas não-escritas, valores e comportamentos implícitos do grupo por observação, não só o "ritmo de trabalho". Uma versão simplificada tipo "para conhecer melhor como o time funciona" pode achatar essa nuance. Prefiro deixar pra Victoria confirmar se a distinção importa pro que esse indicador está medindo. |

---

## Situação 13 — Pilar 4 (Orientação a Resultados)

**Alternativa C — "Alinhos com stakeholders"** *(também tem erro de concordância: "Alinhos" deveria ser "Alinho")*

| | Texto |
|---|---|
| Atual (título) | *Alinhos com stakeholders* |
| Atual (descrição) | *Reúno as partes envolvidas para alinhar expectativas e definir coletivamente o que é essencial para o prazo.* |
| Proposto (título) | *Alinho com quem está envolvido* |
| Termo trocado | "stakeholders" — este é o caso mais fácil da lista: a própria descrição já usa a versão em português ("as partes envolvidas"), só o título ficou em inglês. Corrige também o erro de concordância de tabela. |
| Status | ✅ Reescrita direta (alta confiança — a descrição já define o significado em português) |

---

## Situação 15 — Pilar 4 (Orientação a Resultados)

**Alternativa C — "Faço retrospecto coletivo"**

| | Texto |
|---|---|
| Atual | *Reúno o time para uma **retrospectiva** e construímos juntos o que faríamos de diferente na próxima vez.* |
| Proposto | *Reúno o time para revisar o que aconteceu e conversamos juntos sobre o que faríamos diferente da próxima vez.* |
| Termo trocado | "retrospectiva" (jargão de metodologias ágeis/Scrum) → "revisar o que aconteceu" |
| Status | ✅ Reescrita direta (título também ajusta pra "Faço uma revisão com o time") |

---

## Situação 16 — Pilar 4 (Orientação a Resultados)

**Alternativa A — "Negocio o trade-off"**

| | Texto |
|---|---|
| Atual | *Comunico o dilema ao **stakeholder** e negocio o **trade-off**/escopo ou o prazo para conseguir manter a qualidade da entrega.* |
| Proposto | *Explico o problema para quem pediu a entrega e negocio o que será feito ou o prazo, para conseguir manter a qualidade.* |
| Termos trocados | "stakeholder" → "quem pediu a entrega"; "trade-off" (estrangeirismo) → removido, a ideia de troca já fica clara em "negocio o que será feito ou o prazo" |
| Status | ✅ Reescrita direta (título também ajusta pra "Negocio o que é possível") |

---

## Situação 18 — Pilar 5 (Liderança)

**Alternativa A — "Explico, defino e acompanho"**

| | Texto |
|---|---|
| Atual | *Explico o objetivo e as expectativas, defino **checkpoints** periódicos e deixo espaço para ele executar com autonomia.* |
| Proposto | *Explico o objetivo e as expectativas, combino conversas periódicas para acompanhar e deixo espaço para ele fazer com autonomia.* |
| Termo trocado | "checkpoints" (estrangeirismo) → "conversas periódicas para acompanhar" |
| Status | ✅ Reescrita direta |

---

## Situação 19 — Pilar 5 (Liderança)

**Alternativa A — "Acompanho de perto"**

| | Texto |
|---|---|
| Atual | *Ofereço feedbacks frequentes, **co-crio** um plano de desenvolvimento com ele e monitoro a evolução regularmente.* |
| Proposto | *Dou retornos frequentes, crio com ele um plano de desenvolvimento e acompanho a evolução regularmente.* |
| Termo trocado | "co-crio" (neologismo/jargão) → "crio com ele" |
| Status | ✅ Reescrita direta |

---

## Situação 21 — Pilar 6 (Inovação e Adaptação)

**Alternativa A — "Me adapto proativamente"**

| | Texto |
|---|---|
| Atual | *Busco entender o **racional** da mudança, identifico as oportunidades nela e me reposiciono antes que me peçam.* |
| Proposto | *(sem proposta — ver abaixo)* |
| Termo problemático | "racional" usado como substantivo ("o racional da mudança") — calco do inglês "the rationale" |
| Status | ⚠️ **REQUER DECISÃO HUMANA** |
| Conflito | "Entender o racional" (a lógica/raciocínio por trás) é mais específico que "entender o motivo" (só o porquê). Essa alternativa provavelmente está evidenciando uma leitura analítica/estratégica da mudança, não só aceitar uma justificativa — trocar por "motivo" pode achatar essa nuance justamente no ponto que talvez distinga essa alternativa das outras 3 da mesma situação. Prefiro confirmar com a Victoria antes de reescrever. |

---

## Situação 22 — Pilar 6 (Inovação e Adaptação)

**Título da situação**

| | Texto |
|---|---|
| Atual | *...um problema recorrente no processo do seu time que ninguém ainda **endereçou** de forma definitiva.* |
| Proposto | *...um problema recorrente no processo do seu time que ninguém ainda resolveu de vez.* |
| Termo trocado | "endereçou" (calco do inglês "to address") → "resolveu" |
| Status | ✅ Reescrita direta |

**Alternativa C — "Facilito uma sessão coletiva"**

| | Texto |
|---|---|
| Atual | *Levanto o problema em uma reunião de time e conduzo uma **sessão de ideação** com todos os envolvidos.* |
| Proposto | *Levanto o problema em uma reunião de time e conduzo uma conversa em grupo pra buscarmos soluções juntos.* |
| Termo trocado | "sessão de ideação" (jargão de design thinking) → "conversa em grupo pra buscarmos soluções" |
| Status | ✅ Reescrita direta (título também ajusta pra "Reúno o time para pensar juntos") |

---

## Situação 23 — Pilar 6 (Inovação e Adaptação)

**Alternativa A — "Defino e começo"** *(também tem erro de concordância: "Clarifica" deveria ser "Clarifico")*

| | Texto |
|---|---|
| Atual | ***Clarifica** os objetivos com o gestor, estruturo meu próprio entendimento do papel e começo a operar com autonomia.* |
| Proposto | *Esclareço os objetivos com o gestor, estruturo meu próprio entendimento do papel e começo a atuar com autonomia.* |
| Termo trocado | "Clarifica" → "Esclareço" (corrige o erro de concordância e troca por uma palavra mais natural — "esclarecer" já é usado em outras situações do questionário, ex: Situação 12) |
| Status | ✅ Reescrita direta |

---

## Situação 27 — Pilar 7 (Desenvolvimento Contínuo)

**Alternativa B — "Apresento e co-evoluo"**

| | Texto |
|---|---|
| Atual (título) | *Apresento e co-evoluo* |
| Atual (descrição) | *Apresento a solução em uma reunião de time e convido os colegas a contribuírem com melhorias e adaptações.* |
| Proposto (título) | *Apresento e melhoro com o time* |
| Termo trocado | "co-evoluo" (neologismo/jargão) — a descrição já está em português simples, só o título precisa mudar |
| Status | ✅ Reescrita direta (alta confiança — descrição já define o significado) |

---

## Nota transversal — "projeto" (investigado a pedido, mantido na maioria dos casos)

A palavra **"projeto"** aparece 12 vezes, concentrada em 6 situações (03, 09, 12, 13, 15, 24). Diferente
dos termos acima, "projeto" não é jargão — é uma palavra comum que todo mundo entende. A questão levantada
foi outra: se "tarefa" seria mais relável pra colaboradores de funções mais operacionais/rotineiras, que
talvez não pensem no próprio trabalho em termos de "projetos".

**Decisão tomada:** não trocar globalmente por "tarefa". Nas Situações **03, 13, 15 e 24**, "projeto" carrega
a **escala** do cenário — "projeto estratégico de longo prazo", "meses de trabalho que falhou",
"liderança de um projeto com prazo apertado". "Tarefa" sugere algo pequeno e rotineiro; usá-la nesses
casos enfraqueceria o que a situação está testando (lidar com ambiguidade/fracasso em algo grande, não
numa tarefa do dia a dia). Nas Situações **09 e 12**, o uso é incidental (referência ao trabalho de outra
pessoa, não o assunto central) — ali sim suavizei para "o que eles estão fazendo"/"o que já está em
andamento" (ver os itens correspondentes acima).

---

## Nota transversal — "feedback" (não tratado item a item)

A palavra **"feedback"** aparece 6 vezes no questionário (Situações 02, 04, 08, 19, 23, 26). Diferente de "stakeholder" ou "trade-off", "feedback" já é amplamente usada no português falado no Brasil, inclusive fora do ambiente corporativo ("me dá um feedback aí"). Por isso **não tratei como jargão automático** e não propus reescrita — mas sinalizo aqui porque é uma decisão de estilo, não de clareza: se vocês preferirem um produto 100% livre de estrangeirismos, a troca seria por "retorno" ou "crítica"/"opinião sincera" dependendo do contexto. Deixo para a Victoria decidir se vale padronizar.

Mesma observação para **"autonomia"** (aparece em várias situações) e **"mentoria"** (Situação 25) — palavras de origem técnica que hoje têm uso corrente amplo; não foram tratadas como problema.

---

## Erros de digitação/concordância encontrados (fora do escopo desta auditoria, mas vale corrigir)

Não são sobre linguagem difícil — são erros mesmo, que valem correção independente da aprovação de conteúdo:

1. **Situação 10-A**, título: "Ouço separado e **medío** juntos" → provavelmente "Ouço separado e **medeio** junto" ou "...e medeio a conversa junto"
2. **Situação 13-C**, título: "**Alinhos** com stakeholders" → "**Alinho** com..." (já incluído na proposta acima, junto com a troca de "stakeholders")
3. **Situação 23-A**, descrição: "**Clarifica** os objetivos" → "**Clarifico**" ou (como propus acima) "Esclareço" (já incluído na proposta acima)
4. **Situação 25-D**, descrição: "Identifico colegas mais atualizados e **cria** oportunidades" → "...e **crio** oportunidades"

---

## Como usar este documento

Para cada item ✅, o texto da coluna "Proposto" pode ir direto para aprovação da Victoria junto com o `MAPEAMENTO_REVISAO.md` pendente (item 9 do handoff). Os 3 itens ⚠️ merecem conversa specific — são os que têm mais risco de mudar sutilmente o que a alternativa evidencia se simplificados sem cuidado.

**Nada foi alterado no banco.** Após aprovação, a aplicação é só no campo de texto (`title`/`description` de `questions`/`alternatives`) — sem tocar em ID, estrutura ou nos vínculos de `alternative_indicators`/`alternative_disc`/etc., que continuam exatamente como estão hoje.
