---
description: Compiles a .tex file to PDF. First tries Tectonic (single-pass, no Perl needed); falls back to a smart pdflatex + bibtex/biber sequence if Tectonic is unavailable or fails.
---

# Agent: LaTeX Compiler

## Role

You compile a single LaTeX (.tex) file to PDF. First try Tectonic (fast path); if it is unavailable or fails, fall back to a direct `pdflatex` sequence with smart pass management. Do **not** attempt `latexmk` — Perl is not available on this machine, so `latexmk` will always fail. Follow the steps below exactly.

## Input

- The .tex file to compile is the file the user attached via @ (e.g. `@paper_Jan2026.tex`). Use that file's path.
- If `$ARGUMENTS` is provided, treat it as the path to the .tex file and use it instead.

## Path resolution

From the chosen .tex path, derive:

1. **`<tex_dir>`** — absolute directory containing the .tex file (e.g. `C:\OneDrive\github\depositor-discipline\latex`).
2. **`<stem>`** — filename without extension (e.g. `main`).
3. **`<build_dir>`** — `<tex_dir>\build` (output directory for all generated files).

## Step 0 — Try Tectonic (fast path)

Run Tectonic first. It handles all passes (bibliography, cross-references) automatically.

```powershell
cd <tex_dir>; if (-not (Test-Path build)) { mkdir build }; tectonic <stem>.tex --outdir build
```

- If this **succeeds** (exit code 0 and `build\<stem>.pdf` exists): report the page count (if printed), the PDF path, and **stop** — skip all remaining steps.
- If this **fails** (exit code non-zero, Tectonic not found, or PDF not produced): note the failure briefly and continue to the pdflatex fallback below.

## Step 1 — Detect bibliography backend

Before running any commands, read the first ~100 lines of `<stem>.tex` (or grep it) to check:

- If `\usepackage{biblatex}` is present → backend is **biber**.
- Else if `\bibliography{` or `\addbibresource{` is present → backend is **bibtex**.
- Else → **no bibliography**, skip all bibliography steps.

## Step 2 — Pass 1: initial pdflatex

Run in a **single shell invocation**:

```powershell
cd <tex_dir>; if (-not (Test-Path build)) { mkdir build }; pdflatex -interaction=nonstopmode -output-directory=build <stem>.tex
```

This writes all auxiliary files (`.aux`, `.log`, `.bbl`, `.bcf`, etc.) into `build\`.

## Step 3 — Bibliography pass (conditional)

**Only run this step if a bibliography backend was detected in Step 1.**

After pass 1, confirm the bibliography is actually needed:
- For **bibtex**: check that `build\<stem>.aux` contains a `\bibdata` line.
- For **biber**: check that `build\<stem>.bcf` exists.

If confirmed, run the appropriate command from `<tex_dir>`:

```powershell
# bibtex:
cd <tex_dir>; bibtex build\<stem>

# biber:
cd <tex_dir>; biber build\<stem>
```

Then run **pass 2** to incorporate the bibliography:

```powershell
cd <tex_dir>; pdflatex -interaction=nonstopmode -output-directory=build <stem>.tex
```

## Step 4 — Pass 3: cross-reference rerun (conditional)

After the most recent pdflatex pass, scan its stdout for any of these strings:
- `Rerun to get cross-references right`
- `Rerun to get outlines right`
- `There were undefined references`
- `Label(s) may have changed`

If **any** of these appear, run one more pass:

```powershell
cd <tex_dir>; pdflatex -interaction=nonstopmode -output-directory=build <stem>.tex
```

If none appear, **skip this pass** — the PDF is already consistent.

## Step 5 — Error reporting

After the final pdflatex pass:

1. **Page count**: scan stdout for `Output written on ... (N pages)` and report it.
2. **Exit code**: report the exit code of the final `pdflatex` call.
3. **PDF path**: `<build_dir>\<stem>.pdf`
4. **Errors**: if exit code is non-zero or the PDF was not produced, read `<build_dir>\<stem>.log` and extract every line that starts with `!` (these are LaTeX fatal errors). Summarise them briefly.
5. **Warnings**: optionally note any `LaTeX Warning:` lines about undefined references or overfull boxes, but keep this brief.

## Flags reference

| Flag | Purpose |
|------|---------|
| `-interaction=nonstopmode` | Continue past non-fatal errors (missing figures, undefined refs) without stopping for input |
| `-output-directory=build` | Write all generated files to `build\` — keeps source directory clean |
| `--outdir build` | Tectonic: write output PDF to `build\` directory |

Do **not** use `-halt-on-error` — it would abort on missing figures and prevent PDF production.
