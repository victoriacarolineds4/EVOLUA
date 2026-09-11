# EVOLUA — Documento de Handoff Técnico
> Estado do sistema para continuidade do desenvolvimento. Escrito para um dev sênior assumir sem contexto prévio.
> Data-base: **11/09/2026 — pós Auditoria de Prontidão v2.0 + correções P1/P2** (Consolidação Metodológica v2 + auditoria de segurança/estado/motor/relatório + as 2 correções que ela levantou, ambas aplicadas e verificadas em produção). Ver §5/§6 para a metodologia, §14 para o veredito de prontidão.

---

## 1. O que é o EVOLUA

Plataforma SaaS de **diagnóstico e desenvolvimento humano** (Neon Conecta). Não é um teste de personalidade nem DISC/MBTI: é uma **metodologia própria** que transforma o comportamento observado (via situações reais de trabalho) em **ações práticas de gestão**.

**Diferencial central:** o relatório não *descreve* o colaborador — ele *diz ao gestor o que fazer*, em linguagem simples, sem exigir estudo. Regra de ouro: **nenhum traço aparece sozinho; sempre vem colado com "então faça isto"**.

**Dois usuários:**
- **Gestor** — cadastra-se, cria "aplicações" (campanhas), envia o link, vê os relatórios.
- **Colaborador** — recebe o link, informa nome/cargo, responde 28 situações, gera seu Mapa de Desenvolvimento.

**Monetização:** venda única por pacotes de licenças (5/10/20/50). Licença é reservada **na criação da aplicação** (não por resposta individual — ver §9).

---

## 2. Stack

- **Next.js 15.5** (App Router, Server Components, Server Actions) · **React 19.1** · **TypeScript**
- **TailwindCSS** + **Shadcn UI portado para Base UI** (`@base-ui/react` — NÃO Radix) · `tw-animate-css`
- **Supabase** (`@supabase/ssr` + `@supabase/supabase-js`) — Postgres + Auth + RLS
- **React Hook Form** + **Zod v4** · **React Query** (`@tanstack/react-query`) · **Recharts** (radar) · **Framer Motion** · **Lucide React** · **Sonner** (toasts) · **next-themes**
- Deploy alvo: **Vercel**

**Design:** tema escuro, verde neon `#4ade80` / `oklch(0.85 0.24 152)`, minimalista (inspiração Stripe/Linear/Notion).

---

## 3. Arquitetura e estrutura

```
src/
  app/
    (auth)/        → login, cadastro, recuperar-senha   [layout próprio]
    (dashboard)/   → dashboard, aplicacoes, relatorio, meu-plano, configuracoes [layout com auth guard]
    e/[token]/     → jornada pública do colaborador (entrada + questionário)
    layout.tsx     → root (providers, tema, fontes)
  components/      → ui/ (shadcn/base-ui), layout/ (AppShell, Sidebar, Topbar, UserMenu, Container, Section)
  features/        → aplicacoes/, auth/, colaborador/, relatorio/  (components + actions por feature)
  services/        → profile, company, applications, public-application, questionnaire, dashboard, motor/
  lib/             → supabase/ (browser+server+middleware clients), motor/ (o cérebro), utils
  types/           → database.types.ts (tipos do banco)
  middleware.ts    → proteção de rotas
supabase/
  migrations/      → 001..013 (schema)
  seeds/           → 002_official_methodology, 004_motor_dimensions, 005_official_mapping (novo)
  EVOLUA_FULL_SETUP.sql → consolidação de TUDO (migrations 001–013 + os 3 seeds), na ordem certa,
                          p/ provisionar um projeto Supabase novo do zero colando 1 arquivo no SQL Editor
```

**Princípios:** Server Components por padrão; Client Components só p/ interatividade; lógica de domínio pura em `src/lib`, IO em `src/services`.

> **`src/lib/mocks/` foi removido** (Sprint de Melhorias, item 5) — toda a plataforma roda 100% com dados reais. Não recriar mocks; se precisar de um ambiente de demonstração comercial, discutir arquitetura antes (não existe mais `/e/demo`).

---

## 4. Banco de dados (Supabase/Postgres)

Migrations `001`→`013`. Rodar tudo de uma vez: colar `supabase/EVOLUA_FULL_SETUP.sql` no **SQL Editor** (não precisa de connection string; usa só o painel — nunca psql/conexão direta neste projeto).

### Tabelas
| Tabela | Papel |
|---|---|
| `companies` | empresa (name, plan `starter`, licenses_total=10, licenses_used) |
| `profiles` | 1:1 com `auth.users` (company_id, full_name, role `gestor`/`colaborador`) |
| `applications` | campanha do gestor (name, **token** único, status draft/active/closed, license_limit, responses_count) |
| `responses` | jornada de um colaborador (application_id, name, role, status started/completed, progress, current_question, completed_at) |
| `questions` | 28 situações (order_index, title, pillar_number) |
| `alternatives` | 112 alternativas (question_id, letter A–D, title, description) |
| `answers` | resposta escolhida (response_id, question_id, alternative_id) — UNIQUE(response_id, question_id) |
| `pillars` | 7 pilares (number, name) |
| `indicators` | 35 indicadores (code I01–I35, name, pillar_number) |
| `disc_profiles` · `psychological_types` · `motivators` · `operational_styles` | 4 dimensões complementares (tabelas de referência) |
| `alternative_indicators` | vínculo alternativa→indicador + `evidence_strength` (0–3) |
| `alternative_disc` · `alternative_psychological_types` · `alternative_motivators` · `alternative_operational_styles` | vínculos alternativa→dimensão + `evidence_strength` |

