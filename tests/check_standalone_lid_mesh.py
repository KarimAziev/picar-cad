"""Check standalone lid mounting, concealed fuse clearance and print orientation.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""
from pathlib import Path
import subprocess
import tempfile

from scad_test_support import OPENSCAD
from check_gearmotor_encoder_mesh import connected_components, mesh_volume
from check_panel_stack_mesh import bounds, close, vertices

ROOT = Path(__file__).resolve().parents[1]
COMMON = f'''
include <{ROOT}/scad/lipo_pack_case/standalone_parameters.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_lid.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_case.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_adapter.scad>
use <{ROOT}/scad/lipo_pack_case/lid_equipment.scad>
use <{ROOT}/scad/lipo_pack_case/lid_fuse.scad>
use <{ROOT}/scad/lipo_pack_case/printable.scad>
use <{ROOT}/scad/components/button_bracket/button_bracket.scad>
$fn=32;
pl=standalone_lipo_case;
p=multi_lipo_pack_lid_props(pl);
spec=plist_get("lid",pl);
fuse=lid_fuse_props(plist_get("fuse",spec),p);
equipment=lid_equipment_layout(plist_get("equipment",spec),p);
module fuse_body() {{
  translate([0,0,plist_get("roof_z",p)]) {{ lid_fuse(fuse,plist_get("t",p)); }}
}}
'''


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="standalone-lid-") as folder:
        source = Path(folder) / "fixture.scad"
        mesh = Path(folder) / "fixture.stl"

        def render(code: str, empty: bool = False, reject: bool = False) -> None:
            source.write_text(COMMON + code)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
                 "--export-format", "binstl", "-o", str(mesh), str(source)],
                capture_output=True, text=True)
            log = result.stdout + result.stderr
            if reject:
                assert "ERROR: Assertion" in log, log
                return
            assert "ERROR:" not in log and "WARNING:" not in log, log
            if empty and "Current top level object is empty" in log:
                return
            assert result.returncode == 0, log
            if empty:
                assert mesh_volume(mesh) < 0.00001, (mesh_volume(mesh), log)

        render("multi_lipo_pack_printable(pl);")
        assert connected_components(mesh) == 9
        close([bounds(vertices(mesh))[0][2]], [0])
        render("multi_lipo_pack_lid_printable(pl);")
        assert connected_components(mesh) == 1
        close([bounds(vertices(mesh))[0][2]], [0])
        render("button_bracket(toggle_switch_bracket_plist,show_button=false);")
        assert connected_components(mesh) == 1
        close([bounds(vertices(mesh))[0][2]], [0])
        render('multi_lipo_pack_adapter_spacers(plist_get("adapter_props",p));')
        assert connected_components(mesh) == 4
        close([bounds(vertices(mesh))[0][2]], [0])
        print("PASS lid, switch bracket and four spacers print on Z=0", flush=True)

        render('''intersection() {
  multi_lipo_pack_lid(pl);
  multi_lipo_pack_lid(pl,slot_mode=true);
}''', empty=True)
        render('''intersection() {
  multi_lipo_pack_lid(pl);
  multi_lipo_pack_lid(pl,show_lid=false,show_equipment=true,
                      show_adapter=true,show_bolts=true);
}''', empty=True)
        render('''intersection() {
  fuse_body();
  multi_lipo_pack_lid(pl,show_lid=false,show_adapter=true,show_bolts=true);
}''', empty=True)
        print("PASS roof holes align and installed equipment clears lid and fuse", flush=True)

        render('''no_sensor=plist_merge(pl,["lid",plist_merge(spec,["lidar",undef])]);
multi_lipo_pack_lid_printable(no_sensor);''')
        assert connected_components(mesh) == 1
        print("PASS removing lidar repacks equipment around the fuse retaining ties", flush=True)

        for slide in (-160, -60, 0, 60, 160):
            render(f'''intersection() {{
  multi_lipo_pack_case(pl,show_packs=true,show_rail_bolts=false);
  translate([{slide},0,plist_get("mount_z",p)]) {{ fuse_body(); }}
}}''', empty=True)
        print("PASS concealed fuse clears the case and wired battery throughout sliding", flush=True)

        for orientation in ("wlh", "lwh", "whl", "lhw", "hlw", "hwl"):
            render(f'''intersection() {{
  button_bracket(toggle_switch_bracket_plist,orientation="{orientation}",
                 anchor=[-1,1,0],show_button=false);
  button_bracket(toggle_switch_bracket_plist,orientation="{orientation}",
                 anchor=[-1,1,0],slot_mode=true);
}}''', empty=True)
        print("PASS switch slot and solid anchors agree in six orientations", flush=True)

        render('''bad=plist_merge(pl,["lid",plist_merge(spec,
  ["equipment",[["kind","wago","pos",[0,0]]]])]);
multi_lipo_pack_lid(bad);''', reject=True)
        render('''bad=plist_merge(pl,["lid",plist_merge(spec,
  ["headroom",5])]);
multi_lipo_pack_lid(bad);''', reject=True)
        render('''bad=plist_merge(pl,["lid",plist_merge(spec,
  ["fuse",["pos",[0,25]]])]);
multi_lipo_pack_lid(bad);''', reject=True)
        print("PASS overlapping equipment and insufficient fuse clearance are rejected", flush=True)


if __name__ == "__main__":
    main()
