import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
namespace AR18RaceManMachine
/-! Algebraic support for Proposition 3, Appendix B p. B-13 (B9–B10).
The response equations are premises, not derived here from model primitives.
Productivity and denominator positivity are explicit conditional inputs.
This does not prove the capital threshold or full Proposition 3. -/
def FactorResponse (s p q w r : ℝ) : Prop :=
  s * w + (1 - s) * r = p ∧ w - r = q

lemma factorResponse_iff (s p q w r : ℝ) :
    FactorResponse s p q w r ↔
      w = p + (1 - s) * q ∧ r = p - s * q := by
  unfold FactorResponse
  constructor
  · rintro ⟨ha, hb⟩
    have hc := congrArg (fun x : ℝ => s * x) hb
    constructor <;> nlinarith
  · rintro ⟨rfl, rfl⟩
    constructor <;> ring

lemma factorResponse_existsUnique (s p q : ℝ) :
    ∃! z : ℝ × ℝ, FactorResponse s p q z.1 z.2 := by
  refine ⟨(p + (1 - s) * q, p - s * q), ?_, ?_⟩
  · exact (factorResponse_iff _ _ _ _ _).2 ⟨rfl, rfl⟩
  · intro z hz
    obtain ⟨hw, hr⟩ := (factorResponse_iff _ _ _ _ _).1 hz
    exact Prod.ext hw hr

/-- Relative log factor-price response supplied by B10. -/
noncomputable def taskRelativeResponse (lambdaN lambdaI dN dI sigma eps : ℝ) : ℝ :=
  (lambdaN * dN - lambdaI * dI) / (sigma + eps)

lemma taskRelativeResponse_split (lambdaN lambdaI dN dI sigma eps : ℝ) :
    taskRelativeResponse lambdaN lambdaI dN dI sigma eps =
      lambdaN * dN / (sigma + eps) - lambdaI * dI / (sigma + eps) := by
  exact sub_div _ _ _

lemma automation_response {s p lambdaN lambdaI dI sigma eps w r : ℝ}
    (h : FactorResponse s p
      (taskRelativeResponse lambdaN lambdaI 0 dI sigma eps) w r) :
    w = p - (1 - s) * (lambdaI * dI / (sigma + eps)) ∧
    r = p + s * (lambdaI * dI / (sigma + eps)) := by
  rw [factorResponse_iff] at h
  simp only [taskRelativeResponse, mul_zero, zero_sub, neg_div] at h
  constructor <;> nlinarith [h.1, h.2]

lemma reinstatement_response {s p lambdaN lambdaI dN sigma eps w r : ℝ}
    (h : FactorResponse s p
      (taskRelativeResponse lambdaN lambdaI dN 0 sigma eps) w r) :
    w = p + (1 - s) * (lambdaN * dN / (sigma + eps)) ∧
    r = p - s * (lambdaN * dN / (sigma + eps)) := by
  rw [factorResponse_iff] at h
  simpa only [taskRelativeResponse, mul_zero, sub_zero] using h

lemma automation_strict_effects {s p lambdaN lambdaI dI sigma eps w r : ℝ}
    (hs : 0 < s) (hs' : s < 1) (hp : 0 < p)
    (hl : 0 < lambdaI) (hi : 0 < dI) (hd : 0 < sigma + eps)
    (h : FactorResponse s p
      (taskRelativeResponse lambdaN lambdaI 0 dI sigma eps) w r) :
    w < p ∧ p < r ∧ 0 < r ∧ w < r := by
  obtain ⟨hw, hr⟩ := automation_response h
  have ht := div_pos (mul_pos hl hi) hd
  have hst := mul_pos hs ht
  have hs't := mul_pos (sub_pos.mpr hs') ht
  exact ⟨by linarith, by linarith, by linarith, by linarith⟩

lemma reinstatement_strict_effects {s p lambdaN lambdaI dN sigma eps w r : ℝ}
    (hs : 0 < s) (hs' : s < 1) (hp : 0 < p)
    (hl : 0 < lambdaN) (hn : 0 < dN) (hd : 0 < sigma + eps)
    (h : FactorResponse s p
      (taskRelativeResponse lambdaN lambdaI dN 0 sigma eps) w r) :
    p < w ∧ r < p ∧ 0 < w ∧ r < w := by
  obtain ⟨hw, hr⟩ := reinstatement_response h
  have ht := div_pos (mul_pos hl hn) hd
  have hst := mul_pos hs ht
  have hs't := mul_pos (sub_pos.mpr hs') ht
  exact ⟨by linarith, by linarith, by linarith, by linarith⟩

lemma automation_wage_sign_criteria {s p lambdaN lambdaI dI sigma eps w r : ℝ}
    (hd : 0 < sigma + eps)
    (h : FactorResponse s p
      (taskRelativeResponse lambdaN lambdaI 0 dI sigma eps) w r) :
    (0 < w ↔ (1 - s) * (lambdaI * dI) < p * (sigma + eps)) ∧
    (w = 0 ↔ p * (sigma + eps) = (1 - s) * (lambdaI * dI)) ∧
    (w < 0 ↔ p * (sigma + eps) < (1 - s) * (lambdaI * dI)) := by
  have hw := (automation_response h).1
  have he : w * (sigma + eps) =
      p * (sigma + eps) - (1 - s) * (lambdaI * dI) := by
    rw [hw]
    field_simp
  have hm : 0 < w * (sigma + eps) ↔ 0 < w := mul_pos_iff_of_pos_right hd
  have hn : w * (sigma + eps) < 0 ↔ w < 0 := by
    constructor <;> intro hh <;> nlinarith
  have hz : w * (sigma + eps) = 0 ↔ w = 0 := by simp [ne_of_gt hd]
  constructor
  · rw [← hm, he]; constructor <;> intro hh <;> linarith
  constructor
  · rw [← hz, he]; constructor <;> intro hh <;> linarith
  · rw [← hn, he]; constructor <;> intro hh <;> linarith

/-- Log labor-share growth identity at fixed supplies is an explicit condition;
no derivative identity is silently assumed proved. -/
lemma share_growth_sign {s w r g : ℝ} (hs : s < 1)
    (hg : g = (1 - s) * (w - r)) :
    (0 < g ↔ r < w) ∧ (g = 0 ↔ w = r) ∧ (g < 0 ↔ w < r) := by
  have hp : 0 < 1 - s := sub_pos.mpr hs
  rw [hg]
  constructor
  · rw [mul_pos_iff_of_pos_left hp]; exact sub_pos
  constructor
  · rw [mul_eq_zero]; simp [ne_of_gt hp, sub_eq_zero]
  · have hh : (1 - s) * (w - r) < 0 ↔ w - r < 0 := by
      constructor <;> intro hh <;> nlinarith
    rw [hh]; exact sub_neg

/-- Complete B9–B10 algebra bundle; no claim to full Proposition 3. -/
def B9B10AlgebraSpec : Prop :=
  ∀ s p lambdaN lambdaI dN dI sigma eps : ℝ,
    let q := taskRelativeResponse lambdaN lambdaI dN dI sigma eps
    (∃! z : ℝ × ℝ, FactorResponse s p q z.1 z.2) ∧
    ∀ w r, FactorResponse s p q w r ↔
      w = p + (1 - s) * q ∧ r = p - s * q

theorem b9B10Algebra : B9B10AlgebraSpec := by
  intro s p lambdaN lambdaI dN dI sigma eps
  exact ⟨factorResponse_existsUnique _ _ _, fun w r => factorResponse_iff _ _ _ w r⟩
end AR18RaceManMachine
