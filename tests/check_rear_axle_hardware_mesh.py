# Module: Rear axle hardware clearance checks.
#
# Author: Karim Aziiev <karim.aziiev@gmail.com>
# License: GPL-3.0-or-later

"""Check sleeve bores, dogbone cup engagement and housing hardware clearance."""

from pathlib import Path
import subprocess
import tempfile

import trimesh

from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    common = f"""
include <{ROOT}/scad/suspension/rear_axle/hardware_params.scad>
include <{ROOT}/scad/suspension/rear_axle/structure_params.scad>
include <{ROOT}/scad/suspension/rear_axle/arm_hub_params.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/placeholders/hsp_rear_drivetrain.scad>
use <{ROOT}/scad/suspension/rear_axle/rear_bulkhead.scad>
use <{ROOT}/scad/suspension/rear_chassis/computed_params.scad>
$fn = 64;
module sleeve() {{
  hsp_motor_sleeve(rear_motor_sleeve_spec, anchor=[0, 0, 1]);
}}
module wheel_axle() {{
  hsp_rear_wheel_axle(rear_wheel_axle_spec, anchor=[0, 0, 1],
                      show_bearings=false, show_hex=false);
}}
module ball_and_pin() {{
  sphere(d=plist_get("ball_d", rear_dogbone_spec));
  rotate([0, 90, 0]) {{
    cylinder(d=plist_get("pin_d", rear_dogbone_spec),
             h=plist_get("pin_l", rear_dogbone_spec), center=true);
  }}
}}
module housing(part) {{
  mounts = rear_bulkhead_mount_positions(rear_chassis_layout(),
    rear_bulkhead_bolt_spacing_x, rear_bulkhead_bolt_spacing_2[1]);
  rear_bulkhead(rear_housing_spec, rear_differential_spec, rear_pinion_spec,
                 rear_lower_arm_spec, rear_tower_spec, mounts,
                 part=part, show_hardware=false);
}}
module installed_differential() {{
  axis = rear_bulkhead_axis(rear_housing_spec, rear_differential_spec);
  translate(axis - hsp_rear_differential_axis(rear_differential_spec)) {{
    hsp_rear_differential(rear_differential_spec, show_bearings=true);
  }}
}}
module pinion() {{
  origin = rear_bulkhead_pinion_origin(rear_housing_spec,
    rear_differential_spec, rear_pinion_spec);
  translate(origin) {{
    rotate([-90, 0, 0]) {{
      hsp_rear_pinion(rear_pinion_spec, anchor=[0, 0, 1], show_bearings=true);
    }}
  }}
}}
"""
    with tempfile.TemporaryDirectory(prefix="rear-axle-hardware-") as folder:
        source = Path(folder) / "fixture.scad"
        output = Path(folder) / "fixture.stl"

        def export(code: str) -> subprocess.CompletedProcess[str]:
            source.write_text(common + code)
            output.unlink(missing_ok=True)
            return subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics",
                 "--hardwarnings", "--export-format", "binstl",
                 "-o", str(output), str(source)],
                capture_output=True, text=True,
            )

        def check(label: str, code: str, *, empty: bool = False) -> None:
            result = export(code)
            log = result.stdout + result.stderr
            assert "ERROR:" not in log and "WARNING:" not in log, (label, log)
            if empty and "Current top level object is empty" in log:
                print(f"PASS {label}", flush=True)
                return
            assert result.returncode == 0, (label, log)
            mesh = trimesh.load_mesh(output)
            assert isinstance(mesh, trimesh.Trimesh), label
            if empty:
                assert abs(mesh.volume) < 1e-6, (label, mesh.volume)
            else:
                assert mesh.is_watertight and mesh.is_winding_consistent, label
                assert mesh.is_volume and mesh.volume > 0, label
                assert mesh.nondegenerate_faces().all(), (label, "degenerate faces")
                assert mesh.unique_faces().all(), (label, "duplicate faces")
            print(f"PASS {label}", flush=True)

        check("reducing sleeve is a closed solid", "sleeve();")
        check("4 mm motor engagement is open", """
intersection() {
  sleeve();
  translate([0, 0, -0.01]) {
    cylinder(d=3.98, h=plist_get("motor_engagement", rear_motor_sleeve_spec) + 0.01);
  }
}
""", empty=True)
        check("5 mm pinion engagement is open", """
intersection() {
  sleeve();
  translate([0, 0, plist_get("motor_engagement", rear_motor_sleeve_spec)
                   + plist_get("shaft_end_gap", rear_motor_sleeve_spec)]) {
    cylinder(d=4.98,
             h=plist_get("pinion_engagement", rear_motor_sleeve_spec) + 0.01);
  }
}
""", empty=True)
        # The same radius lies in metal at the 4 mm end and in air at the 5 mm
        # end. This detects reversed bores and accidental constant-diameter holes.
        check("motor end retains the 4 mm bore step", """
difference() {
  translate([2.15, -0.05, 1]) { cube([0.1, 0.1, 1]); }
  sleeve();
}
""", empty=True)
        check("pinion end clears the 5 mm bore step", """
intersection() {
  translate([2.15, -0.05,
             plist_get("motor_engagement", rear_motor_sleeve_spec)
             + plist_get("shaft_end_gap", rear_motor_sleeve_spec) + 1]) {
    cube([0.1, 0.1, 1]);
  }
  sleeve();
}
""", empty=True)

        check("wheel axle is a closed solid", "wheel_axle();")
        check("wheel cup accepts the stock ball and drive pin", """
intersection() {
  wheel_axle();
  translate([0, 0, plist_get("cup_ball_depth", rear_wheel_axle_spec)]) {
    ball_and_pin();
  }
}
""", empty=True)
        check("both differential cups accept the stock balls and drive pins", """
intersection() {
  hsp_rear_differential(rear_differential_spec, show_bearings=false);
  union() {
    for (p = hsp_rear_differential_output_positions(rear_differential_spec)) {
      translate(p) {
        rotate([0, 90, 0]) { ball_and_pin(); }
      }
    }
  }
}
""", empty=True)

        # Each hardware item is checked against the printed housing. The bevel
        # gear blanks intentionally overlap each other as packaging envelopes;
        # this does not test tooth engagement or a manufactured gear mesh.
        for part in ("lower", "lid"):
            for hardware in ("installed_differential", "pinion"):
                check(f"{part} housing clears {hardware} and its bearings",
                      f'intersection() {{ housing("{part}"); {hardware}(); }}',
                      empty=True)

        result = export('hsp_motor_sleeve(plist_remove("motor_bore_d", '
                        'rear_motor_sleeve_spec));')
        assert "ERROR: Assertion" in result.stderr, result.stderr
        assert "Missing hardware setting: motor_bore_d" in result.stderr, result.stderr
        print("PASS sleeve rejects missing required bore setting", flush=True)

        result = export(f"""
use <{ROOT}/scad/suspension/rear_axle/rear_axle_assembly.scad>
rear_axle_assembly(
  settings=plist_put("require_stock_fit", true, rear_axle_settings),
  housing=rear_housing_spec, arm=rear_lower_arm_spec, hub=rear_hub_spec,
  tower=rear_tower_spec, differential=rear_differential_spec,
  pinion=rear_pinion_spec, dogbone=rear_dogbone_spec,
  axle=rear_wheel_axle_spec, sleeve=rear_motor_sleeve_spec,
  shock=rear_shock_spec, fastener=rear_fastener_spec, layout=rear_chassis_layout());
""")
        assert "ERROR: Assertion" in result.stderr, result.stderr
        assert "Dogbone fit unresolved" in result.stderr, result.stderr
        print("PASS strict assembly rejects the stock dogbone mismatch", flush=True)



if __name__ == "__main__":
    main()
