<#
.SYNOPSIS
    Scaffold a new analytical track inside an existing ai-vault project.

.DESCRIPTION
    Creates tracks/<descriptor>-<month-year>/ with self-contained code/, data/,
    and latex/ subfolders, then copies the LaTeX template (main.tex, main.bib,
    section stubs) from the vault into the track's latex/ folder.

    Each track is an independent analytical sub-project with its own paper
    draft. Multiple tracks can coexist in tracks/ and run in parallel.

.PARAMETER ProjectPath
    Path to the project root (the directory created by new-project.ps1).

.PARAMETER TrackName
    Short descriptor for the track, e.g. "did", "iv-shift-share". The full
    track folder name becomes <descriptor>-<month-year> based on today's date.

.PARAMETER VaultRoot
    Path to the ai-vault repository. Defaults to the parent of this script.

.EXAMPLE
    .\new-track.ps1 -ProjectPath "C:\projects\my-paper" -TrackName "did"
    # creates tracks/did-may2026/
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [Parameter(Mandatory = $true)]
    [string]$TrackName,

    [Parameter(Mandatory = $false)]
    [string]$VaultRoot = (Split-Path $PSScriptRoot -Parent)
)

$VaultRoot   = (Resolve-Path $VaultRoot).Path
$ProjectPath = (Resolve-Path $ProjectPath).Path

if (-not (Test-Path (Join-Path $ProjectPath "tracks"))) {
    Write-Error "No tracks/ folder at $ProjectPath. Run new-project.ps1 first."
    exit 1
}

$slug = ($TrackName -replace '[^A-Za-z0-9-]', '-').ToLower().Trim('-')
$monthYear = (Get-Date -Format "MMMMyyyy").ToLower()
$trackDir = "tracks\$slug-$monthYear"

$trackFullPath = Join-Path $ProjectPath $trackDir
if (Test-Path $trackFullPath) {
    Write-Error "Track already exists: $trackFullPath"
    exit 1
}

Write-Host ""
Write-Host "ai-vault new-track" -ForegroundColor Cyan
Write-Host "  Project : $ProjectPath"
Write-Host "  Track   : $trackDir"
Write-Host ""

function New-TrackDir {
    param([string]$RelPath)
    $full = Join-Path $ProjectPath $RelPath
    if (-not (Test-Path $full)) {
        New-Item -ItemType Directory -Path $full -Force | Out-Null
    }
    $gk = Join-Path $full ".gitkeep"
    if (-not (Test-Path $gk)) {
        New-Item -ItemType File -Path $gk -Force | Out-Null
    }
    Write-Host "[dir]     $RelPath"
}

function Copy-TemplateFile {
    param([string]$SrcRel, [string]$DstRel)
    $src = Join-Path $VaultRoot $SrcRel
    $dst = Join-Path $ProjectPath $DstRel
    $dstDir = Split-Path $dst -Parent
    if (-not (Test-Path $dstDir)) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }
    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "[copied]  $DstRel"
}

# ── Track directory tree ──────────────────────────────────────────────────────
Write-Host "Creating track directories..."
New-TrackDir "$trackDir\code\sample-construction"
New-TrackDir "$trackDir\code\result-generation"
New-TrackDir "$trackDir\code\archives"
New-TrackDir "$trackDir\data"
New-TrackDir "$trackDir\latex\figures"
New-TrackDir "$trackDir\latex\tables"
New-TrackDir "$trackDir\latex\build"
New-TrackDir "$trackDir\latex\sections\intro"
New-TrackDir "$trackDir\latex\sections\institutional-background"
New-TrackDir "$trackDir\latex\sections\data"
New-TrackDir "$trackDir\latex\sections\identification"
New-TrackDir "$trackDir\latex\sections\results"
New-TrackDir "$trackDir\latex\sections\heterogeneity"
New-TrackDir "$trackDir\latex\sections\robustness"
New-TrackDir "$trackDir\latex\sections\conclusion"

# ── Copy LaTeX template ───────────────────────────────────────────────────────
Write-Host ""
Write-Host "Copying LaTeX template..."
$tpl = "scripts\templates\track"
Copy-TemplateFile "$tpl\main.tex" "$trackDir\latex\main.tex"
Copy-TemplateFile "$tpl\main.bib" "$trackDir\latex\main.bib"
Copy-TemplateFile "$tpl\sections\intro\intro_current.tex"                                   "$trackDir\latex\sections\intro\intro_current.tex"
Copy-TemplateFile "$tpl\sections\institutional-background\inst_bg_current.tex"              "$trackDir\latex\sections\institutional-background\inst_bg_current.tex"
Copy-TemplateFile "$tpl\sections\data\data_current.tex"                                     "$trackDir\latex\sections\data\data_current.tex"
Copy-TemplateFile "$tpl\sections\identification\identification_current.tex"                 "$trackDir\latex\sections\identification\identification_current.tex"
Copy-TemplateFile "$tpl\sections\results\results_current.tex"                               "$trackDir\latex\sections\results\results_current.tex"
Copy-TemplateFile "$tpl\sections\heterogeneity\heterogeneity_current.tex"                   "$trackDir\latex\sections\heterogeneity\heterogeneity_current.tex"
Copy-TemplateFile "$tpl\sections\robustness\robustness_current.tex"                         "$trackDir\latex\sections\robustness\robustness_current.tex"
Copy-TemplateFile "$tpl\sections\conclusion\conclusion_current.tex"                         "$trackDir\latex\sections\conclusion\conclusion_current.tex"

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host ""
Write-Host "Track ready at: $trackDir"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Edit $trackDir\latex\main.tex - replace [PAPER_TITLE] placeholders"
Write-Host "  2. Drop sample-construction scripts in $trackDir\code\sample-construction\"
Write-Host "  3. Drop analysis .qmd in $trackDir\code\result-generation\"
Write-Host "  4. Invoke skills with the track name, e.g.:"
Write-Host "       /skills/latex-compile $slug-$monthYear"
Write-Host ""
