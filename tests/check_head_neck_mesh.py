"""Check conservative head bounds against OpenSCAD meshes (no Python dependencies).

Run: python3 tests/check_head_neck_mesh.py
"""
from pathlib import Path
import ast
import json
import re
import struct
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def mesh_bounds(path):
    lo = [float("inf")] * 3
    hi = [float("-inf")] * 3
    with path.open("rb") as stream:
        stream.read(80)
        count = struct.unpack("<I", stream.read(4))[0]
        assert path.stat().st_size == 84 + 50 * count
        for _ in range(count):
            triangle = struct.unpack("<12fH", stream.read(50))
            for start in (3, 6, 9):
                for axis in range(3):
                    value = triangle[start + axis]
                    lo[axis] = min(lo[axis], value)
                    hi[axis] = max(hi[axis], value)
    return [lo, hi]


def main():
    cases = [
        (0, 0, True, {}),
        (37, 42, True, {}),
        (-145, -63, True, {}),
        (90, 90, True, {}),
        (28, -90, False, {}),
        (31, 24, True, {"head_neck_pan_servo_assembly_reversed": True,
                        "ir_case_bracket_position": "both"}),
        (65, -128, True, {"head_plate_width": 46,
                          "head_upper_plate_height": 38,
                          "ir_case_bracket_position": "right"}),
    ]
    with tempfile.TemporaryDirectory(prefix="head-neck-bbox-") as folder:
        source = Path(folder) / "head.scad"
        mesh = Path(folder) / "head.stl"
        source.write_text(
            f'use <{ROOT}/scad/head/head_neck.scad>\n'
            '$fn=24;\n'
            'echo(bounds=head_neck_bounds(pan, tilt, centered));\n'
            'echo(max_z=head_neck_max_z(centered));\n'
            'echo(max_height=head_neck_max_height());\n'
            'head_neck(pan_servo_rotation=pan, tilt_servo_rotation=tilt,\n'
            '          center_pan_servo_slot=centered);\n'
        )
        for pan, tilt, centered, params in cases:
            command = ["openscad", "--backend=Manifold", "--enable=textmetrics",
                       "--hardwarnings", "--export-format", "binstl", "-o", str(mesh)]
            params = dict(params, pan=pan, tilt=tilt, centered=centered)
            for key, value in params.items():
                command += ["-D", f"{key}={json.dumps(value)}"]
            result = subprocess.run(command + [str(source)], capture_output=True, text=True)
            log = result.stdout + result.stderr
            assert result.returncode == 0, log
            assert "WARNING:" not in log and "ERROR:" not in log, log
            expected = ast.literal_eval(re.search(r"ECHO: bounds = (.*)", log)[1])
            max_z = float(re.search(r"ECHO: max_z = (.*)", log)[1])
            max_height = float(re.search(r"ECHO: max_height = (.*)", log)[1])
            actual = mesh_bounds(mesh)
            # echo rounds values; STL also stores single-precision coordinates.
            tolerance = 0.001
            for axis in range(3):
                assert actual[0][axis] >= expected[0][axis] - tolerance, (params, expected, actual)
                assert actual[1][axis] <= expected[1][axis] + tolerance, (params, expected, actual)
            assert actual[1][2] <= max_z + tolerance, (params, actual, max_z)
            assert actual[1][2] - actual[0][2] <= max_height + tolerance
            print(f"PASS pan={pan}, tilt={tilt}, centered={centered}, "
                  f"mesh Z={actual[0][2]:.3f}..{actual[1][2]:.3f}", flush=True)
    print("PASS: 7 fully populated meshes enclosed, including changed dimensions and IR sides")


if __name__ == "__main__":
    main()
