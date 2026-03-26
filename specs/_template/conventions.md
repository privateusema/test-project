# Conventions: <Feature Name>

**Status:** Draft | Accepted
**Author:** Architect Agent
**Created:** YYYY-MM-DD
**Design:** `specs/<feature>/design.md`

---

## Instructions

This document tells the implementer **HOW** to build — patterns, structure, and testing approach. The design doc (`design.md`) tells them **WHAT** to build.

The architect fills this document during Phase 2, alongside `design.md`. Delete any section that does not apply to this feature's stack layers. Do not leave sections empty — either fill them or remove them.

The implementer reads this before writing any code. The reviewer uses it to verify conformance.

---

## Project Structure

Directory layout for code this feature introduces. For the first feature (MVP), this becomes the project skeleton — Task T1 scaffolds it.

```
<!-- Fill in the directory tree for this feature. Examples by stack:

Python backend only:
src/
  main.py              # FastAPI app entry, lifespan, middleware registration
  api/
    <domain>/
      router.py        # APIRouter for this domain
      schemas.py       # Pydantic request/response models
      service.py       # Business logic (no HTTP concerns)
  agents/              # LangGraph graphs and nodes (if applicable)
  db/
    client.py          # Supabase async client singleton (app.state)
    queries.py         # DB access functions
  core/
    config.py          # Settings via pydantic-settings BaseSettings
    exceptions.py      # AppException base class + handlers
    middleware.py      # Custom middleware (request ID, timing, logging)
tests/
  unit/
  integration/
  evals/               # LLM/agent evaluation tests (if applicable)

Full-stack (Python + Next.js):
src/                   # Python backend (structure above)
app/                   # Next.js App Router
  (auth)/              # Route group — unauthenticated pages
  (app)/               # Route group — authenticated pages
    <feature>/
      page.tsx         # Server Component (data fetching)
      layout.tsx
  components/
    ui/                # shadcn/ui primitives (do not modify)
    <feature>/         # Feature-specific components
  lib/
    actions.ts         # Server Actions (AI SDK streamText, etc.)
    hooks.ts           # Custom client hooks
  types.ts             # Shared TypeScript types
tests/
  unit/                # Vitest component + hook tests
  e2e/                 # Playwright end-to-end tests

Delete this comment block and replace with the actual tree. -->
```

---

## Backend Conventions

<!-- Delete this entire section if this feature has no backend code (L2 = No). -->

### Framework & Routing

<!-- e.g., FastAPI with APIRouter per domain. Each domain has its own router mounted in main.py. Use lifespan context manager (not @app.on_event) for startup/shutdown — initialize Supabase client, LangGraph checkpointer, and other singletons on app.state. -->

### Request / Response Patterns

<!-- e.g., Pydantic v2 models with ConfigDict(from_attributes=True, extra="forbid"). Use separate model classes per operation: CreateRequest, UpdateRequest, Response. Never reuse a single model for both input and output. Annotate all fields — no bare Any types. -->

### Error Handling

<!-- e.g., AppException base class with code (str), message (str), details (dict | None). Register handlers in main.py for:
  - AppException → HTTP status from exception
  - StarletteHTTPException → consistent JSON shape
  - RequestValidationError → 422 with field-level detail
All error responses use the shape: {"error": {"code": str, "message": str, "details": ...}}
Never expose stack traces or internal state in error responses. -->

### Middleware & Cross-Cutting Concerns

<!-- e.g., Middleware stack registered in this order (outermost to innermost):
  1. CORSMiddleware — must be outermost. With allow_credentials=True, origins must be explicit (no wildcards)
  2. TrustedHostMiddleware
  3. GZipMiddleware(minimum_size=1000)
  4. RequestIDMiddleware (custom) — generates UUID, attaches to request state and response header X-Request-ID
  5. TimingMiddleware (custom) — logs request duration via structlog
