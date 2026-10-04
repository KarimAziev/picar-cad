"""Check deck cutouts, component envelopes, and rejected equipment layouts."""

import ast
import math
from pathlib import Path
import subprocess
import tempfile

from scad_test_support import OPENSCAD, echo_value
from check_panel_stack_mesh import bounds, vertices
from check_gearmotor_encoder_mesh import connected_components, mesh_volume
from check_rear_chassis_mesh import read_triangles, ray_hits

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="rear-equipment-") as folder:
        source = Path(folder) / "fixture.scad"
        mesh = Path(folder) / "fixture.stl"
        preamble = f'''
include <{ROOT}/scad/suspension/rear_chassis/computed_params.scad>
use <{ROOT}/scad/suspension/rear_chassis/rear_chassis_frame.scad>
use <{ROOT}/scad/suspension/rear_chassis/rear_equipment.scad>
use <{ROOT}/scad/suspension/rear_chassis/rear_chassis.scad>
use <{ROOT}/scad/components/deck_component.scad>
'''

        def render(code: str, *, empty: bool = False) -> str:
            source.write_text(preamble + code)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics",
                 "--hardwarnings", "--export-format", "binstl",
                 "-o", str(mesh), str(source)], text=True, capture_output=True)
            log = result.stdout + result.stderr
            assert "ERROR:" not in log and "WARNING:" not in log, log
            if empty and "Current top level object is empty" in log:
                return log
            assert result.returncode == 0, log
            if empty:
                assert mesh_volume(mesh) < 0.00001, log
            return log

        for kind in ("voltmeter", "step_down", "perf_board"):
            log = render(f'''
component="{kind}"=="perf_board" ? perfboard_default_plist : [];
p=deck_component_props("{kind}",component);
echo(size=plist_get("size",p));
deck_component("{kind}",component);
''')
            size = ast.literal_eval(echo_value(log, "size"))
            actual = bounds(vertices(mesh))
            expected = [[-size[0] / 2, -size[1] / 2, 0],
                        [size[0] / 2, size[1] / 2, size[2]]]
            for axis in range(3):
                assert actual[0][axis] >= expected[0][axis] - 0.025, (kind, actual, size)
                assert actual[1][axis] <= expected[1][axis] + 0.025, (kind, actual, size)
        print("PASS deck component envelopes contain rendered hardware", flush=True)

        cases = (("production", "rear_equipment_specs", "rear_panel_specs", "rear_power_case_plist"),
                 ("converter", "rear_equipment_mixed", "[]", "undef"),
                 ("meters", "rear_equipment_meters", "[]", "undef"))
        for label, preset, panels, power_case in cases:
            fixture = f'''
l=rear_chassis_layout(equipment={preset}, panels={panels}, power_case={power_case});
parts=plist_get("equipment",l);
echo(mounts=[for(p=parts) [plist_get("pos",p), plist_get("rotation",p),
                           plist_get("bolt_spacing",plist_get("props",p)),
                           plist_get("bolt_d",plist_get("props",p))]]);
'''
            log = render(fixture + 'rear_chassis_frame(layout=l);')
            assert connected_components(mesh) == 1, label
            mounts = ast.literal_eval(echo_value(log, "mounts"))
            triangles = read_triangles(mesh)
            for pos, angle, pitch, diameter in mounts:
                r = math.radians(angle)
                for sx in (-1, 1):
                    for sy in (-1, 1):
                        x, y = sx * pitch[0] / 2, sy * pitch[1] / 2
                        cx = pos[0] + x * math.cos(r) - y * math.sin(r)
                        cy = pos[1] + x * math.sin(r) + y * math.cos(r)
                        assert not ray_hits(triangles, cx, cy), (label, cx, cy)
                        # Material remains just beyond each screw-head envelope.
                        assert ray_hits(triangles, cx + diameter + 0.5, cy), (label, cx, cy)
            # Hardware clears the plate, motor, fuse panel, case and support columns.
            render(fixture + '''
intersection() {
  rear_chassis(layout=l, anchor=undef, show_equipment=false,
               show_lidar=false, show_lidar_lid=false, show_lipo_packs=false);
  rear_equipment(l);
}
''', empty=True)
            # Inspect the annulus between the screw shaft and underside recess.
            probes = '''
for(p=parts) {
  props=plist_get("props",p);
  d=plist_get("bolt_d",props);
  pitch=plist_get("bolt_spacing",props);
  translate(plist_get("pos",p)) {
    rotate([0,0,plist_get("rotation",p)]) {
      for(x=[-pitch[0]/2,pitch[0]/2], y=[-pitch[1]/2,pitch[1]/2]) {
        translate([x+d*0.8,y,z]) { cube([0.05,0.05,0.05],center=true); }
      }
    }
  }
}
'''
            render(fixture + 'z=0.1; intersection() { rear_chassis_frame(layout=l);'
                   + probes + '}', empty=True)
            render(fixture + 'z=chassis_thickness-0.1; intersection() {'
                   'rear_chassis_frame(layout=l);' + probes + '}')
            assert mesh_volume(mesh) > 0, label
            print(f"PASS {label}: connected plate, aligned through-holes, underside recesses, no hardware collision",
                  flush=True)

        invalid = [
            ('[["kind","missing"]]', "Unknown deck component"),
            ('[["kind","voltmeter","zone","middle"]]', "zone must be"),
            ('[["kind","voltmeter","count",0]]', "count must be"),
            ('[["kind","voltmeter","count",100]]', "does not fit"),
            ('[["kind","perf_board","component",["size",[200,200,1.6]]]]', "does not fit"),
            ('[["kind","perf_board","zone","left","position",[0.5,0.5],'
             '"component",["component_h",100]]]', "does not fit"),
            ('[["kind","voltmeter","zone","left","position",[0.5,0.5]],'
             '["kind","voltmeter","zone","left","position",[0.5,0.5]]]', "does not fit"),
        ]
        for specs, message in invalid:
            source.write_text(preamble + f'echo(rear_chassis_layout(equipment={specs}));')
            result = subprocess.run(
                [OPENSCAD, "--enable=textmetrics", "--hardwarnings",
                 "-o", str(source.with_suffix('.csg')), str(source)],
                text=True, capture_output=True)
            log = result.stdout + result.stderr
            assert "ERROR: Assertion" in log and message in log, log
            assert "WARNING:" not in log, log
        print("PASS invalid kinds, zones, counts, oversize, height and collisions rejected", flush=True)


if __name__ == "__main__":
    main()
