"""Check lowered hardware, supported mounting floors and printable chassis solids.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""

import numpy as np

import check_suspension_mesh as checks
from check_chassis_joint_bores import vertical_hits


def main() -> None:
    checks.FIXTURE = checks.ROOT / "tests/fixtures/chassis_mount_recesses.scad"
    checks.OUT = checks.ROOT / "build/skill-previews/lowered-mounts/checks"
    checks.OUT.mkdir(parents=True, exist_ok=True)
    meshes = {part: checks.one_solid(part)
              for part in ("front", "head", "servo", "rear_mount", "rear_frame")}
    # Independent probes span the suspension floor, connecting steering area,
    # full-height pin spine, rear footprint and rear joint reinforcement.
    probes = {
        "front": [(0, 15, [0, 4]), (10, -10, [0, 4]),
                  (0, -25, [0, 6])],
        "rear_mount": [(0, -25, [0, 4]), (10, -55, [0, 6]),
                       (0, -60.69, [])],
    }
    for part, points in probes.items():
        for x, y, expected in points:
            np.testing.assert_allclose(vertical_hits(meshes[part], x, y),
                                       expected, atol=1e-5,
                                       err_msg=f"{part} mounting floor at {x}, {y}")
    for arm, steering in ((0, 0), (-15, 0), (0, -25), (0, 25)):
        name = f"front-clearance-{arm}-{steering}"
        checks.assert_no_interference(
            checks.export("front_collision", name=name, empty=True,
                          arm_angle=arm, steering_angle=steering), name)
    # The HSP footprint intersects the placeholder arms at +25 degrees.
    # Compare the same pose at both mounting heights to detect added overlap.
    bump = checks.export("front_collision", name="front-bump", empty=True,
                         arm_angle=25)
    reference = checks.export("front_collision", name="front-bump-unrecessed",
                              empty=True, arm_angle=25,
                              suspension_chassis_mount_recess=0)
    bump_volume = 0 if bump is None else abs(bump.volume)
    reference_volume = 0 if reference is None else abs(reference.volume)
    assert bump_volume <= reference_volume + 1e-6, (
        "Recess increases modeled bump overlap", bump_volume, reference_volume)
    print(f"NOTE +25 degree arm pose: {bump_volume:.1f} mm³ modeled overlap; "
          f"unrecessed reference {reference_volume:.1f} mm³. "
          "Physical suspension travel requires verification.")
    checks.assert_no_interference(
        checks.export("rear_collision", empty=True), "rear joint")
    printable = checks.one_solid("front_printable")
    layer = checks.one_solid("front_first_layer")
    np.testing.assert_allclose(printable.bounds[0, 2], 0, atol=1e-6)
    np.testing.assert_allclose(layer.bounds[:, :2],
                               [[-32.15, -33.75], [32.15, 55.8]], atol=1e-5)
    print("PASS 4 mm mounting floors, full-height pin spine, open maintenance hole, "
          "four clear front poses, bump comparison, rear joint clearance "
          "and connected first layer")


if __name__ == "__main__":
    main()
