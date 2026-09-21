# Auditoria de Aceitação — EVOLUA 40 (pré-piloto)

**Data:** 18/09/2026
**Natureza:** Read-only na auditoria original (§1-16 abaixo). Os itens 1, 2 e 3 do bloco 15 ("O que precisa ser feito antes do piloto") foram corrigidos a pedido da Victoria em seguida — ver §17.
**Natureza (auditoria original):** Read-only. Nenhuma alteração foi feita em metodologia, código ou banco durante esta auditoria.
**Método:** inventário do estado real (banco + código, não documentação antiga) + harness em Node/TypeScript importando diretamente `src/lib/motor/engine.ts`, `scoring.ts` e `report-builder.ts` de produção — não uma reimplementação em outra linguagem. Os dados de vínculo (situação→alternativa→DISC/Tipo/Motivador/Estilo/Indicador) foram reconstruídos a partir dos scripts efetivamente aplicados em produção (reconstrução + v2.1 + as 4 migrations aplicadas hoje) e conferem com os totais que as próprias migrations validaram ao rodar.

---

## 1. ESTADO REAL DO EVOLUA

| Item | Valor real |
|---|---:|
| Situações | 40 |
| Alternativas | 160 (4 por situação) |
| Indicadores | 35 (5 por pilar) |
| Pilares | 7 |
| Vínculos alternativa→indicador | 192 |
| Vínculos alternativa→DISC | 67 (D20/I10/S21/C16) |
| Vínculos alternativa→Tipo Psicológico | 29 |
| Vínculos alternativa→Motivador | 24 |
| Vínculos alternativa→Estilo Operacional | 64 |
| `MIN_EVIDENCE_SITUATIONS` (piso de confiança "alta") | 3 |
| `DIMENSION_PROXIMITY_MARGIN` (margem de "próximo") | 10 pontos percentuais |

Achado de processo (não é bug de metodologia, mas afeta a confiabilidade da auditoria): **`supabase/migrations/` não reflete o histórico real do banco.** Pelo menos duas correções de conteúdo importantes (`12_disc_rebalanceamento_v2.sql` — rebalanceamento DISC — e `12_correcao_mapeamento_v2.sql` — correção dos indicadores, 166→140 vínculos) foram aplicadas via SQL Editor direto, fora da pasta de migrations, e só descobri o estado real do banco quando a migration 016 (desta sessão) abortou por divergência de contagem. Isso significa que, hoje, **ler `supabase/migrations/` sozinho não é suficiente para saber o que está em produção** — é preciso somar também os scripts em `backups/`. Recomendo, antes do piloto, consolidar isso: rodar `pg_dump --schema-only` + um dump dos dados de metodologia atual e congelar como a "migration 020" ou equivalente, para que a pasta de migrations volte a ser fonte de verdade.

---

## 2. TESTES EXECUTADOS

1. Integridade estrutural (contagens, duplicatas, órfãos, `evidence_strength` fora de 0–3)
2. Cobertura dos 35 indicadores (situações/alternativas/evidência máxima por indicador)
3. Cobertura dos 4 perfis DISC + teste de oportunidade (persona pura por código)
4. 12 personas sintéticas (D, I, S, C puros; 4 mistas; equilibrada; contraditória; baixa evidência; aleatória)
5. Teste de inversão (D↔S, I↔C)
6. Teste de determinismo (10 execuções idênticas)
7. Teste de sensibilidade (30 trocas de 1 única resposta sobre uma persona D-pura, em 10 situações)
8. Teste de respostas "perfeitas" (funcionário ideal)
9. Teste de empate/proximidade (busca por empate exato + busca de caso real de proximidade no Motivador)
10. Verificação pontual: motivadores inativos (PRO/SEG) com vínculo residual
11. Rastreabilidade (leitura de código: todo campo do relatório até a linha do banco)
12. Revisão de código de `motor.service.ts` e `report-builder.ts`

