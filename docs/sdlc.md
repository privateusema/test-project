# SDLC: Software Development Lifecycle

**Scope:** All features developed in this project
**Reference:** Loaded by agents via `@docs/sdlc.md` include in `CLAUDE.md`

---

## 1. Overview

This project follows a spec-first, role-driven development lifecycle. Every feature passes through eight defined phases, each with a quality gate that must be satisfied before the next phase begins. No code is written without an accepted spec. No code merges without a passing review. No production deploy happens without human sign-off.

Four agents operate across the lifecycle:

| Agent | Role | Permission Mode |
|---|---|---|
| `@architect` | Design and spec authorship | `default` (plan-safe) |
| `@implementer` | Code and tests | `acceptEdits` |
| `@reviewer` | Spec validation and audit | `plan` (read-only) |
| `@devops` | Infrastructure, CI/CD, deployments | `acceptEdits` |

The main Claude Code session is the **orchestrator**. It MUST NOT perform work that belongs to an agent's domain. It delegates, monitors, coordinates, and communicates with the user — it does not build, deploy, design, review, or write application code.

### Delegation Rules

**Delegation is mandatory.** When a task matches an agent's domain, the orchestrator MUST delegate to that agent — no exceptions, even for "quick" or "simple" tasks.

| Task type | Delegate to | Examples |
|---|---|---|
| Design, specs, architecture decisions | `@architect` | Write requirements, produce design.md, evaluate tech choices |
| Application code, tests, bug fixes | `@implementer` | Implement a feature, write tests, fix a bug |
| Code review, spec validation, security audit | `@reviewer` | Review a PR, validate acceptance criteria, audit security |
| Infrastructure, CI/CD, deployment, DNS, Docker, K8s, cloud ops | `@devops` | Build/push images, apply K8s manifests, configure Cloudflare, set up CI |

**The orchestrator may only perform directly:**
- Requirements conversations with the user (Phase 1)
- Coordinating and sequencing agent work
- Communicating results and status to the user
- Trivial file reads or searches to decide which agent to invoke

If the orchestrator catches itself running `kubectl`, `docker`, `terraform`, `curl` against cloud APIs, writing application code, or producing design documents — it has violated delegation and must stop and hand off to the correct agent.

---

## 2. Phases and Quality Gates

### Phase Summary Table

| Phase | Name | Owner | Quality Gate (Exit Criteria) |
|---|---|---|---|
| 1 | Requirements | Architect + Human | Spec complete, ACs testable, human sign-off. `requirements.md` Status: Accepted |
| 2 | Design | Architect + Human | Design doc complete with test strategy, observability, and deployment sections. Task breakdown complete. `design.md` Status: Accepted |
| 3 | Implementation | Implementer | All tasks in `tasks.md` checked, tests pass, lint clean, CI green on feature branch |
| 4 | Code Review | Reviewer + Human | Reviewer report has no HIGH findings, SAST clean, all spec ACs verified with file:line evidence. Human approval for security-critical paths |
| 5 | Integration Test | CI + Implementer | Integration tests pass, LLM eval metrics meet baselines (if agent/RAG code), no regressions from prior tests |
| 6 | Staging Deploy | Devops | Docker image pushed with SHA tag, deployed to staging namespace, health checks green, smoke tests pass |
| 7 | Production Deploy | Devops + Human | Human approval gate, staging verification complete, rollback plan documented. Squash-and-merge to main |
| 8 | Post-Deploy Verify | Devops | Health checks green for 10 minutes, no error rate spike, LangSmith traces show normal agent behavior, Cloudflare AI Gateway metrics stable |

---

### Phase 1: Requirements

The architect agent leads a requirements conversation with the human, starting from `project-startup.md` or an in-session prompt. The goal is a complete `specs/<feature>/requirements.md` with a clear problem statement, user stories, and testable acceptance criteria (ACs). Each AC must be binary and verifiable — not vague or aspirational.

**Artifacts consumed:** Prior context, user intent, business constraints
**Artifacts produced:** `specs/<feature>/requirements.md`
**Quality gate:** All ACs are specific and testable. No open questions remain unresolved. The human explicitly sets the spec `Status: Accepted` in the file.

The gate blocks Phase 2. The architect must not produce a design until requirements are accepted.