### RLS — reescrito na Sprint de Melhorias (migrations 011, 012, 013)

**⚠️ Histórico importante (não repetir o erro):** as migrations 003/005 originais deixavam `responses` e `applications` com SELECT/UPDATE `using(true)` para o papel `anon` — ou seja, **qualquer requisição usando a chave pública `anon`** podia fazer dump de **todos os colaboradores e tokens de aplicação de todas as empresas**, e até alterar/inserir livremente. Isso foi auditado e fechado. O modelo atual:

- `companies`/`profiles`: SELECT/UPDATE próprios (via `auth.uid()`). Sem policy de INSERT — criação só via trigger.
- `questions`/`alternatives`/`pillars`/`indicators`/dimensões (`disc_profiles` etc.): **SELECT público** — correto, é metodologia global, não dado de cliente.
- `alternative_*` (o mapeamento): **SELECT authenticated** — qualquer gestor logado lê (necessário pro Motor calcular via client autenticado).
- `applications`/`responses`: **`anon` NÃO tem mais SELECT nem UPDATE direto.** Toda leitura/escrita anônima passa por **funções `SECURITY DEFINER`** (abaixo). `authenticated` mantém SELECT/UPDATE escopados por empresa (via `profiles.company_id`), como sempre.
- `responses_insert_public` / `answers_insert_anon` (INSERT `anon`): já não são `with check(true)` — o `WITH CHECK` agora chama uma função `SECURITY DEFINER` que valida a regra de negócio (aplicação ativa e com licença; resposta em andamento e alternativa pertence à questão) **dentro do banco**, não só no app.

**Funções RPC do colaborador anônimo** (todas `SECURITY DEFINER`, `grant execute to anon, authenticated`):
| Função | Uso |
|---|---|
| `get_application_by_token(p_token text)` | Lê 1 aplicação pelo token (nunca lista todas) |
| `get_application_by_id(p_id uuid)` | Idem, por id |
| `get_response_by_id(p_id uuid)` | Lê 1 resposta pelo id (o segredo do cookie `evolua_rid`) |
| `update_response_progress(p_id, p_progress, p_current_question, p_status?, p_completed_at?)` | Atualiza só a própria resposta. **Migration 014 (11/09/2026):** agora valida estado — rejeita qualquer update numa resposta já `completed` (imutável), valida `progress`/`current_question` contra o total real de questões, e só permite a transição para `completed` se todas as respostas existirem em `answers`. Antes disso a função aceitava forjar `completed` sem nenhuma resposta, `progress` negativo e reverter `completed→started` — achado e corrigido na Auditoria de Prontidão v2.0 (ver §14). |
| `create_response(p_application_id, p_name, p_role)` | Cria a resposta, validando aplicação ativa/com licença por dentro |
| `save_answer(p_response_id, p_question_id, p_alternative_id)` | Salva 1 resposta, validando resposta em andamento + alternativa pertence à questão; idempotente (`ON CONFLICT DO NOTHING`) |
| `application_accepts_responses(p_application_id)` / `answer_is_valid_for_insert(...)` | Helpers usados dentro do `WITH CHECK` das policies de INSERT |

**⚠️ Gotcha de RLS descoberto (documentar bem, é sutil):** ao remover o SELECT `using(true)` de `anon` em `applications`/`responses`, os **INSERTs diretos passaram a falhar com `42501`** — porque a validação de **foreign key** do Postgres (`responses.application_id → applications.id`, `answers.response_id → responses.id`) exige que quem insere "enxergue" a linha referenciada sob RLS. A correção não é reabrir SELECT — é mover o **INSERT em si** para dentro de uma função `SECURITY DEFINER` (que roda com privilégio do dono, bypassando RLS internamente). Ver migrations 012/013 para o texto completo do porquê.

**⚠️ Outro gotcha (mais sutil ainda):** `Prefer: return=representation` num INSERT que a policy realmente bloqueou retorna HTTP 401/erro — mas se você **não** pedir `return=representation`, um INSERT que passe no `WITH CHECK` mas falhe na releitura pode dar a falsa impressão de estar bloqueado quando na verdade persistiu. **Sempre confirme mudanças de RLS consultando a tabela via `service_role`, nunca só pelo código HTTP da tentativa.**

### Trigger crítico — `handle_new_user` (migration 010)
No signup (`auth.users` INSERT), como `SECURITY DEFINER`: cria a **empresa** (nome vem de `raw_user_meta_data.company_name`) e o **profile** já vinculado como `gestor`.

### IDs fixos da metodologia (determinísticos)
- Pilares: `10000000-…-00000000000N` (1–7)
- Indicadores: `20000000-…-0000000000NN` (I01–I35)
- Questões: `30000000-…-0000000000NN` (situação 01–28)
- Alternativas: `40000000-0000-0000-QQQQ-00000000000L` (QQQQ=situação 0001–0028, L=1..4 = A..D)
- DISC=`50000000-…`, Tipo=`60000000-…`, Motivador=`70000000-…`, Estilo=`80000000-…`

