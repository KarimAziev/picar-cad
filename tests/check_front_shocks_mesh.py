"""Module: Front shock mounting bore and assembled clearance checks.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""
import check_suspension_mesh as checks


def main() -> None:
    checks.FIXTURE = checks.ROOT / "tests/fixtures/front_shocks.scad"
    checks.OUT = checks.ROOT / "build/skill-previews/front-shock-checks"
    checks.OUT.mkdir(parents=True, exist_ok=True)
    for solved, angle in ((False, 0), (True, -5), (True, 5)):
        for part in ("blocked_mount_bores", "shock_structure_collision",
                     "fastener_structure_collision"):
            name = f"{part}-{solved}-{angle}"
            mesh = checks.export(part, name=name, empty=True,
                                 solved=solved, arm_angle=angle)
            if part == "fastener_structure_collision" and mesh is not None:
                # Nominal M3 shanks touch the 3 mm arm bores. Polygonal contact
                # leaves approximately 1e-5 mm³ of CSG slivers across both arms.
                contact_volume_tolerance = 1e-4
                assert abs(mesh.volume) < contact_volume_tolerance, (name, mesh.volume)
            else:
                checks.assert_no_interference(mesh, name)
            print(f"PASS {name}", flush=True)


if __name__ == "__main__":
    main()
