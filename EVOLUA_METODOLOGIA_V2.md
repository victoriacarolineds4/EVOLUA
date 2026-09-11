# EVOLUA — Metodologia v2: Consolidação e Separação Score/Confiança

**Data:** 11/09/2026
**Escopo:** correção de precisão do mapeamento comportamental + motor de confiança. Preserva integralmente a estrutura oficial (28 situações, 112 alternativas, 7 pilares, 35 indicadores, escala de 4 níveis). Nenhuma situação, pergunta, pilar ou indicador foi criado, removido ou renomeado.
**Documento-base:** [ANALISE_PROFUNDA_SINAL_COMPORTAMENTAL.md](ANALISE_PROFUNDA_SINAL_COMPORTAMENTAL.md) (10/09/2026) — auditoria completa das 112 alternativas contra os 35 indicadores. Este documento não repete essa auditoria; consolida as correções autorizadas a partir dela.

---

## 1. O que existia

O EVOLUA calculava o score de cada indicador como `raw/max × 100` (evidência real sobre o teto teórico) e o score do pilar como a **média simples dos 5 indicadores, sempre, independente de quanta evidência cada um tinha**. Um indicador sem nenhuma resposta que o evidenciasse pontuava 0 e entrava na média do pilar do mesmo jeito que um indicador com evidência real e forte. Não havia nenhum sinal, no motor ou no relatório, distinguindo "medimos e o comportamento é fraco" de "não conseguimos medir isso ainda".

O mapeamento `alternative_indicators` (166 vínculos) tinha sido construído majoritariamente por proximidade temática — a situação pertence ao Pilar X, então suas alternativas tendem a ser vinculadas aos indicadores do Pilar X — sem verificação sistemática de que cada vínculo individual correspondesse a um comportamento específico e defensável.

## 2. Problemas encontrados

1. **Confusão estrutural entre ausência de evidência e comportamento fraco.** Um indicador com `evidenceCount=0` contribuía 0 pontos para a média do pilar exatamente como um indicador genuinamente fraco contribuiria. Este foi o problema que motivou toda esta consolidação — visível no caso real da Victoria (pilar Responsabilidade = 18, quando as 5 parcelas da média eram, na prática, ruído de escassez de dados).
2. **Vínculos por associação temática, não por comportamento.** ~30 dos 166 vínculos não resistiram à pergunta "que comportamento específico desta alternativa justifica este indicador?" (detalhado na auditoria).
3. **Indicadores mal classificados.** ~11 vínculos apontavam para o indicador errado quando um mais preciso existia (ex.: "conferir item por item antes de concluir" estava em Consistência na Rotina; é, por definição, Fechamento de Ciclos).
4. **Cobertura estruturalmente presa a uma única situação.** Como `evidenceCount` no motor soma 1 por alternativa **escolhida**, e cada situação só permite escolher 1 de 4 alternativas, um indicador cujos vínculos genuínos estão todos dentro de uma única situação nunca consegue passar de `evidenceCount=1`, mesmo que pareça ter "vários vínculos" no mapeamento. Isso — não falta de vínculos nominais — era a causa raiz de boa parte da baixa cobertura.
5. **Dois indicadores (I20, I35) medindo algo que uma escolha pontual não consegue evidenciar** — "confiança construída ao longo do tempo" e "compromisso contínuo" são, por definição, padrões observados em múltiplas interações reais, não em uma resposta hipotética isolada.

## 3. O que foi corrigido

### 3.1 Mapeamento (`alternative_indicators`)

47 ajustes aplicados a partir da auditoria: **30 remoções** (vínculo sem justificativa comportamental defensável), **11 reclassificações** (indicador errado → correto), **2 upgrades de força** (evidência que era mais direta do que a força registrada refletia), **4 adições** (evidência genuína identificada na auditoria mas ainda não vinculada). Total: 166 → 140 vínculos.

Script: [backups/metodologia_v2/12_correcao_mapeamento_v2.sql](backups/metodologia_v2/12_correcao_mapeamento_v2.sql) — transação atômica, com backup automático da tabela antes da mudança (`_backup_alternative_indicators_20260911`). **Pendente de aprovação e execução por você**, conforme protocolo de segurança de banco.

Nenhuma remoção teve substituto forçado — onde a evidência genuína não existia, o vínculo foi simplesmente removido, mesmo quando isso deixou um indicador (I04) sem cobertura nenhuma. Não foi criado nenhum vínculo novo "para fechar número"; as 4 adições vieram de comportamentos que a auditoria já havia identificado como genuinamente evidenciados mas não vinculados.

### 3.2 Motor — separação Score × Confiança

Sem alterar a fórmula `raw/max×100` (ela continua correta para o que mede: "do que era possível demonstrar, quanto a pessoa demonstrou"). O que muda:

