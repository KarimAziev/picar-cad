"""Check printed power-enclosure parts, service access and mounting clearances.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""

import ast
from pathlib import Path
import subprocess
import tempfile

from scad_test_support import OPENSCAD, echo_value
from check_gearmotor_encoder_mesh import connected_components, mesh_volume
from check_panel_stack_mesh import bounds, vertices, transformed_bounds

ROOT = Path(__file__).resolve().parents[1]
COMMON = f'''
include <{ROOT}/scad/parameters.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/lib/enclosure_panels.scad>
use <{ROOT}/scad/lib/slots.scad>
use <{ROOT}/scad/placeholders/heat_insert_nut.scad>
use <{ROOT}/scad/lib/transforms.scad>
use <{ROOT}/scad/components/step_down_enclosure/step_down_voltage_enclosure.scad>
p=step_down_enclosure_props();
s=plist_get("size",p);
b=plist_get("body_size",p);
pl=plist_get("plist",p);
module shell() {{
  _power_enclosure_base(p);
  translate([0,0,b[2]]) {{ _power_enclosure_lid(p); }}
}}
'''


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="power-enclosure-") as folder:
        source = Path(folder) / "fixture.scad"
        mesh = source.with_suffix(".stl")

        def render(code: str, *, empty: bool = False) -> str:
            source.write_text(COMMON + code)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
                 "--export-format", "binstl", "-o", str(mesh), str(source)],
                text=True, capture_output=True)
            log = result.stdout + result.stderr
            assert "ERROR:" not in log and "WARNING:" not in log, log
            if empty and "Current top level object is empty" in log:
                return log
            assert result.returncode == 0, log
            if empty:
                assert mesh_volume(mesh) < 0.00001, (mesh_volume(mesh), log)
            return log

        for part, count in (("base", 1), ("lid", 1), ("both", 2)):
            render(f'step_down_enclosure_printable(part="{part}");')
            assert connected_components(mesh) == count, part
            assert abs(bounds(vertices(mesh))[0][2]) < 0.00001, part
        print("PASS base and lid are connected, separate printable parts on Z=0", flush=True)

        render('''intersection() {
  _power_enclosure_base(p);
  translate([0,0,b[2]]) { _power_enclosure_lid(p); }
}''', empty=True)
        render('intersection() { shell(); _power_enclosure_boards(p); }', empty=True)
        render('''intersection() { shell();
  difference() {_power_enclosure_fasteners(p); _power_enclosure_inserts(p);}
}''', empty=True)
        render('''intersection() {
  translate([-s[0]/2,-s[1]/2,-6]) {cube([s[0],s[1],5.999]);}
  _power_enclosure_boards(p);
}''', empty=True)
        print("PASS lid lip, populated boards, lid screws, nuts and PCB screws clear the printed parts/deck",
              flush=True)

        for config in (
            '[]',
            '["lid",["slots",[],"texts",[],"vents",["enabled",false]],'
            '"header_slot",["enabled",false]]',
            '["inner_size",["120%","150%","100%"],"board_pos",["60%","40%"],'
            '"cable_tie",["enabled",false],'
            '"walls",["left",["t",6],"right",["t",3],'
            '"rear",["t",4],"front",["t",5]]]',
            '["step_down_voltage",plist_merge(step_down_voltage_plist,'
            '["vin",["rotation_z",0,"base_w",12,"thickness",7,"x_offset",1,"y_offset",2],'
            '"vout",["rotation_z",45,"base_w",10,"thickness",6,"x_offset",2,"y_offset",3]]),'
            '"sensor_current",plist_merge(ina_plist,'
            '["screw_terminal",["base_w",12,"thickness",7,"y_offset",1]])]',
        ):
            setup = f'q=step_down_enclosure_props({config});\n'
            render(setup + '''intersection() {
  _power_enclosure_lid(q);
  for(fp=plist_get("terminal_footprints",q)) {
    translate([fp[0][0]-fp[1][0]/2-0.5,fp[0][1]-fp[1][1]/2-0.5,-10]) {
      cube([fp[1][0]+1,fp[1][1]+1,30]);
    }
  }
}''', empty=True)
            render(setup + '_power_enclosure_lid(q);')
            assert connected_components(mesh) == 1, config
        print("PASS all three terminal footprints have clear top access through roof and lip, "
              "including shifted boards, resized/rotated terminals and disabled vents", flush=True)

        for mode in ("engraved", "raised"):
            config = f'["lid",["text_mode","{mode}","vents",["enabled",false]]]'
            setup = f'q=step_down_enclosure_props({config});\n'
            render(setup + '''intersection() {
  _power_enclosure_lid(q);
  for(fp=plist_get("component_footprints",q)) {
    translate([fp[0][0]-fp[1][0]/2,fp[0][1]-fp[1][1]/2,-10]) {
      cube([fp[1][0],fp[1][1],30]);
    }
  }
}''', empty=True)
            render(setup + '_power_enclosure_lid(q);')
            assert connected_components(mesh) == 1, mode
            assert abs(bounds(vertices(mesh))[1][2]
                       - (3.2 if mode == "raised" else 2.4)) < 0.00001
            render(f'step_down_enclosure_printable(part="lid",plist={config});')
            assert connected_components(mesh) == 1, mode
            assert abs(bounds(vertices(mesh))[0][2]) < 0.00001, mode
        print("PASS power-component footprints stay open with vents disabled; "
              "engraved/raised lids are connected and print on Z=0", flush=True)

        render('''q=step_down_enclosure_props([
  "step_down_voltage",plist_merge(step_down_voltage_plist,
    ["inductor",["size",[8,6,4],"offsets",[2,2]],
     "can_capacitors",[["d",8,"h",7,"base_h",2,"position",[-10,4,0]]],
     "smd_chip_specs",[[4,3,1.5,0.8,[-1,-7,0],[0,0,30]]]]),
  "lid",["text_mode","raised","text_height",4,"vents",["enabled",false]]]);
intersection() {
  _power_enclosure_lid(q);
  for(fp=plist_get("component_footprints",q)) {
    translate([fp[0][0]-fp[1][0]/2,fp[0][1]-fp[1][1]/2,-10]) {
      cube([fp[1][0],fp[1][1],30]);
    }
  }
}''', empty=True)
        print("PASS resized inductor/capacitor and rotated chip footprints retain lid access", flush=True)

        render('''q=step_down_enclosure_props(["lid",["text_mode","raised",
  "texts",[["text","MMMMMMMM","at","regulator","size",8]],
  "text_height",2]]);
intersection() {
  _power_enclosure_lid(q);
  for(fp=concat(plist_get("terminal_footprints",q),
                plist_get("component_footprints",q))) {
    translate([fp[0][0]-fp[1][0]/2,fp[0][1]-fp[1][1]/2,-10]) {
      cube([fp[1][0],fp[1][1],30]);
    }
  }
}''', empty=True)
        print("PASS raised labels cannot cover terminal or power-component openings", flush=True)

        render('''intersection() {_power_enclosure_base(p); _power_enclosure_inserts(p,slot_mode=true);}''', empty=True)
        render('''intersection() {_power_enclosure_base(p); _power_enclosure_inserts(p);}''')
        assert connected_components(mesh) == 4
        interference = bounds(vertices(mesh))
        assert abs(interference[0][2] - (25 - 5 + 1.6)) < 0.001, interference
        assert abs(interference[1][2] - (25 - (1.6 + 1.6 / 2) + 0.1)) < 0.001, interference
        render('''difference() {
  intersection() {_power_enclosure_base(p); _power_enclosure_inserts(p);}
  for(pos=plist_get("lid_positions",p)) {
    translate(pos+[0,0,b[2]-5+1.6]) {
      difference() {
        cylinder(d=4.01,h=1.6,$fn=100);
        cylinder(d=3.2,h=1.6,$fn=100);
      }
    }
  }
}''', empty=True)
        render('''difference() {
  for(pos=plist_get("lid_positions",p)) {
    translate(pos+[0,0,b[2]-plist_get("insert_depth",p)-0.1]) {
      cylinder(d=3,h=0.09,$fn=32);
    }
  }
  _power_enclosure_base(p);
}''', empty=True)
        render('''intersection() {
  translate([0,0,b[2]+12]) {_power_enclosure_lid(p);}
  _power_enclosure_fasteners(p,exploded=12);
}''', empty=True)
        print("PASS shared stepped insert cutters, intact blind bottoms, lower-knurl interference and exploded lid screws",
              flush=True)

        render('''intersection() {
  _power_enclosure_base(p);
  for(m=plist_get("board_mounts",p)) {
    translate(m[0]+[0,0,8.5]) {cylinder(d=5,h=50,$fn=32);}
  }
}''', empty=True)
        print("PASS all six PCB fasteners have straight screwdriver access with the lid removed",
              flush=True)

        render('''intersection() {
  _power_enclosure_base(p);
  four_corner_children(plist_get("bolt_spacing",p)) {
    translate([0,0,-0.1]) {cylinder(d=3,h=5,$fn=32);}
  }
}''', empty=True)
        print("PASS chassis mounting holes remain open through the captive-nut floor", flush=True)

        for slot in ([3.2, 1.6], [4.2, 2], [5.2, 2]):
            render(f'''q=step_down_enclosure_props(["cable_tie",["slot_size",{slot}]]);
intersection() {{
  _power_enclosure_tie_slots(q);
  union() {{_power_enclosure_boards(q); _power_enclosure_fasteners(q);}}
}}''', empty=True)
        print("PASS 3, 4 and 5 mm cable-tie paths clear PCB screws and chassis nuts", flush=True)

        for config in ('[]', '["walls",["front",["vents",["opening_mode","omit"]]]]',
                       '["walls",["front",["t",6,"cutouts",'
                       '[["at","sensor_terminal","l",11,"bottom",10,"corner_r",2]]]]]'):
            render(f'''q=step_down_enclosure_props({config});
wall=plist_get("front",plist_get("walls",q));
panel=plist_get("front",plist_get("panels",q));
port=plist_get("openings",panel)[0];
size=plist_get("body_size",q); t=plist_get("t",wall);
gap=plist_get("opening_gap",plist_get("vents",panel));
pos=plist_get("pos",port); dims=plist_get("size",port);
difference() {{
  translate([plist_get("inner_min",q)[0]+pos[0]+0.1,
             size[1]/2-t+0.1,plist_get("floor_t",q)+pos[1]-gap+0.1]) {{
    cube([dims[0]-0.2,t-0.2,gap-0.2]);
  }}
  _power_enclosure_base(q);
}}''', empty=True)
        print("PASS outlet margins survive independent vent modes and 6 mm front walls", flush=True)

        for mode in ("shorten", "omit", "clip"):
            render(f'''q=step_down_enclosure_props(["walls",["front",[
  "cutouts",[["at","sensor_terminal","l",11,"bottom",8,
              "corner_r",3,"rim_chamfer",4,"vent_gap","10%"]],
  "vents",["size",[3,17],"margin",[10,10,2,1],"opening_mode","{mode}"]]]]);
panel=plist_get("front",plist_get("panels",q));
gap=plist_get("vent_gap",plist_get("openings",panel)[0]);
intersection() {{
  _power_enclosure_vents(q);
  _power_enclosure_wall_plane(q,"front") {{
    offset(delta=gap-0.001) {{enclosure_panel_openings(panel);}}
  }}
}}''', empty=True)
        print("PASS all three vent modes preserve per-opening clearance around rounded cutouts and rim chamfers",
              flush=True)

        for config in (
            '["inner_size",["110%","110%","100%"],'
            '"insert",["d",4.6,"flang_d",5.6,"h",8,"hole_d",3]]',
            '["insert",["use_taper",true]]',
            '["insert",["h",24]]',
            '["walls",["left",["t",6],"right",["t",3],'
            '"rear",["t",4],"front",["t",5]]]',
            '["inner_size",["110%","120%","130%"],'
            '"lid",["texts",[],"vents",["size",[2,4],"gap",[3,3]]]]',
        ):
            setup = f'''q=step_down_enclosure_props({config});
qb=plist_get("body_size",q);
module case_shell() {{
  _power_enclosure_base(q);
  translate([0,0,qb[2]]) {{_power_enclosure_lid(q);}}
}}
'''
            render(setup + 'step_down_enclosure_printable(part="both",plist=' + config + ');')
            assert connected_components(mesh) == 2, config
            render(setup + '''intersection() {
  _power_enclosure_base(q);
  translate([0,0,qb[2]]) {_power_enclosure_lid(q);}
}''', empty=True)
            render(setup + '''intersection() {
  case_shell();
  union() {
    _power_enclosure_boards(q);
    difference() {_power_enclosure_fasteners(q); _power_enclosure_inserts(q);}
  }
}''', empty=True)
            render(setup + '''intersection() {
  _power_enclosure_boards(q); _power_enclosure_fasteners(q);
}''', empty=True)
        print("PASS larger/longer inserts, asymmetric walls and percentage-sized cavities fit hardware/lids",
              flush=True)

        thick = '''q=step_down_enclosure_props([
  "walls",["left",["t",6],"right",["t",3],"rear",["t",4,
    "cutouts",[["l",13,"bottom",7,"corner_r",2]]],"front",["t",5]]]);
'''
        render(thick + '''intersection() {
  union() {
    for(name=["left","right","rear","front"]) {
      panel=plist_get(name,plist_get("panels",q));
      cut=plist_get("openings",panel)[0];
      _power_enclosure_wall_plane(q,name,extra=-0.02) {
        translate(plist_get("pos",cut)+plist_get("size",cut)/3) {
          square(plist_get("size",cut)/3);
        }
      }
    }
  }
  _power_enclosure_base(q);
}''', empty=True)
        render(thick + '''intersection() {
  _power_enclosure_base(q);
  union() {
    for(name=["left","right","rear","front"]) {
      cut=plist_get("openings",plist_get(name,plist_get("panels",q)))[0];
      _power_enclosure_wall_plane(q,name,extra=-0.02) {
        translate(plist_get("pos",cut)+[0.01,0.01]) {
          square([0.1,0.1]);
        }
      }
    }
  }
}''')
        assert connected_components(mesh) == 4
        print("PASS all four cutouts cross their actual wall thickness and retain rounded bottom corners",
              flush=True)

        render(thick + '''intersection() {
  union() {
    _power_enclosure_base(q);
    difference() {
      translate([-50,-25,-6]) {cube([100,50,6]);}
      translate(plist_get("mount_pos",q)) {pcb_mount_slots(q,6);}
    }
  }
  for(pos=plist_get("mount_positions",q)) {
    translate(pos+[0,0,-6]) {cylinder(d=3,h=6+plist_get("floor_t",q),$fn=32);}
  }
}''', empty=True)

        for slots in ('"auto"', '[["pos",["10%","20%"],"size",["80%","60%"],"corner_r",1]]'):
            config = f'["parent_slots",["enabled",true,"slots",{slots}]]'
            setup = f'q=step_down_enclosure_props({config});\n'
            render(setup + 'step_down_enclosure_parent_slots(q,6);')
            assert mesh_volume(mesh) > 50, slots
            render(setup + '''intersection() {
  step_down_enclosure_parent_slots(q,6);
  union() {
    for(k=plist_get("keepouts",q)) {
      translate(k[0]+[0,0,-6]) {cylinder(r=k[1]+1,h=10,$fn=48);}
    }
    _power_enclosure_tie_slots(q);
  }
}''', empty=True)
            render(setup + '''intersection() {
  _power_enclosure_base(q);
  step_down_enclosure_parent_slots(q,6);
}''', empty=True)
            render(f'step_down_enclosure_printable(part="base",plist={config});')
            assert connected_components(mesh) == 1, slots
            render(setup + '''intersection() {
  step_down_voltage_enclosure(plist=''' + config + ''',anchor=[0,0,1],
                              parent_t=6,slot_mode=true);
  translate([-50,-20,-5]) {cube([100,40,3]);}
}''')
            assert mesh_volume(mesh) > 50, slots
        print("PASS automatic/explicit parent wiring slots align with the floor and preserve connected fastener bridges",
              flush=True)

        for orientation, anchor in (("wlh", [1, 1, 1]), ("lwh", [-1, 0, 1]),
                                    ("whl", [0, -1, 0]), ("lhw", [1, 0, -1]),
                                    ("hlw", [-1, 1, 0]), ("hwl", [0, 0, 1])):
            log = render(f'''echo(size=s); echo(body=b);
echo(lid_t=plist_get("t",plist_get("lid",p)));
step_down_voltage_enclosure(anchor={anchor},orientation="{orientation}",
                           show_hardware=false,show_fasteners=false);''')
            size = ast.literal_eval(echo_value(log, "size"))
            body = ast.literal_eval(echo_value(log, "body"))
            lid_t = float(echo_value(log, "lid_t"))
            expected = transformed_bounds(
                [[-size[0]/2, -size[1]/2, 0],
                 [size[0]/2, size[1]/2, body[2] + lid_t]],
                size, orientation, anchor)
            actual = bounds(vertices(mesh))
            for face in range(2):
                assert all(abs(a-b) < 0.002 for a, b in zip(actual[face], expected[face])), (
                    orientation, anchor, actual, expected)
        print("PASS all six orientations preserve the closed reference envelope and anchors", flush=True)

        render('''step_down_voltage_enclosure(anchor=[0,0,1]);''')
        actual = bounds(vertices(mesh))
        assert actual[0][2] >= -0.00001, actual
        print("PASS complete assembly exports with all PCB screw heads above the mounting plane", flush=True)


if __name__ == "__main__":
    main()
