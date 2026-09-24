"""Verify rear plate bounds, solid lands and through-holes in exported meshes.

Run: python3 tests/check_rear_chassis_mesh.py
Requires OpenSCAD; uses only the Python standard library.
"""
import ast
import math
from pathlib import Path
import re
import struct
import subprocess
import tempfile

from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]


def read_triangles(path):
    data = path.read_bytes()
    count = struct.unpack_from("<I", data, 80)[0]
    assert len(data) == 84 + count * 50
    return [[record[3:6], record[6:9], record[9:12]]
            for record in struct.iter_unpack("<12fH", data[84:])]


def ray_hits(triangles, x, y):
    """Whether a Z-directed ray encounters any triangle at this XY coordinate."""
    for a, b, c in triangles:
        det = (b[1] - c[1]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[1] - c[1])
        if abs(det) < 1e-9:
            continue
        u = ((b[1] - c[1]) * (x - c[0]) + (c[0] - b[0]) * (y - c[1])) / det
        v = ((c[1] - a[1]) * (x - c[0]) + (a[0] - c[0]) * (y - c[1])) / det
        if min(u, v, 1 - u - v) >= -1e-7:
            return True
    return False


def main() -> None:
    cases = [(side, orientation, [0, 1, 1], False, 0)
             for side in ("auto", "left", "right") for orientation in ("wlh", "lwh")]
    cases += [("auto", "wlh", [-1, 0, -1], False, -20),
              ("auto", "lwh", [1, -1, 0], True, 10)]
    with tempfile.TemporaryDirectory(prefix="rear-chassis-mesh-") as folder:
        source = Path(folder) / "fixture.scad"
        mesh = Path(folder) / "fixture.stl"
        source.write_text(f'''
include <{ROOT}/scad/suspension/rear_suspension/computed_params.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/lib/functions.scad>
use <{ROOT}/scad/motor_brackets/rc/gearbox_bracket.scad>
use <{ROOT}/scad/panel_stack/panel_stack.scad>
use <{ROOT}/scad/suspension/rear_suspension/rear_suspension_chassis.scad>

changed = false;
side = "auto";
orientation = "wlh";
anchor = [0,1,1];
y_offset = 0;
motor = changed ? plist_put("gearbox", plist_put("mount_ear_x_dist", 30,
                     plist_get("gearbox", motor_plist)), motor_plist) : motor_plist;
bracket = changed ? gearmotor_bracket_compute_params(motor, bolt_pad_y=5, fillet_x_w=5)
                  : gearmotor_bracket_compute_params(motor);
layout = rear_suspension_layout(bracket=bracket, side=side,
                                orientation=orientation, panel_y_offset=y_offset);
size = rear_suspension_chassis_size(layout);
center_y = (plist_get("min_y", layout) + plist_get("max_y", layout)) / 2;
shift = to_anchor(anchor, size, centered=true) - [0, center_y, 0];
panel_pos = plist_get("panel_pos", layout);
span = panel_stack_oriented_bolt_spacing(orientation);
motor_pos = plist_get("motor_pos", layout);
holes = concat(
  [for (p=plist_get("mount_hole_positions", bracket))
     [motor_pos[0]-p[0], motor_pos[1]-p[1], plist_get("bolt_d", bracket)/2+0.5]],
  [for (p=plist_get("gearbox_hole_positions", bracket))
     [motor_pos[0]-p[0], motor_pos[1]-p[1], plist_get("mount_cbore_d", bracket)/2+0.5]],
  [for (x=[-1,1], y=[-1,1])
     [panel_pos[0]+x*span[0]/2, panel_pos[1]+y*span[1]/2,
      panel_stack_bolt_cbore_dia/2+0.5]],
  [for (x=[-1,1]) [x*rear_suspension_holder_bolt_spacing_x/2, 0,
                   rear_suspension_chassis_bolt_bore_d/2+0.5]],
  [for (x=[-1,1]) [x*rear_bulkhead_bolt_spacing_1[0]/2,
                   plist_get("bulkhead_1_y",layout), rear_suspension_chassis_bolt_bore_d/2+0.5]],
  [for (x=[-1,1], y=[-1,1]) [x*rear_bulkhead_bolt_spacing_2[0]/2,
      plist_get("bulkhead_2_y",layout)+y*rear_bulkhead_bolt_spacing_2[1]/2,
      rear_suspension_chassis_bolt_bore_d/2+0.5]],
  [[0, plist_get("maintenance_y",layout), rear_chassis_maintenance_hole_d/2+0.5]]);
echo(size=size, shift=shift, holes=holes);
rear_suspension_chassis(anchor=anchor, layout=layout);
''')
        for side, orientation, anchor, changed, offset in cases:
            command = [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
                       "--export-format", "binstl", "-o", str(mesh),
                       "-D", f'side="{side}"', "-D", f'orientation="{orientation}"',
                       "-D", f"anchor={anchor}", "-D", f"changed={str(changed).lower()}",
                       "-D", f"y_offset={offset}", str(source)]
            result = subprocess.run(command, text=True, capture_output=True)
            log = result.stdout + result.stderr
            assert result.returncode == 0 and "WARNING:" not in log and "ERROR:" not in log, log
            values = re.search(r"ECHO: size = (.*), shift = (.*), holes = (.*)", log)
            assert values is not None, log
            size, shift, holes = map(ast.literal_eval, values.groups())
            triangles = read_triangles(mesh)
            points = [point for triangle in triangles for point in triangle]
            low = [min(p[i] for p in points) for i in range(3)]
            high = [max(p[i] for p in points) for i in range(3)]
            expected_low = [(anchor[i] - 1) * size[i] / 2 for i in range(3)]
            expected_high = [expected_low[i] + size[i] for i in range(3)]
            assert all(abs(a-b) < 0.002 for a,b in zip(low+high, expected_low+expected_high)), (low, high, size)
            for x, y, radius in holes:
                x += shift[0]
                y += shift[1]
                assert not ray_hits(triangles, x, y), (side, orientation, "blocked hole", x, y)
                for angle in range(0, 360, 45):
                    rx = x + radius * math.cos(math.radians(angle))
                    ry = y + radius * math.sin(math.radians(angle))
                    assert ray_hits(triangles, rx, ry), (side, orientation, "missing land", x, y, angle)
            print(f"PASS {side}/{orientation}, anchor={anchor}, changed={changed}: "
                  f"bounds and {len(holes)} through-holes with surrounding lands", flush=True)


if __name__ == "__main__":
    main()
