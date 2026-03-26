## Summary

[1-2 sentence description of what this PR does and why]

## Spec Reference

- Requirements: `specs/<feature>/requirements.md`
- Design: `specs/<feature>/design.md`
- Task: T<N> — [task description]

## Changes

- [bullet list of what changed]

## Testing

- [ ] Unit tests pass (`pytest tests/unit/`)
- [ ] Integration tests pass (`pytest tests/integration/`) — if applicable
- [ ] LLM evals pass (`pytest tests/evals/ -m eval`) — if agent/RAG code changed
- [ ] Manual verification: [describe what was tested manually]

## Risk Assessment

- [ ] **Security-critical** — touches auth, secrets, RLS, or WAF (requires human review)
- [ ] **Infrastructure change** — modifies K8s manifests, Terraform, or CI/CD (requires devops review)
- [ ] **Database migration** — includes schema changes (requires rollback plan)
- [ ] **None of the above** — standard code change

## Checklist

- [ ] Conventional commit prefix used (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `infra:`)
- [ ] No secrets in code or logs
- [ ] Tests cover acceptance criteria
- [ ] Design doc deviations documented (if any)
- [ ] ADR created for significant technical decisions (if any)
