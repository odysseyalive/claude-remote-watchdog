#!/bin/bash
# Claude Code Remote Control Watchdog
# Detects dead /remote-control sessions in tmux and auto-reconnects them.
#
# Usage: remote-watchdog.sh [--dry-run] [--verbose]
#
# How it works:
#   1. Scans all tmux panes for Claude Code's status bar text
#   2. Skips panes without Remote Control enabled
#   3. If "Remote Control reconnecting/connecting" is detected:
#      - First detection: marks as warning (grace period)
#      - Second consecutive detection: triggers auto-reconnect
#   4. Auto-reconnect cycles /remote-control via tmux keystrokes, then
#      self-verifies the result in the same run (no manual re-run needed).
#
# Output strategy (token-frugal — designed to run on a tight loop):
#   - Silent on success. Healthy panes print nothing unless --verbose.
#   - Only WARN / DEAD / ACTION / errors produce output.
#   - Exit code: 0 = nothing wrong, 1 = a reconnect was attempted,
#                2 = a reconnect was attempted and verification failed.
#
# Tunables (env overrides):
#   STEP_WAIT       seconds between TUI keystrokes        (default 5)
#   CAPTURE_LINES   bottom lines of each pane to inspect  (default 12)
#   VERIFY_WAIT     seconds to wait before self-verify    (default 6)
#
# Requirements: tmux, Claude Code CLI with /remote-control
# State files: /tmp/claude-remote-watchdog-*.fail (2-check grace period)

set -euo pipefail

DRY_RUN=false
VERBOSE=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --verbose|-v) VERBOSE=true ;;
    *) echo "[ERR] unknown argument: $arg" >&2; exit 64 ;;
  esac
done

STEP_WAIT="${STEP_WAIT:-5}"        # TUI render delay between keystrokes (fragile — see CLAUDE.md)
CAPTURE_LINES="${CAPTURE_LINES:-12}"  # status bar lives at the bottom; 12 gives margin without matching conversation
VERIFY_WAIT="${VERIFY_WAIT:-6}"    # let the fresh bridge settle before re-checking

EXIT_CODE=0

# Read the bottom of a pane (status bar area). One capture per pane.
capture() {
  tmux capture-pane -t "$1" -p 2>/dev/null | tail -n "$CAPTURE_LINES" || true
}

# Return the trailing state word from a "Remote Control <word>" status line.
rc_state() {
  grep -o "Remote Control [a-z]*" <<<"$1" | tail -1 | awk '{print $3}'
}

cycle_remote_control() {
  local pane_id="$1" win_name="$2"

  if $DRY_RUN; then
    echo "[DRY-RUN] Would cycle /remote-control on pane $pane_id ($win_name)"
    return 0
  fi

  echo "[ACTION] Cycling /remote-control on pane $pane_id ($win_name)..."

  # Ctrl+C to interrupt anything in progress, then clear the input line.
  tmux send-keys -t "$pane_id" C-c
  sleep 2
  tmux send-keys -t "$pane_id" C-u
  sleep 1

  # Step 1: /remote-control → TUI appears with 3 options:
  #   Disconnect this session
  #   Show QR code
  # ❯ Continue                  ← cursor starts here
  tmux send-keys -t "$pane_id" "/remote-control" Enter
  sleep "$STEP_WAIT"

  # Step 2: Navigate Up×2 to "Disconnect this session", select it.
  tmux send-keys -t "$pane_id" Up Up
  sleep 1
  tmux send-keys -t "$pane_id" Enter
  sleep "$STEP_WAIT"

  # Step 3: /remote-control again → auto-connects to a fresh bridge session.
  tmux send-keys -t "$pane_id" "/remote-control" Enter

  # Self-verify: re-read the pane and confirm it left the stuck state.
  # This replaces the old "wait, then re-run the whole script" pattern.
  sleep "$VERIFY_WAIT"
  local after
  after=$(capture "$pane_id")
  if grep -q "Remote Control reconnecting" <<<"$after"; then
    echo "[FAIL] $win_name ($pane_id): still stuck after reconnect — will retry next check"
    return 1
  fi
  echo "[OK] $win_name ($pane_id): reconnect sent and verified"
  return 0
}

# --- main ---

FOUND_ANY=false
HEALTHY_COUNT=0

while IFS='|' read -r pane_id win_name; do
  [[ -n "$pane_id" ]] || continue

  pane_content=$(capture "$pane_id")

  # Skip panes without Remote Control in the status bar.
  grep -q "Remote Control" <<<"$pane_content" || continue

  FOUND_ANY=true
  state_file="/tmp/claude-remote-watchdog-${pane_id//[^a-zA-Z0-9]/_}.fail"

  if grep -q "Remote Control reconnecting\|Remote Control connecting" <<<"$pane_content"; then
    # Both "reconnecting" and "connecting" can be stuck states.
    # 2-check grace period: first hit = warn, second consecutive = auto-reconnect.
    if [[ -f "$state_file" ]]; then
      rm -f "$state_file"
      echo "[DEAD] $win_name ($pane_id): stuck on '$(rc_state "$pane_content")' — auto-reconnecting"
      if cycle_remote_control "$pane_id" "$win_name"; then
        [[ $EXIT_CODE -lt 1 ]] && EXIT_CODE=1
      else
        EXIT_CODE=2
      fi
    else
      touch "$state_file"
      echo "[WARN] $win_name ($pane_id): '$(rc_state "$pane_content")' — confirming next check"
    fi
  else
    # "Remote Control active", "Remote Control at ...", etc.
    rm -f "$state_file" 2>/dev/null || true
    HEALTHY_COUNT=$((HEALTHY_COUNT + 1))
    $VERBOSE && echo "[HEALTHY] $win_name ($pane_id)"
  fi

done < <(tmux list-panes -a -F '#{pane_id}|#{window_name}' 2>/dev/null)

# Silent on success: a clean run prints nothing (exit 0) so loop iterations
# cost ~zero tokens. Only surface a line when explicitly asked (--verbose).
if $VERBOSE; then
  if ! $FOUND_ANY; then
    echo "[SKIP] No Remote Control sessions found"
  elif [[ $EXIT_CODE -eq 0 ]]; then
    echo "[OK] All $HEALTHY_COUNT Remote Control session(s) healthy"
  fi
fi

exit "$EXIT_CODE"
