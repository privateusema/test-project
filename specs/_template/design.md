# Design: <Feature Name>

**Status:** Draft | In Review | Accepted
**Author:** Mario Aguilera / Architect Agent
**Created:** YYYY-MM-DD
**Requirements:** `specs/<feature>/requirements.md`

---

## Overview

One paragraph: what this feature is, where it lives in the system, and the key technical approach.

---

## Architecture

Which of the 6 stack layers this touches:

| Layer | Affected? | Notes |
|---|---|---|
| L1 Frontend & Delivery | Yes/No | |
| L2 Backend & Agentic Runtime | Yes/No | |
| L3 Kubernetes & Scaling | Yes/No | |
| L4 Security & Auth | Yes/No | |
| L5 Data, Memory & Storage | Yes/No | |
| L6 Observability & DevOps | Yes/No | |

Diagram (ASCII or Mermaid) if helpful:

```
[User] → [Cloudflare Workers] → [FastAPI on DOKS] → [Supabase]
```

---

## Components

New or modified files and their responsibility:

| File | New/Modified | Responsibility |
|---|---|---|
| `src/...` | New | |
| `tests/...` | New | |

---

## Data Model

Schema additions or changes. Include full Supabase migration SQL.

```sql
-- Migration: <feature>
CREATE TABLE ...;
ALTER TABLE ...;
```

RLS policies required:

```sql
CREATE POLICY ...
```

---

## API / Interfaces

### HTTP Endpoints (if applicable)

```
POST /api/<resource>
  Body: { ... }
  Response: { ... }
  Auth: JWT required
```

### Agent Tool Schema (if applicable)

```python
class ToolInput(BaseModel):
    ...
```

### Internal Contracts

Key function or class interfaces that other components will depend on.

---

## Security Considerations

- Auth: [how authentication and authorization work for this feature]
- Input validation: [what user inputs exist and how they are validated]
- Prompt injection: [if LLM calls are involved, how injection is mitigated]
- Secrets: [what secrets are needed and how they are stored]
- RLS: [Supabase row-level security rules required]

---

## Testing Strategy

| Test Type | What | Where |
|---|---|---|
| Unit | [what] | `tests/unit/` |
| Integration | [what] | `tests/integration/` |
| Agent eval | [what] | `tests/evals/` |
| E2E | [what] | `tests/e2e/` |

---

## Observability

What metrics, traces, and log events does this feature need?

| Type | What to Instrument | Tool |
|---|---|---|
| Metrics | [e.g., request latency, error rate, token usage] | Prometheus / OpenTelemetry |
| Traces | [e.g., full request path, agent tool call chain, LLM inference] | OpenTelemetry / LangSmith |
| Logs | [e.g., ingestion pipeline steps, auth events, errors] | structlog (JSON) with trace_id |
| Dashboards | [e.g., Grafana board for API latency and error rates] | Grafana |

---

## Deployment

| Aspect | Detail |
|---|---|
| Strategy | [Rolling update / Blue-green / Canary] |
| Health endpoints | `/healthz` (liveness), `/ready` (readiness) |
| Startup time | [Estimated seconds — affects startup probe config] |
| Resource requirements | [CPU/memory requests and limits] |
| Rollback plan | [`kubectl rollout undo` / git-revert manifest] |

---

## Infrastructure Changes

New infrastructure required for this feature:

| Resource | Type | Details |
|---|---|---|
| [e.g., K8s Deployment] | [New / Modified] | [Description] |
| [e.g., DNS record] | [New] | [api.xchains.dev → LoadBalancer IP] |
| [e.g., Supabase table] | [New] | [documents table with RLS] |

---

## Open Questions

Questions that arose during design and are not yet resolved:

- [ ] Q1: [question] — impacts [component]
- [ ] Q2: [question] — impacts [component]

---

## Decisions Made

Significant decisions and their rationale:

| Decision | Alternatives Considered | Rationale |
|---|---|---|
| Use X instead of Y | Y, Z | [reason] |
