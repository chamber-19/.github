# Coding Conventions

This document captures repository-specific conventions used for documentation, scripts, and org-wide automation assets.

## Core Sections (Required)

### 1) Naming Rules

| Item | Rule | Example | Evidence |
| --- | --- | --- | --- |
| Files | Use descriptive kebab-case for workflow and prompt files | `auto-pr-body-and-labels.yml`, `add-to-learning.prompt.md` | `.github/workflows/`, `.github/prompts/` |
| Functions/methods | PowerShell functions use approved verb-noun naming | `Get-PythonCommand`, `ConvertFrom-YamlCompat` | `scripts/reconcile-family-table.ps1` |
| Types/interfaces | `[TODO]` not a typed-application repo | `[TODO]` | `[TODO]` |
| Constants/env vars | Upper snake case for environment variables | `GITHUB_TOKEN`, `ORG_BOT_APP_ID` | scripts/workflows where read |

### 2) Formatting and Linting

- Formatter: `[TODO]` (no root formatter config file in scan output)
- Linter: `scripts/lint-org-config.ps1` for org-specific policy checks
- Most relevant enforced rules: valid instruction frontmatter, resolvable skill references, family-table row requirements
- Run commands: `pwsh -File scripts/lint-org-config.ps1`

### 3) Import and Module Conventions

- Import grouping/order: YAML workflows generally keep `uses`/`with`/`env` grouped per step
- Alias vs relative import policy: not applicable for current script/document structure
- Public exports/barrel policy: not applicable

### 4) Error and Logging Conventions

- Error strategy by layer: PowerShell scripts set `$ErrorActionPreference = "Stop"` and throw explicit errors
- Logging style and required context fields: operational status logs use concise `Write-Host`/workflow log lines
- Sensitive-data redaction rules: secrets are passed via GitHub Actions secrets/env and never hardcoded in repo files

### 5) Testing Conventions

- Test file naming/location rule: validation is command-driven via scripts and workflows; no dedicated `tests/` tree
- Mocking strategy norm: limited mocking; rely on dry-run paths and CI execution
- Coverage expectation: `[TODO]`

### 6) Evidence

- `scripts/lint-org-config.ps1`
- `scripts/reconcile-family-table.ps1`
- `.github/instructions/markdown.instructions.md`
