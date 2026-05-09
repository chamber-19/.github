# chamber-19/.github

This repository holds the Chamber 19 organization's shared configuration,
AI guidance, and documentation assets.

## What lives here

| Path | Purpose |
|---|---|
| `profile/README.md` | Org landing page rendered at github.com/chamber-19 |
| `.github/copilot-instructions.md` | Family-wide AI guidance — loads automatically alongside every repo's own file |
| `.github/instructions/` | Path-scoped instruction files with `applyTo:` frontmatter — load automatically when matching file types are touched |
| `.github/prompts/` | Reusable agent prompt files for common multi-step tasks |
| `docs/skills/` | Deep technical reference for each technology in the stack — read before making changes in a given language |
| `docs/evals/` | YAML eval specs for testing AI instruction compliance cold |
| `docs/memory.md` | Org-wide institutional memory — incidents, compatibility traps, and closed decisions with evidence |
| `docs/pilots.md` | Pre-written success criteria for Copilot feature pilots |

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

Skills in `docs/skills/` are referenced by instruction files and AGENTS.md
files across the org. Read the relevant skill before making changes:

| Skill | When to read |
|---|---|
| `TAURI.md` | Tauri commands, IPC, sidecars, events, packaging |
| `RUST.md` | Any Rust — commands, error handling, async |
| `PYTHON.md` | Python sidecars, automation, ML pipelines |
| `AUTOCAD_DOTNET.md` | AutoCAD .NET plugins, transactions, attributes |
| `VBA_EXCEL.md` | VBA macros for IFA-IFC-Checklist |
| `MARKDOWN.md` | Any `.md` file in the org |
| `DOCX.md` | Word document generation (transmittal-builder) |
| `AUTOCAD_INTERPRETIVE_DANCE.md` | [adversarial-test] Broken skill link — resolves to `docs/skills/AUTOCAD_INTERPRETIVE_DANCE.md` which does not exist |

## Contributing

Changes here propagate immediately to every repo in the org. Treat updates
with the same care as a `desktop-toolkit` framework change — review
carefully, test mentally against each consumer's existing rules, and prefer
additive changes over breaking ones.

When you find an incident, compatibility trap, or closed decision in any
repo, add an entry to `docs/memory.md` with evidence before the context
is lost.