- Cada indicador ganha um campo `confidence`, derivado do nº de situações distintas que geraram evidência:
  - **0 situações → `insuficiente`** — o indicador não mostra score; mostra "dados insuficientes".
  - **1 situação → `baixa`**
  - **2 situações → `moderada`**
  - **3+ situações → `alta`** (piso `MIN_EVIDENCE_SITUATIONS` atingido)
- **A média do pilar passa a considerar apenas os indicadores com evidência real (`hasScore=true`)** — os de confiança "insuficiente" são excluídos do cálculo, não zerados. Isso é diferente de "excluir quem pontuou baixo": um indicador com confiança baixa mas score real (porque a pessoa realmente respondeu algo que o evidencia) continua entrando na média normalmente, com peso igual aos demais. Só quem não tem nenhum dado é excluído.
- O pilar ganha `confidence` (a mais fraca entre os indicadores considerados) e `indicatorsWithScore` (quantos dos 5 entraram na conta). Se nenhum dos 5 tiver evidência, o pilar mostra "dados insuficientes" em vez de um número.
- O score geral (`overall`) segue a mesma lógica — média só dos pilares com `hasScore=true`.

**Efeito demonstrado em teste isolado** (3 perfis sintéticos, ver Seção 8): num pilar onde só 2 dos 5 indicadores tinham evidência, a média ingênua (todos os 5, como no motor antigo) deu **18** — o mesmo número observado no seu resultado real de Responsabilidade — enquanto a média corrigida (só os 2 com dado) deu **45**. A diferença de 27 pontos não é uma mudança de comportamento da pessoa: é a quantidade de ruído estrutural que a fórmula antiga estava somando à conta.

### 3.3 Relatório

- [pillar-card.tsx](src/features/relatorio/components/pillar-card.tsx): pilares sem nenhuma evidência mostram "sem dados" em vez de um anel de score; pilares com confiança abaixo de "alta" mostram uma nota discreta (ex.: "Confiança baixa · 3/5 indicadores com evidência").
- [motor-report.tsx](src/features/relatorio/components/motor-report.tsx): a seção "Pontos Fortes e Pontos de Atenção" agora só considera pilares com `hasScore=true` (um pilar sem dado não pode aparecer como fraqueza), e cada ponto de atenção com confiança abaixo de "alta" carrega a ressalva explícita: *"este score reflete pouca evidência observada, não necessariamente um comportamento fraco"*. A seção "Padrões mais claros identificados" (adicionada na consolidação anterior) já usava exatamente este critério — apenas trocamos a referência do campo legado `sufficient` para `confidence === "alta"`, sem mudança de comportamento.
- Corrigido, de passagem, um bug pré-existente: `overallLevel` usava o nível do primeiro pilar da lista (`pillars[0]`) em vez do nível calculado a partir do score geral — agora usa `scoreToLevel(overall)` corretamente.

## 4. Como funciona a nova lógica de evidência

```
Situação → pessoa escolhe 1 de 4 alternativas
  → cada alternativa pode ter 0+ vínculos com indicadores (força 1-3)
    → raw = soma das forças das alternativas escolhidas que evidenciam o indicador
    → max = soma da maior força disponível em cada situação capaz de evidenciar o indicador
    → score = raw/max × 100  (só calculado se evidenceCount ≥ 1)
    → confidence = f(nº de situações distintas que contribuíram)
→ Pilar = média dos scores dos indicadores com confidence ≠ "insuficiente"
→ Geral = média dos pilares com hasScore = true
```

## 5. Como score e confiança são calculados (referência rápida)

| evidenceCount | confidence | Aparece na média do pilar? | O que o relatório mostra |
|---|---|---|---|
| 0 | insuficiente | Não | "Dados insuficientes" |
| 1 | baixa | Sim | Score + nota de confiança baixa |
| 2 | moderada | Sim | Score + nota de confiança moderada |
| ≥3 | alta | Sim | Score, sem ressalva |

## 6. Classificação final dos 35 indicadores (após correção do mapeamento)

Situações distintas com evidência genuína possível (teto, não o resultado de uma pessoa específica — uma pessoa real pode medir abaixo disso dependendo do que escolheu):

**Grupo A — bem mensurado (≥3 situações, 14 indicadores, 40%):**
I02 Priorização (4), I03 Planejamento (4), I07 Proatividade diante de Falhas (4), I09 Aceitação de Responsabilidade (3), I12 Disposição para o Novo (4), I14 Autodesenvolvimento (4), I16 Disposição para Ajudar (3), I21 Iniciativa de Comunicação (3), I23 Pedido de Ajuda (6), I24 Clareza na Orientação (3), I25 Adaptação da Mensagem (3), I27 Gestão de Múltiplas Demandas (3), I30 Estabilidade sob Pressão (3), I33 Integridade (3).

