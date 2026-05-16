# chamber-19/.github

This repository is the Chamber 19 org hub — shared AI configuration, skills,
documentation, and org-level automation all live here. There is no separate
org-maintenance repo; `.github` is org maintenance.

## What lives here

| Path | Purpose |
| --- | --- |
| `profile/README.md` | Org landing page rendered at github.com/chamber-19 |
| `AGENTS.md` | Top-level pointer for AI agents — directs to the canonical instruction files |
| `CHANGELOG.md` | Release log for this org-config repo — every PR updates it (Keep a Changelog format) |
| `.github/copilot-instructions.md` | Family-wide AI guidance — loads automatically alongside every repo's own file |
| `.github/instructions/` | Path-scoped instruction files with `applyTo:` frontmatter — load automatically when matching file types are touched |
| `.github/prompts/` | Reusable agent prompt files for common multi-step tasks |
| `.github/workflows/` | Org-level GitHub Actions workflows — propagation, family-table reconcile, lint, Biome auto-fix, Tailwind canonicalization, reusable setup steps |
| `docs/skills/` | Deep technical reference for each technology in the stack — read before making changes in a given language |
| `docs/evals/` | YAML eval specs for testing AI instruction compliance cold |
| `docs/memory.md` | Org-wide institutional memory — incidents, compatibility traps, and closed decisions with evidence |
| `docs/pilots.md` | Pre-written success criteria for Copilot feature pilots |
| `scripts/` | Org-config and maintenance scripts — `reconcile-family-table.ps1`, `lint-org-config.ps1`, `family-manifest.yml`, `fix-biome.sh`, `fix-tailwind-canonical-vars.mjs`, `foundry-pr-trigger.yml` (copy into consumer `.github/workflows/` to enable Foundry review) |

## How inheritance works

GitHub loads the org-level `.github/copilot-instructions.md` automatically
alongside each consumer repo's own `.github/copilot-instructions.md`. Both
apply. Repo-specific rules win on conflict.

This means:

- The org file should hold only family-wide rules
- Repo-specific rules belong in each repo's own file
- Path-scoped instruction files in `.github/instructions/` apply org-wide
  to matching file types across all repos

## Skills

Two kinds of skills live in this repo:

**Technology skills** (`docs/skills/`) — deep reference for each stack technology, referenced by instruction files and `AGENTS.md` files across the org. Read the relevant skill before making changes:

| Skill | When to read |
| --- | --- |
| `TAURI.MD` | Tauri commands, IPC, sidecars, events, packaging |
| `RUST.MD` | Any Rust — commands, error handling, async |
| `PYTHON.md` | Python sidecars, automation, ML pipelines |
| `AUTOCAD_DOTNET.md` | AutoCAD .NET plugins, transactions, attributes |
| `AUTOCAD_ASSISTANT.md` | Autodesk Assistant queries, MCP client patterns |
| `VBA_EXCEL.md` | VBA macros for IFA-IFC-Checklist |
| `MARKDOWN.md` | Any `.md` file in the org |
| `CSS_DISCIPLINE.md` | Any CSS/SCSS/Sass/Less or inline style object work |
| `UI_UX_DISCIPLINE.md` | Any UI-facing change (components, copy, layouts, accessibility behavior) |
| `DOCX.md` | Word document generation (transmittal-builder) |
| `BIOME.md` | TypeScript/JavaScript linting and formatting in frontend repos |
| `CHANGELOG.md` | Writing or updating any `CHANGELOG.md` — format, date convention, categories, release procedure |
| `POWERSHELL.md` | Writing or reviewing PowerShell scripts — approved verbs, parameter design, error handling, `PowerShellForGitHub` |

> Note: `TAURI.MD` and `RUST.MD` use uppercase `.MD` extensions; the rest use `.md`. A coordinated rename to lowercase is pending — it touches 12 references across consumer repos' `copilot-instructions.md` files.

**Methodology skills** (`docs/skills/`) — foundational skills that shape how we work on the org itself:

| Skill | When to read |
| --- | --- |
| `acquire-codebase-knowledge/SKILL.md` | Mapping a repo, producing `docs/codebase/` documentation, onboarding |
| `AI_READY.md` | Making any repo AI-ready — generates `AGENTS.md`, `copilot-instructions.md`, CI, issue templates |

## Contributing

Changes here propagate immediately to every repo in the org. Treat updates
with the same care as a `desktop-toolkit` framework change — review
carefully, test mentally against each consumer's existing rules, and prefer
additive changes over breaking ones.

When you find an incident, compatibility trap, or closed decision in any
repo, add an entry to `docs/memory.md` with evidence before the context
is lost.
