"""Verify the steering encoder bracket against its assembly and chassis slots.

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
OUT = ROOT / "build/steering-encoder/mesh-checks"
FIXTURE = ROOT / "tests/fixtures/steering_encoder.scad"


def export(mode: str, *, empty: bool = False, offset: float = 0,
           show_encoder: bool = False) -> trimesh.Trimesh | None:
    path = OUT / f"{mode}-{offset}-{show_encoder}.stl"
    result = subprocess.run(
        [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--enable=roof",
         "--hardwarnings", "-o", str(path), "-D", f'mode="{mode}"',
         "-D", f"steering_encoder_x_offset={offset}",
         "-D", f"show_encoder={json.dumps(show_encoder)}", str(FIXTURE)],
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
    nominal_x = [-75.63, 75.63]
    # Polygonized rounded edges can fall inside the analytic extent by 1 micron.
    np.testing.assert_allclose(frame.bounds[:, 0], nominal_x,
                               rtol=0, atol=1e-3)
    assert bracket.bounds[0, 0] >= nominal_x[0] - 1e-5
    assert bracket.bounds[1, 0] <= nominal_x[1] + 1e-5
    print("PASS connected bracket and rear frame within 151.26 mm chassis width", flush=True)
    for mode in ("placement_difference", "frame_collision", "hole_obstruction",
                 "magnet_collision"):
        export(mode, empty=True)
        print(f"PASS {mode}: no residual solid", flush=True)

    nominal = export("local_bracket")
    assert nominal is not None
    for offset in (-1.0, 1.0):
        shifted = export("local_bracket", offset=offset)
        assert shifted is not None
        np.testing.assert_allclose(shifted.bounds, nominal.bounds, atol=1e-5)
        np.testing.assert_allclose(shifted.volume, nominal.volume, atol=1e-5)
        for mode in ("upright_difference", "foot_difference",
                     "placement_difference", "hole_obstruction", "frame_collision"):
            export(mode, empty=True, offset=offset)
        export("upright_difference", empty=True, offset=offset, show_encoder=True)
        print(f"PASS {offset:+g} mm: upright and encoder translate together; "
              "fixed foot, clear chassis holes, matching assembly", flush=True)

    for offset in (-100, 100):
        result = subprocess.run(
            [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
             "-o", str(OUT / "invalid-offset.stl"),
             "-D", f"steering_encoder_x_offset={offset}", str(FIXTURE)],
            capture_output=True, text=True)
        assert result.returncode != 0 and "upright on the mounting foot" in result.stderr
    print("PASS offsets beyond the mounting foot are rejected", flush=True)


if __name__ == "__main__":
    main()
