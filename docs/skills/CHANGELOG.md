# CHANGELOG Skill

Read this skill when writing, reviewing, or updating any `CHANGELOG.md` file across Chamber 19 repos. It defines the format, Chamber 19 date convention, category rules, entry quality standards, and the release procedure.

---

## markdownlint disable comment — required

Every Chamber 19 `CHANGELOG.md` **must** have this as its very first line:

```markdown
<!-- markdownlint-disable MD024 -->
```

MD024 flags duplicate heading text. CHANGELOGs necessarily repeat `### Added`, `### Changed`, etc. across every version section — this is intentional and correct. The disable comment suppresses the false positive across the whole file.

**When editing any CHANGELOG:** check that this comment is present on line 1. If it is missing, add it before making any other changes.

---

## Format baseline — Keep a Changelog

Chamber 19 CHANGELOGs follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) with one Chamber 19 extension: entries in `[Unreleased]` are grouped by **date first, then category**. The date appears **once** as a `###` heading; categories (`#### Added`, `#### Changed`, etc.) appear under it. Inline per-bullet dates (`[2026-05-09]` at the end of a line) are the **old format** — do not use them.

```markdown
<!-- markdownlint-disable MD024 -->

# Changelog — <repo name>

One-sentence description of what this changelog covers.

## [Unreleased]

### 2026-05-09

#### Added

- New thing added.
- Second thing added on the same day — shares the same date heading.

#### Changed

- Existing thing changed.

---

## [1.0.0] - 2026-04-01

### Added

- Initial release.
```

---

## Chamber 19 date convention

Standard KaC only dates released version sections. The `[Unreleased]` section has no date by definition — which makes it hard to see when an entry was made without reading git history.

**Convention:** Date is the primary grouping. Use one `### YYYY-MM-DD` heading per day in `[Unreleased]`. Under each date, use `#### Added`, `#### Changed`, `#### Removed`, `#### Fixed`, `#### Security` as needed. Do not repeat the date under each category.

```markdown
### 2026-05-09

#### Added

- `docs/skills/CHANGELOG.md` — new skill defining changelog format and date convention.
- `AGENTS.md` at the repo root — top-level pointer for AI agents.

#### Fixed

- `markdown_quality.yml` renamed to `markdown_quality.yaml` to match extension convention.
```

This puts all work from a given day in one block, eliminating repeated date headings across categories.

**On release:** when `[Unreleased]` is promoted to a versioned section, flatten the date-grouped blocks into standard KaC category sections (`### Added`, `### Changed`, etc.) and drop the date subheadings — the version header date is sufficient.

**Existing entries without dates:** do not retrofit. Git history is the authoritative timestamp for older entries. Apply the convention to all new entries from the point the skill is adopted.

**NEVER use both a `### YYYY-MM-DD` heading AND a `[YYYY-MM-DD]` per-bullet tag on the same entry.** The heading is the date. Using both causes conflicting edits between agents — one removes headings (old format), one adds them (new format).

---

## Categories

Under each `### YYYY-MM-DD` date heading, use exactly these category subheadings (`####`), in this order, omitting any that have no entries:

| Category | Use for |
| --- | --- |
| `Added` | New files, features, skills, commands, or configuration |
| `Changed` | Modifications to existing files or behaviour |
| `Deprecated` | Things being phased out — still present but flagged |
| `Removed` | Deleted files, features, or configuration |
| `Fixed` | Bug fixes, naming corrections, broken references |
| `Security` | Anything affecting secrets, permissions, or attack surface |

Do not invent new categories. Do not use `Updated` — that is `Changed`.

---

## Writing good entries

### Required elements

Each entry is a single bullet. It must contain:

1. **What changed** — the file path or feature name, in backticks
2. **What was done to it** — one clause describing the change
3. **Why, if non-obvious** — a brief rationale when the change is not self-evident from the description
4. **The day group** — entry must be placed under the correct `### YYYY-MM-DD` heading in `[Unreleased]`; omitted in versioned sections unless intentionally retained for readability

### Length

One sentence maximum per bullet. If the change requires more than one sentence to describe, use a dash-separated compound description — but do not split into multiple lines or add sub-bullets.

### Paths in backticks

Always wrap file paths, directory names, command names, and configuration keys in backticks.

```markdown
# Good
### 2026-05-09

- `docs/skills/MARKDOWN.md` — added `## Accessibility` section covering alt text and emoji rules.

# Bad
- Updated the MARKDOWN skill file to add accessibility content
```

### Active voice

Write entries as past-tense statements of fact, not as passive descriptions.

```markdown
# Good
### 2026-05-09

- `AGENTS.md` — added repo-root pointer for AI agents.

# Bad
- An AGENTS.md file was added to the repo root as a pointer for AI agents.
```

### No marketing language

No "improved", "enhanced", "streamlined", or "powerful". State what changed.

---

## Per-repo requirements

The following repos have a hard MUST on CHANGELOG entries per PR:

- `chamber-19/.github` — every PR must add an entry under `## [Unreleased]`

For all other repos: add an entry when a PR changes user-visible behaviour, public API, configuration, CI/CD, or documentation. Skip for trivial fixes like typo corrections in comments.

When in doubt: add the entry. It costs one line; missing it costs future debugging time.

---

## Release procedure

When cutting a release for a repo that uses this CHANGELOG:

1. Rename `## [Unreleased]` to `## [vX.Y.Z] - YYYY-MM-DD`.
2. Flatten date-grouped bullets into normal category bullets for the release notes unless day-level grouping adds clear value.
3. Add a new empty `## [Unreleased]` section above the version section, with all category subheadings ready.
4. Commit the CHANGELOG update in the same commit as the version bump.
5. Create a GitHub Release and paste the new version section body as the release notes.

```markdown
## [Unreleased]

### Added

#### YYYY-MM-DD

### Changed

#### YYYY-MM-DD

### Fixed

#### YYYY-MM-DD

---

## [1.2.0] - 2026-05-09

### Added

- `docs/skills/CHANGELOG.md` — new changelog skill.

### Changed

...
```

---

## Failure modes

| Symptom | Fix |
| --- | --- |
| Entry has no file path or feature name | Add the path or name in backticks — entries without anchors are not searchable |
| Entry is passive voice | Rewrite as active: "renamed X to Y", "added Y to Z" |
| Entry spans multiple sentences | Compress into one compound sentence or split into separate bullets |
| Missing date grouping on `[Unreleased]` entry | Add or reuse `### YYYY-MM-DD` and place the bullet under it |
| New category invented (e.g. `Updated`) | Rename to the correct KaC category |
| Date repeated on each bullet for the same day | Keep one `### YYYY-MM-DD` subheading and remove duplicated per-bullet dates |
| Entry has BOTH a `### YYYY-MM-DD` subheading AND a `[YYYY-MM-DD]` per-bullet tag | Remove the per-bullet tag — the subheading is the authoritative date; per-bullet dates are the old format and must never appear alongside a date subheading |
| Versioned section has per-entry dates | Strip per-bullet dates — the header date is sufficient |
