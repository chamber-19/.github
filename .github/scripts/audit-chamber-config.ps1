[CmdletBinding()]
param(
    [string]$WorkspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
)

$ErrorActionPreference = "Stop"

$repos = @(
    "launcher",
    "Foundry",
    "Transmittal-Builder",
    "Drawing-List-Manager",
    "desktop-toolkit"
)

$expectedEcosystems = @{
    "launcher"             = @("cargo", "npm", "github-actions")
    "Foundry"              = @("nuget", "pip", "github-actions")
    "Transmittal-Builder"  = @("cargo", "npm", "pip", "github-actions")
    "Drawing-List-Manager" = @("cargo", "npm", "pip", "github-actions")
    "desktop-toolkit"      = @("cargo", "npm", "pip", "github-actions")
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

foreach ($repo in $repos) {
    $repoRoot = Join-Path $WorkspaceRoot $repo
    if (-not (Test-Path -LiteralPath $repoRoot)) {
        Add-Failure "$repo repo not found under $WorkspaceRoot"
        continue
    }

    Assert-File $repo ".github/copilot-instructions.md" | Out-Null
    Assert-File $repo ".github/dependabot.yml" | Out-Null
    Assert-File $repo ".github/workflows/copilot-setup-steps.yml" | Out-Null

    Assert-Contains $repo ".github/dependabot.yml" "version: 2"
    Assert-Contains $repo ".github/workflows/copilot-setup-steps.yml" "copilot-setup-steps:"

    foreach ($ecosystem in $expectedEcosystems[$repo]) {
        Assert-Contains $repo ".github/dependabot.yml" "package-ecosystem: `"$ecosystem`""
    }
}

foreach ($repo in @("launcher", "Transmittal-Builder", "Drawing-List-Manager")) {
    Assert-Contains $repo ".github/dependabot.yml" "@chamber-19/desktop-toolkit"
    Assert-Contains $repo ".github/dependabot.yml" "dependency-name: `"desktop-toolkit`""
}

Assert-Contains "Drawing-List-Manager" ".github/dependabot.yml" "dependency-name: `"glib`""
Assert-Contains "Drawing-List-Manager" ".github/dependabot.yml" "dependency-name: `"rand`""
Assert-Contains "desktop-toolkit" ".github/dependabot.yml" "directory: `"/python`""
Assert-Contains "desktop-toolkit" ".github/dependabot.yml" "directory: `"/python/chamber19_desktop_toolkit/pyinstaller`""

if (Test-Path -LiteralPath (Join-Path $WorkspaceRoot "Foundry/.github/copilot-setup-steps.yml")) {
    Add-Failure "Foundry still has legacy .github/copilot-setup-steps.yml; setup file must live under .github/workflows"
}

Assert-File "launcher" "frontend/package-lock.json" | Out-Null
Assert-File "launcher" "frontend/src-tauri/Cargo.lock" | Out-Null

if ($failures.Count -gt 0) {
    Write-Host "Chamber 19 config audit failed:" -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host "Chamber 19 config audit passed for $($repos.Count) repos." -ForegroundColor Green
