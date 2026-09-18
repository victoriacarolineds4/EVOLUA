# Investigação — Por que o DISC do Allan Pires saiu "Conforme" (C) em vez de "Dominante" (D)

**Data:** 18/09/2026
**Motivação:** Victoria reportou que o resultado do relatório do Allan Pires (CEO) não bate com o perfil real da pessoa por experiência direta. Pediu investigação aprofundada da metodologia, com o objetivo de chegar a ~99% de precisão — sem implementar nada ainda, só diagnosticar e propor.
**Método:** dados reais (respostas do Allan às 40 situações, via SQL fornecido pela Victoria) cruzados localmente com o mapeamento `alternative_disc` de produção e com o mapeamento v2.1 já revisado mas **não aplicado** (`backups/disc_v2/12_disc_rebalanceamento_v2.sql`). Cálculo reproduzido manualmente com a mesma fórmula do motor (`src/lib/motor/engine.ts`) e conferido: bate exatamente com o que o relatório publicado mostra (D 35% / C 37%, "tendência", "próximo de outro perfil").

---

## 1. Resumo executivo

O resultado do Allan **não é um bug de cálculo** — o motor está fazendo exatamente o que foi projetado para fazer, com honestidade estatística (por isso o relatório já vem com "tendência" e "próximo de outro perfil D", em vez de afirmar C com convicção). O problema é que **o instrumento (o mapeamento alternativa→DISC) não tem volume nem balanceamento suficiente de evidência para diferenciar com confiança um C de um D** quando a pessoa mostra bastante dos dois — que é exatamente o caso do Allan: ele deu **muito mais respostas D (10 situações, raw 22) do que C (6 situações, raw 14)**, mas o resultado ainda empata porque o "teto" (máximo possível) de C é bem menor que o de D, então a mesma quantidade de evidência pesa proporcionalmente mais para C.

Testei isso com os dados reais dele contra **duas versões do mapeamento**:

| Mapeamento | D (evidências / share) | C (evidências / share) | Resultado |
|---|---|---|---|
| **Produção hoje** (40 vínculos, só cobre 24/40 situações) | 6 evidências, raw 15/29, **35%** | 3 evidências, raw 6/11, **37%** | C vence por 2pp — "tendência", já reportado |
| **v2.1 pendente** (54 vínculos, cobre 34/40 situações — preparado, não aplicado) | 10 evidências, raw 22/36, **32%** | 6 evidências, raw 14/21, **35%** | C ainda vence por 3pp |

**Mesmo aplicando a correção já revisada e pronta (v2.1), o empate D/C do Allan não se resolve** — na verdade quase não muda. Isso mostra que o problema não é só "faltam alguns vínculos", é estrutural: como o "teto" de C é sempre muito menor que o de D (C=21 vs D=36 mesmo no v2.1), qualquer pessoa com bastante evidência real de D **e também** alguma evidência de C tende a sair com os dois embolados, porque a escala de C satura muito mais rápido.

---

## 2. O que os dados do Allan mostram, situação por situação

Das 40 respostas dele, o padrão comportamental é claramente de iniciativa/decisão/ação direta — típico de D:

- **"Decido sozinho e informo depois"** (S21), **"Decido com confiança"** (S28), **"Decido e aproveito sozinho"** (S36), **"Intervenho na hora"** (S35), **"Vou direto ao ponto"** (S18), **"Vou testando direto"** (S12), **"Já começo a estudar [sem esperar]"** (S38) — sete respostas isoladas, cada uma um sinal de D forte, mas **3 delas (S12, S21, S38) não têm NENHUM vínculo DISC no mapeamento atual nem no v2.1** — o sinal existe na resposta, mas é invisível para o motor porque a alternativa nunca foi marcada.
- Ao mesmo tempo, ele deu respostas como **"Organizo as próximas atividades"** (S1, sem vínculo), **"Faço revisão completa"** (S31, vínculo C), **"Estruturo com metas claras"** (S40, vínculo C) — comportamento organizador que é genuinamente C, não é erro de leitura. **Allan tem os dois traços** (é comum — DISC não é excludente), mas o instrumento não tem munição suficiente pra dizer com segurança qual pesa mais.

---

## 3. Causas raiz identificadas (por ordem de impacto)