**Não executados nesta rodada** (ver §17): teste de ponta a ponta via UI real (criar aplicação → link público → responder → concluir) e nova bateria de multitenancy ao vivo — ver justificativa no bloco 13.

---

## 3. RESULTADOS

| Área | Teste | Resultado | Severidade | Evidência |
|---|---|---|---|---|
| Estrutura | 40 situações / 160 alternativas / 35 indicadores / 7 pilares | 🟢 PASSOU | — | contagem exata, sem duplicata |
| Estrutura | Vínculos órfãos / `attribute_id` inválido / `evidence_strength` fora de 0-3 | 🟢 PASSOU | — | 0 ocorrências nas 5 tabelas de vínculo |
| Indicadores | Cobertura ≥3 situações (piso de confiança "alta") | 🔴 FALHOU | **CRÍTICO** | 18 de 35 indicadores (51%) nunca atingem "alta"; 1 (I20) nunca sai de "insuficiente" |
| DISC | Oportunidade — persona pura consegue ser predominante? | 🟡 RESSALVA | **CRÍTICO** (só para C) | D/I/S saem confiantes; C sai `isClose=true` mesmo na persona mais pura possível |
| DISC | Cobertura por código (I é a mais pobre) | 🟡 RESSALVA | MODERADO | I: 10 vínculos/9 situações vs D: 20/19 — confirmado também na persona "equilibrada" (I sai sub-representada) |
| Motor | Determinismo | 🟢 PASSOU | — | 10/10 execuções idênticas |
| Motor | Inversão (D↔S, I↔C) | 🟢 PASSOU | — | as 4 trocas mudaram na direção esperada |
| Motor | Sensibilidade (1 resposta) | 🟢 PASSOU | — | 30 trocas testadas, nenhuma mudou DISC nem moveu overall ≥5 pontos |
| Motor | "Resposta perfeita" | 🟢 PASSOU (com ressalva de método) | BAIXO | nenhuma combinação simples maximiza todos os pilares (61-97) |
| Relatório | Coerência Motivador vs DISC/Tipo/Estilo | 🔴 FALHOU | **CRÍTICO** | bug reproduzido com dados reais — ver §4.1 |
| Código | `motor.service.ts` não filtra `active=true` nas 4 dimensões complementares | 🟡 RESSALVA | BAIXO/MODERADO | hoje inofensivo (PRO/SEG sem vínculo), mas frágil |
| Segurança | Multitenancy/RLS | 🟢 PASSOU (evidência de sessão anterior, não reexecutado) | — | ver §13 |
| Processo | `supabase/migrations/` como fonte de verdade | 🔴 FALHOU | MODERADO | histórico real está espalhado em `backups/`, não só em `migrations/` |

---

## 4. PROBLEMAS ENCONTRADOS (comprovados pelos testes)

### 4.1 — CRÍTICO: o Motivador pode apresentar um empate de 3 vias como certeza (bug reproduzido)

`src/lib/motor/report-builder.ts`, linha 134 (array `dimensions`) e linha 102 (frase-resumo): ambos usam `d.motivators.sufficient` para decidir se mostram o motivador como confiante. **Todas as outras 3 dimensões (DISC, Tipo, Estilo) usam `leader().confident`, que exige `sufficient && !isClose`.** O Motivador nunca checa `isClose` — o valor existe (o motor calcula), mas é ignorado nesse ponto do código.

Prova com dados reais (busca aleatória, seed fixo, trial 13):

```
Ranking: APR 34% (3 evidências) | AUT 33% (2 evidências) | CNF 33% (2 evidências)
motivators.isClose = true   (a diferença entre o 1º e o 2º é de só 1 ponto percentual)
motivators.sufficient = true
report.dimensions[motivador].confident = true   <- deveria ser false, é um empate de 3 vias
```

Resumo gerado nesse caso: *"...e **se move principalmente por** aprendizado."* — linguagem assertiva, sem nenhum hedge, para um resultado que é estatisticamente um sorteio entre 3 motivadores. Se essa mesma proximidade acontecesse em DISC, Tipo ou Estilo, o texto sairia como *"...pode se mover por X, ainda com poucas evidências"* — o padrão que o resto do produto usa consistentemente para não afirmar o que não pode afirmar.

