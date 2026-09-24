# Scope and cost assessment

The practical choice is an expanded partial formalization of the task framework and local comparative statics. A nearly complete formalization of this paper is not a low-cost extension of the original two proofs.

The author requested nearly complete coverage if feasible at reasonable cost, and explicitly allowed a smaller formalization when that is the better choice. We retain the paper-wide gaps rather than relabeling selected supporting results as complete propositions.

## What was worth implementing now

| Work | Reason for prioritizing it | Cost assessment |
| --- | --- | --- |
| Real task intervals and their Lebesgue measures | Represents the actual continuum and the geometry of displacement/reinstatement | Low; existing Mathlib measure lemmas |
| Cost minimization and cutoff existence | Connects firms' feasible decisions to the task boundary | Low to moderate; reuses AppliedModelingLib's continuous-threshold theorem |
| Wage/rental response system | Checks the complete elimination performed in the handwritten derivation | Low; real algebra and explicit inequalities |
| Moving-boundary task integral | Removes an assumed derivative formula from the response calculation | Moderate; fundamental theorem of calculus and chain rule |
| Relative-demand and price-index differentiation | Derives local response relations from equations holding near the comparison point | Moderate; logarithms, real powers, and derivative uniqueness |
| Linking the local formulas, factor-income shares, and employment/share responses | Distinguishes economic conclusions from isolated identities | Moderate; explicit normalization, market clearing, and chain rule |
| Full equilibrium and dynamics | Requires existence, uniqueness, optimization, stability, and further source review | High; a separate research formalization campaign |

These are engineering judgments, not a dollar quote or a guarantee of elapsed time. Exact local build duration and dependencies are recorded in [the compiler report](../verification/build.json). Proof development and source review take additional time. Narrow imports reduced repeated proof checks substantially; the project does not rebuild the entire library for each local edit.

## Source inventory and remaining work

Source: NBER Working Paper 22252, revised June 2017. Printed page numbers differ from PDF viewer page numbers. The table records named results, not a percentage-complete metric. **No complete named result below is claimed as fully formalized.** Supporting facts for a proposition do not close all its clauses.

| Named source result | Printed page | PDF page | Remaining mathematical work |
| --- | --- | --- | --- |
| Proposition 1 | 10 | 12 | Static equilibrium existence/uniqueness; continuum CES aggregation |
| Corollary 1 | 11 | 13 | Derive the Cobb–Douglas special case from production |
| Proposition 2 | 11–12 | 13–14 | Establish equilibrium paths and the full constrained/unconstrained comparative statics; current proofs cover local analytical support |
| Proposition 3 | 12–13 | 14–15 | Identify dual productivity with fixed-factor primal productivity; prove all productivity signs and the capital-stock threshold; cover unit effective elasticity |
| Proposition 4 | 17–18 | 19–20 | All balanced-growth regimes, existence/uniqueness and global stability |
| Proposition 5 | 19 | 21 | Long-run comparisons and transition/accumulation claims |
| Proposition 6 | 25–26 | 27–28 | Endogenous research values, equilibrium multiplicity and saddle-path stability |
| Corollary 2 | 28 | 30 | Permanent innovation shifts along the endogenous growth equilibrium |
| Proposition 7 | 31 | 33 | Heterogeneous skills, standardization and inequality |
| Proposition 8 | 33 | 35 | Creative destruction and stability restrictions |
| Proposition 9 | 34–35 | 36–37 | Welfare, labor-market frictions and planner envelopes |
| Lemma A1 | 40 | 42 | Complete general-model monotonicity of relative demand |
| Lemma A2 | 40–41 | 42–43 | Discount-rate regions and effective-wage threshold functions |
| Lemma A3 | 46 | 48 | Innovation-value asymptotics and controlled small-growth arguments |
| Proposition B1 | B-10 | 62 | General nonhomothetic comparative statics |
| Lemma B1 | B-14 | 66 | Marginal-product bounds for the dynamic equilibrium |
| Proposition B2 | B-28 | 80 | General-model welfare analysis |
| Proposition B3 | B-32 | 84 | Static equilibrium when new tasks also require capital |
| Proposition B4 | B-33 | 85 | Endogenous innovation with capital-requiring new tasks |

A source-only review found these 19 named results. This is a planning inventory, not an authenticated completeness receipt for every definition, assumption, or prose presentation. In particular, source extraction around page breaks can miss headings; the inventory includes Lemma B1 as well as Proposition B1.

## Why full coverage is expensive

Full coverage requires several different mathematical developments: continuum production and optimization; market clearing and a differentiable equilibrium selection; infinite-horizon household behavior and transversality; ordinary differential equations and saddle manifolds; discounted innovation-value integrals and asymptotic approximations; heterogeneous-skill equilibria; and planner/welfare arguments. The current library supplies useful mathematical foundations, but does not supply this paper's entire model as a ready-made theorem.

It would be misleading to reduce that cost by assuming the economic conclusions inside an equilibrium record, assigning plausible names to algebraic identities, or counting helper lemmas as whole paper results. The current implementation instead proves specific links in a visible chain and lists what is still missing.

## Next mathematical priorities

1. Prove the primal CES production and dual-price relationship, including the unit-elasticity case.
2. Establish existence, uniqueness, and local differentiability of the static equilibrium rather than assuming an equilibrium path.
3. Connect the endogenous cost cutoff to both technological regimes throughout the response path, including feedback in the unconstrained case.
4. Complete the sign and capital-threshold clauses of Proposition 3.
5. Only then begin the dynamic and endogenous-innovation proofs.

The library's full source-semantic closeout remains open. Compiler acceptance and an independent diagnostic review are useful evidence, but neither is that closeout.
