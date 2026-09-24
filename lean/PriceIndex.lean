import Mathlib.Analysis.SpecialFunctions.Pow.Deriv
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
namespace AR18RaceManMachine
open Filter
open scoped Topology

/-! Differential support for B9 from the CES price-index identity.
This proves a dual price-index response, not its equality to the derivative
of the primal production function. `A` and `J` are task cost weights;
`C` is the positive constant price-index total (B^(1-sigma) in the paper).
The exponent `a` specializes to `1-sigma`, with sigma ≠ 1. -/

lemma priceIndex_derivative_zero
    {A J R W : ℝ → ℝ} {t A' J' R' W' a C : ℝ}
    (hA : HasDerivAt A A' t) (hJ : HasDerivAt J J' t)
    (hR : HasDerivAt R R' t) (hW : HasDerivAt W W' t)
    (hRp : 0 < R t) (hWp : 0 < W t)
    (hc : (fun x => A x * (R x) ^ a + J x * (W x) ^ a)
      =ᶠ[𝓝 t] (fun _ => C)) :
    A' * (R t) ^ a + J' * (W t) ^ a +
      a * (A t * (R t) ^ a * (R' / R t) +
        J t * (W t) ^ a * (W' / W t)) = 0 := by
  have hr := hR.rpow_const (p := a) (Or.inl (ne_of_gt hRp))
  have hw := hW.rpow_const (p := a) (Or.inl (ne_of_gt hWp))
  have hd := (hA.mul hr).add (hJ.mul hw)
  have hz := hd.unique ((hasDerivAt_const t C).congr_of_eventuallyEq hc)
  rw [Real.rpow_sub_one (ne_of_gt hRp), Real.rpow_sub_one (ne_of_gt hWp)] at hz
  calc
    _ = (A' * R t ^ a + A t * (R' * a * (R t ^ a / R t))) +
        (J' * W t ^ a + J t * (W' * a * (W t ^ a / W t))) := by ring
    _ = 0 := hz

/-- The normalized capital and labor weights produce a weighted log-price
response by differentiating a locally constant price index. -/
lemma priceIndex_weighted_response
    {A J R W : ℝ → ℝ} {t A' J' R' W' a C : ℝ}
    (hA : HasDerivAt A A' t) (hJ : HasDerivAt J J' t)
    (hR : HasDerivAt R R' t) (hW : HasDerivAt W W' t)
    (hRp : 0 < R t) (hWp : 0 < W t) (ha : a ≠ 0) (hC : 0 < C)
    (hc : (fun x => A x * (R x) ^ a + J x * (W x) ^ a)
      =ᶠ[𝓝 t] (fun _ => C)) :
    (J t * (W t) ^ a / C) * (W' / W t) +
      (1 - J t * (W t) ^ a / C) * (R' / R t) =
      -(A' * (R t) ^ a + J' * (W t) ^ a) / (a * C) := by
  have hz := priceIndex_derivative_zero hA hJ hR hW hRp hWp hc
  have hv : A t * (R t) ^ a + J t * (W t) ^ a = C := hc.eq_of_nhds
  have hs : 1 - J t * (W t) ^ a / C = A t * (R t) ^ a / C := by
    apply (eq_div_iff (ne_of_gt hC)).2
    field_simp
    linarith
  rw [hs]
  apply (eq_div_iff (mul_ne_zero ha (ne_of_gt hC))).2
  calc
    _ = a * (A t * R t ^ a * (R' / R t) + J t * W t ^ a * (W' / W t)) := by
      field_simp
      ring
    _ = _ := by linarith

/-- B9 supporting specification from an actual local price-index identity;
`p` is explicitly the dual cost-weight productivity expression. -/
def PriceIndexB9Spec : Prop :=
  ∀ (A J R W : ℝ → ℝ) (t A' J' R' W' sigma C : ℝ),
    HasDerivAt A A' t → HasDerivAt J J' t →
    HasDerivAt R R' t → HasDerivAt W W' t →
    0 < R t → 0 < W t → sigma ≠ 1 → 0 < C →
    (fun x => A x * (R x) ^ (1 - sigma) + J x * (W x) ^ (1 - sigma))
      =ᶠ[𝓝 t] (fun _ => C) →
    let s := J t * (W t) ^ (1 - sigma) / C
    let p := -(A' * (R t) ^ (1 - sigma) + J' * (W t) ^ (1 - sigma)) /
      ((1 - sigma) * C)
    s * (W' / W t) + (1 - s) * (R' / R t) = p

theorem priceIndexB9 : PriceIndexB9Spec := by
  intro A J R W t A' J' R' W' sigma C hA hJ hR hW hRp hWp hs hC hc
  exact priceIndex_weighted_response hA hJ hR hW hRp hWp
    (sub_ne_zero.mpr (Ne.symm hs)) hC hc
end AR18RaceManMachine
