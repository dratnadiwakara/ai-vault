#!/usr/bin/env bash
# new-project.sh — Initialize a new research project from the ai-vault template.
#
# Creates the shared (cross-track) folder structure and copies template files
# from the vault. Per-track scaffolding (code/, data/, latex/) lives inside
# tracks/<descriptor>-<month-year>/ and is created by scripts/new-track.sh.
#
# Usage:
#   ./scripts/new-project.sh <project-path> [vault-root]
#
# Example:
#   ./scripts/new-project.sh ../my-paper
#   ./scripts/new-project.sh /home/user/projects/cecl-paper

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_ROOT="${2:-$(dirname "$SCRIPT_DIR")}"
PROJECT_PATH="$(mkdir -p "$1" && cd "$1" && pwd)"

echo ""
echo "ai-vault new-project initializer"
echo "  Vault  : $VAULT_ROOT"
echo "  Project: $PROJECT_PATH"
echo ""

mk_dir() {
    local rel="$1"
    local full="$PROJECT_PATH/$rel"
    mkdir -p "$full"
    touch "$full/.gitkeep"
    echo "[dir]     $rel"
}

cp_file() {
    local rel="$1"
    local src="$VAULT_ROOT/$rel"
    local dst="$PROJECT_PATH/$rel"
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "[copied]  $rel"
}

# ── Shared (cross-track) directories ──────────────────────────────────────────
echo "Creating shared directories..."
mk_dir "data/raw"
mk_dir "data/constructed"
mk_dir "code"
mk_dir "tracks"
mk_dir "docs/slides"
mk_dir "docs/memos"
mk_dir "docs/snapshots"
mk_dir "related-papers"
mk_dir "correspondence"

# ── Copy shared template files (no per-track scaffolding) ────────────────────
echo ""
echo "Copying template files..."
cp_file "CLAUDE.md"
cp_file ".gitignore"
cp_file ".claudeignore"
cp_file "code/common.R"
cp_file "docs/memos/revision_plan.md"
cp_file "docs/memos/referee_response.md"
cp_file "docs/memos/todo.md"
cp_file "docs/index.md"
cp_file "docs/_config.yml"
cp_file "docs/_layouts/default.html"
cp_file "docs/css/site.css"

# ── .claude/ setup ─────────────────────────────────────────────────────────────
echo ""
echo "Setting up .claude/commands/ symlinks..."

CLAUDE_DIR="$PROJECT_PATH/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
mkdir -p "$COMMANDS_DIR"

SETTINGS_SRC="$VAULT_ROOT/.claude/settings.local.json"
if [ -f "$SETTINGS_SRC" ]; then
    cp "$SETTINGS_SRC" "$CLAUDE_DIR/settings.local.json"
    echo "[copied]  .claude/settings.local.json"
fi

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

echo ""
echo "Done."
echo ""
echo "Next steps:"
echo "  1. Open $PROJECT_PATH in Claude Code"
echo "  2. Edit CLAUDE.md — replace all [PLACEHOLDER] sections with paper-specific context"
echo "  3. Add raw data to data/raw/ (gitignored)"
echo "  4. Create your first track:"
echo "       $VAULT_ROOT/scripts/new-track.sh '$PROJECT_PATH' <descriptor>"
echo "  5. Initialize git: cd '$PROJECT_PATH' && git init"
echo ""
