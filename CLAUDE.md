> **Note:** This is the ai-vault template repository. When initializing a new project,
> run `scripts/new-project.ps1` (or `.sh`) from this directory.
> The CLAUDE.md in new projects is copied from this file — remove this note and
> fill in all [PLACEHOLDER] sections for the specific paper.

# [PAPER_TITLE] — Project Context

**Paper**: [PAPER_TITLE]
**Slug**: [PAPER_SLUG]
**Description**: [SHORT_DESCRIPTION]
**Authorship**: [PLACEHOLDER — `solo` or `coauthored`. Drives first-person voice in writing skills: `solo` → "I" (per Cochrane 2005); `coauthored` → "we". Default if unset: `coauthored`.]

## Project Layout

```
data/raw/                     ← raw source data (never modified)
data/constructed/             ← intermediate constructed datasets
code/common.R                 ← shared libraries, paths, global options
code/approach-[name]-[month-year]/         ← early-stage: one subfolder per analytical approach (e.g. approach-did-march2026)
code/approach-[name]-[month-year]/tables/  ← intermediate table output (.md only) for this approach
code/approach-[name]-[month-year]/figures/ ← intermediate figure output (.png, .pdf) for this approach
code/sample-construction/     ← plain .R scripts that build analytical samples
code/result-generation/       ← .qmd documents that generate tables and figures
code/archives/                ← old scripts (not sourced)
latex/main.tex                ← master LaTeX document (FINAL STAGE ONLY)
latex/main.bib                ← BibTeX references
latex/figures/                ← FINAL figure output — populated only when results are finalized
latex/tables/                 ← FINAL table output — populated only when results are finalized
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
├── approach-did-april2026/       ← DiD specification explorations
│   ├── 01_sample_20260401.R
│   ├── 02_main_spec_20260403.R
│   ├── tables/             ← intermediate table output (.md only)
│   └── figures/            ← intermediate figure output (.png, .pdf)
├── approach-iv-april2026/        ← IV alternative
│   ├── 01_first_stage_20260405.R
│   ├── tables/
│   └── figures/
├── sample-construction/    ← shared data prep (used by all approaches)
├── result-generation/      ← promoted scripts for the winning approach
├── archives/               ← discarded approaches (move here, don't delete)
└── common.R                ← shared libraries and settings
```

**Conventions:**

- Name subfolders `approach-[descriptor]-[month-year]` where month-year is lowercase (e.g., `approach-did-march2026`, `approach-iv-shift-share-april2026`). The month-year suffix marks when the approach was started and disambiguates re-attempts of the same approach at different points in the project.
- Scripts inside follow the same date-suffix convention: `01_desc_20260401.R`.
- Each approach folder may have its own `common_[slug].R` if it needs settings that differ from `code/common.R`.
- **All intermediate outputs (tables and figures) stay inside the approach subfolder** — write to `code/approach-[name]-[month-year]/tables/` and `code/approach-[name]-[month-year]/figures/`, never to `latex/`.
- The `latex/` directory is reserved for the final stage only. Do not write anything there until the user explicitly instructs promotion.
- When an approach is chosen and finalized: copy tables to `latex/tables/` and figures to `latex/figures/`, then move scripts into `code/result-generation/`, archive the rest to `code/archives/`.
- When an approach is abandoned: move its folder to `code/archives/` — do not delete.

### Result Snapshots

Use `/skills/snapshot-results "slug"` to capture the current approach's `tables/` and `figures/` into a versioned report under `docs/snapshots/`. The skill looks for outputs in `code/approach-[name]-[month-year]/tables/` and `code/approach-[name]-[month-year]/figures/` — specify the approach folder name as an argument if needed.

```
docs/snapshots/
└── 20260409-approach-did-april2026-baseline/
    ├── index.md        ← report with embedded figures and rendered tables
    ├── figures/        ← copies of code/approach-[name]-[month-year]/figures/*.png and *.pdf
    └── tables/         ← markdown-rendered versions of code/approach-[name]-[month-year]/tables/*.tex
```

**When to snapshot:** Only when the user explicitly requests it. Never snapshot automatically.

**Workflow:**

```
/skills/snapshot-results "approach-did-april2026-baseline"
# → reads from code/approach-did-april2026/tables/ and code/approach-did-april2026/figures/
# → creates docs/snapshots/20260409-approach-did-april2026-baseline/
# → updates docs/index.md registry
# → fill in the Summary section in index.md
```

---

## API Keys & Secrets

