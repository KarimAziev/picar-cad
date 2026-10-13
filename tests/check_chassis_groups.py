"""Verify printable chassis groups, continuous joints and fixed outer bounds.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""
import numpy as np

import check_suspension_mesh as checks


def main() -> None:
    checks.FIXTURE = checks.ROOT / "scad/suspension/chassis_printable.scad"
    checks.OUT = checks.ROOT / "build/skill-previews/chassis-groups/mesh-checks"
    checks.OUT.mkdir(parents=True, exist_ok=True)
    flags = ("split_head_chassis", "split_front_chassis",
             "split_rear_chassis", "split_rear_suspension")
    # Every detachable section, each individual union, both requested long
    # groups, and the complete chassis exercise all four boundary types.
    groups = [(i, i) for i in range(5)] + [(i, i + 1) for i in range(4)]
    groups += [(1, 3), (0, 4)]
    separate = []
    for first, last in groups:
        options = {flag: not first <= i < last for i, flag in enumerate(flags)}
        mesh = checks.one_solid("group", name=f"group-{first}-{last}",
                                chassis_print_section=first, **options)
        assert abs(mesh.bounds[0, 2]) < 1e-6, "Printable must rest on Z=0"
        if first == last:
            separate.append(mesh)
        else:
            expected = np.array([
                np.min([m.bounds[0] for m in separate[first:last + 1]], axis=0),
                np.max([m.bounds[1] for m in separate[first:last + 1]], axis=0),
            ])
            np.testing.assert_allclose(mesh.bounds, expected, atol=1e-5)
            assert mesh.volume > sum(m.volume for m in separate[first:last + 1]), (
                first, last, "Merged joints must restore material")
    print("PASS chassis groups: watertight, connected, bed contact and fixed envelope")


if __name__ == "__main__":
    main()