**Correção sugerida (não aplicada — fora do escopo desta auditoria):** trocar `d.motivators.sufficient` por `mot.confident` (equivalente a `d.motivators.sufficient && !d.motivators.isClose`) nas linhas 102 e 134 de `report-builder.ts`. É uma mudança de 2 linhas, sem risco aparente — mas decisão de quando aplicar é da Victoria, não foi feita aqui.

### 4.2 — CRÍTICO: 18 dos 35 indicadores (51%) nunca podem atingir confiança "alta"

Calculado com o mapeamento real (`alternative_indicators`, 192 vínculos): para cada indicador, contei quantas das 40 situações têm pelo menos uma alternativa vinculada a ele.

| Situação de cobertura | Qtde de indicadores | O que significa |
|---|---:|---|
| 0 situações | 1 (**I20 — Construção de Confiança**) | Nunca terá score — sempre "dados insuficientes", para qualquer pessoa |
| 1 situação | 2 (I04, I35) | Sempre capados em confiança "baixa" |
| 2 situações | 15 | Sempre capados em confiança "moderada", nunca "alta" |
| exatamente 3 situações (no piso) | 10 | Qualquer resposta "fora do padrão" numa das 3 já derruba a confiança |
| ≥4 situações | 7 | Cobertura confortável |

Isso **não é um bug que quebra o sistema** — o motor lida com isso corretamente (mostra "dados insuficientes" em vez de inventar um score), e é consistente com o que já estava documentado (`REALINHAMENTO_METODOLOGIA_OFICIAL.md` já registrava ~40% de cobertura real antes da expansão para 40 situações). Mas é uma limitação estrutural relevante para o piloto: **a maioria dos indicadores vai aparecer com confiança baixa ou moderada para praticamente todo mundo, sempre** — não é um problema pontual de uma pessoa, é o teto do instrumento atual. Isso deveria ser algo que a Victoria comunica conscientemente ao entrar no piloto, não uma surpresa.

Lista completa por indicador está em `indicator_coverage.json` (gerado pelo harness, anexo a esta auditoria).

### 4.3 — CRÍTICO (mas específico ao perfil C): mesmo a persona DISC mais pura possível não sai confiante em C

Construí uma persona sintética que escolhe, em toda situação onde existe alguma alternativa vinculada a C, exatamente essa alternativa — ou seja, o comportamento mais consistentemente "C" que o próprio instrumento permite expressar. Resultado:

```
Persona pura C: top=C, share C:37% D:27% I:20% S:16%, isClose=TRUE
```

Ao mesmo tempo, as personas puras D, I e S saem todas com `isClose=false` (confiantes). **C é o único dos 4 perfis que nunca consegue ser reportado com confiança plena, nem no cenário ideal construído para maximizá-lo.** É a mesma dinâmica que expliquei na investigação anterior sobre o Allan (teto de C muito menor que o de D fazendo o `share` de C ser estatisticamente instável), agora comprovada de forma controlada e reprodutível, não só num caso real.

### 4.4 — MODERADO: `motor.service.ts` não filtra `active=true`

`loadMotorMethodology()` busca `disc_profiles`, `psychological_types`, `motivators` e `operational_styles` inteiros, sem `.eq("active", true)`. Hoje isso é inofensivo porque os únicos atributos inativos (PRO, SEG) não têm nenhum vínculo em `alternative_motivators` (confirmado: 0 vínculos residuais). Mas é uma dependência frágil — se algum dia um atributo com vínculos reais for desativado (o próprio fluxo que a Victoria já usou para PRO/SEG), ele continuaria aparecendo nos relatórios como se estivesse ativo, silenciosamente.

### 4.5 — MODERADO: histórico do banco não está unificado em `supabase/migrations/`

Já descrito em §1. Risco operacional (dificulta auditoria futura e onboarding de outro dev), não risco de metodologia.