All API keys and credentials stored at `C:\key-variables\key-variables.yaml`. Read from there when any key is needed — do not ask user to provide keys manually.

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

### Data Lineage Comments

Every script that reads a prebuilt `.rds` / `.parquet` / `.csv` from `data/` or `data/constructed/` must include a lineage comment block **immediately above** the `readRDS()` / `load_latest()` / `fread()` call. Format:

```r
# Source: <path to file, with YYYYMMDD placeholder if glob-loaded>
# Built by:   <path to upstream build script>
# Contents:   <one- or two-line description of key columns / sample>
dt <- setDT(load_latest("data", "^zip_tech_sample_\\d{8}\\.rds$"))
```

Rules:

- Build-script path must be clickable in the IDE (use the repo-relative path, e.g. `code/approach-[name]/sample-construction/B1_xxx.R`).
- If the file touches external (OneDrive, duckdb) sources, document those too — either inline above the path constant, or in a block above `source()`.
- When a single `00_common.R` is sourced by many scripts, the top of `00_common.R` should carry a full lineage map listing every consumed dataset and its upstream script.
- When refactoring a folder (e.g. moving build scripts to a new location), update every lineage comment that references the old path — the comments are load-bearing documentation, not decoration.

### External Data: `empirical-data-construction`

If any script consumes data produced by `C:\Users\dimut\OneDrive\github\empirical-data-construction`:

- **Read the `README.md` files carefully** (root README and the per-dataset README for the specific dataset) before writing code that loads the data. Column names, units, coverage, and caveats live there.
- **Do not load the `.parquet` files directly.** Query the **DuckDB harmonized views** instead — they apply the canonical joins, filters, and naming conventions.
- If a harmonized view does not exist for the needed dataset, stop and ask the user before falling back to parquet.

### Figure & Table Export

- **During early-stage work (approach subfolders):** write outputs to the approach subfolder:
  - Figures → `code/approach-[name]-[month-year]/figures/` as `.png` files with `bg = "transparent"`.
  - Tables → `code/approach-[name]-[month-year]/tables/` as `.md` files only — **no `.tex` during exploration**.
- **Final stage only (on explicit user instruction):** copy outputs to `latex/figures/` and `latex/tables/` (converting to `.tex` at that point).
- Never write to `latex/` during exploratory or approach-stage work.
- Control exports with logical flags at the top of each script:

  ```r
  save_figures <- TRUE
  save_tables  <- TRUE
  ```

### Regression Table Markdown Export

For regression tables in approach subfolders, convert `etable()` output to a true pipe-delimited markdown table via `knitr::kable(format = "pipe")`:

```r
# etable() with tex=FALSE returns a data.frame-like object.  Use a CHARACTER
# VECTOR for `headers` (one label per column) -- the list-form
# `headers = list("Early" = 1, ...)` encodes column-spans and produces stray
# 0/1 rows in the markdown output.
et <- etable(m1, m2, m3,
             headers = c("Early", "Mid", "Late"),
             tex     = FALSE)
df <- as.data.frame(et, stringsAsFactors = FALSE)
rownames(df) <- NULL
md <- knitr::kable(df, format = "pipe", row.names = FALSE)
writeLines(as.character(md), paste0(tables_path, "tab_name.md"))
```

- Always use `tex = FALSE` in `etable()` during exploration.
- Pass column labels as a **character vector**, not a named list, to avoid span-encoded 1-rows in the output.
- For descriptive stat tables, use `knitr::kable(df, format = "pipe")`.
- Do **not** save `.tex` regression tables during exploration -- markdown only.
- Do not use `capture.output(print(et))` -- it produces space-aligned text that line-wraps when the terminal is narrow and breaks the table into chunks.

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

#### Regression Style: Explicit, Not Programmatic

**Never generate regressions inside loops, `lapply`, `purrr::map`, or any other iteration construct.** Each regression must be written out explicitly so the user can highlight and run a single model without executing the entire script.

```r
# CORRECT — each model is a standalone, runnable line
r$baseline   <- feols(y ~ x1 + x2 | unit + year, data = df, cluster = ~unit)
r$controls   <- feols(y ~ x1 + x2 + x3 + x4 | unit + year, data = df, cluster = ~unit)
r$subsample  <- feols(y ~ x1 + x2 | unit + year, data = df[df$group == 1, ], cluster = ~unit)

# WRONG — hides individual models, cannot run one at a time
specs <- list(~x1, ~x1+x2, ~x1+x2+x3)
r <- lapply(specs, function(s) feols(as.formula(paste("y ~", s)), data = df))
```

