#!/bin/bash
# Awareness Ledger: trigger-pattern capture reminder
# PreToolUse hook on Task and Bash. Exits 0 always (awareness, not blocking).
# Only outputs when a trigger pattern matches — eliminates reminder fatigue.

TOOL_NAME="$1"

if [[ "$TOOL_NAME" != "Task" && "$TOOL_NAME" != "Bash" ]]; then
    exit 0
fi

LEDGER_DIR=".claude/skills/awareness-ledger/ledger"
if [[ ! -d "$LEDGER_DIR" ]]; then
    exit 0
fi

INPUT=$(cat)

if echo "$INPUT" | grep -qiE '(roll\s*back|revert|undo|broke|regression|root\s*cause|what\s*went\s*wrong|caused\s*by|the\s*fix\s*was|lesson\s*learned)'; then
    echo "--- AWARENESS LEDGER ---" >&2
    echo "Capture trigger: incident-related language. Suggested record: INC." >&2
    echo "After resolving, consider /awareness-ledger record" >&2
    echo "--- END LEDGER ---" >&2
    exit 0
fi

if echo "$INPUT" | grep -qiE '(chose.*because|should\s*use.*instead|trade-?off|downside\s*of\s*this|going\s*forward|from\s*now\s*on|the\s*pattern\s*should)'; then
    echo "--- AWARENESS LEDGER ---" >&2
    echo "Capture trigger: decision/trade-off language. Suggested record: DEC." >&2
    echo "After completing, consider /awareness-ledger record" >&2
    echo "--- END LEDGER ---" >&2
    exit 0
fi

if echo "$INPUT" | grep -qiE '(keeps\s*happening|every\s*time\s*we|i.ve\s*noticed|turns\s*out|the\s*trick\s*is|what\s*works\s*is|except\s*when|doesn.t\s*apply)'; then
    echo "--- AWARENESS LEDGER ---" >&2
    echo "Capture trigger: recurring pattern language. Suggested record: PAT." >&2
    echo "After completing, consider /awareness-ledger record" >&2
    echo "--- END LEDGER ---" >&2
    exit 0
fi

if echo "$INPUT" | grep -qiE '(first\s*it\s*does.*then|when\s*the\s*user\s*does|the\s*flow\s*is|only\s*happens\s*when|requires.*to\s*be\s*running)'; then
    echo "--- AWARENESS LEDGER ---" >&2
    echo "Capture trigger: flow/process description. Suggested record: FLW." >&2
    echo "After completing, consider /awareness-ledger record" >&2
    echo "--- END LEDGER ---" >&2
    exit 0
fi

exit 0