---

## 5. FALSOS ALARMES (pareciam problema, testes mostraram que não são)

- **"O sistema pode ser enganado por respostas estrategicamente 'corretas'"** — testei escolhendo, em cada situação, a alternativa com maior peso total de evidência de indicador. Resultado: overall 83 (alto, mas não 100), pilares variando de 61 a 97 — **não existe uma combinação simples que maximize tudo ao mesmo tempo.** Ressalva: este é um proxy (evidência de indicador), não uma simulação de "tentativa deliberada de parecer ideal" com conhecimento da metodologia — um teste mais adversarial (alguém que estudasse o instrumento) não foi tentado.
- **"Uma resposta isolada pode dominar um indicador"** — não é possível por construção: `evidenceCount` conta situações distintas, não alternativas, e o piso de confiança exige 3 situações diferentes. Confirmado também empiricamente no teste de sensibilidade (nenhuma troca de 1 resposta moveu o resultado de forma desproporcional).
- **"O resultado pode variar entre execuções iguais"** — não. 10/10 execuções idênticas.
- **"A inversão de comportamento não muda o resultado"** — mudou nos 4 casos testados (D↔S, I↔C), na direção esperada.

---

## 6. RISCOS METODOLÓGICOS (que permanecem após os testes)

1. Meio do instrumento (Motivador, Tipo Psicológico) tem cobertura ainda mais escassa que DISC — 16/40 e 26/40 situações respectivamente, mesmo após o fechamento de lacunas desta semana. Grande parte das pessoas vai receber "ainda com poucas evidências" nessas duas leituras.
2. C (DISC) e I (DISC) são estruturalmente mais difíceis de confirmar com confiança que D e S — não por acaso, mas porque o instrumento tem menos alternativas que discriminam esses dois construtos com especificidade suficiente (ver `EVOLUA_DISC_ESPECIFICACAO.md §12`, que já documentava isso antes desta auditoria).
3. Nenhuma validação empírica contra padrão-ouro existe até hoje — tudo aqui é consistência interna do instrumento, não prova de acurácia real (o que a Victoria já sabia e é o motivo de ter pedido esta auditoria).

## 7. RISCOS TÉCNICOS (comprovados)

1. Bug do Motivador (§4.1) — o único que classifico como risco técnico real e de correção rápida.
2. Filtro `active` ausente (§4.4).
3. Fragmentação do histórico de migrations (§4.5, §1).

---

## 8. PERSONAS SINTÉTICAS — resultados completos

| Persona | DISC (top, share) | Tipo | Motivador | Estilo | Overall | Label do relatório |
|---|---|---|---|---|---:|---|
| 01 D forte | D 44% (isClose=false) | Idealista | Autonomia | Executor | 80 | Perfil Dominante — confiante |
| 02 I forte | I 38% (isClose=false) | Idealista | Autonomia | Executor | 82 | Perfil Influente — confiante |
| 03 S forte | S 44% (isClose=false) | Idealista | — (insuficiente) | Executor | 71 | Perfil Estável — confiante |
| 04 C forte | C 37% (**isClose=true**) | Idealista | — (insuficiente) | Planejador | 72 | Perfil Conforme — **tendência** |
| 05 D+I | I 44% / D 36% (isClose=true) | Artesão | Desafios | Executor | 63 | Perfil Influente — tendência |
| 06 I+S | S 33% / D 25% (isClose=true) | Artesão | Desafios | Planejador | 65 | Perfil Estável — tendência |
| 07 S+C | C 48% / S 30% (isClose=false) | Guardião | Autonomia | Planejador | 54 | Perfil Conforme — confiante |
| 08 C+D | D 50% / C 37% (isClose=false) | Artesão | — (insuficiente) | Executor | 60 | Perfil Dominante — confiante |
| 09 equilibrado | C 31% (isClose=true; D/S empatados em 25%, I sub-representado em 18%) | Guardião | Confiança | Planejador | 54 | Perfil Conforme — tendência |
| 10 contraditória | D 33% / C 28% (isClose=true) | Idealista | — (insuficiente) | Executor | 78 | Perfil Dominante — tendência |
| 11 baixa evidência (5/40 respostas) | insuficiente (`top=null`) | insuficiente | insuficiente | insuficiente | 42 | ainda mostra "tendência a Dominante" hedged — ver nota |
| 12 aleatória (seed fixo) | I 40% (isClose=false) | Idealista | Confiança | Colaborativo | 46 | Perfil Influente — confiante |

