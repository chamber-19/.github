# PowerShell Skill

Read this skill when writing, reviewing, or updating any PowerShell script (`.ps1`, `.psm1`) across Chamber 19 repos — primarily `scripts/` in `.github`.

---

## Mental model

PowerShell scripts in Chamber 19 are operational tooling: they reconcile state, run CI checks, and automate org maintenance. They are not interactive shells — they are commands that run unattended in GitHub Actions and locally without prompts.

Three rules that override everything else:

1. **Approved verbs only.** Run `Get-Verb` to see the full list. Using an unapproved verb triggers PSScriptAnalyzer `PSUseApprovedVerbs` warnings in CI and confuses tab-completion.
2. **`[switch]` not `[bool]`** for boolean flags. `[bool]$Flag` cannot be set from the command line without assignment syntax; `[switch]$Flag` is natural PowerShell.
3. **`$ErrorActionPreference = "Stop"`** at the top of every script. Silent failures are bugs.

---

## Non-negotiable patterns

### Verb-Noun naming

Use only approved PowerShell verbs. Run `Get-Verb` to verify any verb before using it.

Common replacements for unapproved verbs in Chamber 19 scripts:

| Use this (approved) | Not this (unapproved) |
| --- | --- |
| `ConvertTo-`, `ConvertFrom-` | `Escape-`, `Encode-`, `Format-` (when converting) |
| `Update-` | `Replace-` |
| `Get-` | `Fetch-`, `Retrieve-` |
| `Set-` | `Write-` (when setting state) |
| `Invoke-` | `Run-`, `Execute-`, `Call-` |
| `Assert-` | `Check-`, `Ensure-` (when asserting a hard invariant) |
| `Build-` | `Make-`, `Create-` (when constructing a structure) |
| `Show-` | `Display-`, `Print-` |

`Format-` is an approved verb only in the context of formatting output — not for general string transformation (use `ConvertTo-` instead).

### Function structure

Every named function must have `[CmdletBinding()]` and a `param()` block:

```powershell
function Get-RepoMetadata {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    process {
        # ...
    }
}
```

For internal helper functions that are not pipeline-facing, `[CmdletBinding()]` is optional, but `param()` is still required.

### Switch parameters

```powershell
# CORRECT
[switch]$DryRun

# WRONG — [bool] requires explicit $true/$false on the command line
[bool]$DryRun
```

Test switch state with `.IsPresent`:

```powershell
if ($DryRun.IsPresent) {
    Write-Host "Dry run — no changes written."
}
```

### Error handling

```powershell
$ErrorActionPreference = "Stop"   # always at script top

try {
    $result = Invoke-GitHubApi -Path "/repos/$Org/$Name"
}
catch {
    throw "GitHub API request failed for '$Name': $($_.Exception.Message)"
}
```

In advanced functions with `[CmdletBinding()]`, prefer `$PSCmdlet.WriteError()` and `$PSCmdlet.ThrowTerminatingError()` over bare `Write-Error` and `throw`.

Construct a proper `ErrorRecord` when using these:

```powershell
$errorRecord = [System.Management.Automation.ErrorRecord]::new(
    $_.Exception,
    'GitHubApiFailed',
    [System.Management.Automation.ErrorCategory]::ConnectionError,
    $Path
)
$PSCmdlet.ThrowTerminatingError($errorRecord)
```

### Automatic variable names to avoid

PowerShell has a set of automatic variables (`$Matches`, `$Error`, `$Args`, `$Input`, `$PSBoundParameters`, etc.) that the runtime sets automatically. Assigning to them may silently overwrite runtime state and produce hard-to-diagnose bugs.

`$Matches` is the most commonly hit: it is populated by the `-match` and `-replace` operators. If you store regex results in a variable named `$matches`, PSScriptAnalyzer will warn and the value may be overwritten unexpectedly on the next `-match` call.

```powershell
# WRONG — $matches is an automatic variable
$matches = $regex.Matches($line)

# CORRECT — use a distinct name
$regexMatches = $regex.Matches($line)
$skillMatches = $skillReferenceRegex.Matches($line)
```

Common automatic variables to never assign to:

| Variable | Set by |
| --- | --- |
| `$Matches` | `-match` and `-replace` operators |
| `$Error` | Any terminating error |
| `$Args` | Non-named function arguments |
| `$Input` | Pipeline input to a function |
| `$PSItem` / `$_` | Current pipeline object |

### Output discipline

- Return `[PSCustomObject]@{...}` for structured data, not text strings.
- Use `Write-Verbose` for operational messages (shown with `-Verbose`).
- Use `Write-Host` only for human-readable UI output (not piped, not data).
- Pipe `List<T>.Add()` results to `| Out-Null` — the method returns the index.

```powershell
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("| Header |") | Out-Null      # CORRECT — suppresses index output
$lines.Add("| --- |") | Out-Null
```

---

## Common patterns in Chamber 19 scripts

### GitHub API via `Invoke-RestMethod`

```powershell
function Get-GitHubHeaders {
    $headers = @{
        Accept = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
        "User-Agent" = "chamber-19-automation"
    }
    if ($env:GITHUB_TOKEN) {
        $headers.Authorization = "Bearer $($env:GITHUB_TOKEN)"
    }
    return $headers
}

function Invoke-GitHubApi {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    $uri = "https://api.github.com$Path"
    try {
        return Invoke-RestMethod -Method Get -Uri $uri -Headers (Get-GitHubHeaders)
    }
    catch {
        throw "GitHub API request failed for '$Path': $($_.Exception.Message)"
    }
}
```

### Dry-run / check pattern

All write-capable scripts expose `-DryRun` and optionally `-Check`:

