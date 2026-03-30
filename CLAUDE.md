# AI Vault (canonical)

This repo holds shared **rules**, **skills**, and **agents** for use from Cursor and Claude Code. Paths are relative to this repository root.

## Policy

- **Auto context:** Only `rules/r-code-conventions.mdc` is meant to apply automatically (R / Quarto / R Markdown work).
- **Everything else:** Invoke **explicitly** by file path or name. Do **not** load full skill or agent bodies into context unless the user requests them or the task clearly requires a specific asset.

## Locations

| Kind | Path |
|------|------|
| Rules | `rules/*.mdc` |
| Skills | `skills/<name>/SKILL.md` |
| Agents | `agents/*.md` |

## How to invoke (examples)

- Rule: `rules/docs-markdown.mdc`, `rules/slide-generation.mdc`
- Skill: `skills/latex-preflight-check/SKILL.md`
- Agent: `agents/latex-compile.md`

Use `@` or file paths in Cursor; in Claude Code, reference the path and ask to follow that file.

## Index

See [VAULT_USAGE.md](VAULT_USAGE.md) and [AGENTS.md](AGENTS.md) for full lists.
