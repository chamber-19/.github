<!-- markdownlint-disable MD013 -->
# Copilot Instructions — Chamber 19

> **Org:** `chamber-19`
> **Scope:** Org-wide baseline for all AI agents and Copilot sessions in Chamber 19 repos.

This file loads automatically alongside each repo's own
`.github/copilot-instructions.md`. Both apply. Repo-specific rules win
on conflict. Keep this file focused on family-wide concerns — put
repo-specific rules in the repo's own file.

---

## What this org builds

Chamber 19 produces two tightly coupled tracks that feed each other:

**Engineering desktop tools** — Tauri 2.0 desktop applications with Rust
backends and Python sidecars supporting substation design workflows:
transmittal builders, drawing list managers, batch drawing tools, and
AutoCAD automation plugins. These tools talk to Python sidecars via
newline-delimited JSON over stdio and drive AutoCAD through .NET plugins
or light COM automation. They generate the ground truth used to train AI
models.

**Local AI infrastructure** — Foundry brokers local inference via Ollama
and hosts Qdrant-backed RAG stacks. It consumes fine-tuned models from
Hugging Face, evaluates code changes and drawing markups, and routes jobs
to local LLMs with deterministic checks before calling any model.

These tracks are one system: engineering tools generate labelled data,
training pipelines produce domain-aware models, Foundry brokers them back
into the workflow.

---

## Working on this repo (`chamber-19/.github`)

When the change is **inside this repo** (not a consumer repo), additional rules apply. See [`AGENTS.md`](../AGENTS.md) for the full set; the load-bearing ones:

- **MUST** add an entry to [`CHANGELOG.md`](../CHANGELOG.md) under `## [Unreleased]` for every PR. Use Keep a Changelog categories: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.
- **MUST** keep the family table inside `<!-- family-table:start ... end -->` markers as a single table. The `scripts/reconcile-family-table.ps1` script regenerates this block; never hand-edit if you can run the script instead.
- **MUST** keep instruction wrappers in `.github/instructions/` thin (under 3 KB) — they load via `applyTo:` and reference the deep skill in `docs/skills/`.
- **NEVER** add a skill in `docs/skills/` without also adding the matching wrapper in `.github/instructions/` and the row in the skills registry table below.
- **NEVER** edit submodule content (`docs/skills/tauri2-skills/`, `docs/skills/threejs-skills/`) — update the submodule pointer instead.

These rules apply only when working *on* this repo. Consumer repos load this file as family-wide guidance — they do not need to maintain a CHANGELOG here.

---

## Family table

<!-- family-table:start -->
| Repo | Role | Stack |
| --- | --- | --- |
| `desktop-toolkit` | Shared framework for Tauri desktop apps | Tauri 2.0, React, Rust, Python |
| `launcher` | Desktop launcher and updater — activation, app routing, updater | Tauri 2.0, React, Rust |
| `transmittal-builder` | Python FastAPI backend service — engineering transmittal package generator | Python, FastAPI |
| `Drawing-List-Manager` | Tauri app with Python sidecar — project drawing register | Tauri 2.0, Rust |
| `batch-fnr` | Batch DXF Find-and-Replace with headless .NET AutoCAD sidecar | Tauri 2.0, Rust, React, .NET |
| `block-library` | Tauri 2 desktop DXF viewer with Google Drive catalog sync and SQLite local cache | Tauri 2.0, React, Three.js, Rust |
| `Foundry` | Local agent broker — Ollama-backed dep-reviewer and other agents | .NET, Ollama, Microsoft.SemanticKernel |
| `autocad-knowledge` | AutoCAD .NET pattern reference — source of truth for AUTOCAD_DOTNET.md skill | Markdown, C# samples |
| `chamber-19-autocad-mcp` | MCP server inside AutoCAD — read-only inspection surface for LLM agents | .NET, PowerShell |
| `IFA-IFC-Checklist` | Macro-enabled Excel workbook for IFA/IFC pre-submittal checklists | Excel VBA |
| `Glyphic` | TODO: curate role for Glyphic | TODO |
| `.github` | TODO: curate role copy for this repo in family-table generation | Markdown, YAML |
<!-- family-table:end -->

