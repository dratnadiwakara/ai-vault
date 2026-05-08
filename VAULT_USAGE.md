# AI Vault Usage

This repository is a **Claude Code project template and global command library** for empirical finance research. It serves two purposes:

1. **Template** — projects are organized around **tracks** (self-contained analytical sub-projects). Use `scripts/new-project.ps1` (or `.sh`) to create the project shell, then `scripts/new-track.ps1` (or `.sh`) for each track.
2. **Command library** — all skills and agents live in `.claude/commands/`. New projects receive symlinks back here so skills and agents are managed in one place.

## Initializing a New Project

From this vault's root directory (Windows):

```powershell
.\scripts\new-project.ps1 -ProjectPath "C:\projects\my-paper"
.\scripts\new-track.ps1   -ProjectPath "C:\projects\my-paper" -TrackName "did"
```

From this vault's root directory (Mac/Linux):

```bash
./scripts/new-project.sh ../my-paper
./scripts/new-track.sh   ../my-paper did
```

What `new-project.ps1` / `.sh` does:
1. Creates the shared (cross-track) directory structure: `data/{raw,constructed}/`, `code/`, `tracks/`, `docs/`, `correspondence/`, `related-papers/`.
2. Copies shared template files: `CLAUDE.md`, `.gitignore`, `.claudeignore`, `code/common.R`, docs scaffolding, memo stubs.
3. Creates `<project>/.claude/commands/skills/` as a **symlink** → `<vault>/.claude/commands/skills/`
4. Creates `<project>/.claude/commands/agents/` as a **symlink** → `<vault>/.claude/commands/agents/`

What `new-track.ps1` / `.sh` does:
1. Computes the track folder name as `<descriptor>-<month-year>` (e.g., `did-april2026`).
2. Creates `tracks/<name>/code/{sample-construction,result-generation,archives}/`, `tracks/<name>/data/`, and `tracks/<name>/latex/{sections/...,figures,tables,build}/`.
3. Copies the LaTeX template (`main.tex`, `main.bib`, 8 section stubs) from `<vault>/scripts/templates/track/` into the new track's `latex/`.

On Windows, if symlink creation fails (requires Developer Mode or elevated prompt), the script falls back to **directory junctions** (`mklink /J`), which work for same-drive paths without special permissions.

## Symlink Model

```
my-paper/
├── CLAUDE.md                          ← copied from vault, fill in [PLACEHOLDER]s
├── .claude/
│   └── commands/
│       ├── skills/                    → symlink → ai-vault/.claude/commands/skills/
│       └── agents/                    → symlink → ai-vault/.claude/commands/agents/
├── data/                              ← shared raw + constructed
├── code/
│   └── common.R                       ← shared
└── tracks/
    └── did-april2026/
        ├── code/
        ├── data/
        └── latex/
```

All projects share a single set of skills and agents. When you update a skill or agent in the vault, every linked project gets the update automatically — no file copying needed.

## Invoking Skills and Agents

In Claude Code, use slash commands. Skills that operate on a paper draft, code base, or per-track results take the **track name as their first argument**:

```
/skills/latex-compile did-april2026
/skills/write-section did-april2026 intro
/skills/snapshot-results did-april2026 baseline
/agents/finance-paper-reviewer did-april2026
/agents/literature-reviewer bank branch closures and credit supply
```

See `.claude/commands/skills/` and `.claude/commands/agents/` for the full list — each skill's instructions document its argument form.

## After Initialization

1. Open the new project folder in Claude Code.
2. Edit `CLAUDE.md` — replace all `[PLACEHOLDER]` sections with paper-specific context (identification strategy, key variables, sample description, data sources).
3. Add raw data to `data/raw/` (this directory is gitignored).
4. Create your first track: `scripts/new-track.ps1 -ProjectPath . -TrackName <descriptor>`.
5. Edit `tracks/<descriptor>-<month-year>/latex/main.tex` to replace `[PAPER_TITLE]`.
6. Initialize git: `git init && git add . && git commit -m "Initialize project from ai-vault template"`.

## Vault Structure

```
ai-vault/
├── CLAUDE.md                        ← template (also the vault's own CLAUDE.md)
├── .gitignore / .claudeignore
├── .claude/
│   ├── settings.local.json
│   └── commands/
│       ├── skills/                  ← skill files
│       └── agents/                  ← agent files
├── data/raw/ / data/constructed/    ← gitkeep placeholders
├── code/
│   └── common.R                     ← shared template
├── tracks/                          ← gitkeep placeholder (no default tracks)
├── docs/
│   ├── _config.yml                  ← Jekyll config for GitHub Pages
│   ├── index.md                     ← snapshot registry (Pages landing page)
│   ├── snapshots/                   ← versioned result snapshots
│   ├── slides/
│   └── memos/
├── related-papers/                  ← gitignored
├── correspondence/
└── scripts/
    ├── new-project.ps1
    ├── new-project.sh
    ├── new-track.ps1
    ├── new-track.sh
    ├── repair-symlinks.ps1
    └── templates/
        └── track/                   ← LaTeX template files copied by new-track
            ├── main.tex / main.bib
            └── sections/<section>/<section>_current.tex
```
