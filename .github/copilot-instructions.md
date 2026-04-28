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

## Architectural decisions that persist across sessions

Use GitHub Copilot Memory (visible at Repo Settings → Copilot → Memory) to
recall and update these as decisions evolve. Current state:

1. **`autocad-pipeline` is deliberately minimal.** v0.1.0 contains only
   `Directory.Build.props` and a parameterized `Plugin.csproj.template`. No
   shared C# code. No NuGet packages. No PowerShell scripts. The pipeline is
   the build contract, not a runtime library.
2. **AutoCAD plugin commands use bare names, no prefix.** `TOTAL`, not
   `CH19TOTAL`. The Chamber 19 identity lives in package metadata, not in
   every command typed at the AutoCAD command line.
3. **Launcher is the installer/updater for AutoCAD plugins.** It does not
   ship plugin source code. Plugins live in their own repos. Launcher
   fetches their releases from GitHub.
4. **GitHub Releases is the distribution channel, not a network share.**
   Even for internal use. This keeps engineers on VPN-optional workflows
   and is ready for external distribution if that ever happens.
5. **Plugins and the launcher release on independent tags.** Plugin tags
   follow the form `v0.1.0` within their own repo. Launcher has its own
   version. A launcher update does not imply a plugin update and vice
   versa.
6. **The launcher repo was renamed from `shopvac` to `launcher`.** Old
   clones need `git remote set-url`. GitHub's redirect handles URLs
   automatically but don't rely on it in documentation.
7. **GitHub Packages versions are immutable.** A bad
   `@chamber-19/desktop-toolkit` release cannot be yanked cleanly. Fix
   forward with a new patch version.

When making a decision that affects another repo or that future sessions
need to respect, persist it to Copilot Memory. Explicit state beats
re-derivation every time.

## Memory scope — what to persist

GitHub Copilot Memory is repo-scoped, persists across sessions, is tagged
by agent and model, and auto-expires. The user can review and curate
memories at Repo Settings → Copilot → Memory.

**Persist to Copilot Memory:**

- Repo-specific discoveries that aren't in this instructions file (a subtle
  bug in a particular module and the regression test that pins it; a
  Cargo.lock regeneration quirk specific to one repo)
- Version-pin contracts with shared libraries (e.g. "this consumer's v1.x
  line expects `desktop-toolkit` ^2.3.0+")
- Deviations from documented conventions
- Recurring traps that cost time to discover

**Do NOT persist to memory:**

- Architectural decisions that belong in this instructions file (more
  durable here, and they load every session)
- Cross-repo context that applies family-wide (belongs in this file's
  shared section)
- Per-PR context (PR title, branch name, transient commit hashes)
- Debugging state from a single session
- File contents — re-read files when needed, don't cache them in memory
- Anything you could infer by reading current files in the repo

When in doubt, prefer to re-read the repo over trusting stale memory.
Memory is for repo-specific discoveries, not the shape of permanent
decisions — those go in this file.

## Scope and style

### Coding style

- **Match the style already in the file.** Don't introduce a new
  formatting convention in a repo that has a consistent one. Read
  neighboring files first.
- **Be concise.** No explanatory comments on obvious code. Comments
  explain *why*, not *what*.
- **No scope creep.** If asked to fix a bug, fix the bug. Don't also
  refactor surrounding code "while you're there" unless explicitly asked.
- **Prefer editing over rewriting.** When given a file to modify, produce
  a minimal diff. Don't rewrite the whole file to apply a one-line change.

### Response style in chat

- Match the length of the question. Short questions get short answers.
- Be direct. If a request is a bad idea, say so and explain why rather
  than complying silently.
- Don't narrate what you're about to do before doing it. Just do it, then
  describe the result if relevant.
- If uncertain, say you're uncertain. Don't fabricate confidence.

### When to push back

Actively push back when the user:

- Proposes reconstructing Suite-style infrastructure (e.g. a shared
  controller exe, a named-pipe RPC layer, a multi-layer toolkit with 4+
  components) before there's concrete duplication justifying it
- Suggests building an abstraction "because we'll probably need it" — ask
  whether the need is experience-based or prediction-based
- Wants to combine scoped work (e.g. "while we're renaming the repo,
  let's also add the installer logic") — keep unrelated changes in
  separate PRs
- Wants to combine a `desktop-toolkit` pin bump with feature work in the
  same PR — separate them, because pin-bump PRs need to be reviewable as
  pin-bump PRs

## Code change discipline

When editing existing code:

- Match existing style, even if you'd do it differently. Don't reformat
  adjacent code or "improve" comments that weren't part of the request.
- Don't refactor things that aren't broken. If you notice unrelated dead
  code or smells, mention them in the PR description — don't delete or
  fix them in this PR.
- Every changed line should trace directly to the user's request. If you
  can't justify a line, remove it.
- Clean up only the orphans your own changes created (unused imports,
  variables, helpers that became unreachable). Pre-existing dead code
  stays unless explicitly asked.

When implementing:

- Minimum code that solves the problem. No speculative abstractions, no
  flexibility that wasn't requested, no error handling for scenarios that
  can't actually happen.
- If you wrote 200 lines and 50 would suffice, rewrite it.
- Senior-engineer test: would a careful reviewer call this overcomplicated?
  If yes, simplify before opening the PR.

When uncertain:

- State your assumptions explicitly. Don't guess silently.
- If multiple interpretations of the request exist, present them. Don't
  pick one and proceed.
- If something is unclear, stop and ask. Naming what's confusing is more
  helpful than producing a guess.

## When you don't know

- Check Copilot Memory first (repo-specific discoveries and recurring
  traps live there)
- Then check the repo's `RELEASING.md`, `CHANGELOG.md`, and `README.md`
- Then search across the Chamber 19 repos via GitHub
- Only then ask the user — and when you ask, ask a specific question, not
  an open-ended one

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
