#Requires -Version 5.1
<#
.SYNOPSIS
  Link a project to the ai-vault repo: symlink .cursor/rules, .cursor/skills, .cursor/agents
  and ensure CLAUDE.md references the vault.

.DESCRIPTION
  Run from the TARGET PROJECT ROOT (the project that should use the vault), for example:
    pwsh -File "C:\path\to\ai-vault\scripts\link-ai-vault.ps1" -VaultRoot "C:\path\to\ai-vault"

  Only rules/r-code-conventions.mdc is configured to auto-apply in Cursor; other assets are explicit-invoke.

.PARAMETER VaultRoot
  Absolute path to the ai-vault repository root (folder containing rules/, skills/, agents/).

.PARAMETER ProjectRoot
  Project to link (default: current directory).

.PARAMETER Validate
  Verify symlinks, vault folders, and that only r-code-conventions.mdc has alwaysApply: true.

.PARAMETER SkipClaudeMd
  Do not create or update CLAUDE.md in the project.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string] $VaultRoot = '',

    [Parameter(Mandatory = $false)]
    [string] $ProjectRoot = (Get-Location).Path,

    [switch] $Validate,
    [switch] $SkipClaudeMd
)

$ErrorActionPreference = 'Stop'

# Default vault root: parent of this script's directory (works when $PSScriptRoot is unset in some hosts)
if (-not $VaultRoot) {
    $scriptDir = $PSScriptRoot
    if (-not $scriptDir -and $PSCommandPath) {
        $scriptDir = Split-Path -Parent $PSCommandPath
    }
    if (-not $scriptDir) {
        throw 'Cannot determine vault root; pass -VaultRoot explicitly.'
    }
    $VaultRoot = (Resolve-Path (Join-Path $scriptDir '..')).Path
}

function Test-VaultLayout {
    param([string] $Root)
    @('rules', 'skills', 'agents') | ForEach-Object {
        $p = Join-Path $Root $_
        if (-not (Test-Path -LiteralPath $p -PathType Container)) {
            throw "Vault layout missing: $p"
        }
    }
}

function Get-RulesAutoApplyViolations {
    param([string] $RulesDir)
    $violations = @()
    Get-ChildItem -LiteralPath $RulesDir -Filter '*.mdc' -File | ForEach-Object {
        $content = Get-Content -LiteralPath $_.FullName -Raw
        $name = $_.Name
        if ($content -match 'alwaysApply:\s*true') {
            if ($name -ne 'r-code-conventions.mdc') {
                $violations += "alwaysApply: true in $name (only r-code-conventions.mdc should auto-apply)"
            }
        }
    }
    $rcc = Join-Path $RulesDir 'r-code-conventions.mdc'
    if (Test-Path -LiteralPath $rcc) {
        $c = Get-Content -LiteralPath $rcc -Raw
        if ($c -notmatch 'alwaysApply:\s*true') {
            $violations += 'r-code-conventions.mdc should have alwaysApply: true'
        }
    }
    return $violations
}

function Set-CursorSymlink {
    param(
        [string] $LinkPath,
        [string] $TargetPath,
        [string] $Name
    )
    if (Test-Path -LiteralPath $LinkPath) {
        $item = Get-Item -LiteralPath $LinkPath -Force -ErrorAction SilentlyContinue
        if ($item.LinkType -eq 'SymbolicLink' -or $item.LinkType -eq 'Junction') {
            Remove-Item -LiteralPath $LinkPath -Force
        }
        elseif ($item.PSIsContainer) {
            throw "Path exists and is not a symlink: $LinkPath - remove or rename it, then re-run."
        }
        else {
            Remove-Item -LiteralPath $LinkPath -Force
        }
    }
    $parent = Split-Path -Parent $LinkPath
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent | Out-Null
    }
    try {
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -ErrorAction Stop | Out-Null
        Write-Host "Linked $Name (symlink) -> $TargetPath"
    }
    catch {
        # Windows often requires Developer Mode or elevation for symlinks; directory junction works without that (same volume).
        try {
            New-Item -ItemType Junction -Path $LinkPath -Target $TargetPath -ErrorAction Stop | Out-Null
            Write-Host "Linked $Name (junction) -> $TargetPath"
        }
        catch {
            throw "Could not create symlink or junction for $LinkPath. Enable Windows Developer Mode (symlinks), or run elevated. Inner: $($_.Exception.Message)"
        }
    }
}

$VaultRoot = (Resolve-Path -LiteralPath $VaultRoot).Path
$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path

# --- Project scaffold + ignore initialization ---
$scaffoldDirs = @(
    'code/archives',
    'code/sample-construction',
    'code/result-generation',
    'data/raw',
    'data/clean',
    'docs/figures',
    'docs/tables',
    'docs/slides',
    'docs/todo',
    'docs/other-materials',
    'latex'
)