⚠️ **Esses IDs NÃO são UUIDs RFC válidos** (dígito de versão 0). O Postgres aceita, mas `z.string().uuid()` do **Zod v4 REJEITA**. Ver Gotchas (§10).

---

## 5. A Metodologia EVOLUA (taxonomia oficial — confirmada e reconstruída)

> **Histórico da decisão (não reabrir sem novo motivo):** em 08/09/2026 descobriu-se que a taxonomia então implementada ("Autogestão...Desenvolvimento Contínuo") **não era oficial** — o documento fundacional trazido pela Victoria definia outros 7 pilares. A Victoria confirmou explicitamente que o documento fundacional **prevalece** sobre a decisão técnica anterior (que só validara "Autogestão..." por já estar no código, sem acesso ao documento). Entre 08/09 e 10/09/2026 a taxonomia abaixo, os 35 indicadores e os 112 vínculos alternativa→indicador foram **reconstruídos do zero** e aplicados em produção (scripts em `backups/metodologia_reconstruida/`). Em 10–11/09/2026 uma auditoria comportamental completa (`ANALISE_PROFUNDA_SINAL_COMPORTAMENTAL.md`) reavaliou os 166 vínculos gerados nessa reconstrução e uma segunda rodada de correções (`EVOLUA_METODOLOGIA_V2.md`, script `backups/metodologia_v2/12_correcao_mapeamento_v2.sql`) foi aplicada e **confirmada ao vivo em produção** (140 vínculos). O estado abaixo é o final, real, em produção.

**7 Pilares · 5 indicadores cada = 35 indicadores · 28 situações · 4 alternativas cada = 112 alternativas.**

| # | Pilar | Indicadores |
|---|---|---|
| 1 | Organização e Rotina | I01 Gestão do Tempo · I02 Priorização · I03 Planejamento · I04 Consistência na Rotina · I05 Fechamento de Ciclos |
| 2 | Responsabilidade | I06 Assunção de Erros · I07 Proatividade diante de Falhas · I08 Transparência sobre Atrasos · I09 Aceitação de Responsabilidade · I10 Cuidado com Impacto no Outro |
| 3 | Aprendizagem e Mudança | I11 Abertura a Mudança · I12 Disposição para o Novo · I13 Receptividade a Feedback · I14 Autodesenvolvimento · I15 Flexibilidade Cognitiva |
| 4 | Relacionamentos | I16 Disposição para Ajudar · I17 Acolhimento · I18 Mediação de Conflitos · I19 Tolerância à Diferença · I20 Construção de Confiança |
| 5 | Comunicação | I21 Iniciativa de Comunicação · I22 Transparência com Liderança · I23 Pedido de Ajuda · I24 Clareza na Orientação · I25 Adaptação da Mensagem |
| 6 | Pressão e Decisão | I26 Autonomia sob Pressão · I27 Gestão de Múltiplas Demandas · I28 Lida com Insatisfação · I29 Decisão com Informação Limitada · I30 Estabilidade sob Pressão |
| 7 | Crescimento e Ética | I31 Busca por Crescimento · I32 Disposição para Ensinar · I33 Integridade · I34 Uso da Autonomia · I35 Compromisso com Evolução |

**Classificação de cobertura dos 35 indicadores** (após a correção v2, ver `EVOLUA_METODOLOGIA_V2.md` §6 para a lista completa por indicador):
- **Grupo A — bem mensurado** (≥3 situações distintas genuínas): 14 indicadores (40%) — I02, I03, I07, I09, I12, I14, I16, I21, I23, I24, I25, I27, I30, I33.
- **Grupo B — parcial, aproveitável** (2 situações): 7 indicadores (20%).
- **Grupo C — cobertura insuficiente, não estrutural** (0-1 situação; corrigível em tese com novas situações, fora do escopo desta consolidação): 12 indicadores (34%), incluindo **I04 Consistência na Rotina** (0 situações genuínas).
- **Grupo D — estruturalmente difícil** (a própria definição exige observação longitudinal, não uma escolha pontual): **I20 Construção de Confiança** e **I35 Compromisso com Evolução**. Recomendação registrada (não implementada): tratar como "acompanhamento requerido" no relatório em vez de score numérico.

⚠️ **Este documento (`REALINHAMENTO_METODOLOGIA_OFICIAL.md`) e outros dois na raiz (`INDICADORES_E_MAPEAMENTO_NOVO.md`, `REMAPEAMENTO_INDICADORES_VIAVEIS.md`) são material de trabalho da reconstrução de 08–10/09/2026** — úteis como histórico de como se chegou até aqui, mas **`EVOLUA_METODOLOGIA_V2.md` é a versão final e vigente**; em caso de conflito, ele prevalece.

**Dimensões complementares** (extraídas das MESMAS respostas, não são novo questionário):
- **DISC** (como age): Dominância, Influência, Estabilidade, Conformidade
- **Tipo Psicológico** (como pensa): Estrategista, Idealista, Guardião, Artesão
- **Motivadores** (o que move): Reconhecimento, Crescimento, Propósito, Recompensa Financeira, Autonomia, Aprendizado, Segurança, Desafios
- **Estilo Operacional** (como trabalha): Executor, Planejador, Analítico, Colaborativo

