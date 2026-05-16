# Technology Stack

This document summarizes the technology stack used to author, lint, and automate the Chamber 19 org-config repository.

## Core Sections (Required)

### 1) Runtime Summary

| Area | Value | Evidence |
| --- | --- | --- |
| Primary language | Markdown + YAML for policy and workflows | `README.md`, `.github/workflows/` |
| Runtime + version | PowerShell 7+ for maintenance scripts | `scripts/reconcile-family-table.ps1` (`Assert-PowerShellVersion`) |
| Package manager | npm (workflow tooling contexts only) | `.github/workflows/fix-biome.yml`, `.github/workflows/fix-tailwind-canonical-vars.yml` |
| Module/build system | GitHub Actions workflow orchestration | `.github/workflows/*.yml` |

### 2) Production Frameworks and Dependencies

List only high-impact production dependencies (frameworks, data, transport, auth).

| Dependency | Version | Role in system | Evidence |
| --- | --- | --- | --- |
| `actions/checkout` | `v4` | Repository checkout in CI workflows | `.github/workflows/*.yml` |
| `actions/github-script` | `v7` | PR-body generation and label automation | `.github/workflows/auto-pr-body-and-labels.yml` |
| `actions/create-github-app-token` | `v1` | App-token generation for cross-repo maintenance PRs | `.github/workflows/fix-biome.yml` |
| Python + `PyYAML` | `[TODO]` version depends on host | YAML fallback parsing path in reconcile script | `scripts/reconcile-family-table.ps1` |

### 3) Development Toolchain

| Tool | Purpose | Evidence |
| --- | --- | --- |
| `pwsh` | Run repo maintenance and lint scripts | `scripts/lint-org-config.ps1`, `scripts/reconcile-family-table.ps1` |
| `git` | Diffing and managed-block reconciliation validation | `scripts/reconcile-family-table.ps1` (`Show-Diff`) |
| `actionlint` (CI) | GitHub Actions syntax validation | `.github/workflows/lint-yaml.yml` |

### 4) Key Commands

```bash
pwsh -File scripts/lint-org-config.ps1
pwsh -File scripts/reconcile-family-table.ps1 -DryRun
pwsh -File scripts/reconcile-family-table.ps1
```

### 5) Environment and Config

- Config sources: `.github/copilot-instructions.md`, `AGENTS.md`, `.github/instructions/*.instructions.md`, `scripts/family-manifest.yml`
- Required env vars: `GITHUB_TOKEN` (optional but used for authenticated API calls), `ORG_BOT_APP_ID`, `ORG_BOT_APP_PRIVATE_KEY` (maintenance workflows)
- Deployment/runtime constraints: workflows run on GitHub-hosted runners; scripts require local PowerShell 7+ for deterministic local validation

### 6) Evidence

- `scripts/reconcile-family-table.ps1`
- `.github/workflows/fix-biome.yml`
- `.github/workflows/lint-org-config.yml`
