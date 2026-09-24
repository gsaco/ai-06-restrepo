import AR18RaceManMachine.ProofInterface
import AR18RaceManMachine.TaskFramework
import AR18RaceManMachine.WageDecomposition
import AR18RaceManMachine.PriceIndex
import AR18RaceManMachine.RelativeDemand
import AR18RaceManMachine.LocalResponses
import Lean.Util.CollectAxioms

/-! Lean-native discovery and recursive axiom check for every theorem in this
paper namespace. This is compiler evidence, not a source-fidelity receipt. -/
open Lean Elab Command

run_cmd do
  let env ← getEnv
  let mut count := 0
  for (name, info) in env.constants.toList do
    if (`AR18RaceManMachine).isPrefixOf name then
      if let .thmInfo _ := info then
        let axioms ← collectAxioms name
        for ax in axioms do
          unless #[`propext, `Classical.choice, `Quot.sound].contains ax do
            throwError "Unexpected axiom in {name}: {ax}"
        logInfo m!"CHECKED {name}: {axioms}"
        count := count + 1
  logInfo m!"CHECKED theorem declarations: {count}. Only approved foundational axioms."
