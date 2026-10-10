"""Verify the steering encoder bracket against its assembly and chassis slots.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""
from pathlib import Path
import subprocess

import numpy as np
import trimesh

from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "build/steering-encoder/mesh-checks"
FIXTURE = ROOT / "tests/fixtures/steering_encoder.scad"


def export(mode: str, *, empty: bool = False) -> trimesh.Trimesh | None:
    path = OUT / f"{mode}.stl"
    result = subprocess.run(
        [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--enable=roof",
         "--hardwarnings", "-o", str(path), "-D", f'mode="{mode}"', str(FIXTURE)],
        capture_output=True, text=True)
    log = result.stdout + result.stderr
    assert "WARNING:" not in log and "ERROR:" not in log, log
    if empty and "Current top level object is empty" in log:
        return None
    assert result.returncode == 0 and path.exists(), log
    mesh = trimesh.load_mesh(path)
    assert isinstance(mesh, trimesh.Trimesh)
    if empty:
        triangles = mesh.triangles
        volume = np.einsum("ij,ij->i", triangles[:, 0],
                           np.cross(triangles[:, 1], triangles[:, 2])).sum() / 6
        assert abs(volume) < 1e-6, (mode, volume)
    else:
        assert mesh.is_watertight and mesh.is_winding_consistent, mode
        assert mesh.volume > 0 and len(mesh.split(only_watertight=False)) == 1, mode
    return mesh


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    frame = export("frame")
    bracket = export("bracket")
    assert frame is not None and bracket is not None
    np.testing.assert_allclose(frame.bounds[:, 0], [-75.63, 75.63], atol=1e-5)
    assert bracket.bounds[0, 0] >= frame.bounds[0, 0] - 1e-5
    assert bracket.bounds[1, 0] <= frame.bounds[1, 0] + 1e-5
    print("PASS connected bracket and rear frame within 151.26 mm chassis width", flush=True)
    for mode in ("placement_difference", "frame_collision", "hole_obstruction",
                 "magnet_collision"):
        export(mode, empty=True)
        print(f"PASS {mode}: no residual solid", flush=True)


if __name__ == "__main__":
    main()
