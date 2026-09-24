#!/usr/bin/env python3
"""Recheck this homework's Lean files in an installed AppliedModelingLib environment.

Builds paper modules from a fresh temporary overlay, never from the library's
possibly different AR18RaceManMachine snapshot. This is a compiler/axiom check,
not the library's source-semantic closeout protocol.
"""
from pathlib import Path
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--library', type=Path, default=ROOT.parent.parent / 'AppliedModelingLib')
parser.add_argument('--report', type=Path, help='Optional JSON result and dependency/source hashes')
args = parser.parse_args()
lib = args.library.expanduser().resolve()
if not (lib / 'lakefile.toml').is_file():
    parser.error('Pass --library with the path to the installed AppliedModelingLib clone.')

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def capture(argv):
    return subprocess.check_output(argv, cwd=lib, text=True).strip()

def checked(argv, *, env=None):
    result = subprocess.run(argv, cwd=lib, env=env, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    print(result.stdout, end='', flush=True)
    bad = ('panic', 'internal error', 'sorryax')
    if result.returncode or any(x in result.stdout.lower() for x in bad):
        raise SystemExit(f'Check failed (exit {result.returncode}). No passing report written.')
    return result.stdout

start = time.monotonic()
env = os.environ.copy()
env['LEAN_NUM_THREADS'] = '1'
shared = 'AppliedModelingLib.Foundations.Math.ThresholdCharacterization'
checked(['lake', 'build', '+' + shared], env=env)
search = capture(['lake', 'env', 'printenv', 'LEAN_PATH'])
# Lake reports paths relative to its own root on some releases.
search = os.pathsep.join(str((lib / p).resolve()) if not Path(p).is_absolute() else p
                         for p in search.split(os.pathsep) if p)
modules = ['MainTheorems', 'Assumptions', 'PaperInterface', 'ProofInterface',
           'TaskFramework', 'WageDecomposition', 'PriceIndex', 'RelativeDemand',
           'LocalResponses', 'Verification']
logs = {}
snapshot_hashes = {m + ".lean": sha(ROOT / (m + ".lean")) for m in modules}
with tempfile.TemporaryDirectory(prefix='restrepo-lean-') as scratch:
    overlay = Path(scratch)
    package = overlay / 'AR18RaceManMachine'
    package.mkdir()
    for module in modules:
        shutil.copy2(ROOT / (module + '.lean'), package / (module + '.lean'))
    for module in modules:
        print(f'Checking AR18RaceManMachine.{module}', flush=True)
        logs[module] = checked([
            'lake', 'env', 'env', 'LEAN_PATH=' + str(overlay) + os.pathsep + search,
            'lean', '-R', str(overlay), '-o', str(package / (module + '.olean')),
            str(package / (module + '.lean')),
        ], env=env)

if any(sha(ROOT / f) != h for f, h in snapshot_hashes.items()):
    raise SystemExit('Sources changed during the check; rerun before recording a passing result.')

manifest = json.loads((lib / 'lake-manifest.json').read_text())
report = {
    'status': 'compiler_and_axiom_check_passed',
    'source_semantic_closeout': 'not_completed',
    'library_url': capture(['git', 'remote', 'get-url', 'origin']),
    'library_commit': capture(['git', 'rev-parse', 'HEAD']),
    'toolchain': (lib / 'lean-toolchain').read_text().strip(),
    'mathlib_commit': next(p['rev'] for p in manifest['packages'] if p['name'] == 'mathlib'),
    'threshold_module_sha256': sha(lib / 'AppliedModelingLib/Foundations/Math/ThresholdCharacterization.lean'),
    'lake_manifest_sha256': sha(lib / 'lake-manifest.json'),
    'source_sha256': snapshot_hashes,
    'elapsed_seconds': round(time.monotonic() - start, 2),
    'diagnostics': logs,
}
if args.report:
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + '\n')
print('PASS: all homework modules rebuilt; Lean verified theorem axiom closure.')