**Nota sobre a persona 11:** na prática, uma resposta com só 5 de 40 situações nunca chega a `status=completed` (a validação da migration 014 exige todas as respostas para permitir conclusão) — então este cenário extremo, embora informativo sobre o comportamento do motor isoladamente, não é alcançável no fluxo real do produto. Ainda assim, o motor se comportou corretamente: hedge em toda a linguagem, `top=null`.

Dados completos em `persona_results.json`.

---

## 9. TESTE DE INVERSÃO — antes/depois

| Código puro | Invertido para | Top antes | Top depois | Mudou na direção esperada? |
|---|---|---|---|---|
| D | S | D | S | ✅ sim |
| I | C | I | C | ✅ sim |
| S | D | S | D | ✅ sim |
| C | I | C | I | ✅ sim |

---

## 10. TESTE DE SENSIBILIDADE — casos relevantes

Testei 10 situações × 3 trocas cada (30 trocas de uma única resposta) sobre a persona D-pura. **Nenhuma** produziu mudança de perfil DISC predominante nem moveu o `overall` em 5 pontos ou mais. Não há efeito cascata indevido nem insensibilidade suspeita nos casos testados — o sistema responde de forma proporcional a mudanças pequenas, como esperado.

---

## 11. TESTE DE RESPOSTAS "PERFEITAS" — vulnerabilidade?

Não encontrei uma vulnerabilidade clara com o método testado (maximizar evidência de indicador por alternativa): overall=83, pilares entre 61 e 97 — nenhum "padrão óbvio de resposta certa" que zere a variância entre pilares. Ressalva: não testei um adversário que conhece a metodologia e escolhe deliberadamente para parecer "resiliente, colaborativo, proativo" em vez de maximizar evidência numérica — esse teste mais realista de impression management não foi feito nesta rodada.

---

## 12. TESTE DO RELATÓRIO — inconsistências encontradas

A única inconsistência real encontrada foi a do §4.1 (Motivador ignorando `isClose`). Testei também, ao longo das 12 personas, se algum indicador "muito desenvolvido" aparecia junto de uma recomendação que o tratasse como deficiência — não encontrei esse padrão nas execuções realizadas (o código já separa corretamente `strengths`/`attentionPoints` a partir do mesmo `byScoreDesc`, sem sobreposição possível por construção).

---

## 13. TESTE DE PONTA A PONTA — resultado

**Não executado via UI/HTTP real nesta rodada.** Dois motivos:

1. A empresa de teste logada tem só **4 licenças disponíveis** — criar aplicações de teste para simular respostas reais consumiria um recurso pago e escasso sem necessidade, já que o núcleo computacional (situações → motor → relatório) foi testado exaustivamente via o harness (que importa o mesmo `engine.ts`/`report-builder.ts` de produção — a mesma lógica, só sem passar pela camada HTTP/Server Actions/RLS).
2. A parte de multitenancy/RLS já tem um teste empírico documentado no `HANDOFF.md §"Cobertura de testes de segurança"` (2 tenants reais, 6 vetores de IDOR tentados contra a API de produção, todos bloqueados) — e nenhuma policy de RLS foi alterada desde então nesta sessão.

**Se quiser que eu rode o E2E real (criar 1 aplicação de teste, responder via link público, conferir persistência e o relatório final ponta a ponta), preciso de autorização explícita para consumir 1 das 4 licenças restantes.** Posso fazer isso a qualquer momento, só não assumi essa decisão por conta própria.

---

