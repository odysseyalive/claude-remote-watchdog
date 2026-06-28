# Consultation Protocol

How agents query the ledger during `consult` and Auto-Consultation.

## Triage

1. Read `ledger/index.md`. Match tags against the files, directories, components,
   and risk language in the current topic.
2. If no records match → skip agents entirely. Report "No ledger records match the
   current context." Zero overhead until records exist.

## Proportional Agent Spawning

| Match Scope | Agents Spawned |
|-------------|----------------|
| No records match | None |
| Only incidents/flows match | Regression Hunter only |
| Only decisions/patterns match | Skeptic only |
| Risk/failure language detected | Premortem Analyst only |
| Multiple record types match | All three (full panel) |

Agents are defined in `../agents/` (`regression-hunter.md`, `skeptic.md`,
`premortem-analyst.md`), each `context: none`, read-only.

## Synthesis

- **Agents agree** → HIGH-confidence warning.
- **Agents disagree** → the disagreement IS the signal; surface all views.

## Consultation Briefing Format

```markdown
## Ledger Consultation

### Warnings (HIGH confidence — agents agree)
- **[Warning]** — [INC/DEC/PAT/FLW ref] — [one-line explanation]

### Considerations (agents disagree — investigate)
- **[Topic]**
  - Regression Hunter: [finding]
  - Skeptic: [finding]
  - Premortem Analyst: [finding]

### Context (relevant records, no warnings)
- [ID] — [why relevant]

### Capture Opportunity
- **Suggested type:** [INC/DEC/PAT/FLW]
- **Suggested ID:** [auto-generated]
- **Source material:** [quote]
Confirm to record, or skip.
```