**Grupo B — parcial, aproveitável (2 situações, 7 indicadores, 20%):**
I10 Cuidado com Impacto no Outro, I11 Abertura a Mudança, I13 Receptividade a Feedback, I17 Acolhimento, I19 Tolerância à Diferença, I22 Transparência com Liderança, I29 Decisão com Informação Limitada.
Uso recomendado: informativo, sempre com o rótulo de confiança visível — não deve ancorar sozinho uma recomendação de desenvolvimento sem essa ressalva.

**Grupo C — cobertura insuficiente, não estrutural (0-1 situação, 12 indicadores, 34%):**
I01 Gestão do Tempo, I04 Consistência na Rotina (0 — sem cobertura genuína nenhuma), I05 Fechamento de Ciclos, I06 Assunção de Erros, I08 Transparência sobre Atrasos, I15 Flexibilidade Cognitiva, I18 Mediação de Conflitos, I26 Autonomia sob Pressão, I28 Lida com Insatisfação, I31 Busca por Crescimento, I32 Disposição para Ensinar, I34 Uso da Autonomia.
Em princípio mensuráveis com o formato atual — o problema é que cada um tem, hoje, uma única situação "dedicada" e nenhuma segunda situação em outro ponto do questionário que observe o mesmo comportamento de novo. Corrigível **apenas** com redesenho futuro de situações (fora do escopo desta consolidação, que preserva as 28 situações).

**Grupo D — estruturalmente difícil, exige observação longitudinal (2 indicadores, 6%):**
**I20 Construção de Confiança** e **I35 Compromisso com Evolução**. Ver Seção 7.

## 7. Indicadores estruturalmente difíceis (I20, I35)

Diagnóstico (item 7 do prompt): o problema não é mapeamento nem construção de alternativas — é a definição do indicador exigir observação repetida ao longo do tempo, algo que uma única aplicação do questionário não pode fornecer com honestidade, não importa quão bem desenhada seja a situação.

**Recomendação metodológica** (não implementada nesta consolidação — requer decisão de produto):
- O relatório deve tratar I20 e I35 como **"acompanhamento requerido"**, não como score numérico. Em vez de um número, o Mapa de Desenvolvimento pode trazer uma nota fixa do tipo: *"Confiança e compromisso contínuo são construídos ao longo do tempo — este é um ponto para o gestor observar diretamente nos próximos meses, não algo que uma avaliação pontual consegue confirmar."*
- Isso separa explicitamente **o que o teste consegue inferir** (os 33 indicadores restantes, com o grau de confiança apropriado) de **o que só acompanhamento/feedback continuado consegue confirmar** (I20, I35).
- Esta mudança de apresentação **não foi implementada no código nesta rodada** — os dois indicadores hoje seguem o mesmo tratamento dos demais (score + confidence, tipicamente "baixa" ou "insuficiente"). Fica registrada como próxima evolução recomendada (Seção 11), já que altera a interface do relatório para esses 2 casos especificamente e merece validação visual antes de entrar em produção.

## 8. Testes realizados

- `npx tsc --noEmit` — sem erros.
- `npm run build` — build de produção completo, sem erros, 15 rotas geradas.
- `npm run lint` — sem erros.
- Não há suite de testes automatizados no projeto (`package.json` não define `test`); nenhum teste pré-existente foi quebrado por não haver nenhum.
- **Verificação funcional com 3 perfis sintéticos**, via harness isolado (motor real, mapeamento corrigido, sem tocar produção):
  - **Persona 1 (alta evidência)** — respostas escolhidas para maximizar evidência nos indicadores Grupo A. Confirma: indicadores com `evidenceCount≥3` chegam a `confidence="alta"` (I09, I14, I27).
  - **Persona 2 (evidência esparsa)** — respostas deliberadamente fora dos vínculos principais. Confirma: 10 indicadores ficaram com `evidenceCount=0`, todos corretamente marcados `confidence="insuficiente"` e excluídos da média do pilar (não zerados silenciosamente).
  - **Persona 3 (mista)** — perfil intermediário, confirma a lógica em um caso não-extremo.
  - **Checagem de regressão numérica**: comparação direta entre a média "ingênua" (fórmula antiga, todos os 5 indicadores) e a média corrigida — diferenças de até 27 pontos no mesmo pilar, incluindo um caso que reproduz numericamente o "18" observado no seu teste real.
  - **Checagem de confiança crescente**: `evidenceCount` maior → `confidence` mais alta, de forma monotônica, em todos os indicadores testados.
  - **Checagem de sinal duplicado**: existem grupos de indicadores com o mesmo score numérico dentro de uma pessoa — isso é esperado quando cada um tem só 1 evidência e a pessoa escolheu a alternativa de força máxima nela (`raw=max` → 100 para qualquer indicador nessas condições), não é sinal de que dois indicadores estão sendo alimentados pela mesma alternativa. Confirmado, olhando o mapeamento, que não há dois indicadores do Grupo A recebendo evidência das mesmas alternativas sem justificativa distinta — os casos de vínculo duplo (uma alternativa evidenciando 2 indicadores) são todos os secundários já documentados como genuínos na auditoria.
  - Os 7 pilares computaram corretamente nas 3 personas, sem exceções.
