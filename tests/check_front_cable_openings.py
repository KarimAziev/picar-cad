"""Check front cable passages and bumper hardware orientation.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""
import numpy as np

import check_suspension_mesh as checks


def main() -> None:
    checks.OUT = checks.ROOT / "build/skill-previews/front-cable-update/regression"
    checks.OUT.mkdir(parents=True, exist_ok=True)
    checks.FIXTURE = checks.ROOT / "tests/fixtures/front_ribbon_slots.scad"
    holes = checks.export("servo_cables", split_front_chassis=False)
    shells = holes.split()
    assert len(shells) == 2
    for shell in shells:
        assert shell.is_watertight
        np.testing.assert_allclose(shell.extents, [4, 8.8, 6], atol=1e-5)
    np.testing.assert_allclose(shells[0].volume, shells[1].volume, atol=1e-5)
    checks.assert_no_interference(
        checks.export("servo_cables", name="servo-cables-split", empty=True,
                      split_front_chassis=True), "joint suppresses servo cable holes")
    checks.assert_no_interference(
        checks.export("servo_cable_land", empty=True, split_front_chassis=False),
        "1 mm material around servo cable holes")
    wiring = checks.one_solid("wiring")
    np.testing.assert_allclose(wiring.extents, [12, 20, 6], atol=1e-5)
    area = 12 * 20 - 4 * 2**2 + 18 * 2**2 * np.sin(np.pi / 18)
    np.testing.assert_allclose(wiring.volume, area * 6, atol=0.01)
    checks.assert_no_interference(checks.export("wiring_land", empty=True),
                                  "1.5 mm material around wiring passage")
    for orientation in ("wlh", "lwh"):
        checks.assert_no_interference(
            checks.export("wiring_servo", name=f"wiring-servo-{orientation}",
                          empty=True, front_rpi_orientation=f'"{orientation}"'),
            f"wiring passage clears steering hardware, orientation={orientation}")
    checks.assert_no_interference(
        checks.export("wiring_land", name="wiring-land-wlh", empty=True,
                      front_rpi_orientation='"wlh"'),
        "wiring passage retains material in the alternate Pi orientation")
    print("PASS paired head-size cable holes, joint gating and rounded wiring passage")

    checks.FIXTURE = checks.ROOT / "tests/fixtures/front_bumper.scad"
    for reverse in (False, True):
        checks.assert_no_interference(
            checks.export("hardware_frame", name=f"hardware-frame-{reverse}",
                          empty=True, reverse_bolts=reverse),
            f"hardware clears head frame, reverse={reverse}")
    print("PASS both hardware directions clear the frame")


if __name__ == "__main__":
    main()
