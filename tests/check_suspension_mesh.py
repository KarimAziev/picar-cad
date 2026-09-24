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
from typing import Literal, overload
import numpy as np
import trimesh

from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "tests/fixtures/suspension_chassis_mesh.scad"
OUT = ROOT / "build/skill-previews/chassis-mesh-checks"


@overload
def export(
    part: str,
    *,
    name: str | None = None,
    empty: Literal[False] = False,
    **params: object,
) -> trimesh.Trimesh: ...


@overload
def export(
    part: str,
    *,
    name: str | None = None,
    empty: Literal[True],
    **params: object,
) -> trimesh.Trimesh | None: ...


def export(
    part: str,
    *,
    name: str | None = None,
    empty: bool = False,
    **params: object,
) -> trimesh.Trimesh | None:
    path = OUT / f"{name or part}.stl"
    cmd = [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--enable=roof",
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
    mesh = trimesh.load_mesh(path)
    assert isinstance(mesh, trimesh.Trimesh), f"{path}: expected a triangle mesh"
    return mesh


def one_solid(part: str, *, name: str | None = None, **params: object) -> trimesh.Trimesh:
    mesh = export(part, name=name, empty=False, **params)
    assert mesh.is_watertight, f"{part}: mesh is not watertight"
    assert mesh.is_winding_consistent, f"{part}: inconsistent face winding"
    shells = mesh.split(only_watertight=False)
    assert len(shells) == 1, f"{part}: {len(shells)} disconnected shells"
    assert mesh.volume > 0, f"{part}: no solid volume"
    print(f"PASS {part}: one watertight solid, {mesh.volume:.1f} mm³")
    return mesh


def assert_no_interference(mesh: trimesh.Trimesh | None, part: str) -> None:
    if mesh is None:
        return
    # Coplanar contact faces have zero volume and an undefined center of mass.
    # Integrate volume directly to avoid computing Trimesh's mass properties.
    tri = mesh.triangles
    volume = np.einsum("ij,ij->i", tri[:, 0], np.cross(tri[:, 1], tri[:, 2])).sum() / 6
    assert abs(volume) < 1e-6, (part, volume)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for part in ("front", "rear", "middle"):
        one_solid(part)
    printable = one_solid("printable")
    assert abs(printable.bounds[0, 2]) < 1e-6, "Printable must sit on Z=0"
    layer = one_solid("first_layer")
    np.testing.assert_allclose(layer.bounds[:, :2], printable.bounds[:, :2],
                               atol=1e-6)
    print("PASS first layer: connected deck footprint reaches the bed")

    for wide in (False, True):
        for part in ("male", "female"):
            one_solid(part, name=f"{part}-{wide}", wide=wide)
        collision = export("joint_collision", name=f"joint_collision-{wide}",
                           empty=True, wide=wide)
        assert_no_interference(collision, f"joint_collision-{wide}")
    for part in ("front_collision", "middle_collision"):
        collision = export(part, empty=True)
        assert_no_interference(collision, part)
    print("PASS compact/wide joints and complete frames: no solid interference")

    # The current middle deck no longer uses the former two-joint spacing API.
    # Check the active front-chassis assembly's rear-frame spacing instead.
    base = one_solid("placed_rear", name="spacing-zero")
    for spacing in (10, 20):
        moved = one_solid("placed_rear", name=f"spacing-{spacing}",
                          front_spacing=spacing)
        np.testing.assert_allclose(moved.bounds - base.bounds,
                                   [[0, -spacing, 0]] * 2, atol=1e-5)
        np.testing.assert_allclose(moved.volume, base.volume, atol=1e-5)
    print("PASS front-chassis spacing moves the rear frame without changing its solid")

    corners = export("corners").split(only_watertight=False)
    assert len(corners) == 4 and all(m.is_watertight for m in corners)
    expected_volume = (20 * 20 - (1 - np.pi / 4) * 4 ** 2) * 4
    for mesh in corners:
        assert abs(mesh.volume - expected_volume) < 0.1
    print("PASS single-corner rounding: all four choices remove one corner")


if __name__ == "__main__":
    main()
