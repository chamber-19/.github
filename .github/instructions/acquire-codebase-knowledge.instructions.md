---
applyTo: "**/docs/codebase/**"
---

# Acquire Codebase Knowledge — Chamber 19 rules

These rules apply when creating or editing files inside a `docs/codebase/` directory — the output folder produced by the `acquire-codebase-knowledge` skill. For the complete workflow — scan script, per-template investigation questions, validation loop, and output contract — read `docs/skills/acquire-codebase-knowledge/SKILL.md` in the `chamber-19/.github` repo when accessible.

## Non-negotiable

- **MUST** produce exactly seven documents: `STACK.md`, `STRUCTURE.md`, `ARCHITECTURE.md`, `CONVENTIONS.md`, `INTEGRATIONS.md`, `TESTING.md`, `CONCERNS.md`
- **MUST** mark unknowns as `[TODO]` — never infer or assume facts not traceable to a file or terminal output
- **MUST** mark team-intent gaps as `[ASK USER]`
- **MUST** include at least one evidence reference (concrete file path) per non-trivial claim
- **MUST** run the scan script (`docs/skills/acquire-codebase-knowledge/scripts/scan.py`) first in Phase 1 before reading any source code
- **NEVER** document patterns from `dist/`, `build/`, `generated/`, `.next/`, `__pycache__/` — source files only
- **NEVER** copy README claims as facts — cross-reference with actual file structure before documenting

## Workflow phases

1. **Phase 1** — Run scan, read intent documents (`PRD`, `README`, `ROADMAP`)
2. **Phase 2** — Investigate each area using `references/inquiry-checkpoints.md`
3. **Phase 3** — Populate all seven templates from `assets/templates/`
4. **Phase 4** — Validate every doc, list all `[ASK USER]` items, flag intent vs. reality divergences
