# Remapeamento dos Indicadores — Viabilidade Real

**Data:** 10/09/2026
**Status:** Fase 1 — proposta para revisão. **Nada foi aplicado no banco.**
**Base:** `INDICADORES_E_MAPEAMENTO_NOVO.md` (textos das 112 alternativas, inalterados) e a análise de distribuição situação↔indicador de 09/09/2026, que mostrou 34 de 35 indicadores matematicamente impossíveis de atingir `MIN_EVIDENCE_SITUATIONS = 3`.

## O que mudou no desenho

O mapeamento anterior seguia o padrão "1 situação → 1 indicador dedicado": as 4 alternativas de uma situação quase sempre apontavam para o mesmo indicador. Isso deixava cada indicador limitado, no melhor caso, a 1 situação candidata — matematicamente impossível de atingir o piso de 3.

Neste redesenho, cada situação passa a espalhar suas 4 alternativas entre indicadores **diferentes** (majoritariamente dentro do mesmo pilar, já que cada pilar tem 5 indicadores e só 4 situações — então cada situação naturalmente cobre 4 dos 5 indicadores do pilar, revezando qual fica de fora). Isso, sozinho, já levaria os 5 indicadores de cada pilar a 3–4 situações "poderiam". Onde essa distribuição interna não bastava — ou onde uma alternativa genuinamente evidenciava algo de **outro** pilar — usei vínculos secundários cross-pilar, sempre justificados individualmente (não para fechar conta).

**A regra de não forçar continua valenda.** Em alguns casos (sinalizados abaixo), o vínculo cross-pilar é uma leitura genuína, mas mais indireta que uma evidência dentro do próprio pilar — isso é uma característica honesta do redesenho, não um defeito escondido.

## Resultado: os 35 chegam a 3+, mas o preço é ficar rente ao piso

| Indicador | Pilar | Antes (poderiam) | Depois (poderiam) | Depois (certamente 4/4) | P(atingir piso), escolha aleatória |
|---|---|---|---|---|---|
| I01 Gestão do Tempo | Organização e Rotina | 2 | **3** ⚠️ | 0 | 1.6% |
| I02 Priorização | Organização e Rotina | 1 | **4** ⚠️ | 0 | 8.6% |
| I03 Planejamento | Organização e Rotina | 3 | **3** | 0 | 1.6% |
| I04 Consistência na Rotina | Organização e Rotina | 1 | **3** ⚠️ | 0 | 3.1% |
| I05 Fechamento de Ciclos | Organização e Rotina | 2 | **3** ⚠️ | 0 | 3.1% |
| I06 Assunção de Erros | Responsabilidade | 1 | **3** ⚠️ | 0 | 1.6% |
| I07 Proatividade diante de Falhas | Responsabilidade | 2 | **3** ⚠️ | 0 | 3.1% |
| I08 Transparência sobre Atrasos | Responsabilidade | 1 | **3** ⚠️ | 0 | 3.1% |
| I09 Aceitação de Responsabilidade | Responsabilidade | 1 | **4** ⚠️ | 1 | 15.6% |
| I10 Cuidado com Impacto no Outro | Responsabilidade | 2 | **3** ⚠️ | 0 | 1.6% |
| I11 Abertura a Mudança | Aprendizagem e Mudança | 1 | **3** ⚠️ | 0 | 3.1% |
| I12 Disposição para o Novo | Aprendizagem e Mudança | 1 | **4** ⚠️ | 0 | 19.5% |
| I13 Receptividade a Feedback | Aprendizagem e Mudança | 1 | **3** ⚠️ | 0 | 4.7% |
| I14 Autodesenvolvimento | Aprendizagem e Mudança | 2 | **4** ⚠️ | 0 | 5.1% |
| I15 Flexibilidade Cognitiva | Aprendizagem e Mudança | 0 | **3** ⚠️ | 0 | 1.6% |
| I16 Disposição para Ajudar | Relacionamentos | 1 | **3** ⚠️ | 0 | 4.7% |
| I17 Acolhimento | Relacionamentos | 1 | **3** ⚠️ | 0 | 4.7% |
| I18 Mediação de Conflitos | Relacionamentos | 1 | **3** ⚠️ | 1 | 6.2% |
| I19 Tolerância à Diferença | Relacionamentos | 1 | **3** ⚠️ | 1 | 6.2% |
| I20 Construção de Confiança | Relacionamentos | 0 | **3** ⚠️ | 0 | 1.6% |
| I21 Iniciativa de Comunicação | Comunicação | 1 | **3** ⚠️ | 1 | 6.2% |
| I22 Transparência com Liderança | Comunicação | 1 | **3** ⚠️ | 0 | 4.7% |
| I23 Pedido de Ajuda | Comunicação | 1 | **4** ⚠️ | 1 | 15.6% |
| I24 Clareza na Orientação | Comunicação | 1 | **4** ⚠️ | 0 | 8.6% |
| I25 Adaptação da Mensagem | Comunicação | 1 | **3** ⚠️ | 0 | 3.1% |
| I26 Autonomia sob Pressão | Pressão e Decisão | 1 | **3** ⚠️ | 0 | 4.7% |
| I27 Gestão de Múltiplas Demandas | Pressão e Decisão | 1 | **3** ⚠️ | 1 | 6.2% |
| I28 Lida com Insatisfação | Pressão e Decisão | 1 | **3** ⚠️ | 0 | 4.7% |
| I29 Decisão com Informação Limitada | Pressão e Decisão | 1 | **3** ⚠️ | 1 | 6.2% |
| I30 Estabilidade sob Pressão | Pressão e Decisão | 0 | **3** ⚠️ | 0 | 1.6% |
| I31 Busca por Crescimento | Crescimento e Ética | 1 | **3** ⚠️ | 0 | 4.7% |
| I32 Disposição para Ensinar | Crescimento e Ética | 1 | **3** ⚠️ | 1 | 6.2% |
| I33 Integridade | Crescimento e Ética | 1 | **3** ⚠️ | 1 | 6.2% |
| I34 Uso da Autonomia | Crescimento e Ética | 1 | **3** ⚠️ | 1 | 6.2% |
| I35 Compromisso com Evolução | Crescimento e Ética | 0 | **3** ⚠️ | 0 | 1.6% |