This rule applies even when specifications differ only slightly. Repetition is intentional — it makes each model independently readable and executable.

### Winsorization

Winsorize sparingly and document the choice on a per-variable basis.

- **Default cutoffs are 1/99.** Use the 1st and 99th percentiles unless there is a specific reason to deviate (and ask the user before deviating).
- **Skip bounded variables by default.** Percentages, fractions, ratios with a natural [0, 1] (or [0, 100]) support, and other inherently bounded measures do not require winsorization. Apply it only if the distribution exhibits genuinely extreme values that visibly distort estimates — never as a routine pre-processing step.
- **Skip variables with a well-behaved distribution.** If the tails are not pathological (no isolated outliers many standard deviations from the mass, no obvious data-entry errors), leave the variable untouched.
- **Winsorize within period for panel data.** When the variable has meaningful time-series variation, compute the winsorization cutoffs within each period (year, quarter, cycle) rather than pooling across the panel. Pooled winsorization disproportionately clips periods with systematically high or low realizations (e.g., crisis years, rate-hike cycles) and induces spurious mean reversion across time.
- **Ask when in doubt.** If it is not obvious whether a given variable should be winsorized, or which cutoffs (1/99 vs. 5/95) and grouping (within period, within bank, full panel) apply, stop and ask the user before proceeding. Do not silently winsorize a newly added variable.
- **Document every winsorization site** with a one-line comment stating the cutoffs and the grouping (e.g., `# winsor 1/99 within YEAR`).

### Regression Table Footer Rows

Every regression table must include two footer rows below N: **Mean(DV)** and **SD(treatment)**.

- `Mean(DV)`: mean of the dependent variable computed from the exact `data=` subset passed to `feols()` (after all sample filters and `na.omit`), rounded to 3 decimal places.
- `SD(treatment)`: standard deviation of the key treatment variable (not controls) from the same subset, rounded to 3 decimal places.
- Use the actual variable name as the label when cleaner (e.g., `Mean(gr\_branch)`, `SD(share\_deps\_closed)`).

Compute inline before calling `feols()`:

```r
mean_dv  <- round(mean(data$dep_var,     na.rm = TRUE), 3)
sd_treat <- round(sd(data$treatment_var, na.rm = TRUE), 3)
```

Add via `etable()` `extralines` argument or append manually to the exported `.tex`. Row order: **N → Mean(DV) → SD(treatment) → Within R²**.

### Key Results Summary (print after generating regression tables)

After a regression script finishes writing table files, print a concise key-coefficient summary in the chat as a Markdown table. This gives the user a fast overview without having to open each table file.

**Format:**

```
| Outcome | Coef | SE | Sig | N |
|---|---|---|---|---|
| Δ Loans | -0.033 | 0.374 |  | 2,654 |
| Δ Securities | 0.486 | 0.303 |  | 2,654 |
| Δ log(A/Emp) | 0.023 | 0.008 | *** | 2,654 |
| ... | ... | ... | ... | ... |
```

**Rules:**

- One row per outcome (dependent variable). For multi-column tables in the same table file, list each column as a separate row.
- Columns: **Outcome**, **Coef** (key endogenous/treatment coefficient, 3 decimals), **SE** (3 decimals), **Sig** (stars: `*` p<0.10, `**` p<0.05, `***` p<0.01; blank if not significant), **N**.
- Below the table, report the first-stage F-statistic (for IV specifications) and flag any specification change from the prior run (e.g., controls added/removed, sample filter changed).
- End with one short line (≤25 words) summarizing the overall pattern — not per-coefficient interpretation.
- Do **not** repeat the full etable output (controls, fixed effects lines, SE type) — that lives in the saved `.md` file.
- Do **not** print this summary for descriptive-stat tables (Table 1, Table 2 style) — only for regression tables.

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

## Session Memory

`NOTES.md` files are written by the `/agents/session-debrief` agent after each work session. They summarize what was done, decisions made, and open threads.

- `NOTES.md` in project root → high-level summary of overall paper progress
- `NOTES.md` in subfolders (e.g., `code/approach-did/NOTES.md`) → focused notes specific to that directory's work

Read relevant `NOTES.md` at session start to orient quickly. They are a supplement to — not a substitute for — reading code and git history when deeper context is needed.

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
- `/skills/cochrane-style-check` — audit a `.tex` file against Cochrane (2005) "Writing Tips for Ph.D. Students"; report under `.claude/cc/cochrane-style-check/`. Reads `**Authorship**` field from this file

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
