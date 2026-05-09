[CmdletBinding()]
param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot "family-manifest.yml"),
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Org = "chamber-19"
$ApiBaseUrl = "https://api.github.com"

function Assert-PowerShellVersion {
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        throw "PowerShell 7+ is required."
    }
}

function Get-PythonCommand {
    if (Get-Command -Name python3 -ErrorAction SilentlyContinue) {
        return "python3"
    }

    if (Get-Command -Name python -ErrorAction SilentlyContinue) {
        return "python"
    }

    throw "YAML parser fallback requires Python 3 with PyYAML, but no python executable was found."
}

function Get-GitHubHeaders {
    $headers = @{
        Accept = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
        "User-Agent" = "chamber-19-family-table-reconciler"
    }

    if ($env:GITHUB_TOKEN) {
        $headers.Authorization = "Bearer $($env:GITHUB_TOKEN)"
    }

    return $headers
}

function Invoke-GitHubApi {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [switch]$CaptureHeaders
    )

    $uri = "$ApiBaseUrl$Path"
    $headers = Get-GitHubHeaders
    $responseHeaders = $null

    try {
        $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ResponseHeadersVariable responseHeaders
    }
    catch {
        throw "GitHub API request failed for '$Path': $($_.Exception.Message)"
    }

    if ($CaptureHeaders) {
        return [pscustomobject]@{
            Body    = $response
            Headers = $responseHeaders
        }
    }

    return $response
}

function Get-RepoMetadata {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    try {
        $repo = Invoke-GitHubApi -Path "/repos/$Org/$Name"
    }
    catch {
        if ($_.Exception.Message -match "404") {
            throw "Repository '$Org/$Name' not found (deleted, renamed, or inaccessible)."
        }

        throw
    }

    $languages = Invoke-GitHubApi -Path "/repos/$Org/$Name/languages"
    $primaryLanguage = $null

    if (@($languages.PSObject.Properties).Count -gt 0) {
        $primaryLanguage = $languages.PSObject.Properties |
            Sort-Object -Property Value -Descending |
            Select-Object -First 1 -ExpandProperty Name
    }

    return [pscustomobject]@{
        Name            = $repo.name
        Archived        = [bool]$repo.archived
        Private         = [bool]$repo.private
        DefaultBranch   = $repo.default_branch
        Visibility      = $repo.visibility
        PrimaryLanguage = $primaryLanguage
    }
}

function Get-OrgRepoNames {
    $page = 1
    $all = New-Object System.Collections.Generic.List[string]

    while ($true) {
        $response = Invoke-GitHubApi -Path "/orgs/$Org/repos?per_page=100&page=$page&type=all"
        $responseItems = @($response)
        if ($null -eq $response -or $responseItems.Count -eq 0) {
            break
        }

        foreach ($repo in $responseItems) {
            $all.Add([string]$repo.name) | Out-Null
        }

        if ($responseItems.Count -lt 100) {
            break
        }

        $page += 1
    }

    return $all
}

function Escape-Cell {
    param([AllowNull()][string]$Value)

    if ($null -eq $Value) {
        return ""
    }

    return $Value.Replace("|", "\|").Replace("`r", " ").Replace("`n", " ")
}

function Build-TableText {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("profile", "copilot")]
        [string]$TargetName,
        [Parameter(Mandatory = $true)]
        [object]$TargetConfig,
        [Parameter(Mandatory = $true)]
        [object[]]$Repos
    )

    $columns = @($TargetConfig.columns)
    if ($columns.Count -eq 0) {
        throw "Target '$TargetName' has no columns configured in manifest."
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("| $($columns -join ' | ') |") | Out-Null
    $lines.Add("|$((@('---') * $columns.Count) -join '|')|") | Out-Null

    foreach ($repo in $Repos) {
        $cells = New-Object System.Collections.Generic.List[string]
        foreach ($column in $columns) {
            switch ($column) {
                "Repo" {
                    $repoCell = [string]$TargetConfig.repo_link
                    $repoCell = $repoCell.Replace("{name}", [string]$repo.name)
                    $cells.Add($repoCell) | Out-Null
                }
                "Role" {
                    $role = if ($TargetName -eq "profile") { $repo.profile_role } else { $repo.copilot_role }
                    $cells.Add((Escape-Cell -Value $role)) | Out-Null
                }
                "Stack" {
                    $cells.Add((Escape-Cell -Value $repo.stack)) | Out-Null
                }
                default {
                    throw "Unsupported column '$column' in target '$TargetName'."
                }
            }
        }

        $lines.Add("| $($cells -join ' | ') |") | Out-Null
    }

    return ($lines -join "`n")
}

function Replace-TableSection {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [Parameter(Mandatory = $true)]
        [string]$TableText
    )

    if (-not (Test-Path -LiteralPath $FilePath)) {
        throw "Target file '$FilePath' does not exist."
    }

    $content = Get-Content -LiteralPath $FilePath -Raw
    $startMarker = "<!-- family-table:start -->"
    $endMarker = "<!-- family-table:end -->"

    if ($content -notmatch [regex]::Escape($startMarker) -or $content -notmatch [regex]::Escape($endMarker)) {
        throw "Target file '$FilePath' is missing family-table markers. Add `<!-- family-table:start -->` and `<!-- family-table:end -->` manually first."
    }

    $pattern = "(?s)(<!-- family-table:start -->\r?\n)(.*?)(\r?\n<!-- family-table:end -->)"
    if ($content -notmatch $pattern) {
        throw "Could not locate a replaceable family table block in '$FilePath'. Ensure the start marker appears before the end marker."
    }

    $replacement = '$1' + $TableText + '$3'
    return [regex]::Replace($content, $pattern, $replacement, 1)
}

