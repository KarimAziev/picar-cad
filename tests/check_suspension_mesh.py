# /// script
# requires-python = ">=3.11"
# dependencies = ["trimesh>=4,<5", "numpy>=2,<3", "networkx>=3,<4"]
# ///
"""Run with `uv run tests/check_suspension_mesh.py` (OpenSCAD nightly required).

Check exported solids independently of OpenSCAD's successful-export status.
Outputs are reviewable under build/skill-previews/chassis-mesh-checks.
"""
from pathlib import Path
import subprocess
import numpy as np
import trimesh

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "tests/fixtures/suspension_chassis_mesh.scad"
OUT = ROOT / "build/skill-previews/chassis-mesh-checks"


def export(part, *, name=None, empty=False, **params):
    path = OUT / f"{name or part}.stl"
    cmd = ["openscad", "--backend=Manifold", "--enable=textmetrics", "--enable=roof",
           "--hardwarnings", "-o", str(path), "-D", f'part="{part}"']
    for key, value in params.items():
        cmd += ["-D", f"{key}={str(value).lower()}"]
    result = subprocess.run(cmd + [str(FIXTURE)], capture_output=True, text=True)
    log = result.stdout + result.stderr
    assert "WARNING:" not in log and "ERROR:" not in log, log
    if empty and "Current top level object is empty" in log:
        return None
    assert result.returncode == 0, log
    assert path.exists(), log
    return trimesh.load_mesh(path)


def one_solid(part, **params):
    mesh = export(part, **params)
    assert mesh.is_watertight, f"{part}: mesh is not watertight"
    assert mesh.is_winding_consistent, f"{part}: inconsistent face winding"
    shells = mesh.split(only_watertight=False)
    assert len(shells) == 1, f"{part}: {len(shells)} disconnected shells"
    assert mesh.volume > 0, f"{part}: no solid volume"
    print(f"PASS {part}: one watertight solid, {mesh.volume:.1f} mm³")
    return mesh


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for part in ("front", "rear", "middle"):
        one_solid(part)
    printable = one_solid("printable")
    assert abs(printable.bounds[0, 2]) < 1e-6, "Printable must sit on Z=0"
    layer = one_solid("first_layer")
    np.testing.assert_allclose(layer.bounds[:, :2], printable.bounds[:, :2],
                               atol=1e-6)
    print("PASS first layer: connected deck and both tongues reach the bed")

    for wide in (False, True):
        for part in ("male", "female"):
            one_solid(part, name=f"{part}-{wide}", wide=wide)
        collision = export("joint_collision", name=f"joint_collision-{wide}",
                           empty=True, wide=wide)
        assert collision is None or abs(collision.volume) < 1e-6
    for part in ("front_collision", "middle_collision"):
        collision = export(part, empty=True)
        # Coplanar face contacts can be exported as zero-volume triangles.
        assert collision is None or abs(collision.volume) < 1e-6, part
    print("PASS compact/wide joints and complete frames: no solid interference")

    base = one_solid("placed_middle", name="spacing-zero")
    for front, middle in ((10, 0), (0, 10), (10, 20)):
        moved = one_solid("placed_middle", name=f"spacing-{front}-{middle}",
                          front_spacing=front, middle_spacing=middle)
        np.testing.assert_allclose(moved.bounds - base.bounds,
                                   [[0, -front - middle, 0]] * 2, atol=1e-6)
        np.testing.assert_allclose(moved.volume, base.volume, atol=1e-5)
    print("PASS both spacing controls propagate through the top assembly")

    corners = export("corners").split(only_watertight=False)
    assert len(corners) == 4 and all(m.is_watertight for m in corners)
    expected_volume = (20 * 20 - (1 - np.pi / 4) * 4 ** 2) * 4
    for mesh in corners:
        assert abs(mesh.volume - expected_volume) < 0.1
    print("PASS single-corner rounding: all four choices remove one corner")


if __name__ == "__main__":
    main()
