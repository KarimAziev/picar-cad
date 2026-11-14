"""Check horn profiles, independent mount configurations, and seated hardware.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""
from pathlib import Path
import json
import subprocess
import tempfile

import numpy as np
import trimesh

from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]
PRELUDE = f"""
include <{ROOT}/scad/rc_params.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/placeholders/servo_horn.scad>
use <{ROOT}/scad/head/head_mount.scad>
use <{ROOT}/scad/suspension/front_chassis/head_frame/head_slots.scad>
use <{ROOT}/scad/suspension/front_chassis/front_frame_util.scad>
"""


def render(folder: Path, body: str,
           params: dict[str, str] | None = None) -> trimesh.Trimesh | None:
    source = folder / "horn.scad"
    output = folder / "horn.stl"
    output.unlink(missing_ok=True)
    source.write_text(PRELUDE + body)
    command = [OPENSCAD, "--backend=Manifold", "--enable=textmetrics",
               "--hardwarnings", "--export-format", "binstl", "-o", str(output)]
    for key, value in (params or {}).items():
        command += ["-D", f"{key}={value}"]
    result = subprocess.run(command + [str(source)], capture_output=True, text=True)
    log = result.stdout + result.stderr
    assert "WARNING:" not in log and "ERROR:" not in log, log
    if not output.exists():
        assert "Current top level object is empty" in log, log
        return None
    assert result.returncode == 0, log
    mesh = trimesh.load_mesh(output)
    assert isinstance(mesh, trimesh.Trimesh)
    return mesh


def empty(folder: Path, body: str,
          params: dict[str, str] | None = None) -> None:
    mesh = render(folder, body, params)
    if mesh is not None:
        # Coincident contact faces may produce a zero-volume STL.
        triangles = mesh.triangles
        volume = abs(float(np.einsum(
            "ij,ij->i", triangles[:, 0],
            np.cross(triangles[:, 1], triangles[:, 2])).sum() / 6))
        assert volume < 0.0001, (body, params, volume)


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="servo-horn-") as directory:
        folder = Path(directory)
        # Measured edge gaps produce these centers, independently of cutout clearance.
        expected = [7.865, 10.165, 12.465]
        for shape, sides, count in [("cross", "all", 12),
                                    ("cross", "vertical", 6),
                                    ("cross", "horizontal", 6),
                                    ("single", "all", 3), ("double", "all", 6)]:
            centers = []
            for clearance in [0, 0.25]:
                mesh = render(folder, f"""
linear_extrude(height=1) {{
  servo_horn_profile_from_plist(pl=["shape", "{shape}", "cross_side_holes", "{sides}"],
                               mode="holes", screw_clearance={clearance});
}}
""")
                assert mesh is not None
                pieces = mesh.split()
                assert len(pieces) == count, (shape, sides, count, len(pieces))
                positions = sorted(tuple(np.round(piece.centroid[:2], 5)) for piece in pieces)
                centers.append(positions)
                for piece in pieces:
                    assert piece.is_watertight
                    assert np.allclose(piece.extents[:2], 0.8 + clearance * 2, atol=1e-5)
                    radius = float(np.linalg.norm(piece.centroid[:2]))
                    assert any(abs(radius - value) < 1e-5 for value in expected)
                if shape == "single":
                    assert all(y > 0 for _, y in positions)
            assert centers[0] == centers[1], (shape, sides)
        # The explicit interface must emit circles when no children are supplied.
        mesh = render(folder, 'linear_extrude(height=1) { servo_horn_profile(mode="holes"); }')
        assert mesh is not None and len(mesh.split()) == 12
        empty(folder, """
linear_extrude(height=1) {
  difference() {
    servo_horn_profile_from_plist(mode="holes");
    servo_horn_profile_from_plist(mode="shape");
  }
}
""")
        # Custom children retain their hole index and placement through both wrappers.
        mesh = render(folder, """
