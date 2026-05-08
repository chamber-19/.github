# Copilot Instruction Alignment Audit — Chamber 19 Org
**Date:** 2026-05-07
**Scope:** All repos under `C:\Users\koraj\Documents\GitHub` except `IFA-IFC-Checklist-main` and `Glyphic`
**Source of truth:** `.github/.github/copilot-instructions.md` + `.github/.github/instructions/` + `.github/.github/prompts/`

---

## Summary

| Repo | `copilot-instructions.md` | `instructions/` | `prompts/` | `AGENTS.md` | Status |
|---|:---:|:---:|:---:|:---:|---|
| `.github` (org) | ✅ 276 L | ✅ 7 files | ✅ 2 files | — | Source of truth |
| `desktop-toolkit` | ✅ 45 L | ✅ 1 file | ✅ 1 file | ✅ redirect | Aligned |
| `launcher` | ✅ 46 L | ✅ 1 file | ✅ 1 file | ✅ redirect | Aligned |
| `Transmittal-Builder` | ✅ 58 L | ✅ 2 files | ✅ 1 file | ✅ detailed | Aligned |
| `Drawing-List-Manager` | ✅ 46 L | ✅ 1 file | ✅ 1 file | ✅ redirect | Aligned |
| `batch-fnr` | ✅ 88 L | ❌ | ❌ | ✅ 97 L | Aligned (single-purpose) |
| `Foundry` | ✅ 157 L | ✅ 1 file | ❌ | ✅ redirect | Mostly aligned |
| `block-library` | ✅ 54 L | ❌ | ❌ | ✅ redirect | Aligned |
| `autocad-knowledge` | ❌ | ❌ | ❌ | ✅ 23 L | **⚠️ Misaligned** |
| `foundry-evals` | ❌ | ❌ | ❌ | ❌ | **⚠️ No instructions** |

---

## Critical Issues

These actively mislead AI agents or produce broken code.

---

### ~~1. Org family table description of `block-library` is completely wrong~~ ✅ Fixed

**File:** `.github/.github/copilot-instructions.md`, line 49
**Severity:** Critical — any agent reading org context will generate wrong architecture for `block-library`

**What the org says:**
```
| `block-library` | Web dashboard for AutoCAD block libraries with Supabase backend | React, TypeScript, PySide6 |
```

**What the repo actually is** (from `block-library/.github/copilot-instructions.md`):
- A **Tauri 2 desktop app**, not a web dashboard
- Data layer: **Google Drive** source of truth + **SQLite** local cache — no network backend
- Stack: React 19 + Vite + Three.js + React Three Fiber
- Explicitly forbidden: `No Supabase. No Postgres. No Docker. No nginx.`
- No PySide6 — explicitly a retired pattern

This is a full-stack architectural mismatch. An agent consulting the org file would describe `block-library` entirely wrong and suggest Supabase patterns that are explicitly banned in that repo.

**Fix:** Update org family table line 49:
```markdown
| `block-library` | Tauri 2 desktop DXF viewer with Google Drive catalog sync and SQLite local cache | Tauri 2.0, React, Three.js, Rust |
```

---

### ~~2. `block-library` uses the Tauri 1 `isTauri` guard~~ ✅ Fixed

**File:** `block-library/.github/copilot-instructions.md`, line 38
**Severity:** Critical — code written following this example will silently fail on Tauri 2

**What the repo instructs:**
```ts
const isTauri = typeof window !== 'undefined' && '__TAURI__' in window
```

**Org standard** (`.github/.github/copilot-instructions.md`, line 66):
```ts
const isTauri = typeof window !== "undefined" && "__TAURI_INTERNALS__" in window
```

`__TAURI__` is the Tauri 1 internals key. Tauri 2 exposes `__TAURI_INTERNALS__`. `batch-fnr` uses the correct Tauri 2 form. Any AI session using `block-library` instructions as a reference will produce a guard that evaluates to `false` in a live Tauri 2 app, silently disabling all IPC calls.

