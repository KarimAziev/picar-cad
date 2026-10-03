"""Module: Ribbon openings, hardware clearance and connected chassis checks.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""

import numpy as np

import check_suspension_mesh as checks


def main() -> None:
    checks.FIXTURE = checks.ROOT / "tests/fixtures/front_ribbon_slots.scad"
    checks.OUT = checks.ROOT / "build/skill-previews/front-ribbon/mesh-checks"
    checks.OUT.mkdir(parents=True, exist_ok=True)
    for orientation in ("wlh", "lwh"):
        for reverse in (False, True):
            params = {"front_rpi_orientation": f'"{orientation}"',
                      "front_rpi_rotate_z_180": reverse}
            case = f"{orientation}-{reverse}"
            frame = checks.one_solid("frame", name=f"frame-{case}", **params)
            baseline = checks.one_solid("baseline", name=f"baseline-{case}", **params)
            np.testing.assert_allclose(frame.bounds, baseline.bounds, atol=1e-5)
            slots = checks.export("slots", name=f"slots-{case}", **params)
            assert slots is not None
            count = 5
            assert len(slots.split()) == count, f"{case}: openings must stay separate"
            np.testing.assert_allclose(slots.volume, count * 20 * 3 * 6, atol=0.01)
            np.testing.assert_allclose(baseline.volume - frame.volume,
                                       slots.volume, atol=0.02)
            for part in ("land", "separation", "servo"):
                checks.assert_no_interference(
                    checks.export(part, name=f"{part}-{case}", empty=True, **params),
                    f"{part}-{case}",
                )
            print(f"PASS {case}: {count} full 20 x 3 mm passages, 1.5 mm hardware "
                  "clearance, 3 mm slot separation and unchanged frame bounds")


if __name__ == "__main__":
    main()
