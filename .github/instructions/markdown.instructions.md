---
applyTo: "**/*.md"
---

# Markdown — Chamber 19 writing rules

The rules below are the enforced minimum and apply even if you cannot access the skill file. For complete guidance — examples, failure modes, accessibility rules, and the pre-commit checklist — read `docs/skills/MARKDOWN.md` in the `chamber-19/.github` repo when you can access it.

## Non-negotiable

- **MUST** start every file with a single `#` title as the first line
- **MUST** write a one-paragraph purpose statement immediately after the title
- **MUST** wrap all file names, paths, commands, config keys, and code in backticks
- **MUST** use fenced code blocks with a language identifier for all multi-line code — never leave the identifier blank
- **MUST** write list items in parallel grammatical form — all imperatives, all noun phrases, or all complete sentences — never mixed
- **MUST** use active voice — "Run cargo check" not "cargo check should be run"
- **NEVER** use exclamation points in documentation
- **NEVER** use marketing language — no "seamlessly", "powerful", "robust", "leverage", "cutting-edge"
- **NEVER** skip heading levels — do not jump from `##` to `####`

## Bold and emphasis

- Bold (`**text**`) is for MUST/NEVER keywords and critical terms only — not for decoration
- Do not combine bold and italic (`**_text_**`) — rewrite the sentence instead
- ALLCAPS only for `MUST`, `NEVER`, `PREFER` in rules documents — use bold elsewhere
- **NEVER** put spaces inside emphasis markers — code identifiers with `_` or `*` characters belong in backticks (e.g., `` `RELAY_` `` not `RELAY_`)

## Headings

- **MUST** ensure all heading text is unique within the file — duplicate headings break anchor navigation and fail linters
- **NEVER** skip heading levels — do not jump from `##` to `####`

## Links

- **NEVER** use bare URLs — wrap every URL as `[descriptive text](url)`
- Link text must describe the destination — never "here" or "this"
- Internal links use relative paths — never hardcoded GitHub URLs

## HTML and whitespace

- **NEVER** use raw HTML tags in Markdown — wrap XML/HTML literals in backticks
- **MUST** ensure no trailing spaces on any line

## Code blocks

- **MUST** specify a language identifier on every fenced code block — `bash`, `python`, `rust`, `csharp`, `yaml`, `toml`, `json`, `markdown`, `text` — never a bare ` ``` `
- **MUST** have a blank line before the opening fence and after the closing fence

## Lists

- **MUST** have a blank line before the first list item and after the last — lists that run directly into a preceding paragraph will not render correctly in all tools
- **NEVER** nest lists more than two levels deep

## Tables

- Every table needs a header row
- Separator rows **MUST** use `| --- | --- | --- |` style (spaces inside every pipe) — the compact form `|---|---|---|` breaks some renderers and fails markdown linters
- **MUST** apply one pipe style consistently — all rows (header, separator, data) compact `| --- |` or all aligned `| -------- |`; never mix styles within a table
- **MUST** use exactly one space inside each pipe for all cells — never pad cells with multiple spaces (`| content              |`)
- Keep cells short — one sentence maximum
- Use tables for structured comparison data only, not for lists with one meaningful column

## Links

- Link text must describe the destination — never "here" or "this"
- Internal links use relative paths — never hardcoded GitHub URLs

## Tone

- Chamber 19 tone: warm, matter-of-fact, engineering-grade
- Match the length of the content to the complexity of the topic
- One idea per paragraph — start a new paragraph when the topic shifts

## CHANGELOG discipline

- If the repo has a `CHANGELOG.md`, follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format with categories `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`
- New entries go under `## [Unreleased]` — never under a tagged version after release
- See that repo's `AGENTS.md` for whether a CHANGELOG entry is required per PR (currently required in `chamber-19/.github`)
