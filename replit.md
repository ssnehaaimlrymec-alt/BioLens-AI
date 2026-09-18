# Biodiversity Intelligence AI

An evidence-backed environmental intelligence workspace for connecting soil, water, habitat, climate, and biodiversity signals.

## Run & Operate

- `pnpm --filter @workspace/api-server run dev` — run the API server (port 5000)
- `pnpm run typecheck` — full typecheck across all packages
- `pnpm run build` — typecheck + build all packages
- `pnpm --filter @workspace/api-spec run codegen` — regenerate API hooks and Zod schemas from the OpenAPI spec
- `pnpm --filter @workspace/db run push` — push DB schema changes (dev only)
- Required env: none for demo mode. Optional `DATABASE_URL` powers the prepared PostgreSQL schema.

## Stack

- pnpm workspaces, Node.js 24, TypeScript 5.9
- API: Express 5
- DB: PostgreSQL + Drizzle ORM
- Validation: Zod (`zod/v4`), `drizzle-zod`
- API codegen: Orval (from OpenAPI spec)
- Build: esbuild (CJS bundle)

## Where things live

- `artifacts/biodiversity-intelligence-ai` — React/Vite frontend and route-level UI.
- `artifacts/api-server/src/services/intelligence.ts` — deterministic retrieval, session memory, multi-metric reasoning, and recommendations.
- `artifacts/api-server/src/routes` — API route handlers.
- `lib/api-spec/openapi.yaml` — source-of-truth API contract.
- `lib/db/src/schema/biodiversity.ts` — PostgreSQL/Drizzle persistence schema.
- `data/documents` — source-marked scientific seed documents.

## Architecture decisions

- The API contract is OpenAPI-first so frontend hooks and server validation stay aligned.
- The shipped report path is deterministic and evidence-linked; it does not claim an external LLM was used in demo mode.
- Retrieval is lexical and isolated behind the intelligence service so it can migrate to embeddings/pgvector without changing the UI contract.
- Session memory is in-process for zero-configuration demos; the Drizzle schema is prepared for durable persistence.
- Risk levels are qualitative screening labels, not unexplained composite scores.

## Product

Users can describe or enter environmental conditions, receive clarifying questions, inspect connected risks, explore what-if scenarios, and review the scientific evidence behind recommendations.

## User preferences

The user requested a simple, professional, challenge-ready implementation that prioritizes scientific grounding, transparent reasoning, and a working demo without requiring an API key.

## Gotchas

- Run API codegen after every OpenAPI change.
- Artifact workflows supply `PORT` and `BASE_PATH`; do not hard-code them in app code.
- Demo mode intentionally works without credentials and session memory resets when the API restarts.

## Pointers

- See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details
