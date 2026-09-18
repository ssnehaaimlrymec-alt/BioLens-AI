# Biodiversity Intelligence AI

AI Environmental Scientist for Biodiversity & Ecosystem Health.

## Problem Statement

Environmental decisions are often made from isolated measurements: rainfall without soil context, land use without habitat context, or biodiversity observations without a view of the wider ecosystem. That makes it difficult to identify reinforcing risks and choose interventions that are both practical and scientifically grounded.

## Solution

Biodiversity Intelligence AI combines structured environmental inputs, natural-language extraction, a transparent multi-metric reasoning engine, and a local scientific retrieval layer. It produces a screening report that connects soil, water, land use, habitat, biodiversity, and human-pressure signals, then displays the evidence used for each recommendation.

The default runtime is an honest deterministic demo mode. It works without an API key and labels the mode in the interface.

## Key Features

- Natural-language environmental analysis.
- Structured JSON environmental input.
- Session-aware conversation memory.
- Clarifying questions when core information is missing.
- Transparent risk screening for soil health, water availability, habitat, biodiversity, and human impact.
- Multi-metric relationships instead of one-variable answers.
- Evidence retrieval from a local scientific knowledge base.
- Recommendations with action, rationale, impacted metrics, feasibility, evidence strength, confidence, and time horizon.
- What-if scenario analysis with model-based inference clearly separated from sourced findings.
- Knowledge base and source browsing.
- Optional latitude and longitude fields without making unsupported location claims.
- Demo mode that works without an external LLM.

## Architecture

```text
React + Vite frontend
        |
        v
FastAPI-style REST contract on the shared Express API server
        |
        v
Input validation -> session memory -> environmental signal extraction
        |
        v
Transparent multi-metric reasoning engine
        |
        v
Lexical RAG retrieval over local scientific documents
        |
        v
Structured report with evidence-backed recommendations
```

The workspace uses the existing TypeScript monorepo API server rather than adding a second Python process. The API surface is OpenAPI-first and generates both the React Query client and Zod validation schemas.

## Technology Stack

- React, Vite, TypeScript, Tailwind CSS, React Query, Wouter.
- Express 5 API server with Pino logging.
- OpenAPI 3.1 with Orval-generated Zod schemas and React Query hooks.
- Drizzle ORM and PostgreSQL schema for knowledge documents, sessions, messages, and reports.
- Deterministic local retrieval and reasoning so the app runs without external credentials.

## Knowledge Base

Scientific seed documents live in `data/documents/`. The runtime knowledge layer includes source metadata and passages from credible organizations and source categories, including FAO, IPCC, IPBES, and UNEP. The current corpus covers:

- Soil health, soil organic carbon, soil moisture, and soil pH.
- Land use, agroforestry, intercropping, and cover crops.
- Habitat fragmentation, restoration, species richness, and habitat diversity.
- Rainfall, temperature, water availability, and ecosystem resilience.
- Pollution, deforestation, and pollinator support.

The sample passages intentionally avoid unsupported numerical improvement claims.

## RAG Pipeline

1. Load the local source records at API startup.
2. Normalize environmental terms and recommendation topics.
3. Score documents by lexical overlap across topic, title, passage, and keywords.
4. Return the highest-relevance passages with source, year, URL, and a relevance explanation.
5. Attach only retrieved passages to recommendations and the evidence view.

The retrieval interface is isolated in `artifacts/api-server/src/services/intelligence.ts` so it can migrate to embeddings and pgvector without changing the report contract.

## Multi-Metric Reasoning

The screening engine evaluates five areas:

- Soil health.
- Water availability.
- Habitat condition.
- Biodiversity.
- Human impact.

It then looks for explicit relationships, including low rainfall + low soil moisture + low habitat diversity, monoculture + habitat simplification, and low organic carbon + water or heat stress. Each relationship returns a visible chain and an interpretation. The report calls these screening inferences; it does not present them as a site-specific diagnosis.

No unexplained composite score is shown. Concern levels are qualitative and are derived from the number of supplied screening signals in each area. Thresholds such as soil moisture below 25 or organic carbon below 0.5 are treated as demo screening heuristics, not universal ecological limits.

## Conversation Memory

Each chat request accepts an optional `session_id`. The API stores the session's merged environmental fields and message history in a server-side session map. Later messages can answer only the missing field requested by the previous turn, without repeating the full land description. The Drizzle schema includes durable session, message, and report tables for the PostgreSQL-backed version.

## Database Schema

`lib/db/src/schema/biodiversity.ts` defines:

- `knowledge_documents`
- `conversation_sessions`
- `conversation_messages`
- `environmental_reports`

Apply the development schema with:

```bash
pnpm --filter @workspace/db run push
```

