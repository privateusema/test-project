# CLAUDE.md — test-project

## CRITICAL

This file provides context to Claude Code and other AI agents for working in this project. Load it fully before taking any action.

---

## Project Overview

**Name:** `test-project`
**Goal:** Validate the project scaffolding and deployment pipeline end-to-end
**Description:** A minimal FastAPI application that serves a health check endpoint. Its sole purpose is to verify the scaffolding template, containerization, DOKS deployment, and Cloudflare routing work correctly at test.xchains.dev. Not intended for production use.

---

## Stack Subset

This project uses the following layers of the full 6-layer stack. Agents should only apply conventions for layers marked Yes.

| Layer | Used? | Notes |
|---|---|---|
| L1 Frontend & Delivery | No | No frontend — API only |
| L2 Backend & Agentic Runtime | Yes | FastAPI (minimal — no agents, no LLM) |
| L3 Kubernetes & Scaling | Yes | DOKS deployment, single replica |
| L4 Security & Auth | No | Cloudflare WAF only (existing zone rules) — no app-level auth |
| L5 Data, Memory & Storage | No | No database — stateless |
| L6 Observability & DevOps | No | GitHub Actions CI only |

Full stack reference: `github(ai-env)::AI/research/full_stack_requirements.md` (53 capabilities, 6 layers).

---

## How to Run Locally

```bash
# Install dependencies
pip install -r requirements.txt

# Start the dev server
uvicorn src.main:app --reload

# Run tests
pytest

# Build container
docker build -t test-project .
```

---

## Entry Points and Key Files

| File | Purpose |
|---|---|
| `src/main.py` | FastAPI app entry point |
| `specs/` | Feature specs (requirements, design, tasks) |
| `.env.example` | All required environment variables |
| `Dockerfile` | Container build |
| `docker-compose.yml` | Local dev services (app + Valkey) |

---

## Agent Constraints

Project-specific constraints for AI agents working in this repo:

- **Language:** Python only
- **Framework:** FastAPI
- **DB access:** None — stateless app
- **Secrets:** Environment variables only. Never hardcode or log credentials
- **Scope:** Minimal validation project — keep it as simple as possible

---

## Stack Conventions

- Python: FastAPI (HTTP), LangChain/LangGraph (agents), Supabase Python client (DB), Pydantic (validation)
- TypeScript: Next.js App Router, Vercel AI SDK (streaming), Supabase JS client
- Infra: DigitalOcean DOKS + Cloudflare + Terraform/Pulumi
- DB: Supabase Postgres + pgvector — one database, no separate stores without an architecture decision
- Agent memory: mem0 on DOKS backed by pgvector — do not use in-process memory for cross-session state
- Cache: DigitalOcean Managed Valkey (Redis-compatible)
- Secrets: DOKS Secrets or Doppler — never in code or committed files

Feature-specific conventions (patterns, structure, testing approach) are documented per-feature in `specs/<feature>/conventions.md`, produced by the architect during Phase 2. Template: `specs/_template/conventions.md`.

---

## Platform Infrastructure, Credentials, and Deployment

@docs/platform-infrastructure.md

---

## Development Workflow

@docs/sdlc.md
@docs/git-workflow.md
