# Lean development · continuous tasks and local responses

**Status: expanded partial formalization.** Built with the homework's AppliedModelingLib package. The original two supporting examples are retained, and the new modules develop the continuous task framework, firm cost allocation, actual moving-integral derivatives, local wage and rental responses, and labor-share and employment derivatives.

- [Read the proofs and their assumptions](docs/LEAN_VERIFICATION.md).
- [Inspect the compiler report and source hashes](verification/build.json).
- [Understand the scope, cost, and 19 named source results](docs/SCOPE_AND_COST.md).
- [Return to the project guide](../README.md).

The main integration endpoint is `localFactorResponses` in [LocalResponses.lean](LocalResponses.lean). It differentiates locally valid equilibrium identities; it does not prove equilibrium existence. The full paper and the library's source-semantic closeout remain unfinished.

## Reproduce

```bash
python3 lean/check.py --library /path/to/AppliedModelingLib
```

Run from the homework repository root with the recorded toolchain and dependencies installed. This directory is not a standalone Lake project. The runner builds the imported library threshold module, compiles these exact homework sources in a temporary overlay, and rejects unexpected theorem axioms. See the guide for details.

The legacy `review_surface` in [status.json](status.json) and the `audit/` records concern the original two-example scaffold. They do not certify the new modules. The `homework_extension` status section identifies the expanded development and its current evidence.
