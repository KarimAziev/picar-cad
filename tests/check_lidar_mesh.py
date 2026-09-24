# /// script
# requires-python = ">=3.11"
# dependencies = ["trimesh>=4,<5", "numpy>=2,<3", "networkx>=3,<4"]
# ///
"""Verify C1 underside holes, depth, body connectivity and anchor behavior."""
import sys
sys.dont_write_bytecode = True
import numpy as np
import check_suspension_mesh as check


def main() -> None:
    check.FIXTURE = check.ROOT / "tests/fixtures/lidar_mesh.scad"
    check.OUT = check.ROOT / "build/skill-previews/lidar-review/mesh-checks"
    check.OUT.mkdir(parents=True, exist_ok=True)
    body = check.one_solid("body")
    solid = check.one_solid("solid")
    np.testing.assert_allclose(body.bounds, [[-27.8, -27.8, 0], [27.8, 27.8, 41.3]], atol=1e-5)
    holes = check.export("holes")
    centers = sorted(tuple(np.round(m.bounds.mean(axis=0), 6)) for m in holes.split())
    assert centers == [(-21.5, -21.5, 2), (-21.5, 21.5, 2),
                       (21.5, -21.5, 2), (21.5, 21.5, 2)], centers
    np.testing.assert_allclose(solid.volume - body.volume, holes.volume, atol=1e-5)
    end = check.export("blind_end")
    np.testing.assert_allclose(end.volume, holes.volume * 0.2 / 4, atol=1e-5)
    anchored = check.one_solid("anchor")
    np.testing.assert_allclose(anchored.bounds - body.bounds,
                               [[-27.8, -27.8, -20.65]] * 2, atol=1e-5)
    base_anchored = check.one_solid("base_anchor")
    np.testing.assert_allclose(base_anchored.bounds - body.bounds,
                               [[-27.8, -27.8, -11.55]] * 2, atol=1e-5)
    print("PASS: four underside holes at +/-21.5 mm, exactly 4 mm deep; correct anchors")


if __name__ == "__main__":
    main()
