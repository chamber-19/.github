---
applyTo: "**/AGENTS.md"
---

# AI Ready — Chamber 19 rules

These rules apply when creating or editing `AGENTS.md` files. For the full workflow — artifact checklist, PR pattern mining, and CI configuration — read `docs/skills/AI_READY.md` in the `chamber-19/.github` repo when accessible.

## Non-negotiable

- **MUST** place `AGENTS.md` at the repo root — never nested inside a subdirectory
- **MUST** direct agents to all instruction and skill files relevant to the repo
- **MUST** document hard rules that apply regardless of which agent reads the file — language conventions, forbidden actions, required checks
- **MUST** keep content permanent and repo-scoped — no task-specific, session-specific, or ephemeral state
- **NEVER** embed secrets, credentials, or machine-specific paths in `AGENTS.md`
- **NEVER** duplicate content already in `copilot-instructions.md` — `AGENTS.md` complements it, not copies it