**Escala de 4 níveis:** Precisa de atenção · Está evoluindo · Bem desenvolvido · Muito desenvolvido.

**Fluxo lógico:** Situações → Evidências → Indicadores → Pilares → Relatório → Plano de ação.

---

## 6. O Motor de Interpretação (o cérebro)

Determinístico, **sem IA** (a IA, se usada, só montaria texto — nunca interpreta). Dividido em puro (`src/lib/motor`) e IO (`src/services/motor`).

### Arquivos
- **`lib/motor/types.ts`** — contratos (`MotorInput`, `RawDiagnosis`, `PillarScore`, `IndicatorScore`, `DimensionResult`, `Level`).
- **`lib/motor/scoring.ts`** — **política de pontuação ajustável**: `MIN_EVIDENCE_SITUATIONS=3` (piso de evidência), cortes dos 4 níveis. Ponto único p/ calibrar a metodologia.
- **`lib/motor/engine.ts`** — `computeDiagnosis(MotorInput): RawDiagnosis`, função pura.
- **`lib/motor/translation.ts`** — **camada de tradução (RASCUNHO)**: dicionários atributo→ação de gestão, em **linguagem neutra de gênero** (ver §7 sobre a estimativa de personalizar por gênero).
- **`lib/motor/report-builder.ts`** — `buildReport(diagnosis, colaborador): GeneratedReport` — monta o relatório "ação primeiro".
- **`services/motor/motor.service.ts`** — loader (Supabase→Motor): `loadMotorMethodology`, `computeDiagnosisForResponse`, `getReportForResponse`, `getCompletedReportsForCompany`. Tipado com `SupabaseClient` real (sem `any` — passa no lint estrito do `next build`).

### Modelo de pontuação (v2 — score separado de confiança)
- **Indicador (0–100)** = evidência mostrada ÷ evidência máxima possível × 100 — fórmula **não mudou** na v2. O que mudou é que cada indicador agora também carrega `confidence: "insuficiente"|"baixa"|"moderada"|"alta"`, derivado de `evidenceCount` (nº de situações **distintas** que geraram evidência — não nº de alternativas vinculadas):
  - `evidenceCount=0` → **insuficiente** → `hasScore=false`, o indicador não deve ser exibido como número (relatório mostra "dados insuficientes").
  - `1` → baixa · `2` → moderada · `≥3` (piso `MIN_EVIDENCE_SITUATIONS`) → alta.
- **Pilar** = média **só dos indicadores com `hasScore=true`** (os sem evidência nenhuma são excluídos do cálculo, não zerados — essa é a mudança de fórmula da v2, motivada por um caso real: um pilar cuja média "ingênua" incluindo indicadores sem dado dava 18, e recalculada só com quem tinha evidência real dava 45, mesmo score bruto). Pilar carrega `confidence` (a mais fraca entre os indicadores considerados) e `indicatorsWithScore` (quantos dos 5 entraram na conta). Se nenhum dos 5 tiver evidência, o pilar mostra "dados insuficientes".
- **Geral (`overall`)** = média só dos pilares com `hasScore=true`. **Correção de bug nesta v2:** `overallLevel` usava `pillars[0].level` (nível do primeiro pilar da lista, não do score geral) — agora usa `scoreToLevel(overall)` corretamente.
- **Dimensões** (DISC/Tipo/Motivadores/Estilo) = ranking por evidência + participação %; predominante só é afirmado com ≥3 situações (senão "tendência"). Não tocadas pela v2.
- **⚠️ Por que `evidenceCount` já é "nº de situações" e não "nº de alternativas":** cada situação só permite escolher 1 de 4 alternativas — então um indicador cujos vínculos genuínos estão todos dentro de UMA situação nunca ultrapassa `evidenceCount=1`, mesmo que essa situação tenha 4 alternativas linkadas a ele. Isso é intencional e foi a causa raiz de boa parte da baixa cobertura encontrada na auditoria (ver §5).

Arquivos alterados nesta v2: `lib/motor/types.ts` (tipo `Confidence`, campos novos em `IndicatorScore`/`PillarScore`), `lib/motor/scoring.ts` (`evidenceCountToConfidence`, `weakestConfidence`), `lib/motor/engine.ts` (cálculo), `lib/motor/report-builder.ts` (`strengths`/`attentionPoints` carregam `confidence`; bug fix do `overallLevel`), `features/relatorio/components/pillar-card.tsx` e `motor-report.tsx` (UI mostra "dados insuficientes" / ressalvas de confiança). Commit `2079560`, deployado e **verificado com relatório real via UI** (ver §5-histórico e `EVOLUA_METODOLOGIA_V2.md`).

