# Reading and reproducing the Lean formalization

This is an expanded **partial formalization**, checked using the homework's AppliedModelingLib package. The local proofs include genuine continuous-task and derivative arguments. They do not establish the complete economic equilibrium or the entire paper.

## Read the argument in this order

| Module | Checked content | Exact boundary |
| --- | --- | --- |
| [TaskFramework](../TaskFramework.lean) | Real-interval partition, Lebesgue task measures, threshold existence/uniqueness, cost minimization, finite task reallocation, automation saturation, explicit exponential-productivity cutoff | Primary-factor input cost, not full intermediate-input/task-output optimization; prices are given; threshold existence uses explicit continuity/crossing restrictions |
| [RelativeDemand](../RelativeDemand.lean) | Log-equilibrium differentiation, moving-boundary integral, relative factor-price response, positive task coefficients, normalized wage, employment and income-share responses | Requires a locally valid differentiable equilibrium path; does not prove that path exists |
| [PriceIndex](../PriceIndex.lean) | Real-power differentiation of a locally constant CES price index and its weighted price response | Effective elasticity differs from one; the dual coefficient is not yet identified with primal fixed-factor productivity |
| [WageDecomposition](../WageDecomposition.lean) | Unique solution of the two response equations, both technology directions, wage sign trichotomy | Algebraic support; positivity of productivity and relevant coefficients is explicit where required |
| [LocalResponses](../LocalResponses.lean) | Combines actual task integrals and local equilibrium identities into wage/rental formulas; establishes the interval partition and interior price weight; separately connects price weights to factor-income shares | Implemented cutoff changes, not automatically technological-frontier changes; reduced equilibrium equations and differentiable paths are inputs |
| [PaperInterface](../PaperInterface.lean) / [ProofInterface](../ProofInterface.lean) | The original cost-ranking and wage-sign examples | Retained as the original presentation examples; not the complete current proof package |
| [Verification](../Verification.lean) | Lean-native enumeration and recursive axiom checking of all paper-namespace theorem declarations | Compiler/axiom evidence, not a source-to-Lean equivalence certificate |

## The most useful new proof

`localFactorResponses` is the integration endpoint. It takes a locally valid relative-demand equation and price-index equation, uses a real task-productivity integral with moving endpoints, differentiates them, and solves the resulting system for wage and rental-rate responses. It does not assume those two differential response equations as conclusions to be proved.

The task integrand in its specification is the paper's productivity raised to effective elasticity minus one. The normalized wage divides the wage by capital income; capital is held fixed. The implementation also checks that the task partition is admissible at the comparison point and that the price-index labor weight lies strictly between zero and one.

`priceWeight_eq_incomeShare` separately connects that weight to labor income using the capital and labor market-clearing quantities. The top-level response theorem itself concludes a formula using the price weight. The remaining production-duality bridge is needed before interpreting its productivity coefficient as the full primal productivity effect in Proposition 3.

The supporting income-share derivative uses endogenous labor supply. The older `share_growth_sign` helper in `WageDecomposition` is explicitly a fixed-supply algebraic conditional and should not substitute for that endogenous-supply result.

## Important modeling restrictions

- Tasks are real intervals with actual Lebesgue measure. No finite discretization is used.
- The cutoff point is assigned to capital. The corresponding singleton has zero measure; ties are cost-minimizing under either assignment.
- New cost-ranking results need productivity monotonicity only on the active interval. The legacy cost-ranking example still has global assumptions.
- General threshold existence additionally requires continuous productivity and a strict crossing of the relative price inside the active interval. Strict monotonicity alone gives uniqueness, not existence. The exponential case also has a directly checked closed-form threshold.
- The moving-integral support uses a globally continuous integrand, an explicit sufficient regularity restriction. Equilibrium selection differentiability is assumed, not established.
- `sigma` in the analytical modules is the source's **effective** substitution elasticity. The price-index argument excludes effective elasticity one. The algebraic system itself has no such exclusion.
- The response formula's denominator must be nonzero. Strict economic sign conclusions need positive coefficients and a positive denominator; the identities alone do not prove these signs for arbitrary parameters.
- The derivative of the implemented cutoff represents technological automation only in the binding regime. The full unconstrained-regime feedback calculation is outstanding.

## AppliedModelingLib reuse

The development uses the library's formalizer/prover workflow and directly imports its threshold module:

- Repository: [AppliedModelingLib](https://github.com/nikhgarg/AppliedModelingLib).
- Inspected revision: `2db7d108` (the compiler report contains the full revision).
- Module: `AppliedModelingLib/Foundations/Math/ThresholdCharacterization.lean`.
- Imported result: `exists_threshold_of_continuous_strictMonoOn_Icc_crossing_interval`.
- This is a direct import, not copied or ported code. The upstream project uses the Apache 2.0 license. Mathlib supplies the standard real analysis, measure, and derivative foundations.

The [compiler report](../verification/build.json) pins the exact library revision, threshold-module bytes, Mathlib revision, toolchain, and every checked homework source file. The threshold module is rebuilt and its transitive axioms are included in the Lean-native check.

## Reproduce the check

Use an installed AppliedModelingLib clone with the report's Lean toolchain and Mathlib dependencies available. From the homework repository:

```bash
python3 lean/check.py --library /path/to/AppliedModelingLib
```

To save a fresh compiler report:

```bash
python3 lean/check.py --library /path/to/AppliedModelingLib --report lean/verification/build.json
```

The runner rebuilds the imported threshold module, copies this homework's Lean sources into a temporary package directory, compiles every module in dependency order, and checks all discovered paper theorems for unexpected axioms. It does not overwrite the library clone's paper files or silently check its possibly different Restrepo snapshot. It refuses to record success if the homework sources change during the run.

Accepted foundational axioms are `propext`, `Classical.choice`, and `Quot.sound`. Any `sorryAx` or other axiom causes failure. Source hashes bind the saved report to the files actually checked. The script is a reproducible compiler check, not a replacement for the library's formal source review.

## Source provenance and review status

- Version: NBER Working Paper 22252, revised June 2017.
- PDF SHA-256: `441d01202afd56ef8002fc24ffc2beb51191741c0b5accb11d2534620dd616b7`.
- Extracted-text SHA-256: `54b4062af900f44f7a9bb08470ced8dd3029ec8a3ffe25a75cb2b81c20261a30`.
- Source locations: task framework and cost allocation in Section 2; relative demand in equation (13); price index in equation (10); wage-system elimination on printed page B-13, equations B9–B10; labor-share normalization in footnote 14.

The source PDF/text remain in the ignored private cache. Independent diagnostic reviews checked the mathematical scope and identified the distinctions documented above. They are **not** authenticated source-semantic receipts. Existing `audit/` files remain unfinished workflow inputs; they do not certify the expanded modules. No final library closeout, full-paper coverage claim, or human approval is asserted.

See [scope and cost](SCOPE_AND_COST.md) for the 19 named source results and the next proof priorities.
