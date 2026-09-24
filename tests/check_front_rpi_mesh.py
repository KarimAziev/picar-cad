"""Check oriented Raspberry Pi mounting passages and frame enclosure.

Run: python3 tests/check_front_rpi_mesh.py
Requires OpenSCAD; uses only the Python standard library.
"""
import ast
import math
from pathlib import Path
import re
import subprocess
import tempfile

from check_rear_chassis_mesh import read_triangles, ray_hits

from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    source_text = f'''
include <{ROOT}/scad/suspension/front_chassis/computed_params.scad>
use <{ROOT}/scad/suspension/front_chassis/front_chassis_rear_frame.scad>
echo(reference=rpi_5_size(), offset=rpi_bolts_offset,
     spacing=rpi_bolt_spacing, radius=rpi_bolt_cbore_dia/2 + 0.4,
     front_y=y_front_chassis_rear_frame_main_start + front_rpi_y_offset,
     width=front_chassis_rear_frame_w, rear_y=front_chassis_y_joint_2_end);
front_chassis_rear_frame(debug=false);
'''
    cases = [(orientation, reverse, -5) for orientation in ("wlh", "lwh")
             for reverse in (False, True)]
    cases += [("lwh", True, -120), ("lwh", False, 80)]
    with tempfile.TemporaryDirectory(prefix="front-rpi-") as folder:
        source = Path(folder) / "frame.scad"
        source.write_text(source_text)
        mesh = Path(folder) / "frame.stl"
        for orientation, reverse, x_offset in cases:
            defines = ["-D", f'front_rpi_orientation="{orientation}"',
                       "-D", f"front_rpi_rotate_z_180={str(reverse).lower()}",
                       "-D", f"front_rpi_x_offset={x_offset}"]
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--enable=roof",
                 "--hardwarnings", "--export-format", "binstl", "-o", str(mesh),
                 *defines, str(source)], text=True, capture_output=True)
            log = result.stdout + result.stderr
            assert result.returncode == 0 and "WARNING:" not in log and "ERROR:" not in log, log
            match = re.search(r"ECHO: reference = (.*), offset = (.*), spacing = (.*), radius = (.*), "
                              r"front_y = (.*), width = (.*), rear_y = (.*)", log)
            assert match is not None, log
            reference, offset, spacing, radius, front_y, width, rear_y = map(ast.literal_eval, match.groups())
            triangles = read_triangles(mesh)
            oriented_w, oriented_l = (reference[:2] if orientation == "wlh"
                                      else reference[1::-1])
            assert x_offset >= -width / 2 and x_offset + oriented_w <= width / 2
            points = [p for tri in triangles for p in tri]
            assert abs(min(p[0] for p in points) + width / 2) < 0.001
            assert abs(max(p[0] for p in points) - width / 2) < 0.001
            # Independently transform measured PCB hole centers about the
            # USB-inclusive reference center, then apply the final anchor.
            for sx in (0, spacing[0]):
                for sy in (0, spacing[1]):
                    x = offset + sx - reference[0] / 2
                    y = offset + sy - reference[1] / 2
                    if reverse:
                        x, y = -x, -y
                    if orientation == "lwh":
                        x, y = -y, x
                    x += x_offset + oriented_w / 2
                    y += front_y - oriented_l / 2
                    assert not ray_hits(triangles, x, y), (orientation, reverse, x_offset, "blocked hole", x, y)
                    for angle in range(0, 360, 45):
                        rx = x + radius * math.cos(math.radians(angle))
                        ry = y + radius * math.sin(math.radians(angle))
                        assert ray_hits(triangles, rx, ry), (orientation, reverse, x_offset, "missing land", x, y, angle)
            check = subprocess.run(
                [OPENSCAD, "--hardwarnings", "-o", str(Path(folder) / "assertions.csg"),
                 *defines, str(ROOT / "tests/test_front_rpi.scad")], text=True, capture_output=True)
            assert check.returncode == 0 and "ERROR:" not in check.stderr, check.stderr
            print(f"PASS {orientation}, reverse={reverse}, x={x_offset}: "
                  f"width={width}, rear_y={rear_y}; four open holes with surrounding material", flush=True)


if __name__ == "__main__":
    main()
