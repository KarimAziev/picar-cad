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
            # Rounded rectangle area, including the 40-sided corner tessellation.
            radius = 0.6
            slot_area = 20 * 3 - 4 * radius**2 + 20 * radius**2 * np.sin(np.pi / 20)
            np.testing.assert_allclose(slots.volume, count * slot_area * 6, atol=0.01)
            np.testing.assert_allclose(baseline.volume - frame.volume,
                                       slots.volume, atol=0.02)
            for part in ("land", "separation", "servo", "wiring_land"):
                checks.assert_no_interference(
                    checks.export(part, name=f"{part}-{case}", empty=True, **params),
                    f"{part}-{case}",
                )
            # Boolean subtraction can retain coplanar, zero-volume shells.
            removed = checks.export("wiring", name=f"wiring-{case}", **params)
            assert removed is not None
            solids = [shell for shell in removed.split(only_watertight=False)
                      if abs(shell.volume) > 1e-6]
            assert len(solids) == 1, f"{case}: expected one wiring passage"
            wiring = solids[0]
            assert wiring.is_watertight and wiring.is_winding_consistent
            np.testing.assert_allclose(wiring.extents, [14, 14, 6], atol=1e-5)
            np.testing.assert_allclose(wiring.volume,
                                       40 * 7**2 * np.sin(np.pi / 40) * 6,
                                       atol=0.01)
            print(f"PASS {case}: {count} full 20 x 3 mm passages, 1.5 mm hardware "
                  "clearance, rounded corners, a 14 mm wiring passage and intact frame bounds")


if __name__ == "__main__":
    main()
