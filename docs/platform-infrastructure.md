# Platform Infrastructure

Cloud resources available to this project. MCP servers are configured in `.mcp.json` and load automatically when Claude Code starts in this directory.

**DigitalOcean** (MCP: `@digitalocean/mcp`)
- DOKS cluster: `doks-nyc3-main` (NYC3, v1.35.1-do.0, 2 nodes s-2vcpu-4gb)
- Container Registry: `xchains-registry` (NYC3, Starter tier)
- Spaces: `xchains-spaces` (NYC3, S3-compatible object storage, endpoint `nyc3.digitaloceanspaces.com`)
- Managed Valkey: `xchains-valkey` (1GB/1vCPU, Redis-compatible). Discover connection string via MCP `db-cluster-list` or `db-cluster-get`. Protocol: `rediss://` (TLS), port 25061. Use the private connection URI when running on DOKS (same VPC).
- Use MCP for: cluster ops, scaling, Spaces management, load balancer config, DNS
- DOKS auth: `doctl kubernetes cluster kubeconfig save doks-nyc3-main` (required before first `kubectl` use)
- Registry auth: `doctl registry login` (required before `docker push`)

**Cloudflare** (MCP: `@cloudflare/mcp-server-cloudflare`)
- Domain: `xchains.dev` (this project: `<SUBDOMAIN>.xchains.dev`)
- WAF: geo-lock to US only, Bot Fight Mode, AI Labyrinth active
- SSL/TLS: Full (Strict), origin cert expires 2041
- Origin certificate: `~/keys/xchains-origin.pem` (cert) + `~/keys/xchains-origin.key` (private key) — needed for DOKS ingress TLS termination behind Cloudflare
- Use MCP for: DNS records, WAF rules, Workers, AI Gateway config, cache purge

**Supabase** (MCP: `@supabase/mcp-server-supabase`)
- Project: `<PROJECT_REF>` (us-east-2)
- Plan: Pro (daily backups, PITR, 8GB DB)
- Extensions: pgvector enabled
- Use MCP for: SQL execution, migrations, edge functions, table management, type generation

**GitHub** (MCP: `ghcr.io/github/github-mcp-server` via Docker)
- Account: `privateusema`
- Use MCP for: repo management, PRs, issues, CI/CD status, branch operations

**Anthropic API**
- Key location: `~/keys/claude-api-key-1.key`
- Models: Haiku (speed/cost), Sonnet (standard), Opus (reasoning)
- Prompt caching available for up to 90% cost reduction on system prompts

**LangSmith**
- Key location: `~/keys/langsmith-api-key-1.key`
- Project: `<PROJECT_NAME>`
- Use for: agent chain tracing, retrieval debugging, eval harnesses

---

## Credential Locations

All API tokens are sourced from env vars set in `~/.zshrc`. Key files live in `~/keys/`. Never hardcode or commit credentials.

| Key Name | File Path | Used For |
|---|---|---|
| `claude-api-key-1` | `~/keys/claude-api-key-1.key` | Anthropic API (ANTHROPIC_API_KEY) |
| `langsmith-api-key-1` | `~/keys/langsmith-api-key-1.key` | LangSmith tracing (LANGCHAIN_API_KEY) |
| `supabase-publishable-key` | `~/keys/supabase-publishable-key.key` | Supabase client-side (SUPABASE_ANON_KEY) |
| `supabase-secret-key` | `~/keys/supabase-secret-key.key` | Supabase server-side (SUPABASE_SERVICE_ROLE_KEY) |
| `supabase-mcp-key-1` | `~/keys/supabase-mcp-key-1` | Supabase MCP personal access token (SUPABASE_ACCESS_TOKEN) |
| `do-mcp-api-key-1` | `~/keys/do-mcp-api-key-1.key` | DigitalOcean API (DIGITALOCEAN_API_TOKEN) |
| `cf-mcp-api-key-1` | `~/keys/cf-mcp-api-key-1.key` | Cloudflare API (CLOUDFLARE_API_TOKEN) |
| `cloudflare-account-id` | `~/keys/cloudflare-account-id.txt` | Cloudflare account ID (CLOUDFLARE_ACCOUNT_ID) |
| `github-mcp-pat-1` | `~/keys/github-pat-1.key` | GitHub MCP PAT (GITHUB_PERSONAL_ACCESS_TOKEN) |
| `xchains-origin.pem` | `~/keys/xchains-origin.pem` | Cloudflare origin certificate (for DOKS ingress TLS) |
| `xchains-origin.key` | `~/keys/xchains-origin.key` | Cloudflare origin private key (for DOKS ingress TLS) |

---

## Environment Variables

All required environment variables are listed in `.env.example`. Key variables for this project:

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Claude API key |
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase publishable key (safe for client-side) |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase secret key (server-side only) |
| `LANGCHAIN_API_KEY` | LangSmith tracing |
| `LANGCHAIN_TRACING_V2` | Set to `true` to enable LangSmith tracing |
| `LANGCHAIN_PROJECT` | LangSmith project name |
| `VALKEY_URL` | Managed Valkey connection string (rediss:// — discover via MCP `db-cluster-get`) |
| `[ADD PROJECT-SPECIFIC VARS]` | [purpose] |

---

## Deployment Notes

- **Container registry:** `registry.digitalocean.com/xchains-registry/<PROJECT_NAME>`
- **Kubernetes namespace:** `<PROJECT_NAME>`
- **Domain:** `<SUBDOMAIN>.xchains.dev`
- **CI/CD:** GitHub Actions — builds image, pushes to DO Registry, deploys to DOKS
- **Supabase project ref:** `<PROJECT_REF>` (update `.mcp.json` with this value)
