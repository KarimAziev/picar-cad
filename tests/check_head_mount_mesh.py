"""Validate removable head parts, joint clearances, and the horn seating floor.

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
include <{ROOT}/scad/parameters.scad>
use <{ROOT}/scad/head/head_mount.scad>
use <{ROOT}/scad/head/ir_case.scad>
use <{ROOT}/scad/lib/functions.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/lib/transforms.scad>
use <{ROOT}/scad/placeholders/bolt.scad>
use <{ROOT}/scad/placeholders/servo_horn.scad>
module ir_hardware() {{
  length = ir_case_mount_bolt_length(head_bridge_thickness);
  at_ir_case_mount_bolts() {{
    translate([0, 0, length]) {{
      rotate([180, 0, 0]) {{
        bolt(d=ir_case_mount_bolt_d, h=length, show_nut=true,
             nut_head_distance=ir_case_mount_foot_size()[2] + head_bridge_thickness);
      }}
    }}
  }}
}}
module horn_screw_clearances() {{
  servo_horn_profile_from_plist(pl=tilt_servo_horn_slot_plist,
                               mode="holes",
                               screw_clearance=tilt_servo_horn_screw_clearance);
}}
module front() {{
  translate([0, head_front_height / 2, 0]) {{
    rotate([0, 0, 180]) {{ head_front_plate(); }}
  }}
}}
module cameras() {{
  translate([0, head_front_height / 2, 0]) {{
    rotate([0, 0, 180]) {{
      translate([0, 0, -head_front_thickness - camera_thickness]) {{
        for (i=[0:len(head_cameras)-1]) {{
          head_front_camera(spec=head_cameras[i], i=i, slot_mode=false,
                            do_place_camera=true, show_bolts=true, show_nuts=true);
        }}
      }}
    }}
  }}
}}
module ir() {{
  rotate([0, 180, 0]) {{
    head_ir_case(show_ir_led=true, show_ir_case_rail=true,
                 show_ir_case_bolts=true, show_ir_case_nuts=true);
  }}
}}
module frame() {{
  front();
  head_bridge_assembled();
  head_side_panel_assembled(is_left=true);
  head_side_panel_assembled(is_left=false);
}}
module floor_probe(z) {{
  angle = head_tilt_horn_angle();
  p = head_tilt_axis_position()
      + [-6 * sin(angle), 6 * cos(angle)];
  translate([p[0] - 0.25, p[1] - 0.25, z]) {{ cube([0.5, 0.5, 0.5]); }}
}}
module at_flange_probes(part, depth) {{
  front_part = part == "front";
  width = front_part ? head_front_width : head_bridge_size()[0];
  outer_x = head_joint_clearance + (front_part ? 0 : head_side_panel_thickness);
  points = front_part ? head_front_joint_points() : head_bridge_joint_points();
  for (x=[outer_x + depth, width - outer_x - depth]) {{
    for (p=points) {{
      translate([x,
                 front_part ? head_front_height - p[1] : head_bridge_depth - p[0],
                 front_part ? p[0] : head_bridge_thickness + head_bridge_bolt_drop]) {{
        children();
      }}
    }}
  }}
}}
module roof_corner_probes(toward_front) {{
  size = head_bridge_size();
  slope = (head_side_panel_top - head_side_panel_notch_y)
          / head_side_panel_curve_start;
  start = head_side_panel_curve_end - head_side_panel_top;
  depth = head_bridge_corner_setback();
  flange_x = head_side_panel_thickness + head_joint_clearance;
  front_lip = head_front_thickness + head_joint_clearance;
  assert(abs(start + depth * slope - head_side_panel_size()[1]) < 0.000001);
  for (z=[0.5, head_bridge_thickness - 0.5]) {{
    for (edge_x=[flange_x / 4, 3 * flange_x / 4]) {{
      y = size[1] - depth + edge_x / flange_x * (depth - front_lip);
      for (x=[edge_x, size[0] - edge_x]) {{
        translate([x - 0.05, y + toward_front - 0.05, z - 0.05]) {{
          cube([0.1, 0.1, 0.1]);
        }}
      }}
    }}
  }}
}}
"""


def render(folder: Path, body: str, params: dict[str, float] | None = None
           ) -> trimesh.Trimesh | None:
    source = folder / "case.scad"
    output = folder / "case.stl"
    output.unlink(missing_ok=True)
    source.write_text(PRELUDE + body)
    command = [OPENSCAD, "--backend=Manifold", "--enable=textmetrics",
               "--hardwarnings", "--export-format", "binstl", "-o", str(output)]
    for key, value in (params or {}).items():
        command += ["-D", f"{key}={json.dumps(value)}"]
    result = subprocess.run(command + [str(source)], capture_output=True, text=True)
    log = result.stdout + result.stderr
    assert "ERROR:" not in log and "WARNING:" not in log, log
    if not output.exists():
        assert "Current top level object is empty" in log, log
        return None
    assert result.returncode == 0, log
    mesh = trimesh.load_mesh(output)
    assert isinstance(mesh, trimesh.Trimesh)
    return mesh


