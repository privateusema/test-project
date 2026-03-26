# Tasks: <Feature Name>

**Status:** Not Started
**Design:** `specs/<feature>/design.md`
**Requirements:** `specs/<feature>/requirements.md`

Update status as work progresses:
- `[ ]` Not started
- `[~]` In progress
- `[x]` Complete
- `[-]` Blocked (note reason)

---

## Task List

| ID | Task | Phase | Agent | Depends On | Status | Notes |
|---|---|---|---|---|---|---|
| T1 | [e.g. Create Supabase migration for new table] | Implement | implementer | — | [ ] | |
| T2 | [e.g. Implement FastAPI endpoint] | Implement | implementer | T1 | [ ] | |
| T3 | [e.g. Write unit tests for endpoint] | Implement | implementer | T2 | [ ] | |
| T4 | [e.g. Add Supabase RLS policy] | Implement | implementer | T1 | [ ] | |
| T5 | [e.g. Integrate in Next.js UI] | Implement | implementer | T2 | [ ] | |
| T6 | [e.g. Add LangSmith tracing] | Implement | implementer | T2 | [ ] | |
| T7 | [e.g. Reviewer agent audit] | Implement | reviewer | T1-T6 | [ ] | Run @agent-reviewer |
| D1 | Deploy to staging | StagingDeploy | devops | All impl tasks | [ ] | |
| D2 | Run smoke tests on staging | StagingDeploy | devops | D1 | [ ] | |
| D3 | Deploy to production | ProdDeploy | devops | D2 + human approval | [ ] | |
| D4 | Verify post-deploy health (10 min) | PostDeploy | devops | D3 | [ ] | |

---

## Session Log

Brief notes on what was done each session (not a git log — capture decisions and deviations):

| Date | Tasks | Notes |
|---|---|---|
| YYYY-MM-DD | T1 | [any deviation from design, decision made] |
