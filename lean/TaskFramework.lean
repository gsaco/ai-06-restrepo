import Mathlib.MeasureTheory.Measure.Lebesgue.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Ring
import AppliedModelingLib.Foundations.Math.ThresholdCharacterization

/-!
# Continuous tasks and firms' choices

Source: Acemoglu–Restrepo, NBER w22252, June 2017, Section 2, equations
(1), (5)–(6) and Figure 2. These are supporting results, not Proposition 1.
We use actual real intervals and Lebesgue measure, not a finite task grid.
Capital is assigned the cutoff point; labor is assigned the open lower end.
The cutoff singleton has zero measure, and at equal cost either factor is optimal.
Threshold existence below makes continuity and strict endpoint crossing explicit.
Prices are given; market clearing and equilibrium price existence are not assumed proved.

Reuse: AppliedModelingLib.Foundations.Math.ThresholdCharacterization,
exists_threshold_of_continuous_strictMonoOn_Icc_crossing_interval,
from the homework library checkout. See docs/LEAN_VERIFICATION.md for pins.
-/

namespace AR18RaceManMachine

open Set MeasureTheory

/-- The unit continuum of active tasks. -/
def activeTasks (N : ℝ) : Set ℝ := Icc (N - 1) N

/-- A cutoff partition with the boundary assigned to capital. -/
def capitalTasks (N J : ℝ) : Set ℝ := Icc (N - 1) J

def laborTasks (N J : ℝ) : Set ℝ := Ioc J N

/-- Continuum partition and actual measures, for an admissible implemented cutoff. -/
def taskPartitionSpec : Prop :=
  ∀ N J : ℝ, J ∈ activeTasks N →
    capitalTasks N J ∪ laborTasks N J = activeTasks N ∧
    Disjoint (capitalTasks N J) (laborTasks N J) ∧
    volume.real (activeTasks N) = 1 ∧
    volume.real (capitalTasks N J) = J - (N - 1) ∧
    volume.real (laborTasks N J) = N - J ∧
    volume.real (capitalTasks N J) + volume.real (laborTasks N J) = 1

theorem taskPartition : taskPartitionSpec := by
  intro N J hJ
  obtain ⟨hlo, hhi⟩ := hJ
  have hcap : volume.real (capitalTasks N J) = J - (N - 1) :=
    Real.volume_real_Icc_of_le hlo
  have hlab : volume.real (laborTasks N J) = N - J :=
    Real.volume_real_Ioc_of_le hhi
  refine ⟨?_, ?_, ?_, hcap, hlab, ?_⟩
  · ext i
    simp only [capitalTasks, laborTasks, activeTasks, mem_union, mem_Icc, mem_Ioc]
    constructor
    · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩)
      · exact ⟨h1, h2.trans hhi⟩
      · exact ⟨hlo.trans h1.le, h2⟩
    · intro hi
      by_cases hij : i ≤ J
      · exact Or.inl ⟨hi.1, hij⟩
      · exact Or.inr ⟨lt_of_not_ge hij, hi.2⟩
  · apply Set.disjoint_left.mpr
    intro i hi hj
    exact (not_lt_of_ge hi.2) hj.1
  · change volume.real (Icc (N - 1) N) = 1
    rw [Real.volume_real_Icc_of_le (by linarith)]
    ring
  · rw [hcap, hlab]
    ring

/-- Existence is derived from continuity/crossing; uniqueness from strict increase.
This proves a cost threshold at given positive prices, not an equilibrium. -/
def costThresholdExistenceSpec : Prop :=
  ∀ (γ : ℝ → ℝ) (N W R : ℝ),
    0 < W → 0 < R → ContinuousOn γ (activeTasks N) →
    StrictMonoOn γ (activeTasks N) →
    γ (N - 1) < W / R → W / R < γ N →
    ∃! c : ℝ, c ∈ Ioo (N - 1) N ∧ W / R = γ c

theorem costThresholdExistence : costThresholdExistenceSpec := by
  intro γ N W R _ _ hcont hmono hlo hhi
  obtain ⟨c, hc, heq, _⟩ :=
    AppliedModelingLib.exists_threshold_of_continuous_strictMonoOn_Icc_crossing_interval
      (by linarith : N - 1 < N) hcont hmono hlo hhi
  refine ⟨c, ⟨hc, heq.symm⟩, ?_⟩
  intro d hd
  exact hmono.injOn ⟨hd.1.1.le, hd.1.2.le⟩ ⟨hc.1.le, hc.2.le⟩
    (hd.2.symm.trans heq.symm)

