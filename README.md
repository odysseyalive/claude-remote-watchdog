# claude-remote-watchdog

Auto-detect and fix dead [Claude Code](https://docs.anthropic.com/en/docs/claude-code) Remote Control (`/remote-control`) sessions in tmux.

> **Token-cost disclaimer.** When run inside Claude Code on a loop (e.g.
> `/loop 2m /remote-watchdog`), each healthy tick generates only ~50–150 output
> tokens (one tool call + a one-line reply). The real per-tick cost is the
> session context re-read on each model call — mostly billed as cheap **cached
> input** as long as ticks stay inside the ~5-minute cache TTL (2-minute spacing
> keeps it warm). These are rough estimates, not metered figures, and scale with
> your session's system prompt and loaded MCP tools. For an exact number, run
> `/cost` after a known number of ticks and divide.

## The Problem

Claude Code's `/remote-control` silently drops connections after 15-60 minutes. The built-in reconnection never recovers — the status bar shows "Remote Control reconnecting" indefinitely. The only fix is to manually cycle `/remote-control` at the terminal, which defeats the purpose of remote control.

See: [anthropics/claude-code#34255](https://github.com/anthropics/claude-code/issues/34255)

## How It Works

1. Scans all tmux panes for Claude Code's status bar (the bottom of each pane)
2. Detects `Remote Control reconnecting`/`connecting` (stuck/dead states)
3. Uses a 2-check grace period to avoid false positives on transient drops
4. Sends tmux keystrokes to automatically cycle disconnect → reconnect:
   - `Ctrl+C` → clear prompt
   - `/remote-control` → navigate to "Disconnect this session" → Enter
   - `/remote-control` → auto-connects to fresh bridge session
5. **Self-verifies** the reconnect in the same run — re-reads the pane and
   confirms it left the stuck state. No manual re-run needed.

### Token-frugal by design

The watchdog is built to run on a tight loop without burning context tokens:

- **Silent on success.** A healthy run prints *nothing* and exits `0`. Only
  `WARN`/`DEAD`/`ACTION`/`OK`/`FAIL` events produce output. Use `--verbose` to
  see per-pane health.
- Because each healthy check is essentially free, you can loop *more often*
  (e.g. `/loop 2m`) for faster recovery at lower total token cost than the old
  verbose `/loop 5m`.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- tmux (sessions must run inside tmux panes)

## Install

One-liner — no clone needed (downloads the files listed in `manifest.txt`
straight into `~/.claude/`).

**Linux / macOS / WSL:**

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/odysseyalive/claude-remote-watchdog/main/install.sh)"
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/odysseyalive/claude-remote-watchdog/main/install.ps1 | iex
```

The installer downloads each file in `manifest.txt` into `~/.claude/`:
- `~/.claude/commands/remote-watchdog.md` — slash command
- `~/.claude/scripts/remote-watchdog.sh` — watchdog script

**Update** any time by re-running the same one-liner — it overwrites the
command and script in place.

> **Windows note:** the watchdog needs `tmux` + bash, which on Windows only
> exist under **WSL**. `install.ps1` lands the files in your Windows-side
> `~/.claude` for parity, but to actually run the watchdog use the bash
> one-liner *inside WSL*.

## Usage

### Inside Claude Code (recommended)

One-time health check:

```
/remote-watchdog
```

Auto-monitor every 2 minutes (cheap now that healthy runs are silent):

```
/loop 2m /remote-watchdog
```

### Standalone (no Claude session needed)

Manual run (silent unless something needs attention):

```bash
~/.claude/scripts/remote-watchdog.sh
```

Verbose — show every pane's health plus a summary line:

```bash
~/.claude/scripts/remote-watchdog.sh --verbose
```

Dry run (detect only, no reconnect):

```bash
~/.claude/scripts/remote-watchdog.sh --dry-run
```

Crontab — fully autonomous, every 2 min, log only real events:

```bash
*/2 * * * * ~/.claude/scripts/remote-watchdog.sh >> /tmp/remote-watchdog.log 2>&1
```

## Output

A healthy run is **silent** (exit `0`). Output appears only when something
happens:

```
[WARN] agent-universe (%5): 'reconnecting' — confirming next check
[DEAD] workspace-i (%6): stuck on 'reconnecting' — auto-reconnecting
[ACTION] Cycling /remote-control on pane %6 (workspace-i)...
[OK] workspace-i (%6): reconnect sent and verified
```

| Status | Meaning |
|--------|---------|
| `[HEALTHY]` | Remote Control active (only shown with `--verbose`) |
| `[WARN]` | First detection of reconnecting — grace period |
| `[DEAD]` | Confirmed dead — auto-reconnect triggered |
| `[ACTION]` | Cycling `/remote-control` keystrokes |
| `[OK]` | Reconnect sent **and self-verified** |
| `[FAIL]` | Still stuck after reconnect — will retry next check |
| `[SKIP]` | No Remote Control sessions found (only shown with `--verbose`) |

### Exit codes

| Code | Meaning |
|------|---------|
| `0` | Nothing wrong (or only a grace-period warning) |
| `1` | A reconnect was attempted and verified |
| `2` | A reconnect was attempted but verification failed |

### Tunables (environment variables)

| Var | Default | Purpose |
|-----|---------|---------|
| `STEP_WAIT` | `5` | Seconds between TUI keystrokes (raise on slow machines) |
| `CAPTURE_LINES` | `12` | Bottom lines of each pane to inspect for the status bar |
| `VERIFY_WAIT` | `6` | Seconds to wait before self-verifying a reconnect |

## How the Reconnect Works

The `/remote-control` TUI menu has three options:

```
  Disconnect this session
  Show QR code
❯ Continue                  ← cursor starts here
```

The script navigates `Up Up Enter` to select "Disconnect", then runs `/remote-control` again which auto-connects to a fresh bridge — no TUI interaction needed on the second call.

## Limitations

- **tmux required**: Detection relies on reading tmux pane content via `tmux capture-pane`
- **TUI timing**: The script uses 5-second waits between keystrokes; slow machines may need `STEP_WAIT` increased
- **Grace period**: Takes 2 consecutive checks before triggering reconnect to avoid false positives — ~4 min at `/loop 2m`, ~10 min at `/loop 5m`

## License

MIT
