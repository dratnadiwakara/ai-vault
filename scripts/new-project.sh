#!/usr/bin/env bash
# new-project.sh — Initialize a new research project from the ai-vault template.
#
# Usage:
#   ./scripts/new-project.sh <project-path> [vault-root]
#
# Arguments:
#   project-path   Absolute or relative path for the new project directory.
#                  Will be created if it does not exist.
#   vault-root     (Optional) Path to this ai-vault repository.
#                  Defaults to the parent directory of this script.
#
# Example:
#   ./scripts/new-project.sh ../my-paper
#   ./scripts/new-project.sh /home/user/projects/cecl-paper

set -euo pipefail

# ── Resolve paths ──────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_ROOT="${2:-$(dirname "$SCRIPT_DIR")}"
PROJECT_PATH="$(mkdir -p "$1" && cd "$1" && pwd)"

echo ""
echo "ai-vault new-project initializer"
echo "  Vault  : $VAULT_ROOT"
echo "  Project: $PROJECT_PATH"
echo ""

# ── Helper: create directory with .gitkeep ────────────────────────────────────
mk_dir() {
    local rel="$1"
    local full="$PROJECT_PATH/$rel"
    mkdir -p "$full"
    touch "$full/.gitkeep"
    echo "[dir]     $rel"
}

# ── Helper: copy a file from vault to project ──────────────────────────────────
cp_file() {
    local rel="$1"
    local src="$VAULT_ROOT/$rel"
    local dst="$PROJECT_PATH/$rel"
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "[copied]  $rel"
}

# ── Create empty template directories ─────────────────────────────────────────
echo "Creating directories..."
mk_dir "data/raw"
mk_dir "data/constructed"
mk_dir "code/sample-construction"
mk_dir "code/result-generation"
mk_dir "code/archives"
mk_dir "latex/figures"
mk_dir "latex/tables"
mk_dir "latex/build"
mk_dir "latex/sections/intro"
mk_dir "latex/sections/institutional-background"
mk_dir "latex/sections/data"
mk_dir "latex/sections/identification"
mk_dir "latex/sections/results"
mk_dir "latex/sections/heterogeneity"
mk_dir "latex/sections/robustness"
mk_dir "latex/sections/conclusion"
mk_dir "docs/slides"
mk_dir "docs/memos"
mk_dir "related-papers"
mk_dir "correspondence"

# ── Copy template files ────────────────────────────────────────────────────────
echo ""
echo "Copying template files..."
cp_file "CLAUDE.md"
cp_file ".gitignore"
cp_file ".claudeignore"
cp_file "code/common.R"
cp_file "latex/main.tex"
cp_file "latex/main.bib"
cp_file "latex/sections/intro/intro_current.tex"
cp_file "latex/sections/institutional-background/inst_bg_current.tex"
cp_file "latex/sections/data/data_current.tex"
cp_file "latex/sections/identification/identification_current.tex"
cp_file "latex/sections/results/results_current.tex"
cp_file "latex/sections/heterogeneity/heterogeneity_current.tex"
cp_file "latex/sections/robustness/robustness_current.tex"
cp_file "latex/sections/conclusion/conclusion_current.tex"
cp_file "docs/memos/revision_plan.md"
cp_file "docs/memos/referee_response.md"
cp_file "docs/memos/todo.md"

# ── .claude/ setup ─────────────────────────────────────────────────────────────
echo ""
echo "Setting up .claude/commands/ symlinks..."

CLAUDE_DIR="$PROJECT_PATH/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
mkdir -p "$COMMANDS_DIR"

# Copy settings.local.json
SETTINGS_SRC="$VAULT_ROOT/.claude/settings.local.json"
if [ -f "$SETTINGS_SRC" ]; then
    cp "$SETTINGS_SRC" "$CLAUDE_DIR/settings.local.json"
    echo "[copied]  .claude/settings.local.json"
fi

# Symlink skills and agents back to vault
VAULT_SKILLS="$VAULT_ROOT/.claude/commands/skills"
VAULT_AGENTS="$VAULT_ROOT/.claude/commands/agents"
PROJ_SKILLS="$COMMANDS_DIR/skills"
PROJ_AGENTS="$COMMANDS_DIR/agents"

mk_symlink() {
    local link="$1"
    local target="$2"
    local label="$3"
    if [ -e "$link" ] || [ -L "$link" ]; then
        echo "[exists]  $label (skipped)"
    else
        ln -sfn "$target" "$link"
        echo "[symlink] $label -> $target"
    fi
}

mk_symlink "$PROJ_SKILLS" "$VAULT_SKILLS" ".claude/commands/skills"
mk_symlink "$PROJ_AGENTS" "$VAULT_AGENTS" ".claude/commands/agents"

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
echo "Done."
echo ""
echo "Next steps:"
echo "  1. Open $PROJECT_PATH in Claude Code"
echo "  2. Edit CLAUDE.md — replace all [PLACEHOLDER] sections with paper-specific context"
echo "  3. Add raw data to data/raw/ (gitignored)"
echo "  4. Initialize git: cd '$PROJECT_PATH' && git init"
echo ""
