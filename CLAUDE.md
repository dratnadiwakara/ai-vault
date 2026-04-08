> **Note:** This is the ai-vault template repository. When initializing a new project,
> run `scripts/new-project.ps1` (or `.sh`) from this directory.
> The CLAUDE.md in new projects is copied from this file — remove this note and
> fill in all [PLACEHOLDER] sections for the specific paper.

# [PAPER_TITLE] — Project Context

**Paper**: [PAPER_TITLE]
**Slug**: [PAPER_SLUG]
**Description**: [SHORT_DESCRIPTION]

## Project Layout

```
data/raw/                     ← raw source data (never modified)
data/constructed/             ← intermediate constructed datasets
code/common.R                 ← shared libraries, paths, global options
code/sample-construction/     ← plain .R scripts that build analytical samples
code/result-generation/       ← .qmd documents that generate tables and figures
code/archives/                ← old scripts (not sourced)
latex/main.tex                ← master LaTeX document
latex/main.bib                ← BibTeX references
latex/figures/                ← figure output (.png, .pdf)
latex/tables/                 ← table output (.tex)
latex/sections/               ← section .tex files (\input{} from main.tex)
latex/build/                  ← pdflatex output (gitignored)
docs/slides/                  ← presentation files
docs/memos/                   ← revision plans, referee responses, todo
related-papers/               ← downloaded PDFs (gitignored)
correspondence/               ← agent-generated reports and reviews
scripts/                      ← new-project initialization scripts
```

## Paper-Specific Context

### Identification Strategy
[PLACEHOLDER — describe the quasi-experimental design, source of variation, and identifying assumption]

### Key Variables
[PLACEHOLDER — list outcome variables, treatment variables, controls with definitions]

### Sample
[PLACEHOLDER — unit of observation, time period, data sources, key filters]

### Data Sources
[PLACEHOLDER — list raw data sources and their locations in data/raw/]

---

## R Coding Standards

### Core Principles

- **Never render** `.qmd` or `.Rmd` files during script execution — run regressions and output tables/figures by sourcing `.R` scripts or running Quarto CLI explicitly.
- Place all `library()` calls at the very top of each script.
- Reset the environment with `rm(list = ls())` as the first line of every standalone script.
- Use **relative paths** exclusively. In Quarto/R Markdown documents, construct paths with `here::here()`. In plain `.R` scripts, use paths relative to the project root (e.g., `"data/raw/file.csv"`).
- Append date suffixes (`YYYYMMDD`) to new script filenames (e.g., `01_build_panel_20260406.R`).

### Project Organization

| Folder | Contents |
|--------|----------|
| `code/sample-construction/` | Plain `.R` scripts that read from `data/raw/` and write to `data/constructed/` |
| `code/result-generation/` | `.qmd` documents with `type: source` that produce tables and figures |
| `code/common.R` | Shared libraries, paths, ggplot2 theme, fixest globals |

### Data Management

- Raw data lives in `data/raw/` and is **never modified**.
- Processed/constructed datasets go to `data/constructed/`.
- Define `data_path <- "data/constructed/"` near the top of each analysis script.
- Generate timestamped output filenames: `format(Sys.time(), "%Y%m%d_%H%M%S")`.
- Include a comment in each script indicating which upstream script generated any imported dataset.

### Figure & Table Export

- Figures → `latex/figures/` as timestamped `.png` files with `bg = "transparent"`.
- Tables → `latex/tables/` as `.tex` files with matching timestamps.
- Control exports with logical flags at the top of each script:
  ```r
  save_figures <- TRUE
  save_tables  <- TRUE
  ```

### Visualization Standards

Apply `theme_custom()` (defined in `code/common.R`) to all ggplot2 plots. Use these brand colors:

| Name | Hex |
|------|-----|
| Primary blue | `"#012169"` |
| Primary gold | `"#f2a900"` |
| Accent gray | `"#525252"` |
| Positive green | `"#15803d"` |
| Negative red | `"#b91c1c"` |

### Econometric Modeling

- Use the `fixest` package for all panel regressions.
- Define global formula macros with `setFixest_fml()` and global output options with `setFixest_etable()` **once** in `code/common.R`. Reuse them across analysis files — do not redefine per script.
- Store model results in named lists (e.g., `r <- list(); r$baseline <- feols(...)`).

### Quarto Documents

- Use `type: source` in the Quarto YAML front matter so the document runs as a script without rendering to HTML/PDF.
- Suppress warnings and messages by default in chunk options.
- Do not knit/render `.qmd` files to check results — source them or run them via `quarto run`.

---

## Skills & Agents

Skills and agents live in `.claude/commands/` (symlinked from ai-vault in project repositories).
Invoke via slash commands in Claude Code:

**Skills:**
- `/skills/latex-compile` — compile LaTeX to PDF (pdflatex, no latexmk)
- `/skills/write-section` — write a paper section as a LaTeX file
- `/skills/latex-preflight-check` — pre-submission QA checklist
- `/skills/latex-figure-inserter` — insert a figure environment into a .tex file
- `/skills/latex-table-inserter` — insert a table environment into a .tex file
- `/skills/academic-paragraph-inserter` — insert a prose paragraph at a line number
- `/skills/academic-introduction-evaluator` — evaluate introduction against JF/RFS standards
- `/skills/table-figure-descriptions` — generate table/figure notes (Journal of Finance style)
- `/skills/figure-table-crosscheck` — audit in-text numbers against table values
- `/skills/bib-validator` — validate BibTeX entries against Google Scholar
- `/skills/sanity-check` — generate R data sanity-check script and report

**Agents:**
- `/agents/finance-paper-reviewer` — full pre-submission review (6 sub-agents in parallel)
- `/agents/literature-reviewer` — search, download PDFs, build .bib, write literature review
- `/agents/ai-detector` — detect LLM fingerprints and robotic prose
- `/agents/harsh-editor` — adversarial editorial review of paper vs. code
- `/agents/professor-robustness-check` — quick robustness replication from raw data
- `/agents/referee2-audit` — systematic 5-audit replication and code review
- `/agents/referee-response-evaluator` — evaluate and improve referee response letters
- `/agents/academic-paper-writer` — draft paper sections with IMRAD structure

---

## LaTeX Conventions

- Output directory for pdflatex: `latex/build/`
- Figures referenced as `\includegraphics{figures/filename}` (graphicspath set in `latex/main.tex`)
- Tables `\input{}`-ed from `latex/tables/` or inline in section files
- Section files: `latex/sections/<section>/<section>_current.tex` (`\input{}`-ed from `main.tex`)
- Never edit `latex/build/` contents directly
- Compile sequence: `pdflatex → bibtex → pdflatex → pdflatex` (all run from `latex/` directory)