---

### Phase 2: Design

With accepted requirements, the architect produces `specs/<feature>/design.md`. The design covers architecture placement in the 6-layer stack, component boundaries, the data model, API interfaces, security considerations, a testing strategy, and observability/deployment notes. After design approval, the architect produces `specs/<feature>/tasks.md` — an ordered, dependency-tracked implementation task list scoped to one focused session per task.

**Artifacts consumed:** `specs/<feature>/requirements.md` (Accepted)
**Artifacts produced:** `specs/<feature>/design.md`, `specs/<feature>/conventions.md`, `specs/<feature>/tasks.md`
**Quality gate:** Design doc covers all required sections. Task list is complete, ordered, and dependency-correct. Conventions doc covers applicable backend and/or frontend sections. Human sets `design.md` Status: Accepted.

The gate blocks Phase 3. The implementer must not write application code until the design is accepted.

---

### Phase 3: Implementation

The implementer works through `tasks.md` one task at a time. Each task is implemented with its tests before moving on. The implementer marks tasks complete in `tasks.md` (`[ ]` → `[x]`) after each one, not in a batch at the end. The built-in Tasks system is used for within-session progress signaling to the orchestrator.

**Artifacts consumed:** `specs/<feature>/design.md`, `specs/<feature>/conventions.md`, `specs/<feature>/tasks.md`
**Artifacts produced:** Application code, tests, any infrastructure additions declared in the design
**Quality gate:** All tasks in `tasks.md` are checked (`[x]`). `pytest` / `npm test` passes locally. `ruff` / `eslint` / `tsc` lint is clean. CI pipeline is green on the feature branch.

The gate blocks Phase 4. Do not open a review PR until CI is green.

---

### Phase 4: Code Review

The reviewer agent runs a structured audit against the spec. It confirms each AC is implemented, checks design conformance, runs the security checklist, and verifies test coverage. The output is a structured review report with findings categorized as HIGH, MEDIUM, or LOW. HIGH findings block merge.

For changes touching auth flows, RLS policies, LLM input handling, or secrets management, a human must also review and approve those paths before the gate passes.

**Artifacts consumed:** All code on the feature branch, `specs/<feature>/requirements.md`, `specs/<feature>/design.md`, `specs/<feature>/tasks.md` (including Design Deviations table)
**Artifacts produced:** Review report (in-session output or written to `specs/<feature>/review-<N>.md`)
**Quality gate:** No HIGH findings in the reviewer report. SAST scan clean. Every AC verified with `file:line` evidence. Human approval obtained for security-critical paths.

The gate blocks Phase 5.

---

### Phase 5: Integration Test

The implementer (or CI) runs the full integration test suite against the feature branch — not just unit tests. For features involving LLM calls, RAG retrieval, or agent behavior, LLM eval metrics (e.g., answer relevance, faithfulness, tool call accuracy) must meet baselines defined in `specs/<feature>/design.md`. No regressions from the existing test suite are acceptable.

**Artifacts consumed:** Feature branch code, integration test suite, eval baselines (if defined)
**Artifacts produced:** CI test run artifacts, eval report (if agent/RAG code)
**Quality gate:** All integration tests pass. LLM evals meet baselines (if applicable). No regressions. CI run linked in the PR.

The gate blocks Phase 6 (staging deploy) for full-stack and code-only variants.

---

### Phase 6: Staging Deploy

The devops agent builds the Docker image from the merged-to-staging branch (tagged with the Git SHA), pushes it to the DO container registry, applies any new Kubernetes manifests or Helm chart changes, and deploys to the staging namespace on DOKS. Smoke tests confirm the deploy is functional.

**Artifacts consumed:** Docker image, `infrastructure/k8s/` manifests (if changed), staging namespace
**Artifacts produced:** Running deployment in staging, smoke test results
**Quality gate:** Image pushed with SHA tag. Deployment rolls out cleanly (`kubectl rollout status`). Health check endpoints return 200. Smoke tests pass.

The gate blocks Phase 7. Production deploy must not proceed if staging is unhealthy.

---

### Phase 7: Production Deploy

Production deploy requires explicit human approval. Before the devops agent deploys, it confirms: staging verification is complete, the rollback plan is documented (previous image tag or Helm revision), and the human has approved. The feature branch is squash-merged to `main`. The devops agent deploys to the production namespace.

