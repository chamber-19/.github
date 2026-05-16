# AI tooling pilot success criteria

Written **before** the pilots start so future-us can't fudge the evaluation.

Review date: **3 months from pilot start** (set a calendar reminder).

---

## Pilot 1: Copilot code review on `desktop-toolkit`

**Scope:** Enable Copilot code review on `chamber-19/desktop-toolkit` only. Two-week trial.

**Success criteria (must meet BOTH to expand):**

- Caught **≥1 real issue** during the trial that a human reviewer would plausibly have missed.
- Generated **<3 false-positive comments per PR on average** across the trial period.

**Decision tree:**

- **Pass:** Expand to `transmittal-builder` next. Re-evaluate after another 2 weeks.
- **Fail:** Disable. Do not retry for 6 months.

---

## Pilot 2: Path-specific instruction files — CONCLUDED

**Original scope:** Add ONE file: `.github/instructions/powershell-release.instructions.md` with `applyTo: "scripts/**/*.ps1"`. Two-week trial.

**Outcome:** Expanded far beyond the original scope. The full `.github/instructions/` system is now built out with wrappers for Markdown, Python, Rust, Tauri, AutoCAD .NET, Biome, DOCX, acquire-codebase-knowledge, and AI-Ready. Each wrapper is thin (<3 KB), references the deep skill in `docs/skills/`, and loads automatically when matching file types are touched. Pilot is considered concluded — the feature is in production org-wide.

**Decision:** Path-specific instruction wrappers are permanent. All new skills in `docs/skills/` get a matching wrapper in `.github/instructions/`.

---

## Pilot 3 (deferred): Copilot Spaces

Do NOT pre-build. Build the first Space (Desktop Toolkit Consumers) only when you reach for it during a real chat session.

**Trigger:** You ask a cross-repo question in Copilot Chat that would obviously be answered better with a curated Space.

---

## Pilot 4 (deferred): Custom Copilot agents

Do NOT build. Reconsider only if you notice yourself typing the same multi-paragraph framing into the cloud agent ≥3 times in a month.

---

## Pilot 5: Claude Code skills + command parity system — CONCLUDED

**Scope:** Build a 1:1:1 parity system across `docs/skills/` (deep reference) + `.github/instructions/` (auto-injected wrappers) + `.claude/commands/` (slash commands). Each skill gets all three.

**Outcome:** All 13 skills have matching commands in the workspace `.claude/commands/` directory. Commands load the skill into context and apply it. Parity rule is enforced in both directions and documented in `CLAUDE.md` and `copilot-instructions.md`.

**Decision:** The three-layer parity system is permanent. CLAUDE.md enforces: new skill → new wrapper → new command; enforce in both directions. The skills registry table in `copilot-instructions.md` is the authoritative list.

---

## Pilot 6: Memory system layer — IN PROGRESS

**Scope:** Formalise the Chamber 19 AI memory system across its three physical layers:

1. **Session memory** — `copilot-instructions.md` + `CLAUDE.md` loaded each turn (injected working memory)
2. **Cross-session institutional memory** — `docs/memory.md` (incidents, compatibility traps, closed decisions)
3. **Claude Code Auto Memory** — `~/.claude/projects/.../memory/MEMORY.md` (project-specific session discoveries)

**Problem being solved:** `docs/memory.md` accumulates indefinitely with no mechanism to mark entries as promoted, deprecated, or stale. The "forgetting" step in the memory lifecycle is missing.

**Success criteria (must meet ALL to consider complete):**

- `docs/memory.md` has a clear status convention — entries can be marked `[Active]`, `[Promoted → rule in copilot-instructions.md]`, or `[Deprecated]` with a date.
- A documented consolidation trigger: when 3+ incidents share a pattern, distill into a MUST/NEVER rule and mark the source incidents as Promoted.
- The CLAUDE.md, copilot-instructions.md, and docs/memory.md are updated to document this lifecycle so any agent or contributor can follow it without asking.
- The Auto Memory system and `docs/memory.md` have a clear handoff boundary: session-specific discoveries stay in Auto Memory; org-wide traps that would affect any contributor (human or AI) get promoted to `docs/memory.md`.

**Decision tree:**

- **Pass:** Memory system is production-ready. Mark complete, move to Phase 0 of the roadmap.
- **Fail:** Identify which criteria weren't met and fix before proceeding.

---

## Evaluation log

| Date | Pilot | Result | Decision |
| --- | --- | --- | --- |
| 2026-05-10 | Pilot 2 | Concluded — expanded to full instructions system | Permanent; all new skills get a matching wrapper |
| 2026-05-10 | Pilot 5 | Concluded — 13 skills, 13 wrappers, 13 commands | Permanent; parity rule enforced in CLAUDE.md |
| — | Pilot 1 | Not yet evaluated | Awaiting trial data |
| — | Pilot 6 | In progress | — |