### 3.1 — 30% do questionário (as 12 situações mais novas, S29–S40) não tinha NENHUM vínculo DISC/Tipo/Motivador/Estilo em produção até esta investigação
Quando o questionário foi expandido de 28 para 40 situações (`015_expansion_40_situations.sql`, commit `bcc62a5`), só os vínculos de **indicadores** (os 7 pilares/35 indicadores) foram criados para as situações novas. Os vínculos para DISC, Tipo Psicológico, Motivador e Estilo Operacional **nunca foram adicionados** para S29–S40 — nem em produção, nem na proposta v2.1 (que resolve isso, mas só para DISC).
**Efeito prático:** hoje, todo colaborador que responde as 40 situações tem só 24 delas (60%) contribuindo para o perfil DISC — os outros 40% das respostas são descartados silenciosamente para essa camada. Isso vale também para Tipo, Motivador e Estilo — o mesmo buraco existe nas 4 camadas complementares, não só no DISC.

### 3.2 — Os "tetos" (máximo possível) por código DISC são muito desiguais, e isso torna o `share` de códigos com teto pequeno estatisticamente instável
A fórmula atual (commit `0aa86fc`) já corrigiu o viés médio (antes D vencia ~94% das vezes em empates reais só por ter mais situações mapeadas). Mas ela não resolve a **variância** por pessoa: com poucas situações discriminando C (hoje 6 vínculos, teto total 11; no v2.1, 10 vínculos, teto total 21 — sempre bem menor que o de D), **uma pessoa com 3-6 respostas C-como-coincidência já satura boa parte do teto de C**, produzindo um share alto mesmo que, em volume absoluto, ela tenha dado o dobro de respostas D. É exatamente o que aconteceu com o Allan.

### 3.3 — A própria correção v2.1 (pendente) deixa 2 situações que hoje têm vínculo DISC (S15 e S27) **totalmente sem vínculo depois de aplicada**
A v2.1 removeu vínculos fracos de S15 e S27 por não passarem no "teste de especificidade" (correto, tecnicamente), mas não colocou nada no lugar — então essas 2 situações somem do cálculo. Combinado com os 4 "buracos" originais que sobram (S1, S3, S10, S25 nunca tiveram vínculo DISC em nenhuma versão), **o v2.1 ainda deixa 6 das 40 situações (15%) cegas para DISC**: S1, S3, S10, S15, S25, S27.

### 3.4 — DISC/Tipo/Motivador/Estilo foram encaixados num questionário desenhado para outra coisa
As 40 situações foram escritas para avaliar 7 pilares / 35 indicadores de competência (organização, responsabilidade, comunicação etc.) — os vínculos DISC foram adicionados depois, alternativa por alternativa, perguntando "essa resposta específica também sinaliza uma dimensão DISC?". Isso é honesto metodologicamente (não força vínculo onde não existe — ver a própria v2.1 recusando vínculos "genéricos"), mas tem uma consequência inevitável: **não há garantia de volume mínimo nem de balanceamento por código** para nenhuma das 4 camadas. O resultado é uma medida de "competência" (pilares/indicadores) sólida e bem coberta, e uma medida de "perfil comportamental" (DISC etc.) estruturalmente mais pobre em evidência.

### 3.5 — A margem de "próximo" (10pp) é fixa, mas a variância real por par de código não é
`DIMENSION_PROXIMITY_MARGIN = 10` trata D-vs-C e D-vs-S da mesma forma, mas como os tetos são muito diferentes entre pares, a mesma margem de 10pp significa coisas estatisticamente diferentes dependendo de quão grande é o teto de cada código envolvido. Não é a causa principal do caso do Allan, mas contribui para a sensação de "quase qualquer resultado empata".

### 3.6 — Não existe, hoje, nenhuma validação empírica contra perfil conhecido
Toda a "confiança" reportada (baixa/moderada/alta) vem de **contar quantas situações apontam pra um código** — não de comparar o resultado do EVOLUA contra um padrão-ouro (ex.: um DISC validado aplicado nas mesmas pessoas, ou avaliação de um especialista). Isso significa que, hoje, **não há como medir objetivamente a acurácia real do instrumento** — só a consistência interna dele. Para uma meta de "99% de precisão" isso é uma lacuna crítica: sem um conjunto de teste com perfis conhecidos, não dá para provar (nem para a Victoria, nem para um cliente que questionar) que o instrumento acerta X% das vezes.

---

## 4. Recomendações

### Rápidas — sem reescrever conteúdo, alto retorno
1. **Aplicar a migration v2.1** (`backups/disc_v2/12_disc_rebalanceamento_v2.sql`) — já revisada, testada por simulação, e coberta por guarda de segurança (aborta se o banco não estiver no estado esperado). Sozinha não resolve o caso do Allan, mas corrige classificações erradas já identificadas e amplia a cobertura de 24→34 situações.
2. **Cobrir as 6 situações que ficam sem vínculo mesmo após a v2.1** (S1, S3, S10, S15, S25, S27) — decidir, para cada uma, se alguma das 4 alternativas já existentes tem um comportamento DISC específico o bastante (mesmo critério de rigor já usado na v2.1), evitando forçar vínculo onde não há.
3. **Fazer o mesmo levantamento de cobertura para Tipo Psicológico, Motivador e Estilo Operacional** — o mesmo buraco de 30% (S29–S40 sem vínculo) existe nas 3 outras camadas e provavelmente está gerando o mesmo tipo de resultado "tendência"/ambíguo que se vê nas Leituras Complementares do relatório do Allan (Conformidade-tendência, Idealista-tendência, Autonomia-tendência).