**Artifacts consumed:** Staging verification, approved PR (squash-merged to main), rollback plan
**Artifacts produced:** Running deployment in production namespace
**Quality gate:** Human approval received. PR squash-merged to `main`. Rollback plan documented. Deployment rolls out cleanly. Initial health checks pass.

The gate blocks Phase 8 verification from being declared complete. Deployment is not done until stability is confirmed.

---

### Phase 8: Post-Deploy Verify

The devops agent monitors production for 10 minutes after deploy. It checks: health check endpoints remain green, error rate has not spiked (Grafana or DO monitoring), LangSmith traces show normal agent behavior (no unexpected errors, latency regressions, or tool call failures), and Cloudflare AI Gateway metrics (token usage, error rate, latency) are stable.

**Artifacts consumed:** Running production deployment, monitoring dashboards, LangSmith traces, Cloudflare AI Gateway metrics
**Artifacts produced:** Post-deploy stability confirmation (session note or commit message)
**Quality gate:** All checks stable for 10 minutes. Any anomaly triggers rollback to the prior version before declaring done.

---

## 3. Agent Responsibilities Per Phase

| Agent | Primary Phases | Secondary Phases |
|---|---|---|
| Architect | 1 (Requirements), 2 (Design) | Consulted during 4 (Review) for design questions |
| Implementer | 3 (Implementation), 5 (Integration Test) | Creates PRs for 4 (Review) |
| Reviewer | 4 (Code Review) | Consulted during 5 for regression analysis |
| Devops | 6 (Staging), 7 (Production), 8 (Post-Deploy) | Supports 3 with infrastructure implementation tasks declared in the design; supports 5 with CI/CD |

**Orchestration:** The main Claude Code session coordinates agents. It can run independent agents in parallel (e.g., `@implementer` on application code while `@devops` handles infrastructure) using worktrees. The built-in Tasks system (`Ctrl+T`) provides real-time visibility into what each agent is doing.

---

## 4. Workflow Variants

Not every feature touches every phase equally. Three standard variants:

### Variant 1: Full-Stack Feature

**Phases:** 1, 2, 3, 4, 5, 6, 7, 8 (all)

A feature that includes both application code changes and infrastructure changes (new K8s manifests, Terraform resources, Cloudflare rules, etc.). The implementer and devops agents may work in parallel during Phase 3 using worktrees — `@implementer` in `feat/<feature>-app` and `@devops` in `feat/<feature>-infra`. Both branches converge before Phase 4.

Use this variant when: the design doc touches any layer outside L1–L2 (i.e., new K8s deployments, DB migrations, Cloudflare rules, Supabase edge functions with infra dependencies).

### Variant 2: Infrastructure-Only

**Phases:** 1, 2, 3, 4, 6, 7, 8 (Phase 5 skipped)

No application code is changed. The devops agent handles Phase 3 implementation (IaC, K8s manifests, Helm charts, CI workflows). The reviewer audits IaC in Phase 4 — same quality gate applies. Phase 5 integration tests are skipped because there is no application code path to exercise. The staging → production flow (Phases 6–8) proceeds normally.

Use this variant when: the feature is purely operational — new cluster node pool, updated WAF rules, new Spaces bucket policy, CI pipeline change.

### Variant 3: Code-Only (No Infrastructure Changes)

**Phases:** 1, 2, 3, 4, 5, 7, 8 (Phase 6 skipped or abbreviated)

Application code changes only. Existing infrastructure (DOKS deployment, ingress, Cloudflare rules) is unchanged. Phase 6 staging deploy is simplified: the devops agent updates the existing deployment's image tag to the new SHA rather than applying new manifests. If the staging namespace already has the correct configuration, Phase 6 may be treated as an image tag update only — no manifest changes required.

Use this variant when: the design doc confirms no infrastructure changes and the only artifact is updated application code in an existing container.

---

## 5. Session Initialization Patterns

Standard Claude Code session commands by phase. Name every session — the `--resume` picker uses names.

**Phase 1 — Requirements**
```bash
# Architect in plan mode: design conversation without file writes until ready
claude --agent architect --permission-mode plan -n <feature>-requirements
```

