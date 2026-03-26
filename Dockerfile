# ── Multi-stage Dockerfile ────────────────────────────────────────────────────
# Two variants are provided below. Uncomment the one that matches your project.
# Default: Python (FastAPI + uvicorn)
# Alternative: Node.js (Next.js)
# ─────────────────────────────────────────────────────────────────────────────

# ══ Python variant (FastAPI) — DEFAULT ═══════════════════════════════════════

FROM python:3.14-slim AS builder

WORKDIR /app

# Install into a virtual env at a fixed path so the COPY below
# does not depend on the Python minor-version directory name.
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

FROM python:3.14-slim AS runtime

WORKDIR /app

# Copy virtual env from builder (version-independent path)
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application source
COPY src/ ./src/

# Run as non-root user
RUN useradd --create-home appuser && \
    chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]


# ══ Node.js variant (Next.js) — UNCOMMENT TO USE ═════════════════════════════

# FROM node:22-slim AS deps
# WORKDIR /app
# COPY package.json package-lock.json ./
# RUN npm ci
#
# FROM node:22-slim AS builder
# WORKDIR /app
# COPY --from=deps /app/node_modules ./node_modules
# COPY . .
# RUN npm run build
#
# FROM node:22-slim AS runtime
# WORKDIR /app
# ENV NODE_ENV=production
# COPY --from=builder /app/.next/standalone ./
# COPY --from=builder /app/.next/static ./.next/static
# COPY --from=builder /app/public ./public
# RUN useradd --create-home appuser
# USER appuser
# EXPOSE 3000
# CMD ["node", "server.js"]