⚠️ = indicador que só passou a ser teoricamente alcançável com o redesenho (incluindo os 4 que eram `poderiam = 0`: I15, I20, I30, I35 — agora resolvidos com vínculos genuínos, majoritariamente cross-pilar).

**Resumo:** **35 de 35 indicadores agora são matematicamente alcançáveis** (`poderiam ≥ 3`). Isso é uma melhora completa em relação aos 34 impossíveis de antes.

## O preço honesto: a probabilidade real ainda é baixa

A coluna final assume **escolha aleatória uniforme** (1 de 4 por situação) — é um piso pessimista, não uma previsão real, porque a premissa da metodologia é que pessoas reais **não escolhem aleatoriamente**: alguém com tendência genuína de "Planejamento", por exemplo, tende a escolher a alternativa que reflete isso em mais de uma situação, não por acaso, mas porque é consistente com quem ela é. É exatamente essa consistência que o piso de 3 situações foi desenhado para capturar.

Dito isso, os números são baixos mesmo assim: a mediana das probabilidades sob escolha aleatória fica entre 3–6%, e mesmo os indicadores mais favorecidos (I12 Disposição para o Novo, 19,5%; I09 e I23, 15,6%) estão longe de uma garantia. Isso acontece porque, embora cada indicador agora tenha 3–4 situações candidatas, a maioria delas só tem **1 das 4 alternativas** apontando para aquele indicador especificamente (a maioria das entradas na tabela completa abaixo mostra "1/4") — ou seja, a pessoa precisa acertar a alternativa certa em cada uma das 3 situações, não só "participar" da situação.

Isso é uma limitação estrutural remanescente, não escondida: **o redesenho resolve a impossibilidade matemática, mas não elimina a dependência de um padrão de resposta coerente da pessoa real.** Só o teste de sistema com respostas reais variadas (Fase 2, item 2 do prompt) vai mostrar a taxa de acerto de verdade — a simulação aleatória aqui é só o chão, não o teto.

