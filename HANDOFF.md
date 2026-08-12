# EVOLUA — Documento de Handoff Técnico
> Estado do sistema para continuidade do desenvolvimento. Escrito para um dev sênior assumir sem contexto prévio.
> Data-base: agosto/2026 — pós Sprint de Melhorias (9 itens: seed do mapeamento, licenças, encerrar aplicação, e-mail, limpeza de mocks, estimativa de gênero, hardening de RLS, rotação de chaves, revisão do mapeamento).

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
| `update_response_progress(p_id, p_progress, p_current_question, p_status?, p_completed_at?)` | Atualiza só a própria resposta |
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

## 5. A Metodologia EVOLUA (congelada)

**7 Pilares · 5 indicadores cada = 35 indicadores · 28 situações (4 por pilar) · 4 alternativas cada = 112 alternativas.**

| # | Pilar | Indicadores |
|---|---|---|
| 1 | Autogestão | I01 Responsabilidade Pessoal · I02 Gestão Emocional · I03 Autoconfiança · I04 Disciplina e Consistência · I05 Clareza de Propósito |
| 2 | Comunicação | I06 Clareza na Expressão · I07 Escuta Ativa · I08 Assertividade · I09 Feedback Construtivo · I10 Comunicação Adaptada |
| 3 | Relacionamento | I11 Empatia · I12 Colaboração · I13 Gestão de Conflitos · I14 Construção de Confiança · I15 Influência Positiva |
| 4 | Orientação a Resultados | I16 Planejamento e Organização · I17 Foco e Priorização · I18 Gestão do Tempo · I19 Qualidade nas Entregas · I20 Resiliência sob Pressão |
| 5 | Liderança | I21 Visão Estratégica · I22 Tomada de Decisão · I23 Desenvolvimento de Pessoas · I24 Delegação Eficaz · I25 Inspiração e Motivação |
| 6 | Inovação e Adaptação | I26 Mentalidade de Crescimento · I27 Criatividade Prática · I28 Tolerância à Ambiguidade · I29 Abertura ao Feedback · I30 Adaptabilidade |
| 7 | Desenvolvimento Contínuo | I31 Autocrítica Construtiva · I32 Busca por Aprendizado · I33 Aplicação do Conhecimento · I34 Compartilhamento de Conhecimento · I35 Visão de Futuro |

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

### Modelo de pontuação
- **Indicador (0–100)** = evidência mostrada ÷ evidência máxima possível × 100. Comparável entre pessoas.
- **Pilar** = média dos seus indicadores.
- **Dimensões** = ranking por evidência + participação %; predominante só é afirmado com ≥3 situações (senão "tendência").

### Estrutura do relatório "ação primeiro" (`GeneratedReport`)
Perfil → Essencial em 30s → Como agir (6 blocos) → Pilares + Radar → Leituras Complementares → Pontos Fortes/Atenção → Plano 30/60/90.

### O mapeamento das 112 alternativas — agora VERSIONADO, ainda RASCUNHO
- **Seed:** `supabase/seeds/005_official_mapping.sql` (941 vínculos: 316 indicadores + 625 dimensões). Gerado a partir do banco e **verificado byte-a-byte** — computar o diagnóstico a partir só do arquivo `.sql` dá exatamente o mesmo resultado que a partir do banco ao vivo.
- **Revisão humana:** `MAPEAMENTO_REVISAO.md` na raiz — as 28 situações com as 4 alternativas de cada e todos os vínculos (indicadores + DISC + Tipo + Motivadores + Estilo, com a força em português), para a Victoria revisar sem precisar mexer no banco.
- Continua **rascunho gerado por análise do texto de cada alternativa** — não é instrumento validado psicometricamente. Discrimina perfis corretamente nos testes (2 perfis sintéticos diferentes → scores e dimensões claramente distintos).
- **Cobertura:** todo indicador tem ≥3 situações que o evidenciam (os 4 mais magros — I10, I24, I27, I34 — foram reforçados). I16 Planejamento é o mais coberto (17 situações).

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
**Gestor (protegidas):** `/dashboard` · `/aplicacoes` · `/aplicacoes/nova` · `/aplicacoes/[id]` · `/relatorio` · `/relatorio/[responseId]` · `/meu-plano` · `/configuracoes`
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

---

## 11. Ambiente, credenciais e segurança

- **`.env.local`** (git-ignored): `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `NEXT_PUBLIC_APP_URL`. `SUPABASE_SERVICE_ROLE_KEY` **nunca** aparece no código do app — usada só em scripts locais pontuais de setup/teste.
- Projeto Supabase atual: ref `rxtxsmvnjeasmawktonf`.
- ⚪ **Rotação de chaves — DECISÃO TOMADA (2026-08): NÃO rotacionar por enquanto.** As chaves `anon`/`service_role` foram compartilhadas em chat durante o desenvolvimento, mas a Victoria decidiu manter como está enquanto for só ela trabalhando no projeto (sem produção/usuários reais ainda). **Não reabrir esse assunto por conta própria** — só revisitar se: (a) alguma chave vazar de fato fora deste contexto controlado, ou (b) o projeto for pra produção com usuários reais. Se/quando for retomado: o projeto já migrou o "JWT Signing Keys" (ECC P-256) mas as chaves legadas `anon`/`service_role` (HS256) dependem do "Legacy JWT Secret", que só se troca revogando via aba JWT Keys — ação que derruba as duas chaves na hora sem gerar substitutas automáticas. O caminho recomendado pela própria Supabase nesse caso é migrar para o novo sistema "Publishable and secret API keys" (rotação independente, sem esse efeito colateral) em vez de forçar a revogação do secret legado — isso é uma migração de código (trocar as env vars e possivelmente o nome delas), não um simples reset, e merece ser tratada como tarefa própria.
- Rodar dev: `npm run dev` (porta 3000). Provisionar banco novo do zero: colar **só** `supabase/EVOLUA_FULL_SETUP.sql` no SQL Editor — já inclui migrations 001–013 + os 3 seeds na ordem certa, nada mais precisa ser rodado separadamente.

---

## 12. Pendências reais restantes

1. **Validação humana do mapeamento e dos textos de tradução** (Victoria) — usar `MAPEAMENTO_REVISAO.md`. É a única pendência das 9 desta sprint que não é código.
2. Se/quando decidirem personalizar por gênero: ver estimativa em §9.2.
3. SMTP customizado no Supabase (ou desativar confirmação de e-mail) para parar de depender do rate-limit do provedor padrão.
4. ~~Rotacionar as chaves~~ — decisão tomada: **não fazer agora** (ver §11). Não sugerir de novo a menos que algo mude (vazamento real ou ida pra produção).

---

## 13. Como um novo dev deve pensar
- A base (auth, questionário, banco, relatório, RLS) está **sólida, real e testada em profundidade** — inclusive isolamento entre empresas e resistência a bypass da API. O trabalho de maior valor agora é **metodológico** (validar/afinar o mapeamento e os textos com a Victoria), não engenharia.
- Respeitar: linguagem "ação primeiro"; Base UI (não Radix); IDs fixos da metodologia; sem expor ID na URL do colaborador; a IA nunca interpreta respostas — só o Motor determinístico calcula; toda escrita anônima passa por função `SECURITY DEFINER`, nunca INSERT/UPDATE direto exposto sem validação de negócio no próprio banco.
- Ao mexer em RLS: sempre testar com `service_role` direto (não confiar no HTTP status da tentativa) e sempre checar se há FK apontando para a tabela que você está restringindo.
