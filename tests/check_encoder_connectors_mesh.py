"""Check encoder connectors, printable supports, and their clearances.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""
import json
from pathlib import Path
import subprocess

import numpy as np
import trimesh

from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "build/encoder-connectors/mesh-checks"
FIXTURE = ROOT / "tests/fixtures/encoder_connectors.scad"


def export(name: str, *, empty: bool = False, **params: object) -> trimesh.Trimesh | None:
    path = OUT / f"{name}.stl"
    command = [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
               "-o", str(path)]
    for key, value in params.items():
        command += ["-D", f"{key}={json.dumps(value)}"]
    result = subprocess.run(command + [str(FIXTURE)], capture_output=True, text=True)
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
        assert abs(volume) < 1e-6, (name, volume)
    else:
        assert mesh.is_watertight and mesh.is_winding_consistent and mesh.volume > 0, name
        assert len(mesh.split(only_watertight=False)) == 1, name
    return mesh


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for part, target in (("l", 10), ("l", 16), ("motor", 10)):
        base = export(f"{part}-{target}-plain", part=part, target_h=target)
        assert base is not None
        for jst, pins in ((True, False), (False, True), (True, True)):
            name = f"{part}-{target}-{jst}-{pins}"
            options = dict(part=part, target_h=target, jst=jst, pins=pins)
            mesh = export(name, empty=False, **options)
            assert mesh is not None
            assert mesh.volume < base.volume, name
            # Four mounting bores remain enclosed after the lateral edge trims.
            if target == 10:
                assert mesh.euler_number == base.euler_number, name
            export(f"{name}-collision", empty=True, mode="collision", **options)
            if part == "l":
                export(f"{name}-foot-gaps", empty=True, mode="foot_gaps", **options)
                zero_extra = export(f"{name}-zero-extra", empty=False, extra_left_w=0,
                                    **options)
                assert zero_extra is not None
                np.testing.assert_allclose(mesh.bounds, zero_extra.bounds, atol=1e-6)
                np.testing.assert_allclose(mesh.volume, zero_extra.volume, atol=1e-6)
            print(f"PASS {name}: connected support, clear connectors, stable mounting bores", flush=True)
    rounded = export("rounded-top", jst=True, pins=True)
    square = export("square-top", jst=True, pins=True, top_corner_r=0)
    assert rounded is not None and square is not None
    np.testing.assert_allclose(rounded.bounds, square.bounds, atol=1e-6)
    # Two 1 mm quarter-circle corners in a 3 mm wall remove about 1.29 mm³.
    assert 1.25 < square.volume - rounded.volume < 1.35
    print("PASS continuous foot and two rounded trimmed top corners", flush=True)
    for label, expected, options in (
        ("jst", [[-4.85, 4.65, -3.4], [4.85, 9.48, 0]], dict(jst=True)),
        ("pins", [[-4.05, -12.495, -4.56], [4.05, -5.145, 0]], dict(pins=True)),
    ):
        mesh = export(label, mode="connectors", **options)
        assert mesh is not None
        np.testing.assert_allclose(mesh.bounds, expected, atol=1e-5)
    print("PASS JST envelope and 4.56 mm right-angle header height", flush=True)
    result = subprocess.run(
        [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
         "-o", str(OUT / "low-pin-header.stl"), "-D", "pins=true",
         "-D", "target_h=14", str(FIXTURE)], capture_output=True, text=True)
    assert result.returncode != 0 and "pin tails reach the mounting foot" in result.stderr
    print("PASS downward pin tails require mounting-foot clearance", flush=True)


if __name__ == "__main__":
    main()
