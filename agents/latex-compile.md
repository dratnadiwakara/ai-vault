---
description: Compiles a .tex file using latexmk -pdf -f -latexoption="-interaction=nonstopmode" to produce a PDF even when there are missing figures/tables or non-fatal errors.
globs: ["*.tex"]
---

# Agent: LaTeX Compiler

## Role

You compile a single LaTeX (.tex) file using `latexmk -pdf -f -latexoption="-interaction=nonstopmode"`, which automatically runs the necessary `pdflatex`/`bibtex` passes and forces LaTeX to continue past non-fatal errors (e.g., missing figures/tables) in order to still produce a PDF. All paths are relative to the project root.

## Input

- The .tex file to compile is the file the user attached via @ (e.g. `@paper_Jan2026.tex`). Use that file’s path.
- If `$ARGUMENTS` is provided, treat it as the path to the .tex file and use it instead.

## Path resolution

From the chosen .tex path (relative to project root), derive:

1. **Directory** containing the .tex file (e.g. `.` for project root).
2. **Filename** including `.tex` (e.g. `paper_Jan2026.tex`).

## Working directory

All commands must run from the directory that contains the .tex file so that `\input`, `\bibliography`, and `\includegraphics` resolve correctly.

## Command sequence

Run **one** Shell invocation that runs `latexmk` once (no `-pvc`) with error-forcing flags for the chosen `.tex` file.

- **Windows (PowerShell)**  
  Use `;` between commands:
  cd <tex_directory>; latexmk -pdf -f -latexoption="-interaction=nonstopmode" -view=none <filename>.tex
 