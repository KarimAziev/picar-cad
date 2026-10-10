"""Check head pin placement, solid head transition, mating solids and print placement.

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
                 "transition_void"):
        checks.assert_no_interference(checks.export(part, empty=True), part)
    for part in ("head_printable", "frame_printable"):
        mesh = checks.one_solid(part)
        np.testing.assert_allclose(mesh.bounds[0, 2], 0, atol=1e-6)
    moved = checks.one_solid("head", name="head-spaced", spacing=20)
    np.testing.assert_allclose(moved.bounds - head.bounds, [[0, 20, 0]] * 2, atol=1e-5)
    for length in (23.8, 33.8):
        pins = checks.export("pins", name=f"pins-{length}",
                             front_chassis_head_joint_pin_l=length)
        assert len(pins.split()) == 2
        for pin in pins.split():
            np.testing.assert_allclose(pin.bounds[:, 1],
                                       [45.5, 45.5 + length], atol=1e-5)
        for part in ("pin_keepout", "pin_obstruction"):
            checks.assert_no_interference(
                checks.export(part, name=f"{part}-{length}", empty=True,
                              front_chassis_head_joint_pin_l=length), part)
    result = subprocess.run(
        [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
         "-D", "front_chassis_head_joint_pin_l=12",
         "-D", 'part="head"', "-o", str(checks.OUT / "invalid.stl"),
         str(checks.FIXTURE)], text=True, capture_output=True,
    )
    assert result.returncode != 0 and "engagement beyond the head root" in result.stderr
    print("PASS 23.8 and 33.8 mm pins extend toward the head: "
          "fixed bulkhead ends, hardware keepouts with 1 mm margin, "
          "open passages, solid head transition, matching envelope, printable "
          "solids and insufficient head engagement rejected")


if __name__ == "__main__":
    main()
