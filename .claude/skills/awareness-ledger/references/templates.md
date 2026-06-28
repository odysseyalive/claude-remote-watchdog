# Record Type Templates

Modeled on Google SRE blameless postmortems, MADR/ADR, NASA LLIS, and Klein's premortem.

## Incident Record (INC) — `INC-YYYY-MM-DD-slug`

```markdown
# INC-YYYY-MM-DD-slug

**Status:** active | resolved | superseded
**Tags:** [domain tags, file paths, function names]
**Related:** [DEC-xxx, PAT-xxx, FLW-xxx, INC-xxx]

## What Happened
[Factual description. No blame. What was observed?]

## Timeline
| Time/Commit | Event |
|-------------|-------|
| [ref] | [what happened] |

## Root Cause
[Direct technical cause]

## Contributing Factors (Swiss Cheese Layers)
1. **[Layer]** — [how it contributed]

## Resolution
[What was done to fix it]

## Lessons Learned
> **"[Verbatim lesson]"**
*— Captured YYYY-MM-DD, source: [conversation / commit / user]*

## Prevention
[What would prevent recurrence — link DEC/PAT records]
```

## Decision Record (DEC) — `DEC-YYYY-MM-DD-slug`

```markdown
# DEC-YYYY-MM-DD-slug

**Status:** proposed | accepted | deprecated | superseded-by [DEC-xxx]
**Tags:** [domain tags, file paths, architectural area]
**Related:** [INC-xxx, PAT-xxx, FLW-xxx, DEC-xxx]

## Context
[What issue motivates this decision?]

## Decision Drivers
- [Driver]

## Options Considered
### Option A: [Name]
- Good, because [argument]
- Bad, because [argument]

## Decision
Chosen option: **[Option X]**, because [justification].
> **"[Verbatim rationale]"**
*— Captured YYYY-MM-DD, source: [...]*

## Consequences
- [Consequence]

## Confirmation Criteria
[How will we know this was right? What triggers reconsideration?]
```

## Pattern Record (PAT) — `PAT-YYYY-MM-DD-slug`

```markdown
# PAT-YYYY-MM-DD-slug

**Status:** active | deprecated | under-review
**Tags:** [domain tags, file paths, language/framework]
**Related:** [INC-xxx, DEC-xxx, FLW-xxx, PAT-xxx]

## Pattern
[Reusable knowledge]

## Evidence
1. **[Evidence]** — [source/date]

## Counter-Evidence
1. **[Counter-evidence]** — [source/date]
> **"[Verbatim observation, especially if it contradicts the pattern]"**
*— Captured YYYY-MM-DD, source: [...]*

## Applicability
- **When to use:** [...]
- **When NOT to use:** [...]

## Confidence
[HIGH / MEDIUM / LOW] — based on evidence-to-counter-evidence ratio and recency.
```

## Flow Record (FLW) — `FLW-YYYY-MM-DD-slug`

```markdown
# FLW-YYYY-MM-DD-slug

**Status:** active | outdated | superseded-by [FLW-xxx]
**Tags:** [domain tags, user action, system component]
**Related:** [INC-xxx, DEC-xxx, PAT-xxx, FLW-xxx]

## Flow Description
[What user action or system process does this capture?]

## Steps
| Step | Action | Code Path | Notes |
|------|--------|-----------|-------|
| 1 | [what happens] | `file:line` | |

## Environmental Conditions
- [Condition / dependency / version / config]

## Edge Cases
- [Edge case]
> **"[Verbatim observation]"**
*— Captured YYYY-MM-DD, source: [...]*
```

## Status Lifecycle

```
proposed → active → [resolved | deprecated | superseded-by REF]
                  → under-review → active (re-confirmed)
```

## Index Generation Rules

`ledger/index.md` is regenerated when records change. Sections: **By Tag**,
**By Status** (Active / Resolved / Under Review), **Relationship Map**, and a
**Statistics** table (Type | Total | Active | Resolved | Deprecated). Group by the
most common tags — file paths, function names, domain/component names — so agents
can match records to the current work context.
