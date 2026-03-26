# Project Startup

This document is the handoff point between mono-repo scaffolding and project-level agentic development. It is the first thing you read after a project has been scaffolded from `project_template/`. Follow it sequentially.

---

## What has already been done (mono-repo level)

Before you arrived here, the following was completed at the AI-Env mono-repo level:

1. `project_template/` (in the AI-Env mono-repo) was copied to this directory (`~/dev/<name>/`)
2. All placeholder values were filled in:
   - `CLAUDE.md` — project name, goal, description, stack subset, entry points, agent constraints
   - `README.md` — project overview, architecture table, deployment details
   - `.env.example` — LangSmith project name
   - `.claude/agents/devops.md` — Docker image tags
3. No source directories were created — that is your job, driven by the spec

**The project is now self-contained.** All agent configuration, hooks, permissions, MCP wiring, Cursor rules, and spec templates are local. There are no dependencies on the mono-repo for development.

---

## What happens now (project level)

You are starting the spec-first development workflow. The goal of this session is to produce a complete requirements spec for the project's first feature — the MVP.

### Step 1 — Understand the project

Read these files in order:
1. `CLAUDE.md` — project goal, stack subset, conventions, constraints
2. `README.md` — architecture overview
3. `.env.example` — what services are in play

### Step 2 — Requirements conversation

The architect agent (or the orchestrating session) conducts a requirements conversation with the user. This is interactive — ask questions, don't assume.

**Questions to answer:**

*Problem & users*
- What specific problem does this project solve?
- Who are the users? (just the developer? a small audience? public?)
- What does the user do today without this tool?

*Core workflow*
- What is the primary user flow, step by step?
- What does the user see and interact with?
- What happens behind the scenes at each step?

*Scope boundaries*
- What is the smallest version of this that would be useful? (the MVP)
- What features are explicitly out of scope for the first version?
- Are there hard technical constraints? (e.g., Python-only, no new cloud services)

*Data & integrations*
- What data does the system store?
- What external services does it call?
- What are the inputs and outputs?

*Non-functional*
- Who needs to authenticate? How?
- Are there performance requirements?
- Is there anything security-sensitive beyond standard practices?

### Step 3 — Write the requirements spec

After the conversation, create `specs/mvp/requirements.md` from the template at `specs/_template/requirements.md`. It must include:

- **Problem statement** — one paragraph, grounded in the conversation
- **User stories** — 3-7 stories covering the core workflow
- **Acceptance criteria** — testable, binary conditions. Every criterion will be validated in review. If you can't test it, rewrite it
- **Constraints** — hard limits from CLAUDE.md + anything surfaced in conversation
- **Out of scope** — explicitly fence off what the MVP does not do
- **Open questions** — anything unresolved that blocks design

### Step 4 — Review and accept

Present the requirements spec to the user for review. Iterate until accepted. The spec is accepted when:
- The user confirms the problem statement is accurate
- Every user story reflects intended behavior
- Acceptance criteria are complete and testable
- Out-of-scope items are agreed upon

### Step 5 — Hand off to design

Once requirements are accepted, the next session activates `@agent-architect` (or `@100-architect` in Cursor) to produce:
1. `specs/mvp/design.md` — architecture, components, data model, APIs, security, testing strategy
2. `specs/mvp/tasks.md` — ordered implementation tasks, each scoped to one focused session

No code is written until the design is accepted.

---

## After startup: the 8-phase development lifecycle

Once design is accepted, the project follows the full 8-phase SDLC defined in `docs/sdlc.md`:

```
1. SPEC → 2. DESIGN → 3. IMPLEMENT → 4. REVIEW → 5. INTEGRATION TEST → 6. STAGING → 7. PRODUCTION → 8. VERIFY
```

- `@agent-architect` owns phases 1-2 (requirements, design)
- `@agent-implementer` owns phase 3 (code + tests, one task at a time from `tasks.md`)
- `@agent-reviewer` owns phase 4 (spec validation, security audit, regression check)
- `@agent-devops` owns phases 6-8 (staging deploy, production deploy, post-deploy verification)
- CI pipeline handles phase 5 (integration tests, LLM evals, SAST)
- New features restart at phase 1 with their own `specs/<feature>/` directory

See `docs/sdlc.md` for full quality gates, session initialization patterns, workflow variants, and spec evolution process.

---

## Reference

| File | Purpose |
|---|---|
| `CLAUDE.md` | Project context — the single source of truth for agents |
| `specs/_template/` | Templates for requirements, design, and task specs |
| `.claude/agents/` | Agent definitions (architect, implementer, reviewer, devops) |
| `.cursor/rules/` | Cursor role rules (000-always, 100-architect, 101-implementer, 102-reviewer) |
| `.claude/settings.json` | Hooks (destructive command blocking, change logging, session reminders) and permissions |
| `.mcp.json` | MCP server connections (DO, CF, GitHub, Supabase) |
