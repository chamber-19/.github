# Architecture

This repository uses a documentation-and-automation architecture where policy source files are linted and propagated through scripts and GitHub Actions workflows.

## Core Sections (Required)

### 1) Architectural Style

- Primary style: layered maintenance repository (policy layer + automation layer + publication layer)
- Why this classification: policy content lives in `docs/skills/` and `.github/instructions/`, while execution logic lives in `scripts/` and `.github/workflows/`
- Primary constraints: every PR must update `CHANGELOG.md`; family-table blocks are generated from `scripts/family-manifest.yml`; wrapper files must stay thin and point to deep skills

### 2) System Flow

```text
Repo change -> lint scripts/workflows validate rules -> reconcile scripts regenerate managed table blocks -> docs/profile content published via repository state
```

Flow steps:

1. Contributors edit policy and automation files in `.github/`, `docs/`, and `scripts/`.
2. Workflows such as `lint-org-config.yml` and `lint-yaml.yml` validate syntax and policy compliance.
3. `scripts/reconcile-family-table.ps1` reads `scripts/family-manifest.yml`, validates live GitHub metadata, and rewrites managed table blocks.
4. `profile/README.md` and `.github/copilot-instructions.md` serve as published outputs consumed by humans and AI tooling.

### 3) Layer/Module Responsibilities

| Layer or module | Owns | Must not own | Evidence |
| --- | --- | --- | --- |
| Policy content (`docs/skills/`, `.github/instructions/`) | Human- and agent-readable rules | Runtime product behavior | `docs/skills/MARKDOWN.md`, `.github/instructions/markdown.instructions.md` |
| Maintenance scripts (`scripts/`) | Deterministic reconciliation and lint checks | Interactive app features | `scripts/reconcile-family-table.ps1`, `scripts/lint-org-config.ps1` |
| Workflow layer (`.github/workflows/`) | Scheduling and CI orchestration | Long-term state storage | `.github/workflows/reconcile-family-table.yml` |

### 4) Reused Patterns

| Pattern | Where found | Why it exists |
| --- | --- | --- |
| Managed marker block replacement | `scripts/reconcile-family-table.ps1`, `.github/workflows/auto-pr-body-and-labels.yml` | Safe regeneration of deterministic sections without rewriting unrelated content |
| Thin-wrapper + deep-skill split | `.github/instructions/*.instructions.md` and `docs/skills/*.md` | Keep auto-injected guidance lightweight while preserving full reference docs |
| Validate-then-write flow | `scripts/reconcile-family-table.ps1` | Prevent drift and catch manifest errors before mutating target files |

### 5) Known Architectural Risks

- Managed-output files can drift when manifest and hand-edited docs diverge.
- Workflow logic can break in reusable (`workflow_call`) mode if scripts are assumed to exist in caller repos.

### 6) Evidence

- `.github/workflows/auto-pr-body-and-labels.yml`
- `scripts/reconcile-family-table.ps1`
- `scripts/family-manifest.yml`