## Mapeamento completo — situação por situação

### Pilar 1 — Organização e Rotina

**Situação 1 — "Termino uma atividade e ainda tenho tempo disponível."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Adianto a próxima tarefa | I01 Gestão do Tempo (forte) |
| B) Revejo o que já entreguei | I05 Fechamento de Ciclos (clara) |
| C) Organizo as próximas atividades | I03 Planejamento (clara) |
| D) Pergunto se o time precisa de apoio | I16 Disposição para Ajudar (secundária) |

**Situação 2 — "Inicio meu turno e existem várias tarefas para começar."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Ordeno pelas mais urgentes | I02 Priorização (forte); I27 Gestão de Múltiplas Demandas (secundária) |
| B) Faço uma lista antes de começar | I03 Planejamento (clara) |
| C) Começo pela mais simples | I01 Gestão do Tempo (clara) |
| D) Confirmo prioridades com o time | I02 Priorização (secundária) |

**Situação 3 — "Preciso definir por onde começar o trabalho."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Começo pelo que trava o resto | I02 Priorização (clara) |
| B) Escrevo os passos antes de agir | I03 Planejamento (clara) |
| C) Começo pela parte mais simples | I01 Gestão do Tempo (clara) |
| D) Peço uma referência | I04 Consistência na Rotina (secundária) |

**Situação 4 — "Estou finalizando uma atividade importante."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Reviso com cuidado antes de entregar | I05 Fechamento de Ciclos (forte) |
| B) Entrego assim que fica pronta | I05 Fechamento de Ciclos (secundária) |
| C) Peço para alguém revisar comigo | I04 Consistência na Rotina (clara) |
| D) Confiro item por item | I04 Consistência na Rotina (clara) |


### Pilar 2 — Responsabilidade

**Situação 5 — "Percebo um erro que pode afetar um cliente."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Aviso imediatamente | I10 Cuidado com Impacto no Outro (forte); I08 Transparência sobre Atrasos (secundária) |
| B) Busco entender o erro por completo | I07 Proatividade diante de Falhas (clara) |
| C) Aviso e já sugiro solução | I09 Aceitação de Responsabilidade (clara); I21 Iniciativa de Comunicação (secundária) |
| D) Converso com o time antes de decidir | I07 Proatividade diante de Falhas (secundária) |

**Situação 6 — "Eu cometo um erro."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Assumo na hora | I06 Assunção de Erros (forte); I33 Integridade (secundária) |
| B) Explico o que levou ao erro | I04 Consistência na Rotina (secundária) |
| C) Peço desculpas primeiro | I10 Cuidado com Impacto no Outro (clara) |
| D) Corrijo antes de comentar | I07 Proatividade diante de Falhas (clara) |

**Situação 7 — "Percebo que vou atrasar uma entrega."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Aviso com nova estimativa | I08 Transparência sobre Atrasos (forte); I22 Transparência com Liderança (secundária) |
| B) Tento recuperar sozinho | I08 Transparência sobre Atrasos (secundária) |
| C) Aviso e peço apoio | I10 Cuidado com Impacto no Outro (clara) |
| D) Reorganizo minhas prioridades | I02 Priorização (secundária) |

**Situação 8 — "Recebo uma responsabilidade inesperada."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Aceito e já me organizo | I09 Aceitação de Responsabilidade (forte); I27 Gestão de Múltiplas Demandas (secundária) |
| B) Aceito e pergunto o que se espera | I09 Aceitação de Responsabilidade (clara); I23 Pedido de Ajuda (secundária); I13 Receptividade a Feedback (secundária) |
| C) Aceito e busco quem já fez | I09 Aceitação de Responsabilidade (clara); I12 Disposição para o Novo (secundária); I31 Busca por Crescimento (secundária) |
| D) Aceito e ajusto no caminho | I09 Aceitação de Responsabilidade (clara) |


### Pilar 3 — Aprendizagem e Mudança