**Fix:** Update `block-library/.github/copilot-instructions.md` line 38:
```ts
const isTauri = typeof window !== 'undefined' && '__TAURI_INTERNALS__' in window
```

---

### ~~3. `docx.instructions.md` is a 1-line empty stub~~ ✅ Fixed

**File:** `.github/.github/instructions/docx.instructions.md`
**Severity:** Significant for `Transmittal-Builder` — the path-scoped instruction that auto-loads DOCX guidance is empty

The skill file `docs/skills/DOCX.md` is rich and complete (255 lines covering `python-docx`, rendering workflows, OOXML patching, QA gates, scripts, and task playbooks). However, the path-scoped instruction file that auto-loads alongside it — `docx.instructions.md` — is a 1-line stub with no content.

All other instruction files in this directory (`python.instructions.md`, `rust.instructions.md`, `tauri.instructions.md`, etc.) have 14–46 lines of `applyTo:` frontmatter plus MUST/NEVER rules that reference the matching skill file. This one has none. The skill exists; nothing directs agents to read it.

**Fix:** Populate `docx.instructions.md` with at minimum:
```markdown
---
applyTo: "**/templates/**,**/*.docx,**/docx*"
---

# DOCX — Chamber 19 rules

Read `docs/skills/DOCX.md` in this repo before writing any Word template or render code.

- **MUST** use `python-docx` for all template manipulation in the transmittal-builder Python sidecar.
- **MUST** call `render_docx.py` and visually inspect page PNGs before shipping any DOCX change.
- **MUST** call `print(..., flush=True)` for all sidecar output — same as all Python sidecars.
- **NEVER** call COM/Word automation from the Tauri process — all DOCX work lives in the Python sidecar.
- **NEVER** hardcode content strings into the `.docx` template file — treat it as a layout artifact only.
```

---

## Significant Issues

These create gaps where AI agents work without appropriate context loaded.

---

### ~~4. `autocad-knowledge` has no `.github/` directory~~ ✅ Fixed

**Severity:** Significant — AI agents working in this repo load org instructions but not repo-specific constraints

The repo has a solid `AGENTS.md` (23 lines covering authoritative-sources-only, citation requirements, no speculation, API surface boundaries). However `AGENTS.md` is not loaded by GitHub Copilot — only `.github/copilot-instructions.md` is.

When an agent edits `.cs` files here, the org's `autocad-dotnet.instructions.md` applies (transaction patterns, Copy Local, etc.), but the knowledge-base-specific constraints are invisible: no "authoritative sources only", no citation rules, no "do not invent patterns", no domain boundary labelling. Given that this repo is the source of truth for AI-generated AutoCAD code across the org, the accuracy constraints are the most important ones.

**Fix:** Create `autocad-knowledge/.github/copilot-instructions.md`:
```markdown
# AutoCAD Knowledge Base — Copilot Instructions

> **Repo:** `chamber-19/autocad-knowledge`
> Defer to org `.github/copilot-instructions.md` for family-wide rules.
> This repo is the source of truth for AutoCAD patterns consumed by AI agents — accuracy is critical.

- **MUST** cite the source of every pattern (Autodesk docs, verified training material, or working code). Format: `[id†Lstart-Lend]`.
- **MUST** target .NET 8 and AutoCAD 2026/2027 APIs unless a section is explicitly labelled for an older version.
- **NEVER** invent or speculate on API behaviour. If behaviour is undocumented but observed, record it in `gotchas.md` with repro steps.
- **NEVER** add COM automation as a primary pattern — COM is last-resort gotcha context only.
- **NEVER** add patterns for third-party verticals (Civil 3D, Revit, Plant 3D) — this knowledge base covers AutoCAD only.
- **NEVER** alter logic in copied training lab code — copy exactly and document what it demonstrates.

All rules in `AGENTS.md` apply here.
```

---

### ~~5. `foundry-evals` has no instruction surface at all~~ ✅ Fixed