servo_horn_profile_from_plist(pl=["shape", "single"], mode="holes") {
  translate([0, 0, $i]) { cylinder(d=0.2, h=0.2, $fn=12); }
}
""")
        assert mesh is not None
        assert np.allclose(sorted(piece.centroid[2] for piece in mesh.split()), [0.1, 1.1, 2.1])
        print("PASS: horn shapes, hole selection, measured centers, clearance and child placement", flush=True)

        horn_dimensions: dict[str, str | float] = {
            "shape": "cross", "cross_side_holes": "all", "arm_len": 14,
            "arm_bottom_width": 5.25, "arm_top_width": 4.03,
            "center_ring_dia": 7.05, "center_ring_inner_dia": 3.87,
            "center_hole_dia": 2, "horn_height": 5.6, "thickness": 2,
            "arm_z_offset": 2.5, "screw_d": 0.8, "initial_screws_gap": 3.94,
            "screws_gap": 1.5, "screw_holes_count": 3, "color": "black"}
        pan_dimensions = dict(horn_dimensions, shape="double", arm_len=16, screws_gap=2)
        tilt_dimensions = dict(horn_dimensions, shape="single", arm_len=15, screws_gap=1.8)
        configurations = [{},
                          {"pan_servo_horn_slot_plist": json.dumps(
                              [item for pair in pan_dimensions.items() for item in pair])},
                          {"tilt_servo_horn_slot_plist": json.dumps(
                              [item for pair in tilt_dimensions.items() for item in pair])},
                          {"pan_servo_horn_recess_clearance": "0.4",
                           "tilt_servo_horn_recess_clearance": "0.35",
                           "pan_servo_horn_screw_clearance": "0.15",
                           "tilt_servo_horn_screw_clearance": "0.15"},
                          {"head_side_panel_thickness": "6"}]
        pan_reference = None
        tilt_reference = None
        for index, params in enumerate(configurations):
            empty(folder, """
assert(abs(front_chassis_front_frame_start_y() - 129.601973) < 0.000001,
       "Horn configuration must preserve the chassis nose datum");
""", params)
            pan = render(folder, """
difference() {
  translate([-20, -20, 0]) { cube([40, 40, chassis_thickness]); }
  front_chassis_head_slots();
}
""", params)
            tilt = render(folder, 'head_side_panel(with_horn_mount=true);', params)
            assert pan is not None and tilt is not None
            assert pan.is_watertight and tilt.is_watertight
            if index == 0:
                pan_reference = float(pan.volume)
                tilt_reference = float(tilt.volume)
            elif index == 1:
                assert tilt_reference is not None and abs(float(tilt.volume) - tilt_reference) < 1e-5
                assert pan_reference is not None and abs(float(pan.volume) - pan_reference) > 1
            elif index == 2:
                assert pan_reference is not None and abs(float(pan.volume) - pan_reference) < 1e-5
                assert tilt_reference is not None and abs(float(tilt.volume) - tilt_reference) > 1
            empty(folder, """
difference() {
  linear_extrude(height=chassis_thickness) {
    servo_horn_profile_from_plist(pl=pan_servo_horn_slot_plist, mode="holes",
                                 screw_clearance=pan_servo_horn_screw_clearance);
  }
  front_chassis_head_slots();
}
""", params)
            empty(folder, """
intersection() {
  head_side_panel(with_horn_mount=true);
  head_tilt_horn(show_servo_horn_screws=true, show_servo_horn_bolt=true);
}
""", params)
            empty(folder, """
difference() {
  translate([0, 0, chassis_thickness - front_chassis_head_pan_servo_slot_recess]) {
    linear_extrude(height=front_chassis_head_pan_servo_slot_recess) {
      servo_horn_profile_from_plist(pl=pan_servo_horn_slot_plist, mode="shape",
                                   clearance=pan_servo_horn_recess_clearance);
    }
  }
  front_chassis_head_slots();
}
""", params)
        print("PASS: independent pan/tilt dimensions, recesses, through-holes and seated tilt hardware", flush=True)


if __name__ == "__main__":
    main()
