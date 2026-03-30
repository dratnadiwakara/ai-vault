# AI Vault — agents and skills index

**Invocation:** Only `rules/r-code-conventions.mdc` is auto-applied for R-family files. All items below are **explicit invocation**—reference the path when needed; do not preload into context by default.

## Rules (`rules/`)

| File | Summary |
|------|---------|
| `r-code-conventions.mdc` | R, ggplot2, fixest, Quarto structure—**auto** on `*.R`, `*.Rmd`, `*.qmd` |
| `docs-markdown.mdc` | Jekyll/docs markdown, figures, AI-written boxes |
| `slide-generation.mdc` | Marp slide decks under `docs/slides/` |
| `sync-to-dr-workflow.mdc` | Sync vault changes to `dr-workflow` template |

## Agents (`agents/`)

| File | Summary |
|------|---------|
| `latex-compile.md` | Run `latexmk` on a `.tex` file |
| `literature-reviewer.md` | Literature review workflow |
| `finance-paper-reviewer.md` | Finance paper review |
| `ai-detector.md` | AI-detection oriented review |

## Skills (`skills/`)

| Folder | Skill |
|--------|--------|
| `academic-introduction-evaluator` | Introduction evaluation |
| `academic-paper-writer` | Academic paper drafting |
| `academic-paragraph-inserter` | Paragraph insertion |
| `bib-validator` | Bibliography validation |
| `figure-table-crosscheck` | Figures/tables cross-check |
| `harsh-editor` | Aggressive editing pass |
| `latex-figure-inserter` | LaTeX figure insertion |
| `latex-preflight-check` | Pre-submission LaTeX QA |
| `latex-table-inserter` | LaTeX table insertion |
| `professor-robustness-check` | Robustness review |
| `referee-response-evaluator` | Referee response evaluation |
| `referee2-audit` | Referee-style audit (see `references/`) |
| `sanity-check` | General sanity check |
| `table-figure-descriptions` | Table/figure descriptions |

Each skill’s instructions live in `skills/<folder>/SKILL.md`.
