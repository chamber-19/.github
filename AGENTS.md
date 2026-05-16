# AGENTS — Chamber 19 org-config repo

Top-level pointer for any AI agent working on this repo. The canonical instruction set is `.github/copilot-instructions.md` plus the path-scoped wrappers in `.github/instructions/`.

## Read first

Before any change to this repo, read:

1. `.github/copilot-instructions.md` — family-wide rules (loads automatically in every chamber-19 repo, plus this one)
2. `CHANGELOG.md` — recent changes; **every PR to this repo MUST add an entry**
3. `README.md` — what lives where in this repo
4. The matching `.github/instructions/<topic>.instructions.md` for the file type you're editing

## Repo scope

This repo (`chamber-19/.github`) holds:

- Org-wide AI guidance and instructions
- Skill files and their wrappers
- Org-level GitHub Actions workflows
- Family manifest and reconciliation scripts
- Public org profile

It does **not** hold consumer-app code. App code lives in dedicated repos (`launcher`, `desktop-toolkit`, `Transmittal-Builder`, etc. — see the family table in `.github/copilot-instructions.md`).

## Hard rules for this repo specifically

- **MUST** add a `CHANGELOG.md` entry for every PR — under the `## [Unreleased]` heading, in the appropriate category (`Added` / `Changed` / `Deprecated` / `Removed` / `Fixed` / `Security`). Use Keep a Changelog format.
- **MUST** keep the family table inside `<!-- family-table:start -->` ... `<!-- family-table:end -->` markers as a single table. The reconcile script regenerates this block; never hand-edit if you can run the script instead.
- **MUST** keep instruction wrappers in `.github/instructions/` thin (under 3 KB) — they load via `applyTo:` and reference the deep skill in `docs/skills/`.
- **NEVER** edit submodule content (`docs/skills/tauri2-skills/`, `docs/skills/threejs-skills/`) — those are external. Update the submodule pointer instead.
- **NEVER** add a skill in `docs/skills/` without also adding the matching wrapper in `.github/instructions/` and the row in the skills registry table in `.github/copilot-instructions.md`.

## Methodology

This repo's housekeeping uses two foundational skills:

- `docs/skills/acquire-codebase-knowledge/SKILL.md` — scan-then-document discipline for any repo audit. Drives the `docs/codebase/` template set.
- `docs/skills/AI_READY.md` — pointer to John Papa's `ai-ready` skill for verifying any repo has the AI-discoverable artifact set (`AGENTS.md`, `copilot-instructions.md`, CI, issue templates, CHANGELOG).

Additional skills are promoted into `docs/skills/` over time through normal repo PR workflow.

## When in doubt

1. Check `docs/memory.md` — institutional memory of incidents and closed decisions.
2. Check open issues/PRs in this repo for current execution context.
3. Ask the user — direct, specific questions, not open-ended ones.
