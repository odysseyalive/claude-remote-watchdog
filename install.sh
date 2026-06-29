#!/bin/bash
# Install / update claude-remote-watchdog (Linux / macOS / WSL).
#
# Downloads the files listed in manifest.txt straight from the repo and
# writes them under ~/.claude/. Re-run any time to update to the latest
# version — it overwrites the command and script in place.
# Windows (native PowerShell) users: use install.ps1 instead.
#
# Remote one-liner (no clone needed):
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/odysseyalive/claude-remote-watchdog/main/install.sh)"
#
# Or from a local clone:
#   ./install.sh
#
# Override the source with BRANCH=… or REPO_URL=… for testing.

set -euo pipefail

BRANCH="${BRANCH:-main}"
REPO_URL="${REPO_URL:-https://raw.githubusercontent.com/odysseyalive/claude-remote-watchdog/$BRANCH}"
INSTALL_ROOT="$HOME/.claude"

if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required but not found on PATH." >&2
    exit 1
fi

echo "claude-remote-watchdog installer"
echo "================================"
echo "Source: $REPO_URL"
echo

# Download the manifest, then every file it lists.
MANIFEST_TMP="$(mktemp)"
trap 'rm -f "$MANIFEST_TMP"' EXIT
curl -fsSL "$REPO_URL/manifest.txt" -o "$MANIFEST_TMP"

while IFS= read -r line || [ -n "$line" ]; do
    # Skip blank lines and comments.
    case "$line" in
        ''|\#*) continue ;;
    esac

    # Split the line into fields; an optional leading flag is shifted off.
    # shellcheck disable=SC2086  # intentional word splitting of the manifest line
    set -- $line
    flag=""
    case "${1:-}" in
        exec|keep) flag="$1"; shift ;;
    esac
    src="${1:-}"
    rel="${2:-}"
    if [ -z "$src" ] || [ -z "$rel" ]; then
        echo "Skipping malformed manifest line: $line" >&2
        continue
    fi

    dest="$INSTALL_ROOT/$rel"

    if [ "$flag" = "keep" ] && [ -f "$dest" ]; then
        echo "Keeping existing $rel (preserving your edits)..."
        continue
    fi

    # Earlier versions symlinked these into ~/.claude/. Drop a stale symlink
    # first so curl writes a real file here instead of following the link and
    # overwriting the source in the repo clone.
    if [ -L "$dest" ]; then
        echo "Removing old symlink at ~/.claude/$rel..."
        rm -f "$dest"
    fi

    mkdir -p "$(dirname "$dest")"
    curl -fsSL "$REPO_URL/$src" -o "$dest"
    echo "Installed: ~/.claude/$rel"

    if [ "$flag" = "exec" ]; then
        chmod +x "$dest"
    fi
done < "$MANIFEST_TMP"

cat <<'EOF'

✓ Installed! Usage:

  One-time check:     /remote-watchdog
  Auto-monitor:       /loop 5m /remote-watchdog
  Standalone cron:    */5 * * * * ~/.claude/scripts/remote-watchdog.sh >> /tmp/remote-watchdog.log 2>&1
  Dry run:            ~/.claude/scripts/remote-watchdog.sh --dry-run

  Update later:       re-run this installer (overwrites in place)

EOF
