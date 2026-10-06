"""Check supported recesses, bolt floors, and wide-joint reference compatibility.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""

import numpy as np
import trimesh

import check_suspension_mesh as checks


def vertical_hits(mesh: trimesh.Trimesh, x: float, y: float) -> np.ndarray:
    """Return distinct surface heights along a vertical probe line."""
    a, b, c = (mesh.triangles[:, i] for i in range(3))
    det = (b[:, 1] - c[:, 1]) * (a[:, 0] - c[:, 0]) + (
        c[:, 0] - b[:, 0]) * (a[:, 1] - c[:, 1])
    valid = np.abs(det) > 1e-9
    a, b, c, det = a[valid], b[valid], c[valid], det[valid]
    u = ((b[:, 1] - c[:, 1]) * (x - c[:, 0]) +
         (c[:, 0] - b[:, 0]) * (y - c[:, 1])) / det
    v = ((c[:, 1] - a[:, 1]) * (x - c[:, 0]) +
         (a[:, 0] - c[:, 0]) * (y - c[:, 1])) / det
    hit = (u >= -1e-7) & (v >= -1e-7) & (u + v <= 1 + 1e-7)
    z = u * a[:, 2] + v * b[:, 2] + (1 - u - v) * c[:, 2]
    return np.unique(np.round(z[hit], 5))


def main() -> None:
    checks.FIXTURE = checks.ROOT / "tests/fixtures/chassis_joint_bores.scad"
    checks.OUT = checks.ROOT / "build/skill-previews/chassis-joints/checks"
    checks.OUT.mkdir(parents=True, exist_ok=True)
    # Probe the annulus between the through hole and the 6 mm head recess.
    cases = {
        "compact": (14.03939124, [0.0], [-23.0, 23.0]),
        "wide": (14.03939124, [-37.85, 0.0, 37.85], [-75.7, 75.7]),
        "rear": (10.0, [-30.25, 0.0, 30.25], [-60.5, 60.5]),
        "head": (7.3, [], [-24.725, 24.725]),
    }
    for joint, (length, top_xs, side_xs) in cases.items():
        options = {"joint": f'"{joint}"'}
        male = checks.one_solid("male", name=f"{joint}-male", **options)
        female = checks.one_solid("female", name=f"{joint}-female", **options)
        y = -length / 2 + 2.2
        for x in top_xs:
            np.testing.assert_allclose(vertical_hits(male, x, y), [1.55, 3.05], atol=1e-5)
        for x in side_xs:
            np.testing.assert_allclose(vertical_hits(male, x, y), [4.5, 6], atol=1e-5)
            countersunk = joint in ("compact", "head")
            floor = (3.05 - 2.2) / (3.05 - 1.5) * 1.95 if countersunk else 2.8
            np.testing.assert_allclose(vertical_hits(female, x, y), [floor, 4.3], atol=1e-5)
            if countersunk:
                for radius in (1.6, 2.8, 3.1):
                    floor = max(0, (3.05 - radius) / (3.05 - 1.5) * 1.95)
                    np.testing.assert_allclose(
                        vertical_hits(female, x, -length / 2 + radius),
                        [floor, 4.3], atol=1e-5)
        checks.assert_no_interference(
            checks.export("collision", name=f"{joint}-collision", empty=True, **options),
            joint)
        if joint == "wide":
            checks.assert_no_interference(
                checks.export("nominal_collision", name=f"{joint}-nominal-fit",
                              empty=True, **options), joint)
            checks.assert_no_interference(
                checks.export("nominal_difference", name=f"{joint}-nominal-difference",
                              empty=True, suspension_chassis_joint_counterbores=False,
                              **options), joint)
        print(f"PASS {joint}: supported bore depths, intact thin skins, mating fit")
    for bore_h, sink_h, expected_floor in ((2.0, 1.95, 2.0), (3.3, 3.0, 0.0)):
        female = checks.one_solid(
            "female", name=f"compact-recess-{bore_h}-{sink_h}", joint='"compact"',
            chassis_counterbore_h=bore_h, chassis_countersunk_bore_h=sink_h)
        np.testing.assert_allclose(vertical_hits(female, 23, -14.03939124 / 2 + 2.2),
                                   [expected_floor, 4.3], atol=1e-5)
    print("PASS full counterbore selection and omission of unsupported countersinks")
    print("PASS 0.2 mm sockets mate with the 0.4 mm wide-joint reference; "
          "nominal male profiles and hole patterns match")


if __name__ == "__main__":
    main()
