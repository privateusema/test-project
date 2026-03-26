# test-project

> Validate the project scaffolding and deployment pipeline end-to-end

---

## Overview

A minimal FastAPI application that serves a health check endpoint. Its sole purpose is to verify the scaffolding template, containerization, DOKS deployment, and Cloudflare routing work correctly at test.xchains.dev.

---

## Quick Start

```bash
# 1. Clone and enter project directory
git clone <REPO_URL>
cd test-project

# 2. Copy environment variables and fill in values
cp .env.example .env

# 3. Install dependencies and start dev server
pip install -r requirements.txt
uvicorn src.main:app --reload
```

The app will be available at `http://localhost:8000`.

---

## Architecture

| Layer | What |
|---|---|
| L2 Backend | FastAPI — single health-check endpoint |
| L3 Kubernetes | DOKS single-replica deployment |

Full stack reference: `github(ai-env)::AI/research/full_stack_requirements.md`

---

## Deployment

- **Container:** `registry.digitalocean.com/xchains-registry/test-project`
- **Kubernetes:** DOKS cluster `doks-nyc3-main`, namespace `test-project`
- **Domain:** `test.xchains.dev` (behind Cloudflare WAF + CDN)
- **CI/CD:** GitHub Actions → DO Container Registry → rolling deploy to DOKS

---

## Environment Variables

See `.env.example` for the full list of required variables and their descriptions.