**Correção adicional (11/09/2026, commit `69c2f47`, achado na Auditoria de Prontidão v2.0 — ver §14):** o resumo do topo do relatório (`profile.summary`) e o badge de perfil (`profile.label`) usavam DISC/Tipo/Motivador/Estilo como fato assertivo mesmo quando a mesma dimensão aparecia como "tendência" (baixa confiança) mais abaixo, na seção Leituras Complementares — inconsistência real dentro da mesma tela. Agora `buildReport` monta o resumo **clausula por clausula**, cada uma checando o `confident`/`sufficient` da sua própria dimensão (`disc.confident`, `tipo.confident`, `d.motivators.sufficient`, `est.confident`) e trocando verbos assertivos ("tem", "pensa", "se move por") por hedged ("aparenta ter", "tende a pensar", "pode se mover por... ainda com poucas evidências") quando a confiança é baixa — mesmo padrão já usado em "Pontos de Atenção". `profile.labelConfident` (= `disc.confident`) controla um selo "tendência" no badge, igual ao das Leituras Complementares. **Verificado com relatório real via UI**: um perfil com DISC/Tipo confiantes mas Motivador não-confiante gerou o resumo corretamente misto — só a cláusula do motivador ficou hedged.

### Estrutura do relatório "ação primeiro" (`GeneratedReport`)
Perfil → Essencial em 30s → Como agir (6 blocos) → Pilares (com confiança) + Radar → Padrões mais claros (só indicadores `confidence="alta"`) → Leituras Complementares → Pontos Fortes/Atenção (com ressalva de confiança) → Plano 30/60/90.

### O mapeamento das 112 alternativas — reconstruído + corrigido, versionado
- **Estado em produção:** tabela `alternative_indicators` com **140 vínculos**, confirmados ao vivo (não só por arquivo) em 11/09/2026.
- **Histórico:** seed antigo "941 vínculos" (`005_official_mapping.sql`) e taxonomia antiga — **obsoletos, não usar**. Reconstrução de 08–10/09/2026 (`backups/metodologia_reconstruida/`) aplicou a taxonomia oficial com 166 vínculos iniciais. Auditoria comportamental de 10–11/09/2026 (`ANALISE_PROFUNDA_SINAL_COMPORTAMENTAL.md`) reavaliou cada um dos 166 pedindo "que comportamento específico justifica este vínculo?" — resultado: 30 remoções, 11 reclassificações, 2 upgrades de força, 4 adições → 140 vínculos finais (`backups/metodologia_v2/12_correcao_mapeamento_v2.sql`, já aplicado).
- **Não é mais rascunho gerado só por proximidade temática** — cada vínculo remanescente tem uma justificativa comportamental defensável registrada na auditoria. Ainda não é instrumento validado psicometricamente (isso exigiria dados reais de uso ao longo do tempo).
- **Cobertura real (não nominal):** só 14 de 35 indicadores (40%, Grupo A) têm evidência genuína em ≥3 situações distintas — ver classificação completa em §5. Os outros 21 têm cobertura parcial ou insuficiente; isso é **esperado e documentado**, não um bug — o motor agora comunica essa diferença via `confidence` em vez de disfarçar como score baixo.
- As 4 camadas complementares (DISC/Tipo/Motivador/Estilo — tabelas `alternative_disc` etc., 166 vínculos: 40+17+11+46) **não foram tocadas** pela correção v2 (só `alternative_indicators` mudou) e continuam validadas pelo teste de 3 personas reais anterior a esta consolidação.

---

## 7. Fluxos

### Gestor
1. `/cadastro` → `signUpAction` → `friendlyAuthError()` traduz qualquer erro do Supabase Auth pra PT-BR (nunca mostra texto técnico/código de erro cru) → trigger cria empresa + profile gestor.
2. `/login` → `loginAction` → dashboard.
3. `/dashboard` — stats reais: card "Colaboradores" mostra **licenças reservadas** (`licenses_used`, a métrica de consumo — ver §9), com "N pessoas responderam" como subtítulo informativo (métrica de resposta real, diferente por design).
4. `/aplicacoes` — cria aplicação (`createApplicationAction`, reserva `license_limit` na hora). Encerrar via `close-application-dialog` → `closeApplicationAction` (**não devolve licença ao saldo** — decisão de produto confirmada, comentada no código).
5. `/relatorio` — lista respostas concluídas da empresa → `/relatorio/[responseId]` renderiza o Mapa (computado ao vivo pelo Motor).

### Colaborador (público, sem auth — todas as leituras/escritas via RPC, ver §4)
1. `/e/[token]` → `EntryFlow` (WelcomeCard → ParticipantForm nome/cargo).
2. `ParticipantForm` → `createResponseAction` → RPC `create_response` → cookie httpOnly `evolua_rid` → redireciona a `/e/[token]/questionario`.
3. `/e/[token]/questionario` — 1 situação por vez; `saveAnswerAction` → RPC `save_answer` + RPC `update_response_progress`; na 1ª resposta consome licença via `increment_application_responses_count`; na última → status `completed`.
4. Fim → `CompletionScreen`.

**Restrições de segurança do colaborador (mantidas e testadas):** sem localStorage/sessionStorage; sem ID na URL (cookie httpOnly); nunca exibir erro técnico/404/JSON (telas amigáveis — testado inclusive para aplicação encerrada e link inválido).

---

## 8. Rotas
**Auth:** `/login` · `/cadastro` · `/recuperar-senha`
**Gestor (protegidas):** `/dashboard` · `/aplicacoes` · `/aplicacoes/[id]` · `/relatorio` · `/relatorio/[responseId]` · `/meu-plano` · `/configuracoes`
**Colaborador (pública):** `/e/[token]` · `/e/[token]/questionario`
Proteção em `src/middleware.ts` (`PROTECTED_PREFIXES` / `AUTH_PREFIXES`).

