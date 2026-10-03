"""Check rear supply routing, terminal passages and the reversed case rails.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""
from pathlib import Path
import subprocess
import tempfile

from scad_test_support import OPENSCAD
from check_gearmotor_encoder_mesh import mesh_volume

ROOT = Path(__file__).resolve().parents[1]
COMMON = f'''
include <{ROOT}/scad/suspension/rear_chassis/computed_params.scad>
use <{ROOT}/scad/suspension/rear_chassis/rear_power_wiring.scad>
use <{ROOT}/scad/suspension/rear_chassis/rear_equipment.scad>
use <{ROOT}/scad/suspension/rear_chassis/rear_chassis_frame.scad>
use <{ROOT}/scad/lipo_pack_case/lid_wiring.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_case.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_lid.scad>
use <{ROOT}/scad/placeholders/crimp_terminals/ring_terminal.scad>
use <{ROOT}/scad/lib/wire.scad>
l=rear_chassis_layout();
payload=plist_get("power_case",l); pl=plist_get("plist",payload);
p=rear_power_wiring_props(l);
paths=concat(plist_get("feeds",p),[plist_get("converter_path",p)]);
module case_body() {{
 translate(plist_get("pos",payload)) {{
  multi_lipo_pack_case(pl,anchor=[0,0,1],target_h=plist_get("target_h",payload),
                      show_standoffs=false,show_packs=false,show_rail_bolts=false);
 }}
}}
module lid_body() {{
 translate(plist_get("pos",payload)+[0,0,plist_get("mount_z",payload)]) {{
  multi_lipo_pack_lid_on_case(pl,show_lidar=false,show_equipment=false,
                             show_adapter=false,show_wago_brackets=false);
 }}
}}
module lead(path) {{
 wire_path(path,d=plist_get("d",p),cut_len=undef,mode="none");
}}
module fuse_passages() {{
 difference() {{
  rear_power_harness(l,slot_mode=true);
  rear_power_harness(l,slot_mode=true,config=plist_merge(rear_power_wiring,
      ["fuse_hole_columns",0,"fuse_outlet",false]));
 }}
}}
'''


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="rear-power-wiring-") as folder:
        source = Path(folder) / "fixture.scad"
        mesh = Path(folder) / "fixture.stl"

        def empty(code: str) -> None:
            source.write_text(COMMON + code)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
                 "--export-format", "binstl", "-o", str(mesh), str(source)],
                capture_output=True, text=True)
            log = result.stdout + result.stderr
            assert "ERROR:" not in log and "WARNING:" not in log, log
            if "Current top level object is empty" in log:
                return
            assert result.returncode == 0, log
            assert mesh_volume(mesh) < 0.00001, (mesh_volume(mesh), log)

        empty('''intersection() {
 rear_chassis_frame(layout=l);
 fuse_passages();
}''')
        print("PASS fuse wire passages cut through the complete chassis", flush=True)
        empty('''difference() {
 intersection() {
  minkowski() {
   fuse_passages();
   cylinder(r=1.99,h=0.001,$fn=64);
  }
  translate([-200,-300,0.01]) {cube([400,600,plist_get("size",l)[2]-0.02]);}
 }
 union() {rear_chassis_frame(layout=l); fuse_passages();}
}''')
        print("PASS fuse passages retain 2 mm lands at edges, mounts and joint pins", flush=True)
        empty('''intersection() {
 rear_power_harness(l);
 union() {rear_chassis_frame(layout=l); case_body(); lid_body();}
}''')
        print("PASS rear wires and ring clear the chassis, case and closed lid", flush=True)
        empty('''union() {
 for(i=[0:len(paths)-2],j=[i+1:len(paths)-1]) {
  intersection() {lead(paths[i]); lead(paths[j]);}
 }
 intersection() {
  rear_power_harness(l);
  translate(plist_get("pos",payload)+[0,0,plist_get("mount_z",payload)]) {
   lid_wiring(pl);
  }
 }
}''')
        print("PASS distribution wires stay separate and clear the battery harness", flush=True)
        empty('''intersection() {
 rear_chassis_frame(layout=l);
 for(h=plist_get("holes",p)) {
  translate(h+[0,0,-5]) {ring_terminal(plist_get("ring_terminal",p));}
 }
}''')
        print("PASS complete insulated ring terminals pass through all four chassis holes", flush=True)
        empty('''intersection() {rear_power_harness(l); rear_equipment(l);}''')
        print("PASS ring terminal rests above the converter PCB and clears its components", flush=True)
        empty('''intersection() {case_body(); lid_body();}''')
        print("PASS reversed case rails fit the unchanged lid frame", flush=True)


if __name__ == "__main__":
    main()
