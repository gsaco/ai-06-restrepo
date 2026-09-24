import AR18RaceManMachine.PaperInterface

namespace AR18RaceManMachine

/-- Checked cost ranking for the conditional, interior threshold. -/
theorem thresholdCostRanking : thresholdCostRankingSpec := by
  intro γ w R I costThreshold hmono hγ hw hR heq
  constructor
  · intro i hi
    have hiCost : i < costThreshold := lt_of_lt_of_le hi (min_le_right I costThreshold)
    have hγlt : γ i < γ costThreshold := hmono hiCost
    have hmul : γ i * R < w := by
      apply (lt_div_iff₀ hR).mp
      rw [heq]
      exact hγlt
    constructor
    · exact le_trans (le_of_lt hi) (min_le_left I costThreshold)
    · dsimp [laborUnitCost]
      apply (lt_div_iff₀ (hγ i)).2
      nlinarith
  · intro i hi
    by_cases hI : I ≤ costThreshold
    · left
      simpa [implementedThreshold, min_eq_left hI] using hi
    · right
      have hcost : costThreshold ≤ I := le_of_lt (lt_of_not_ge hI)
      have hiCost : costThreshold < i := by
        simpa [implementedThreshold, min_eq_right hcost] using hi
      have hγlt : γ costThreshold < γ i := hmono hiCost
      have hmul : w < γ i * R := by
        have hdiv : w / R < γ i := by rwa [heq]
        exact (div_lt_iff₀ hR).mp hdiv
      dsimp [laborUnitCost]
      apply (div_lt_iff₀ (hγ i)).2
      nlinarith

/-- Checked algebraic sign of the Proposition 3 wage response. -/
theorem automationWageSign : automationWageSignSpec := by
  intro productivityGain laborShare ΛI σhat εL _ _ _ _ _
  unfold automationWageResponse
  constructor <;> intro h <;> linarith

end AR18RaceManMachine