## 14. VEREDITO TÉCNICO

> **B) ESTÁ PRONTO PARA PILOTO CONTROLADO, COM RESSALVAS**

Justificativa: a arquitetura do motor é sólida — determinístico, sem efeito cascata indevido, sem quebra em nenhum dos 12 cenários testados, e o princípio de "nunca afirmar o que não pode afirmar" está corretamente implementado em 3 das 4 dimensões complementares. As ressalvas encontradas são reais e específicas (não genéricas), mas nenhuma delas causa erro, crash, ou dado corrompido — o padrão é "o sistema mostra menos confiança do que se gostaria", não "o sistema mostra confiança errada", **com uma única exceção comprovada: o bug do Motivador (§4.1)**, que é precisamente o tipo de "falsa certeza" que o resto do produto foi desenhado para evitar.

---

## 15. O QUE PRECISA SER FEITO ANTES DO PILOTO

1. **Corrigir o bug do Motivador (§4.1)** — troca de 2 linhas em `report-builder.ts`, baixo risco, alta prioridade: é a única falha que pode apresentar um empate como fato para uma pessoa real.
2. **Decidir o destino do indicador I20** (Construção de Confiança, zero cobertura) — ou recebe vínculo real em pelo menos 3 situações, ou é formalmente descontinuado antes do piloto. Hoje ele só ocupa espaço sem nunca gerar valor.
3. **Comunicar internamente (à própria Victoria e a quem for interpretar os relatórios do piloto) que ~metade dos indicadores e o perfil C do DISC vão aparecer com confiança baixa/moderada com frequência** — não é erro, é o teto atual do instrumento; melhor saber disso antes de um cliente perguntar por que o relatório "parece incompleto".
4. Se quiser rastreabilidade completa antes do piloto: autorizar o teste E2E real (§13) e/ou consolidar `supabase/migrations/` (§1/§4.5).

## 16. O QUE NÃO PRECISA SER ALTERADO

- Motor de cálculo (`engine.ts`) — determinístico, sem sensibilidade excessiva, sem efeito cascata, resistente a inversão, resistente (no teste tentado) a resposta estratégica.
- Estrutura de dados — 40/160/35/7, zero duplicatas, zero órfãos, zero `evidence_strength` inválido nas 5 tabelas de vínculo.
- Lógica de confiança/proximidade em DISC, Tipo e Estilo — corretamente hedgeada em todos os cenários testados.
- Rastreabilidade — toda afirmação do relatório tem origem verificável até a linha do banco; nenhuma "alucinação" possível, já que a camada de tradução é lookup determinístico por código, nunca geração livre.
- Isolamento multitenancy — sem mudança desde o teste documentado no HANDOFF; nenhum motivo para reabrir agora.

---

## Anexos gerados por esta auditoria
- `indicator_coverage.json` — cobertura detalhada dos 35 indicadores (atualizado após as correções do §17)
- `persona_results.json` — resultado completo das 12 personas (versão pré-correção; ver §17 para os números pós-correção)
- Scripts do harness (`structural.ts`, `battery.ts`, `battery2.ts`, `battery3.ts`) — no scratchpad da sessão, não commitados (são ferramenta de teste, não parte do produto)

---

## 17. Correção dos itens 1, 2 e 3 (mesmo dia, a pedido da Victoria)

Todas as mudanças abaixo foram reverificadas rodando o mesmo harness (motor real de produção) contra o novo estado — não são só a alteração aplicada, são o resultado observado depois dela.

### Item 1 — bug do Motivador (§4.1)

Corrigido em `src/lib/motor/report-builder.ts` (2 linhas: `d.motivators.sufficient` → `mot.confident`, nas linhas ~102 e ~134). Reproduzi o mesmo caso de empate de 3 vias (APR 34% / AUT 33% / CNF 33%) depois da correção: `report.dimensions[motivador].confident` agora sai `false`, e o resumo passou a dizer *"pode se mover por aprendizado, ainda com poucas evidências"* em vez de afirmar como fato. `tsc`/`eslint` limpos.