- **Não foram criados usuários ou respostas em produção** para este teste — tudo rodou em processo Node isolado, contra uma cópia local do motor e dados lidos (não escritos) do banco.

## 9. O que o EVOLUA consegue afirmar

- Para os **14 indicadores do Grupo A**: um score numérico com confiança alta, comparável entre pessoas, baseado em pelo menos 3 situações comportamentais distintas.
- Para os **7 do Grupo B**: uma leitura direcional (score real, baseado em evidência real), mas com confiança moderada — útil como indício, não como conclusão fechada.
- Para os **12 do Grupo C** e os **2 do Grupo D**: hoje, na melhor das hipóteses, uma leitura de confiança baixa; frequentemente, nenhuma leitura numérica (dados insuficientes). O relatório agora deixa isso visível em vez de escondido dentro de uma média.
- Que **evidência repetida em contextos diferentes aumenta a confiança da medição** — isso está implementado e testado.
- Que **um pilar com poucos indicadores medidos não é automaticamente "fraco"** — sua média agora reflete só o que foi de fato observado.

## 10. O que o EVOLUA NÃO deve afirmar

- Não deve apresentar o score de I20 (Construção de Confiança) ou I35 (Compromisso com Evolução) como uma medição confiável de comportamento — mesmo depois desta correção, a natureza desses dois indicadores excede o que uma aplicação pontual consegue confirmar (Seção 7).
- Não deve tratar um pilar ou indicador com confiança "baixa" ou "insuficiente" como evidência de fraqueza — o relatório agora comunica isso explicitamente, mas a interpretação humana (gestor lendo o relatório) precisa ser orientada a respeitar essa distinção.
- Não deve comparar, entre duas pessoas, o score de um indicador com confiança muito diferente (ex.: pessoa A com `alta` vs pessoa B com `baixa` no mesmo indicador) como se fossem igualmente conclusivos.
- Não deve — e esta consolidação não tentou — inflar a cobertura dos indicadores Grupo C via mapeamento; a limitação é real e está documentada, não escondida.

## 11. Próximas evoluções recomendadas (não implementadas agora)

1. **Apresentação especial para I20/I35** no relatório (Seção 7) — mudança de UI, não de motor; precisa de validação visual.
2. **Redesenho de situações** (fora do escopo desta consolidação, que preservou as 28 atuais) para dar aos 12 indicadores do Grupo C uma segunda situação genuína — isso exigiria decisão explícita sua, já que adicionar/alterar situações não é uma correção de mapeamento, é uma mudança de conteúdo do instrumento.
3. **Camadas complementares (DISC, Tipo Psicológico, Motivadores, Estilo Operacional)** — já implementadas e validadas anteriormente com 3 personas reais via UI (166 vínculos: 40 DISC, 17 Tipo, 11 Motivador, 46 Estilo). As correções desta consolidação tocaram exclusivamente `alternative_indicators`; os vínculos dessas 4 camadas não foram alterados e continuam válidos como estavam. Reavaliação: nenhuma das alternativas cujo vínculo de indicador mudou nesta rodada teve seu texto alterado, então a leitura comportamental que sustentava os vínculos de DISC/Tipo/Motivador/Estilo permanece válida sem necessidade de nova auditoria.
4. **Indicador de confiança visível também no nível do indicador individual dentro do card do pilar** (hoje só o agregado do pilar aparece na UI) — considerar se vale a pena para o gestor ver o detalhe por indicador, não só por pilar, sem poluir a tela (o app já prioriza "pouco texto, muito espaço" — CLAUDE.md).

---

## Pendências que dependem de você

1. **Aprovar e rodar** [backups/metodologia_v2/12_correcao_mapeamento_v2.sql](backups/metodologia_v2/12_correcao_mapeamento_v2.sql) (140 vínculos corrigidos, já copiado para sua área de transferência).
2. Depois de rodar: peço para eu fazer a **verificação ao vivo em produção** (consulta real, não comparação com arquivo) antes de considerar a correção do mapeamento concluída.
3. Decidir se quer que eu avance com a apresentação especial de I20/I35 (item 1 da Seção 11) como próximo passo.