---

## 9. Decisões de produto confirmadas nesta sprint

1. **Licenças — Opção A (reserva por aplicação):** criar aplicação reserva `license_limit` integralmente (`companies.licenses_used += limit`). Ao **encerrar** uma aplicação com respostas incompletas, a sobra **não volta ao saldo** — deliberado, comentado em `closeApplicationAction`. O card "Colaboradores" do Dashboard reflete essa métrica de consumo (não a contagem de respostas).
2. **Gênero no relatório — segue neutro.** Estimativa de personalizar por gênero do colaborador: schema simples (~1-2h), mas o texto (`translation.ts`) tem 20 blocos de prosa que precisariam virar pares m/f ou ser reformulados — **~4-6h de redação**. Recomendação: manter neutro até haver sinal real de necessidade (reversível a qualquer momento).
3. **Confirmação de e-mail do Supabase:** causa raiz de falhas de cadastro identificada como **rate-limit do provedor de e-mail padrão do Supabase** (compartilhado entre todo o projeto, poucos e-mails/hora sem SMTP customizado) — não é restrição por domínio. Correção definitiva fora do código: configurar SMTP próprio (Project Settings → Authentication → SMTP) ou desativar "Confirm email".

---

## 10. ⚠️ GOTCHAS (armadilhas que já custaram bugs — não repetir)

1. **Shadcn sobre Base UI (não Radix):**
   - `DropdownMenuLabel` NÃO pode usar `Menu.GroupLabel` (exige `<Menu.Group>` pai → quebra a página). Usar `<div>` estilizado.
   - Itens de menu disparam **`onClick`**, não `onSelect`.
   - Sem `asChild`; `onOpenChange` difere do Radix.
2. **Zod v4 `.uuid()` × IDs da metodologia:** nunca usar `.uuid()` — usar regex leniente `^[0-9a-f]{8}-[0-9a-f]{4}-...$/i`.
3. **Plural PT:** nunca usar o padrão `${n!==1?'is':''}` colado em "disponível"/"aplicação" — gera "disponívelis". Usar `${n===1?'disponível':'disponíveis'}`.
4. **Automação de preview/browser:** cliques sintéticos podem não cair na delegação de eventos do React 19 nem no `onChange` do RHF — artefato do ambiente de teste, não bug do produto. Setar `.value` via native setter + `dispatchEvent('input'/'change')`, e para cliques usar eventos de ponteiro completos (`pointerdown`/`mousedown`/`pointerup`/`mouseup`/`click`) ou acionar o handler via fiber (`el[reactPropsKey].onClick(...)`).
5. **RLS + FK + SECURITY DEFINER:** ao restringir SELECT de um papel numa tabela, checar se algum INSERT em OUTRA tabela referencia essa como FK — a validação de FK do Postgres exige visibilidade RLS na tabela referenciada pelo papel que insere. Ver §4.
6. **`Prefer: return=representation` mascarando bloqueios de RLS:** um INSERT que falhe só na releitura pós-insert pode reportar erro ao cliente mesmo tendo persistido. Sempre confirmar via `service_role` após qualquer mudança de RLS, nunca só pelo HTTP status da tentativa.
7. **`.rpc()` sem generic `Database`:** o client Supabase sem tipo `Database` explícito infere `.rpc(...)` como `{}`, não `any` — precisa de cast explícito (`as {...}`) pros campos, diferente de `.from(...)` que infere `any`.
8. **Recharts/radar:** client component via wrapper `dynamic(..., { ssr: false })` (nunca `ssr:false` direto em Server Component no Next 15). Ver `radar-chart-wrapper.tsx`.
9. **`npm run build` com dev server ativo simultaneamente:** os dois escrevem no mesmo `.next/` e corrompem o cache (`Cannot find module './XXX.js'`). Rodar build de produção com o dev server **parado**, ou limpar `.next/` e reiniciar se acontecer.
10. **Verificar telas de gestor (`/relatorio/[id]` etc.) sem senha:** a Victoria não compartilha senha em campo de UI. Técnica usada nesta sessão: criar conta descartável via API (`POST /auth/v1/signup` com `data:{full_name, company_name}` — o trigger `handle_new_user` já cria empresa+profile), pegar o `access_token` retornado (não precisa de confirmação de e-mail se "Confirm email" estiver off) e montar o cookie `sb-<project-ref>-auth-token` = `"base64-" + base64(JSON.stringify({access_token, token_type, expires_in, expires_at, refresh_token, user}))`, setado via `document.cookie` no browser. Funciona para navegar autenticado sem nunca digitar senha em campo algum. Sempre limpar os dados de teste + apagar o usuário em Authentication → Users depois.
11. **Editar `lib/motor/*` sem commitar+pushar antes de testar em produção:** já aconteceu duas vezes nesta sessão — implementar mudança local, testar via UI real, e o resultado bater com a fórmula ANTIGA porque o deploy nunca recebeu o código novo. Sempre `git status` antes de testar algo "ao vivo"; se há mudança em `src/` não commitada, commitar+pushar e aguardar o deploy (~50-60s) antes de confiar no que a UI mostra.

---

## 11. Ambiente, credenciais e segurança

