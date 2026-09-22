# /// script
# requires-python = ">=3.11"
# dependencies = ["trimesh>=4,<5", "numpy>=2,<3", "networkx>=3,<4"]
# ///
"""Run with `uv run tests/check_plate_joint_mesh.py` (OpenSCAD nightly required)."""
from pathlib import Path
import json
import subprocess
import tempfile

import numpy as np
import trimesh

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "build/plate-joint/mesh-checks"
FIXTURE = ROOT / "tests/fixtures/plate_joint_mesh.scad"


def export(part, name, empty=False, **params):
    path = OUT / f"{name}.stl"
    command = ["openscad", "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
               "-o", str(path), "-D", f"part={json.dumps(part)}"]
    for key, value in params.items():
        command += ["-D", f"{key}={json.dumps(value)}"]
    result = subprocess.run(command + [str(FIXTURE)], capture_output=True, text=True)
    log = result.stdout + result.stderr
    assert "WARNING:" not in log and "ERROR:" not in log, log
    if empty and "Current top level object is empty" in log:
        return None
    assert result.returncode == 0 and path.exists(), log
    mesh = trimesh.load_mesh(path)
    if empty:
        tri = mesh.triangles
        volume = np.einsum("ij,ij->i", tri[:, 0], np.cross(tri[:, 1], tri[:, 2])).sum() / 6
        assert abs(volume) < 1e-6, (name, volume)
    else:
        assert mesh.is_watertight and mesh.is_winding_consistent and mesh.volume > 0, name
        assert len(mesh.split(only_watertight=False)) == 1, name
    return mesh


