import Mathlib.Analysis.SpecialFunctions.Log.Deriv
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.Tactic

/-! Analytical support for (13) and Appendix B (B10). The local equilibrium
identity is a premise; equilibrium existence, uniqueness, and its differentiable
selection are not established here. `g i = γ(i) ^ (σ̂ - 1)` specializes the
continuous task integrand to the paper. `omega = W / (R * K)` is the paper's
normalization, and capital is fixed along the path. -/
namespace AR18RaceManMachine
open Filter MeasureTheory
open scoped Topology

noncomputable def logRelativeDemandResidual (sigma K : ℝ)
    (omega L J A : ℝ → ℝ) (t : ℝ) : ℝ :=
  sigma * Real.log (omega t) + Real.log (L (omega t)) -
    ((1 - sigma) * Real.log K + Real.log (J t) - Real.log (A t))

/-- Differentiate the local log equilibrium, rather than assume its differential. -/
theorem logRelativeDemand_derivative
    {sigma K t dw dl dj da : ℝ} {omega L J A : ℝ → ℝ}
    (hw : HasDerivAt omega dw t) (hl : HasDerivAt L dl (omega t))
    (hj : HasDerivAt J dj t) (ha : HasDerivAt A da t)
    (pw : 0 < omega t) (pl : 0 < L (omega t))
    (pj : 0 < J t) (pa : 0 < A t)
    (heq : ∀ᶠ s in 𝓝 t, logRelativeDemandResidual sigma K omega L J A s = 0) :
    (sigma + omega t * dl / L (omega t)) * (dw / omega t) =
      dj / J t - da / A t := by
  have hd := ((hw.log (ne_of_gt pw)).const_mul sigma).add
    ((hl.comp t hw).log (ne_of_gt pl))
  have hr := ((hasDerivAt_const t ((1 - sigma) * Real.log K)).add
    (hj.log (ne_of_gt pj))).sub (ha.log (ne_of_gt pa))
  have heq' : (fun _ : ℝ => (0 : ℝ)) =ᶠ[𝓝 t]
      (fun s => logRelativeDemandResidual sigma K omega L J A s) :=
    heq.mono fun _ h => h.symm
  have hz := (hd.sub hr).congr_of_eventuallyEq heq'
  have hh := hz.unique (hasDerivAt_const t (0 : ℝ))
  dsimp at hh
  field_simp [ne_of_gt pw, ne_of_gt pl] at hh ⊢
  nlinarith

/-- Leibniz rule for a continuous task integrand and moving task boundaries. -/
theorem taskIntegral_hasDerivAt {g I N : ℝ → ℝ} {t di dn : ℝ}
    (hg : Continuous g) (hi : HasDerivAt I di t) (hn : HasDerivAt N dn t) :
    HasDerivAt (fun s => ∫ x in I s..N s, g x)
      (g (N t) * dn - g (I t) * di) t := by
  have hN := (intervalIntegral.integral_hasDerivAt_right
    (hg.intervalIntegrable 0 (N t)) hg.stronglyMeasurable.stronglyMeasurableAtFilter
    hg.continuousAt).comp t hn
  have hI := (intervalIntegral.integral_hasDerivAt_right
    (hg.intervalIntegrable 0 (I t)) hg.stronglyMeasurable.stronglyMeasurableAtFilter
    hg.continuousAt).comp t hi
  apply (hN.sub hI).congr_of_eventuallyEq
  exact Filter.Eventually.of_forall fun s =>
    intervalIntegral.integral_interval_sub_left
      (hg.intervalIntegrable 0 (N s)) (hg.intervalIntegrable 0 (I s)) |>.symm

noncomputable def taskLambda (gEndpoint J A : ℝ) : ℝ := gEndpoint / J + 1 / A

/-- B10 along a differentiable equilibrium path with actual moving task integrals.
Nonzero response denominator is explicit. The `I` path is the equilibrium task
boundary; identifying it with the technological frontier requires the binding
regime hypothesis elsewhere. -/
theorem relativeDemand_B10 {sigma K t dw dl di dn : ℝ}
    {omega L g I N : ℝ → ℝ}
    (hg : Continuous g) (hw : HasDerivAt omega dw t)
    (hl : HasDerivAt L dl (omega t))
    (hi : HasDerivAt I di t) (hn : HasDerivAt N dn t)
    (pw : 0 < omega t) (pl : 0 < L (omega t))
    (pj : 0 < ∫ x in I t..N t, g x) (pa : 0 < I t - N t + 1)
    (heq : ∀ᶠ s in 𝓝 t, logRelativeDemandResidual sigma K omega L
      (fun u => ∫ x in I u..N u, g x) (fun u => I u - N u + 1) s = 0)
    (hden : sigma + omega t * dl / L (omega t) ≠ 0) :
    dw / omega t =
      (taskLambda (g (N t)) (∫ x in I t..N t, g x) (I t - N t + 1) * dn -
       taskLambda (g (I t)) (∫ x in I t..N t, g x) (I t - N t + 1) * di) /
      (sigma + omega t * dl / L (omega t)) := by
  have hd := logRelativeDemand_derivative hw hl (taskIntegral_hasDerivAt hg hi hn)
    ((hi.sub hn).add_const 1) pw pl pj pa heq
  apply (eq_div_iff hden).2
  rw [mul_comm]
  rw [hd]
  unfold taskLambda
  simp only [Pi.sub_apply]
  ring

