"""Module: Rear axle printability, mounting support and assembled clearances.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""

import check_suspension_mesh as checks


def main() -> None:
    checks.FIXTURE = checks.ROOT / "tests/fixtures/rear_axle_structure.scad"
    checks.OUT = checks.ROOT / "build/skill-previews/rear-axle-structure-checks"
    checks.OUT.mkdir(parents=True, exist_ok=True)
    for path in checks.OUT.glob("*.stl"):
        path.unlink()

    for part in ("lower", "lid", "tower"):
        checks.one_solid(part)

    # A 1 mm radial annulus must remain around each fastener throughout the
    # plate or mounting-foot floor. This detects holes opening into relief
    # windows and mounting feet clipped by an insufficient housing envelope.
    for part in ("missing_tower_lands", "missing_mount_lands", "missing_nut_walls"):
        checks.assert_no_interference(checks.export(part, empty=True), part)
        print(f"PASS {part}: all required fasteners have surrounding material")

    checks.assert_no_interference(
        checks.export("missing_crown_roof", empty=True), "missing_crown_roof"
    )
    print("PASS missing_crown_roof: continuous roof above the pinion mesh opening")

    # Assembly intersections use the neutral ride-height placement.
    for part in ("blocked_tower_holes", "blocked_nut_insertion", "split_collision",
                 "housing_arm_collision", "arm_hub_collision", "link_shock_collision",
                 "hub_shock_collision", "hub_link_collision",
                 "fastener_housing_collision", "chassis_axle_collision",
                 "wheel_shaft_collision"):
        checks.assert_no_interference(checks.export(part, empty=True), part)
        print(f"PASS {part}: printed parts have no positive-volume intersection")


if __name__ == "__main__":
    main()
