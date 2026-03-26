---
paths:
  - "src/**"
  - "app/**"
---

# Stack Conventions

- **Python**: FastAPI (HTTP), LangChain/LangGraph (agents), Supabase Python client (DB), Pydantic (validation)
- **TypeScript**: Next.js App Router, Vercel AI SDK (streaming), Supabase JS client
- **Database**: Supabase Postgres + pgvector — one database, no separate stores without an architecture decision (ADR required)
- **Agent memory**: mem0 on DOKS backed by pgvector — do not use in-process memory for cross-session state
- **Cache**: DigitalOcean Managed Valkey (Redis-compatible)
- **Secrets**: Environment variables only. Never hardcode, commit, or log credentials
- **Embeddings**: Anthropic-recommended or DigitalOcean Gradient model — do not add OpenAI as a dependency without an ADR
- **New dependencies**: Do not introduce libraries or tools outside the existing stack without an ADR in `docs/adr/`
