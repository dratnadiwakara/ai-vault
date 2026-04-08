<#
.SYNOPSIS
    Initialize a new research project from the ai-vault template.

.DESCRIPTION
    Creates a new project directory with the full template folder structure,
    copies template files from the vault, and symlinks the .claude/commands/
    skills and agents directories back to this vault so all projects share
    one universal set of skills and agents.

.PARAMETER ProjectPath
    Absolute or relative path for the new project directory. Will be created
    if it does not exist.

.PARAMETER VaultRoot
    Path to this ai-vault repository. Defaults to the parent directory of
    the script (i.e., the vault root when run from scripts/).

.EXAMPLE
    .\new-project.ps1 -ProjectPath "C:\projects\my-paper"
    .\new-project.ps1 -ProjectPath "..\my-paper"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [Parameter(Mandatory = $false)]
    [string]$VaultRoot = (Split-Path $PSScriptRoot -Parent)
)

# ── Resolve paths ──────────────────────────────────────────────────────────────
$VaultRoot   = (Resolve-Path $VaultRoot).Path
$ProjectPath = [System.IO.Path]::GetFullPath($ProjectPath)

Write-Host ""
Write-Host "ai-vault new-project initializer" -ForegroundColor Cyan
Write-Host "  Vault    : $VaultRoot"
Write-Host "  Project  : $ProjectPath"
Write-Host ""

# ── Create project root ────────────────────────────────────────────────────────
if (-not (Test-Path $ProjectPath)) {
    New-Item -ItemType Directory -Path $ProjectPath -Force | Out-Null
    Write-Host "[created] $ProjectPath"
}

# ── Helper: create directory with .gitkeep ─────────────────────────────────────
function New-ProjectDir {
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

# ── Helper: copy a file from vault to project ──────────────────────────────────
function Copy-VaultFile {
    param([string]$RelPath)
    $src = Join-Path $VaultRoot $RelPath
    $dst = Join-Path $ProjectPath $RelPath
    $dstDir = Split-Path $dst -Parent
    if (-not (Test-Path $dstDir)) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }
    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "[copied]  $RelPath"
}

# ── Create empty template directories ─────────────────────────────────────────
Write-Host "Creating directories..."
New-ProjectDir "data\raw"
New-ProjectDir "data\constructed"
New-ProjectDir "code\sample-construction"
New-ProjectDir "code\result-generation"
New-ProjectDir "code\archives"
New-ProjectDir "latex\figures"
New-ProjectDir "latex\tables"
New-ProjectDir "latex\build"
New-ProjectDir "latex\sections\intro"
New-ProjectDir "latex\sections\institutional-background"
New-ProjectDir "latex\sections\data"
New-ProjectDir "latex\sections\identification"
New-ProjectDir "latex\sections\results"
New-ProjectDir "latex\sections\heterogeneity"
New-ProjectDir "latex\sections\robustness"
New-ProjectDir "latex\sections\conclusion"
New-ProjectDir "docs\slides"
New-ProjectDir "docs\memos"
New-ProjectDir "related-papers"
New-ProjectDir "correspondence"

# ── Copy template files ────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Copying template files..."
Copy-VaultFile "CLAUDE.md"
Copy-VaultFile ".gitignore"
Copy-VaultFile ".claudeignore"
Copy-VaultFile "code\common.R"
Copy-VaultFile "latex\main.tex"
Copy-VaultFile "latex\main.bib"
Copy-VaultFile "latex\sections\intro\intro_current.tex"
Copy-VaultFile "latex\sections\institutional-background\inst_bg_current.tex"
Copy-VaultFile "latex\sections\data\data_current.tex"
Copy-VaultFile "latex\sections\identification\identification_current.tex"
Copy-VaultFile "latex\sections\results\results_current.tex"
Copy-VaultFile "latex\sections\heterogeneity\heterogeneity_current.tex"
Copy-VaultFile "latex\sections\robustness\robustness_current.tex"
Copy-VaultFile "latex\sections\conclusion\conclusion_current.tex"
Copy-VaultFile "docs\memos\revision_plan.md"
Copy-VaultFile "docs\memos\referee_response.md"
Copy-VaultFile "docs\memos\todo.md"

# ── .claude/ setup ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Setting up .claude/commands/ symlinks..."

$claudeDir = Join-Path $ProjectPath ".claude"
$commandsDir = Join-Path $claudeDir "commands"

if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
}
if (-not (Test-Path $commandsDir)) {
    New-Item -ItemType Directory -Path $commandsDir -Force | Out-Null
}

# Copy settings.local.json
$settingsSrc = Join-Path $VaultRoot ".claude\settings.local.json"
$settingsDst = Join-Path $claudeDir "settings.local.json"
if (Test-Path $settingsSrc) {
    Copy-Item -Path $settingsSrc -Destination $settingsDst -Force
    Write-Host "[copied]  .claude\settings.local.json"
}

# Symlink skills and agents back to vault
$vaultSkills = Join-Path $VaultRoot ".claude\commands\skills"
$vaultAgents = Join-Path $VaultRoot ".claude\commands\agents"
$projSkills  = Join-Path $commandsDir "skills"
$projAgents  = Join-Path $commandsDir "agents"

function New-SymlinkOrJunction {
    param([string]$LinkPath, [string]$TargetPath, [string]$Label)
    if (Test-Path $LinkPath) {
        Write-Host "[exists]  $Label (skipped)"
        return
    }
    try {
        # Try symbolic link first (requires Developer Mode or elevated prompt)
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -Force | Out-Null
        Write-Host "[symlink] $Label -> $TargetPath"
    } catch {
        try {
            # Fall back to Junction (works without Developer Mode)
            & cmd /c mklink /J "$LinkPath" "$TargetPath" | Out-Null
            Write-Host "[junction] $Label -> $TargetPath"
        } catch {
            Write-Warning "Could not create symlink or junction for $Label. Link it manually:"
            Write-Warning "  mklink /J `"$LinkPath`" `"$TargetPath`""
        }
    }
}

New-SymlinkOrJunction -LinkPath $projSkills -TargetPath $vaultSkills -Label ".claude\commands\skills"
New-SymlinkOrJunction -LinkPath $projAgents -TargetPath $vaultAgents -Label ".claude\commands\agents"

# ── Summary ────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Open $ProjectPath in Claude Code"
Write-Host "  2. Edit CLAUDE.md — replace all [PLACEHOLDER] sections with paper-specific context"
Write-Host "  3. Add raw data to data\raw\ (gitignored)"
Write-Host "  4. Initialize git: cd '$ProjectPath' && git init"
Write-Host ""
