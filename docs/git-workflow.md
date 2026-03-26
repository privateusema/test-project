# Git Workflow

## Branching Model

Trunk-based development: `main` is always deployable.

Short-lived feature branches only (< 1 day ideal, never > 3 days). No long-lived branches. If work spans multiple sessions, merge frequently.

## Branch Naming Convention

| Prefix | Purpose | Example |
|---|---|---|
| `spec/` | Spec creation or revision | `spec/mvp`, `spec/auth-rev2` |
| `feat/` | Feature implementation (one task per branch) | `feat/mvp-t3`, `feat/ingestion-pipeline-t7` |
| `infra/` | Infrastructure changes | `infra/k8s-manifests`, `infra/ci-pipeline` |
| `fix/` | Bug fixes | `fix/auth-redirect-loop` |
| `docs/` | Documentation only | `docs/adr-003` |
| `chore/` | Maintenance, dependency updates | `chore/bump-langchain` |

## Session Naming Convention

Mirror branch naming: `-n <feature>-<phase>` (e.g., `-n mvp-design`, `-n mvp-t3`, `-n mvp-review`)

## Worktree Usage

- Use `--worktree <branch-name>` for parallel work (e.g., implementer on API + devops on infra)
- Worktrees auto-create branches and auto-clean if no changes
- Naming: worktree name matches branch name

## Merge Strategy

- **Squash-and-merge** is the default for all PRs (configure in GitHub repo settings)
- One task per PR. PRs should be under 200 lines of changes when possible.
- Merge commit only if preserving branch history is specifically needed

## Conventional Commits

All commit messages must use a prefix:

| Prefix | Use for |
|---|---|
| `feat:` | New feature or capability |
| `fix:` | Bug fix |
| `refactor:` | Code restructuring without behavior change |
| `test:` | Adding or updating tests |
| `docs:` | Documentation changes |
| `infra:` | Infrastructure, CI/CD, deployment changes |
| `chore:` | Dependency updates, tooling, maintenance |
| `ci:` | CI/CD pipeline changes |

Format: `<prefix> <short description>` (e.g., `feat: add document upload endpoint`)

## PR Workflow

1. Implementer creates feature branch from `main`
2. Implementer works on one task, writes code + tests
3. Implementer creates PR with structured description (see `.github/PULL_REQUEST_TEMPLATE.md`)
4. CI pipeline runs automatically (lint, test, SAST, build, scan)
5. Reviewer agent validates against spec acceptance criteria
6. Human reviews security-critical changes (auth, secrets, RLS, infrastructure)
7. All checks pass → squash-and-merge to `main`
8. Branch auto-deletes after merge

## Spec Evolution via Branches

- Create `spec/<feature>-rev<N>` branch
- Architect modifies specs
- PR reviewed by human (specs are human-approved)
- Merge triggers design revision if needed
