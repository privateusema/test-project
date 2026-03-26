---
paths:
  - "src/**"
  - "app/**"
  - "tests/**"
---

# Testing Requirements

## Deterministic Code (API routes, data transforms, utilities)
- Standard pytest coverage — aim for 80%+ on touched files
- Write tests alongside implementation, not after
- No task is complete without tests exercising its acceptance criteria

## LLM Interaction Code (prompts, chains, agents)
- Place evaluation tests in `tests/evals/`
- Use DeepEval metrics: faithfulness > 0.8, relevancy > 0.7, hallucination < 0.2
- Maintain baseline scores in `tests/evals/baselines/`
- Use cached/mocked LLM responses for deterministic CI runs

## RAG Pipelines
- Test contextual precision and recall with defined thresholds
- Hybrid search (keyword + semantic) must be tested independently and combined

## Frontend Code (components, pages, hooks)
- Component tests with Testing Library (or equivalent from conventions.md)
- E2E tests for critical user flows with Playwright (or equivalent from conventions.md)
- Accessibility testing: automated axe-core checks in component tests
- Visual regression: optional, per conventions.md

## Before Marking a Task Complete
1. Run the full test suite: `pytest`
2. Verify no regressions in previously passing tests
3. If modifying agent/RAG code, run evals: `pytest tests/evals/ -m eval`
4. Ensure test coverage has not decreased on touched files
