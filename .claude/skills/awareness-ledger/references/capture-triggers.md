# Capture Triggers

Conversation signals that suggest a record should be created. Capture is always
user-confirmed — agents suggest, the user decides.

## Incident Triggers (→ INC)
- Rollback/revert: "roll back", "revert", "undo", "broke", "regression"
- Error investigation: "root cause", "why did this", "what went wrong"
- Post-fix reflection: "that was caused by", "the fix was", "lesson learned"

## Decision Triggers (→ DEC)
- Choice justification: "I chose X because", "use X instead of Y"
- Trade-off discussion: "the trade-off is", "downside of this approach"
- Architecture language: "going forward", "from now on", "the pattern should be"

## Pattern Triggers (→ PAT)
- Repeated observation: "this keeps happening", "every time we", "I've noticed"
- Rule discovery: "turns out", "the trick is", "what works is"
- Exception identification: "except when", "doesn't apply to", "unless"

## Flow Triggers (→ FLW)
- Step-by-step debugging: "first it does X, then Y, then Z"
- User behavior: "when the user does X", "the flow is"
- Environment-specific: "only happens when", "requires X to be running"

## Memory Triggers — Route to Auto Memory, NOT the Ledger

Some capture-worthy-looking signals belong in Claude Code's per-user-per-machine
auto memory, not the project ledger:

- Writing tics/preferences, notation/formatting rules, humor calibration,
  tool aliases/invocation habits, transient session state.

**Bail-out rule:** if the fact would not survive a teammate opening the repo on a
fresh machine — and the project would not suffer from its absence — it belongs in
auto memory, not the ledger.
