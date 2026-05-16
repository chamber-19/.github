# External Integrations

This document summarizes external systems this org-config repository integrates with for validation, reconciliation, and maintenance automation.

## Core Sections (Required)

### 1) Integration Inventory

| System | Type (API/DB/Queue/etc) | Purpose | Auth model | Criticality | Evidence |
| --- | --- | --- | --- | --- | --- |
| GitHub REST API | API | Repository metadata lookup and org repo enumeration in reconciliation | `GITHUB_TOKEN` bearer token when available | high | `scripts/reconcile-family-table.ps1` |
| GitHub Actions runtime | CI platform | Executes lint/reconcile/automation workflows | GitHub Actions provided token and app token | high | `.github/workflows/*.yml` |
| GitHub CLI (`gh`) | CLI API client | Creates and manages maintenance PRs in target repos | GitHub App token in workflow env | medium | `.github/workflows/fix-biome.yml`, `.github/workflows/fix-tailwind-canonical-vars.yml` |

### 2) Data Stores

| Store | Role | Access layer | Key risk | Evidence |
| --- | --- | --- | --- | --- |
| Git repository files | Canonical policy and generated outputs | `git` + workflow checkout steps | Drift between manifest and generated blocks | `scripts/family-manifest.yml`, `profile/README.md` |
| GitHub repository metadata | Validation source for manifest entries | `Invoke-RestMethod` in PowerShell script | API rate limit or auth failures | `scripts/reconcile-family-table.ps1` |

### 3) Secrets and Credentials Handling

- Credential sources: GitHub Actions secrets (`ORG_BOT_APP_ID`, `ORG_BOT_APP_PRIVATE_KEY`) and `GITHUB_TOKEN`
- Hardcoding checks: no hardcoded tokens observed in inspected scripts/workflows
- Rotation or lifecycle notes: `[TODO]` (handled at org secret-management level)

### 4) Reliability and Failure Behavior

- Retry/backoff behavior: `[TODO]` explicit retry policy not implemented in reconcile API calls
- Timeout policy: workflow/job-level defaults apply; no explicit custom timeout in reviewed scripts
- Circuit-breaker or fallback behavior: YAML parsing fallback from `ConvertFrom-Yaml` to Python+PyYAML in `scripts/reconcile-family-table.ps1`

### 5) Observability for Integrations

- Logging around external calls: yes (`Write-Host` validation status lines in reconciliation)
- Metrics/tracing coverage: no dedicated metrics backend in this repo
- Missing visibility gaps: no centralized telemetry for API error rates across maintenance workflows

### 6) Evidence

- `scripts/reconcile-family-table.ps1`
- `.github/workflows/fix-biome.yml`
- `.github/workflows/fix-tailwind-canonical-vars.yml`
