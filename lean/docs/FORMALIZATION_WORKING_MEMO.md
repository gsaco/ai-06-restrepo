> **Current development:** this file retains the earlier scaffold/workflow history. The expanded partial formalization is described in [the current guide](LEAN_VERIFICATION.md), with its [scope and cost assessment](SCOPE_AND_COST.md). Earlier two-proof counts and pending-work checklists below are historical, not the current compiler status. The formal source-semantic closeout remains unfinished.

# Formalization Working Memo: The Race Between Machine and Man: Implications of Technology for Growth, Factor Shares and Employment

This is a working lead log, not audit evidence and not a final validation
report. Record possible issues while reading and proving; independently verify
each retained item against the pinned source and final Lean surface during
closeout.

For every item, record the exact source location, current mathematical reading,
Lean treatment, and review state. Prefer “clarification” unless the printed
formula or statement is actually false.

## Possible Source Clarifications

- None recorded.

## Possible Printed Typos Or Errors

- None recorded.

## Possible Proof-Strategy Deviations

- None recorded.

## Possible Model Conventions Or Extra Assumptions

- None recorded.

## Deferred Formalization Or Library Work

- None recorded.

## Run-specific source and proof boundary (24 September 2026)

- Pinned local source: NBER Working Paper 22252, revised June 2017, SHA-256 `441d01202afd56ef8002fc24ffc2beb51191741c0b5accb11d2534620dd616b7`. The PDF and extracted text remain outside public Git.
- Named main-text results inventoried: Propositions 1--9; Corollaries 1--2. Named appendix results include Lemmas A1--A3 and Propositions B1--B4. The complete named-theory source map has **not** been frozen or independently reviewed.
- Equations (5)--(6): `thresholdCostRankingSpec` assumes a positive, strictly increasing productivity schedule, positive factor prices, and an equal-cost threshold. Lean proves the cost ordering on either side of `min I costThreshold`. The Lean premise requires positivity and strict monotonicity on all real indices, a stronger domain than the source's active task interval. It does not establish the existence of the threshold, the equilibrium factor prices, or Proposition 1.
- Proposition 3: `automationWageSignSpec` proves that an algebraically defined wage response is positive exactly when the productivity term exceeds the displacement term. Its response formula is imported as a definition from the source equation. Lean does not derive that equation from (8)--(11), and the full multi-clause Proposition 3 remains open.
- Proposition 6 and the balanced-growth path classifications are not formalized.
- No additional non-source assumptions are hidden inside a theorem proof. The explicit assumptions in `thresholdCostRankingSpec` are conditional source-model inputs; their sufficiency for a full equilibrium is not claimed.
- Focused Lean build: `lake build +AR18RaceManMachine.ProofInterface` succeeded. `#print axioms` for both endpoints listed only `propext`, `Classical.choice`, and `Quot.sound`.
- Contributor fast check: `python3 scripts/paper_contribution.py check AR18RaceManMachine --fast` succeeded. This is not a source-to-Lean semantic closeout. The closeout planner next requests an engine-registration commit before further audit work.
