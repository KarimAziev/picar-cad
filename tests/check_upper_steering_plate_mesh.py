"""Check the printable bridge and its interfaces against production assemblies.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""
from pathlib import Path
import json
import subprocess

import numpy as np
import trimesh

from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "build/upper-steering-plate/mesh-checks"
FIXTURE = ROOT / "tests/fixtures/upper_steering_plate_mesh.scad"


def export(name: str, *, source: Path = FIXTURE, empty: bool = False,
           **params: object) -> trimesh.Trimesh | None:
    path = OUT / f"{name}.stl"
    command = [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--enable=roof", "--hardwarnings",
               "-o", str(path)]
    for key, value in params.items():
        command += ["-D", f"{key}={json.dumps(value)}"]
    result = subprocess.run(command + [str(source)], capture_output=True, text=True)
    log = result.stdout + result.stderr
    assert "WARNING:" not in log and "ERROR:" not in log, log
    if empty and "Current top level object is empty" in log:
        return None
    assert result.returncode == 0 and path.exists(), log
    mesh = trimesh.load_mesh(path)
    assert isinstance(mesh, trimesh.Trimesh)
    if empty:
        tri = mesh.triangles
        volume = np.einsum("ij,ij->i", tri[:, 0], np.cross(tri[:, 1], tri[:, 2])).sum() / 6
        assert abs(volume) < 1e-5, (name, volume)
    else:
        assert mesh.is_watertight and mesh.is_winding_consistent and mesh.volume > 0
        assert len(mesh.split(only_watertight=False)) == 1, name
    return mesh


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    plate = export("plate")
    assert plate is not None
    # Two windows plus five mounting bores: seven independent through holes.
    assert plate.euler_number == -12, plate.euler_number
    # Rounded offsets approximate circles; allow one micron of tessellation error.
    np.testing.assert_allclose(plate.bounds, [[0, 0, 0], [59.8, 38.5, 8.9]], atol=1e-3)
    centered = export("centered", plate_anchor=[0, 0, 0])
    assert centered is not None
    np.testing.assert_allclose(centered.bounds, plate.bounds - [29.9, 19.25, 4.45], atol=1e-3)
    printable = export("printable", source=ROOT / "scad/suspension/upper_steering_plate_printable.scad")
    assert printable is not None
    np.testing.assert_allclose(printable.bounds, plate.bounds, atol=1e-3)
    np.testing.assert_allclose(printable.volume, plate.volume, atol=1e-3)
    export("slots", part="slots", empty=True)
    export("mount-bores", part="mount_bores", empty=True)
    print("PASS: one watertight solid, two windows, five clear bores, anchors and printable orientation", flush=True)
    for arm, steering in ((0, 0), (10, -25), (25, 25), (-15, 0)):
        export(f"collision-{arm}-{steering}", part="collision", empty=True,
               arm_angle=arm, steering_angle=steering)
        print(f"PASS: no plate interference with suspension, bellcranks or servo at arm={arm}, steering={steering}", flush=True)


if __name__ == "__main__":
    main()
