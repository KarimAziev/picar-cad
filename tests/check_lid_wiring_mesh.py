"""Check routed wires against the closed enclosure, hardware and each other.

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
include <{ROOT}/scad/lipo_pack_case/standalone_parameters.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/lib/transforms.scad>
use <{ROOT}/scad/lib/wire.scad>
use <{ROOT}/scad/placeholders/lipo_pack.scad>
use <{ROOT}/scad/placeholders/lipo_pack_wiring.scad>
use <{ROOT}/scad/placeholders/t_plug.scad>
use <{ROOT}/scad/lipo_pack_case/lid_wiring.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_case.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_lid.scad>
pl=standalone_lipo_case;
p=lid_wiring_props(pl); c=plist_get("case_props",p);
pack=plist_get("pack",p); s=plist_get("size",pack); b=plist_get("body_size",c);
routes=plist_get("routes",p);
pack_routes=[for(key=["power_lead","balance_lead"])
  let(q=lipo_pack_top_wiring_props(pack,key))
  for(path=plist_get("paths",q))
  ["d",plist_get("d",q),"path",[for(pt=path) _harness_pack_point(pl,c,pt)]]];
all_routes=concat(routes,pack_routes);
module pack_frame() {{
 translate(plist_get("pack_positions",c)[0]-[b[0]/2,b[1]/2,0]) {{
  with_orientation(to=plist_get("orientation",pack),size=s,anchor=[1,1,1]) {{children();}}
 }}
}}
module pack_wires() {{
 pack_frame() {{for(key=["power_lead","balance_lead"]) {{
  lipo_pack_top_wiring(lipo_pack_top_wiring_props(pack,key));
 }}}}
}}
module lead(r) {{wire_path(plist_get("path",r),d=plist_get("d",r),mode="none",cut_len=undef);}}
module terminal_contacts() {{
 for(r=routes) {{
  path=plist_get("path",r);
  for(pt=[path[0],path[len(path)-1]]) {{
   translate(pt) {{sphere(r=plist_get("d",r)/2+0.05,$fn=32);}}
  }}
 }}
}}
'''


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="lid-wiring-") as folder:
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
 union() {lid_wiring(pl); pack_wires();}
 union() {
  multi_lipo_pack_case(pl,anchor=[0,0,1],show_packs=false,show_rail_bolts=false);
  multi_lipo_pack_lid_on_case(pl,show_equipment=false,show_lidar=false,
                            show_wago_brackets=false,show_adapter=true);
  translate(plist_get("pack_positions",c)[0]-[b[0]/2,b[1]/2,0]) {
   lipo_pack_from_pl(pack,anchor=[1,1,1],show_wiring=false);
  }
 }
}''')
        print("PASS complete harness and folded battery leads clear pack, case, lid and adapter", flush=True)

        empty('''difference() {
 intersection() {
  union() {lid_wiring(pl); pack_wires();}
  multi_lipo_pack_lid_on_case(pl,show_lid=false,show_lidar=false,show_adapter=false);
 }
 terminal_contacts();
}''')
        print("PASS wires clear cradles, switch and concealed fuse except at their terminal contacts", flush=True)

        empty('''union() {
 for(i=[0:len(all_routes)-2],j=[i+1:len(all_routes)-1]) {
  intersection() {lead(all_routes[i]); lead(all_routes[j]);}
 }
}''')
        print("PASS all nine routed conductors are mutually clear", flush=True)

        empty('''intersection() {
 t_plug_mated(show_male=false);
 t_plug_mated(show_female=false);
}''')
        print("PASS mated T-plug blades fit the matching female cavities", flush=True)


if __name__ == "__main__":
    main()