Consumer apps (`transmittal-builder`, `Drawing-List-Manager`, `launcher`)
pin `desktop-toolkit` in both ecosystems: `@chamber-19/desktop-toolkit`
(npm) and `desktop-toolkit` (Cargo). Both pins must be updated together
in a dedicated PR. A toolkit release does not auto-propagate.

---

## Desktop App Architecture (May 2026 Refactor)

Chamber 19 desktop tools now follow a **shared shell + per-app backend** model:

**Launcher** (one universal Tauri shell for all apps):
- Handles desktop integration, app routing, activation gate, updates
- Deploys once; all tools use it
- No tool-specific installers

**Backends** (per-app Python FastAPI services):
- Stateless HTTP services — can run locally, remotely, in containers
- Examples: `transmittal-builder`, `Drawing-List-Manager`
- Launcher discovers & routes to them via HTTP

**Activation** (centralized in `desktop-toolkit`):
- PIN generation, office IP gating, hardware fingerprinting, token signing
- All tools reuse the same activation logic
- Server-side: FastAPI service in `desktop-toolkit`
- Client-side: Tauri Rust commands in `launcher`

**When adding a new tool:** Create backend service, register route in launcher config, done.
Launcher doesn't need rebuilding per tool.

---

## Hard architectural decisions

These decisions are closed. They exist because alternative approaches
caused real problems. MUST is mandatory and mechanically checkable.
NEVER is a closed decision — do not revisit it.

### Tauri and Rust

- **MUST** define `const isTauri = typeof window !== "undefined" && "__TAURI_INTERNALS__" in window` at module load. Use this guard before every IPC call. Inline checks and repeated string literals are forbidden.
- **MUST** return `Result<T, String>` from every `#[tauri::command]` function. `.unwrap()` inside a command handler is a bug.
- **MUST** stream long-running work to the frontend via `emit_all()` or `emit()`. Polling from the frontend is **NEVER** allowed — it caused hangs in early versions.
- **MUST** commit `Cargo.lock` and run `cargo check --locked`. Drift is a bug.
- **MUST** bump `desktop-toolkit` pins for Rust, Python, and JS together in a dedicated PR. **NEVER** mix version bumps with feature work.

### Python sidecars

- **MUST** call `print(..., flush=True)` for all sidecar output. Tauri reads line by line and deadlocks on buffered output — this caused real hangs.
- **MUST** exchange messages as newline-delimited JSON on stdin/stdout — one JSON object per line, no other delimiters.
- **MUST** use `pathlib.Path` for all filesystem paths. `os.path` is forbidden.
- **MUST** annotate every function with type hints.
- **NEVER** use a bare `except:` — always name the specific exception type.

### AutoCAD .NET plugins

- **MUST** wrap every database operation inside `TransactionManager.StartTransaction()`. Open entities `ForRead` first, call `.UpgradeOpen()` only when writing.
- **MUST** set `Copy Local = False` for all Autodesk assemblies. Copying them to the output folder causes version conflicts and crashes.
- **MUST** register command names without prefixes — `TOTAL`, not `CH19TOTAL`. Identity lives in metadata.
- **MUST** use `new Database(false, true)` and `ReadDwgFile` for batch processing. **NEVER** open the AutoCAD UI for headless tasks.
- **NEVER** call COM APIs from .NET plugins — use Python sidecars for COM. COM inside plugins causes deadlocks.

### Architecture and process

