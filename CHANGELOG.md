<!-- markdownlint-disable MD024 -->

# Changelog — `chamber-19/.github`

All notable changes to this repo are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this repo adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) for any tagged releases.

**Every PR to this repo MUST add an entry under `## [Unreleased]` in the matching category.** This is enforced via `.github/copilot-instructions.md` and `AGENTS.md`. Categories: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.

## [Unreleased]

> **Format:** New entries use date-first grouping — `### YYYY-MM-DD` at top, then `#### Added` / `#### Changed` / etc. under it. Older entries below use the legacy category-first format and are not being retrofitted.

### 2026-05-16

#### Fixed

- `.github/workflows/fix-biome.yml` — replaced `printf` with heredoc to eliminate SC2016 (backtick in single-quoted string).
- `.github/workflows/fix-tailwind-canonical-vars.yml` — replaced `printf` with heredoc to eliminate SC2016 (backtick in single-quoted strings, three occurrences).
- `.github/workflows/lint-yaml.yml` — replaced unquoted `$(find ...)` with `mapfile` array to eliminate SC2046 (word splitting).

### 2026-05-10

#### Added

- `docs/skills/POWERSHELL.md` — automatic variable section added (covers `$Matches`, `$Error`, `$Args`; explains that assigning to automatic variables may overwrite runtime state).
- `.github/workflows/lint-yaml.yml` — new workflow running `yamllint` and `actionlint` on all `.yml`/`.yaml` files on push, PR, and `workflow_dispatch`.

#### Changed

- `.github/workflows/fix-tailwind-canonical-vars.yml` and `.github/workflows/fix-biome.yml` — renamed `ORG_MAINTENANCE_APP_ID`/`ORG_MAINTENANCE_APP_PRIVATE_KEY` secrets to `ORG_BOT_APP_ID`/`ORG_BOT_APP_PRIVATE_KEY`; updated git user from `chamber-19-org-maintenance[bot]` to `chamber-19[bot]` to reflect org-maintenance consolidation.
- `docs/skills/CHANGELOG.md` — date convention changed to date-first grouping: `### YYYY-MM-DD` is now the primary heading in `[Unreleased]`, with `#### Added` / `#### Changed` / etc. as subheadings under it; eliminates the repeated-date problem entirely.
- `.github/instructions/changelog.instructions.md` — rewritten to match the date-first format; MUST rules updated to reflect `### YYYY-MM-DD > #### Category` structure.
- `docs/skills/POWERSHELL.md` — added `$Matches` automatic variable warning and failure mode row.
- `docs/skills/MARKDOWN.md` — added `### Table column count must be consistent` rule with good/bad examples; added two matching rows to the failure modes table.
- `docs/skills/AI_READY.md` — added blank lines around fenced code block at step 2 (blanks-around-fences fix).
- `.github/prompts/release-bump.prompt.md` — removed deprecated `mode: agent` frontmatter key; `description` field retained.
- `.github/prompts/consume-toolkit-bump.prompt.md` — removed deprecated `mode: agent` frontmatter key; `description` field retained.
- `docs/memory.md` — rewritten with proper Markdown structure: `#` title, purpose statement, status convention (`[Active]`/`[Promoted]`/`[Deprecated]`), each incident as a `###` heading with bold fields, compatibility traps as a table, closed decisions as a table, recurring traps as a list, and a memory lifecycle section documenting the handoff boundary between Auto Memory and `docs/memory.md`.
- `AGENTS.md` and `docs/skills/BIOME.md` — replaced stale `org-maintenance/IMPLEMENTATION_PLAN.md` references with the workspace-level `IMPLEMENTATION_PLAN.md` and corrected methodology skill paths to `docs/skills/...`.
- `profile/README.md` family table — updated `transmittal-builder`, `Drawing-List-Manager`, and `batch-fnr` to backend-service roles; retained `block-library` as UI-first exception; replaced the `.github` TODO row with a concrete org-hub description.
- `docs/skills/CHANGELOG.md` — corrected the day-group rule to reference `### YYYY-MM-DD` headings (not `####`).

#### Fixed

- `scripts/lint-org-config.ps1` — renamed `$matches` → `$skillMatches` to avoid assigning to the `$Matches` automatic variable, eliminating a PSScriptAnalyzer warning.

### Added

#### 2026-05-10

