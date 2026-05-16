# Testing Patterns

This repository relies on script- and workflow-based validation rather than a traditional unit-test suite.

## Core Sections (Required)

### 1) Test Stack and Commands

- Primary test framework: `[TODO]` (no dedicated unit-test framework configured in repo root)
- Assertion/mocking tools: `[TODO]`
- Commands:

```bash
pwsh -File scripts/lint-org-config.ps1
pwsh -File scripts/reconcile-family-table.ps1 -DryRun
```

### 2) Test Layout

- Test file placement pattern: validation scripts in `scripts/`; workflow checks in `.github/workflows/`
- Naming convention: lint/reconcile scripts use verb-noun naming in PowerShell (`lint-org-config`, `reconcile-family-table`)
- Setup files and where they run: GitHub Actions workflow files orchestrate runtime setup (`.github/workflows/*.yml`)

### 3) Test Scope Matrix

| Scope | Covered? | Typical target | Notes |
| --- | --- | --- | --- |
| Unit | no | `[TODO]` | No unit-test harness currently configured |
| Integration | yes | script behavior against repo files and GitHub API | Covered via script execution and workflow jobs |
| E2E | partial | workflow automation across target repos | Maintenance workflows create PRs rather than direct writes |

### 4) Mocking and Isolation Strategy

- Main mocking approach: minimal; scripts run against real files and live APIs
- Isolation guarantees: dry-run mode in `reconcile-family-table.ps1` prevents file writes
- Common failure mode in tests: environment/tooling drift (missing parsers, missing secrets, missing called scripts)

### 5) Coverage and Quality Signals

- Coverage tool + threshold: `[TODO]` (not configured)
- Current reported coverage: `[TODO]`
- Known gaps/flaky areas: reusable workflows that assume script paths in caller repos

### 6) Evidence

- `scripts/lint-org-config.ps1`
- `scripts/reconcile-family-table.ps1`
- `.github/workflows/lint-org-config.yml`
