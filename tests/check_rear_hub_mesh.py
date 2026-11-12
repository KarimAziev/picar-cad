"""Module: Rear hub solid connectivity and mechanical-interface clearances.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""

import numpy as np

import check_suspension_mesh as checks


def main() -> None:
    checks.FIXTURE = checks.ROOT / "tests/fixtures/rear_hub.scad"
    checks.OUT = checks.ROOT / "build/skill-previews/rear-hub-checks"
    checks.OUT.mkdir(parents=True, exist_ok=True)
    hub = checks.one_solid("hub")
    assert hub.bounds[0, 0] < 0, "Camber arm must extend inboard"
    centered = checks.one_solid("hub", name="hub-centered", anchor="[0, 0, 0]")
    np.testing.assert_allclose(centered.bounds - hub.bounds,
                               [[-8, -16.7, -24.05]] * 2, atol=1e-5)
    np.testing.assert_allclose(centered.volume, hub.volume, atol=1e-4)
    for part in ("slot_collision", "blocked_bores", "missing_link_walls"):
        checks.assert_no_interference(checks.export(part, empty=True), part)
        print(f"PASS {part}")


if __name__ == "__main__":
    main()