**Situação 9 — "A empresa muda um processo."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Me adapto e sigo | I11 Abertura a Mudança (forte); I26 Autonomia sob Pressão (secundária) |
| B) Pergunto o porquê antes | I15 Flexibilidade Cognitiva (clara) |
| C) Testo por conta própria | I14 Autodesenvolvimento (clara) |
| D) Sinto resistência, mas me ajusto | I11 Abertura a Mudança (secundária) |

**Situação 10 — "Recebo uma tarefa que nunca fiz."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Topo e aprendo na prática | I12 Disposição para o Novo (forte); I34 Uso da Autonomia (secundária) |
| B) Pesquiso antes de começar | I14 Autodesenvolvimento (clara) |
| C) Pergunto a quem já fez | I12 Disposição para o Novo (clara); I23 Pedido de Ajuda (secundária) |
| D) Peço mais prazo | I12 Disposição para o Novo (secundária) |

**Situação 11 — "Recebo um feedback."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Ouço tudo antes de reagir | I13 Receptividade a Feedback (forte) |
| B) Agradeço e já aplico | I14 Autodesenvolvimento (clara) |
| C) Peço exemplos concretos | I13 Receptividade a Feedback (clara) |
| D) Fico incomodado, mas repenso depois | I13 Receptividade a Feedback (secundária); I06 Assunção de Erros (secundária) |

**Situação 12 — "Preciso aprender uma ferramenta nova."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Vou testando direto | I12 Disposição para o Novo (clara) |
| B) Procuro um curso antes | I14 Autodesenvolvimento (forte); I35 Compromisso com Evolução (secundária) |
| C) Peço para me mostrarem | I12 Disposição para o Novo (secundária) |
| D) Aprendo aos poucos | I15 Flexibilidade Cognitiva (clara) |


### Pilar 4 — Relacionamentos

**Situação 13 — "Um colega precisa de ajuda."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Ajudo na hora | I16 Disposição para Ajudar (forte); I32 Disposição para Ensinar (secundária) |
| B) Pergunto o que ele precisa | I20 Construção de Confiança (clara) |
| C) Ajudo, mas combino um horário | I16 Disposição para Ajudar (clara) |
| D) Indico quem pode ajudar melhor | I16 Disposição para Ajudar (secundária) |

**Situação 14 — "Chega um novo colaborador na equipe."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Me aproximo e me apresento | I17 Acolhimento (forte) |
| B) Explico como as coisas funcionam | I17 Acolhimento (clara); I24 Clareza na Orientação (secundária) |
| C) Deixo no ritmo dele | I20 Construção de Confiança (clara) |
| D) Apresento o mais importante primeiro | I17 Acolhimento (secundária) |

**Situação 15 — "Existe um conflito entre dois colegas."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Converso com os dois | I18 Mediação de Conflitos (forte); I28 Lida com Insatisfação (secundária) |
| B) Não me envolvo | I18 Mediação de Conflitos (secundária) |
| C) Sugiro que conversem entre si | I18 Mediação de Conflitos (clara) |
| D) Aviso alguém de confiança | I18 Mediação de Conflitos (clara) |

**Situação 16 — "Preciso trabalhar com alguém que pensa muito diferente de mim."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Procuro entender a lógica dela | I19 Tolerância à Diferença (forte); I18 Mediação de Conflitos (secundária) |
| B) Foco no resultado comum | I19 Tolerância à Diferença (clara) |
| C) Ajusto minha comunicação | I19 Tolerância à Diferença (clara); I15 Flexibilidade Cognitiva (secundária); I25 Adaptação da Mensagem (secundária) |
| D) É difícil, mas encontro um jeito | I19 Tolerância à Diferença (secundária); I11 Abertura a Mudança (secundária) |


### Pilar 5 — Comunicação

**Situação 17 — "Tenho uma ideia para melhorar um processo."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Compartilho assim que surge | I21 Iniciativa de Comunicação (forte); I31 Busca por Crescimento (secundária) |
| B) Estruturo antes de apresentar | I21 Iniciativa de Comunicação (clara) |
| C) Testo antes de propor | I21 Iniciativa de Comunicação (secundária); I29 Decisão com Informação Limitada (secundária) |
| D) Comento informalmente antes | I21 Iniciativa de Comunicação (secundária) |

