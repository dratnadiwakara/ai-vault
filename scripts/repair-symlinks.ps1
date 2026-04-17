<#
.SYNOPSIS
    Re-create .claude/commands/skills and .claude/commands/agents symlinks in all
    sibling project folders, pointing to this vault's .claude/commands/.

.DESCRIPTION
    Run this after moving the vault to a new machine or a new path.
    Scans every immediate sub-directory of the vault's parent that contains a
    .claude/commands folder and replaces the skills/agents entries (whether plain
    directories, stale symlinks, or junctions) with fresh junctions to the vault.

.PARAMETER VaultRoot
    Path to this ai-vault repository. Defaults to the parent of the scripts/ folder.

.PARAMETER GithubRoot
    Parent directory that contains all project folders. Defaults to the vault's parent.

.EXAMPLE
    .\repair-symlinks.ps1
    .\repair-symlinks.ps1 -VaultRoot "C:\Users\me\github\ai-vault"
#>

param(
    [string]$VaultRoot   = (Split-Path $PSScriptRoot -Parent),
    [string]$GithubRoot  = $null
)

$VaultRoot = (Resolve-Path $VaultRoot).Path
if (-not $GithubRoot) { $GithubRoot = Split-Path $VaultRoot -Parent }

$vaultSkills = Join-Path $VaultRoot ".claude\commands\skills"
$vaultAgents = Join-Path $VaultRoot ".claude\commands\agents"

Write-Host ""
Write-Host "ai-vault symlink repair" -ForegroundColor Cyan
Write-Host "  Vault      : $VaultRoot"
Write-Host "  Scanning   : $GithubRoot"
Write-Host "  -> skills  : $vaultSkills"
Write-Host "  -> agents  : $vaultAgents"
Write-Host ""

if (-not (Test-Path $vaultSkills)) { Write-Error "Vault skills dir not found: $vaultSkills"; exit 1 }
if (-not (Test-Path $vaultAgents)) { Write-Error "Vault agents dir not found: $vaultAgents"; exit 1 }

function Set-Junction {
    param([string]$LinkPath, [string]$TargetPath, [string]$Label)

    if (Test-Path -LiteralPath $LinkPath) {
        $item = Get-Item -LiteralPath $LinkPath -Force -ErrorAction SilentlyContinue
        if ($item.LinkType -in @('SymbolicLink','Junction')) {
            if ($item.Target -eq $TargetPath) {
                Write-Host "  [ok]      $Label" -ForegroundColor DarkGray
                return
            }
            # Stale link — remove and recreate
            Remove-Item -LiteralPath $LinkPath -Recurse -Force
        } else {
            # Plain directory — remove
            Remove-Item -LiteralPath $LinkPath -Recurse -Force
        }
    }

    try {
        New-Item -ItemType Junction -Path $LinkPath -Target $TargetPath -ErrorAction Stop | Out-Null
        Write-Host "  [fixed]   $Label -> $TargetPath" -ForegroundColor Green
    } catch {
        Write-Warning "  [failed]  $Label : $($_.Exception.Message)"
    }
}

$projects = Get-ChildItem -Path $GithubRoot -Directory | Where-Object { $_.FullName -ne $VaultRoot }
$fixed = 0

foreach ($proj in $projects) {
    $commandsDir = Join-Path $proj.FullName ".claude\commands"
    if (-not (Test-Path $commandsDir)) { continue }

    Write-Host "$($proj.Name)"
    Set-Junction -LinkPath (Join-Path $commandsDir "skills") -TargetPath $vaultSkills -Label ".claude\commands\skills"
    Set-Junction -LinkPath (Join-Path $commandsDir "agents") -TargetPath $vaultAgents -Label ".claude\commands\agents"
    $fixed++
}

Write-Host ""
if ($fixed -eq 0) {
    Write-Host "No projects with .claude/commands/ found." -ForegroundColor Yellow
} else {
    Write-Host "Done - repaired $fixed project(s)." -ForegroundColor Green
}
Write-Host ""