$cursorIgnoreTemplate = @"
venv/
venv/**
.venv/
.venv/**
renv/
renv/**
packrat/
packrat/**

data/
data/**

related-papers/
related-papers/**


*.aux
*.log
*.out
*.bbl
*.blg
*.toc
*.lof
*.lot
*.synctex.gz
*.fls
*.fdb_latexmk
*.nav
*.snm
*.vrb

# Data files
*.parquet
*.rds
*.csv
*.xls
*.xslx

# R configuration files
.Rprofile
.Rhistory
.RData
.Rproj.user
.Rproj
"@

$claudeIgnoreTemplate = $cursorIgnoreTemplate

$gitignoreTemplate = @'
related-papers/
archives/
archives/**


# LaTeX compilation files
paper_Jan2026.pdf
*.aux
*.log
*.out
*.bbl
*.blg
*.toc
*.lof
*.lot
*.synctex.gz
*.fls
*.fdb_latexmk
*.nav
*.snm
*.vrb

# Data files
*.parquet
*.rds
*.csv
*.xls
*.xslx

# R configuration files
.Rprofile
.Rhistory
.RData
.Rproj.user
.Rproj
'@

function Normalize-EOL($s) {
    # Normalize CRLF -> LF for deterministic comparisons
    return ($s -replace "`r`n", "`n")
}

Test-VaultLayout -Root $VaultRoot

$rulesDir = Join-Path $VaultRoot 'rules'
$violations = Get-RulesAutoApplyViolations -RulesDir $rulesDir
if ($violations.Count -gt 0) {
    $violations | ForEach-Object { Write-Warning $_ }
    if (-not $Validate) {
        throw "Fix rule frontmatter in vault before linking. Run with -Validate to see checks."
    }
}

if ($Validate) {
    Write-Host "=== Validate: vault at $VaultRoot"
    Test-VaultLayout -Root $VaultRoot
    $v = Get-RulesAutoApplyViolations -RulesDir $rulesDir

    $scaffoldErrors = $false
    $isSelfLink = ($ProjectRoot -ieq $VaultRoot)
    if (-not $isSelfLink) {
        foreach ($dirRel in $scaffoldDirs) {
            $dirAbs = Join-Path $ProjectRoot $dirRel
            if (-not (Test-Path -LiteralPath $dirAbs -PathType Container)) {
                Write-Warning "Missing scaffold dir: $dirAbs"
                $scaffoldErrors = $true
            }
        }
    }

    # Validate ignore files
    $gitignorePath = Join-Path $ProjectRoot '.gitignore'
    $gitignoreNeedles = @(
        'related-papers/',
        'archives/',
        'archives/**',
        '# LaTeX compilation files',
        'paper_Jan2026.pdf',
        '# Data files',
        '*.rds',
        '# R configuration files',
        '.Rproj'
    )
    if (-not $isSelfLink) {
        if (-not (Test-Path -LiteralPath $gitignorePath -PathType Leaf)) {
            Write-Warning "Missing .gitignore: $gitignorePath"
            $scaffoldErrors = $true
        }
        else {
            $gitignoreContent = Get-Content -LiteralPath $gitignorePath -Raw
            foreach ($needle in $gitignoreNeedles) {
                if ($gitignoreContent -notmatch [regex]::Escape($needle)) {
                    Write-Warning "Unexpected .gitignore content missing: $needle"
                    $scaffoldErrors = $true
                }
            }
        }
    }

    $cursorIgnorePath = Join-Path $ProjectRoot '.cursorignore'
    $claudeIgnorePath = Join-Path $ProjectRoot '.claudeignore'
    $expectedCursor = (Normalize-EOL $cursorIgnoreTemplate).TrimEnd("`n")

    if (-not $isSelfLink) {
        if (-not (Test-Path -LiteralPath $cursorIgnorePath -PathType Leaf)) {
            Write-Warning "Missing .cursorignore: $cursorIgnorePath"
            $scaffoldErrors = $true
        }
        else {
            $gotCursor = (Normalize-EOL (Get-Content -LiteralPath $cursorIgnorePath -Raw)).TrimEnd("`n")
            if ($gotCursor -ne $expectedCursor) {
                Write-Warning ".cursorignore does not match expected ignore template"
                $scaffoldErrors = $true
            }
        }
    }

    if (-not $isSelfLink) {
        if (-not (Test-Path -LiteralPath $claudeIgnorePath -PathType Leaf)) {
            Write-Warning "Missing .claudeignore: $claudeIgnorePath"
            $scaffoldErrors = $true
        }
        else {
            $gotClaude = (Normalize-EOL (Get-Content -LiteralPath $claudeIgnorePath -Raw)).TrimEnd("`n")
            if ($gotClaude -ne $expectedCursor) {
                Write-Warning ".claudeignore does not match expected ignore template"
                $scaffoldErrors = $true
            }
        }
    }

    if ($v.Count -eq 0) {
        Write-Host "OK: only r-code-conventions.mdc has alwaysApply: true"
    }
    else {
        $v | ForEach-Object { Write-Warning $_ }
    }

    $cursorDir = Join-Path $ProjectRoot '.cursor'
    $linkErrors = $false
    foreach ($name in @('rules', 'skills', 'agents')) {
        $link = Join-Path $cursorDir $name
        $target = Join-Path $VaultRoot $name
        if (Test-Path -LiteralPath $link) {
            $item = Get-Item -LiteralPath $link -Force
            if ($item.LinkType -eq 'SymbolicLink' -or $item.LinkType -eq 'Junction') {
                $targetFull = (Resolve-Path -LiteralPath $target).Path
                $raw = $item.Target
                if ($raw -is [Array]) { $raw = $raw[0] }
                if ($raw) {
                    if (-not [System.IO.Path]::IsPathRooted($raw)) {
                        $raw = Join-Path (Split-Path -Parent $item.FullName) $raw
                    }
                    $resolvedFull = (Resolve-Path -LiteralPath $raw).Path
                }
                else {
                    $resolvedFull = (Resolve-Path -LiteralPath $link).Path
                }
                if ($resolvedFull -ieq $targetFull) {
                    Write-Host "OK: .cursor/$name ($($item.LinkType)) -> $targetFull"
                }
                else {
                    Write-Warning ".cursor/$name target is $resolvedFull (expected $targetFull)"
                    $linkErrors = $true
                }
            }
            else {
                Write-Warning ".cursor/$name exists but is not a symlink or junction"
                $linkErrors = $true
            }
        }
        else {
            Write-Warning "Missing: $link"
            $linkErrors = $true
        }
    }
    $exitCode = 0
    if ($v.Count -gt 0 -or $scaffoldErrors -or $linkErrors) {
        $exitCode = 1
    }
    exit $exitCode
}

# --- Link ---
$cursorDir = Join-Path $ProjectRoot '.cursor'
if (-not (Test-Path -LiteralPath $cursorDir)) {
    New-Item -ItemType Directory -Path $cursorDir | Out-Null
}

# Ensure scaffold + ignore files (overwrite .gitignore per project policy)
foreach ($dirRel in $scaffoldDirs) {
    $dirAbs = Join-Path $ProjectRoot $dirRel
    if (-not (Test-Path -LiteralPath $dirAbs -PathType Container)) {
        New-Item -ItemType Directory -Path $dirAbs -Force | Out-Null
    }
}

Set-Content -LiteralPath (Join-Path $ProjectRoot '.gitignore') -Value $gitignoreTemplate -Encoding utf8
Set-Content -LiteralPath (Join-Path $ProjectRoot '.cursorignore') -Value $cursorIgnoreTemplate -Encoding utf8
Set-Content -LiteralPath (Join-Path $ProjectRoot '.claudeignore') -Value $claudeIgnoreTemplate -Encoding utf8

Set-CursorSymlink -LinkPath (Join-Path $cursorDir 'rules') -TargetPath (Join-Path $VaultRoot 'rules') -Name 'rules'
Set-CursorSymlink -LinkPath (Join-Path $cursorDir 'skills') -TargetPath (Join-Path $VaultRoot 'skills') -Name 'skills'
Set-CursorSymlink -LinkPath (Join-Path $cursorDir 'agents') -TargetPath (Join-Path $VaultRoot 'agents') -Name 'agents'

if (-not $SkipClaudeMd) {
    $claudePath = Join-Path $ProjectRoot 'CLAUDE.md'
    $bridge = @"

---

## Linked AI vault

This project uses a shared **ai-vault** at:

``$VaultRoot``

- Cursor: ``.cursor/rules``, ``.cursor/skills``, ``.cursor/agents`` symlink to the vault.
- Only ``rules/r-code-conventions.mdc`` auto-applies for R/Quarto files. Other rules, skills, and agents are **explicit invocation** only - reference by path; do not preload.

"@
    if (Test-Path -LiteralPath $claudePath) {
        $existing = Get-Content -LiteralPath $claudePath -Raw
        if ($existing -notmatch 'Linked AI vault') {
            Add-Content -LiteralPath $claudePath -Value $bridge -Encoding utf8
            Write-Host "Appended vault bridge to CLAUDE.md"
        }
        else {
            Write-Host "CLAUDE.md already contains vault bridge; skipped"
        }
    }
    else {
        @"
# Project context

$($bridge.TrimStart())
"@ | Set-Content -LiteralPath $claudePath -Encoding utf8
        Write-Host "Created CLAUDE.md with vault bridge"
    }
}

Write-Host "Done. Project linked to ai-vault at $VaultRoot"
