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
code/approach-[name]/         ← early-stage: one subfolder per analytical approach
code/sample-construction/     ← plain .R scripts that build analytical samples
code/result-generation/       ← .qmd documents that generate tables and figures
code/archives/                ← old scripts (not sourced)
latex/main.tex                ← master LaTeX document
latex/main.bib                ← BibTeX references
latex/figures/                ← figure output (.png, .pdf)
latex/tables/                 ← table output (.tex)
latex/sections/               ← section .tex files (\input{} from main.tex)
latex/build/                  ← pdflatex output (gitignored)
docs/_config.yml              ← Jekyll config for GitHub Pages
docs/index.md                 ← snapshot registry (GitHub Pages landing page)
docs/snapshots/               ← versioned result snapshots (one folder per run)
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

## Early-Stage Workflow

### Code Exploration: Named Approach Subfolders

When the paper direction is not yet settled, keep competing analytical approaches in separate named subfolders directly under `code/`:

```
code/
├── approach-a-did/         ← DiD specification explorations
│   ├── 01_sample_20260401.R
│   └── 02_main_spec_20260403.R
├── approach-b-iv/          ← IV alternative
│   └── 01_first_stage_20260405.R
├── sample-construction/    ← shared data prep (used by all approaches)
├── result-generation/      ← promoted scripts for the winning approach
├── archives/               ← discarded approaches (move here, don't delete)
└── common.R                ← shared libraries and settings
```

**Conventions:**

- Name subfolders `approach-[descriptor]` (e.g., `approach-did`, `approach-iv-shift-share`).
- Scripts inside follow the same date-suffix convention: `01_desc_20260401.R`.
- Each approach folder may have its own `common_[slug].R` if it needs settings that differ from `code/common.R`.
- When an approach is chosen: move its scripts into `code/result-generation/`, archive the rest to `code/archives/`.
- When an approach is abandoned: move its folder to `code/archives/` — do not delete.

### Result Snapshots

Use `/skills/snapshot-results "slug"` to capture the current `latex/tables/` and `latex/figures/` into a versioned report under `docs/snapshots/`:

```
docs/snapshots/
└── 20260409-approach-a-baseline/
    ├── index.md        ← report with embedded figures and rendered tables
    ├── figures/        ← copies of latex/figures/*.png and *.pdf
    └── tables/         ← markdown-rendered versions of latex/tables/*.tex
```

**When to snapshot:**

- After completing a meaningful set of results (baseline spec, first pass at robustness).
- Before changing a specification that will alter existing outputs.
- When sharing preliminary findings with coauthors.

**Workflow:**

```
/skills/snapshot-results "approach-a-baseline"
# → creates docs/snapshots/20260409-approach-a-baseline/
# → updates docs/index.md registry
# → fill in the Summary section in index.md
# → git add docs/ && git commit && git push
```

### GitHub Pages (one-time setup)

1. Go to repo **Settings → Pages → Source**: Deploy from a branch → Branch: `main`, Folder: `/docs`.
2. After the first push to `docs/`, the site is live at `https://[username].github.io/[repo]/`.
3. The landing page (`docs/index.md`) lists all snapshots. Each snapshot links to its own `index.md` with embedded figures and tables.

---

## Runtime Paths

> **IMPORTANT:** Before running any R or Python command, verify these paths are filled in. If either is still a placeholder, stop and ask the user to provide the correct path before proceeding.

```
R_EXE           = "C:/Program Files/R/R-4.5.3/bin/R.exe"
PYTHON_VENV     = C:/envs/.basic_venv
PYTHON_VENV_DOCLING = C:/envs/.docling_venv
```

**Rules:**

- Always invoke R via `R_EXE` (e.g., `"$R_EXE" script.R`), never rely on `Rscript` or `R` being on PATH.
- Always activate the venv before running Python: source `$PYTHON_VENV/Scripts/activate` (Windows) or `$PYTHON_VENV/bin/activate` (Unix), then call `python`.
- **Exception:** When running `related-papers/convert_batch.py`, use `PYTHON_VENV_DOCLING` (`C:/envs/.docling_venv`) instead of `PYTHON_VENV`.
- If `R_EXE` is still `[PLACEHOLDER...]`, do **not** attempt to run the script — prompt the user: *"Please set `R_EXE` in CLAUDE.md before I can run this."*

---

## R Coding Standards

### Core Principles

- **Never render** `.qmd` or `.Rmd` files during script execution — run regressions and output tables/figures by sourcing `.R` scripts or running Quarto CLI explicitly.
- Place all `library()` calls at the very top of each script.
- Reset the environment with `rm(list = ls())` as the first line of every standalone script.
- Use **relative paths** exclusively. In Quarto/R Markdown documents, construct paths with `here::here()`. In plain `.R` scripts, use paths relative to the project root (e.g., `"data/raw/file.csv"`).
- Append date suffixes (`YYYYMMDD`) to new script filenames (e.g., `01_build_panel_20260406.R`).

