"""Check Wago retention, mounting interfaces and printable geometry.

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
include <{ROOT}/scad/rc_params.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/wago/wago_bracket.scad>
use <{ROOT}/scad/wago/wago_mounts.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_lid.scad>
use <{ROOT}/scad/suspension/rear_chassis/computed_params.scad>
use <{ROOT}/scad/suspension/rear_chassis/rear_chassis_frame.scad>
use <{ROOT}/scad/suspension/rear_chassis/rear_chassis.scad>
$fn=32;
'''


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="wago-bracket-") as folder:
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
                assert mesh_volume(mesh) < 0.00001, log

        for pl in ('[]', '["mount_side","sides"]',
                   '["wago",["n",3,"total_w",22.7]]',
                   '["clearance",0.4,"base_t",3,"clip_overlap",0.35]',
                   '["top_clearance",0]'):
            render(f'wago_bracket(pl={pl});')
            assert connected_components(mesh) == 1
            close([bounds(vertices(mesh))[0][2]], [0])
            render(f'''intersection() {{
  wago_bracket(pl={pl});
  wago_bracket(pl={pl},show_bracket=false,show_wago=true,show_bolts=true);
}}''', empty=True)
        print("PASS five bracket variants are connected, base-down and clear of hardware", flush=True)

        for anchor in ('[1,1,1]', '[0,0,0]', '[-1,1,-1]'):
            render(f'''intersection() {{
  wago_bracket(anchor={anchor});
  wago_bracket(anchor={anchor},slot_mode=true);
}}''', empty=True)
        # A raised connector must meet the retaining lips before escaping.
        render('''intersection() {
  wago_bracket();
  translate([0,0,0.5]) { wago_bracket(show_bracket=false,show_wago=true); }
}''')
        assert mesh_volume(mesh) > 0.01
        print("PASS anchor-aligned mounting holes and positive vertical clip retention", flush=True)

        for angle in (0, 90, 180, 37):
            render(f'''
mounts=[["pos",[0,0],"rotation",{angle}]];
intersection() {{
  difference() {{
    translate([-50,-50,0]) {{ cube([100,100,3]); }}
    wago_mounts(mounts,z=3,slot_mode=true,parent_t=3);
  }}
  wago_mounts(mounts,z=3,show_bolts=true);
}}''', empty=True)
        print("PASS parent holes follow cardinal and arbitrary Z rotations", flush=True)

        lid_common = '''
lid=plist_merge(plist_get("lid",multi_lipo_packs_case),
 ["equipment",[],"fuse",undef,
  "wago_mounts",[["pos",[-54,0]],["pos",[54,0],"rotation",180]]]);
pl=plist_merge(multi_lipo_packs_case,["lid",lid]);
'''
        render(lid_common + 'multi_lipo_pack_lid_printable(pl);')
        assert connected_components(mesh) == 1
        close([bounds(vertices(mesh))[0][2]], [0])
        render(lid_common + '''intersection() {
  multi_lipo_pack_lid(pl);
  multi_lipo_pack_lid(pl,slot_mode=true);
}''', empty=True)
        render(lid_common + '''intersection() {
  multi_lipo_pack_lid(pl);
  multi_lipo_pack_lid(pl,show_lid=false,show_wago_brackets=true,show_bolts=true);
}''', empty=True)
        print("PASS lid remains printable with aligned Wago holes and mounting hardware", flush=True)

        render('''
layout=rear_chassis_layout(equipment=[], wago_mounts=[["placement","after","rotation",90]]);
intersection() {
  rear_chassis_frame(layout=layout);
  wago_mounts(plist_get("wago_mounts",layout),show_bolts=true,parent_t=6);
}''', empty=True)
        print("PASS chassis bracket hardware clears the extended mounting plate", flush=True)

        render('''
layout=rear_chassis_layout(equipment=[], wago_mounts=[["placement","auto","rotation",270]]);
intersection() {
  rear_chassis(layout=layout,anchor=undef,show_wago_brackets=false);
  wago_mounts(plist_get("wago_mounts",layout),parent_t=6);
}''', empty=True)
        print("PASS automatic bracket placement clears the assembled rear hardware", flush=True)

        for bad in ('["clip_overlap",1.5]', '["clearance",-0.1]',
                    '["ear_d",3]', '["wago",["n",6]]'):
            render(f'wago_bracket(pl={bad});', reject=True)
        render(lid_common.replace('[-54,0]', '[0,0]') + 'multi_lipo_pack_lid(pl);', reject=True)
        rounded = lid_common.replace('"wago_mounts",', '"corner_r",25,"wago_mounts",')
        render(rounded.replace('[-54,0]', '[-54,10]') + 'multi_lipo_pack_lid(pl);', reject=True)
        render('''echo(wago_chassis_mounts([["placement","under"]],undef,[],3)); cube(1);''', reject=True)
        print("PASS invalid fits and colliding placements fail explicitly", flush=True)


if __name__ == "__main__":
    main()