def no_overlap(folder: Path, body: str,
               params: dict[str, float] | None = None) -> None:
    mesh = render(folder, body, params)
    # Coincident contact faces can be emitted as a zero-volume STL.
    if mesh is not None:
        triangles = mesh.triangles
        volume = abs(float(np.einsum(
            "ij,ij->i", triangles[:, 0],
            np.cross(triangles[:, 1], triangles[:, 2])).sum() / 6))
        assert volume < 0.0001, (body, params, volume)


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="head-joints-") as directory:
        folder = Path(directory)
        for shape in ["single", "double"]:
            no_overlap(folder, f"""
linear_extrude(height=1) {{
  difference() {{
    head_tilt_horn_holes(shape="{shape}");
    polygon(head_side_panel_outline());
  }}
}}
""")
            no_overlap(folder, f"""
intersection() {{
  head_side_panel(with_horn_mount=true, servo_horn_shape="{shape}");
  head_tilt_horn(servo_horn_shape="{shape}",
                 show_servo_horn_screws=true, show_servo_horn_bolt=true);
}}
""")
        print("PASS: single/double horn holes stay inside the panel and seated hardware clears it",
              flush=True)
        for params in [{}, {"head_side_panel_thickness": 6},
                       {"head_front_width": 46, "head_bridge_depth": 38,
                        "head_mount_flange_thickness": 5, "head_frame_pocket_nut_h": 2}]:
            for body in ["head_front_printable();", "head_bridge();",
                         "head_side_panel(with_horn_mount=true);",
                         'ir_case_printable(mount="top", show_rail=false);']:
                mesh = render(folder, body, params)
                assert mesh is not None, body
                assert mesh.is_watertight and mesh.is_volume, body
                assert len(mesh.split()) == 1, body
                assert abs(float(mesh.bounds[0][2])) < 0.00001, body
            for part, model in [("front", "head_front_printable"),
                                ("bridge", "head_bridge")]:
                pocket = f"""
at_flange_probes("{part}", head_mount_flange_thickness - head_frame_pocket_nut_h / 2) {{
  rotate([0, 90, 0]) {{
    rotate([0, 0, 90]) {{
      cylinder(d=head_frame_pocket_nut_d - 0.02,
               h=head_frame_pocket_nut_h - 0.02, center=true, $fn=6);
    }}
  }}
}}
"""
                no_overlap(folder, f"intersection() {{ {model}(); {pocket} }}", params)
                no_overlap(folder,
                           f"difference() {{ {pocket} {model}(slot_mode=true); }}",
                           params)
                # The seating floor surrounds the screw hole on both outer faces.
                floor = render(folder, f"""
intersection() {{
  {model}();
  at_flange_probes("{part}",
                  (head_mount_flange_thickness - head_frame_pocket_nut_h) / 2) {{
    translate([0, 2.5, 0]) {{ cube([0.2, 0.2, 0.2], center=true); }}
  }}
}}
""", params)
                assert floor is not None and abs(float(floor.volume) - 0.032) < 0.00001
                # Material just beyond a hex flat distinguishes the pocket from a round bore.
                flats = render(folder, f"""
intersection() {{
  {model}();
  at_flange_probes("{part}",
                  head_mount_flange_thickness - head_frame_pocket_nut_h / 2) {{
    r = head_frame_pocket_nut_d / 2 * (1 + cos(30)) / 2;
    translate([0, r * cos(30), r * sin(30)]) {{
      cube([0.1, 0.1, 0.1], center=true);
    }}
  }}
}}
""", params)
                assert flats is not None and abs(float(flats.volume) - 0.004) < 0.00001
            print(f"PASS: eight inner hex pockets, seating floors and slot modes: {params}",
                  flush=True)
            for a, b in [("front()", "head_bridge_assembled()"),
                         ("front()", "head_side_panel_assembled()"),
                         ("head_bridge_assembled()", "head_side_panel_assembled()"),
                         ("head_bridge_assembled()", "cameras()"),
                         ("head_side_panel_assembled()", "cameras()"),
                         ("frame()", "ir()"),
                         ("frame()", "head_frame_hardware(show_nuts=true)"),
                         ("cameras()", "head_frame_hardware(show_nuts=true)"),
                         ("head_side_panel(with_horn_mount=true)", "head_tilt_horn()")]:
                no_overlap(folder, f"intersection() {{ {a}; {b}; }}", params)
            no_overlap(folder, 'intersection() { ir_case(mount="top"); ir_hardware(); }',
                       params)
            no_overlap(folder, 'intersection() { ir_case(mount="top"); ir_case_rail(); }',
                       params)
            # The entire screw clearance circles must lie inside the horn recess.
            no_overlap(folder, """
linear_extrude(height=1) {
  difference() {
    horn_screw_clearances();
    servo_horn_profile_from_plist(pl=tilt_servo_horn_slot_plist, mode="shape",
                                 clearance=tilt_servo_horn_recess_clearance);
  }
}
""", params)
            # Hardware screws, including the center fastener, must clear the panel.
            no_overlap(folder, """
intersection() {
  head_side_panel(with_horn_mount=true);
  head_tilt_horn(show_servo_horn_screws=true, show_servo_horn_bolt=true);
}
""", params)
            # Check the rearward flanges separately from the camera face plate.
            no_overlap(folder, """
intersection() {
  front(); cameras();
  translate([-100, -100, -100]) {
    cube([200, 200, 100 - head_front_thickness - 0.1]);
  }
}
""", params)
            no_overlap(folder, """
intersection() {
  head_side_panel(with_horn_mount=true);
  floor_probe(head_horn_seat_thickness + 0.1);
}
""", params)
            floor = render(folder, """
intersection() {
  head_side_panel(with_horn_mount=true);
  floor_probe(head_horn_seat_thickness - 0.6);
}
""", params)
            assert floor is not None and abs(float(floor.volume) - 0.125) < 0.00001
            no_overlap(folder, """
intersection() {
  head_bridge();
  roof_corner_probes(0.6);
}
""", params)
            corners = render(folder, """
intersection() {
  head_bridge();
  roof_corner_probes(-0.6);
}
""", params)
            assert corners is not None and abs(float(corners.volume) - 0.008) < 0.00001
            # Every flange base must have roof material beneath it.
            no_overlap(folder, """
difference() {
  intersection() {
    translate([0, 0, -head_bridge_thickness]) { head_bridge(); }
    cube([head_bridge_size()[0], head_bridge_size()[1], 0.05]);
  }
  head_bridge();
}
""", params)
            lip = render(folder, """
intersection() {
  head_bridge();
  size = head_bridge_size();
  translate([size[0] / 2 - 0.1,
             size[1] - (head_front_thickness + head_joint_clearance) / 2 - 0.1,
             head_bridge_thickness / 2 - 0.1]) {
    cube([0.2, 0.2, 0.2]);
  }
}
""", params)
            assert lip is not None and abs(float(lip.volume) - 0.008) < 0.00001
            print(f"PASS: connected bed-oriented parts, joint/hardware clearances, "
                  f"horn seating and screws, aligned roof corners and front lip: {params}",
                  flush=True)
        # Slot count follows the available depth and the configured slot pitch.
        layout_cases = [({}, 3), ({"head_bridge_depth": 48}, 5),
                        ({"ir_case_mount_bolt_spacing_y": 10}, 2),
                        ({"ir_case_mount_rear_pad": 5}, 2),
                        ({"head_ir_setback": 21}, 0),
                        ({"head_bridge_slot_width": 4, "head_bridge_slot_gap": 3}, 2)]
        for params, expected_count in layout_cases:
            body = f"assert(plist_get(\"count\", head_bridge_slot_layout()) == {expected_count});"
            mesh = render(folder, body + "head_bridge();", params)
            assert mesh is not None and mesh.is_watertight and mesh.is_volume
            assert len(mesh.split()) == 1
            # Every generated slot center must be open through the bridge.
            no_overlap(folder, """
layout = head_bridge_slot_layout();
count = plist_get("count", layout);
if (count > 0) {
  intersection() {
    head_bridge();
    for (i=[0:count - 1]) {
      translate([head_bridge_size()[0] / 2 - 0.05,
                 i * (head_bridge_slot_width + head_bridge_slot_gap) - 0.05, 0]) {
        cube([0.1, 0.1, head_bridge_thickness]);
      }
    }
  }
}
""", params)
            no_overlap(folder, """
intersection() {
  ir_case(mount="top");
  ir_hardware();
}
""", params)
            # The actual foot cross-section must remain supported by the bridge.
            no_overlap(folder, """
linear_extrude(height=1) {
  difference() {
    translate([(head_bridge_size()[0] - ir_case_mount_foot_size()[0]) / 2,
               head_bridge_depth - head_ir_setback]) {
      projection(cut=true) {
        translate([0, 0, ir_case_mount_foot_size()[2] / 2]) {
          rotate([90, 0, 0]) { ir_case_mount_foot(); }
        }
      }
    }
    projection(cut=true) {
      translate([0, 0, -head_bridge_thickness / 2]) { head_bridge(); }
    }
  }
}
""", params)
            print(f"PASS: automatic bridge slot count {expected_count}: {params}", flush=True)
        plate = render(folder, "head_mount_printable();")
        assert plate is not None and plate.is_watertight
        assert len(plate.split()) == 4
        print("PASS: four separate parts on the head print plate")


if __name__ == "__main__":
    main()
