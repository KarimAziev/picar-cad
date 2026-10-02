"""Verify joint centers through evaluated production CSG transforms.

Markers are inserted in temporary source copies at the actual ball, socket and
hole primitives. This checks assembly placement independently of solver datums.
No source in scad/ is modified and no mesh tessellation is needed.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""

import ast
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import numpy as np

from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]
TAGS = {0.123456: "rod", 0.234567: "hole", 0.345678: "lever",
        0.456789: "ball", 0.567891: "socket", 0.678912: "hinge"}


def instrument(root: Path, name: str, old: str, new: str) -> None:
    path = root / "scad" / name
    source = path.read_text()
    assert source.count(old) == 1, (name, "marker insertion point changed")
    path.write_text(source.replace(old, new))


def markers(path: Path) -> dict:
    stack = [np.eye(4)]
    points = {name: [] for name in TAGS.values()}
    for line in path.read_text().splitlines():
        text = line.strip()
        if text.endswith("{"):
            matrix = stack[-1].copy()
            if text.startswith("multmatrix("):
                matrix = matrix @ np.array(ast.literal_eval(text[11:text.rfind(")")]))
            stack.append(matrix)
        elif text == "}":
            stack.pop()
        elif text.startswith("sphere("):
            match = re.search(r"\br = ([0-9.]+)", text)
            if match and float(match[1]) in TAGS:
                points[TAGS[float(match[1])]].append(
                    (stack[-1][:3, 3].copy(), stack[-1][:3, 2].copy()))
    assert len(stack) == 1
    return points


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="picar-front-linkage-") as temporary:
        root = Path(temporary)
        shutil.copytree(ROOT / "scad", root / "scad")
        instrument(root, "placeholders/ball_stud.scad",
                   "        difference() {",
                   "        sphere(r=0.456789, $fn=8);\n        difference() {")
        instrument(root, "suspension/knuckle/knuckle_bushing.scad",
                   "          sphere(d=bushing_d, $fn=fn);",
                   "          sphere(d=bushing_d, $fn=fn);\n"
                   "          sphere(r=0.567891, $fn=8);")
        instrument(root, "placeholders/tie_rod_end.scad",
                   "            tie_rod_spherical_bushing(h=bushing_h,",
                   "            sphere(r=0.123456, $fn=8);\n"
                   "            tie_rod_spherical_bushing(h=bushing_h,")
        instrument(root, "suspension/knuckle/knuckle_steering_arm.scad",
                   "            circle(d=bolt_d, $fn=fn);",
                   "            circle(d=bolt_d, $fn=fn);\n"
                   "            sphere(r=0.234567, $fn=8);")
        instrument(root, "suspension/bellcrank/bellcrank_lever.scad",
                   "      translate([bolt_holes_x, 0, 0]) {",
                   "      translate([bolt_holes_x, 0, 0]) {\n"
                   "        sphere(r=0.345678, $fn=8);")
        instrument(root, "suspension/wishbone_arms/barrel_hinge.scad",
                   "            circle(r=hole_r, $fn=$preview ? 20 : 360);",
                   "            circle(r=hole_r, $fn=$preview ? 20 : 360);\n"
                   "            sphere(r=0.678912, $fn=8);")
        # The real component entry, using its explicit diagnostic controls.
        entry = root / "scad/suspension/steering_characterization/articulated.scad"
        reference_hinges = None
        for angle, steering, hole in ((0, 0, 0), (10, 0, 0), (25, 15, 0), (-15, -15, 1)):
            csg = root / "pose.csg"
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--enable=roof",
                 "--hardwarnings", "-o", str(csg), "-D", f"lower_arm_angle={angle}",
                 "-D", f"bellcrank_angle={steering}", "-D", f"steering_hole={hole}",
                 str(entry)], capture_output=True, text=True)
            log = result.stdout + result.stderr
            assert result.returncode == 0 and "WARNING:" not in log and "ERROR:" not in log, log
            m = markers(csg)
            assert len(m["ball"]) == len(m["socket"]) == len(m["rod"]) == len(m["hole"]) == 4
            assert len(m["lever"]) == 2
            # OpenSCAD CSG matrices are rounded; this is a numerical tolerance,
            # not a claim about printer or physical measurement accuracy.
            tolerance = 0.001
            for ball, _ in m["ball"]:
                assert min(np.linalg.norm(ball - socket) for socket, _ in m["socket"]) < tolerance
            # Faces and axes are taken from the actual hole cutter primitives.
            targets = [(p - n * 5.2, n) for p, n in m["hole"][hole::2] + m["lever"]]
            remaining = list(targets)
            for ball, axis in m["rod"]:
                closest = min(range(len(remaining)), key=lambda i: np.linalg.norm(ball - remaining[i][0]))
                point, normal = remaining.pop(closest)
                assert np.linalg.norm(ball - point) < tolerance, (angle, steering, ball, point)
                assert abs(abs(axis @ normal) - 1) < tolerance, (axis, normal)
            for side in (-1, 1):
                balls = [p for p, _ in m["rod"] if p[0] * side > 0]
                assert len(balls) == 2
                assert abs(np.linalg.norm(balls[0] - balls[1]) - 39.7) < tolerance
            # Arm hinge X/Z axes must remain fixed while arm endpoints move.
            hinges = np.array([p[[0, 2]] for p, _ in m["hinge"]])
            if reference_hinges is None:
                reference_hinges = hinges
            else:
                np.testing.assert_allclose(hinges, reference_hinges, atol=tolerance)
            print(f"PASS lower={angle}, bellcrank={steering}, hole={hole}: "
                  "four seated suspension balls, both rods connected at fixed length, "
                  "aligned bushing axes and stationary hinges", flush=True)


if __name__ == "__main__":
    main()
