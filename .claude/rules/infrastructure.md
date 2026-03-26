---
paths:
  - "infrastructure/**"
  - "*.tf"
  - "*.yaml"
  - ".github/workflows/**"
---

# Infrastructure Conventions

## Terraform / Pulumi
- Always run `terraform plan` before `terraform apply` — never apply without reviewing the plan
- Include plan output in PR description for all infrastructure changes
- Use workspaces or separate state files per environment (staging, production)
- Pin provider versions. Do not use `latest`

## Kubernetes
- All deployments must include liveness, readiness, and startup probes
- Startup probes are mandatory for services that load ML models or warm caches
- Set resource requests AND limits on all containers
- Use rolling update strategy: `maxUnavailable: 0`, `maxSurge: 1` for zero-downtime
- Include Prometheus scrape annotations on all deployments
- Never use `latest` image tag — always use commit SHA or semantic version

## CI/CD
- Docker images tagged with commit SHA (immutable tags)
- All CI checks must pass before merge (lint, test, SAST, build, scan)
- Manual approval gate required before production deployment
- Rollback procedure: `kubectl rollout undo deployment/<name>` or git-revert manifest change

## DNS & CDN
- All public endpoints behind Cloudflare (WAF, DDoS, CDN)
- Origin server uses Cloudflare origin certificate for TLS (Full Strict mode)
- DNS changes via Cloudflare MCP or wrangler CLI