### Estruturais — para de fato chegar perto de alta precisão
4. **Igualar (ou aproximar) os tetos por código dentro de cada dimensão.** Hoje C tem menos da metade do teto de D. Uma meta editorial (ex.: "cada código DISC deve ter pelo menos N situações genuinamente discriminantes, com força total comparável") tornaria o `share` normalizado menos ruidoso pessoa a pessoa. Isso exige reescrever/adicionar alternativas com o mesmo rigor já demonstrado na v2.1 (nunca forçar vínculo artificial).
5. **Construir um conjunto de validação (golden set).** Aplicar o questionário em um grupo de pessoas cujo perfil DISC já é conhecido por um instrumento validado (ou por avaliação estruturada de RH/consultoria), e medir a concordância real. Sem isso, "99% de precisão" é uma meta que não há como comprovar nem hoje, nem depois de qualquer ajuste — é o passo que mais falta para transformar isso de "parece fazer sentido" em "medido".
6. **Considerar situações extras adaptativas só quando o resultado sair `isClose`.** Em vez de aumentar o questionário para todo mundo, mostrar 4–8 situações adicionais, específicas para desempatar o par que ficou próximo (ex.: só D-vs-C), apenas para quem cair nesse caso. Mantém o questionário curto para a maioria e resolve exatamente o problema do Allan sem inflar a experiência de quem já teve resultado claro.
7. **Reconsiderar a meta de "99% de precisão" como comunicada.** Mesmo instrumentos comportamentais comerciais validados (DISC, Myers-Briggs etc.) não reportam esse nível de precisão de forma responsável — a confiabilidade teste-reteste de instrumentos DISC publicados geralmente fica na faixa de 80-90%, e isso com décadas de calibração estatística. Não é uma limitação do EVOLUA especificamente; é inerente a medir traço comportamental por autorrelato. Recomendo alinhar a meta interna para algo mensurável e defensável (ex.: "concordância ≥85% com avaliação de referência, com dados para provar") em vez de 99% — e não comunicar 99% de precisão para clientes, por risco de expectativa quebrada e questionamento de credibilidade do produto.

---

## 5. O que NÃO parece ser o problema

- **O cálculo de pilares/indicadores (score geral, 66 no caso do Allan) não é afetado** por nada disso — os indicadores tiveram vínculos criados corretamente para as 40 situações desde a expansão. O problema é isolado à camada categórica (DISC/Tipo/Motivador/Estilo).
- **A normalização por teto próprio (commit `0aa86fc`) foi uma correção correta e necessária** — sem ela, o resultado do Allan provavelmente sairia "D" quase sempre, mas por viés estrutural do instrumento, não por evidência real (o mesmo tipo de erro, só que mascarado). A normalização deixou o sistema honesto o suficiente para EXPOR o problema real (falta de evidência C vs D bem balanceada), que antes ficava escondido atrás do viés a favor de D.
- **O texto do relatório em si está correto e coerente com os dados** — "tendência", "próximo de outro perfil (Dominância)" é exatamente o que os números sustentam. O sistema não está mentindo; está sendo honesto sobre uma limitação real do instrumento.

---

## 6. Próximos passos sugeridos (aguardando decisão da Victoria)

Nenhuma mudança foi feita no código ou no banco nesta investigação. Se quiser seguir, a ordem de menor risco/maior retorno seria:
1. Aplicar v2.1 (item 4.1) — reversível, já com backup automático (`_backup_alternative_disc_20260913`).
2. Decidir sobre as 6 situações órfãs (item 4.2).
3. Repetir esta mesma investigação para Tipo/Motivador/Estilo (item 4.3) antes de decidir.
4. Só depois entrar na parte estrutural (itens 4.4–4.7), que é mais trabalho e decisão de produto, não só de dado.

---

## 7. Atualização — recalibração aplicada (18/09/2026, mesmo dia)

