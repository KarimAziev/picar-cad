"""Check printable plates, screw insertion, captive nut shoulders and roof rounding."""

import subprocess
import tempfile
from pathlib import Path

from check_gearmotor_encoder_mesh import connected_components, mesh_volume
from check_panel_stack_mesh import bounds, close, vertices
from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]
COMMON = f"""
include <{ROOT}/scad/rc_params.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_lid.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_adapter.scad>
use <{ROOT}/scad/lipo_pack_case/printable.scad>
$fn=32;
pl=multi_lipo_packs_case;
p=multi_lipo_pack_lid_props(pl);
a=plist_get("adapter_props",p);
o=plist_get("lidar_offset",p);
s=plist_get("canonical_size",p);
module adapter() {{
 translate([o[0],o[1],s[2] + plist_get("adapter_gap",p)]) {{ multi_lipo_pack_adapter(a); }}
}}
"""


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="lipo-adapter-") as folder:
        source = Path(folder) / "fixture.scad"
        mesh = Path(folder) / "fixture.stl"

        def render(code: str, empty: bool = False, common: str = COMMON) -> None:
            source.write_text(common + code)
            result = subprocess.run(
                [
                    OPENSCAD,
                    "--backend=Manifold",
                    "--enable=textmetrics",
                    "--hardwarnings",
                    "--export-format",
                    "binstl",
                    "-o",
                    str(mesh),
                    str(source),
                ],
                capture_output=True,
                text=True,
            )
            log = result.stdout + result.stderr
            assert "ERROR:" not in log and "WARNING:" not in log, log
            if empty and "Current top level object is empty" in log:
                return
            assert result.returncode == 0, log
            if empty:
                assert mesh_volume(mesh) < 0.00001, (mesh_volume(mesh), log)

        render("multi_lipo_pack_adapter_printable(a);")
        assert connected_components(mesh) == 1
        close(bounds(vertices(mesh))[0], [-27.8, -27.8, 0])
        close(bounds(vertices(mesh))[1], [27.8, 27.8, 4])
        render("multi_lipo_pack_printable();")
        assert connected_components(mesh) == 6
        close([bounds(vertices(mesh))[0][2]], [0])
        print(
            "PASS: adapter is one solid on the bed; combined layout has six separate parts without adapter spacers",
            flush=True,
        )

        render(
            """intersection() {
 adapter();
 multi_lipo_pack_lid(pl,show_lid=false,show_lidar=true,show_bolts=true);
}""",
            empty=True,
        )
        render(
            """intersection() {
 multi_lipo_pack_lid(pl);
 translate([o[0],o[1],s[2] + plist_get("adapter_gap",p)]) {
  multi_lipo_pack_adapter(a,show_plate=false,show_hardware=true);
 }
}""",
            empty=True,
        )
        render(
            """intersection() {
 multi_lipo_pack_adapter(a);
 multi_lipo_pack_adapter(a,slot_mode=true);
}""",
            empty=True,
        )
        # Captured nuts have an actual plastic shoulder below them, not just the lid.
        render(
            """difference() {
 for(q=plist_get("holes",a)) {
  translate([q[0]+2,q[1],0.2]) { cube([0.2,0.2,0.2]); }
 }
 multi_lipo_pack_adapter(a);
}""",
            empty=True,
        )
        print(
            "PASS: sensor screws, lid screws and nuts clear the plate; nut shoulders remain solid",
            flush=True,
        )

        # Check the full straight tool/head path from the removed lid underside.
        render(
            """intersection() {
 multi_lipo_pack_lid(pl);
 translate([o[0],o[1],plist_get("roof_z",p)-0.01]) {
  multi_lipo_pack_adapter_lid_slots(a,access_h=30);
 }
}""",
            empty=True,
        )
        # Sensor mounting screws are inserted before the adapter is placed on the lid.
        render(
            """intersection() {
 multi_lipo_pack_adapter(a);
 for(q=plist_get("sensor_holes",a)) {
  translate([q[0],q[1],-20]) { cylinder(d=5,h=19.99); }
 }
}""",
            empty=True,
        )
        print(
            "PASS: straight screw/tool access for lid attachment and separate sensor-plate assembly",
            flush=True,
        )

        # Radius applies to the actual outer silhouette, including skirt tips.
        render(
            """intersection() {
 multi_lipo_pack_lid(pl);
 for(x=[-1,1],y=[-1,1]) {
  translate([x*(s[0]/2-0.15)-0.05,y*(s[1]/2-0.15)-0.05,0.1]) {
   cube([0.1,0.1,s[2]-0.2]);
  }
 }
}""",
            empty=True,
        )
        render(
            """difference() {
 translate([-0.1,s[1]/2-0.2,plist_get("roof_z",p)+0.5]) { cube(0.1); }
 multi_lipo_pack_lid(pl);
}""",
            empty=True,
        )
        render(
            """difference() {
 for(x=[-1,1],y=[-1,1]) {
  translate([x*(s[0]/2-0.15)-0.05,y*(s[1]/2-0.15)-0.05,plist_get("roof_z",p)+0.5]) {
   cube(0.1);
  }
 }
 multi_lipo_pack_lid(plist_merge(pl,["lid",plist_merge(plist_get("lid",pl),["corner_r",0])]));
}""",
            empty=True,
        )
        print(
            "PASS: rounded roof corners and skirt tips, with straight edge retained",
            flush=True,
        )

        # Different rail direction and sensor orientation/offset: both patterns follow.
        altered = """pl=plist_merge(multi_lipo_packs_case,[
 "lipo_packs",[["size",[55,80,20]]],
 "walls",["bottom",["t",3],"inner",["t",3],
           "front",["t",3,"h",15],"rear",["t",3,"h",15],
           "left",["t",3,"h",20],"right",["t",3,"h",20]],
 "lid",plist_merge(plist_get("lid",multi_lipo_packs_case),[
   "equipment",[],"fuse",undef,"voltmeters",[],
   "lidar_orientation","lwh","lidar_offset",[3,-2],
   "lidar",plist_merge(rplidar_c1_plist,["size",[62,58],"bolt_spacing",[46,40],"offsets",[1,-2]])])]);"""
        alt = COMMON.replace("pl=multi_lipo_packs_case;", altered)
        render(
            """intersection() {
 multi_lipo_pack_lid(pl);
 translate([o[0],o[1],plist_get("roof_z",p)-0.01]) {
  multi_lipo_pack_adapter_lid_slots(a,access_h=30);
 }
}""",
            empty=True,
            common=alt,
        )
        render(
            """intersection() {
 adapter(); multi_lipo_pack_lid(pl,show_lid=false,show_lidar=true,show_bolts=true);
}""",
            empty=True,
            common=alt,
        )
        render("multi_lipo_pack_adapter_printable(a);", common=alt)
        assert connected_components(mesh) == 1
        print(
            "PASS: Y rails, changed sensor pattern, rotated sensor and shifted mounting center",
            flush=True,
        )


if __name__ == "__main__":
    main()