/-- Cost of a feasible mixture: x is the fraction of one unit of effective
primary-factor input supplied by capital. Labor's effective unit cost is W / γ i. -/
noncomputable def mixedTaskCost (W R : ℝ) (γ : ℝ → ℝ) (i x : ℝ) : ℝ :=
  x * R + (1 - x) * (W / γ i)

/-- Minimum effective primary-factor cost. This is the factor-cost term in
Eq. (5); intermediate-input price terms are not modeled here. -/
noncomputable def minimumFactorCost (W R I : ℝ) (γ : ℝ → ℝ) (i : ℝ) : ℝ :=
  if i ≤ I then min R (W / γ i) else W / γ i

/-- Implements the capital-at-cutoff convention. -/
noncomputable def thresholdFactorCost (W R I c : ℝ) (γ : ℝ → ℝ) (i : ℝ) : ℝ :=
  if i ≤ min I c then R else W / γ i

/-- The exact minimum over all technologically feasible primary-factor mixtures. -/
def factorCostMinimizationSpec : Prop :=
  ∀ (W R I i : ℝ) (γ : ℝ → ℝ),
    (∀ x : ℝ, 0 ≤ x → x ≤ 1 → (I < i → x = 0) →
      minimumFactorCost W R I γ i ≤ mixedTaskCost W R γ i x) ∧
    ∃ x : ℝ, 0 ≤ x ∧ x ≤ 1 ∧ (I < i → x = 0) ∧
      mixedTaskCost W R γ i x = minimumFactorCost W R I γ i

theorem factorCostMinimization : factorCostMinimizationSpec := by
  intro W R I i γ
  by_cases htech : i ≤ I
  · simp only [minimumFactorCost, if_pos htech]
    constructor
    · intro x hx hx1 _
      dsimp [mixedTaskCost]
      have h1 := min_le_left R (W / γ i)
      have h2 := min_le_right R (W / γ i)
      nlinarith [mul_nonneg hx (sub_nonneg.mpr h1),
        mul_nonneg (sub_nonneg.mpr hx1) (sub_nonneg.mpr h2)]
    · by_cases hcost : R ≤ W / γ i
      · refine ⟨1, by norm_num, le_rfl, ?_, ?_⟩
        · intro h
          exact False.elim ((not_lt_of_ge htech) h)
        · simp [mixedTaskCost, min_eq_left hcost]
      · refine ⟨0, le_rfl, by norm_num, fun _ => rfl, ?_⟩
        simp [mixedTaskCost, min_eq_right (le_of_not_ge hcost)]
  · simp only [minimumFactorCost, if_neg htech]
    constructor
    · intro x _ _ hx
      rw [hx (lt_of_not_ge htech)]
      simp [mixedTaskCost]
    · exact ⟨0, le_rfl, by norm_num, fun _ => rfl, by simp [mixedTaskCost]⟩

/-- No global monotonicity premise: only the active task interval is used. -/
def thresholdImplementsMinimumSpec : Prop :=
  ∀ (γ : ℝ → ℝ) (N W R I c : ℝ),
    StrictMonoOn γ (activeTasks N) →
    (∀ i ∈ activeTasks N, 0 < γ i) → 0 < R →
    c ∈ activeTasks N → W / R = γ c →
    ∀ i ∈ activeTasks N,
      thresholdFactorCost W R I c γ i = minimumFactorCost W R I γ i

theorem thresholdImplementsMinimum : thresholdImplementsMinimumSpec := by
  intro γ N W R I c hm hp hR hc heq i hi
  by_cases htech : i ≤ I
  · by_cases hcost : i ≤ c
    · have hg : γ i ≤ γ c := hm.monotoneOn hi hc hcost
      have hmul : γ i * R ≤ W := (le_div_iff₀ hR).mp (by rwa [heq])
      have hprice : R ≤ W / γ i := (le_div_iff₀ (hp i hi)).mpr (by nlinarith)
      simp [thresholdFactorCost, minimumFactorCost, htech,
        le_min htech hcost, min_eq_left hprice]
    · have hg : γ c < γ i := hm hc hi (lt_of_not_ge hcost)
      have hmul : W < γ i * R := (div_lt_iff₀ hR).mp (by rwa [heq])
      have hprice : W / γ i ≤ R := (div_le_iff₀ (hp i hi)).mpr (by nlinarith)
      have hn : ¬ i ≤ min I c := fun h => hcost (h.trans (min_le_right I c))
      simp [thresholdFactorCost, minimumFactorCost, htech, hn, min_eq_right hprice]
  · have hn : ¬ i ≤ min I c := fun h => htech (h.trans (min_le_left I c))
    simp [thresholdFactorCost, minimumFactorCost, htech, hn]

