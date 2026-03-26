---
paths:
  - "src/**"
  - "app/**"
  - "infrastructure/**"
---

# Security Requirements

## Code-Level
- Never hardcode secrets, API keys, or tokens. Use environment variables exclusively
- Never log credentials or sensitive data
- All user input must be validated before use — especially before LLM calls
- Never construct raw SQL with user-supplied values — use parameterized queries or Supabase client
- All database access through Supabase RLS. No direct SQL bypassing row-level security
- Auth enforced on all protected routes (Supabase Auth required)

## LLM Security (OWASP LLM Top 10)
- **Prompt injection**: Sanitize and validate all inputs before they reach the LLM. Use layered validation
- **Sensitive information disclosure**: Minimize data in prompts. Monitor outputs for leaked credentials or PII
- **Excessive agency**: Apply principle of least privilege to agent tool access. Limit what tools agents can call
- **System prompt leakage**: Do not expose system prompts in API responses. Mask in error messages
- **Vector/embedding weaknesses**: Validate embeddings before storage. Secure pgvector access via RLS
- **Unbounded consumption**: Rate limit LLM endpoints via Cloudflare AI Gateway. Set cost budgets per request

## Infrastructure
- All DOKS resources on private VPC. Databases never publicly exposed
- Cloudflare WAF geo-lock to US on all public endpoints
- Container images scanned for vulnerabilities before deployment (Trivy)
- Kubernetes secrets encrypted at rest. No secrets in manifests — use sealed secrets or external secrets operator
