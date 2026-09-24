"""Geometry-only checks for the steering characterization tools."""

import math
import unittest

from steering_characterization import (
    CenterGeometry,
    center_sweep,
    circle_rod_angles,
    nearest_branch,
    rotate_z,
)


class RevoluteRodTests(unittest.TestCase):
    def test_both_roots_close_a_spatial_rod(self) -> None:
        pivot = [3, -4, 7]
        radial = [12, 5, 2]
        target = [25, -8, 16]
        length = 20
        roots = circle_rod_angles(pivot, radial, target, length)
        if roots is None:
            self.fail("Expected a reachable rod constraint")
        for angle in roots:
            endpoint = [a + b for a, b in zip(pivot, rotate_z(radial, angle))]
            self.assertAlmostEqual(math.dist(endpoint, target), length, places=10)

    def test_known_circle_intersection(self) -> None:
        roots = circle_rod_angles([0, 0, 0], [1, 0, 0], [1, 0, 0], 1)
        if roots is None:
            self.fail("Expected a reachable rod constraint")
        self.assertAlmostEqual(roots[0], -math.pi / 3)
        self.assertAlmostEqual(roots[1], math.pi / 3)

    def test_unreachable_constraints(self) -> None:
        for target, length in (([5, 0, 0], 1), ([1, 0, 0], 3), ([1, 0, 3], 1)):
            with self.subTest(target=target, length=length):
                self.assertIsNone(circle_rod_angles([0, 0, 0], [1, 0, 0], target, length))

    def test_tangent_has_one_repeated_root(self) -> None:
        roots = circle_rod_angles([0, 0, 0], [1, 0, 0], [2, 0, 0], 1)
        if roots is None:
            self.fail("Expected a reachable rod constraint")
        self.assertAlmostEqual(roots[0], roots[1])
        self.assertAlmostEqual(roots[0], 0)

    def test_roundoff_near_tangent_is_clamped(self) -> None:
        roots = circle_rod_angles([0, 0, 0], [1, 0, 0], [2 + 1e-10, 0, 0], 1)
        if roots is None:
            self.fail("Tangent within tolerance should remain reachable")
        self.assertEqual(roots, (0.0, 0.0))

    def test_rotation_preserves_height_and_radius(self) -> None:
        rotated = rotate_z([3, 4, 7], math.pi / 2)
        for actual, expected in zip(rotated, [-4, 3, 7], strict=True):
            self.assertAlmostEqual(actual, expected)
        self.assertAlmostEqual(math.hypot(*rotated[:2]), 5)

    def test_degenerate_is_not_an_invented_solution(self) -> None:
        with self.assertRaisesRegex(ValueError, "Degenerate circle constraint"):
            circle_rod_angles([0, 0, 0], [1, 0, 0], [0, 0, 0], 1)

    def test_branch_continuity_across_pi(self) -> None:
        previous = math.radians(179)
        result = nearest_branch([math.radians(-179), 0], previous)
        self.assertAlmostEqual(math.degrees(result), 181)

    def test_branch_continuity_across_negative_pi(self) -> None:
        result = nearest_branch([math.radians(179), 0], math.radians(-179))
        self.assertAlmostEqual(math.degrees(result), -181)

    def test_unreachable_sweep_reports_drive_angle(self) -> None:
        data: CenterGeometry = {
            "bellcrank_pivots": [[-25, 0, 0], [25, 0, 0]],
            "center_mounts": [[-25, 12, 3], [25, 12, 3]],
            "center_link_l": 1,
        }
        with self.assertRaisesRegex(ValueError, "unreachable at drive rotation 0"):
            center_sweep(data)

    def test_exact_parallelogram(self) -> None:
        data: CenterGeometry = {
            "bellcrank_pivots": [[-25, 0, 0], [25, 0, 0]],
            "center_mounts": [[-25, 12, 3], [25, 12, 3]],
            "center_link_l": 50,
        }
        rows = center_sweep(data)
        self.assertEqual([row[0] for row in rows], list(range(-25, 26)))
        for drive, idler, residual in rows:
            self.assertAlmostEqual(drive, idler, places=10)
            self.assertAlmostEqual(residual, 0, places=10)

    def test_unequal_pitch_changes_idler_not_link_length(self) -> None:
        data: CenterGeometry = {
            "bellcrank_pivots": [[-24.4, 0, 0], [24.4, 0, 0]],
            "center_mounts": [[-24.4, 12.15, 13.1], [24.4, 12.15, 13.1]],
            "center_link_l": 48.7,
        }
        rows = center_sweep(data)
        self.assertEqual(len(rows), 51)
        self.assertAlmostEqual(rows[25][1], 0.471575534171, places=9)
        self.assertTrue(all(abs(row[2]) < 1e-10 for row in rows))
        # Reconstruct endpoints independently instead of trusting reported residuals.
        for drive, idler, _ in rows:
            with self.subTest(drive=drive):
                drive_angle, idler_angle = math.radians(drive), math.radians(idler)
                left = [-24.4 - 12.15 * math.sin(drive_angle),
                        12.15 * math.cos(drive_angle), 13.1]
                right = [24.4 - 12.15 * math.sin(idler_angle),
                         12.15 * math.cos(idler_angle), 13.1]
                self.assertAlmostEqual(math.dist(left, right), 48.7, places=10)


if __name__ == "__main__":
    unittest.main()
