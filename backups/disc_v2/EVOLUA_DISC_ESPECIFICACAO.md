# EVOLUA DISC — Especificação Oficial (v2.1 — revisão de rigor)

Status: **proposta pronta para revisão**. Migration em `12_disc_rebalanceamento_v2.sql`
(mesma pasta) — preparada, **não executada**. A correção de cálculo (normalização por
teto, item 4 abaixo) já está em produção (código, sem tocar DB/conteúdo) — commit `0aa86fc`.

**v2.1 corrige v2** (entregue antes): a v2 tinha um erro de reconciliação (uma
alternativa não auditada) e 3 vínculos I aprovados sem rigor suficiente. Ver Parte 1.

## 1. Objetivo

DISC no EVOLUA representa uma **tendência comportamental**, não um traço fixo,
inferida das escolhas em situações de trabalho reais. Não é diagnóstico clínico.

## 2. Definição de cada dimensão (usada para auditar todo vínculo)

- **D — Dominância**: iniciativa, decisão, assertividade, enfrentamento, velocidade,
  foco em resultado, autonomia, tomada de decisão.
- **I — Influência**: comunicação, persuasão, influência social, entusiasmo,
  relacionamento, mobilização de pessoas, expressão, interação.
- **S — Estabilidade**: constância, colaboração, paciência, previsibilidade, suporte,
  estabilidade diante de mudanças, construção de confiança.
- **C — Conformidade**: precisão, critérios, análise, organização, qualidade,
  atenção a detalhes, estrutura, respeito a padrões.

Nenhuma dimensão é superior a outra — são estilos, não qualidades morais.

## 3. Reconciliação matemática (v2 → v2.1)

A v2 relatou "30 mantidos + 4 reclassificados + 4 removidos + 1 desdobrado" (39 itens)
contra um estado inicial de **40** vínculos — a soma não batia. Causa: **S27-D**
("Sinto a tentação do caminho fácil, mas volto atrás e faço certo", S=1) não constava
na auditoria original — foi encontrada só nesta revisão, comparando a lista completa de
40 vínculos em produção contra as chaves auditadas. Reavaliada agora: "resistir a um
atalho e se corrigir" é integridade geral, não discrimina D/I/S/C com especificidade —
qualquer perfil pode exibir esse comportamento. **Removida.**

**Estado inicial (produção hoje):** 40 vínculos — D=12, I=7, S=15, C=6.

| Operação | Qtde | Efeito líquido em linhas |
|---|---|---|
| Mantidos (`keep`) | 30 | 0 |
| Removidos (`weak_remove`) | **5** (era 4 — +S27-D) | −5 |
| Reclassificados (`weak_reclassify`) | 4 | 0 (delete+insert, código muda) |
| Desdobrado existente em dupla dimensão (`dual`) | 1 (S22-C: D2 → D1+I1) | −1 original +2 novos = **+1** |
| **Soma da auditoria dos 40 originais** | 30+5+4+1 = **40** ✓ | |
| Novas adições simples | **16** (era 19 — ver Parte 4) | +16 |
| Nova dupla dimensão (S36-D: D1+C1) | 1 caso, 2 linhas | +2 |
| **Total final** | | 40 − 5 − 1 + 2 + 16 + 2 = **54** |

**Estado final (proposto):** 54 vínculos — D=17, I=8, S=19, C=10. Matemática conferida
por script (`decisions_v2.json` + recomputo em Python), não por conta manual.

## 4. Revisão individual dos 5 vínculos fracos apontados — "validade > balanceamento"

| Chave | Comportamento | Dimensão mais defensável | Específico o bastante? | Decisão |
|---|---|---|---|---|
| S05-C ("aviso e já sugiro forma de contornar") | Comunicar um problema propondo solução | Nenhuma com convicção — mistura D e I sem clareza, e já é medido por I21/I07 | Não — genérico, qualquer perfil "resolvedor" escolheria | **REMOVIDO** |
| S17-D ("comento informalmente antes de levar adiante") | Validação social informal antes de agir | Nenhuma — pode ser cautela (C) ou evitar exposição, ambíguo | Não | **REMOVIDO** |
| S18-B ("levo o problema já com sugestão de solução") | Comunicar + propor solução ao líder | Nenhuma com convicção — a questão já tem D (S18-A) e S (S18-C) claros; B fica no meio | Não | **REMOVIDO** |
| S35-C ("peço que cada um explique antes de decidirmos juntos") | Facilitação ativa de diálogo em grupo, mobiliza as partes a se expressarem | **I** — a ação central É a comunicação/facilitação, não incidental a outra coisa | Sim — distinto das outras 3 alternativas da mesma questão (intervir/deixar esfriar/decidir sozinho) | **MANTIDO** (I=2) |
| S36-D ("decido sozinho, mas de um jeito que dá pra desfazer") | Decisão autônoma E cautelosa/reversível | **D+C**, genuinamente dois construtos presentes ao mesmo tempo | Sim — distinto de S36-A (D puro, sem cautela) | **MANTIDO** (dual D=1+C=1) |