The current demo API keeps an in-memory session cache to guarantee a zero-configuration first run. PostgreSQL schema and table contracts are ready for replacing that cache with durable storage.

## API Endpoints

All routes are under `/api`.

| Method | Endpoint | Purpose |
| --- | --- | --- |
| GET | `/health` and `/healthz` | API health |
| POST | `/chat` | Session-aware chat with clarifying questions |
| POST | `/analyze` | Natural-language report |
| POST | `/analyze/json` | Structured environmental report |
| POST | `/what-if` | Scenario analysis |
| POST | `/ingest` | Load or refresh the local knowledge corpus |
| GET | `/knowledge` | Knowledge corpus summary and documents |
| GET | `/sources` | Source catalog |

Interactive Swagger documentation is available at `/api` only through the generated OpenAPI contract; the raw contract is `lib/api-spec/openapi.yaml`.

## Installation

Requirements: Node.js 24 and pnpm 10.

```bash
pnpm install
pnpm --filter @workspace/api-spec run codegen
```

## Environment Variables

Copy `.env.example` to `.env` for local customization:

```bash
DEMO_MODE=true
LLM_API_KEY=
LLM_MODEL=
EMBEDDING_MODEL=
DATABASE_URL=
```

No credentials are required for the deterministic demo. `DEMO_MODE=true` always keeps the app in demo mode. API keys should be supplied through the workspace secrets manager or deployment environment, never committed to source.

## Running Locally

Start the API and web workflows from the Replit workspace, or run the package commands with the workflow-provided `PORT` and `BASE_PATH` values:

```bash
pnpm --filter @workspace/api-server run dev
pnpm --filter @workspace/biodiversity-intelligence-ai run dev
```

The frontend is served at the project preview root. The API is routed under `/api`.

The preloaded demonstration scenario is:

```json
{
  "region": "semi-arid",
  "crop": "wheat",
  "soil_ph": 8.1,
  "organic_carbon": 0.3,
  "soil_moisture": 15,
  "rainfall": "low",
  "temperature": 31,
  "land_use": "monoculture wheat",
  "biodiversity_status": "declining",
  "pollution": "low",
  "deforestation": "low"
}
```

## Example Input

```bash
curl -X POST http://localhost:80/api/analyze/json \
  -H 'content-type: application/json' \
  -d '{"region":"semi-arid","crop":"wheat","soil_ph":8.1,"organic_carbon":0.3,"soil_moisture":15,"rainfall":"low","temperature":31,"land_use":"monoculture wheat","biodiversity_status":"declining"}'
```

## Example Output

The response contains `assessment`, `environmental_relationships`, `recommendations`, `evidence`, `missing_fields`, and `confidence`. Recommendations include:

- What to do.
- Why it works.
- Impacted metrics.
- Time horizon.
- Feasibility.
- Evidence strength.
- Confidence.
- Retrieved scientific passages.

## Scientific Evidence

The Evidence view displays the source title, organization, year, topic, URL, retrieved passage, and why it was relevant. The recommendation engine never invents a citation from a source that was not retrieved.

## Testing

The first build is verified through type checks, API server compilation, database schema push, the generated client, and live endpoint checks. Run the available workspace checks with:

```bash
pnpm --filter @workspace/api-spec run codegen
pnpm run typecheck
pnpm --filter @workspace/api-server run build
pnpm --filter @workspace/biodiversity-intelligence-ai run build
```

## CI/CD

`.github/workflows/ci.yml` installs Node and pnpm, regenerates the API client, type-checks all packages, builds the API and web packages, and checks the API health endpoint.

## Deployment

The app is organized as a deployable React artifact backed by the managed API server. Publish from the Replit workspace after confirming the preview. A Dockerfile is also included for environments that want a single Node-based build image.

## Limitations

- Demo retrieval is lexical rather than embedding-based; it is intentionally easy to inspect and migrate.
- Conversation memory is in-process in the current demo API and resets when the server restarts.
- The reasoning output is a screening aid, not a substitute for local field sampling, regulatory advice, or an ecologist/agronomist.
- No location-specific claims are made from coordinates alone.
- The optional LLM and embedding environment variables are documented, while the shipped report path remains deterministic so it cannot pretend an external model was used.

## Future Scope

- Persist session and report rows through the prepared PostgreSQL schema.
- Add an embedding provider and pgvector retrieval while keeping the evidence contract.
- Add document ingestion from signed uploads and provenance validation.
- Add authenticated workspaces and exportable environmental reports.
- Connect approved weather, land-cover, and biodiversity data sources for location-aware analysis.

## Team

Built as a challenge-ready reference implementation for the Darukaa.Earth AI Biodiversity Intelligence Chatbot Challenge.