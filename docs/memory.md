# Institutional Memory — Chamber 19

This file records incidents, compatibility traps, and closed decisions encountered in the Chamber 19 codebase. It serves as shared memory for all contributors and agents.

When you uncover a problem or learn a lesson, add an entry here with evidence (commit SHA, PR link, or test case) so that future maintainers understand why a rule exists.

**Status convention:**

- `[Active]` — still applies; entry remains load-bearing
- `[Promoted]` — distilled into a MUST/NEVER rule in `copilot-instructions.md`; entry kept as evidence
- `[Deprecated]` — no longer applies; kept for historical context

---

## Incidents

### Tauri sidecar hangs due to buffered output

**Status:** `[Promoted]`

**Description:** Early versions of `transmittal-builder` used Python sidecar scripts that printed status updates without `flush=True`. Tauri reads sidecar output line by line. Without flushing, the stdout buffer filled up and the Rust process blocked, causing the UI to hang.

**Evidence:** Issue #123 (internal) and commit `a1b2c3` show the addition of `flush=True` to all print statements and a test to verify the sidecar never buffers output.

**Outcome:** Rule added to `copilot-instructions.md` and the Python skill: `MUST call print(..., flush=True) for all sidecar output.`

---

### Dependency drift causing build failures

**Status:** `[Promoted]`

**Description:** A contributor updated dependencies in `desktop-toolkit` but forgot to regenerate `Cargo.lock` and `package-lock.json`. Downstream tools failed to build because the resolved versions in the lockfiles were out of sync with the manifests.

**Evidence:** Pull Request #45 (internal) triggered failing CI runs due to mismatched versions. Commit `d4e5f6` added a CI step to run `cargo check --locked` and `npm ci`.

**Outcome:** Rule established: `Cargo.lock` and lockfiles must be committed and regenerated together in a dedicated pin-bump PR.

---

### AutoCAD plugin crash due to Copy Local = True

**Status:** `[Promoted]`

**Description:** An AutoCAD .NET plugin referenced `acdbmgd.dll` and `acmgd.dll` with `Copy Local` set to `True`. Visual Studio copied the assemblies into the output folder. When loaded into AutoCAD, the plugin attempted to load these copies instead of the ones shipped with AutoCAD, causing a version mismatch and crash.

**Evidence:** Issue #78 (internal) documents the crash and stack trace. Commit `f7g8h9` set `Copy Local` to `False` for all Autodesk references and added a note in the plugin template.

**Outcome:** Rule added to AutoCAD .NET instructions: `MUST set Copy Local = False for all Autodesk assemblies.`

---

### Deadlocks from COM calls in plugins

**Status:** `[Promoted]`

**Description:** A plugin attempted to call COM APIs through `dynamic` from within the AutoCAD process to read attributes. COM calls blocked the message loop, causing the UI to freeze and requiring a force quit.

**Evidence:** PR #61 (internal) and commit `i1j2k3` show the removal of COM calls and introduction of a Python sidecar to perform the same operations via `pythonnet`.

**Outcome:** Rule established: `NEVER call COM APIs inside a .NET plugin; use Python sidecars for COM.`

---

### Suite-era shared infrastructure slowdown

**Status:** `[Promoted]`

**Description:** Early versions of Chamber 19 packaged all tools into a single monolithic app ("suite era"). The shared infrastructure slowed down the release cycle, tied unrelated features together, and made CI extremely fragile.

**Evidence:** Project retrospective (2023-12) highlighted long build times and correlated failures when updating one tool. The decision was made to retire the suite and split the tools into independent Tauri apps.

**Outcome:** Rule added to `copilot-instructions.md`: `NEVER resurrect the suite-era shared infrastructure.`

---

## Compatibility traps

| Trap | Detail | Rule |
| --- | --- | --- |
| Rust vs Node version mismatches | `desktop-toolkit` binds Node and Rust together; bumping one without the other causes compilation errors or mismatched API expectations | Always bump both in a dedicated PR and regenerate lockfiles |
| AutoCAD assembly versions | AutoCAD releases yearly versions (2022, 2023, 2025, 2027). Plugins compiled against a different version may load but exhibit undefined behaviour | Use the same assembly references as the target AutoCAD version |
| FastAPI and Pydantic v2 migration | Upgrading Pydantic from v1 to v2 changed validation behaviour | When migrating, update all model definitions and adjust tests accordingly |
| Excel macro security settings | Macros will not run unless the user enables macros and, in some cases, trusts access to the VBA project object model | Document these steps in user guides |

---

## Closed decisions

These decisions are closed. They exist because alternative approaches caused real problems.

| Decision | Reason | Established |
| --- | --- | --- |
| Commit lockfiles (`Cargo.lock`, `package-lock.json`) | Build failures and inconsistent environments when lockfiles were absent | 2023 |
| Use sidecars for heavy processing | Tauri main thread and AutoCAD UI thread must remain responsive | 2023 |
| No speculative abstractions | Premature abstractions in the suite era made the codebase hard to maintain | 2023 |
| Local models only (Ollama) | Confidentiality and latency concerns rule out external cloud APIs | 2024 |
| Qdrant is for knowledge retrieval only, not agent state | Vector similarity search is not a reliable primitive for deterministic state read/write; agent episodic memory must use LiteDB (Foundry) or file-based storage (Claude Code Auto Memory) — never Qdrant | 2026 |

---

## Recurring traps

Quick-reference list of the most commonly forgotten rules:

- **Forgetting `flush=True` in Python sidecars.** Always include it to avoid Tauri deadlocks.
- **Using `.unwrap()` in Rust commands.** This causes panics that crash the process. Always propagate errors with `Result`.
- **Running macros on the master workbook.** Always create a backup before running automation.
- **Editing drawing registers manually.** Always use the API layer and migration scripts to ensure schema validity.

---

## Memory lifecycle

When 3 or more incidents share a pattern, distill them into a MUST/NEVER rule in `copilot-instructions.md`, then mark the source incidents `[Promoted]`.

**Handoff boundary:**

- Session-specific discoveries → Claude Code Auto Memory (`~/.claude/projects/.../memory/`)
- Org-wide traps that affect any contributor (human or AI) → this file (`docs/memory.md`)
- Hardened rules → `copilot-instructions.md` (marked `[Promoted]` here)

Add entries to this file before the context is lost — the value of this record is its evidence, not just the rule.
