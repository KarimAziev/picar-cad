"""Check percentage equivalence and rendered anchor bounds for shape helpers.

Run: python3 tests/check_shape_helpers.py
Requires OpenSCAD with Manifold, textmetrics and roof support.
"""

import itertools
from pathlib import Path
import struct
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]
HEADER = f"""use <{ROOT}/scad/lib/shapes2d.scad>
use <{ROOT}/scad/lib/shapes3d.scad>
$fn=32;
"""


def render(folder, name, source, extension):
    scad = folder / f"{name}.scad"
    output = folder / f"{name}.{extension}"
    scad.write_text(HEADER + source)
    command = ["openscad", "--backend=Manifold", "--enable=textmetrics",
               "--enable=roof", "--hardwarnings"]
    if extension == "stl":
        command += ["--export-format", "binstl"]
    result = subprocess.run(command + ["-o", str(output), str(scad)],
                            capture_output=True, text=True)
    log = result.stdout + result.stderr
    assert result.returncode == 0 and "WARNING:" not in log and "ERROR:" not in log, log
    return output


def check_percentages(folder):
    # Each string is compared with an independently specified absolute value.
    cases = [
        ('chamfered_cube([20,30,10], chamfer=VALUE);', '"10%"', '1'),
        ('chamfered_cube([20,30,10], chamfer=VALUE, ignore_sides=["right"]);',
         '"10%"', '1'),
        ('y_chamfered_cube([2,30,10], chamfer=VALUE);', '"10%"', '1'),
        ('chamfered_square(20, chamfer=VALUE);', '"25%"', '5'),
        ('chamfered_rect([10,40], chamfer=VALUE);', '"10%"', '1'),
        ('rounded_rect([40,20], r=VALUE);', '"10%"', '2'),
        ('rounded_rect_two([40,20], r=VALUE, side="top_left");', '"10%"', '2'),
        ('rounded_rect([40,20], r=VALUE);', '"100%"', '10'),
        ('cuboid([40,20,10], r=VALUE);', '"10%"', '2'),
        ('cuboid([40,20,10], r=VALUE, use_minkowski=true);', '"10%"', '1'),
        ('cuboid([40,20,10], r=VALUE);', '"0%"', '0'),
        ('rect_border([20,30], border_w=VALUE, inner=false);', '"10%"', '2'),
        ('rect_border([20,30], r=VALUE, inner=false);', '"5%"', '1'),
        ('cube_border([20,30], h=6, border_w=VALUE, inner=false);', '"10%"', '2'),
        ('cube_border([20,30,6], r=VALUE, inner=false);', '"5%"', '1'),
        ('rounded_rect_recess([20,30], [24,34], r=VALUE, thickness=6);',
         '"10%"', '2'),
        ('tapered_box([20,30], [10,20], h=10, r_top=VALUE, r_bottom=2);',
         '"10%"', '1'),
        ('tapered_box([20,30], [10,20], h=10, r_top=1, r_bottom=VALUE);',
         '"10%"', '2'),
    ]
    for i, (call, percent, absolute) in enumerate(cases):
        actual = render(folder, f"percent-{i}", call.replace("VALUE", percent), "csg")
        expected = render(folder, f"absolute-{i}", call.replace("VALUE", absolute), "csg")
        assert actual.read_bytes() == expected.read_bytes(), (call, percent, absolute)
    print(f"PASS: {len(cases)} percentage calls match their absolute equivalents", flush=True)


def vertices(path):
    data = path.read_bytes()
    count = struct.unpack_from("<I", data, 80)[0]
    assert len(data) == 84 + 50 * count
    for i in range(count):
        coords = struct.unpack_from("<12f", data, 84 + 50 * i)[3:]
        for j in (0, 3, 6):
            yield coords[j:j + 3]


def scad_anchor(anchor):
    if anchor is None:
        return "undef"
    return "[" + ",".join("undef" if a is None else str(a) for a in anchor) + "]"


