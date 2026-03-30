# AI Vault usage

This repository is the **canonical** store for shared Cursor rules, skills, and agents. Other projects link here via `scripts/link-ai-vault.ps1` (or `.sh`) instead of copying files.

## Auto vs explicit invocation

| Asset | Behavior |
|-------|----------|
| **`rules/r-code-conventions.mdc`** | **Auto-applies** when working on `*.R`, `*.Rmd`, `*.qmd` (Cursor: `alwaysApply: true` + globs). |
| **All other `rules/*.mdc`** | **Explicit only.** Do not preload; invoke by path or `@` (e.g. `@rules/docs-markdown.mdc`). Globs were removed so they do not auto-attach. |
| **`skills/*/SKILL.md`** | **Explicit only.** Reference the skill by folder name or path when needed. |
| **`agents/*.md`** | **Explicit only.** Reference the agent file when delegating a task. |

## Layout

- `rules/` — Cursor rule files (`.mdc`)
- `skills/` — One folder per skill with `SKILL.md`
- `agents/` — Agent definitions (`.md`)

## Linking a project

On **Windows**, if symlink creation fails (permissions), the script falls back to **directory junctions**, which work for same-drive vault paths without Developer Mode.

From the **target project root** (not inside ai-vault):

```powershell
pwsh -File "C:\path\to\ai-vault\scripts\link-ai-vault.ps1" -VaultRoot "C:\path\to\ai-vault"
```

See [scripts/link-ai-vault.ps1](scripts/link-ai-vault.ps1) for parameters (`-Validate`, `-SkipClaudeMd`, etc.).

Project initialization: in addition to creating `.cursor/{rules,skills,agents}` links, the script also scaffolds a standard folder structure (e.g., `code/`, `data/`, `docs/`, `latex/`) and writes `.gitignore`, `.cursorignore`, and `.claudeignore` for new/blank projects.

When linking **this** repository to itself (to test symlinks), use `-SkipClaudeMd` so the vault’s root `CLAUDE.md` is not given a duplicate “Linked AI vault” section.

## Claude Code

Projects that use this vault should have a `CLAUDE.md` (created or updated by the link script) pointing at the vault paths. Load rules/skills/agents **only when the user asks** or when the task clearly requires them—do not paste entire skill bodies into context by default.
