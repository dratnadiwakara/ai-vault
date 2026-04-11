# AI Vault Usage

This repository is a **Claude Code project template and global command library** for empirical finance research. It serves two purposes:

1. **Template** — the folder structure mirrors a standard paper project. Run `scripts/new-project.ps1` (or `.sh`) to initialize new projects from this template.
2. **Command library** — all skills and agents live in `.claude/commands/`. New projects receive symlinks back here so that skills and agents are managed in one place.

## Initializing a New Project

From this vault's root directory (Windows):

```powershell
.\scripts\new-project.ps1 -ProjectPath "C:\projects\my-paper"
```

From this vault's root directory (Mac/Linux):

```bash
./scripts/new-project.sh ../my-paper
```

What the script does:
1. Creates the full template directory structure in the target project.
2. Copies template files: `CLAUDE.md`, `.gitignore`, `.claudeignore`, `code/common.R`, `latex/main.tex`, `latex/main.bib`, all section stubs, and memo files.
3. Creates `<project>/.claude/commands/skills/` as a **symlink** → `<vault>/.claude/commands/skills/`
4. Creates `<project>/.claude/commands/agents/` as a **symlink** → `<vault>/.claude/commands/agents/`

On Windows, if symlink creation fails (requires Developer Mode or elevated prompt), the script falls back to **directory junctions** (`mklink /J`), which work for same-drive paths without special permissions.

## Symlink Model

```
my-paper/
├── CLAUDE.md              ← copied from vault, fill in [PLACEHOLDER]s
├── .claude/
│   └── commands/
│       ├── skills/        → symlink → ai-vault/.claude/commands/skills/
│       └── agents/        → symlink → ai-vault/.claude/commands/agents/
├── data/
├── code/
├── latex/
└── ...
```

All projects share a single set of skills and agents. When you update a skill or agent in the vault, every linked project gets the update automatically — no file copying needed.

## Invoking Skills and Agents

In Claude Code, use slash commands:

```
/skills/latex-compile
/skills/write-section intro
/agents/finance-paper-reviewer latex/main.tex
/agents/literature-reviewer bank branch closures and credit supply
```

See `.claude/commands/skills/` and `.claude/commands/agents/` for the full list — Claude Code discovers them automatically.

## After Initialization

1. Open the new project folder in Claude Code.
2. Edit `CLAUDE.md` — replace all `[PLACEHOLDER]` sections with paper-specific context (identification strategy, key variables, sample description, data sources).
3. Add raw data to `data/raw/` (this directory is gitignored).
4. Initialize git: `git init && git add . && git commit -m "Initialize project from ai-vault template"`.

## Vault Structure

```
ai-vault/
├── CLAUDE.md                        ← template (also the vault's own CLAUDE.md)
├── .gitignore / .claudeignore
├── .claude/
│   ├── settings.local.json
│   └── commands/
│       ├── skills/                  ← 11 skill files
│       └── agents/                  ← 8 agent files
├── data/raw/ / data/constructed/    ← gitkeep placeholders
├── code/
│   ├── common.R                     ← template stub
│   ├── sample-construction/
│   ├── result-generation/
│   └── archives/
├── latex/
│   ├── main.tex / main.bib          ← template stubs
│   ├── figures/ / tables/ / build/
│   └── sections/                    ← 8 section subfolders with *_current.tex stubs
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
    └── new-project.sh
```
