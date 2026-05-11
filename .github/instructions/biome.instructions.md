---
applyTo: "**/*.{ts,tsx,js,jsx}"
---

# Biome — Chamber 19 lint and format rules

These rules apply when writing or editing TypeScript and JavaScript files in Chamber 19 frontend repos (`launcher`, `block-library`, `desktop-toolkit` frontend). For the complete reference — rule governance, suppression policy, org-wide workflows, and the incremental adoption strategy — read `docs/skills/BIOME.md` in the `chamber-19/.github` repo when accessible.

## Scope

Biome applies to JS/TS frontends only. Do not apply these rules to Python backends, Rust shells, C# plugins, or VBA files.

## Non-negotiable

- **MUST** run `npm run lint` before opening a PR — lint errors block merge
- **MUST** run `npm run build` before opening a PR — build failures block merge
- **MUST** use the standard script names: `lint`, `lint:fix`, `format` — do not invent alternatives
- **MUST** include a justification comment and tracking reference on any suppression — never suppress silently
- **MUST** suppress the smallest possible scope — never file-wide or directory-wide without architecture review
- **NEVER** push directly to `main` with unreviewed auto-fixes — always via PR
- **NEVER** add a `biome-ignore` comment without an explanation of why and a follow-up reference
