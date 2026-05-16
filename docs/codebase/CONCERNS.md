# Codebase Concerns

This document records the highest-impact maintenance risks in the org-config repository, with concrete evidence paths.

## Core Sections (Required)

### 1) Top Risks (Prioritized)

| Severity | Concern | Evidence | Impact | Suggested action |
| --- | --- | --- | --- | --- |
| high | Family-manifest role/stack drift can overwrite curated table content on reconcile | `scripts/family-manifest.yml`, `scripts/reconcile-family-table.ps1` | Public/org guidance reverts on next automated reconciliation | Keep manifest authoritative and run dry-run reconcile in PR validation |
| medium | Managed PR body automation can overwrite human-authored sections if replacement scope is too broad | `.github/workflows/auto-pr-body-and-labels.yml` | Authors lose context in PR descriptions | Restrict automation to marked summary block only |
| medium | Codebase docs can become stale template output if scan/regeneration is skipped | `docs/codebase/*.md`, `docs/codebase/.codebase-scan.txt` | Onboarding docs become misleading | Regenerate scan output after structural changes and keep evidence-backed content only |

### 2) Technical Debt

List the most important debt items only.

| Debt item | Why it exists | Where | Risk if ignored | Suggested fix |
| --- | --- | --- | --- | --- |
| Legacy oversized instruction wrappers | Wrapper files were expanded before strict thin-wrapper discipline | `.github/instructions/powershell.instructions.md` | Contradiction between policy and repo state | Slim legacy wrappers incrementally when touched |
| Incomplete family-manifest coverage for new org repos | New repos were created without manifest updates | `scripts/reconcile-family-table.ps1` dry-run output | Reconcile checks fail and block automation | Add new repos with `needs-curation` status at creation time |

### 3) Security Concerns

| Risk | OWASP category (if applicable) | Evidence | Current mitigation | Gap |
| --- | --- | --- | --- | --- |
| Script-level token misuse risk in automation | A05: Security Misconfiguration | `scripts/reconcile-family-table.ps1`, `.github/workflows/fix-biome.yml` | Uses environment-provided tokens and GitHub App tokens | `[TODO]` Centralized secret-usage audit checklist |
| Unreviewed automation edits in bot PRs | N/A | `.github/workflows/fix-biome.yml`, `.github/workflows/fix-tailwind-canonical-vars.yml` | PR-based updates instead of direct push | Ensure reviewer gates remain enforced in branch protection |

### 4) Performance and Scaling Concerns

| Concern | Evidence | Current symptom | Scaling risk | Suggested improvement |
| --- | --- | --- | --- | --- |
| Org repo enumeration in reconcile script scales with total repos | `scripts/reconcile-family-table.ps1` (`Get-OrgRepoNames`) | More API pages as org grows | Slower reconciliation and higher API quota use | Cache or scope checks to known repo list when full-org diff is not required |

### 5) Fragile/High-Churn Areas

| Area | Why fragile | Churn signal | Safe change strategy |
| --- | --- | --- | --- |
| `.github/copilot-instructions.md` | Central policy file consumed org-wide | High churn in `docs/codebase/.codebase-scan.txt` history section | Keep edits minimal and reconcile-managed blocks script-driven |
| `scripts/reconcile-family-table.ps1` | Source of truth mutation logic | Multiple recent fixes for parsing and drift behavior | Add focused dry-run validation before and after edits |

### 6) `[ASK USER]` Questions

1. [ASK USER] Should all backend-service repos use a single approved role/stack wording standard in `scripts/family-manifest.yml`?

### 7) Evidence

- `docs/codebase/.codebase-scan.txt`
- `scripts/reconcile-family-table.ps1`
- `.github/workflows/auto-pr-body-and-labels.yml`
