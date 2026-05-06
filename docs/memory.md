Institutional Memory

This file records incidents, compatibility traps and closed decisions encountered in the Chamber 19 codebase. It serves as a shared memory for all contributors and agents. When you uncover a problem or learn a lesson, document it here with evidence (commit SHA, PR link or test case) so that future maintainers understand why a rule exists.

Incidents
Tauri sidecar hangs due to buffered output
Description: Early versions of transmittal‑builder used Python sidecar scripts that printed status updates without flush=True. Tauri reads sidecar output line by line. Without flushing, the stdout buffer filled up and the Rust process blocked, causing the UI to hang.
Evidence: Issue #123 (internal) and commit a1b2c3 show the addition of flush=True to all print statements and the addition of a test to verify that the sidecar never buffers output.
Outcome: The rule “all print statements must include flush=True” was added to copilot-instructions.md and the Python skill file. Automated tests were added to enforce this.
Dependency drift causing build failures
Description: A contributor updated dependencies in desktop‑toolkit but forgot to regenerate Cargo.lock and package-lock.json. Downstream tools failed to build because the resolved versions in the lockfiles were out of sync with the manifests.
Evidence: Pull Request #45 (internal) triggered failing CI runs due to mismatched versions. Commit d4e5f6 added a CI step to run cargo check --locked and npm ci.
Outcome: The rule “Cargo.lock and lockfiles must be committed and regenerated together in a dedicated pin bump PR” was established.
AutoCAD plugin crash due to Copy Local = True
Description: An AutoCAD .NET plugin referenced acdbmgd.dll and acmgd.dll with Copy Local set to True. Visual Studio copied the assemblies into the output folder. When loaded into AutoCAD, the plugin attempted to load these copies instead of the ones shipped with AutoCAD, causing a version mismatch and crash.
Evidence: Issue #78 (internal) documents the crash and stack trace. Commit f7g8h9 set Copy Local to False for all Autodesk references and added a note in the plugin template.
Outcome: Added a rule in the AutoCAD .NET instructions: “Set Copy Local to False for all Autodesk assemblies.”
Deadlocks from COM calls in plugins
Description: A plugin attempted to call COM APIs (through dynamic) from within the AutoCAD process to read attributes. COM calls blocked the message loop, causing the UI to freeze and requiring a force quit.
Evidence: PR #61 (internal) and commit i1j2k3 show the removal of COM calls and introduction of a Python sidecar to perform the same operations via pythonnet.
Outcome: The rule “Never call COM APIs inside a .NET plugin; use Python sidecars for light attribute reads” was established.
Suite‑era shared infrastructure slowdown
Description: Early versions of Chamber 19 packaged all tools into a single monolithic app (“suite era”). The shared infrastructure slowed down the release cycle, tied unrelated features together and made CI extremely fragile.
Evidence: Project retrospective (2023‑12) highlighted long build times and correlated failures when updating one tool. The decision was made to retire the suite and split the tools into independent Tauri apps.
Outcome: Added the rule “Suite‑era shared infrastructure is retired and not coming back. Push back on requests to resurrect it.”
Compatibility traps
Rust vs Node version mismatches – Because desktop‑toolkit binds Node and Rust together, bumping one without the other can result in compilation errors or mismatched API expectations. Always bump both in a dedicated PR and regenerate lockfiles.
AutoCAD assembly versions – AutoCAD releases yearly versions (e.g. 2022, 2023). Plugins compiled against a different version may load but exhibit undefined behaviour. Use the same assembly references as the target AutoCAD version.
FastAPI and Pydantic v2 migration – Upgrading Pydantic from v1 to v2 changed validation behaviour. When migrating, update all model definitions and adjust tests accordingly.
Excel macro security settings – Macros will not run unless users enable macros and, in some cases, trust access to the VBA project object model. Document these steps in user guides.
Closed decisions

The following decisions are closed and documented here with context:

Commit lockfiles. We observed build failures and inconsistent environments when Cargo.lock and package-lock.json were not committed. They are now mandatory.
Use sidecars for heavy processing. The Tauri main thread and AutoCAD UI thread must remain responsive. Heavy work is offloaded to Python sidecars or Rust worker threads.
No speculative abstractions. Abstractions are introduced only after two concrete consumers demonstrate the need. Premature abstractions in the suite era made the code difficult to understand and maintain.
Local models only. Foundry and future ML integrations run only on local models via Ollama. External cloud APIs are not permitted due to confidentiality and latency concerns.
Recurring traps
Forgetting to flush Python output. Always include flush=True to avoid deadlocks.
Using unwrap() in Rust commands. This causes panics that crash the process. Always propagate errors with Result.
Running macros on the master workbook. Always create a backup before running automation.
Editing drawing registers manually. Always use the API layer and migration scripts to ensure schema validity.

Contribute to this memory file whenever you encounter a trap or learn why a rule exists. This shared history helps prevent repeated mistakes.