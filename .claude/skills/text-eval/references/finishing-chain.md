# Finishing Chain — bounded AI-tell scrub loop

Adapted from skill-builder's `references/creative-integrity.md` § Canonical Scrub-Loop
Spec (text). Carries every ◆ non-negotiable. Scrubbing is invoked, never automatic.

## Loop (text)

1. ◆ **Entry provenance guard.** Only scrub text this project produced/owns. Never
   scrub quoted source material, user-authored immutable directives, or third-party text.
2. ◆ **Evaluate via context-isolated evaluators.** Run `character-scanner` (mechanical,
   first) then `tell-evaluator` (judgment-class). The evaluator NEVER triggers
   regeneration on its own — it reports; the caller decides.
3. ◆ **Triage.** Auto-fix ONLY MUST FIX findings and hard-directive `[hard]` flags
   (em-dash overuse, rhetorical colons, pipeline artifacts, invisible Unicode).
   Advisories are human-decided, never auto-applied.
4. ◆ **Snapshot** the current text as best-so-far before any edit.
5. ◆ **ONE atomic fix pass.** Apply the batched fixes once — not iterative nibbling.
6. ◆ **Whole-document echo re-scan.** Re-run the full evaluation on the entire document
   (fixes introduce new tells — principle 4); never re-scan only the changed spans.
7. ◆ **Re-validate + divergence abort.** If the new pass scores worse than best-so-far,
   ABORT and keep best-so-far. Never optimize toward a detector score.
8. ◆ **Humanity floor.** Advisory-only absent a documented voice profile; never block on
   non-English or technical content. Protect the voice — do not flatten it into
   detector-pleasing mush.
9. ◆ **Cycle cap 2.** At most two fix→re-scan cycles. Then present with cycle history.

## Output

Present: the Verification Preamble (mechanical counts), the tiered judgment findings,
what was auto-fixed, what is left for the human, and the cycle history. Never silently
rewrite the user's text.
