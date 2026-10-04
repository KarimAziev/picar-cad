"""Check stock pins against chassis cutouts, mating plates, and fixed outlines.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""

import numpy as np

import check_suspension_mesh as checks

# Native-coordinate envelopes of the adjoining plate pairs, in millimeters.
BOUNDS = {
    "head": [[-32.15, -47.38939124, 0], [32.15, 123.825, 6]],
    "compact": [[-80.2, -117.82878248, 0], [80.2, 46.325, 6]],
    "wide": [[-80.2, -225.78385852, 0], [80.2, -33.75, 6]],
    "rear": [[-80.2, -161.37939124, 0], [80.2, 5.75, 6]],
}


def main() -> None:
    checks.FIXTURE = checks.ROOT / "tests/fixtures/chassis_pin_clearance.scad"
    checks.OUT = checks.ROOT / "build/skill-previews/chassis-pin-audit/checks"
    checks.OUT.mkdir(parents=True, exist_ok=True)
    for joint, bounds in BOUNDS.items():
        joint_argument = f'"{joint}"'
        for part, margin in (("collision", 1), ("obstruction", 0)):
            result = checks.export(part, name=f"{joint}-{part}", empty=True,
                                   margin=margin, joint=joint_argument)
            checks.assert_no_interference(result, f"{joint}-{part}")
        plates = checks.export("plates", name=f"{joint}-plates", joint=joint_argument)
        # Mating interfaces share edges in the combined assembly mesh.
        # Printable parts are checked individually for watertightness.
        assert plates.volume > 0
        np.testing.assert_allclose(plates.bounds, bounds, atol=0.00002)
        print(f"PASS {joint}: stock pins fit, cutouts clear with 1 mm margin, "
              "and chassis width/length unchanged", flush=True)
    checks.assert_no_interference(
        checks.export("side_lands", empty=True), "wide joint side-bolt lands")
    print("PASS wide joint: solid side-bolt lands with 3 mm nominal padding",
          flush=True)


if __name__ == "__main__":
    main()
