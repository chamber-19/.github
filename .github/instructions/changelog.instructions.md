---
applyTo: "**/CHANGELOG.md"
---

# CHANGELOG — Chamber 19 format rules

These rules apply whenever you are writing or editing a `CHANGELOG.md` file. For the complete reference — release procedure, entry quality standards, and failure modes — read `docs/skills/CHANGELOG.md` in the `chamber-19/.github` repo when accessible.

## Non-negotiable

- **MUST** follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format: `## [Unreleased]` at top, versioned sections below
- **MUST** group `[Unreleased]` entries by date first: one `### YYYY-MM-DD` heading per day
- **MUST** use category subheadings (`#### Added`, `#### Changed`, etc.) under each date heading — not the other way around
- **MUST** reuse the existing day heading when adding another entry on the same day
- **MUST** use only the six standard categories: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`
- **MUST** wrap file paths, command names, and config keys in backticks
- **MUST** write entries in active voice, past tense — "added X", "renamed Y to Z"
- **MUST** keep each entry to one sentence
- **NEVER** add entries under a tagged version section — new entries always go under `[Unreleased]`
- **NEVER** use `Updated` as a category — use `Changed`
- **NEVER** append `[YYYY-MM-DD]` to a bullet — the `### YYYY-MM-DD` heading is the date; per-bullet date tags are the old format and must never appear alongside a date heading
- **NEVER** add per-entry date tags to versioned sections — the header date is sufficient

## Date convention

```markdown
### 2026-05-09

#### Added

- `docs/skills/CHANGELOG.md` — new changelog skill defining format and date rules.

#### Fixed

- `markdown_quality.yml` renamed to `markdown_quality.yaml`.
```

When promoting `[Unreleased]` to a versioned section, flatten the date-grouped blocks into standard KaC category sections (`### Added`, `### Changed`, etc.) and drop the date subheadings.