def invalid_inputs():
    cases = {
        'rail_w="oops%"': "non-negative decimal percentage",
        'rail_w="1.2.3%"': "non-negative decimal percentage",
        'rail_h="100%"': "Rail and plate skins",
        'angle="25%"': "angle must be numeric",
        'angle=89': "collapses the rail neck",
        'bolt_n_center=1.5': "non-negative integer",
        'mode="unknown"': "mode must be",
        'root_side=0': "root_side must be",
    }
    with tempfile.TemporaryDirectory(prefix="plate-joint-invalid-") as folder:
        source = Path(folder) / "invalid.scad"
        for args, expected in cases.items():
            source.write_text(f'use <{ROOT}/scad/components/plate_joint/plate_joint.scad>\n'
                              f'plate_joint(plate_h=6, bolt_d=3, w=54, l=24, {args});\n')
            result = subprocess.run(["openscad", "--backend=Manifold", "--enable=textmetrics",
                                     "--hardwarnings", "-o", str(Path(folder) / "invalid.stl"),
                                     str(source)], capture_output=True, text=True)
            assert result.returncode != 0 and expected in result.stderr, (args, result.stderr)
    print(f"PASS {len(cases)} invalid configurations rejected with parameter errors")


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for rib, pins, pad, relief in ((True, False, False, 0), (False, True, False, 0),
                                    (True, True, True, 0.1)):
        options = dict(rib=rib, pins=pins, pad=pad, relief=relief)
        for side in (-1, 1):
            name = f"{rib}-{pins}-{pad}-{side}"
            for part in ("male", "female"):
                export(part, f"{part}-{name}", side=side, **options)
            export("collision", f"collision-{name}", empty=True, side=side, **options)
            export("socket_difference", f"socket-{name}", empty=True, side=side, **options)
    print("PASS rib/plain rails, pin flats, relief and both roots: single solids, no interference, socket cutters match")
    for count in (0, 1, 2):
        export("male", f"count-{count}", bolts=count)
    for part in ("male", "female", "base"):
        mesh = export(part, f"anchor-default-{part}")
        expected = {
            # The shared slider rib's half-profile overlap leaves its tip 0.05 mm
            # short of the nominal rail height. Preserve the source joint profile.
            "male": [[-27, -23.6, 1.55], [27, 0.02, 6]],
            "female": [[-27, -24, 0], [27, 0.02, 4.1]],
            "base": [[-27, -24, 1.55], [27, 0, 6]],
        }
        np.testing.assert_allclose(mesh.bounds, expected[part], atol=1e-5)
        centered = export(part, f"anchor-center-{part}", joint_anchor=[0, 0, 0])
        corner = export(part, f"anchor-corner-{part}", joint_anchor=[1, 1, 1])
        np.testing.assert_allclose(centered.bounds - mesh.bounds, [[0, 12, -3]] * 2, atol=1e-5)
        np.testing.assert_allclose(corner.bounds - mesh.bounds, [[27, 24, 0]] * 2, atol=1e-5)
        np.testing.assert_allclose(centered.volume, mesh.volume, atol=1e-4)
        if part != "base":
            visible = export(part, f"bolts-visible-{part}", show_bolts=True)
            np.testing.assert_allclose(visible.volume, mesh.volume, atol=1e-5)
            annotated = export(part, f"sizes-visible-{part}", show_sizes=True)
            np.testing.assert_allclose(annotated.volume, mesh.volume, atol=1e-5)
    print("PASS zero/one/two bolts, anchors, preview bolts and size text excluded from exports")
    export("pin_cover_missing", "pin-cover-3.1mm", empty=True)
    print("PASS 3.1 mm passages retain surrounding material across joint and both parent plates")
    for anchor in ([1, 0, 1], [0, 0, 0], [-1, -1, -1]):
        for part in ("male", "female", "base"):
            options = dict(joint_anchor=anchor, pins=True, pin_d=3.1)
            normal = export(part, f"normal-{part}-{anchor}", **options)
            flipped = export(part, f"flipped-{part}-{anchor}", flip=True, **options)
            expected = normal.bounds.copy()
            expected[:, 2] = 6 * anchor[2] - normal.bounds[::-1, 2]
            np.testing.assert_allclose(flipped.bounds, expected, atol=1e-5)
            np.testing.assert_allclose(flipped.volume, normal.volume, atol=1e-4)
        for part in ("male", "female", "female_slots"):
            export("flip_difference", f"flip-difference-{part}-{anchor}", empty=True,
                   joint_anchor=anchor, mirror_part=part, pins=True, pin_d=3.1)
    export("collision", "flipped-collision", empty=True, flip=True, pins=True, pin_d=3.1)
    export("socket_difference", "flipped-socket", empty=True, flip=True, pins=True, pin_d=3.1)
    print("PASS flip preserves anchored envelopes and reflects entire solids and cutters, including [1,0,1]")
    global FIXTURE
    original = FIXTURE
    FIXTURE = ROOT / "tests/fixtures/plate_joint_front_reference.scad"
    for part in ("male", "female"):
        export(part, f"front-reference-{part}", empty=True)
    FIXTURE = ROOT / "tests/fixtures/plate_joint_usage.scad"
    for part in ("plate_a", "plate_b"):
        mesh = export(part, f"usage-{part}")
        expected = [[-70, -25.6, 0], [70, 90, 6]] if part == "plate_a" else [[-100, -120, 0], [100, 0, 6]]
        np.testing.assert_allclose(mesh.bounds, expected, atol=1e-5)
    for part in ("collision", "undef_difference", "male_slots_difference", "thin_bolt_slots_difference", "parent_pin_empty"):
        export(part, f"usage-{part}", empty=True)
    for part in ("auto_width_male", "auto_width_female"):
        mesh = export(part, f"usage-{part}")
        np.testing.assert_allclose(mesh.extents[0], 160 / 3, atol=1e-5)
    export("auto_width_collision", "auto-width-collision", empty=True)
    FIXTURE = original
    print("PASS source-joint geometry parity, real parent plates, forwarded undef and male cutters")
    invalid_inputs()


if __name__ == "__main__":
    main()