/-- Geometric displacement and reinstatement with the implemented cutoff held
fixed except for the stated change. Not general-equilibrium comparative statics. -/
def taskReallocationSpec : Prop :=
  (∀ N J₁ J₂ : ℝ, J₁ ∈ activeTasks N → J₂ ∈ activeTasks N → J₁ ≤ J₂ →
    volume.real (laborTasks N J₁) - volume.real (laborTasks N J₂) = J₂ - J₁ ∧
    volume.real (capitalTasks N J₂) - volume.real (capitalTasks N J₁) = J₂ - J₁) ∧
  (∀ N₁ N₂ J : ℝ, J ∈ activeTasks N₁ → J ∈ activeTasks N₂ → N₁ ≤ N₂ →
    volume.real (laborTasks N₂ J) - volume.real (laborTasks N₁ J) = N₂ - N₁ ∧
    volume.real (capitalTasks N₁ J) - volume.real (capitalTasks N₂ J) = N₂ - N₁)

theorem taskReallocation : taskReallocationSpec := by
  constructor
  · intro N J₁ J₂ h1 h2 _
    have p1 := taskPartition N J₁ h1
    have p2 := taskPartition N J₂ h2
    rw [p1.2.2.2.2.1, p2.2.2.2.2.1, p1.2.2.2.1, p2.2.2.2.1]
    constructor <;> ring
  · intro N₁ N₂ J h1 h2 _
    have p1 := taskPartition N₁ J h1
    have p2 := taskPartition N₂ J h2
    rw [p1.2.2.2.2.1, p2.2.2.2.2.1, p1.2.2.2.1, p2.2.2.2.1]
    constructor <;> ring

/-- Automation can move the implemented cutoff only up to the economic cutoff;
once technology is slack, further technical progress leaves it unchanged. -/
def automationSaturationSpec : Prop :=
  ∀ I₁ I₂ c : ℝ, I₁ ≤ I₂ →
    min I₁ c ≤ min I₂ c ∧
    min I₂ c - min I₁ c ≤ I₂ - I₁ ∧
    (c ≤ I₁ → min I₂ c = min I₁ c) ∧
    (I₂ ≤ c → min I₂ c - min I₁ c = I₂ - I₁)

theorem automationSaturation : automationSaturationSpec := by
  intro I₁ I₂ c hI
  refine ⟨min_le_min_right c hI, ?_, ?_, ?_⟩
  · rcases le_total I₂ c with h2 | h2
    · rw [min_eq_left h2, min_eq_left (hI.trans h2)]
    · rw [min_eq_right h2]
      rcases le_total I₁ c with h1 | h1
      · rw [min_eq_left h1]
        linarith
      · rw [min_eq_right h1]
        linarith
  · intro h1
    rw [min_eq_right h1, min_eq_right (h1.trans hI)]
  · intro h2
    rw [min_eq_left h2, min_eq_left (hI.trans h2)]

/-- Assumption 1' gives an explicit equal-cost threshold without a supplied
threshold witness. Its membership in the active interval is a separate restriction. -/
def exponentialThresholdFormulaSpec : Prop :=
  ∀ A W R : ℝ, 0 < A → 0 < W → 0 < R →
    W / R = Real.exp (A * (Real.log (W / R) / A)) ∧
    ∀ c : ℝ, W / R = Real.exp (A * c) → c = Real.log (W / R) / A

theorem exponentialThresholdFormula : exponentialThresholdFormulaSpec := by
  intro A W R hA hW hR
  have hratio : 0 < W / R := div_pos hW hR
  have hroot : W / R = Real.exp (A * (Real.log (W / R) / A)) := by
    rw [mul_div_cancel₀ _ (ne_of_gt hA), Real.exp_log hratio]
  refine ⟨hroot, ?_⟩
  intro c hc
  have he := Real.exp_injective (hc.symm.trans hroot)
  exact (mul_left_cancel₀ (ne_of_gt hA)) he

end AR18RaceManMachine
