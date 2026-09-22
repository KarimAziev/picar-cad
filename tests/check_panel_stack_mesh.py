"""Check actual panel/slot placements in all orientations and both anchor modes.

Run: python3 tests/check_panel_stack_mesh.py
Uses OpenSCAD and the Python standard library only.
"""
import ast
import itertools
import json
from pathlib import Path
import re
import struct
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
# Independent signed XYZ permutations for the six documented orientations.
ORIENTATIONS = {
    "wlh": ((0, 1), (1, 1), (2, 1)),
    "whl": ((0, 1), (2, -1), (1, 1)),
    "lwh": ((1, -1), (0, 1), (2, 1)),
    "lhw": ((1, 1), (2, 1), (0, 1)),
    "hlw": ((2, -1), (1, 1), (0, 1)),
    "hwl": ((2, 1), (0, 1), (1, 1)),
}


def vertices(path):
    data = path.read_bytes()
    count = struct.unpack_from("<I", data, 80)[0]
    assert len(data) == 84 + 50 * count
    return [triangle[start:start + 3]
            for triangle in struct.iter_unpack("<12fH", data[84:])
            for start in (3, 6, 9)]


def bounds(points):
    return [[operation(p[axis] for p in points) for axis in range(3)]
            for operation in (min, max)]


def close(actual, expected):
    assert all(abs(a - b) < 0.002 for a, b in zip(actual, expected)), (actual, expected)


def transformed_bounds(original, reference, orientation, anchor):
    order = ORIENTATIONS[orientation]
    target = [reference[axis] for axis, _ in order]
    points = []
    for point in itertools.product(*zip(*original)):
        centered = [point[0], point[1], point[2] - reference[2] / 2]
        points.append([sign * centered[axis] + anchor[i] * target[i] / 2
                       for i, (axis, sign) in enumerate(order)])
    return bounds(points)


def main():
    with tempfile.TemporaryDirectory(prefix="panel-stack-mesh-") as folder:
        source = Path(folder) / "fixture.scad"
        mesh = Path(folder) / "fixture.stl"

        def render(call):
            source.write_text(
                f'use <{ROOT}/scad/panel_stack/panel_stack.scad>\n'
                'echo(size=panel_stack_oriented_size(show_standoff=false));\n'
                'echo(bolts=panel_stack_bolt_spacing());\n'
                'echo(height=panel_stack_height());\n'
                '$fn=24;\n' + call + '\n')
            result = subprocess.run(
                ["openscad", "--backend=Manifold", "--enable=textmetrics",
                 "--hardwarnings", "--export-format", "binstl", "-o", str(mesh),
                 str(source)], capture_output=True, text=True)
            log = result.stdout + result.stderr
            assert result.returncode == 0 and "ERROR:" not in log and "WARNING:" not in log, log
            dims = {name: ast.literal_eval(re.search(rf"ECHO: {name} = (.*)", log)[1])
                    for name in ("size", "bolts", "height")}
            return vertices(mesh), dims

        points, dims = render('panel_stack(show_standoff=false, show_fuses=false, '
                              'show_buttons=false, anchor=[0,0,1]);')
        baseline_body = bounds(points)
        w, l, h = dims["size"]
        close(baseline_body[0], [-w / 2, -l / 2, 0])
        close(baseline_body[1], [w / 2, l / 2, h])
        points, _ = render('panel_stack_bolt_holes(anchor=[0,0,1], slot_thickness=7);')
        baseline_slots = bounds(points)
        for orientation in ORIENTATIONS:
            for mode in ("size", "bolts"):
                reference = dims["size"] if mode == "size" else dims["bolts"] + [0]
                for anchor in ([1, 1, 1], [0, 0, 0], [-1, 1, -1]):
                    args = (f'orientation="{orientation}", anchor_mode="{mode}", '
                            f'anchor={json.dumps(anchor)}, show_standoff=false')
                    for baseline, call in (
                        (baseline_body, f'panel_stack({args}, show_fuses=false, show_buttons=false);'),
                        (baseline_slots, f'panel_stack_bolt_holes({args}, slot_thickness=7);'),
                    ):
                        points, _ = render(call)
                        actual = bounds(points)
                        expected = transformed_bounds(baseline, reference, orientation, anchor)
                        for a, e in zip(actual, expected):
                            close(a, e)
                print(f"PASS {orientation}, {mode}: solid and slots at three anchors", flush=True)

        # Full stack's structural top must coincide with the actual top panel,
        # even though screws/standoff threads can protrude beyond that reference.
        points, dims = render('panel_stack(show_fuses=false, show_buttons=false, anchor=[0,0,1]);')
        top_edges = [p for p in points if abs(abs(p[0]) - w / 2) < 0.002]
        assert top_edges
        close([max(p[2] for p in top_edges)], [dims["height"]])

        for buttons, fuses in ((True, True), (True, False), (False, True)):
            points, _ = render(f'panel_stack_print_plate(show_buttons_panel={str(buttons).lower()}, '
                               f'show_fuse_panel={str(fuses).lower()}, '
                               'spacing=7, anchor=[-1,1,-1]);')
            actual = bounds(points)
            width = 2 * w + 7 if buttons and fuses else w
            close(actual[0][:2], [-width, 0])
            close(actual[1], [0, l, 0])
        print("PASS full stack height and single/dual printable anchors", flush=True)


if __name__ == "__main__":
    main()