def check_anchors(folder):
    # Reference dimensions and actual unanchored bounds are deliberately
    # separate: outward borders, deep recesses and lower_chamfer overhang them.
    cases = [
        ("chamfer", 'chamfered_cube([20,30,10], chamfer=2, anchor=ANCHOR);',
         [20,30,10], [0,0,0], [20,30,10]),
        ("y_chamfer", 'y_chamfered_cube([20,30,10], chamfer=2, anchor=ANCHOR);',
         [20,30,10], [0,0,0], [20,30,10]),
        ("lower_chamfer", 'chamfered_cube([20,30,10], chamfer=2, lower_chamfer=true, anchor=ANCHOR);',
         [20,30,10], [0,0,-2], [20,30,8]),
        ("y_lower_chamfer", 'y_chamfered_cube([20,30,10], chamfer=2, lower_chamfer=true, anchor=ANCHOR);',
         [20,30,10], [0,0,-2], [20,30,8]),
        ("border", 'cube_border([20,30], h=6, border_w=2, inner=false, r=1, fn=32, anchor=ANCHOR);',
         [20,30,6], [-1,-1,0], [21,31,6]),
        ("recess", 'rounded_rect_recess([20,30], [24,34], r=0, thickness=10, recess_thickness=3, anchor=ANCHOR);',
         [24,34,10], [0,0,0], [24,34,10]),
        ("deep_recess", 'rounded_rect_recess([20,30], [24,34], r=0, thickness=10, recess_thickness=13, recess_reverse=true, anchor=ANCHOR);',
         [24,34,10], [0,0,-3], [24,34,10]),
        ("taper", 'tapered_box([20,30], [12,18], h=10, r_top=0, r_bottom=0, anchor=ANCHOR);',
         [20,30,10], [0,0,0], [20,30,10]),
        ("thin_taper", 'tapered_box([20,30], [12,18], h=0.005, r_top=0, r_bottom=0, anchor=ANCHOR);',
         [20,30,0.005], [0,0,0], [20,30,0.005]),
        ("square", 'linear_extrude(height=2) { chamfered_square(20, 2, anchor=ANCHOR); }',
         [20,20,0], [0,0,0], [20,20,2]),
        ("rect", 'linear_extrude(height=2) { chamfered_rect([20,30], 2, anchor=ANCHOR); }',
         [20,30,0], [0,0,0], [20,30,2]),
        ("border_2d", 'linear_extrude(height=2) { rect_border([20,30], border_w=2, inner=false, anchor=ANCHOR); }',
         [20,30,0], [-1,-1,0], [21,31,2]),
    ]
    anchors = list(itertools.product([-1, 0, 1], repeat=3)) + [(None, 0, None), None]
    for name, call, reference, low, high in cases:
        source = "\n".join(
            f"translate([{i % 9 * 100},{i // 9 * 100},0]) {{ "
            + call.replace("ANCHOR", scad_anchor(anchor)) + " }"
            for i, anchor in enumerate(anchors))
        mesh = render(folder, name, source, "stl")
        groups = [[] for _ in anchors]
        for vertex in vertices(mesh):
            column = round(vertex[0] / 100)
            row = round(vertex[1] / 100)
            groups[row * 9 + column].append(vertex)
        for i, (anchor, points) in enumerate(zip(anchors, groups)):
            assert points, (name, anchor, "missing geometry")
            anchor = [1 if a is None else a for a in (anchor or [1, 1, 1])]
            for axis in range(3):
                placement = [i % 9 * 100, i // 9 * 100, 0][axis]
                shift = {-1: -reference[axis], 0: -reference[axis] / 2, 1: 0}[anchor[axis]]
                for reduce, bound in [(min, low), (max, high)]:
                    actual = reduce(p[axis] for p in points) - placement
                    expected = bound[axis] + shift
                    assert abs(actual - expected) < 0.0001, (name, anchor, axis, actual, expected)
    print(f"PASS: rendered bounds for {len(cases) * len(anchors)} anchor cases", flush=True)


def main():
    with tempfile.TemporaryDirectory(prefix="shape-helpers-") as directory:
        folder = Path(directory)
        check_percentages(folder)
        check_anchors(folder)


if __name__ == "__main__":
    main()