```powershell
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Check
)

if ($DryRun.IsPresent) {
    Write-Host "Would update: $($updatedFiles -join ', ')" -ForegroundColor Yellow
    if ($Check.IsPresent) { exit 1 }
}
else {
    [System.IO.File]::WriteAllText($targetFile, $updatedContent)
    Write-Host "Updated $targetFile"
}
```

### YAML parsing (no native module)

PowerShell has no built-in YAML parser. Use this compatibility shim:

```powershell
function ConvertFrom-YamlCompat {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Yaml
    )

    if (Get-Command -Name ConvertFrom-Yaml -ErrorAction SilentlyContinue) {
        return ConvertFrom-Yaml -Yaml $Yaml
    }

    # Fallback: Python + PyYAML
    $pythonScript = @"
import json, sys, yaml
print(json.dumps(yaml.safe_load(sys.stdin.read())))
"@
    $json = $Yaml | & python -c $pythonScript
    return $json | ConvertFrom-Json
}
```

### Markdown table separator (Chamber 19 standard)

Table separators MUST use `| --- |` with spaces — not `|---|` (no spaces). The Markdown skill and `markdown.instructions.md` both enforce this.

```powershell
# CORRECT — generates | --- | --- | --- |
$separator = "| $(@('---') * $columns.Count -join ' | ') |"

# WRONG — generates |---|---|---| which fails the linter
$separator = "|$((@('---') * $columns.Count) -join '|')|"
```

---

## PowerShellForGitHub

`PowerShellForGitHub` is Microsoft's official PowerShell module for the GitHub API. For complex scripts that need paginated queries, retries, or fine-grained org/team management, prefer it over raw `Invoke-RestMethod`.

- **Repo:** <https://github.com/microsoft/PowerShellForGitHub>
- **Install:** `Install-Module -Name PowerShellForGitHub -Scope CurrentUser`
- **Auth:** `Set-GitHubAuthentication` (stores token in encrypted credential store) or via `$env:GITHUB_TOKEN`

### When to use it

| Use `PowerShellForGitHub` | Use `Invoke-RestMethod` directly |
| --- | --- |
| Paginated queries (repos, issues, PRs) | One-shot lightweight reads |
| Org/team/label management scripts | CI scripts where no module install is available |
| Complex workflows needing auto-retry | Simple single-endpoint data fetches |
| Cross-repo settings enforcement | Local-only tools |

### Key cmdlets

```powershell
# Configuration
Set-GitHubConfiguration -SessionOnly -DefaultOwnerName "chamber-19"

# Repos
Get-GitHubRepository -OrganizationName "chamber-19"
Get-GitHubRepository -OwnerName "chamber-19" -RepositoryName "launcher"

# Issues and PRs
Get-GitHubIssue -OwnerName "chamber-19" -RepositoryName "launcher" -State Open
Get-GitHubPullRequest -OwnerName "chamber-19" -RepositoryName "launcher"

# Labels
Get-GitHubLabel -OwnerName "chamber-19" -RepositoryName "launcher"
New-GitHubLabel -OwnerName "chamber-19" -RepositoryName "launcher" -Name "bug" -Color "d73a4a"
```

---

## Chamber 19 specifics

- All org automation scripts live in `.github/scripts/` in the `.github` repo.
- Scripts run under PowerShell 7+ — enforce this with a version check at the top:

  ```powershell
  function Assert-PowerShellVersion {
      if ($PSVersionTable.PSVersion.Major -lt 7) {
          throw "PowerShell 7+ is required."
      }
  }

  ```

- GitHub Actions workflows use `pwsh` (PowerShell Core), not `powershell` (Windows PowerShell 5.1).
- Scripts that call the GitHub API must read `$env:GITHUB_TOKEN` — never hardcode tokens.
- The `-DryRun` and `-Check` switches are the standard pattern for any script that writes files or calls GitHub write APIs.

---

## Failure modes

| Symptom | Fix |
| --- | --- |
| PSScriptAnalyzer `PSUseApprovedVerbs` warning | Rename function using an approved verb — check with `Get-Verb` |
| `[bool]$Flag` does not accept bare `-Flag` on command line | Change to `[switch]$Flag` |
| Script fails silently on error | Add `$ErrorActionPreference = "Stop"` at script top |
| `List<T>.Add()` output pollutes the pipeline | Pipe to `&#124; Out-Null` |
| Table separator generates `&#124;---&#124;---&#124;` | Use `"&#124; $(@('---') * $n -join ' &#124; ') &#124;"` pattern |
| YAML parse fails with no module | Use `ConvertFrom-YamlCompat` pattern with Python fallback |
| GitHub API calls fail in CI without auth | Ensure `$env:GITHUB_TOKEN` is set in the Actions step |
| PSScriptAnalyzer warns about assigning `$Matches` | `$Matches` is an automatic variable — rename to `$regexMatches` or similar |

---

## Quick reference

```powershell
# Verify a verb is approved
Get-Verb | Where-Object { $_.Verb -eq 'Update' }

# List all approved verbs
Get-Verb | Sort-Object Verb

# Check a script for verb violations (requires PSScriptAnalyzer)
Invoke-ScriptAnalyzer -Path .\script.ps1 -IncludeRule PSUseApprovedVerbs

# Install PowerShellForGitHub
Install-Module -Name PowerShellForGitHub -Scope CurrentUser

# Authenticate with a token
$env:GITHUB_TOKEN = "<token>"
Set-GitHubConfiguration -SessionOnly -DefaultOwnerName "chamber-19"
```

---

## Reference documentation

- [PowerShell approved verbs](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands)
- [About Functions Advanced Parameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters)
- [PSScriptAnalyzer rules](https://learn.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/rules/overview)
- [PowerShellForGitHub](https://github.com/microsoft/PowerShellForGitHub)
