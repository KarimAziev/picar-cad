"""Nominal steering closure audit; no hardware control or app calibration writes.

Run: python3 tests/steering_characterization.py
Consumes evaluated OpenSCAD dimensions rather than copying hardware constants.
The CSV solves only the rigid center-bar loop, not servo-to-road-wheel steering.
"""

import argparse
import ast
import csv
import json
import math
import subprocess
from collections.abc import Sequence
from pathlib import Path
from typing import TypedDict

from scad_test_support import OPENSCAD, echo_value

ROOT = Path(__file__).resolve().parents[1]


class CenterGeometry(TypedDict):
    """Pivot and mounting coordinates plus the rigid center bar's hole pitch."""

    bellcrank_pivots: Sequence[Sequence[float]]
    center_mounts: Sequence[Sequence[float]]
    center_link_l: float


def circle_rod_angles(
    pivot: Sequence[float],
    radial: Sequence[float],
    target: Sequence[float],
    length: float,
    *,
    tolerance: float = 1e-9,
) -> tuple[float, float] | None:
    """Solve a Z-axis revolute joint joined by a fixed 3D rod to target.

    Return both absolute rotations of radial, in radians. None means unreachable.
    A degenerate unconstrained circle raises ValueError rather than inventing an angle.
    """
    dx, dy, dz = (target[i] - pivot[i] for i in range(3))
    x, y, z = radial
    a, b = dx * x + dy * y, -dx * y + dy * x
    c = (dx * dx + dy * dy + (dz - z) ** 2 + x * x + y * y - length * length) / 2
    amplitude = math.hypot(a, b)
    if amplitude < tolerance:
        raise ValueError("Degenerate circle constraint")
    ratio = c / amplitude
    if abs(ratio) > 1 + tolerance:
        return None
    phase = math.atan2(b, a)
    delta = math.acos(max(-1.0, min(1.0, ratio)))
    return (phase - delta, phase + delta)


def rotate_z(p: Sequence[float], angle: float) -> list[float]:
    c, s = math.cos(angle), math.sin(angle)
    return [c * p[0] - s * p[1], s * p[0] + c * p[1], p[2]]


def nearest_branch(roots: Sequence[float], previous: float) -> float:
    candidates = [
        previous + math.atan2(math.sin(r - previous), math.cos(r - previous))
        for r in roots
    ]
    return min(candidates, key=lambda r: abs(r - previous))


def extract(out: Path):
    result = subprocess.run(
        [
            OPENSCAD,
            "--backend=Manifold",
            "--enable=textmetrics",
            "--enable=roof",
            "--hardwarnings",
            "-o",
            str(out / "datums.csg"),
            str(ROOT / "scad/suspension/steering_characterization/datums.scad"),
        ],
        capture_output=True,
        text=True,
        check=True,
    )
    log = result.stdout + result.stderr
    if "WARNING:" in log or "ERROR:" in log:
        raise RuntimeError(log)
    items = ast.literal_eval(echo_value(log, "steering_audit"))
    return dict(zip(items[::2], items[1::2]))


def audit(data):
    wheels = []
    for side in range(2):
        a, b = data["wheel_rod_a"][side], data["wheel_rod_b"][side]
        target = data["outer_mounts"][side]
        holes = data["knuckle_holes"][side]
        wheels.append(
            {
                "side": "negative_x" if side == 0 else "positive_x",
                "rod_center_length_mm": math.dist(a, b),
                "minimum_mount_distance_xy_mm": math.dist(holes[0][:2], target[:2]),
                "inner_endpoint_axis_gap_xy_mm": math.dist(b[:2], target[:2]),
                "outer_endpoint_nearest_hole_gap_xy_mm": min(
                    math.dist(a[:2], p[:2]) for p in holes
                ),
                "note": "First knuckle hole is the nearest modeled attachment; ball stack heights unconfirmed.",
            }
        )
    return {
        "status": "NEUTRAL_CLOSURE_UNCONFIRMED_NOT_A_CALIBRATION",
        "center_plate_pitch_mm": data["center_link_l"],
        "bellcrank_pivot_pitch_mm": math.dist(*data["bellcrank_pivots"]),
        "center_plate_axis_gaps_xy_mm": [
            math.dist(a[:2], b[:2])
            for a, b in zip(data["center_mounts"], data["center_plate_holes"])
        ],
        "servo_rod_center_length_mm": math.dist(
            data["servo_rod_a"], data["servo_rod_b"]
        ),
        "servo_endpoint_nearest_hole_gap_xy_mm": min(
            math.dist(data["servo_rod_b"][:2], p[:2]) for p in data["servo_lever_holes"]
        ),
        "wheel_rods": wheels,
        "missing": [
            "Installed rod ball-center lengths and selected holes",
            "Ball-center heights relative to the lever faces",
            "Confirmed steering axes, wheel centers, wheelbase and static toe",
            "Suspension travel and joint articulation/clearance limits",
        ],
    }


def center_sweep(data: CenterGeometry) -> list[tuple[int, float, float]]:
    """Solve ideal pins with modeled pitch, following the near-parallel branch.

    Angles are physical CCW bellcrank rotations, NOT servo command angles.
    Start at zero and continue separately toward either lock to avoid branch jumps.
    """
    left, right = data["bellcrank_pivots"]
    arms = [
        [p[i] - pivot[i] for i in range(3)]
        for p, pivot in zip(data["center_mounts"], (left, right))
    ]
    rows: dict[int, tuple[int, float, float]] = {}
    for direction in (-1, 1):
        previous = 0.0
        for step in range(26):
            degrees = direction * step
            rotated = rotate_z(arms[0], math.radians(degrees))
            target = [left[i] + rotated[i] for i in range(3)]
            roots = circle_rod_angles(right, arms[1], target, data["center_link_l"])
            if roots is None:
                raise ValueError(f"Center bar unreachable at drive rotation {degrees}")
            angle = nearest_branch(roots, previous)
            endpoint = [right[i] + rotate_z(arms[1], angle)[i] for i in range(3)]
            residual = math.dist(target, endpoint) - data["center_link_l"]
            rows[degrees] = (degrees, math.degrees(angle), residual)
            previous = angle
    return [rows[key] for key in sorted(rows)]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--out", type=Path, default=ROOT / "build/steering-characterization"
    )
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=True)
    data = extract(out)
    report = audit(data)
    (out / "datums.json").write_text(json.dumps(data, indent=2) + "\n")
    (out / "neutral-audit.json").write_text(json.dumps(report, indent=2) + "\n")
    with (out / "center-bar-only-sweep.csv").open("w", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(["drive_ccw_deg", "idler_ccw_deg", "rod_length_residual_mm"])
        writer.writerows(center_sweep({
            "bellcrank_pivots": data["bellcrank_pivots"],
            "center_mounts": data["center_mounts"],
            "center_link_l": data["center_link_l"],
        }))
    print(json.dumps(report, indent=2))
    print(f"Outputs: {out}")
    print(
        "No servo-to-wheel curve or Ackermann percentage exported: neutral closure requires confirmation."
    )


if __name__ == "__main__":
    main()
