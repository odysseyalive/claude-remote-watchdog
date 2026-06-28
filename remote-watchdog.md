Run the remote control watchdog and report only if something needed attention.

Execute the `remote-watchdog.sh` script located in the same directory as this command file (resolve via symlink if needed):

```bash
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]:-$0}" 2>/dev/null || echo "$0")")" && pwd)"
# Fallback: check common locations
for dir in "$SCRIPT_DIR" ~/.claude/scripts "$(dirname "$(readlink ~/.claude/commands/remote-watchdog.md 2>/dev/null)")" ; do
  [[ -x "$dir/remote-watchdog.sh" ]] && WATCHDOG="$dir/remote-watchdog.sh" && break
done
```

Run: `${WATCHDOG:-~/.claude/scripts/remote-watchdog.sh}`

The script is silent when everything is healthy and self-verifies its own
reconnects, so:

- **No output** → reply with a single line: `✓ remote-control healthy` and stop. Do not elaborate, do not re-run.
- **Output present** (`[WARN]`/`[DEAD]`/`[ACTION]`/`[OK]`/`[FAIL]`) → relay those lines verbatim. The script already verified any reconnect in the same run — do NOT re-run to confirm.

This command runs on a loop; keep your reply to the minimum shown above.

If the script is not executable or missing, run `chmod +x` on it first.