function Show-Diff {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OldContent,
        [Parameter(Mandatory = $true)]
        [string]$NewContent,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $oldPath = Join-Path ([System.IO.Path]::GetTempPath()) ("family-table-old-" + [System.Guid]::NewGuid() + ".md")
    $newPath = Join-Path ([System.IO.Path]::GetTempPath()) ("family-table-new-" + [System.Guid]::NewGuid() + ".md")

    try {
        [System.IO.File]::WriteAllText($oldPath, $OldContent)
        [System.IO.File]::WriteAllText($newPath, $NewContent)

        Write-Host ""
        Write-Host "Diff for ${Label}:" -ForegroundColor Yellow
        & git --no-pager diff --no-index -- $oldPath $newPath
    }
    finally {
        Remove-Item -LiteralPath $oldPath -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $newPath -Force -ErrorAction SilentlyContinue
    }
}

function ConvertFrom-YamlCompat {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Yaml
    )

    if (Get-Command -Name ConvertFrom-Yaml -ErrorAction SilentlyContinue) {
        return ConvertFrom-Yaml -Yaml $Yaml
    }

    $pythonScript = @"
import json
import sys
import yaml

data = yaml.safe_load(sys.stdin.read())
print(json.dumps(data))
"@

    $pythonCommand = Get-PythonCommand

    try {
        $json = $Yaml | & $pythonCommand -c $pythonScript
    }
    catch {
        throw "Failed to parse YAML manifest. Ensure Python 3 with PyYAML is available: $($_.Exception.Message)"
    }

    return $json | ConvertFrom-Json
}

try {
    Assert-PowerShellVersion

    if (-not (Test-Path -LiteralPath $ManifestPath)) {
        throw "Manifest file not found at '$ManifestPath'."
    }

    $manifestRaw = Get-Content -LiteralPath $ManifestPath -Raw
    $manifest = ConvertFrom-YamlCompat -Yaml $manifestRaw

    if (-not $manifest.repos -or $manifest.repos.Count -eq 0) {
        throw "Manifest '$ManifestPath' has no repos."
    }

    $repoNames = @($manifest.repos | ForEach-Object { [string]$_.name })
    $duplicateNames = @($repoNames | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
    if ($duplicateNames.Count -gt 0) {
        throw "Manifest has duplicate repo entries: $($duplicateNames -join ', ')"
    }

    $validationErrors = New-Object System.Collections.Generic.List[string]
    $resolvedRepos = New-Object System.Collections.Generic.List[object]

    foreach ($repo in $manifest.repos) {
        $name = [string]$repo.name
        if ([string]::IsNullOrWhiteSpace($name)) {
            $validationErrors.Add("Manifest contains an entry with an empty repo name.") | Out-Null
            continue
        }

        try {
            $metadata = Get-RepoMetadata -Name $name
        }
        catch {
            $validationErrors.Add($_.Exception.Message) | Out-Null
            continue
        }

        if ($metadata.Archived) {
            $validationErrors.Add("Repository '$Org/$name' is archived. Remove or update this manifest entry.") | Out-Null
        }
        if ($metadata.Private -or $metadata.Visibility -eq "private") {
            $validationErrors.Add("Repository '$Org/$name' is private. Family table entries must be public.") | Out-Null
        }

        Write-Host ("Validated {0}: default_branch={1}, visibility={2}, primary_language={3}" -f `
            $name, $metadata.DefaultBranch, $metadata.Visibility, ($metadata.PrimaryLanguage ?? "unknown"))

        $resolvedRepos.Add($repo) | Out-Null
    }

    $orgRepoNames = Get-OrgRepoNames
    $missingFromManifest = @($orgRepoNames | Where-Object { $_ -notin $repoNames } | Sort-Object)
    if ($missingFromManifest.Count -gt 0) {
        $validationErrors.Add("Manifest is missing org repos: $($missingFromManifest -join ', '). Add entries with status: needs-curation.") | Out-Null
    }

    if ($validationErrors.Count -gt 0) {
        Write-Host "Family table reconciliation validation failed:" -ForegroundColor Red
        foreach ($errorMessage in $validationErrors) {
            Write-Host "  - $errorMessage" -ForegroundColor Red
        }
        exit 1
    }

    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    $updatedFiles = New-Object System.Collections.Generic.List[string]

    foreach ($targetName in @("profile", "copilot")) {
        $target = $manifest.table_targets.$targetName
        if (-not $target) {
            throw "Manifest missing table_targets.$targetName configuration."
        }

        $targetFile = Join-Path $repoRoot ([string]$target.file)
        $tableText = Build-TableText -TargetName $targetName -TargetConfig $target -Repos $manifest.repos
        $originalContent = Get-Content -LiteralPath $targetFile -Raw
        $updatedContent = Replace-TableSection -FilePath $targetFile -TableText $tableText

        if ($originalContent -ne $updatedContent) {
            if ($DryRun) {
                Show-Diff -OldContent $originalContent -NewContent $updatedContent -Label ([string]$target.file)
            }
            else {
                [System.IO.File]::WriteAllText($targetFile, $updatedContent)
                Write-Host "Updated $($target.file)"
            }

            $updatedFiles.Add([string]$target.file) | Out-Null
        }
        else {
            Write-Host "No changes in $($target.file)"
        }
    }

    if ($DryRun) {
        if ($updatedFiles.Count -eq 0) {
            Write-Host "Dry run complete. No table changes." -ForegroundColor Green
        }
        else {
            Write-Host "Dry run complete. Would update: $($updatedFiles -join ', ')" -ForegroundColor Yellow
        }
    }
}
catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
