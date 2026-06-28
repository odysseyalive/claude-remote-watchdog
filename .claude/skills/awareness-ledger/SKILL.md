---
name: awareness-ledger
description: "Institutional memory for your project. Commands: record, consult, review. Usage: /awareness-ledger [command] [args]"
allowed-tools: Read, Glob, Grep, Write, Edit, Task, TaskCreate, TaskUpdate, TaskList, TaskGet
---

# Awareness Ledger

Institutional memory for this project — captures incidents (INC), decisions (DEC),
patterns (PAT), and flows (FLW) so diagnostic findings and architectural decisions
survive across sessions and teammates.

## Quick Commands

| Command | Action |
|---------|--------|
| `/awareness-ledger record [type]` | Record a new INC / DEC / PAT / FLW entry |
| `/awareness-ledger consult [topic]` | Consult the ledger before a plan/change (agent-assisted) |
| `/awareness-ledger review` | Health check: stale entries, missing links, statistics |

## Directives

<!-- origin: user | immutable: true -->
<!-- (empty — add project-specific ledger directives here; they are preserved verbatim) -->
<!-- /origin -->

### Auto-Consultation (READ)

During research and planning — before formulating any plan, recommendation, or
code change proposal — automatically consult the ledger:

1. **Index scan** — Read `ledger/index.md` and match tags against the files,
   directories, and components under discussion. This is free — the index is small.
2. **Record review** — If matching records exist, read the full record files.
   Incorporate warnings, known failure modes, and relevant decisions into your
   thinking before presenting any plan.
3. **Agent escalation** — If high-risk overlap is detected (matching INC records
   with active status, or multiple record types matching the same change area),
   spawn consultation agents proportionally per `references/consultation-protocol.md`.

Skip auto-consultation for: changes to `.claude/` infrastructure files; trivial
edits (typos, formatting, comments); areas with no tag overlap in the index.

### Auto-Capture Suggestion (WRITE)

When the current conversation produces institutional knowledge, suggest recording
it **after** resolving the immediate issue — never interrupt active problem-solving.

Suggest capture when you encounter:
- **Bug investigation** with timeline/root cause/contributing factors → INC
- **Architectural decisions** with trade-offs discussed and option chosen → DEC
- **Recurring patterns** confirmed by evidence → PAT
- **User/system flows** traced step-by-step with code paths → FLW

Capture is always user-confirmed. Agents suggest, the user decides. Directives are
sacred — never auto-record.

## record Command

1. Determine record type (INC/DEC/PAT/FLW) from the argument or the conversation.
2. Read the matching template in `references/templates.md`.
3. Generate an ID `TYPE-YYYY-MM-DD-slug` and write the filled record to the matching
   `ledger/<incidents|decisions|patterns|flows>/` subdirectory.
4. Update `ledger/index.md` (By Tag, By Status, Relationship Map, Statistics).

## consult Command

Follow `references/consultation-protocol.md`: triage the topic → spawn agents
proportionally (one match → one agent, multiple → full panel, empty ledger → skip)
→ synthesize into the Consultation Briefing → suggest capture if warranted.

## review Command

Scan all records for: stale `active` entries, broken `Related:` links, tag drift,
and `proposed` records never confirmed. Report statistics and recommended cleanups.

## Grounding

- `references/templates.md` — record formats (INC/DEC/PAT/FLW), status lifecycle, index rules
- `references/consultation-protocol.md` — triage, proportional agent spawning, synthesis
- `references/capture-triggers.md` — conversation signals that warrant a record vs. auto memory