**Severity:** Significant — zero guidance for eval set structure, labelling conventions, or completeness requirements

The repo's only content is `dep-reviewer/historical-prs.csv`. No `.github/`, no `AGENTS.md`, no `copilot-instructions.md`. The org's `copilot-instructions.md` explicitly states: "NEVER ship an LLM-backed agent without a labelled eval set. The eval set is the contract." But the repo hosting those eval sets carries no instructions about what a complete, valid eval set looks like.

**Fix:** Create `foundry-evals/.github/copilot-instructions.md`:
```markdown
# Foundry Evals — Copilot Instructions

> **Repo:** `chamber-19/foundry-evals`
> Eval sets are the quality contract for every Foundry agent.
> See `Foundry/.github/copilot-instructions.md` for the agent design contract these validate.

- **MUST** have ≥ 20 hand-labelled examples per agent before write actions are enabled on that agent.
- **MUST** label each example: input, expected output, verdict (`pass`/`fail`), and the rule being tested.
- **NEVER** generate labels from a model — all labels must be human-verified.
- Each agent's eval set lives under `<agent-name>/` (e.g., `dep-reviewer/`).
- `historical-prs.csv` is ground-truth — do not rewrite rows, only append.
```

---

### ~~6. `batch-fnr` and `foundry-evals` are absent from the org family table~~ ✅ Fixed

**File:** `.github/.github/copilot-instructions.md`, family table (lines 39–50)

`batch-fnr` is a fully-built Tauri 2 app with an 88-line `copilot-instructions.md` and a detailed 97-line `AGENTS.md` — but it does not appear in the org family table. `foundry-evals` is likewise absent. An AI agent asked to work across Chamber 19 repos would not know these repos exist from the org file alone.

**Fix:** Add to the org family table:
```markdown
| `batch-fnr` | Batch DXF Find-and-Replace — Tauri 2 desktop app with headless .NET AutoCAD sidecar | Tauri 2.0, Rust, React, .NET |
| `foundry-evals` | Hand-labelled eval sets for all Foundry agents | CSV, Markdown |
```

---

### ~~7. `markdown.instructions` is missing the `.md` extension~~ ✅ Fixed

**File:** `.github/.github/instructions/markdown.instructions`

Every other instruction file in this directory uses a `.md` extension (`python.instructions.md`, `rust.instructions.md`, `tauri.instructions.md`, etc.). This file is named `markdown.instructions` with no extension. The content and `applyTo: "**/*.md"` frontmatter are correct. The missing extension is inconsistent and may affect file discovery in some tooling that relies on extension filtering.

**Fix:** Rename to `markdown.instructions.md` to match the rest of the directory.

---

## Minor Issues

Low priority — cleanup or polish only.

---

### ~~8. Foundry has no `.github/prompts/` directory~~ ✅ Fixed

`Foundry` is the most operationally complex repo (agent broker, eval discipline, shadow→write promotion pipeline) but has no prompts for repeatable workflows. All other consumer repos that need multi-step procedures have at least one prompt.

