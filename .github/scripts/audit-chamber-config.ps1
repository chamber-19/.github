[CmdletBinding()]
param(
    [string]$WorkspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
)

$ErrorActionPreference = "Stop"

# Repo names must match the actual GitHub repo names exactly (case-sensitive
# on Linux CI runners). Use the exact casing from github.com/chamber-19.
$repos = @(
    "launcher",
    "Foundry",
    "transmittal-builder",
    "Drawing-List-Manager",
    "desktop-toolkit",
    "IFA-IFC-Checklist",
    "block-library"
)

# Expected package ecosystems per repo — used to verify dependabot.yml coverage.
$expectedEcosystems = @{
    "launcher"             = @("cargo", "npm", "github-actions")
    "Foundry"              = @("nuget", "pip", "github-actions")
    "transmittal-builder"  = @("cargo", "npm", "pip", "github-actions")
    "Drawing-List-Manager" = @("cargo", "npm", "pip", "github-actions")
    "desktop-toolkit"      = @("cargo", "npm", "pip", "github-actions")
    "IFA-IFC-Checklist"    = @("github-actions")
    "block-library"        = @("npm", "pip", "github-actions")
}

$failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
    param([string]$Message)
    $failures.Add($Message) | Out-Null
}

function Assert-File {
    param(
        [string]$Repo,
        [string]$RelativePath
    )

    $path = Join-Path (Join-Path $WorkspaceRoot $Repo) $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        Add-Failure "$Repo missing $RelativePath"
    }
    return $path
}

function Assert-Contains {
    param(
        [string]$Repo,
        [string]$RelativePath,
        [string]$Pattern
    )

    $path = Join-Path (Join-Path $WorkspaceRoot $Repo) $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        Add-Failure "$Repo missing $RelativePath"
        return
    }

    $content = Get-Content -LiteralPath $path -Raw
    if ($content -notmatch [regex]::Escape($Pattern)) {
        Add-Failure "$Repo $RelativePath missing '$Pattern'"
    }
}

# ── Per-repo checks ──────────────────────────────────────────────────────────
foreach ($repo in $repos) {
    $repoRoot = Join-Path $WorkspaceRoot $repo
    if (-not (Test-Path -LiteralPath $repoRoot)) {
        Add-Failure "$repo repo not found under $WorkspaceRoot"
        continue
    }

    # Every repo must have these three files
    Assert-File $repo ".github/copilot-instructions.md" | Out-Null
    Assert-File $repo ".github/dependabot.yml" | Out-Null
    Assert-File $repo ".github/workflows/copilot-setup-steps.yml" | Out-Null

    # Every repo must have an AGENTS.md at the root
    Assert-File $repo "AGENTS.md" | Out-Null

    Assert-Contains $repo ".github/dependabot.yml" "version: 2"
    Assert-Contains $repo ".github/workflows/copilot-setup-steps.yml" "copilot-setup-steps:"

    foreach ($ecosystem in $expectedEcosystems[$repo]) {
        Assert-Contains $repo ".github/dependabot.yml" "package-ecosystem: `"$ecosystem`""
    }
}

# ── desktop-toolkit pin checks ───────────────────────────────────────────────
# Consumer repos that pin desktop-toolkit must declare the pin in dependabot.yml
foreach ($repo in @("launcher", "transmittal-builder", "Drawing-List-Manager")) {
    Assert-Contains $repo ".github/dependabot.yml" "@chamber-19/desktop-toolkit"
    Assert-Contains $repo ".github/dependabot.yml" "dependency-name: `"desktop-toolkit`""
}

# ── Repo-specific checks ─────────────────────────────────────────────────────
Assert-Contains "Drawing-List-Manager" ".github/dependabot.yml" "dependency-name: `"glib`""
Assert-Contains "Drawing-List-Manager" ".github/dependabot.yml" "dependency-name: `"rand`""
Assert-Contains "desktop-toolkit" ".github/dependabot.yml" "directory: `"/python`""
Assert-Contains "desktop-toolkit" ".github/dependabot.yml" "directory: `"/python/chamber19_desktop_toolkit/pyinstaller`""

# ── Foundry path guard ───────────────────────────────────────────────────────
# The copilot-setup-steps workflow must live under .github/workflows/, not .github/ directly.
if (Test-Path -LiteralPath (Join-Path $WorkspaceRoot "Foundry/.github/copilot-setup-steps.yml")) {
    Add-Failure "Foundry has copilot-setup-steps.yml at .github/ — it must live at .github/workflows/copilot-setup-steps.yml"
}

# ── Lockfile checks ──────────────────────────────────────────────────────────
Assert-File "launcher" "frontend/package-lock.json" | Out-Null
Assert-File "launcher" "frontend/src-tauri/Cargo.lock" | Out-Null

# ── Result ───────────────────────────────────────────────────────────────────
if ($failures.Count -gt 0) {
    Write-Host "Chamber 19 config audit FAILED ($($failures.Count) issue(s)):" -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host "  - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host "Chamber 19 config audit passed for $($repos.Count) repos." -ForegroundColor Green