- `docs/skills/POWERSHELL.md` — new deep skill defining approved verbs, parameter design, pipeline patterns, error handling, `PowerShellForGitHub` integration, the `ConvertFrom-YamlCompat` YAML shim, and Chamber 19 specifics for `.github/scripts/`.
- `.claude/commands/powershell.md` — `/powershell` slash command paired with the new POWERSHELL.md skill.

- `.github/workflows/auto-pr-body-and-labels.yml` — new pull-request workflow that auto-generates PR body content from changed files on open/sync/edit, supports opt-out marker (`<!-- auto-pr:off -->`), and applies path-based labels plus a size label when matching repo labels exist.
- `docs/skills/CHANGELOG.md` — new skill defining KaC format, the per-entry `[YYYY-MM-DD]` date convention, category rules, entry quality standards, and release procedure. [2026-05-09]
- `docs/skills/BIOME.md` — new skill for Biome lint and format rules, scoped to Chamber 19 JS/TS frontends (`launcher`, `block-library`, `desktop-toolkit`); covers local workflow, PR policy, suppression rules, org-maintenance workflow templates (planned, not yet wired), and incremental adoption strategy. Adapted from an earlier Glyphic-context manual — all project-specific references removed. [2026-05-09]
- `.github/instructions/changelog.instructions.md` — thin wrapper (`applyTo: **/CHANGELOG.md`) enforcing the date convention and category rules whenever a CHANGELOG file is edited. [2026-05-09]
- `.github/instructions/biome.instructions.md` — thin wrapper (`applyTo: **/*.{ts,tsx,js,jsx}`) enforcing Biome lint-before-PR rule and suppression policy on all TS/JS files. [2026-05-09]
- `.claude/commands/changelog.md` — `/changelog` command paired with the CHANGELOG skill. [2026-05-09]

### Removed (legacy entries)

