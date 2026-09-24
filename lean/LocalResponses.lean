import AR18RaceManMachine.TaskFramework
import AR18RaceManMachine.WageDecomposition
import AR18RaceManMachine.PriceIndex
import AR18RaceManMachine.RelativeDemand

/-!
# Connecting the checked steps

The effective elasticity is `sigma` (sigma-hat in the source).
`I` denotes the implemented cutoff. In the constrained regime it equals the
technological frontier. This module derives local factor-price responses along
an assumed differentiable equilibrium path with a continuous task integrand.
It does NOT establish existence/uniqueness of that equilibrium path, or identify
the dual productivity coefficient with the primal production derivative.
-/
namespace AR18RaceManMachine
open Filter MeasureTheory
open scoped Topology

/-- The minimum cutoff is admissible when both technological and economic
cutoffs lie in the active task interval. -/
theorem implementedCutoff_mem {N I c : ℝ}
    (hi : I ∈ activeTasks N) (hc : c ∈ activeTasks N) :
    min I c ∈ activeTasks N :=
  ⟨le_min hi.1 hc.1, (min_le_left I c).trans hi.2⟩

/-- The explicit task intervals and the cost-minimizing cutoff fit together. -/
theorem implementedTaskPartition {N I c : ℝ}
    (hi : I ∈ activeTasks N) (hc : c ∈ activeTasks N) :
    capitalTasks N (min I c) ∪ laborTasks N (min I c) = activeTasks N ∧
    Disjoint (capitalTasks N (min I c)) (laborTasks N (min I c)) ∧
    volume.real (capitalTasks N (min I c)) + volume.real (laborTasks N (min I c)) = 1 := by
  have h := taskPartition N (min I c) (implementedCutoff_mem hi hc)
  exact ⟨h.1, h.2.1, h.2.2.2.2.2⟩

/-- Market-clearing quantities (8)-(9) identify the normalized price-index
labor weight with labor's share of factor income. `D` is B^(sigma-1)(1-eta)Y. -/
theorem priceWeight_eq_incomeShare {A J R W K L D C sigma : ℝ}
    (hR : 0 < R) (hW : 0 < W) (hD : 0 < D) (hC : 0 < C)
    (hK : K = D * A * R ^ (-sigma))
    (hL : L = D * J * W ^ (-sigma))
    (hindex : A * R ^ (1 - sigma) + J * W ^ (1 - sigma) = C) :
    J * W ^ (1 - sigma) / C = W * L / (R * K + W * L) := by
  have hpR : R ^ (1 - sigma) = R * R ^ (-sigma) := by
    rw [sub_eq_add_neg, Real.rpow_add hR, Real.rpow_one]
  have hpW : W ^ (1 - sigma) = W * W ^ (-sigma) := by
    rw [sub_eq_add_neg, Real.rpow_add hW, Real.rpow_one]
  have hi : R * K + W * L = D * C := by
    rw [hK, hL, ← hindex, hpR, hpW]
    ring
  rw [hi, hL, hpW]
  field_simp

/-- Positive task weights give an interior price-index share, without assuming
an arbitrary number has the interpretation of a share. -/
theorem priceWeight_interior {A J R W a C : ℝ}
    (hA : 0 < A) (hJ : 0 < J) (hR : 0 < R) (hW : 0 < W)
    (hindex : A * R ^ a + J * W ^ a = C) :
    0 < J * W ^ a / C ∧ J * W ^ a / C < 1 := by
  have hcap := mul_pos hA (Real.rpow_pos_of_pos hR a)
  have hlab := mul_pos hJ (Real.rpow_pos_of_pos hW a)
  have hC : 0 < C := by linarith
  constructor
  · exact div_pos hlab hC
  · apply (div_lt_one hC).2
    linarith

/-- A source-shaped local response theorem. The task interval, integral,
normalized wage, and the two locally valid equilibrium equations are explicit.
The B10 differential and the dual price-index analogue of B9 are derived
in the proof, not supplied as premises. Primal productivity remains unidentified. -/
def LocalFactorResponsesSpec : Prop :=
  ∀ (W R I N γ L : ℝ → ℝ) (t dw dr di dn dl K C sigma : ℝ),
    let g := fun i => (γ i) ^ (sigma - 1)
    let omega := fun s => W s / (R s * K)
    let J := fun s => ∫ i in I s..N s, g i
    let A := fun s => I s - N s + 1
    Continuous g → HasDerivAt W dw t → HasDerivAt R dr t →
    HasDerivAt I di t → HasDerivAt N dn t → HasDerivAt L dl (omega t) →
    0 < W t → 0 < R t → 0 < K → 0 < C → 0 < J t → 0 < A t →
    0 < L (omega t) → I t < N t → sigma ≠ 1 →
    sigma + omega t * dl / L (omega t) ≠ 0 →
    (∀ᶠ s in 𝓝 t, logRelativeDemandResidual sigma K omega L J A s = 0) →
    (fun s => A s * (R s) ^ (1 - sigma) + J s * (W s) ^ (1 - sigma))
      =ᶠ[𝓝 t] (fun _ => C) →
    let share := J t * (W t) ^ (1 - sigma) / C
    let prod := -((di - dn) * (R t) ^ (1 - sigma) +
      (g (N t) * dn - g (I t) * di) * (W t) ^ (1 - sigma)) / ((1 - sigma) * C)
    let relative :=
      (taskLambda (g (N t)) (J t) (A t) * dn -
       taskLambda (g (I t)) (J t) (A t) * di) /
       (sigma + omega t * dl / L (omega t))
    capitalTasks (N t) (I t) ∪ laborTasks (N t) (I t) = activeTasks (N t) ∧
    (0 < share ∧ share < 1) ∧
    dw / W t = prod + (1 - share) * relative ∧
    dr / R t = prod - share * relative

theorem localFactorResponses : LocalFactorResponsesSpec := by
  intro W R I N γ L t dw dr di dn dl K C sigma g omega J A hg hw hr hi hn hl
    pw pr pk pc pj pa pl hIN hs hd heq hp
  have hnw := normalizedWage_logDerivative hw hr pw pr pk
  have pow : 0 < omega t := div_pos pw (mul_pos pr pk)
  have hrel := relativeDemand_B10 hg hnw hl hi hn pow pl pj pa heq hd
  have hrel' : dw / W t - dr / R t =
      (taskLambda (g (N t)) (J t) (A t) * dn -
       taskLambda (g (I t)) (J t) (A t) * di) /
       (sigma + omega t * dl / L (omega t)) := by
    have he : (W t / (R t * K)) * (dw / W t - dr / R t) /
        (W t / (R t * K)) = dw / W t - dr / R t := by
      field_simp
    rw [he] at hrel
    exact hrel
  have hprice := priceIndexB9 A J R W t (di - dn)
    (g (N t) * dn - g (I t) * di) dr dw sigma C
    ((hi.sub hn).add_const 1) (taskIntegral_hasDerivAt hg hi hn) hr hw pr pw hs pc hp
  have hmem : I t ∈ activeTasks (N t) := by
    constructor
    · dsimp [A] at pa
      linarith
    · exact hIN.le
  have hshare := priceWeight_interior pa pj pr pw hp.eq_of_nhds
  exact ⟨(taskPartition (N t) (I t) hmem).1, hshare,
    (factorResponse_iff _ _ _ _ _).1 ⟨hprice, hrel'⟩⟩

end AR18RaceManMachine
