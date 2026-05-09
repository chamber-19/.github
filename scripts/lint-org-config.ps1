[CmdletBinding()]
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"
$hasErrors = $false

function Get-RepoRelativePath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return [System.IO.Path]::GetRelativePath($RepoRoot, $Path).Replace("\", "/")
}

function Escape-AnnotationValue {
    param([Parameter(Mandatory = $true)][string]$Value)
    return $Value.Replace("%", "%25").Replace("`r", "%0D").Replace("`n", "%0A")
}

function Add-ErrorAnnotation {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][int]$Line,
        [Parameter(Mandatory = $true)][string]$Message
    )

    $script:hasErrors = $true
    $relativePath = Escape-AnnotationValue (Get-RepoRelativePath -Path $FilePath)
    $escapedMessage = Escape-AnnotationValue $Message
    Write-Host "::error file=$relativePath,line=$Line::$escapedMessage"
}

function Get-FrontmatterCloseIndex {
    param([string[]]$Lines)

    for ($i = 1; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i].Trim() -eq "---") {
            return $i
        }
    }

    return -1
}

function Get-FileLines {
    param([Parameter(Mandatory = $true)][string]$FilePath)

    $content = Get-Content -LiteralPath $FilePath -Raw
    if ($null -eq $content) {
        return @()
    }

    $normalizedContent = $content.Replace("`r`n", "`n").Replace("`r", "`n")
    return $normalizedContent.Split("`n")
}

# Check A — instruction file naming and structure
$instructionsPath = Join-Path $RepoRoot ".github/instructions"
$instructionFiles = Get-ChildItem -LiteralPath $instructionsPath -File

foreach ($file in $instructionFiles) {
    if ($file.Extension -ne ".md") {
        Add-ErrorAnnotation -FilePath $file.FullName -Line 1 -Message "Instruction file must use the .md extension."
    }

    if ($file.Name -notmatch "\.instructions\.md$") {
        Add-ErrorAnnotation -FilePath $file.FullName -Line 1 -Message "Instruction filename must match *.instructions.md."
    }

    $lines = Get-FileLines -FilePath $file.FullName
    if ($lines.Count -eq 0) {
        Add-ErrorAnnotation -FilePath $file.FullName -Line 1 -Message "Instruction file must contain YAML frontmatter and body content."
        continue
    }

    if ($lines[0].Trim() -ne "---") {
        Add-ErrorAnnotation -FilePath $file.FullName -Line 1 -Message "Instruction file must start with YAML frontmatter ('---')."
        continue
    }

    $frontmatterEnd = Get-FrontmatterCloseIndex -Lines $lines
    if ($frontmatterEnd -lt 0) {
        Add-ErrorAnnotation -FilePath $file.FullName -Line 1 -Message "Instruction file frontmatter is not closed with '---'."
        continue
    }

    $applyToLineIndex = -1
    for ($lineIndex = 1; $lineIndex -lt $frontmatterEnd; $lineIndex++) {
        $line = $lines[$lineIndex]
        if ($line -match "^\s*applyTo\s*:\s*(?<value>.+?)\s*$") {
            $applyToValue = $Matches["value"].Trim(" ", "'", '"')
            if (-not [string]::IsNullOrWhiteSpace($applyToValue)) {
                $applyToLineIndex = $lineIndex
                break
            }
        }
    }

    if ($applyToLineIndex -lt 0) {
        Add-ErrorAnnotation -FilePath $file.FullName -Line 1 -Message "Instruction frontmatter must include a non-empty applyTo field."
    }

    $nonBlankBodyLines = 0
    for ($lineIndex = $frontmatterEnd + 1; $lineIndex -lt $lines.Count; $lineIndex++) {
        if (-not [string]::IsNullOrWhiteSpace($lines[$lineIndex])) {
            $nonBlankBodyLines++
        }
    }

    if ($nonBlankBodyLines -lt 5) {
        Add-ErrorAnnotation -FilePath $file.FullName -Line ($frontmatterEnd + 1) -Message "Instruction body must contain at least 5 non-blank lines after frontmatter."
    }
}

# Check B — skill reference resolution in markdown files
$skillFiles = Get-ChildItem -LiteralPath (Join-Path $RepoRoot "docs/skills") -File |
    Where-Object { $_.Name -imatch "\.md$" }
$resolvedSkills = @{}
foreach ($skillFile in $skillFiles) {
    $resolvedSkills["docs/skills/$($skillFile.BaseName).md".ToLowerInvariant()] = $skillFile.Name
}

$markdownFiles = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Filter "*.md"
$skillReferenceRegex = [regex]"(?<!\.)docs/skills/(?<name>[A-Za-z0-9_.-]+)\.md"

foreach ($markdownFile in $markdownFiles) {
    $lines = Get-FileLines -FilePath $markdownFile.FullName
    for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
        $line = $lines[$lineIndex]
        $matches = $skillReferenceRegex.Matches($line)
        foreach ($match in $matches) {
            $refPath = "docs/skills/$($match.Groups["name"].Value).md"
            if (-not $resolvedSkills.ContainsKey($refPath.ToLowerInvariant())) {
                Add-ErrorAnnotation -FilePath $markdownFile.FullName -Line ($lineIndex + 1) -Message "Skill reference '$refPath' does not resolve to a file in docs/skills/."
            }
        }
    }
}

# Check C — required family table entries in org copilot instructions
$orgInstructionsPath = Join-Path $RepoRoot ".github/copilot-instructions.md"
$orgLines = Get-FileLines -FilePath $orgInstructionsPath
$familyTableStartLine = 1
for ($i = 0; $i -lt $orgLines.Count; $i++) {
    if ($orgLines[$i].Trim() -eq "## Family table") {
        $familyTableStartLine = $i + 1
        break
    }
}

$blockLibraryLineNumber = -1
for ($i = 0; $i -lt $orgLines.Count; $i++) {
    if ($orgLines[$i].Contains('`block-library`')) {
        $blockLibraryLineNumber = $i + 1
        break
    }
}

if ($blockLibraryLineNumber -lt 0) {
    Add-ErrorAnnotation -FilePath $orgInstructionsPath -Line $familyTableStartLine -Message "Family table must include a block-library row."
}
else {
    $blockLibraryLine = $orgLines[$blockLibraryLineNumber - 1]
    $hasExpectedPurpose = $blockLibraryLine.Contains("Tauri 2 desktop DXF viewer") -and $blockLibraryLine.Contains("Google Drive catalog sync") -and $blockLibraryLine.Contains("SQLite local cache")
    $hasExpectedStack = $blockLibraryLine.Contains("Tauri 2.0, React, Three.js, Rust")
    if (-not ($hasExpectedPurpose -and $hasExpectedStack)) {
        Add-ErrorAnnotation -FilePath $orgInstructionsPath -Line $blockLibraryLineNumber -Message "block-library row must describe the DXF viewer purpose and include stack: Tauri 2.0, React, Three.js, Rust."
    }
}

$autoCadMcpLineNumber = -1
for ($i = 0; $i -lt $orgLines.Count; $i++) {
    if ($orgLines[$i].Contains('`chamber-19-autocad-mcp`')) {
        $autoCadMcpLineNumber = $i + 1
        break
    }
}

if ($autoCadMcpLineNumber -lt 0) {
    Add-ErrorAnnotation -FilePath $orgInstructionsPath -Line $familyTableStartLine -Message "Family table must include the chamber-19-autocad-mcp repository."
}

if ($hasErrors) {
    exit 1
}

Write-Host "Org config lint passed."
