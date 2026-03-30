#!/usr/bin/env bash
# Link a project to ai-vault: .cursor/rules, .cursor/skills, .cursor/agents -> vault dirs.
# Usage (from target project root):
#   bash /path/to/ai-vault/scripts/link-ai-vault.sh /path/to/ai-vault
#
# Options:
#   --validate   Only check vault layout and symlinks
#   --skip-claude  Do not create/update CLAUDE.md

set -euo pipefail

VALIDATE=0
SKIP_CLAUDE=0
VAULT_ROOT=""

scaffold_dirs=(
  "code/archives"
  "code/sample-construction"
  "code/result-generation"
  "data/raw"
  "data/clean"
  "docs/figures"
  "docs/tables"
  "docs/slides"
  "docs/todo"
  "docs/other-materials"
  "latex"
)

expected_cursorignore=$'data/\ndata/**\n'
expected_claudeignore=$'data/\ndata/**\n'

# Embedded .gitignore template (included in-repo; no external fetch)
gitignore_template=$'related-papers/\narchives/\narchives/**\n\n\n# LaTeX compilation files\npaper_Jan2026.pdf\n*.aux\n*.log\n*.out\n*.bbl\n*.blg\n*.toc\n*.lof\n*.lot\n*.synctex.gz\n*.fls\n*.fdb_latexmk\n*.nav\n*.snm\n*.vrb\n\n# Data files\n*.parquet\n*.rds\n*.csv\n*.xls\n*.xslx\n\n# R configuration files\n.Rprofile\n.Rhistory\n.RData\n.Rproj.user\n.Rproj\n'

while [[ $# -gt 0 ]]; do
  case "$1" in
    --validate) VALIDATE=1; shift ;;
    --skip-claude) SKIP_CLAUDE=1; shift ;;
    *) VAULT_ROOT="$1"; shift ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -z "$VAULT_ROOT" ]]; then
  VAULT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
fi
VAULT_ROOT="$(cd "$VAULT_ROOT" && pwd)"
PROJECT_ROOT="$(pwd)"

for d in rules skills agents; do
  if [[ ! -d "$VAULT_ROOT/$d" ]]; then
    echo "error: missing vault directory: $VAULT_ROOT/$d" >&2
    exit 1
  fi
done

check_autoapply() {
  local bad=0
  while IFS= read -r -d '' f; do
    local base
    base="$(basename "$f")"
    if grep -q 'alwaysApply:[[:space:]]*true' "$f" 2>/dev/null; then
      if [[ "$base" != "r-code-conventions.mdc" ]]; then
        echo "warning: alwaysApply: true in $base (only r-code-conventions.mdc should)" >&2
        bad=1
      fi
    fi
  done < <(find "$VAULT_ROOT/rules" -maxdepth 1 -name '*.mdc' -print0 2>/dev/null)
  if [[ ! -f "$VAULT_ROOT/rules/r-code-conventions.mdc" ]]; then
    echo "error: missing r-code-conventions.mdc" >&2
    return 1
  fi
  if ! grep -q 'alwaysApply:[[:space:]]*true' "$VAULT_ROOT/rules/r-code-conventions.mdc"; then
    echo "error: r-code-conventions.mdc should have alwaysApply: true" >&2
    return 1
  fi
  return $bad
}

