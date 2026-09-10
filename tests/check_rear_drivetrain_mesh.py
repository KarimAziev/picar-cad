# /// script
# requires-python = ">=3.11"
# dependencies = ["trimesh>=4,<5", "numpy>=2,<3", "networkx>=3,<4"]
# ///
"""Check rear print solids, drivetrain clearance and top-level joint movement."""
import sys
sys.dont_write_bytecode = True
import numpy as np
import check_suspension_mesh as mesh_check


def main():
    mesh_check.FIXTURE = mesh_check.ROOT / "tests/fixtures/rc_gearbox_mesh.scad"
    mesh_check.OUT = mesh_check.ROOT / "build/skill-previews/gearbox-refinement/mesh-checks"
    mesh_check.OUT.mkdir(parents=True, exist_ok=True)
    housing = mesh_check.one_solid("housing")
    np.testing.assert_allclose(housing.extents, [42, 31.5, 14.75], atol=1e-5)
    np.testing.assert_allclose(housing.bounds.mean(axis=0), [0, 0, 7.375], atol=1e-5)
    centered_housing = mesh_check.one_solid("housing_centered")
    np.testing.assert_allclose(centered_housing.bounds.mean(axis=0), [0, 0, 0], atol=1e-5)
    native = mesh_check.export("native")
    adapter_native = mesh_check.export("adapter_native")
    np.testing.assert_allclose(np.unique(native.vertices, axis=0),
                               np.unique(adapter_native.vertices, axis=0), atol=1e-5)
    np.testing.assert_allclose(native.volume, adapter_native.volume, atol=1e-5)
    print("PASS measured housing dimensions, anchors and inverse vehicle-adapter geometry")
    mesh_check.FIXTURE = mesh_check.ROOT / "tests/fixtures/rear_drivetrain_mesh.scad"
    mesh_check.OUT = mesh_check.ROOT / "build/skill-previews/rear-drivetrain/mesh-checks"
    mesh_check.OUT.mkdir(parents=True, exist_ok=True)
    frame = mesh_check.one_solid("rear")
    carrier = mesh_check.one_solid("carrier")
    motor = mesh_check.export("motor")
    assert motor.is_watertight and motor.is_winding_consistent and motor.volume > 0
    shells = motor.split(only_watertight=False)
    # The measured front-plate bore is an enclosed cavity, not a detached part.
    outer = [s for s in shells if s.volume > 0]
    cavities = [s for s in shells if s.volume < 0]
    assert len(outer) == 1 and len(cavities) == 1
    assert np.all(cavities[0].bounds[0] > outer[0].bounds[0])
    assert np.all(cavities[0].bounds[1] < outer[0].bounds[1])
    print("PASS motor: one exterior solid with the preserved enclosed front-plate bore")
    mesh_check.one_solid("dogbone")
    suspension = mesh_check.one_solid("suspension")
    centered = mesh_check.one_solid("suspension_centered")
    np.testing.assert_allclose(centered.bounds[:, :2].mean(axis=0), [0, 0], atol=1e-6)
    np.testing.assert_allclose(centered.volume, suspension.volume, atol=1e-5)
    cutters = mesh_check.export("suspension_slots")
    # Locked native datum from the user's measured pattern, independent of the
    # production layout functions. This also catches accidental anchor shifts.
    np.testing.assert_allclose(cutters.bounds, [[-20, -64.89, -0.1], [20, 3, 6.1]], atol=1e-5)
    centers = sorted(tuple(np.round(m.bounds[:, :2].mean(axis=0), 5)) for m in cutters.split())
    expected = sorted([(-11, 0), (11, 0), (-17, -15.22), (17, -15.22),
                       (-17, -22.92), (17, -22.92), (-17, -34.02), (17, -34.02),
                       (0, -46.29), (0, -60.69)])
    np.testing.assert_allclose(centers, expected, atol=1e-5)
    print("PASS original measured cutter coordinates and explicit plate anchoring")
    assert abs(frame.bounds[0, 2]) < 1e-6
    assert abs(carrier.bounds[0, 2]) < 1e-6
    first_layer = mesh_check.one_solid("first_layer")
    np.testing.assert_allclose(frame.bounds[:, :2], first_layer.bounds[:, :2], atol=1e-6)
    for part in ("joint_collision", "motor_collision", "shaft_collision",
                 "suspension_collision", "dogbone_collision"):
        collision = mesh_check.export(part, empty=True)
        assert collision is None or abs(collision.volume) < 1e-6, (
            f"{part}: interference volume {collision.volume:.6f} mm³")
        print(f"PASS {part}: no solid interference")
    base = mesh_check.one_solid("placed_rear", name="placed-zero")
    for front, middle, rear in ((10, 0, 0), (0, 10, 0), (0, 0, 10), (10, 20, 15)):
        moved = mesh_check.one_solid("placed_rear", name=f"placed-{front}-{middle}-{rear}",
                                    front_spacing=front, middle_spacing=middle, rear_spacing=rear)
        np.testing.assert_allclose(moved.bounds - base.bounds,
                                   [[0, -front - middle - rear, 0]] * 2, atol=1e-6)
        np.testing.assert_allclose(moved.volume, base.volume, atol=1e-5)
    print("PASS all three joint-spacing controls reach the rear frame")
    carrier_base = mesh_check.one_solid("placed_carrier", name="carrier-assembled")
    carrier_moved = mesh_check.one_solid("placed_carrier", name="carrier-exploded",
                                         rear_spacing=15, motor_spacing=20)
    np.testing.assert_allclose(carrier_moved.bounds - carrier_base.bounds,
                               [[0, 0, 20]] * 2, atol=1e-6)
    print("PASS middle-mounted carrier stays with middle during rear separation and lifts for service")


if __name__ == "__main__":
    main()