- **NEVER** resurrect the suite-era shared infrastructure. It was retired due to unmanageable coupling and slow iteration.
- **NEVER** combine a `desktop-toolkit` pin bump with feature work in the same PR.
- **NEVER** build an abstraction "because we'll probably need it". Require at least two concrete consumers.
- **NEVER** ship an LLM-backed agent without a labelled eval set. The eval set is the contract.
- **NEVER** call remote LLM APIs from Foundry or any tool. All inference is local via Ollama.

---

## Architectural decisions that persist across sessions

Persist these to Copilot Memory when they evolve. Current state:

1. **`autocad-pipeline` is deliberately minimal.** v0.1.0 has only `Directory.Build.props` and a parameterized `Plugin.csproj.template`. No shared C# code. No NuGet packages. The pipeline is the build contract, not a runtime library.
2. **AutoCAD plugin commands use bare names.** `TOTAL`, not `CH19TOTAL`. Identity lives in package metadata.
3. **Launcher is the installer/updater for AutoCAD plugins.** It fetches plugin releases from GitHub. It does not ship plugin source.
4. **GitHub Releases is the distribution channel.** Even for internal use — keeps engineers on VPN-optional workflows.
5. **Plugins and the launcher release on independent tags.** A launcher update does not imply a plugin update.
6. **The launcher repo was renamed from `shopvac` to `launcher`.** Old clones need `git remote set-url`.
7. **GitHub Packages versions are immutable.** A bad `@chamber-19/desktop-toolkit` release cannot be yanked. Fix forward with a new patch version.
8. **Foundry is the agent broker, not an ML pipeline.** Dependency monitoring uses scheduled polling. Agents run deterministic checks → LLM structured extraction → rule-based output, and fail open to "needs human review" when Ollama or GitHub is unavailable. The ML/scoring/Suite incarnation is retired and is not coming back.

---

## Design system

All Chamber 19 UIs use a warm, industrial aesthetic. These tokens are
non-negotiable in every UI in the org.

| Token | Value |
|---|---|
| Background | `#1C1B19` |
| Accent | `#C4884D` |
| Success | `#6B9E6B` |
| Warning | `#C4A24D` |
| Error | `#B85C5C` |
| Info | `#5C8EB8` |
| Body font | DM Sans |
| Display font | Instrument Serif |
| Monospace | JetBrains Mono |

No purple gradients on white. No Inter, Roboto, or Arial. No exclamation
points. Tone: warm, matter-of-fact, engineering-grade. Never
marketing-driven.

## Accessibility — mandatory for all React UIs

**MUST:** Every `<input>`, `<select>`, and `<textarea>` element must have both an `id` and a `name` attribute. Use `id` for `<label htmlFor>` association. Add `aria-label` when no visible label exists.

```tsx
// CORRECT
<input id="course-search" name="course-search" aria-label="Search courses" ... />
<select id="filter-institution" name="filter-institution" aria-label="Filter by institution" ...>

// WRONG — fails screen reader association and browser autofill hint
<input value={...} onChange={...} placeholder="Search courses" />
```

**MUST NOT:** Use `<span onClick>` or `<div onClick>` as interactive controls. Use `<button>` for clickable actions — it is keyboard-focusable and announced correctly by screen readers.

**MUST NOT:** Write `outline: none` without a companion `:focus-visible` rule that provides an equivalent visible ring.

---

## Skills registry

Deep technical reference lives in `docs/skills/` in this repo. Read the
relevant skill file before making changes in a given language or domain.

