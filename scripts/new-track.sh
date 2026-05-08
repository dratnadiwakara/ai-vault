#!/usr/bin/env bash
# new-track.sh — Scaffold a new analytical track inside an ai-vault project.
#
# Creates tracks/<descriptor>-<month-year>/ with self-contained code/, data/,
# and latex/ subfolders, then copies the LaTeX template from the vault.
#
# Usage:
#   ./scripts/new-track.sh <project-path> <descriptor> [vault-root]
#
# Example:
#   ./scripts/new-track.sh ../my-paper did
#   ./scripts/new-track.sh /home/user/projects/my-paper iv-shift-share

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <project-path> <descriptor> [vault-root]" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_PATH="$(cd "$1" && pwd)"
DESCRIPTOR="$2"
VAULT_ROOT="${3:-$(dirname "$SCRIPT_DIR")}"

if [ ! -d "$PROJECT_PATH/tracks" ]; then
    echo "No tracks/ folder at $PROJECT_PATH. Run new-project.sh first." >&2
    exit 1
fi

# Slugify descriptor and append month-year
SLUG="$(echo "$DESCRIPTOR" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9-]/-/g' -e 's/-\{2,\}/-/g' -e 's/^-//' -e 's/-$//')"
MONTH_YEAR="$(date +'%B%Y' | tr '[:upper:]' '[:lower:]')"
TRACK_DIR="tracks/$SLUG-$MONTH_YEAR"

if [ -d "$PROJECT_PATH/$TRACK_DIR" ]; then
    echo "Track already exists: $PROJECT_PATH/$TRACK_DIR" >&2
    exit 1
fi

echo ""
echo "ai-vault new-track"
echo "  Project : $PROJECT_PATH"
echo "  Track   : $TRACK_DIR"
echo ""

mk_dir() {
    local rel="$1"
    local full="$PROJECT_PATH/$rel"
    mkdir -p "$full"
    touch "$full/.gitkeep"
    echo "[dir]     $rel"
}

cp_tpl() {
    local src_rel="$1"
    local dst_rel="$2"
    local src="$VAULT_ROOT/$src_rel"
    local dst="$PROJECT_PATH/$dst_rel"
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "[copied]  $dst_rel"
}

echo "Creating track directories..."
mk_dir "$TRACK_DIR/code/sample-construction"
mk_dir "$TRACK_DIR/code/result-generation"
mk_dir "$TRACK_DIR/code/archives"
mk_dir "$TRACK_DIR/data"
mk_dir "$TRACK_DIR/latex/figures"
mk_dir "$TRACK_DIR/latex/tables"
mk_dir "$TRACK_DIR/latex/build"
mk_dir "$TRACK_DIR/latex/sections/intro"
mk_dir "$TRACK_DIR/latex/sections/institutional-background"
mk_dir "$TRACK_DIR/latex/sections/data"
mk_dir "$TRACK_DIR/latex/sections/identification"
mk_dir "$TRACK_DIR/latex/sections/results"
mk_dir "$TRACK_DIR/latex/sections/heterogeneity"
mk_dir "$TRACK_DIR/latex/sections/robustness"
mk_dir "$TRACK_DIR/latex/sections/conclusion"

echo ""
echo "Copying LaTeX template..."
TPL="scripts/templates/track"
cp_tpl "$TPL/main.tex" "$TRACK_DIR/latex/main.tex"
cp_tpl "$TPL/main.bib" "$TRACK_DIR/latex/main.bib"
cp_tpl "$TPL/sections/intro/intro_current.tex"                              "$TRACK_DIR/latex/sections/intro/intro_current.tex"
cp_tpl "$TPL/sections/institutional-background/inst_bg_current.tex"         "$TRACK_DIR/latex/sections/institutional-background/inst_bg_current.tex"
cp_tpl "$TPL/sections/data/data_current.tex"                                "$TRACK_DIR/latex/sections/data/data_current.tex"
cp_tpl "$TPL/sections/identification/identification_current.tex"            "$TRACK_DIR/latex/sections/identification/identification_current.tex"
cp_tpl "$TPL/sections/results/results_current.tex"                          "$TRACK_DIR/latex/sections/results/results_current.tex"
cp_tpl "$TPL/sections/heterogeneity/heterogeneity_current.tex"              "$TRACK_DIR/latex/sections/heterogeneity/heterogeneity_current.tex"
cp_tpl "$TPL/sections/robustness/robustness_current.tex"                    "$TRACK_DIR/latex/sections/robustness/robustness_current.tex"
cp_tpl "$TPL/sections/conclusion/conclusion_current.tex"                    "$TRACK_DIR/latex/sections/conclusion/conclusion_current.tex"

echo ""
echo "Done."
echo ""
echo "Track ready at: $TRACK_DIR"
echo ""
echo "Next steps:"
echo "  1. Edit $TRACK_DIR/latex/main.tex — replace [PAPER_TITLE] placeholders"
echo "  2. Drop sample-construction scripts in $TRACK_DIR/code/sample-construction/"
echo "  3. Drop analysis .qmd in $TRACK_DIR/code/result-generation/"
echo "  4. Invoke skills with the track name, e.g.:"
echo "       /skills/latex-compile $SLUG-$MONTH_YEAR"
echo ""