**Situação 18 — "Preciso comunicar um problema ao meu líder."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Vou direto ao ponto | I22 Transparência com Liderança (forte); I08 Transparência sobre Atrasos (secundária) |
| B) Já levo uma sugestão | I22 Transparência com Liderança (clara) |
| C) Escolho um bom momento | I22 Transparência com Liderança (clara); I28 Lida com Insatisfação (secundária) |
| D) Explico o contexto todo | I24 Clareza na Orientação (clara) |

**Situação 19 — "Preciso pedir ajuda."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Peço direto | I23 Pedido de Ajuda (forte) |
| B) Tento sozinho primeiro | I23 Pedido de Ajuda (secundária) |
| C) Explico onde travei | I23 Pedido de Ajuda (clara) |
| D) Sinto receio, mas peço | I23 Pedido de Ajuda (secundária) |

**Situação 20 — "Preciso transmitir uma orientação importante para outra pessoa."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Explico de forma direta | I24 Clareza na Orientação (forte); I32 Disposição para Ensinar (secundária) |
| B) Confirmo se entendeu | I24 Clareza na Orientação (clara); I05 Fechamento de Ciclos (secundária) |
| C) Uso um exemplo prático | I25 Adaptação da Mensagem (clara) |
| D) Ajusto conforme a reação | I25 Adaptação da Mensagem (forte); I19 Tolerância à Diferença (secundária) |


### Pilar 6 — Pressão e Decisão

**Situação 21 — "Surge um problema e o líder não está presente."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Decido sozinho e informo depois | I26 Autonomia sob Pressão (forte); I09 Aceitação de Responsabilidade (secundária); I34 Uso da Autonomia (secundária) |
| B) Reúno o time para decidir | I26 Autonomia sob Pressão (clara); I20 Construção de Confiança (secundária) |
| C) Tento contato com o líder | I26 Autonomia sob Pressão (secundária); I22 Transparência com Liderança (secundária) |
| D) Resolvo só o essencial | I30 Estabilidade sob Pressão (clara) |

**Situação 22 — "Recebo várias demandas ao mesmo tempo."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Organizo por prioridade | I27 Gestão de Múltiplas Demandas (forte); I02 Priorização (secundária) |
| B) Alterno entre elas | I27 Gestão de Múltiplas Demandas (secundária) |
| C) Negocio os prazos | I27 Gestão de Múltiplas Demandas (clara); I21 Iniciativa de Comunicação (secundária) |
| D) Foco em uma de cada vez | I27 Gestão de Múltiplas Demandas (clara) |

**Situação 23 — "Um cliente está muito insatisfeito."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Ouço tudo antes de responder | I28 Lida com Insatisfação (forte); I17 Acolhimento (secundária) |
| B) Já busco uma solução | I28 Lida com Insatisfação (clara); I07 Proatividade diante de Falhas (secundária) |
| C) Mantenho o tom calmo | I30 Estabilidade sob Pressão (clara); I18 Mediação de Conflitos (secundária) |
| D) Explico com transparência | I28 Lida com Insatisfação (clara); I33 Integridade (secundária) |

**Situação 24 — "Preciso decidir com poucas informações."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Decido com o que tenho | I29 Decisão com Informação Limitada (forte) |
| B) Busco mais informação rápido | I29 Decisão com Informação Limitada (clara) |
| C) Peço a opinião de alguém | I29 Decisão com Informação Limitada (clara); I13 Receptividade a Feedback (secundária); I23 Pedido de Ajuda (secundária) |
| D) Escolho a opção mais segura | I29 Decisão com Informação Limitada (clara) |


### Pilar 7 — Crescimento e Ética

**Situação 25 — "Surge uma oportunidade de crescimento."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Abraço mesmo sem estar pronto | I31 Busca por Crescimento (forte); I29 Decisão com Informação Limitada (secundária); I12 Disposição para o Novo (secundária) |
| B) Avalio com calma antes | I31 Busca por Crescimento (clara) |
| C) Pergunto o que vai mudar | I31 Busca por Crescimento (secundária) |
| D) Já penso em quem pode ajudar | I35 Compromisso com Evolução (clara) |