### Item 2 — 18 indicadores sem confiança possível (§4.2)

`supabase/migrations/021_indicadores_fecha_cobertura_fraca.sql` (aplicada em produção): adiciona uma 3ª situação (ou 2ª/3ª no caso de I20, que tinha zero) a 16 dos 18 indicadores, reaproveitando alternativas já existentes que genuinamente evidenciam cada indicador — mesmo teste de especificidade das correções anteriores, sem inventar situação nova.

Resultado reverificado com o harness: **33 dos 35 indicadores agora têm ≥3 situações** (antes eram 17). Só **I06 (Assunção de Erros)** e **I18 (Mediação de Conflitos)** continuam abaixo do piso (2 situações cada) — não encontrei, no conteúdo atual, uma 3ª alternativa que evidenciasse esses dois construtos com especificidade suficiente sem forçar. Ficam documentados como limitação real; resolver exigiria conteúdo novo (fora do escopo desta correção, que não criou nenhuma situação/alternativa nova).

I20 (Construção de Confiança) passou de 0 para 3 situações, todas com força secundária (1) — é o construto "ao longo do tempo", que nenhuma situação isolada evidencia com força; passou de "nunca tem score" para "sempre confiança baixa/moderada", não para cobertura boa. Documentado assim no cabeçalho da migration.

### Item 3 — C nunca sai confiante mesmo na persona mais pura (§4.3)

`supabase/migrations/020_disc_aumenta_teto_c_e_i.sql` (aplicada em produção): 6 vínculos novos, 4 aumentando o teto de C (S2-B, S4-D, S17-B, S24-D) e 2 aumentando o teto de I (S16-C, S20-C) — mesmo critério: só onde a alternativa já existente é genuinamente específica para o código, sem reescrever nada.

Resultado reverificado — a mesma persona C-pura construída na auditoria original:

| | Antes (auditoria original) | Depois (corrigido) |
|---|---|---|
| Persona pura C | C 37% / D 27% (**isClose=true**) | **C 41% / D 27% (isClose=false — confiante)** |

O teste de inversão (D↔S, I↔C) e o de determinismo (10 execuções idênticas) foram refeitos depois de tudo isso — continuam passando limpo.

**Efeito colateral observado, não corrigido:** a persona I-pura, que antes saía confiante (38%/26%, 12pp de gap), agora sai `isClose=true` por uma margem pequena (37%/28%, 9pp — 1pp dentro da margem de proximidade). O teto de I também cresceu (+2 vínculos), mas não o suficiente para compensar o crescimento do teto de C nesse cenário sintético específico de pureza máxima. Não tratei isso agora porque (a) é um cenário extremo — nenhuma pessoa real responde 100% puro a um único código — e (b) já era a dimensão mais escassa mesmo antes desta rodada; perseguir esse caso de borda especificamente arrisca ficar ajustando o mapeamento para o teste sintético em vez de para comportamento real. Fica registrado para acompanhamento, não como algo pendente de correção imediata.

### Migrations desta correção — aplicadas em produção e confirmadas
- `supabase/migrations/020_disc_aumenta_teto_c_e_i.sql` — 67→73 vínculos DISC (D20/I12/S21/C20)
- `supabase/migrations/021_indicadores_fecha_cobertura_fraca.sql` — 192→213 vínculos indicador

Rodadas no SQL Editor do Supabase em 21/09/2026 (021/09), sem erro nas guardas de segurança. Conferido ao vivo no relatório do Allan Pires: Motivador e Tipo continuam confiantes (sem "tendência"), DISC continua "Conforme — tendência" (esperado — ele é um caso genuinamente misto D/C, não resolvido pelo aumento de teto, como já discutido na investigação anterior); score geral e pontos de atenção mudaram (66→60, Aprendizagem e Mudança→Responsabilidade) como consequência natural de mais evidência de indicador entrando no cálculo pela migration 021 — não é regressão, é o sistema recalculando com mais dado real disponível.
