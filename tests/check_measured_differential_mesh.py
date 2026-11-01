# Module: Measured differential geometry and installation checks.
#
# Author: Karim Aziiev <karim.aziiev@gmail.com>
# License: GPL-3.0-or-later

"""Check caliper dimensions, cup machining and the rear axle transformation."""

from math import isclose, pi
from pathlib import Path
import subprocess
import tempfile

import trimesh

from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]
Bounds = tuple[tuple[float, float, float], tuple[float, float, float]]


def main() -> None:
    common = f"""
include <{ROOT}/scad/suspension/rear_axle/hardware_params.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/placeholders/differential.scad>
use <{ROOT}/scad/placeholders/hsp_rear_drivetrain.scad>
$fn = 64;
module measured() {{
  differential(pl=differential_spec(), anchor=[1, 1, 1], slot_mode=false);
}}
module installed() {{
  hsp_rear_differential(pl=rear_differential_spec, anchor=[1, 1, 1],
                        slot_mode=false, show_bearings=false);
}}
"""
    with tempfile.TemporaryDirectory(prefix="measured-differential-") as folder:
        source = Path(folder) / "fixture.scad"
        output = Path(folder) / "fixture.stl"

        def check(label: str, code: str, *, empty: bool = False,
                  bounds: Bounds | None = None,
                  volume: float | None = None) -> None:
            source.write_text(common + code)
            output.unlink(missing_ok=True)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics",
                 "--hardwarnings", "--export-format", "binstl",
                 "-o", str(output), str(source)],
                capture_output=True, text=True,
            )
            log = result.stdout + result.stderr
            assert "ERROR:" not in log and "WARNING:" not in log, (label, log)
            if empty and "Current top level object is empty" in log:
                print(f"PASS {label}", flush=True)
                return
            assert result.returncode == 0, (label, log)
            mesh = trimesh.load_mesh(output)
            assert isinstance(mesh, trimesh.Trimesh), (label, type(mesh))
            if empty:
                assert abs(mesh.volume) < 1e-6, (label, mesh.volume)
            else:
                assert mesh.is_watertight and mesh.is_winding_consistent, label
                assert mesh.is_volume and mesh.volume > 0, label
                assert mesh.nondegenerate_faces().all(), label
                assert mesh.unique_faces().all(), label
            if bounds is not None:
                for actual_row, expected_row in zip(mesh.bounds, bounds):
                    for actual, expected in zip(actual_row, expected_row):
                        assert isclose(float(actual), expected, abs_tol=1e-5), (
                            label, mesh.bounds, bounds)
            if volume is not None:
                # Polygonal circles approximate the analytic capsule section.
                assert isclose(float(mesh.volume), volume, rel_tol=0.005), (
                    label, mesh.volume, volume)
            print(f"PASS {label}", flush=True)

        check("measured differential has 38 by 38 by 45.1 mm bounds",
              "measured();", bounds=((0, 0, 0), (38, 38, 45.1)))
        check("axle adapter preserves the measured envelope along X",
              "installed();", bounds=((0, 0, 0), (45.1, 38, 38)))

        # The axial midpoint of the measured case lies at Z=24.55. A thin
        # section excludes the crown and distinguishes the capsule from both
        # a circular OD25 case and an unrounded rectangular approximation.
        check("case section is the measured 25 by 20 mm capsule", """
intersection() {
  measured();
  translate([0, 0, 24.45]) { cube([38, 38, 0.2]); }
}
""", bounds=((6.5, 9, 24.45), (31.5, 29, 24.65)),
              volume=(pi * 10 ** 2 + 5 * 20) * 0.2)

        check("adapter preserves the capsule's radial orientation", """
intersection() {
  installed();
  translate([24.45, 0, 0]) { cube([0.2, 38, 38]); }
}
""", bounds=((24.45, 6.5, 9), (24.65, 31.5, 29)))

        check("support journals retain their measured 9.17 mm diameter", """
intersection() {
  measured();
  translate([0, 0, 10.3]) { cube([38, 38, 0.2]); }
}
""", bounds=((14.415, 14.415, 10.3), (23.585, 23.585, 10.5)))

        # Both probes lie beyond the 8.3 mm slot depth, inside the remaining
        # 1.7 mm cup root. The axial bore continues through that root.
        check("both cup bores remain open below the slot floors", """
intersection() {
  measured();
  for (z = [9.15, 35.95]) {
    translate([19, 19, z]) { cylinder(d=5.8, h=0.4, center=true); }
  }
}
""", empty=True)
        check("both cups retain solid walls below the slot floors", """
difference() {
  union() {
    for (z = [9.15, 35.95]) {
      translate([19, 22.8, z]) { cube([0.2, 0.2, 0.2], center=true); }
    }
  }
  measured();
}
""", empty=True)
        check("canonical cup slots open along Y", """
intersection() {
  measured();
  for (z = [3, 42.1]) {
    translate([19, 19, z]) {
      rotate([90, 0, 0]) { cylinder(d=2, h=9.82, center=true); }
    }
  }
}
""", empty=True)
        check("canonical cup walls remain across X", """
difference() {
  union() {
    for (z = [3, 42.1]) {
      translate([22.8, 19, z]) { cube([0.2, 0.2, 0.2], center=true); }
    }
  }
  measured();
}
""", empty=True)
        check("adapter accepts both measured dogbone balls and Z-axis pins", """
intersection() {
  installed();
  union() {
    for (p = hsp_rear_differential_output_positions(rear_differential_spec)) {
      translate(p) {
        sphere(d=plist_get("ball_d", rear_dogbone_spec));
        cylinder(d=plist_get("pin_d", rear_dogbone_spec),
                 h=plist_get("pin_l", rear_dogbone_spec), center=true);
      }
    }
  }
}
""", empty=True)

        check("rotated rounded case stays inside its swept clearance", """
rounded = plist_put("case_radius_factor", 0.2, differential_spec());
difference() {
  union() {
    for (angle = [0, 17, 45, 73, 90]) {
      rotate([0, 0, angle]) {
        differential(pl=rounded, anchor=[0, 0, 1], slot_mode=false);
      }
    }
  }
  differential(pl=rounded, anchor=[0, 0, 1], slot_mode=true);
}
""", empty=True)

        # Anchors translate the nominal reference box in both modes. Slot
        # clearances extend beyond that box without shifting its datum.
        for mode in (False, True):
            scad_mode = "true" if mode else "false"
            check(f"canonical and adapter anchors preserve slot_mode={mode}",
                  f"""
module anchored(kind) {{
  if (kind == 0) {{
    differential(pl=differential_spec(), anchor=[0, -1, 1],
                 slot_mode={scad_mode});
  }} else {{
    hsp_rear_differential(pl=rear_differential_spec, anchor=[-1, 0, 1],
                         slot_mode={scad_mode}, show_bearings=false);
  }}
}}
module translated(kind) {{
  if (kind == 0) {{
    translate([-19, -38, 0]) {{
      differential(pl=differential_spec(), anchor=[1, 1, 1],
                   slot_mode={scad_mode});
    }}
  }} else {{
    translate([-45.1, -19, 0]) {{
      hsp_rear_differential(pl=rear_differential_spec, anchor=[1, 1, 1],
                           slot_mode={scad_mode}, show_bearings=false);
    }}
  }}
}}
for (kind = [0, 1]) {{
  difference() {{ anchored(kind); translated(kind); }}
  difference() {{ translated(kind); anchored(kind); }}
}}
""", empty=True)


if __name__ == "__main__":
    main()
