"""Check stock head pins, intact ribbon lands, mating solids and print placement.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""

import subprocess

import numpy as np

import check_suspension_mesh as checks
from scad_test_support import OPENSCAD


def main() -> None:
    checks.FIXTURE = checks.ROOT / "tests/fixtures/front_head_joint.scad"
    checks.OUT = checks.ROOT / "build/skill-previews/head-joint/mesh-checks"
    checks.OUT.mkdir(parents=True, exist_ok=True)
    head = checks.one_solid("head")
    frame = checks.one_solid("frame")
    original = checks.one_solid("original")
    bounds = np.array([np.minimum(head.bounds[0], frame.bounds[0]),
                       np.maximum(head.bounds[1], frame.bounds[1])])
    np.testing.assert_allclose(bounds, original.bounds, atol=1e-5)
    for part in ("collision", "pin_keepout", "pin_obstruction", "bolt_obstruction",
                 "ribbon_obstruction"):
        checks.assert_no_interference(checks.export(part, empty=True), part)
    ribbons = checks.export("ribbon_shape")
    assert ribbons is not None
    assert len(ribbons.split()) == 3
    radius = 0.6
    slot_area = 20 * 3 - 4 * radius**2 + 20 * radius**2 * np.sin(np.pi / 20)
    np.testing.assert_allclose(ribbons.volume, 3 * slot_area * 6.04, atol=0.01)
    lands = checks.export("ribbon_land")
    assert lands is not None
    assert len(lands.split()) == 2
    # Both original 20 x 3 mm retaining strips remain full thickness on the head.
    np.testing.assert_allclose(lands.volume, 2 * 20 * 3 * 6, atol=1e-5)
    for part in ("head_printable", "frame_printable"):
        mesh = checks.one_solid(part)
        np.testing.assert_allclose(mesh.bounds[0, 2], 0, atol=1e-6)
    moved = checks.one_solid("head", name="head-spaced", spacing=20)
    np.testing.assert_allclose(moved.bounds - head.bounds, [[0, 20, 0]] * 2, atol=1e-5)
    for length in (33, 38, 39.5, 43, 44, 54):
        result = subprocess.run(
            [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
             "-D", f"front_chassis_head_joint_pin_l={length}",
             "-D", 'part="head"', "-o", str(checks.OUT / "invalid.stl"),
             str(checks.FIXTURE)], text=True, capture_output=True,
        )
        assert result.returncode != 0 and "bulkhead mounting keepout" in result.stderr
    print("PASS two stock 23.8 mm pins: hardware keepouts with 1 mm margin, "
          "open passages, intact ribbon strips, unchanged envelope, printable "
          "solids and longer stock pins rejected")


if __name__ == "__main__":
    main()