- `.github/prompts/refactor-template.prompt.md` — deleted as a duplicate of `refactor-desktop-to-backend-service.prompt.md`; all content (checklist, cross-repo update list, pitfalls, testing protocol) is covered in the main guide's Parts 1–7 and Validation Checklist. [2026-05-09]
- `.claude/commands/biome.md` — `/biome` command paired with the BIOME skill. [2026-05-09]
- `AGENTS.md` at the repo root — top-level pointer for AI agents, names the canonical instruction files and the hard rules specific to this repo.
- `CHANGELOG.md` (this file) — Keep a Changelog format. Every PR is now required to add an entry.
- `skills/` — methodology skill folder seeded with `acquire-codebase-knowledge` (scan-then-document discipline) and `ai-ready` (AI-readiness checklist). These are the foundation; more skills get promoted in over time per `org-maintenance/IMPLEMENTATION_PLAN.md` Phase 6.
- `chamber-19-autocad-mcp` row added to the family table in `.github/copilot-instructions.md` (it was only in the duplicate table that's now deleted).
- README.md "What lives here" table now lists `AGENTS.md`, `CHANGELOG.md`, `.github/scripts/`, `.github/workflows/`, `skills/`, `scripts/`, and `workflow-templates/`.
- README.md skills section now lists `AUTOCAD_ASSISTANT.md` and the methodology skills under `skills/`.

### Changed

#### 2026-05-10

- `docs/skills/CHANGELOG.md` and `.github/instructions/changelog.instructions.md` — updated changelog date rules to one date heading per day (no repeated same-day per-bullet date tags).
- `.github/PULL_REQUEST_TEMPLATE.md` — simplified to an auto-managed format (`What changed`, `Why`, `Verification`, `Linked issue`) intended to be filled by workflow output instead of manual checklist-heavy authoring.
- `.github/ISSUE_TEMPLATE/general_issue_task.yml` — removed Copilot-task framing from template text to keep issue intake neutral and simpler for regular work.
- `.claude/commands/` — new project-level Claude Code slash commands mirroring all eight skills in `.github/docs/skills/` (`markdown`, `python`, `rust`, `tauri`, `vba-excel`, `autocad-dotnet`, `docx`, `autocad-assistant`) plus the two methodology skills (`acquire-codebase-knowledge`, `ai-ready`) and `add-to-learning`. Parity rule added to `CLAUDE.md`: adding a command requires notifying the user to add a matching `.github` skill, and vice versa. [2026-05-09]
- `learning/SKILL.md` — skill reference for the learning folder: trigger conditions, check-before-create rule, concept note format, naming rules, update discipline, graduation path to org skills, and a section directing agents to check `potential-future-skills/` when a new skill pattern emerges.
- `learning/AGENTS.md` — updated to reference `SKILL.md` as the primary guidance document; tightened the rules list to match the skill.
- `.github/prompts/add-to-learning.prompt.md` — new invokable Copilot skill (adapted from `add-educational-comments` pattern) for capturing concept explanations as permanent reference notes in `learning/concepts/`. Checks for existing notes before creating; updates rather than duplicates.
- `.github/instructions/learning.instructions.md` — new thin wrapper (`applyTo: learning/**`) enforcing concept note format, naming rules, and the search-before-create rule whenever files inside the learning folder are edited.
- `docs/skills/MARKDOWN.md` — added `## Accessibility` section covering image alt text rules, emoji screen reader behaviour, bold/italic not announced by screen readers, links not opening new tabs, and multimedia captions; added three accessibility items to the pre-commit checklist. Content folded in from `skills-tools-agenticflows/markdown-accessibility.instructions.md` (duplicate rules omitted).
- `.github/instructions/markdown.instructions.md` — reframed the skill-file pointer from "read this first" to "these rules are the enforced minimum; the skill has the complete reference." Removes the implication that the wrapper is just a redirect; the wrapper is now authoritative on its own.
- `.github/prompts/refactor-desktop-to-backend-service.prompt.md` — three corrections: (1) removed Docker/Kubernetes from `docs/DEPLOYMENT.md` template (chamber-19 backends are launcher-managed on local machines, not containerised); (2) rewrote the "Update MARKDOWN.md" checklist item so agents apply the skill rather than edit the canonical skill file; (3) removed `E2E_CLEANUP_SUMMARY.md` from the reference implementation list — CHANGELOG is the canonical change record, separate summary docs are not created.
- `profile/README.md` family table updated to reflect the May 2026 refactor: `transmittal-builder`, `Drawing-List-Manager`, `batch-fnr` are now described as backend services (not standalone Tauri apps); `block-library` is labelled UI-first exception. The `.github` row with TODO copy was removed (org-config repos don't belong in the public tools list).
- `.github/copilot-instructions.md` family table — duplicate table inside the `<!-- family-table:start ... end -->` block deleted. The block now contains exactly one table plus the architecture-notes paragraph. **Follow-up:** `scripts/reconcile-family-table.ps1` should be reviewed for idempotency since the duplicate appears to have been generated by a non-idempotent reconcile run.
- `prompts/refactor-desktop-to-backend-service.md` and `prompts/refactor-template.md` moved into Copilot's load path at `.github/prompts/` and renamed with the `.prompt.md` suffix to match the existing convention (`consume-toolkit-bump.prompt.md`, `release-bump.prompt.md`).
- `docs/skills/MARKDOWN.md` — added two linting rules: (1) blank lines around lists (blank line required before first bullet and after last); (2) table separator style (`| --- | --- | --- |` with spaces, not `|---|---|---|`); fixed existing table example in the skill that was itself using the bad format; added both rules to the failure modes table and pre-commit checklist.
- `.github/instructions/markdown.instructions.md` — added `## Lists` section with blank-line-around-lists MUST rule and moved nesting rule there; updated `## Tables` section with `| --- |` separator MUST rule.
- `docs/skills/PYTHON.md` — reformatted into Chamber 19 skill structure: added `# Python Skill` title, purpose paragraph, `---` dividers, Mental model section, Non-negotiable patterns, Common libraries table, Failure modes table, Chamber 19 specifics, and Quick reference with bash code block.
- `docs/skills/RUST.MD` — reformatted into Chamber 19 skill structure matching `PYTHON.md`; added `cargo check --locked` to Quick reference and explicit `Cargo.lock` commit rule.
- `docs/skills/TAURI.MD` — reformatted into Chamber 19 skill structure; added `isTauri` constant code block, full `emit_all` streaming example, libraries table with structured references, and Chamber 19 specifics covering `desktop-toolkit`, activation, and launcher relationship.
- `docs/skills/VBA_EXCEL.md` — complete content rewrite: changed scope from IFA-IFC-Checklist-specific VBA to a general Excel formatting and advanced features skill covering design principles, color/typography, conditional formatting, Form Controls (buttons, dropdowns, spin buttons, checkboxes), VBA for button actions with `ExportToPDF` example, data validation, charts/sparklines, named ranges, sheet protection with `UserInterfaceOnly:=True`, print setup, failure modes table, and Quick reference keyboard shortcuts.
- `docs/skills/DOCX.md` — complete rewrite: removed third-party container-based content (LibreOffice headless, `/mnt/data/` paths, `render_docx.py`, extensive script inventory); replaced with Chamber 19-scoped skill covering `python-docx` usage in `transmittal-builder`: mental model, non-negotiable patterns (styles over direct formatting, pathlib, no stdout), common API patterns (tables, headers, page margins, save), failure modes table, and Chamber 19 specifics.
- `docs/skills/AUTOCAD_ASSISTANT.md` — title standardized from `# Autodesk Assistant — Chamber 19 usage guide` to `# Autodesk Assistant Skill` to match the skill file naming convention.
- `docs/skills/DOCX.md` — second rewrite incorporating the `awesome-claude-skills` docx skill package: added `docx-js` (npm) patterns for JavaScript document creation including all critical gotchas (no `\n` in TextRun, PageBreak inside Paragraph, ShadingType.CLEAR, LevelFormat.BULLET constant, ImageRun type required, columnWidths + cell widths); added Document library section for editing existing files (unpack/edit/pack workflow, `get_node`, `replace_node`, `add_comment`, `reply_to_comment`); stripped all XSD schema validation, redlining/tracked-changes workflow, LibreOffice/pandoc/soffice dependencies, and container paths — verification is opening the result in Word.
- `.claude/commands/docx.md` — updated description and fallback rules to cover all three creation paths.
- `.github/instructions/docx.instructions.md` — rewritten to match updated skill: removed stale `render_docx.py` and PNG inspection references; added docx-js critical rules section (no `\n` in TextRun, PageBreak in Paragraph, ShadingType.CLEAR, LevelFormat.BULLET constant, ImageRun type, columnWidths); added Document library editing workflow note.
- `.github/copilot-instructions.md` — updated `DOCX.md` skills registry description to reflect all three document paths.
- `.claude/commands/vba-excel.md` — updated description and fallback rules to match the new VBA_EXCEL.md scope (Excel formatting and advanced features, not IFA-IFC-Checklist-specific).
- `.github/copilot-instructions.md` — updated `VBA_EXCEL.md` skills registry row description from "Writing VBA macros for the IFA-IFC-Checklist workbook" to reflect the broader Excel formatting scope.
- `docs/skills/MARKDOWN.md` — added `### Fenced code blocks must have a language and blank lines around them` subsection under `## Code formatting`; updated failure modes table with blank-lines-around-fences and language-identifier rows; added two items to pre-commit checklist.
- `.github/instructions/markdown.instructions.md` — added `## Code blocks` section with MUST rules for language identifier and blank lines around fenced code blocks.
- `docs/skills/DOCX.md` — stripped Document library / editing-existing-documents section entirely; skill is now creation-only (`python-docx` and `docx` npm).
- `.github/instructions/docx.instructions.md` — removed `## Editing existing documents` section and Document library workflow reference to match stripped skill.
- `.claude/commands/docx.md` — removed Document library from command description.
- `.github/copilot-instructions.md` — updated `DOCX.md` skills registry row to reflect creation-only scope.
- `docs/skills/MARKDOWN.md` — added six new lint rules: `no-duplicate-heading` (unique heading text required), `no-space-in-emphasis` (code identifiers with `_` in backticks), `no-inline-html` (raw HTML tags must be in backticks), `no-bare-urls` (all URLs in `[text](url)` syntax), `no-trailing-spaces`, and `fenced-code-language` (language identifier required on every fence); updated failure modes table and pre-commit checklist to match.
- `.github/instructions/markdown.instructions.md` — added MUST/NEVER rules for all six new lint rules: `no-bare-urls`, `no-inline-html`, `no-trailing-spaces`, `no-duplicate-heading`, `no-space-in-emphasis`; restructured into named sections (`## Bold and emphasis`, `## Headings`, `## Links`, `## HTML and whitespace`).
- `docs/skills/RUST.MD` — added `## Reference documentation` section with links to [The Rust Reference](https://doc.rust-lang.org/stable/) and [The Cargo Book](https://doc.rust-lang.org/cargo/index.html), including a note that Cargo is the Rust package manager.
- `docs/skills/PYTHON.md` — added `## Reference documentation` section with link to [Python documentation](https://www.python.org/doc/).
- `docs/skills/TAURI.MD` — added `## Reference documentation` section with link to [Tauri v2 documentation](https://v2.tauri.app/start/).
- `docs/skills/AUTOCAD_DOTNET.md` — fixed `no-space-in-emphasis` at line 628 (wrapped `RELAY_` code identifiers in backticks); demoted repeated subsection headings in pattern, gotcha, limitation, and glossary blocks from `##` to `###`; renamed all remaining duplicate `##` headings to include section context (e.g., `## Summary` → `## Editor input summary`).
- `docs/skills/MARKDOWN.md` — added two table rules: `### Table column style must be consistent` (compact vs aligned style must apply uniformly to header, separator, and data rows; never mix) and `### No multiple spaces inside table cells` (exactly one space inside each pipe, no extra padding); rewrote `### Alignment pipes` to clarify it covers text-alignment syntax (`:---`) not pipe position; added two failure modes rows and two pre-commit checklist items.
- `.github/instructions/markdown.instructions.md` — added two MUST rules to `## Tables`: consistent pipe style across all rows, and one space only inside each pipe.
- `docs/skills/acquire-codebase-knowledge/` — moved entire skill folder from `skills/acquire-codebase-knowledge/` into `docs/skills/`; fixed table separator style in `assets/templates/INTEGRATIONS.md` (both tables) and `assets/templates/STACK.md` (three tables) from compact-no-spaces (`|---|`) to `| --- |`.
- `docs/skills/AI_READY.md` — moved from `skills/ai-ready/SKILL.md` into `docs/skills/` as a flat file alongside other skills; deleted the now-empty `skills/` directory.
- `.github/instructions/acquire-codebase-knowledge.instructions.md` — new wrapper (`applyTo: **/docs/codebase/**`) enforcing the seven-document output contract, `[TODO]`/`[ASK USER]` discipline, evidence requirements, and source-only rule.
- `.github/instructions/ai-ready.instructions.md` — new wrapper (`applyTo: **/AGENTS.md`) enforcing `AGENTS.md` placement, content permanence, and no-duplication rules.
- `.claude/commands/acquire-codebase-knowledge.md` and `.claude/commands/ai-ready.md` — updated skill file paths to new `docs/skills/` locations.
- `CLAUDE.md` — updated skill parity table paths for `/acquire-codebase-knowledge` and `/ai-ready`; removed stale `(or \`skills/\` for methodology skills)` note from parity rule.
- `.github/copilot-instructions.md` — added `acquire-codebase-knowledge/SKILL.md` and `AI_READY.md` rows to skills registry.
- `profile/README.md` — expanded intro from single-line description to two-track summary (engineering tools + local AI infrastructure); added `## Architecture (2026)` section covering shared shell + per-app backend model, activation, and new-tool workflow; added reference to `.github` as the org hub.
- `docs/pilots.md` — rewritten as "AI tooling pilot success criteria" (not Copilot-only); Pilot 2 marked concluded with full instructions system outcome; Pilot 5 (Claude Code skills + command parity) added and marked concluded; Pilot 6 (memory system layer) added as in-progress with explicit success criteria for the forgetting/consolidation/status-convention work; evaluation log updated with Pilot 2 and 5 entries.
- `README.md` — removed stale `.github/scripts/` row (directory does not exist; scripts live in `scripts/`); added `BIOME.md` and `CHANGELOG.md` to technology skills table; updated Phase 2.3 note to remove reference to `org-maintenance/IMPLEMENTATION_PLAN.md`.
- `docs/skills/CHANGELOG.md` — added explicit "NEVER combine both formats" rule: if a bullet is under a `#### YYYY-MM-DD` subheading, do not also append `[YYYY-MM-DD]` to the bullet; added matching failure mode to the table.
- `.github/instructions/changelog.instructions.md` — added NEVER rule against appending `[YYYY-MM-DD]` to a bullet already under a `#### YYYY-MM-DD` subheading, preventing conflicting edits between agents.
- `.github/instructions/powershell.instructions.md` — prepended Chamber 19 hard rules section: approved-verb MUST, `[switch]` not `[bool]`, `$ErrorActionPreference = "Stop"`, table-separator format, `$env:GITHUB_TOKEN` requirement, no `Read-Host`; added pointer to `docs/skills/POWERSHELL.md`.
- `.github/copilot-instructions.md` — added `POWERSHELL.md` row to skills registry table.
- `README.md` (this repo) — added `POWERSHELL.md` to the technology skills table.
- `CLAUDE.md` (project root) — added `/powershell` to the command parity table paired with `docs/skills/POWERSHELL.md`.

### Removed

#### 2026-05-10

- `.github/workflows/fix-biome.yml` and `.github/workflows/fix-tailwind-canonical-vars.yml` — moved from `chamber-19/org-maintenance` into this repo; paired scripts `scripts/fix-biome.sh` and `scripts/fix-tailwind-canonical-vars.mjs` also moved to `scripts/`; PR body attribution updated from `chamber-19/org-maintenance` to `chamber-19/.github`.
- `.github/workflows/reusable-copilot-setup-steps.yml` — restored here after brief detour to `org-maintenance`; callers use `chamber-19/.github/.github/workflows/reusable-copilot-setup-steps.yml@main` as before.
- `README.md` — updated description to identify `.github` as the org maintenance hub; updated `.github/workflows/` and `scripts/` table rows to list all workflows and scripts; removed stale `skills/` row; updated methodology skills section to point to `docs/skills/`.
- `scripts/foundry-pr-trigger.yml` and `scripts/foundry-pr-trigger.properties.json` — moved from `workflow-templates/` into `scripts/`; `workflow-templates/` directory removed.
- `docs/skills/CHANGELOG.md` — fixed format baseline example to show `#### YYYY-MM-DD` date subheadings (the correct format) instead of the old inline `[YYYY-MM-DD]` per-bullet style that was causing Copilot and Claude to generate conflicting formats; added explicit callout that inline per-bullet dates are the old format.

- `copilot-alignment-audit.md` (top-level) — the canonical version is archived at `org-maintenance/archive/copilot-alignment-audit.md`. The duplicate inside this repo is no longer needed.
- Top-level `prompts/` directory — emptied after the two prompts above were moved into `.github/prompts/`.

### Fixed

#### 2026-05-10

- `scripts/reconcile-family-table.ps1` — renamed `Escape-Cell` → `ConvertTo-EscapedCell` and `Replace-TableSection` → `Update-TableSection` to use PSScriptAnalyzer-approved verbs; fixed table separator from `|---|` (no spaces) to `| --- |` (spaces) to match the Markdown skill rule.
- `scripts/lint-org-config.ps1` — renamed `Escape-AnnotationValue` → `ConvertTo-EscapedAnnotation` to use an approved PowerShell verb.
- `CHANGELOG.md` (this file) — removed 39 inline `[2026-05-10]` date tags from `### Changed` entries already under the `#### 2026-05-10` subheading; the combination of both formats was causing conflicting edits between Claude and Copilot.

- `docs/evals/markdown_quality.yml` renamed to `markdown_quality.yaml` to match the extension convention used by every other eval file in the directory.

### Security

- (none this entry)

### Known follow-ups (deferred — not in this entry)

- **Skill file casing.** `docs/skills/RUST.MD` and `docs/skills/TAURI.MD` use uppercase `.MD` extensions while the other skills use `.md`. Renaming requires coordinated updates to **12 references** in consumer repos (`block-library`, `batch-fnr`, `Transmittal-Builder`, `Drawing-List-Manager`, `launcher`, `desktop-toolkit` — each has two refs in their own `copilot-instructions.md`). Track in a dedicated PR.
- **`AUTOCAD_DOTNET.md` monolith split.** 152 KB single file should be split into `docs/skills/autocad/` topic chapters.
- **`reconcile-family-table.ps1` idempotency.** The duplicate family table indicates the reconcile script appended instead of replaced. Investigate `scripts/reconcile-family-table.ps1` for idempotency gap.

---

## How to add an entry

1. Open this file.
2. Under `## [Unreleased]`, find or create the appropriate category subheading (`### Added`, `### Changed`, etc.).
3. Add a bullet describing the change in the past tense, single sentence, with file path(s) backticked. Match the style of existing entries.
4. **Do not** create a new version section without a release; that comes at tag time.

## Release procedure (when this repo eventually ships tags)

1. Move every entry from `## [Unreleased]` to a new `## [vX.Y.Z] — YYYY-MM-DD` section.
2. Empty `## [Unreleased]` (keep the heading and category subheadings).
3. Tag and push: `git tag -a vX.Y.Z -m "release X.Y.Z"; git push origin vX.Y.Z`.
4. Create a GitHub Release that pastes the new section's content as the release body.

## Versioning

This repo doesn't currently ship binary releases; the only versions that matter are content states reflected in commit history and (eventually) tags. SemVer applies *to the instruction surface*: a breaking change to org-wide rules is `MAJOR`; a new skill or instruction wrapper is `MINOR`; a wording fix or drift repair is `PATCH`.