- **`.env.local`** (git-ignored): `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `NEXT_PUBLIC_APP_URL`. `SUPABASE_SERVICE_ROLE_KEY` **nunca** aparece no código do app — usada só em scripts locais pontuais de setup/teste.
- Projeto Supabase atual: ref `rxtxsmvnjeasmawktonf`.
- ⚪ **Rotação de chaves — DECISÃO TOMADA (2026-08): NÃO rotacionar por enquanto.** As chaves `anon`/`service_role` foram compartilhadas em chat durante o desenvolvimento, mas a Victoria decidiu manter como está enquanto for só ela trabalhando no projeto (sem produção/usuários reais ainda). **Não reabrir esse assunto por conta própria** — só revisitar se: (a) alguma chave vazar de fato fora deste contexto controlado, ou (b) o projeto for pra produção com usuários reais. Se/quando for retomado: o projeto já migrou o "JWT Signing Keys" (ECC P-256) mas as chaves legadas `anon`/`service_role` (HS256) dependem do "Legacy JWT Secret", que só se troca revogando via aba JWT Keys — ação que derruba as duas chaves na hora sem gerar substitutas automáticas. O caminho recomendado pela própria Supabase nesse caso é migrar para o novo sistema "Publishable and secret API keys" (rotação independente, sem esse efeito colateral) em vez de forçar a revogação do secret legado — isso é uma migração de código (trocar as env vars e possivelmente o nome delas), não um simples reset, e merece ser tratada como tarefa própria.
- Rodar dev: `npm run dev` (porta 3000). Provisionar banco novo do zero: colar **só** `supabase/EVOLUA_FULL_SETUP.sql` no SQL Editor — já inclui migrations 001–013 + os 3 seeds na ordem certa, nada mais precisa ser rodado separadamente.

---

## 12. Pendências reais restantes

> **Atualização (2026-08 — Sprint "Telas Pendentes"):** `/meu-plano`, `/configuracoes` e `/aplicacoes/[id]` eram placeholders "Em breve" **acessíveis pela UI de verdade** (link direto na Sidebar ou botão "Abrir" em cada card de aplicação) — implementadas com dado real, sem billing/upgrade fake, sem campo inventado. `/aplicacoes/nova` era rota morta (sem nenhum link apontando pra ela — a criação real é via modal em `/aplicacoes`) e foi removida. Nenhuma dessas 4 estava listada abaixo porque não fazia parte das 9 itens originais — era lacuna descoberta depois, numa auditoria à parte.

### Resolvidas na Auditoria de Prontidão v2.0 (11/09/2026 — ver §14)

- ~~Rodar `qa_cleanup_teste_mapeamento_v2.sql`~~ — confirmado executado pela Victoria.
- ~~Apagar usuário `gestor.teste.mapeamentov2...`~~ — confirmado apagado.
- ~~`update_response_progress` sem validação de estado~~ — corrigido (migration 014, commit `69c2f47`), verificado com os 3 testes de reprodução agora retornando erro.
- ~~Resumo do relatório não refletia baixa confiança de DISC/Tipo/Motivador/Estilo~~ — corrigido (commit `69c2f47`), verificado com relatório real.

### Pendências ainda abertas

1. **I20/I35 — apresentação especial no relatório** (não implementada): tratar como "acompanhamento requerido" em vez de score numérico, já que são estruturalmente não-mensuráveis por uma aplicação pontual (Grupo D, §5). Mudança de UI, precisa de validação visual antes de entrar — ver `EVOLUA_METODOLOGIA_V2.md` §7 e §11.
2. **Redesenho de situações para os 12 indicadores do Grupo C** (cobertura insuficiente, mas não estrutural) — decisão de produto em aberto, fora do escopo da v2 (que preservou as 28 situações atuais).
3. **Arquivos ainda não commitados desta sessão:** `MAPEAMENTO_REVISAO.md` e `SIMPLIFICACAO_LINGUAGEM.md` (notas de trabalho de tarefas anteriores) e `src/lib/motor/translation.ts` (adições de `MOTIVATOR_GUIDANCE` para DEV/CNF/TQV/OUT) — flagados, não commitados ainda, aguardando decisão de quando entram.
4. **Achados P3 da Auditoria de Prontidão v2.0** (não bloqueiam piloto, ver §14): sem índice explícito em FKs de alto tráfego (`responses.application_id`, `applications.company_id`); observabilidade mínima (só 1 `console.error` em todo o app); nenhuma policy de DELETE existe em nenhuma tabela (decisão de produto a confirmar se é intencional).

### Pendências anteriores (ainda válidas)

5. Se/quando decidirem personalizar por gênero: ver estimativa em §9.2.
6. SMTP customizado no Supabase (ou desativar confirmação de e-mail) para parar de depender do rate-limit do provedor padrão.
7. ~~Rotacionar as chaves~~ — decisão tomada: **não fazer agora** (ver §11). Não sugerir de novo a menos que algo mude (vazamento real ou ida pra produção).
8. **`NEXT_PUBLIC_APP_URL` no ambiente Preview do Vercel:** parece configurada só para Production — em qualquer branch/preview, links públicos gerados pelo app (`/aplicacoes`, `/aplicacoes/[id]`, `/dashboard`) caem no fallback `http://localhost:3000` em vez da URL real do preview. Não afeta produção (lá a env var existe), mas vale configurar também pro Preview se for comum revisar branches antes do merge.