A pedido da Victoria ("recalibrar de forma assertiva todos os indicadores DISC, motivador...
para que a pessoa tenha certeza"), fechei as lacunas de cobertura das 4 dimensões
complementares (DISC, Tipo Psicológico, Motivador, Estilo Operacional), com o mesmo critério
de especificidade da v2.1 — **sem mirar em nenhum resultado esperado para o Allan ou qualquer
outra pessoa**. Os 4 scripts estão prontos em `supabase/migrations/016` a `019` (não aplicados —
precisam rodar no SQL Editor do Supabase; nenhum acesso de escrita ao banco de produção foi
usado nesta investigação).

### O que mudou em cada dimensão

| Dimensão | Antes | Depois | Situações cobertas |
|---|---|---|---|
| DISC | 40 vínculos | 67 vínculos | 24/40 → **40/40** |
| Motivador | 11 vínculos | 24 vínculos | 9/40 → 16/40 |
| Tipo Psicológico | 17 vínculos | 29 vínculos | 14/40 → 26/40 |
| Estilo Operacional | 46 vínculos | 64 vínculos | 28/40 → 37/40 |

Motivador e Tipo ficam abaixo de 40/40 **de propósito** — nem toda situação tem uma escolha
específica o bastante para revelar com honestidade "por que" (Motivador) ou "como pensa" (Tipo)
a pessoa; forçar vínculo onde não há teria repetido o erro que a própria v2.1 corrigiu no DISC
(links "genéricos" que qualquer perfil escolheria).

### O resultado do Allan com o mapeamento recalibrado

| Dimensão | Resultado | Confiança |
|---|---|---|
| DISC | C 35% vs D 29% (6pp) | ainda **próximos** — ambiguidade real, não lacuna |
| **Motivador** | **Autonomia 68%** (4 evidências) | **claro** — nenhum outro motivador chega perto |
| **Tipo Psicológico** | **Idealista 47%** vs Artesão 35% (12pp) | **claro** |
| **Estilo Operacional** | **Planejador 38%** vs Executor 26% (12pp) | **claro** (mesmo resultado que já estava no relatório publicado — confirma que a recalibração não quebrou nada que já estava certo) |

**Achado principal desta segunda rodada:** o DISC do Allan continua genuinamente ambíguo entre
C e D mesmo com cobertura total (40/40) — isso deixou de ser sobre lacuna de dado e passou a
ser, com boa confiança agora, sobre o comportamento real dele nas situações medidas. Mas as
**outras 3 dimensões, uma vez com cobertura decente, convergem para um retrato coerente e nada
genérico**: uma pessoa autônoma (não espera aprovação, decide por conta própria), movida por
propósito/potencial humano mais do que por sistemas/eficiência pura, e que planeja e estrutura
antes de agir. Isso é compatível com um perfil de liderança "C organizado e decidido" — não
contradiz a percepção da Victoria sobre ele ser alguém "no comando"; só não confirma
especificamente que o estilo dele seja D no sentido estrito do DISC (impositivo/direto). O
sistema está sendo consistente, não estava quebrado nas outras 3 camadas.

### Notas estruturais que ficam registradas para decisão futura da Victoria

- **Motivador (REC, FIN, DEV, OUT continuam sem nenhum vínculo).** Não é uma lacuna que dê pra
  fechar com mais rigor no formato atual — nenhuma das 40 situações pede uma escolha entre
  *formas* de recompensa, que é o que esses 4 motivadores medem. Recomendação: se a Victoria
  quiser que esses 4 apareçam de fato nos relatórios, provavelmente precisa de um tipo de
  pergunta diferente (preferência explícita entre recompensas), não mais situações de reação.
- **Tipo Psicológico — GUA (Guardião) ainda concentra 17 dos 29 vínculos** (os 12 vínculos que
  eu adicionei foram só para IDE/EST/ART, deliberadamente, pra não piorar o desbalanceamento).
  Os vínculos GUA existentes não foram reauditados nesta rodada — seria o próximo candidato a
  uma revisão como a v2.1 fez para o DISC, se a Victoria quiser priorizar isso depois.
- **Confirmação de coerência:** o resultado de Estilo Operacional do Allan (Planejador) não
  mudou com a recalibração — bate com o que já estava no relatório publicado antes de qualquer
  mudança. Isso é um sinal de que a expansão de cobertura não introduziu ruído onde já havia
  sinal suficiente; só preencheu onde não havia nada.

### Arquivos desta rodada
- `supabase/migrations/016_disc_rebalanceamento_v2_e_cobertura.sql`
- `supabase/migrations/017_motivador_cobertura.sql`
- `supabase/migrations/018_tipo_psicologico_cobertura.sql`
- `supabase/migrations/019_estilo_operacional_cobertura_s29_40.sql`

Cada um tem guarda de segurança (aborta se o estado atual do banco não bater com o esperado) e
cria uma tabela de backup automática antes de qualquer alteração. Precisam ser executados em
sequência (016→017→018→019) no SQL Editor do Supabase — nenhum foi aplicado ainda.