Aplicando o mesmo rigor a *toda* a lista de adições, duas inconsistências internas
foram encontradas e corrigidas:
- **S33-A** ("aviso todos os afetados com nova estimativa") havia sido classificada
  como I. É estruturalmente quase idêntica a **S07-A** (já C=3: "aviso com nova
  estimativa") — mesma lógica de comunicação estruturada sobre um atraso. "Todos os
  afetados" não é diferença suficiente para mudar de dimensão. **Reclassificada para C=2**,
  consistente com o par análogo.
- **S39-A** ("ofereço ensinar mesmo sem pedido") havia sido classificada como I. É o
  mesmo padrão de **S13-A** ("ajudo na hora, mesmo interrompendo"), já reclassificado
  nesta mesma auditoria de I para S por ser ajuda espontânea (suporte), não persuasão.
  Por coerência interna, **reclassificada para S=2**.

## 5. Tabela completa dos 18 vínculos novos (16 simples + 1 caso dual = 2 linhas)

| Situação-Alt | Dimensão | Força | Classificação | Justificativa |
|---|---|---|---|---|
| S14-B | I | 2 | defensável | Explicar proativamente sem esperar perguntarem = comunicação proativa |
| S26-D | I | 2 | forte | Usar exemplos reais para facilitar entendimento = expressão persuasiva |
| S29-A | D | 2 | forte | Adiantar entregas que não dependem de ninguém, bloqueado = iniciativa |
| S30-A | S | 2 | forte | Seguir a mesma rotina sem supervisão = constância textual |
| S31-A | C | 2 | forte | Revisão completa antes de encerrar = precisão/qualidade |
| S32-A | D | 2 | forte | Assumir na hora, desconfortável, na frente do time = enfrentamento |
| S32-D | S | 1 | defensável | Agradecer e corrigir depois = resiliência relacional |
| S33-A | **C** (corrigido) | 2 | forte | Análoga a S07-A — comunicação estruturada, não persuasão |
| S34-D | C | 2 | forte | Entender por que não funciona antes de mudar = análise |
| S35-A | D | 3 | forte | Intervir na hora propondo decisão em conflito = enfrentamento |
| S35-C | I | 2 | defensável | Facilitação ativa de diálogo = mobilização de pessoas |
| S36-A | D | 2 | forte | Decidir e aproveitar sozinho = autonomia |
| S36-D | D+C | 1+1 | forte (dual) | Decisão reversível = decisão E cautela genuínas |
| S37-A | S | 2 | forte | Ouvir com calma e perguntar o que esperava = receptividade |
| S38-A | D | 2 | forte | Começar a estudar por conta própria, sem pedido = iniciativa |
| S39-A | **S** (corrigido) | 2 | forte | Mesmo padrão de S13-A — suporte, não persuasão |
| S40-A | C | 2 | forte | Estruturar o tempo com metas claras = organização |

Nenhum vínculo classificado como "fraco mas útil para balancear" sobreviveu à revisão —
os que não passaram no teste de especificidade foram removidos mesmo piorando a
cobertura de I (ver Parte 8).

## 6. Arquitetura: independente dos indicadores (mantida)

DISC continua calculado por vínculo direto alternativa→DISC, paralelo e independente de
`alternative_indicators`. Acoplar as duas camadas (derivar DISC dos indicadores) faria
qualquer ajuste de indicador mexer silenciosamente no perfil — pior para auditabilidade,
sem ganho de validade comportamental. Mantida.

## 7. Correção de cálculo — normalização por teto (JÁ EM PRODUÇÃO, `0aa86fc`)

**Este é o achado mais importante desta revisão, e é sobre a FÓRMULA, não sobre o
mapeamento.** `share` era `raw / soma de todos os raw` — isso favorece estruturalmente
qualquer código com teto maior, independente do comportamento real da pessoa.

Simulação com persona sintética 50/50 D/C (metade das respostas comportamento D, metade
C, 500 execuções, motor real):

| Fórmula | D vence | C vence | Outro |
|---|---|---|---|
| `raw / soma total` (antiga) | 470/500 (94%) | 27/500 (5%) | 3 |
| `raw / teto do próprio código` (nova) | 255/500 (51%) | 231/500 (46%) | 14 |

A fórmula antiga reportaria "D" para uma pessoa genuinamente 50/50 em 94% dos casos —
não por comportamento, só porque D tinha mais situações/força disponível no mapeamento.
A nova fórmula (mesmo princípio `raw/max×100` já usado nos indicadores, aplicado por
código antes de comparar) produz ~50/50, o resultado correto.

**Já implementada e testada** em `src/lib/motor/engine.ts` (`computeDimension`), sem
depender do rebalanceamento de vínculos desta migration — vale com qualquer mapeamento,
inclusive o atual. Reconfirmado após o rebalanceamento proposto: os 4 pares mistos
(D/I, I/S, S/C, C/D) saem entre 46%/50%–52%/58% nas simulações — não mais os 94%/5% do
cálculo antigo.

## 8. Proximidade (mantida em 10pp) — reavaliada após normalização

Com `share` agora normalizado, a proximidade de 10 pontos percentuais foi re-simulada:
personas mistas 50/50 disparam `isClose` em 51%–58% dos casos (antes da normalização:
14%–62%, mas contra uma escala injusta). Como a escala normalizada é comparável entre
códigos, a margem de 10pp agora significa a mesma coisa para qualquer par — mantida.

## 9. Simulação completa (motor real, mapeamento proposto + normalização)

500 execuções por cenário:

| Cenário | Resultado |
|---|---|
| A. D pura | 500/500 (100%), isClose=0 |
| B. I pura | 500/500 (100%), isClose=1 (0.2%) |
| C. S pura | 500/500 (100%), isClose=0 |
| D. C pura | 500/500 (100%), isClose=0 |
| E. D/I mista 50/50 | D=250, I=249, isClose=54% |
| F. I/S mista 50/50 | S=257, I=237, isClose=51% |
| G. S/C mista 50/50 | C=262, S=232, isClose=58% |
| H. C/D mista 50/50 | D=250, C=243, isClose=58% |
| I. Respostas aleatórias | sem código dominando artificialmente; 3/500 insuficiente |
| J. Contraditória D/C (repetição) | D=289, C=202 — ainda alguma assimetria residual (58%/40%), mas categoricamente diferente dos 94%/5% pré-correção |

Item J mostra que a normalização corrige o essencial mas não elimina 100% da vantagem
estrutural de D (ele ainda tem o maior teto absoluto, 35 contra 21 de C) — resíduo
esperado, não um bug; documentado como limitação (Parte 11).

## 10. Teste de sensibilidade

Uma única resposta não muda o predominante em nenhum dos cenários testados (personas
puras seguem 100% estáveis a variações de 1 resposta, dado que o teto por código exige
várias situações concordantes). O teste inverso (mudança sistemática e não pontual de D
para I ao longo de várias respostas) foi coberto pelas simulações mistas 50/50 — o
resultado acompanha a mudança de comportamento de forma proporcional, não binária.

## 11. Caso Allan

**Ainda pendente** — você indicou "Allan, CEO, empresa Allan Champs" mas a consulta
SQL somente-leitura que pedi ainda não foi executada/colada nesta conversa. Assim que
tiver o resultado (situação → alternativa escolhida), cruzo localmente com o mapeamento
atual e o proposto e mostro exatamente por que D saiu predominante e I não apareceu.

## 12. Limitações reais que permanecem

- **I continua a dimensão de menor cobertura** (8 vínculos, 7 situações — não melhorou
  em nº de situações, só trocou quais). Remapeamento rigoroso não resolve isso — exige
  reescrever 2–3 alternativas (candidatos: S08, S13) para introduzir uma opção
  genuinamente I onde hoje nenhuma das 4 alternativas representa esse comportamento.
  Não incluído nesta entrega.
- **D mantém o maior teto absoluto** mesmo pós-correção (35 vs 21 de C, 32 de S, 17 de
  I) — a normalização corrige a comparação de share, mas não move o teto em si; em
  casos de comportamento genuinamente contraditório/ambíguo, D ainda tem uma vantagem
  residual (~10-15pp acima do 50/50 ideal nas simulações).
- `methodology_version` (schema) não foi criado — risco baixo (só vínculos mudam, texto
  não), mas o mecanismo formal ainda não existe.
- Script de auditoria automática (item 25 do prompt original) não foi construído.