---

## 13. Como um novo dev deve pensar
- A base (auth, questionário, banco, relatório, RLS) está **sólida, real e testada em profundidade** — inclusive isolamento entre empresas e resistência a bypass da API. A taxonomia/mapeamento agora também está em estado sólido (v2, §5–§6) depois de duas rodadas de reconstrução e auditoria. O trabalho de maior valor agora é: (a) decidir o que fazer com os indicadores Grupo C/D (§5, §12), (b) camadas complementares DISC/Tipo/Motivador/Estilo (já implementadas, validar mais a fundo se necessário), (c) pendências pontuais de UX/infra listadas em §12 — não é mais reconstrução metodológica do zero.
- Respeitar: linguagem "ação primeiro"; Base UI (não Radix); IDs fixos da metodologia; sem expor ID na URL do colaborador; a IA nunca interpreta respostas — só o Motor determinístico calcula; toda escrita anônima passa por função `SECURITY DEFINER`, nunca INSERT/UPDATE direto exposto sem validação de negócio no próprio banco.
- **Score ≠ Confiança (v2):** nunca tratar um indicador/pilar com `confidence` abaixo de "alta" como sinal confiável de comportamento fraco — é isso que o motor e o relatório agora existem para evitar. Se for alterar a fórmula de agregação de novo, documentar o motivo e testar com casos reais antes (ver `EVOLUA_METODOLOGIA_V2.md` para o padrão de teste usado).
- Ao mexer em RLS: sempre testar com `service_role` direto (não confiar no HTTP status da tentativa) e sempre checar se há FK apontando para a tabela que você está restringindo.
- Ao mexer em `lib/motor/*`: commitar e pushar antes de testar em produção — ver gotcha §10.11.

---

## 14. Auditoria de Prontidão para Operação Real v2.0 (11/09/2026)

Auditoria completa (segurança, estado do banco, motor, relatório, UX, performance, observabilidade) sobre o commit `2079560`, cobrindo o que a consolidação v2 não cobria: será que a implementação respeita de fato as decisões tomadas? Nenhuma correção foi feita durante a auditoria em si — só depois, com aprovação explícita.

### Veredito: 🟢 GO (com as duas correções abaixo já aplicadas)

Isolamento multi-tenant **testado empiricamente** (não só por leitura de código): 2 tenants de teste criados via API, 6 vetores diretos de IDOR tentados contra a REST API de produção (ler/alterar `applications`/`profiles`/`companies`/`responses` de outra empresa) — todos bloqueados pela RLS. Motor testado com 3 perfis (pouca evidência / evidência repetida consistente / mista-contraditória) + 2 edge cases (zero respostas, 28 respostas idênticas) — nenhuma exceção, nenhum `NaN`, nenhum score fora de 0-100.

Dois problemas reais encontrados e **já corrigidos e verificados em produção**:

1. **`update_response_progress` sem validação de estado** (RPC pública, migration 011) — aceitava forjar `status=completed` sem nenhuma resposta real, `progress` negativo, e reverter `completed→started`. Corrigido na **migration 014** (`supabase/migrations/014_response_state_validation.sql`, commit `69c2f47`): bloqueia qualquer update numa resposta já `completed`, valida limites de `progress`/`current_question`, e só permite `completed` se todas as respostas existirem em `answers`. Os 3 testes de reprodução do problema agora retornam erro (`response_already_completed`, `cannot_complete_without_all_answers`, `invalid_progress`); fluxo normal de resposta seguiu funcionando (regressão testada).
2. **Resumo do relatório não refletia confiança baixa** — o parágrafo do topo (`profile.summary`) e o badge de perfil afirmavam DISC/Tipo/Motivador/Estilo como fato mesmo quando a mesma dimensão aparecia com selo "tendência" (baixa confiança) na seção Leituras Complementares, na mesma tela. Corrigido no commit `69c2f47`: cada cláusula do resumo agora checa a confiança da sua própria dimensão e usa linguagem hedged quando baixa. Verificado com relatório real: um perfil com DISC/Tipo confiantes e Motivador não-confiante gerou resumo corretamente misto (só a cláusula do motivador ficou hedged).

**Achados que não bloqueiam o piloto (P2/P3, backlog):** cobertura de confiança "alta" atinge só ~1 de 35 indicadores mesmo com questionário 100% completo (estrutural, já documentado em §5 — comunicar ao cliente-piloto antes de começar, não é bug); falta apresentação especial de I20/I35 (§12); sem índice explícito em algumas FKs de alto tráfego (relevante só a partir de dezenas de empresas); observabilidade mínima (só 1 `console.error` em todo o app); nenhuma policy de DELETE existe em nenhuma tabela (nem para gestor — decisão de produto a confirmar se é intencional).

**Metodologia de teste usada** (reutilizável para próximas rodadas): tenants de teste criados via `POST /auth/v1/signup` com `data:{full_name, company_name}` (nunca senha em campo de UI — ver gotcha §10.10), aplicações/respostas criadas via REST direto ou RPC pública, verificação sempre com consulta real pós-aplicação (nunca só comparação com arquivo local), cleanup consolidado num único script SQL por rodada, aprovado antes de rodar.