Note: FastAPI adds middleware in reverse order of app.add_middleware() calls — add CORS last so it wraps everything. -->

### Database Access Patterns

<!-- e.g., Supabase async client (acreate_client). ONE admin client initialized in lifespan, stored on app.state.supabase. For user-scoped operations, override Authorization header with user's JWT to enforce RLS. For direct pgvector similarity search or complex queries, use asyncpg directly via a connection pool (also on app.state). Never construct raw SQL with user-supplied values — use parameterized queries. -->

### Agent / LLM Patterns

<!-- Delete this subsection if this feature has no agent or LLM code.

e.g., LangGraph StateGraph with TypedDict state + Annotated[list, add_messages] reducers. Extend MessagesState for standard chat graphs. Use ToolNode(tools) prebuilt for tool execution. Checkpointer: AsyncPostgresSaver backed by Supabase Postgres (initialized in lifespan). Stream responses via graph.astream(stream_mode=["messages", "custom"], version="v2"). Bind tools to model with model.bind_tools(tools) — do not call tools manually. -->

### Logging

<!-- e.g., structlog with contextvars.merge_contextvars processor. JSON output in production, colored console in development. Bind request_id in RequestIDMiddleware so every log line within a request carries it. Redirect uvicorn access and error loggers through structlog. Use bound_logger = structlog.get_logger().bind(component="name") per module. -->

---

## Frontend Conventions

<!-- Delete this entire section if this feature has no frontend code (L1 = No). -->

### Framework & Routing

<!-- e.g., Next.js App Router. Route groups: (auth)/ for unauthenticated pages, (app)/ for authenticated. All components are Server Components by default — add "use client" only at the leaf level where interactivity is needed. Never make a parent layout a Client Component. -->

### Component Patterns

<!-- e.g., Server Components handle all data fetching and layout. Client Components handle interactivity, event handlers, and streaming state. File naming: kebab-case files (chat-input.tsx), PascalCase component exports. Co-locate component-specific styles and tests alongside the component file. Shared UI primitives live in app/components/ui/ (shadcn/ui — do not modify these). Feature-specific components live in app/components/<feature>/. -->

### State Management

<!-- e.g., Two-store pattern:
  - TanStack Query v5 for server state (fetching, caching, invalidation)
  - Zustand v5 for client-only UI state (panel open/closed, selections, ephemeral state)
  - AI SDK useChat manages chat and streaming state — do not duplicate in Zustand
  - React Hook Form + Zod for form state and validation
  Do NOT use Redux or React Context for global state. -->

### Styling Approach

<!-- e.g., Tailwind CSS v4 (CSS-only config via @theme in globals.css — no tailwind.config.js). shadcn/ui for component primitives. OKLCH color space for design tokens. Dark mode via next-themes with class strategy (class="dark" on <html>). Mobile-first: write base styles for mobile, override at sm(640px) md(768px) lg(1024px) xl(1280px). -->

### Data Fetching

<!-- e.g., AI SDK v6 preferred pattern: Server Actions with streamText() + toDataStream(). Client uses useChat({ api: serverAction }). UIMessage[] is the authoritative chat state — do not maintain a parallel messages array. For non-streaming data, use TanStack Query with Server Action or API route. Prefer Server Actions over API routes for mutations. -->

### Error & Loading States

<!-- All data-dependent components implement four states in this order:
  1. Loading — skeleton or spinner matching layout dimensions
  2. Error — user-facing message + retry action (never expose internal errors)
  3. Empty — explicit empty state (never show a blank screen)
  4. Success — the actual content
Use React Suspense + error boundaries at the route segment level for async Server Components. Use useChat's isLoading and error fields for chat/streaming states. -->

### Accessibility Requirements

