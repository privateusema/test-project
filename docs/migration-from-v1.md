# Migration Guide: v1 → v2 Project Template

This guide migrates an existing project scaffolded from the old `projects/_template/` (v1) to the new `project_template/` structure (v2). The knowledgebase project at `~/dev/knowledgebase/` is the primary migration target.

**What changed:** Claude Code natives adopted (.claude/rules/, enriched agent frontmatter, @includes), 8-phase SDLC, git/PR workflow, CI/CD pipelines, security tooling, ADRs, K8s manifests, Cursor agents, enhanced hooks.

---

## Migration Steps (ordered by dependency)

### Step 1: Create new directories

```bash
mkdir -p .claude/rules
mkdir -p .cursor/agents
mkdir -p docs/adr
mkdir -p tests/unit tests/integration tests/evals/baselines
mkdir -p .github/workflows
```

### Step 2: Copy new files from template

Copy these files from `project_template/` (in the AI-Env mono-repo) to your project. They are new files that don't exist in v1 projects:

```bash
# From AI-Env mono-repo root:
TEMPLATE=project_template
PROJECT=~/dev/<name>

# Claude Code rules
cp $TEMPLATE/.claude/rules/stack-conventions.md $PROJECT/.claude/rules/
cp $TEMPLATE/.claude/rules/security.md $PROJECT/.claude/rules/
cp $TEMPLATE/.claude/rules/testing.md $PROJECT/.claude/rules/
cp $TEMPLATE/.claude/rules/infrastructure.md $PROJECT/.claude/rules/
cp $TEMPLATE/.claude/rules/claude-code-guide.md $PROJECT/.claude/rules/

# Cursor agents
cp $TEMPLATE/.cursor/agents/*.md $PROJECT/.cursor/agents/

# Documentation
cp $TEMPLATE/docs/sdlc.md $PROJECT/docs/
cp $TEMPLATE/docs/git-workflow.md $PROJECT/docs/
cp $TEMPLATE/docs/adr/000-template.md $PROJECT/docs/adr/
cp $TEMPLATE/docs/adr/001-adr-usage.md $PROJECT/docs/adr/

# CI/CD and security
cp $TEMPLATE/.github/workflows/ci.yml $PROJECT/.github/workflows/
cp $TEMPLATE/.github/workflows/deploy.yml $PROJECT/.github/workflows/
cp $TEMPLATE/.github/PULL_REQUEST_TEMPLATE.md $PROJECT/.github/
cp $TEMPLATE/.github/dependabot.yml $PROJECT/.github/
cp $TEMPLATE/.pre-commit-config.yaml $PROJECT/

# Testing
cp $TEMPLATE/pytest.ini $PROJECT/
cp $TEMPLATE/tests/conftest.py $PROJECT/tests/
cp $TEMPLATE/tests/__init__.py $PROJECT/tests/
cp $TEMPLATE/.cursorignore $PROJECT/

# K8s manifests
cp $TEMPLATE/infrastructure/k8s/*.yaml $PROJECT/infrastructure/k8s/
```

### Step 3: Fill in placeholders in copied files

Replace `<PROJECT_NAME>`, `<SUBDOMAIN>`, `<IMAGE_TAG>` in:
- `.github/workflows/deploy.yml`
- `infrastructure/k8s/*.yaml`

### Step 4: Update agent frontmatter

Edit each file in `.claude/agents/` to add the new frontmatter fields. Add these to the YAML block between `---` delimiters:

**All agents:**
```yaml
memory: project
maxTurns: <value>   # architect:50, implementer:100, reviewer:30, devops:80
```

**architect.md:** Add `mcpServers: [github, supabase]`
**implementer.md:** Add `initialPrompt: |` (see template for content)
**reviewer.md:** Add `mcpServers: [github]`, `disallowedTools: [Write, Edit]`, `initialPrompt: |`
**devops.md:** Add `mcpServers: [digitalocean, cloudflare, github, supabase]`

### Step 5: Update architect agent for ADRs

In `.claude/agents/architect.md`:
- Add `docs/adr/` to the Write Access section
- Add step 5 to Your Process: create ADRs for significant decisions

### Step 6: Enhance reviewer agent

In `.claude/agents/reviewer.md`:
- Add OWASP LLM Top 10 checklist (section 5b)
- Add Regression Check (section 7), Duplicate Detection (section 8), Infrastructure Review (section 9)
- Add file:line evidence requirement to Spec Validation (section 2)

### Step 7: Update settings.json hooks

Replace `.claude/settings.json` with the new version from the template (adds SessionStart hook, conventional commit hook, enhanced Stop hook). Or manually add:
- Second `PreToolUse` entry for conventional commit validation
- `SessionStart` event with branch/commit context
- Enhanced `Stop` message with ADR and commit reminders

### Step 8: Decompose CLAUDE.md

1. Create `docs/platform-infrastructure.md` — extract the Platform Infrastructure, Credentials, Environment Variables, and Deployment Notes sections from CLAUDE.md
2. Replace those sections in CLAUDE.md with `@docs/platform-infrastructure.md`
3. Replace the Development Workflow section with `@docs/sdlc.md` and `@docs/git-workflow.md`
4. Remove the Claude Code User Guide section (now in `.claude/rules/claude-code-guide.md`)
5. Target: CLAUDE.md should be ~100-120 lines (project overview, stack subset, how to run, entry points, constraints, `@` includes)

### Step 9: Update .gitignore

Add:
```
.claude/agent-memory-local/
```

Ensure these are NOT gitignored:
- `.claude/agent-memory/`
- `.claude/rules/`

### Step 10: Update spec templates

Replace `specs/_template/design.md` and `specs/_template/tasks.md` with the new versions that include Observability/Deployment/Infrastructure sections and Phase/Agent columns.

### Step 11: Install pre-commit hooks

```bash
cd ~/dev/<name>
pip install pre-commit
pre-commit install
pre-commit run --all-files  # verify
```

### Step 12: Configure GitHub repo settings

- Set default merge strategy to squash-and-merge
- Add `production` environment with required reviewers (for deploy.yml approval gate)
- Add required secrets: `DIGITALOCEAN_API_TOKEN`, `ANTHROPIC_API_KEY`, `LANGCHAIN_API_KEY`

---

## Verification

After migration:
1. Start a Claude Code session — verify SessionStart hook fires (shows branch and last commit)
2. Run `/hooks` — verify all 4 hook events are listed (PreToolUse x2, PostToolUse, SessionStart, Stop)
3. Try `git commit -m "bad message"` — verify conventional commit hook blocks it
4. Try `git commit -m "feat: test"` — verify it passes
5. Run `pre-commit run --all-files` — verify hooks execute
6. Check `python3 -c "import json; json.load(open('.claude/settings.json'))"` — verify valid JSON