**Phase 2 — Design**
```bash
# Architect with write access to specs/ — produces design.md then tasks.md
claude --agent architect -n <feature>-design
```

**Phase 3 — Implementation (single task)**
```bash
# Implementer, standard session
claude -n <feature>-t<N>
# @implementer implement task T<N> from specs/<feature>/tasks.md
```

**Phase 3 — Implementation (parallel with worktrees)**
```bash
# Terminal 1: implementer on application code
claude --worktree feat/<feature>-app -n <feature>-app-t<N>

# Terminal 2: devops on infrastructure in parallel
claude --agent devops --worktree feat/<feature>-infra -n <feature>-infra
```

**Phase 4 — Code Review**
```bash
# Reviewer in plan mode: read-only, produces structured report
claude --agent reviewer -n <feature>-review
```

**Phase 5 — Integration Test**
```bash
# Implementer runs integration suite and evals
claude -n <feature>-integration
# @implementer run the integration test suite and LLM evals for specs/<feature>
```

**Phase 6–8 — Deploy**
```bash
# Devops handles staging deploy, production deploy, and post-deploy verification
claude --agent devops -n <feature>-deploy
```

---

## 6. Spec Evolution

Requirements or design changes after acceptance are common. The process ensures in-flight implementation is not disrupted by unreviewed spec changes.

**Lightweight deviations (no spec branch needed):**

Not every implementation difference requires the full spec evolution process. The implementer logs small deviations in the "Design Deviations" table in `tasks.md`. These are reviewed during Phase 4. This covers:
- Renamed fields or functions for clarity
- Changed return types for practical reasons
- Reordered implementation steps
- Minor API shape adjustments that don't affect other components

The full spec evolution process (branch, PR, human review) is required when:
- Acceptance criteria need to change
- API interfaces that downstream tasks depend on need to change
- The data model changes after migrations have been applied
- A new technology or dependency is introduced

**When a spec change is needed:**

1. Create a branch: `spec/<feature>-rev<N>`
2. The architect modifies `requirements.md` and/or `design.md` on that branch
3. `tasks.md` is updated or regenerated to reflect the revised design
4. Open a PR for the spec change — human reviews and approves it
5. In-progress implementation pauses until the spec revision branch is merged to the feature branch
6. The implementer resumes from the revised `tasks.md` — incomplete tasks are re-evaluated against the new design

**Exploring design alternatives:**

Use `--fork-session` to branch from an existing design session and explore an alternative approach without discarding the current design direction. The fork runs in isolation; only the accepted alternative is carried forward.

```bash
# Fork from an active design session to explore an alternative
claude --fork-session <session-name> -n <feature>-design-alt
```

**What never changes without a spec revision:**
- Acceptance criteria that have already been reviewed and verified
- API interfaces that downstream tasks depend on
- The data model after migrations have been applied

---

## 7. Definition of Done

A feature is complete when all of the following are true:

- [ ] All tasks in `specs/<feature>/tasks.md` are checked (`[x]`)
- [ ] All acceptance criteria in `specs/<feature>/requirements.md` pass — verified by the reviewer with `file:line` evidence
- [ ] CI pipeline is green: lint, unit tests, integration tests, SAST scan, container image scan
- [ ] Reviewer report has no unresolved HIGH findings
- [ ] Integration tests pass with no regressions from prior test suite results
- [ ] LLM eval metrics meet baselines defined in the design (if agent or RAG code is included)
- [ ] Feature branch squash-merged to `main` with human approval
- [ ] Deployed to production namespace and stable for 10 minutes (health checks, error rate, LangSmith traces, Cloudflare AI Gateway metrics)
- [ ] ADRs created in `specs/<feature>/` for any significant architectural decisions made during this feature that deviate from or extend the design doc
- [ ] Frontend accessibility: WCAG 2.1 AA verified (if feature has UI)
- [ ] All interaction states implemented: loading, error, empty, success (if feature has UI)
- [ ] Design deviations in `tasks.md` reviewed and accepted by reviewer

A feature is **not** done when:
- Tests pass locally but CI is red
- The reviewer report has HIGH findings marked as "acknowledged"
- Staging has not been verified before production deploy
- The spec `tasks.md` has unchecked tasks marked as "deferred"
