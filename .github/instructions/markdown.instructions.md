---
applyTo: "**/*.md"
---

# Markdown — Chamber 19 writing rules

Full reference: `docs/skills/MARKDOWN.md` in `chamber-19/.github`

Read `MARKDOWN.md` before writing or editing any `.md` file.

## Non-negotiable

- **MUST** start every file with a single `#` title as the first line
- **MUST** write a one-paragraph purpose statement immediately after the title
- **MUST** wrap all file names, paths, commands, config keys, and code in backticks
- **MUST** use fenced code blocks with a language identifier for all multi-line code — never leave the identifier blank
- **MUST** write list items in parallel grammatical form — all imperatives, all noun phrases, or all complete sentences — never mixed
- **MUST** use active voice — "Run cargo check" not "cargo check should be run"
- **NEVER** use exclamation points in documentation
- **NEVER** use marketing language — no "seamlessly", "powerful", "robust", "leverage", "cutting-edge"
- **NEVER** nest lists more than two levels deep
- **NEVER** skip heading levels — do not jump from `##` to `####`

## Bold and emphasis

- Bold (`**text**`) is for MUST/NEVER keywords and critical terms only — not for decoration
- Do not combine bold and italic (`**_text_**`) — rewrite the sentence instead
- ALLCAPS only for `MUST`, `NEVER`, `PREFER` in rules documents — use bold elsewhere

## Tables

- Every table needs a header row
- Keep cells short — one sentence maximum
- Use tables for structured comparison data only, not for lists with one meaningful column

## Links

- Link text must describe the destination — never "here" or "this"
- Internal links use relative paths — never hardcoded GitHub URLs

## Tone

- Chamber 19 tone: warm, matter-of-fact, engineering-grade
- Match the length of the content to the complexity of the topic
- One idea per paragraph — start a new paragraph when the topic shifts
