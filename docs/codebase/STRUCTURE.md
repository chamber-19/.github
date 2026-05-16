# Codebase Structure

This document maps the repository layout and identifies the operational entry points used to maintain Chamber 19 org-wide AI guidance and automation.

## Core Sections (Required)

### 1) Top-Level Map

List only meaningful top-level directories and files.

| Path | Purpose | Evidence |
| --- | --- | --- |
| `.github/` | Org-level instructions, prompts, templates, and workflows | `.github/copilot-instructions.md`, `.github/workflows/` |
| `docs/skills/` | Deep skill references consumed by instruction wrappers | `docs/skills/CHANGELOG.md`, `docs/skills/POWERSHELL.md` |
| `docs/codebase/` | Generated codebase-knowledge outputs for this repo | `docs/codebase/.codebase-scan.txt` |
| `scripts/` | Maintenance and lint scripts for org config | `scripts/lint-org-config.ps1`, `scripts/reconcile-family-table.ps1` |
| `profile/` | Public org profile README rendered on GitHub | `profile/README.md` |
| `AGENTS.md` | Repo-scoped pointer and hard rules for agents | `AGENTS.md` |
| `CHANGELOG.md` | Keep a Changelog history for this repo | `CHANGELOG.md` |

### 2) Entry Points

- Main runtime entry: GitHub Actions workflows in `.github/workflows/`
- Secondary entry points (worker/cli/jobs): PowerShell maintenance scripts in `scripts/`
- How entry is selected (script/config): workflows are event-triggered via `on:` blocks; scripts are called directly or by workflows

### 3) Module Boundaries

| Boundary | What belongs here | What must not be here |
| --- | --- | --- |
| `.github/instructions/` | Thin path-scoped wrappers with `applyTo` and hard MUST/NEVER rules | Deep implementation guidance duplicated from `docs/skills/` |
| `docs/skills/` | Canonical deep skill content per domain | Repo-local ephemeral task logs |
| `.github/workflows/` | CI automation and maintenance orchestration | Consumer-repo app business logic |
| `scripts/` | Reusable repo-maintenance scripts | Unrelated product code |

### 4) Naming and Organization Rules

- File naming pattern: kebab-case for most `.md` and workflow files; uppercase `.MD` is legacy for some skills (`RUST.MD`, `TAURI.MD`)
- Directory organization pattern: function-based grouping (`docs/`, `scripts/`, `.github/workflows/`, `.github/instructions/`)
- Import aliasing or path conventions: `[TODO]` (not applicable for this repo's current script mix)

### 5) Evidence

- `docs/codebase/.codebase-scan.txt`
- `.github/workflows/lint-org-config.yml`
- `scripts/reconcile-family-table.ps1`
