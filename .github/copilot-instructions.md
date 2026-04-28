<!-- markdownlint-disable MD013 -->
# Copilot Instructions — Chamber 19 Reference

> **Org:** `chamber-19`
> **Scope:** Shared reference guidance for Chamber 19 repositories.

This file is maintained in the org `.github` repository as the source copy for
Chamber 19 conventions. It is **not** a substitute for each repository's own
`.github/copilot-instructions.md`; per-repo files remain the durable context
for GitHub Copilot web, Copilot code review, and Copilot coding agent.

When a convention below applies to a repo, copy or summarize it in that repo's
own instruction file. Repo-specific rules always win over this shared reference.

## Family Context

| Repo | Role | Stack |
| --- | --- | --- |
| `desktop-toolkit` | Shared framework for Tauri desktop apps | Rust, JS, Python, NSIS |
| `launcher` | Desktop shell for installing/updating Chamber 19 tools | Rust, React, Tauri |
| `transmittal-builder` | Engineering transmittal package generator | Rust, React, Python |
| `Drawing-List-Manager` | Project drawing register manager | Rust, React, Python |
| `Foundry` | Local agent broker and dependency alerting service | .NET, Python, Ollama |

Consumer apps pin `desktop-toolkit` in both npm and Cargo. A toolkit release
does not auto-propagate; bumping a consumer pin is a deliberate PR.

## Shared Rules

- Keep work scoped. Do not rebuild Suite-era infrastructure, scoring pipelines,
  or speculative shared layers.
- Prefer concrete duplication over premature abstraction until at least two real
  consumers need the same behavior.
- Keep docs current with user-facing behavior, release workflow changes,
  version bumps, and toolkit pin bumps.
- Use SemVer tags in the form `vMAJOR.MINOR.PATCH`.
- GitHub Releases are the distribution channel for app/plugin artifacts.
- Never commit secrets. Local tokens belong in gitignored local settings or
  environment variables.
- For dependency PRs, inspect manifest and lockfile changes together; toolkit
  pin bumps must keep npm and Rust pins aligned.

## Copilot Guidance

- Keep each repo's main `.github/copilot-instructions.md` short and high-signal.
- Put subsystem/path-specific details in `.github/instructions/*.instructions.md`.
- Avoid conflicting org/reference, repo, path, and `AGENTS.md` instructions.
- For Copilot cloud agent, each repo that needs setup must define
  `.github/workflows/copilot-setup-steps.yml` with a single
  `copilot-setup-steps` job.

## Design System

- Background: `#1C1B19`
- Accent: `#C4884D`
- Success: `#6B9E6B`
- Warning: `#C4A24D`
- Error: `#B85C5C`
- Info: `#5C8EB8`
- Body type: DM Sans
- Display type: Instrument Serif
- Data/technical type: JetBrains Mono

Tone: warm industrial, engineering-grade, short, matter-of-fact.
