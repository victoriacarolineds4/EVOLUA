# EVOLUA

Plataforma de diagnóstico e desenvolvimento humano criada pela Neon Conecta.

> "Toda pessoa pode evoluir quando recebe a direção certa."

Consulte [CLAUDE.md](./CLAUDE.md) para a documentação completa de produto, filosofia e regras de desenvolvimento.

---

## Stack

Next.js 15 (App Router) · TypeScript · TailwindCSS · Shadcn/UI · Supabase · React Query · React Hook Form · Zod · Framer Motion · Recharts

---

## Como instalar

Pré-requisitos: Node.js 20+ e npm.

```bash
npm install
```

---

## Como executar

```bash
npm run dev
```

A aplicação sobe em [http://localhost:3000](http://localhost:3000).

Outros scripts disponíveis:

```bash
npm run build   # build de produção
npm run start   # roda o build de produção
npm run lint    # checagem de lint (ESLint)
```

---

## Como configurar o Supabase

1. Crie um projeto em [supabase.com](https://supabase.com).
2. Em **Project Settings > API**, copie a **Project URL** e a **anon public key**.
3. Duplique o arquivo `.env.example` como `.env.local`:

   ```bash
   cp .env.example .env.local
   ```

4. Preencha as variáveis:

   ```bash
   NEXT_PUBLIC_SUPABASE_URL=
   NEXT_PUBLIC_SUPABASE_ANON_KEY=
   SUPABASE_SERVICE_ROLE_KEY=
   NEXT_PUBLIC_APP_URL=http://localhost:3000
   ```

Sem essas variáveis a aplicação continua rodando normalmente (a fundação usa valores de placeholder), mas nenhuma chamada real ao Supabase funcionará até o projeto ser configurado.

Os clients já estão prontos em:

- `src/lib/supabase/client.ts` — uso em Client Components
- `src/lib/supabase/server.ts` — uso em Server Components e Server Actions
- `src/lib/supabase/middleware.ts` + `src/middleware.ts` — refresh de sessão

Nenhuma tabela ou autenticação foi criada ainda — isso faz parte de uma sprint futura.

---

## Como publicar na Vercel

1. Suba o repositório para o GitHub/GitLab/Bitbucket.
2. Em [vercel.com/new](https://vercel.com/new), importe o repositório.
3. Configure as mesmas variáveis de ambiente do `.env.example` em **Project Settings > Environment Variables**.
4. Deploy. A cada push na branch principal a Vercel gera um novo deploy automaticamente.

---

## Estrutura do projeto

```
src/
  app/            rotas, layout raiz e providers (App Router)
  components/
    ui/           primitivos do design system (Shadcn)
    layout/       Container, Section, PageHeader, Sidebar, Topbar, AppShell, EmptyState
  features/       domínios de negócio (gestor, colaborador, questionario, mapas)
  hooks/          hooks reutilizáveis
  services/       acesso a dados e integrações externas
  lib/            utilitários centrais e clients (ex: supabase)
  types/          tipos compartilhados
  utils/          funções utilitárias
  styles/         estilos globais adicionais
```
