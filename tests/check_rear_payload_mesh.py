"""Check standalone panel placement and raised rear payload mounting geometry."""
import ast
import math
from pathlib import Path
import subprocess
import tempfile

from scad_test_support import OPENSCAD, echo_value
from check_gearmotor_encoder_mesh import connected_components, mesh_volume
from check_panel_stack_mesh import ORIENTATIONS, bounds, close, transformed_bounds, vertices
from check_rear_chassis_mesh import read_triangles, ray_hits

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="rear-payload-") as folder:
        source = Path(folder) / "fixture.scad"
        mesh = Path(folder) / "fixture.stl"

        def render(code: str, empty: bool = False) -> str:
            source.write_text(code)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--enable=roof",
                 "--hardwarnings", "--export-format", "binstl", "-o", str(mesh), str(source)],
                text=True, capture_output=True)
            log = result.stdout + result.stderr
            assert "ERROR:" not in log and "WARNING:" not in log, log
            if empty and "Current top level object is empty" in log:
                return log
            assert result.returncode == 0, log
            if empty:
                assert mesh_volume(mesh) < 0.00001, (mesh_volume(mesh), log)
            return log

        for name, hardware_flag in (("control_panel", "show_buttons"), ("fuse_panel", "show_fuses")):
            preamble = (f'use <{ROOT}/scad/panel_stack/{name}.scad>\n$fn=32;\n'
                        f'echo(size={name}_oriented_size(show_standoff=false));\n'
                        f'echo(bolts={name}_oriented_bolt_spacing());\n')
            args = f"show_standoff=false, {hardware_flag}=false"
            log = render(preamble + f'{name}({args}, anchor=[0,0,1]);')
            size = ast.literal_eval(echo_value(log, "size"))
            bolts = ast.literal_eval(echo_value(log, "bolts"))
            body = bounds(vertices(mesh))
            # Rounded profile tessellation may fall just inside its nominal box.
            for axis in (0, 1):
                assert body[0][axis] >= -size[axis]/2-0.002
                assert body[1][axis] <= size[axis]/2+0.002
            close([body[0][2], body[1][2]], [0, size[2]])
            render(preamble + f'{name}({args}, anchor=[0,0,1], slot_mode=true, slot_thickness=7);')
            slots = bounds(vertices(mesh))
            for orientation in ORIENTATIONS:
                for mode in ("size", "bolts"):
                    reference = size if mode == "size" else bolts
                    for slot, baseline in ((False, body), (True, slots)):
                        render(preamble + f'{name}({args}, orientation="{orientation}", '
                               f'anchor=[-1,0,1], anchor_mode="{mode}", '
                               f'slot_mode={str(slot).lower()}, slot_thickness=7);')
                        for actual, expected in zip(bounds(vertices(mesh)),
                                                     transformed_bounds(baseline, reference, orientation, [-1,0,1])):
                            close(actual, expected)
            print(f"PASS {name}: solid/slot alignment in six orientations and both anchor modes", flush=True)

        # The envelope includes the real panel, stems and both switch throws.
        for orientation in ("wlh", "lwh"):
            for reverse in (False, True):
                render(f'''
use <{ROOT}/scad/panel_stack/control_panel.scad>
$fn=32;
regions=control_panel_clearance_regions("{orientation}");
difference() {{
  scale({[-1 if reverse and orientation == "wlh" else 1, -1 if reverse and orientation == "lwh" else 1, 1]}) {{
    control_panel(orientation="{orientation}", anchor=[0,0,1]);
  }}
  for (b=regions) {{
    translate(b[0]-[0.001,0.001,0.001]) {{ cube(b[1]-b[0]+[0.002,0.002,0.002]); }}
  }}
}}
''', empty=True)
        print("PASS control clearance regions: low hardware and both lever positions enclosed", flush=True)

        common = f'''
include <{ROOT}/scad/suspension/rear_chassis/computed_params.scad>
use <{ROOT}/scad/suspension/rear_chassis/rear_chassis_frame.scad>
use <{ROOT}/scad/suspension/rear_chassis/rear_payload.scad>
use <{ROOT}/scad/motor_brackets/rc/gearbox_bracket.scad>
use <{ROOT}/scad/panel_stack/panel_stack.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_case.scad>
use <{ROOT}/scad/placeholders/lipo_pack.scad>
use <{ROOT}/scad/lib/transforms.scad>
layout=rear_chassis_layout();
payload=plist_get("power_case",layout);
module panels() {{
  for (p=plist_get("panels",layout)) {{
    translate(plist_get("pos",p)+[0,0,chassis_thickness]) {{
      panel_component(plist_get("type",p), orientation=plist_get("orientation",p));
    }}
  }}
}}
module motor() {{
  translate(plist_get("motor_pos",layout)+[0,0,chassis_thickness]) {{
    rotate(plist_get("motor_rotation",layout)) {{
      gearmotor_bracket(params=plist_get("bracket",layout), anchor=[0,0,1]);
    }}
  }}
}}
module payload_body() {{
  rear_power_payload(payload, show_lidar=false, show_lid=false);
}}
module packs() {{
  pl=plist_get("plist",payload);
  props=multi_lipo_pack_props(pl);
  packs=plist_get("lipo_packs",pl);
  positions=plist_get("pack_positions",props);
  canonical=plist_get("canonical_size",props);
  translate(plist_get("pos",payload)+[0,0,plist_get("mount_z",payload)]) {{
    with_orientation(from="wlh", to=plist_get("orientation",props), size=canonical, anchor=[0,0,1]) {{
      rotate([0,0,plist_get("power_rotation",pl,0)]) {{
        with_anchor(anchor=[0,0,1], size=plist_get("body_size",props)) {{
          for (i=[0:len(packs)-1]) {{
            translate(positions[i]) {{ lipo_pack_from_pl(packs[i], anchor=[1,1,1]); }}
          }}
        }}
      }}
    }}
  }}
}}
'''
        # Assembly clearance is checked for the configured production loadout.
        label = "production"
        preamble = common
        for other in ("motor", "panels"):
            render(preamble + f"intersection() {{ rear_power_payload(payload); {other}(); }}", empty=True)
            print(f"PASS {label}: raised case/posts clear installed {other}", flush=True)
        render(preamble + "intersection() { motor(); panels(); }", empty=True)
        render(preamble + "intersection() { packs(); "
               "rear_power_payload(payload, show_packs=false, show_lidar=false, show_lid=false); }", empty=True)
        print(f"PASS {label}: battery clears floor, retaining nuts and case", flush=True)
        # Harness terminal contact is checked by check_lid_wiring_mesh.py.
        render(preamble + "intersection() { payload_body(); "
               "rear_power_payload(payload, show_case=false, show_standoffs=false, "
               "show_wiring=false); }", empty=True)
        render(preamble + "intersection() { rear_chassis_frame(layout=layout); "
               "rear_power_payload(payload, show_case=false, show_lidar=false, show_lid=false); }", empty=True)
        print(f"PASS {label}: lidar/cover clear battery and support fasteners clear plate", flush=True)
        log = render(preamble + '''
holes=concat([for (p=plist_get("panels",layout), x=[-1,1], y=[-1,1])
  let (pos=plist_get("pos",p), span=plist_get("bolt_spacing",p))
  [pos[0]+x*span[0]/2,pos[1]+y*span[1]/2,panel_stack_bolt_cbore_dia/2+0.4]],
  [for (p=plist_get("mount_holes",payload)) [p[0],p[1],plist_get("radius",payload)+0.4]]);
echo(holes=holes);
rear_chassis_frame(layout=layout);
''')
        assert connected_components(mesh) == 1
        triangles = read_triangles(mesh)
        holes = ast.literal_eval(echo_value(log, "holes"))
        for x, y, radius in holes:
            assert not ray_hits(triangles, x, y), (label, "blocked hole", x, y)
            for angle in range(0, 360, 45):
                assert ray_hits(triangles, x+radius*math.cos(math.radians(angle)),
                                y+radius*math.sin(math.radians(angle))), (label, "missing land", x, y)
        print(f"PASS {label}: one chassis solid and {len(holes)} clear panel/payload holes", flush=True)
        log = render(preamble + '''
echo(bottom=plist_get("mount_z",payload));
translate(plist_get("pos",payload)) {
  multi_lipo_pack_case(plist_get("plist",payload), anchor=[0,0,1],
    target_h=plist_get("target_h",payload), parent_thickness=chassis_thickness,
    show_standoffs=false,show_packs=false,show_rail_bolts=false,show_rail_nuts=false);
}
''')
        close([bounds(vertices(mesh))[0][2]], [ast.literal_eval(echo_value(log, "bottom"))])
        assert connected_components(mesh) == 1
        print(f"PASS {label}: hiding standoffs preserves case height and printable body", flush=True)


if __name__ == "__main__":
    main()