**Fix:** Create `Foundry/.github/prompts/create-agent-eval.prompt.md`:
```markdown
---
mode: agent
description: Build a labelled eval set for a Foundry agent. Required before write actions are enabled.
---

# Create agent eval set

You are building a labelled eval set for a Foundry agent. Ask the user for the agent name (e.g. `dep-reviewer`) if not provided.

The eval set is the quality contract. The org rule is: **≥ 20 hand-labelled examples per agent before write actions are enabled on that agent.**

## What a valid example contains

Each example must have four fields:

| Field | Description |
|---|---|
| `input` | The raw agent input — typically a webhook payload, PR metadata, or structured request |
| `expected_output` | The exact structured JSON the agent should produce |
| `verdict` | `pass` or `fail` — whether the agent currently produces the expected output |
| `rule` | The rule being tested (e.g. "semver bump detection", "ecosystem detection", "fail-open on Ollama unavailable") |

Labels must be human-verified. **NEVER** generate labels from a model.

## Procedure

### Step 1 — Identify the agent

Confirm the agent name and its location under `evals/<agent-name>/` in `foundry-evals`.

### Step 2 — Determine rule coverage

Read the agent's rule engine. List every verdict subcategory the rule engine can produce. The eval set must cover every subcategory.

### Step 3 — Source raw inputs

Collect real inputs from `dep-reviewer/historical-prs.csv` or equivalent ground-truth source. Use at least one example per rule subcategory, plus adversarial cases (malformed input, missing fields, Ollama unavailable).

### Step 4 — Label each example

For each input:

1. Determine the correct `expected_output` by applying the rules manually.
2. Run the agent against the input if available. Record the actual output.
3. Set `verdict` to `pass` if actual output matches expected, `fail` otherwise.
4. Record the `rule` being tested.

Do not autogenerate `expected_output` from the agent itself — that produces circular labels.

### Step 5 — Write the eval file

Create `evals/<agent-name>/eval.yaml` (or `.csv` if the agent already uses CSV). Minimum schema:

\`\`\`yaml
- input: <raw input>
  expected_output: <json string>
  verdict: pass
  rule: <rule name>
\`\`\`

### Step 6 — Verify count and coverage

Count examples. Must be ≥ 20. Must cover every rule subcategory at least once. If coverage is incomplete, add targeted examples.

### Step 7 — Report

Report:

1. Agent name and eval file path
2. Total example count
3. Rule subcategories covered (list them)
4. Any subcategory with no passing examples (these block promotion)
```

**Fix:** Create `Foundry/.github/prompts/promote-agent.prompt.md`:
```markdown
---
mode: agent
description: Promote a Foundry agent from shadow mode to write mode. Runs a pre-promotion checklist.
---

# Promote agent to write mode

You are verifying that a Foundry agent is ready to move from shadow mode to write mode. Ask the user for the agent name if not provided.

Shadow mode is the default state for any new agent. Promotion is a deliberate decision — work through this checklist completely before recommending promotion.

## Checklist

### 1. Eval set size

- [ ] `evals/<agent-name>/` in `foundry-evals` contains ≥ 20 hand-labelled examples.
- [ ] All labels are human-verified — not generated from the agent itself.

### 2. Latest eval run

- [ ] All examples pass on the current agent version (`verdict: pass` for every row).
- [ ] No regressions since the previous eval run.

### 3. Deterministic checks layer

- [ ] The agent runs deterministic pre-checks before any LLM call (semver parsing, ecosystem detection, special-case lookups, etc.).
- [ ] Pre-checks are unit-tested independently of the LLM.

### 4. LLM extraction fail-open

- [ ] The agent fails open to `needs human review` if Ollama is unavailable.
- [ ] The agent fails open to `needs human review` if the LLM returns a schema-invalid response after one retry.
- [ ] The agent does not auto-approve, auto-merge, or skip notification on degraded state.

### 5. Rule engine coverage

- [ ] The rule engine produces a verdict for every subcategory in the eval set.
- [ ] Every verdict subcategory has ≥ 1 passing example in the eval set.
- [ ] No subcategory produces an unhandled exception.

### 6. Shadow mode observation period

- [ ] Agent has run in shadow mode (post comments/notifications, no write actions) for ≥ 14 days.
- [ ] Shadow mode output has been reviewed at least once per week during that period.
- [ ] No incorrect verdicts were observed that were not subsequently fixed and re-evaluated.

### 7. Notification path

- [ ] The notification path (GitHub comment or Discord message) has been verified end-to-end in shadow mode.
- [ ] Notifications reach the correct channel or thread.

## Promotion PR

When all checklist items are confirmed, open a PR that:

1. Changes the agent's shadow mode flag to `false` in `foundry.settings.json` (or equivalent config).
2. Attaches the eval run output as a PR comment.
3. References this checklist in the PR description.

Title: `feat(agents): promote <agent-name> to write mode`

## Non-goals

- Do not promote if any checklist item is incomplete — partial promotion is not allowed.
- Do not modify agent logic in the promotion PR.
- Do not combine promotion with feature work.
```

