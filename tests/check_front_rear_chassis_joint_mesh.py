"""Check the assembled front/rear chassis connection without extending the deck.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""

import numpy as np

import check_suspension_mesh as checks


def main() -> None:
    checks.FIXTURE = checks.ROOT / "tests/fixtures/front_rear_chassis_joint.scad"
    checks.OUT = checks.ROOT / "build/skill-previews/chassis-connection/mesh-checks"
    checks.OUT.mkdir(parents=True, exist_ok=True)
    for extra_width in (0, 20):
        options = {"extra_width": extra_width}
        front = checks.one_solid("front", name=f"front-{extra_width}", **options)
        rear = checks.one_solid("rear", name=f"rear-{extra_width}", **options)
        flat = checks.one_solid("rear_flat", name=f"rear-flat-{extra_width}", **options)
        np.testing.assert_allclose(front.extents[0], rear.extents[0], atol=1e-5)
        assert rear.bounds[0, 1] < front.bounds[0, 1] < rear.bounds[1, 1]
        assert rear.bounds[1, 1] < front.bounds[1, 1]
        # The added tongue stays within the front's existing socket envelope.
        # Both assembled outer bounds and the rear deck's far end stay fixed.
        np.testing.assert_allclose(rear.bounds[0], flat.bounds[0], atol=1e-5)
        np.testing.assert_allclose(np.maximum(front.bounds[1], rear.bounds[1]),
                                   np.maximum(front.bounds[1], flat.bounds[1]), atol=1e-5)
        for part in ("collision", "pin_obstruction", "bolt_obstruction"):
            mesh = checks.export(part, name=f"{part}-{extra_width}",
                                 empty=True, **options)
            checks.assert_no_interference(mesh, part)
        land = checks.one_solid("root_land", name=f"root-land-{extra_width}", **options)
        np.testing.assert_allclose(land.volume, 0.05, atol=1e-6)
        shifted = checks.one_solid("rear", name=f"rear-spaced-{extra_width}",
                                   spacing=20, **options)
        np.testing.assert_allclose(shifted.bounds - rear.bounds,
                                   [[0, -20, 0]] * 2, atol=2e-5)
        np.testing.assert_allclose(shifted.volume, rear.volume, rtol=1e-6)
        print(f"PASS width +{extra_width}: matching frames, connected tongue, "
              "fixed chassis length, no interference, open bolts/pins and rigid separation")

    checks.FIXTURE = (checks.ROOT / "scad/suspension/rear_chassis"
                      / "rear_chassis_frame_printable.scad")
    printable = checks.one_solid("printable")
    np.testing.assert_allclose(printable.bounds[0, 2], 0, atol=1e-6)
    print("PASS rear frame printable: one solid resting on Z=0")


if __name__ == "__main__":
    main()