### Project Organization

| Folder                      | Contents                                                                       |
| --------------------------- | ------------------------------------------------------------------------------ |
| `code/sample-construction/` | Plain `.R` scripts that read from `data/raw/` and write to `data/constructed/` |
| `code/result-generation/`   | `.qmd` documents with `type: source` that produce tables and figures           |
| `code/common.R`             | Shared libraries, paths, ggplot2 theme, fixest globals                         |

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

| Name           | Hex         |
| -------------- | ----------- |
| Primary blue   | `"#012169"` |
| Primary gold   | `"#f2a900"` |
| Accent gray    | `"#525252"` |
| Positive green | `"#15803d"` |
| Negative red   | `"#b91c1c"` |

### Econometric Modeling

- Use the `fixest` package for all panel regressions.
- Define global formula macros with `setFixest_fml()` and global output options with `setFixest_etable()` **once** in `code/common.R`. Reuse them across analysis files — do not redefine per script.
- Store model results in named lists (e.g., `r <- list(); r$baseline <- feols(...)`).

### Quarto Documents

- Use `type: source` in the Quarto YAML front matter so the document runs as a script without rendering to HTML/PDF.
- Suppress warnings and messages by default in chunk options.
- Do not knit/render `.qmd` files to check results — source them or run them via `quarto run`.

---

## Python Coding Standards

### Exploratory Display Rule

When executing code inline (e.g. `python -c "..."` or running a scratch snippet to answer "view/check/show me") and the result is a DataFrame with **< 100 rows and < 10 columns**, render it visually using Matplotlib:

```python
import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(min(12, max(4, len(df.columns))), min(8, max(2, len(df) * 0.3 + 1))))
ax.axis('off')
tbl = ax.table(cellText=df.values, colLabels=df.columns, loc='center', cellLoc='center')
tbl.auto_set_font_size(True)
tbl.set_fontsize(10)
fig.tight_layout()
plt.show()
```

**When to use:** User says "view", "check", "show", "what does X look like", or you are running exploratory one-off code to display a result.

**When NOT to use:** Writing or editing a `.py` script/file. Never embed `plt.show()` table pop-outs inside saved scripts — they are for interactive inspection only.

---

## Skills & Agents

Skills and agents live in `.claude/commands/` (symlinked from ai-vault in project repositories).
Invoke via slash commands in Claude Code:

**Skills:**

- `/skills/snapshot-results` — snapshot current tables & figures into `docs/snapshots/` for GitHub Pages sharing
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
- `/skills/pipeline-audit` — retrospective code-simplicity audit: maps every reported result to the code that produces it, identifies dead code and unnecessary complexity, and produces a simplification report

**Agents:**

- `/agents/finance-paper-reviewer` — full pre-submission review (6 sub-agents in parallel)
- `/agents/literature-downloader` — acquire PDFs and convert to markdown (3 phases: `seed`, `expand`, `finalize`)
- `/agents/literature-reviewer` — build .bib, summarize papers, write literature review (run after literature-downloader)
- `/agents/ai-detector` — detect LLM fingerprints and robotic prose
- `/agents/harsh-editor` — adversarial editorial review of paper vs. code
- `/agents/professor-robustness-check` — quick robustness replication from raw data
- `/agents/referee2-audit` — systematic 5-audit replication and code review
- `/agents/referee-response-evaluator` — evaluate and improve referee response letters
- `/agents/academic-paper-writer` — draft paper sections with IMRAD structure

---

## Output Style & Formatting Rules

### Professional Mode (Outward-Facing)

**Condition:** Task involves editing/generating content in `.tex`, `.bib`, or `.md` files, or drafting emails or academic prose.

- Ignore Caveman instructions entirely.
- Use professional academic English suitable for a Finance Professor: formal grammar, precise terminology, standard punctuation.
- Ensure all mathematical notation and citations strictly follow professional standards.

### Caveman Mode (Internal Communication)

**Condition:** Providing explanations, debugging code, or responding in the chat interface.

- Follow the Caveman protocol for token efficiency.
- Minimalist, no-fluff style. Technical accuracy and speed over prose.

**Examples:**

- "Why is my fixest regression failing?" → Caveman explanation.
- "Draft the methodology section in paper.tex" → Formal academic prose.

---

## LaTeX Conventions

- Output directory for pdflatex: `latex/build/`
- Figures referenced as `\includegraphics{figures/filename}` (graphicspath set in `latex/main.tex`)
- Tables `\input{}`-ed from `latex/tables/` or inline in section files
- Section files: `latex/sections/<section>/<section>_current.tex` (`\input{}`-ed from `main.tex`)
- Never edit `latex/build/` contents directly
- Compile sequence: `pdflatex → bibtex → pdflatex → pdflatex` (all run from `latex/` directory)
