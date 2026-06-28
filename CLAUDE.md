# claude-remote-watchdog

## Purpose

A watchdog that auto-detects and fixes dead **Claude Code Remote Control**
(`/remote-control`) sessions running inside **tmux**.

Claude Code's `/remote-control` silently drops connections after 15–60 minutes
and never recovers on its own — the status bar gets stuck on "Remote Control
reconnecting" indefinitely, and the only manual fix is to cycle
`/remote-control` at the terminal. This tool detects that stuck state and
performs the disconnect → reconnect cycle automatically.

See: https://github.com/anthropics/claude-code/issues/34255

## Stack

- **Language:** Bash (shell scripts only — no compiled code, no package manager).
- **Runtime deps:** `tmux` and the Claude Code CLI. Nothing else.
- **Targets:** Linux, macOS, and WSL. Keep scripts portable across GNU and BSD
  coreutils (mind `date`, `awk`, `grep`, `sed` differences between Linux and macOS).

## Layout

- `remote-watchdog.sh` — the watchdog. Scans tmux panes, detects stuck Remote
  Control sessions, and cycles `/remote-control` to reconnect. Supports `--dry-run`.
- `remote-watchdog.md` — the `/remote-watchdog` slash command that runs the script
  from within Claude Code.
- `install.sh` — symlinks the script and command into `~/.claude/scripts/` and
  `~/.claude/commands/`.
- `README.md` — user-facing docs.

## How it works

1. `tmux list-panes -a` enumerates panes; `tmux capture-pane` reads the last few
   lines (the status bar) of each.
2. Panes without "Remote Control" in the status bar are skipped.
3. On "Remote Control reconnecting"/"connecting", a **2-check grace period**
   applies: first detection writes a state file and warns; a second consecutive
   detection triggers reconnect. State files live at
   `/tmp/claude-remote-watchdog-*.fail`.
4. Reconnect sends tmux keystrokes: `Ctrl+C` → `/remote-control` → `Up Up Enter`
   (select "Disconnect this session") → `/remote-control` again (auto-connects to
   a fresh bridge).

## Build / run / test

There is no build step. To run and validate:

```bash
# Install (symlinks into ~/.claude/)
./install.sh

# Run directly
./remote-watchdog.sh

# Detect-only, no reconnect — safe way to test logic
./remote-watchdog.sh --dry-run

# From within Claude Code
/remote-watchdog
/loop 5m /remote-watchdog
```

**Before committing, validate changes with:**

- `shellcheck remote-watchdog.sh install.sh` — must pass clean (lint gate).
- A manual `./remote-watchdog.sh --dry-run` against a real tmux session to
  confirm detection still behaves.

## Conventions

- Keep scripts POSIX/portable enough to run on Linux, macOS, and WSL.
- `set -euo pipefail` at the top of scripts.
- Keep output concise and prefixed with bracketed status tags
  (`[HEALTHY]`, `[WARN]`, `[DEAD]`, `[ACTION]`, `[OK]`, `[SKIP]`) — this runs on a loop.

## Things to avoid / handle carefully

- **Keystroke timing & TUI navigation are fragile.** The `STEP_WAIT`/`sleep`
  values and the `Up Up Enter` sequence depend on how the `/remote-control` TUI
  renders. Don't change them casually; slow machines may need `STEP_WAIT` raised.
- **Don't weaken the grace-period logic.** The 2-check state-file mechanism exists
  specifically to avoid false reconnects on transient drops. Keep it intact.
- **Stay dependency-free.** No new runtime dependencies beyond `tmux` + Bash. It
  must remain a self-contained set of shell scripts.