<!-- WCAG 2.1 AA minimum. Key requirements for chat / streaming UIs:
  - Chat message container: role="log" aria-live="polite" aria-atomic="false"
  - Streaming text: aria-live="polite" aria-atomic="false" on the streaming container
  - Status messages (loading/processing): role="status"
  - Keyboard: Enter to send, Shift+Enter for newline, Escape to cancel in-flight stream
  - Color contrast: minimum 4.5:1 for normal text, 3:1 for large text (18px+ or 14px+ bold)
  - Focus management: return focus to input after send; trap focus in modals
  - All interactive elements reachable by keyboard (no mouse-only interactions)
  - Images: meaningful alt text; decorative images use alt="" -->

### Responsive Breakpoints

<!-- Default Tailwind v4 breakpoints (mobile-first):
  - base: < 640px (mobile)
  - sm: 640px (large mobile / small tablet)
  - md: 768px (tablet)
  - lg: 1024px (desktop)
  - xl: 1280px (large desktop)
  Document layout changes at each breakpoint for the main feature views. -->

---

## Testing Conventions

### Backend Testing

<!-- e.g., pytest + pytest-anyio (asyncio_mode = "auto" in pyproject.toml). HTTP tests via httpx AsyncClient with ASGITransport(app=app) — no real network. Use asgi-lifespan LifespanManager to trigger startup/shutdown events in tests. Mock LLM calls via AsyncMock on model.ainvoke or model.astream — never make real LLM calls in CI. Test LangGraph graphs with MemorySaver checkpointer (not AsyncPostgresSaver). Fixtures in tests/conftest.py — one app fixture, one db fixture, one client fixture. -->

### Frontend Testing

<!-- e.g., Vitest 3.x + React Testing Library for components and hooks. Playwright for E2E and for testing async Server Components. MSW (Mock Service Worker) for mocking API routes and Server Actions — do not make real network calls in component tests. axe-core (via @axe-core/react or vitest-axe) for automated accessibility checks in component tests. Test files co-located with components: chat-input.test.tsx alongside chat-input.tsx. E2E tests in tests/e2e/ targeting critical user flows. -->

### LLM / Agent Testing

<!-- Delete this subsection if no LLM or agent code.

e.g., DeepEval with AnswerRelevancyMetric(threshold=0.7) and FaithfulnessMetric(threshold=0.8). Baseline scores stored in tests/evals/baselines/ and committed to git — CI fails if scores regress below baseline. Use cached or mocked LLM responses for deterministic CI runs (real LLM calls only in manual eval runs). LangSmith evals for tracing and prompt quality — project configured via LANGCHAIN_PROJECT env var. -->

---

## Code Style & Linting

<!-- Fill in the project's linter, formatter, and any rules specific to this project.

Python examples:
  - ruff for linting and formatting (replaces flake8 + black + isort). Config in pyproject.toml.
  - mypy for type checking (strict mode). No bare Any — use explicit types.
  - Pre-commit hooks: ruff + mypy run on commit.
  - Docstrings: Google style for public functions. Internal helpers can omit.

TypeScript/Next.js examples:
  - ESLint with eslint-config-next. No unused variables. No explicit any.
  - Prettier for formatting (via eslint-prettier integration).
  - TypeScript strict mode (strict: true in tsconfig.json). No type assertions (as Type) without a comment explaining why.
  - Absolute imports via tsconfig paths: @/components, @/lib, @/types.

Delete this comment and fill in actual rules. -->

---

## Dependencies & Packages

<!-- Document how to add new dependencies and the pinning policy.

Examples:
  - To add a Python package: add to requirements.txt with a pinned version (==), run pip-compile to resolve transitive deps. Do not add packages without a task in tasks.md or an ADR.
  - To add an npm package: add with --exact flag (npm install --exact <package>). Packages go in dependencies (runtime) or devDependencies (build/test only) — do not mix.
  - No new dependencies without an entry in docs/adr/ if the package is a significant architectural choice.
  - Security: run pip-audit / npm audit before adding packages. Do not add packages with known HIGH CVEs.

Delete this comment and fill in the actual policy. -->