| File | Read when... |
|---|---|
| `TAURI.md` | Writing Tauri commands, IPC, sidecars, events, packaging |
| `RUST.md` | Writing any Rust — commands, structs, async, error handling |
| `PYTHON.md` | Writing Python sidecars, automation, ML pipelines, COM |
| `AUTOCAD_DOTNET.md` | Writing AutoCAD .NET plugins, transactions, attribute access |
| `VBA_EXCEL.md` | Building or formatting Excel workbooks — form controls, VBA macros, charts, conditional formatting, sheet protection |
| `MARKDOWN.md` | Writing or editing any `.md` file in the org |
| `CHANGELOG.md` | Writing or updating any `CHANGELOG.md` file — format, date convention, categories, release procedure |
| `BIOME.md` | Writing or linting TypeScript/JavaScript in `launcher`, `block-library`, or `desktop-toolkit` frontends |
| `DOCX.md` | Creating `.docx` files — `python-docx` (Python) or `docx` npm (JavaScript) |
| `tauri2-skills/skills/source/` | Read before any Tauri 2 command, event, permission, or build change |
| `threejs-skills/skills/source/` | Read before any Three.js/R3F work in block-library |
| `AUTOCAD_ASSISTANT.md` | Writing Autodesk Assistant queries, session priming, or any programmatic MCP client code |
| `acquire-codebase-knowledge/SKILL.md` | Mapping or documenting an existing codebase — outputs seven `docs/codebase/` documents |
| `AI_READY.md` | Making a repo AI-ready — verifying or creating `AGENTS.md`, `copilot-instructions.md`, CI workflows, issue templates |
| `POWERSHELL.md` | Writing or reviewing PowerShell scripts — approved verbs, parameter design, error handling, GitHub API patterns, `PowerShellForGitHub` |

---

## AutoCAD knowledge base

`autocad-knowledge` is the authoritative cross-repo reference for all AutoCAD work in the Chamber 19 family. Before writing any `.NET` plugin code, Autodesk Assistant queries, or DWG-processing logic in any repo, read the relevant files from that repo first.

| When you are... | Read in `autocad-knowledge` |
|---|---|
| Writing any .NET code that touches the drawing database | `transaction-model.md` — foundational, no exceptions |
| Working with block attributes (read/write/find) | `attributes.md` |
| Batch-processing DWG files headlessly | `headless-processing.md` |
| Choosing between .NET / JavaScript / APS Design Automation / APS Viewer | `api-surface-comparison.md` |
| Configuring a `.csproj` for an AutoCAD plugin | `msbuild-setup.md` |
| Writing Autodesk Assistant prompts | `patterns/` + `glossary/session-priming-prompt.md` |
| Hitting an unexpected plugin crash or error | `gotchas.md`, then `gotchas/` directory |
| Trying something that seems like it should work but doesn't | `limitations/` directory first |
| Working with R3P substation, BESS, or P&C drawings | `electrical-engineering.md` + `glossary/` |

**Three facts from this repo that apply org-wide:**
- Block attributes are **not** queryable via Autodesk Assistant MCP. Attribute work requires `batch-fnr` or a custom .NET plugin. See `limitations/block-attributes-not-queryable.md`.
- Plain polylines carry no electrical semantics. Wire connectivity requires ACADE (AutoCAD Electrical). See `limitations/plain-polyline-not-wire.md`.
- The transaction model (`transaction-model.md`) is the foundation for **all** .NET entity code. No exceptions.

---

## Authoritative external references

Fetch from these sources when you need current API or language behaviour.
Do not rely on training data for version-specific details.

| Topic | URL |
|---|---|
| Tauri v2 | <https://v2.tauri.app/start/> |
| Rust book | <https://doc.rust-lang.org/stable/book/> |
| Python stdlib | <https://www.python.org/doc/> |
| npm | <https://docs.npmjs.com/> |
| Node.js | <https://nodejs.org/docs/latest/api/> |

---

## Institutional memory

Organisational memory lives in `docs/memory.md` in this repo. It records incidents, compatibility traps, and closed decisions with evidence. Read it before making architectural decisions. When you find a trap or incident in any repo, add an entry with evidence.

**Memory lifecycle:**