/-- Positive task weights imply the strict positivity used in comparative statics. -/
theorem taskLambda_pos {gEndpoint J A : ℝ} (hg : 0 < gEndpoint)
    (hj : 0 < J) (ha : 0 < A) : 0 < taskLambda gEndpoint J A :=
  add_pos (div_pos hg hj) (div_pos zero_lt_one ha)

/-- Fixed-capital normalization converts the relative wage derivative to B10's
log wage minus log rental-rate response. -/
theorem normalizedWage_logDerivative {W R : ℝ → ℝ} {t dw dr K : ℝ}
    (hw : HasDerivAt W dw t) (hr : HasDerivAt R dr t)
    (pw : 0 < W t) (pr : 0 < R t) (pk : 0 < K) :
    HasDerivAt (fun s => W s / (R s * K))
      ((W t / (R t * K)) * (dw / W t - dr / R t)) t := by
  convert hw.div (hr.mul_const K) (mul_ne_zero (ne_of_gt pr) (ne_of_gt pk)) using 1
  field_simp

/-- Explicit support contract: conditional comparative statics along the local
log equilibrium, with moving-boundary calculus discharged in the proof. -/
def RelativeDemandDerivativeSpec : Prop :=
  ∀ (sigma K t dw dl di dn : ℝ) (omega L g I N : ℝ → ℝ),
    Continuous g → HasDerivAt omega dw t → HasDerivAt L dl (omega t) →
    HasDerivAt I di t → HasDerivAt N dn t →
    0 < omega t → 0 < L (omega t) →
    0 < (∫ x in I t..N t, g x) → 0 < I t - N t + 1 →
    (∀ᶠ s in 𝓝 t, logRelativeDemandResidual sigma K omega L
      (fun u => ∫ x in I u..N u, g x) (fun u => I u - N u + 1) s = 0) →
    sigma + omega t * dl / L (omega t) ≠ 0 →
    dw / omega t =
      (taskLambda (g (N t)) (∫ x in I t..N t, g x) (I t - N t + 1) * dn -
       taskLambda (g (I t)) (∫ x in I t..N t, g x) (I t - N t + 1) * di) /
      (sigma + omega t * dl / L (omega t))

theorem relativeDemandDerivative : RelativeDemandDerivativeSpec := by
  intro sigma K t dw dl di dn omega L g I N hg hw hl hi hn pw pl pj pa heq hden
  exact relativeDemand_B10 hg hw hl hi hn pw pl pj pa heq hden

/-- Footnote 14's labor share, allowing endogenous labor supply. -/
noncomputable def equilibriumLaborShare (L : ℝ → ℝ) (x : ℝ) : ℝ :=
  x * L x / (1 + x * L x)

/-- The share increases strictly in the normalized wage when labor supply is
positive and its derivative is nonnegative. -/
theorem equilibriumLaborShare_hasDerivAt {L : ℝ → ℝ} {x dl : ℝ}
    (hl : HasDerivAt L dl x) (px : 0 < x) (pl : 0 < L x) (hdl : 0 ≤ dl) :
    HasDerivAt (equilibriumLaborShare L)
      ((L x + x * dl) / (1 + x * L x) ^ 2) x ∧
    0 < (L x + x * dl) / (1 + x * L x) ^ 2 := by
  have hp : 0 < 1 + x * L x := by positivity
  have hn : 0 < L x + x * dl := by positivity
  constructor
  · have hprod := (hasDerivAt_id x).mul hl
    convert hprod.div (hprod.const_add 1) (ne_of_gt hp) using 1
    dsimp
    ring
  · exact div_pos hn (sq_pos_of_pos hp)

/-- Along an equilibrium path, labor-share growth has precisely the wage sign;
employment grows at `dl * dw`, and has the same strict sign when `dl > 0`. -/
theorem equilibriumLaborShare_path {L omega : ℝ → ℝ} {t dw dl : ℝ}
    (hw : HasDerivAt omega dw t) (hl : HasDerivAt L dl (omega t))
    (pw : 0 < omega t) (pl : 0 < L (omega t)) (hdl : 0 ≤ dl) :
    let c := (L (omega t) + omega t * dl) / (1 + omega t * L (omega t)) ^ 2
    HasDerivAt (fun s => equilibriumLaborShare L (omega s)) (c * dw) t ∧
    (0 < c * dw ↔ 0 < dw) ∧ (c * dw < 0 ↔ dw < 0) ∧
    (c * dw = 0 ↔ dw = 0) ∧
    HasDerivAt (fun s => L (omega s)) (dl * dw) t ∧
    (0 < dl → ((0 < dl * dw ↔ 0 < dw) ∧ (dl * dw < 0 ↔ dw < 0))) := by
  dsimp
  obtain ⟨hs, hc⟩ := equilibriumLaborShare_hasDerivAt hl pw pl hdl
  refine ⟨hs.comp t hw, ?_, ?_, ?_, hl.comp t hw, ?_⟩
  · exact mul_pos_iff_of_pos_left hc
  · constructor <;> intro h <;> nlinarith
  · exact mul_eq_zero_iff_left (ne_of_gt hc)
  · intro hd
    constructor
    · exact mul_pos_iff_of_pos_left hd
    · constructor <;> intro h <;> nlinarith

end AR18RaceManMachine