**Situação 26 — "Preciso ensinar alguém."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Explico e deixo praticar | I32 Disposição para Ensinar (forte); I16 Disposição para Ajudar (secundária) |
| B) Preparo um passo a passo | I32 Disposição para Ensinar (clara); I17 Acolhimento (secundária); I24 Clareza na Orientação (secundária) |
| C) Ensino no ritmo dela | I32 Disposição para Ensinar (clara); I19 Tolerância à Diferença (secundária) |
| D) Uso exemplos reais | I32 Disposição para Ensinar (clara); I25 Adaptação da Mensagem (secundária) |

**Situação 27 — "Fazer o que é correto parece mais difícil do que fazer o mais fácil."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Escolho o caminho correto | I33 Integridade (forte) |
| B) Penso nas consequências antes | I33 Integridade (clara); I30 Estabilidade sob Pressão (secundária) |
| C) Busco um jeito menos custoso | I33 Integridade (clara) |
| D) Sinto a tentação, mas volto atrás | I33 Integridade (secundária); I06 Assunção de Erros (secundária) |

**Situação 28 — "Recebo autonomia para tomar decisões importantes."**

| Alternativa | Indicador(es) e força |
|---|---|
| A) Decido com confiança | I34 Uso da Autonomia (forte); I09 Aceitação de Responsabilidade (secundária); I26 Autonomia sob Pressão (secundária) |
| B) Uso a autonomia com cautela | I34 Uso da Autonomia (clara) |
| C) Envolvo o time mesmo assim | I34 Uso da Autonomia (secundária) |
| D) Proponho algo diferente | I34 Uso da Autonomia (clara); I35 Compromisso com Evolução (secundária); I11 Abertura a Mudança (secundária) |

## Notas honestas sobre o processo

- **Alguns vínculos são mais fortes que outros.** Onde uma situação tem suas 4 alternativas genuinamente distintas (ex.: Situação 15 — conflito entre colegas, todas as 4 alternativas evidenciam Mediação de Conflitos com nuances diferentes), o vínculo "certamente" (4/4) se mantém. Onde precisei recorrer a cross-pilar para resgatar um indicador (marcados ⚠️ na tabela), a força é predominantemente "secundária" — reflete uma leitura genuína, mas mais indireta.
- **Indicadores com o vínculo mais indireto/frágil, mesmo depois do redesenho:** I01 Gestão do Tempo, I03 Planejamento, I06 Assunção de Erros, I10 Cuidado com Impacto no Outro, I15 Flexibilidade Cognitiva, I20 Construção de Confiança, I30 Estabilidade sob Pressão, I35 Compromisso com Evolução — todos com P(piso) = 1,6% sob escolha aleatória, o menor patamar da tabela. Não acho que estejam errados, mas são os que eu revisaria primeiro se, depois do teste real (Fase 2), a taxa de acerto ficar abaixo do esperado.
- **Algumas alternativas carregam 2–3 leituras simultâneas** (ex.: Situação 8-C "Aceito e busco quem já fez" evidencia Aceitação de Responsabilidade, Disposição para o Novo e Busca por Crescimento ao mesmo tempo). Isso não é forçar o vínculo — é reconhecer que uma escolha real de comportamento frequentemente revela mais de uma coisa ao mesmo tempo. Mas é uma característica nova deste redesenho que vale a Victoria saber: o texto das alternativas não mudou, só ficou mais "aproveitado" nas suas múltiplas leituras genuínas.
- **Nenhum indicador ficou abaixo do piso teórico desta vez** — os 35 alcançam `poderiam ≥ 3`. Isso é diferente de "vai funcionar bem na prática" — só o teste de sistema (Fase 2) mostra isso de verdade.

## Próximo passo

Aguardando aprovação da Victoria para a Fase 2: aplicar este mapeamento em `alternative_indicators` (script revisado + transação atômica, como sempre) e rodar 3–5 respostas de teste reais para medir a taxa de acerto de verdade — não só a probabilidade teórica sob escolha aleatória.
