# ADR-001: Use Architecture Decision Records

## Status

Accepted

## Context

AI agents working on this project need context about past architectural decisions to avoid re-litigating settled choices or making contradictory decisions. Design rationale is currently captured only in chat transcripts and design docs, which are not easily searchable or cross-referenceable.

## Decision

Use Architecture Decision Records (ADRs) stored in `docs/adr/` for all significant technical decisions. ADRs follow the Michael Nygard format (Status, Context, Decision, Consequences). ADRs are immutable — to change a decision, create a new ADR that supersedes the old one. The architect agent creates ADRs during the design phase. ADRs are numbered sequentially (ADR-001, ADR-002, etc.).

## Consequences

- Every significant decision has a permanent, findable record
- Agents can read `docs/adr/` to understand why things are the way they are
- ADR files add to the repository but are small (< 1 page each)
- Superseded ADRs remain in the repository for historical context
- The architect agent's write access must include `docs/adr/`
