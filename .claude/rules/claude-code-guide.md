---
# No paths — always loaded as quick reference
---

# Claude Code Quick Reference

## Agent Invocation

Agents are defined in `.claude/agents/` and loaded automatically at session start.

```bash
# @-mention in prompt (recommended — guarantees the agent runs)
@architect Read specs/mvp/requirements.md and produce specs/mvp/design.md

# Start an entire session as an agent
claude --agent architect

# Natural language (Claude decides whether to delegate based on agent descriptions)
review the auth module for security issues
```

Available agents: `@architect` (design), `@implementer` (code), `@reviewer` (audit), `@devops` (infra).

## Plan Mode

Use for architecture decisions and design before writing code.

```bash
Shift+Tab          # cycle permission modes: default → acceptEdits → plan
/plan              # enter plan mode mid-session
/plan open         # open plan file in editor
```

Plan mode is read-only — Claude explores and designs without modifying files. Exit plan mode to execute.

## Session Management

```bash
claude -n mvp-design           # name a session at startup
claude --continue              # resume most recent session in this directory
claude --resume                # interactive picker for any past session
claude --resume mvp-design     # resume by name
```

Name every session. The `/resume` picker lets you find and continue past work.

## Parallel Execution with Worktrees

Run multiple agents simultaneously without file conflicts:

```bash
# Terminal 1: implementer works on API
claude --worktree feature-api -n mvp-api

# Terminal 2: devops handles infrastructure in parallel
claude --agent devops --worktree infra-setup -n mvp-infra
```

Each worktree gets its own isolated branch. Auto-cleans if no changes are made.

## Task Tracking

Two systems work together:

- **In-session:** `Ctrl+T` toggles the task list. Agents use `TaskCreate`/`TaskUpdate` for real-time progress
- **Cross-session:** `specs/<feature>/tasks.md` is the durable record that survives session ends. The Stop hook reminds you to update it

## Memory & Persistence

```bash
/memory            # view/edit persistent memory (survives across sessions)
```

`autoMemoryEnabled: true` is on — Claude auto-captures learnings. Agents with `memory: project` store durable knowledge in `.claude/agent-memory/<agent-name>/` (committable to git).

## Context Management

```bash
/compact           # summarize and compress conversation when context gets long
/cost              # check token spend
Esc Esc            # rewind to an earlier point in the conversation
```

Use subagents (Explore, Plan) for verbose searches to keep the main context clean.

## Model & Mode Switching

```bash
Option+P           # switch models mid-session (Opus for design, Sonnet for implementation)
Shift+Tab          # cycle permission modes (default → acceptEdits → plan)
/effort            # adjust thinking budget (low/medium/high)
```

## Hooks

Configured in `.claude/settings.json`. This project has:

- **PreToolUse:** Blocks destructive commands (`rm -rf`, `DROP TABLE`, force push to main). Validates conventional commit prefixes
- **PostToolUse:** Logs all file modifications to `.claude/session-changes.log`
- **SessionStart:** Prints current branch, last commit, and SDLC phase reminder
- **Stop:** Reminds to update `tasks.md`, memory, and ADRs

Check active hooks with `/hooks` during any session.

## MCP Servers

Four MCP servers load automatically from `.mcp.json`:

| Server | What it manages |
|---|---|
| `digitalocean` | DOKS cluster, Spaces, Valkey, registry, DNS |
| `cloudflare` | WAF rules, DNS records, Workers, AI Gateway, cache |
| `github` | Repos, PRs, issues, CI/CD status, branches |
| `supabase` | SQL execution, migrations, edge functions, tables, types |

Agents can manage all infrastructure via natural language through these MCP servers. Agents have scoped MCP access via `mcpServers` frontmatter.

## Headless Mode (CI/CD)

```bash
claude -p "run tests and report failures" --output-format json
```

Useful for GitHub Actions — pipe commands without interaction.

## Typical Session Workflow

```bash
# 1. Design phase — architect produces design.md
claude --agent architect -n mvp-design

# 2. Implementation — implementer works one task at a time
claude -n mvp-implement
# @implementer works task T1 from tasks.md

# 3. Parallel infra work (separate terminal)
claude --agent devops --worktree infra-setup -n mvp-infra

# 4. Review before merge
claude --agent reviewer -n mvp-review
```

## Key Shortcuts

| Shortcut | Action |
|---|---|
| `Shift+Tab` | Cycle permission modes |
| `Ctrl+T` | Toggle task list |
| `Ctrl+O` | Toggle verbose (show internal reasoning) |
| `Option+P` | Switch models mid-session |
| `Esc Esc` | Rewind conversation |
| `/compact` | Compress context |
| `/cost` | Show token spend |
| `/effort` | Adjust thinking effort |
