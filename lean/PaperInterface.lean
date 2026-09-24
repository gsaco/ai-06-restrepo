import AR18RaceManMachine.MainTheorems

/-!
# Source-facing interface: Acemoglu and Restrepo, NBER w22252 (June 2017)

This is a deliberately partial translation. `thresholdCostRankingSpec` covers the
cost ranking behind equations (5)--(6), conditional on the paper's increasing
productivity schedule and an interior equal-cost threshold. It does not prove
existence or uniqueness of a general equilibrium (Proposition 1).

`automationWageSignSpec` is the algebraic sign implication of Proposition 3's
wage decomposition in the technology-constrained case. The decomposition is
taken as input; its derivation from the equilibrium equations is not checked.
-/

namespace AR18RaceManMachine

/-- Equation (5): effective cost of labor in task `i`. -/
noncomputable def laborUnitCost (w : ℝ) (γ : ℝ → ℝ) (i : ℝ) : ℝ := w / γ i

/-- Equation (6), together with the paper's tie convention: the implemented
threshold is the smaller of the technology and cost thresholds. -/
def implementedThreshold (I costThreshold : ℝ) : ℝ := min I costThreshold

/-- The cost ranking stated immediately after equations (5)--(6). Task indices
are real numbers; positivity of `γ` makes the divisions meaningful. -/
def thresholdCostRankingSpec : Prop :=
  ∀ (γ : ℝ → ℝ) (w R I costThreshold : ℝ),
    StrictMono γ → (∀ i, 0 < γ i) → 0 < w → 0 < R →
    w / R = γ costThreshold →
      (∀ i, i < implementedThreshold I costThreshold →
        i ≤ I ∧ R < laborUnitCost w γ i) ∧
      (∀ i, implementedThreshold I costThreshold < i →
        I < i ∨ laborUnitCost w γ i < R)

/-- Proposition 3, constrained case: for an automation change with `dN = 0`,
the paper's wage decomposition has a productivity component and a displacement
component. This definition is a local response coefficient, not a derivation of
the equilibrium comparative static. -/
noncomputable def automationWageResponse (productivityGain laborShare ΛI σhat εL : ℝ) : ℝ :=
  productivityGain - (1 - laborShare) * (ΛI / (σhat + εL))

/-- A positive wage response requires the productivity gain to exceed the
displacement term. The antecedent takes Proposition 3's decomposition as given;
this statement does not prove that the model generates that decomposition. -/
def automationWageSignSpec : Prop :=
  ∀ (productivityGain laborShare ΛI σhat εL : ℝ),
    0 ≤ laborShare → laborShare ≤ 1 → 0 < ΛI →
    0 < σhat → 0 < εL →
    (0 < automationWageResponse productivityGain laborShare ΛI σhat εL ↔
      (1 - laborShare) * (ΛI / (σhat + εL)) < productivityGain)

end AR18RaceManMachine