- Entries carry one of three statuses: `[Active]` (still load-bearing), `[Promoted]` (distilled into a MUST/NEVER rule in this file), or `[Deprecated]` (no longer applies).
- **Consolidation trigger:** when 3+ incidents share a pattern, distill them into a MUST/NEVER rule in this file and mark the source incidents `[Promoted]` in `docs/memory.md`.
- **Handoff boundary:** session-specific discoveries stay in Claude Code Auto Memory (`~/.claude/projects/.../memory/`). Org-wide traps that affect any contributor (human or AI) get promoted to `docs/memory.md`. Hardened rules land here and are marked `[Promoted]` in `docs/memory.md`.

---

## Meta-contract

| Keyword | Meaning |
|---|---|
| **MUST** | Mandatory and mechanically checkable. Violating a MUST is a bug, not a style choice. |
| **PREFER** | Recommended default. Can be overridden with a concrete reason. |
| **NEVER** | Closed decision that caused a real problem. Suggesting to override a NEVER is itself a bug. |

If a rule seems wrong for a specific situation, say so explicitly and
wait for confirmation. Do not silently work around it.

---

## Pushback patterns

Push back — firmly and by default — when asked to:

- Reintroduce the retired suite-era shared infrastructure or ML scoring pipeline
- Combine a `desktop-toolkit` pin bump with feature work in the same PR
- Build an abstraction for a single consumer ("we'll probably need it")
- Ship an LLM-backed agent without a labelled eval set
- Call any remote LLM API from Foundry or any Chamber 19 tool
- Add a speculative shared layer before two repos concretely need it

Explain why the rule exists. Ask for confirmation before proceeding.

---

## Copilot Memory — what to persist and what not to

**Persist to Copilot Memory:**
- Repo-specific bugs and the regression tests that pin them
- Subtle pin-compatibility traps discovered through experience
- Deviations from documented conventions with the reason
- Recurring traps that cost time to discover

**Do not persist to Copilot Memory:**
- Architectural decisions that belong in this file — they load every session
- Cross-repo context that applies family-wide — it belongs here
- Per-PR context (branch names, transient commit hashes)
- Debugging state from a single session
- File contents — re-read files, do not cache them in memory
- Anything inferable by reading current repo files

When in doubt, re-read the repo rather than trusting stale memory.

---

## Coding style

- Match the style already in the file. Read neighbouring files before writing.
- No explanatory comments on obvious code. Comments explain *why*, not *what*.
- No scope creep. Fix the bug. Do not refactor adjacent code unless asked.
- Prefer editing over rewriting. Produce a minimal diff, not a full rewrite.
- Minimum code that solves the problem. No speculative flexibility.
- Senior-engineer test: would a careful reviewer call this overcomplicated? If yes, simplify.

## Response style

- Match the length of the question. Short questions get short answers.
- Be direct. If a request is a bad idea, say so and explain why.
- Do not narrate what you are about to do. Do it, then describe the result if relevant.
- If uncertain, say so. Do not fabricate confidence.

## Goal-driven execution

Convert imperative tasks into verifiable goals before starting.

| Instead of... | Transform to... |
|---|---|
| "Add validation" | "Write tests for invalid inputs, then make them pass." |
| "Fix the bug" | "Write a test that reproduces it, then make it pass." |
| "Refactor X" | "Ensure tests pass before and after; diff is style-only." |
| "Bump the toolkit pin" | "npm + Cargo pins updated together; both lockfiles regenerated; `cargo check` and `npm run build` succeed." |

For multi-step work, state a plan with a verify checkpoint at each step
before writing any code. Stop and report if any checkpoint fails — do not
continue into broken state.

```
Step 1 → [action] → verify: [check]
Step 2 → [action] → verify: [check]
```

## When you don't know

1. Check Copilot Memory first — repo-specific discoveries live there
2. Check `RELEASING.md`, `CHANGELOG.md`, and `README.md` in the repo
3. Search across Chamber 19 repos via GitHub
4. Ask the user — ask a specific question, not an open-ended one

---

## Reference

Coding style, code change discipline, and goal-driven execution sections
draw on Karpathy-inspired LLM coding guidelines:
<https://github.com/forrestchang/andrej-karpathy-skills>.