---

### 9. Foundry skills directory has retired archive stubs

**Files:** `Foundry/.github/skills/ml-pipeline.md` and `Foundry/.github/skills/scoring-engine.md`

Both are 3-line files headed "Historical archive — removed." The retirement reason is already documented in three better places: `docs/memory.md` in the org repo, `Foundry/.github/copilot-instructions.md`'s "Strip and do not reintroduce" section, and the org `copilot-instructions.md`'s pushback patterns. These stubs add noise without adding value.

**Optional action:** Delete both files. The "never reintroduce" rule is already load-bearing in the files that matter.

---

## Fix Priority

| # | Issue | File to change |
|---|---|---|
| ~~1~~ ✅ | ~~Org family table wrong for `block-library`~~ | ~~`.github/.github/copilot-instructions.md` line 49~~ |
| ~~2~~ ✅ | ~~`block-library` Tauri 1 `isTauri` guard~~ | ~~`block-library/.github/copilot-instructions.md` line 38~~ |
| ~~3~~ ✅ | ~~`docx.instructions.md` empty stub~~ | ~~`.github/.github/instructions/docx.instructions.md`~~ |
| ~~4~~ ✅ | ~~`autocad-knowledge` missing `.github/`~~ | ~~Create `autocad-knowledge/.github/copilot-instructions.md`~~ |
| ~~5~~ ✅ | ~~`foundry-evals` missing `.github/`~~ | ~~Create `foundry-evals/.github/copilot-instructions.md` — verbatim content above~~ |
| ~~6~~ ✅ | ~~`batch-fnr` + `foundry-evals` absent from family table~~ | ~~`.github/.github/copilot-instructions.md` family table~~ |
| ~~7~~ ✅ | ~~`markdown.instructions` missing `.md` extension~~ | ~~Rename to `markdown.instructions.md`~~ |
| ~~8~~ ✅ | ~~Foundry lacks prompts~~ | ~~Create `Foundry/.github/prompts/create-agent-eval.prompt.md` and `promote-agent.prompt.md` — verbatim content above~~ |
| 9 | Foundry retired skill stubs | Delete `ml-pipeline.md`, `scoring-engine.md` (optional) |

---

## What Is Working Well

- **Org inheritance model is sound.** MUST/NEVER/PREFER contract keywords are used consistently across all 7 repos that have `copilot-instructions.md`.
- **Toolkit pin discipline is enforced.** `Transmittal-Builder` (5-pin) and `Drawing-List-Manager`/`launcher` (4-pin) each have correct, distinct `consume-toolkit-bump.prompt.md` files with the right pin counts. The `toolkit-pin-check.yml` CI workflow exists.
- **Single-purpose repos are well-constrained.** `batch-fnr` and `block-library` each carry explicit forbidden-reintroduction lists — retired patterns are named, not just implied.
- **Foundry's agent contract is detailed.** Deterministic → LLM extraction → rules pipeline, eval-set-first discipline, fail-open semantics, and no remote LLM policy are all clearly stated.
- **Path-scoped instructions are consistent.** All six working instruction files (`rust`, `python`, `tauri`, `autocad-dotnet`, `vba-excel`, `markdown`) use `applyTo:` frontmatter correctly and reference the matching skill file in `docs/skills/`.
- **Skill files are rich.** `docs/skills/` contains full, well-structured reference docs for every language and domain. `DOCX.md` in particular is comprehensive (255 lines) — it just needs the path-scoped instruction stub fixed to surface it automatically.
- **Institutional memory is live.** `docs/memory.md` has real incident records (sidecar flush hang, Copy Local crash, COM deadlock, lockfile drift) that trace directly to rules in the instruction files.