if [[ "$VALIDATE" -eq 1 ]]; then
  echo "=== Validate vault: $VAULT_ROOT"
  autoapply_bad=0
  if ! check_autoapply; then
    autoapply_bad=1
  fi

  scaffoldErrors=0
  for dir in "${scaffold_dirs[@]}"; do
    if [[ ! -d "$dir" ]]; then
      echo "warning: missing scaffold dir: $dir" >&2
      scaffoldErrors=1
    fi
  done

  # Validate ignore files
  if [[ ! -f ".gitignore" ]]; then
    echo "warning: missing .gitignore" >&2
    scaffoldErrors=1
  else
    # Basic content checks (avoid having to require exact full file equality)
    for needle in "related-papers/" "archives/**" "paper_Jan2026.pdf" "*.rds" ".Rproj"; do
      if ! grep -qF "$needle" ".gitignore"; then
        echo "warning: .gitignore missing expected content: $needle" >&2
        scaffoldErrors=1
      fi
    done
  fi

  if [[ ! -f ".cursorignore" ]]; then
    echo "warning: missing .cursorignore" >&2
    scaffoldErrors=1
  else
    got="$(tr -d '\r' < ".cursorignore")"
    got="${got%$'\n'}"$'\n'
    if [[ "$got" != "$expected_cursorignore" ]]; then
      echo "warning: .cursorignore does not match expected data-only ignore" >&2
      scaffoldErrors=1
    fi
  fi

  if [[ ! -f ".claudeignore" ]]; then
    echo "warning: missing .claudeignore" >&2
    scaffoldErrors=1
  else
    got="$(tr -d '\r' < ".claudeignore")"
    got="${got%$'\n'}"$'\n'
    if [[ "$got" != "$expected_claudeignore" ]]; then
      echo "warning: .claudeignore does not match expected data-only ignore" >&2
      scaffoldErrors=1
    fi
  fi

  for name in rules skills agents; do
    link="$PROJECT_ROOT/.cursor/$name"
    target="$VAULT_ROOT/$name"
    linkErrors=0
    if [[ -L "$link" ]]; then
      resolved="$(readlink -f "$link" 2>/dev/null || readlink "$link")"
      if [[ "$resolved" == "$target" ]]; then
        echo "OK: .cursor/$name -> $target"
      else
        echo "warning: .cursor/$name -> $resolved (expected $target)" >&2
        linkErrors=1
      fi
    else
      echo "warning: missing or not a symlink: $link" >&2
      linkErrors=1
    fi

    if [[ "$linkErrors" -eq 1 ]]; then
      scaffoldErrors=1
    fi
  done

  exit $((autoapply_bad || scaffoldErrors ? 1 : 0))
fi

check_autoapply || exit 1

mkdir -p "$PROJECT_ROOT/.cursor"
for name in rules skills agents; do
  link="$PROJECT_ROOT/.cursor/$name"
  target="$VAULT_ROOT/$name"
  rm -rf "$link"
  ln -sfn "$target" "$link"
  echo "Linked .cursor/$name -> $target"
done

# Create scaffold + overwrite ignore files
for dir in "${scaffold_dirs[@]}"; do
  mkdir -p "$dir"
done

printf '%s' "$gitignore_template" > "$PROJECT_ROOT/.gitignore"
printf '%s' "$expected_cursorignore" > "$PROJECT_ROOT/.cursorignore"
printf '%s' "$expected_claudeignore" > "$PROJECT_ROOT/.claudeignore"

if [[ "$SKIP_CLAUDE" -eq 0 ]]; then
  CLAUDE="$PROJECT_ROOT/CLAUDE.md"
  BRIDGE="

---

## Linked AI vault

This project uses a shared **ai-vault** at:

\`$VAULT_ROOT\`

- Cursor: \`.cursor/rules\`, \`.cursor/skills\`, \`.cursor/agents\` symlink to the vault.
- Only \`rules/r-code-conventions.mdc\` auto-applies for R/Quarto files. Other rules, skills, and agents are **explicit invocation** only.
"
  if [[ -f "$CLAUDE" ]]; then
    if ! grep -q 'Linked AI vault' "$CLAUDE"; then
      printf '%s' "$BRIDGE" >> "$CLAUDE"
      echo "Appended vault bridge to CLAUDE.md"
    else
      echo "CLAUDE.md already contains vault bridge; skipped"
    fi
  else
    {
      echo "# Project context"
      printf '%s' "$BRIDGE"
    } > "$CLAUDE"
    echo "Created CLAUDE.md with vault bridge"
  fi
fi

echo "Done. Project linked to ai-vault at $VAULT_ROOT"
