"""Check perfboard mounting cutters, anchors, explicit inputs and rear placement.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""
from pathlib import Path
import subprocess
import tempfile

from scad_test_support import OPENSCAD
from check_gearmotor_encoder_mesh import connected_components, mesh_volume

ROOT = Path(__file__).resolve().parents[1]
COMMON = f'''
include <{ROOT}/scad/parameters.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/lib/transforms.scad>
use <{ROOT}/scad/placeholders/perfboard.scad>
use <{ROOT}/scad/suspension/rear_chassis/computed_params.scad>
use <{ROOT}/scad/suspension/rear_chassis/rear_equipment.scad>
$fn=24;
pl=plist_merge(perfboard_default_plist,["bolt_idxes",[[1,0],[1,1]]]);
'''


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="perfboard-") as folder:
        source = Path(folder) / "fixture.scad"
        mesh = source.with_suffix(".stl")

        def render(code: str, *, empty: bool = False, reject: str = "") -> None:
            source.write_text(COMMON + code)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
                 "--export-format", "binstl", "-o", str(mesh), str(source)],
                capture_output=True, text=True)
            log = result.stdout + result.stderr
            if reject:
                assert "ERROR: Assertion" in log and reject in log, log
                assert "WARNING:" not in log, log
                return
            assert "ERROR:" not in log and "WARNING:" not in log, log
            if empty and "Current top level object is empty" in log:
                return
            assert result.returncode == 0, log
            if empty:
                assert mesh_volume(mesh) < 0.00001, log

        for selection, count in [("undef", 4), ("[[1,0],[1,1]]", 2), ("[]", 0)]:
            render(f'''perf_board_mount(plist_merge(pl,["bolt_idxes",{selection}]),
parent_t=3,slot_mode=true);''', empty=count == 0)
            if count:
                assert connected_components(mesh) == count
        print("PASS selected perfboard corners produce four, two or zero cutters", flush=True)

        for orientation in ("wlh", "lwh", "whl", "lhw", "hlw", "hwl"):
            render(f'''p=perf_board_mount_props(pl);
module parent() {{
  with_orientation(to="{orientation}",size=plist_get("size",p),anchor=[-1,1,0]) {{
    translate([-12,-42,-3]) {{ cube([24,84,3]); }}
  }}
}}
intersection() {{
  difference() {{
    parent();
    perf_board_mount(pl,3,anchor=[-1,1,0],orientation="{orientation}",slot_mode=true);
  }}
  perf_board_mount(pl,3,anchor=[-1,1,0],orientation="{orientation}");
}}''', empty=True)
        print("PASS perfboard hardware clears its parent in all six orientations", flush=True)

        for code, message in [
            ('echo(perf_board_mount_props([]));', "explicit mounting parameters"),
            ('echo(perf_board_mount_props(["size",[20,80,1.6],"bolt_spacing",[16,76]]));',
             "explicit mounting parameters"),
            ('echo(perfboard_props(["size",[20,80,1.6]]));', "bolt_spacing"),
            ('perf_board_mount(pl,parent_t=1,slot_mode=true);', "leave material"),
            ('echo(perfboard_props(plist_merge(pl,["rows",1000])));', "copper grid"),
        ]:
            render(code, reject=message)
        print("PASS missing mounting inputs and invalid copper/recess dimensions are rejected", flush=True)

        render('''layout=rear_chassis_layout(equipment=[["kind","perf_board"]]);
assert(len(plist_get("equipment",layout))==1);
base=rear_chassis_layout(equipment=[]);
assert(plist_get("size",layout)==plist_get("size",base));
assert(plist_get("bounds",layout)==plist_get("bounds",base));
rear_equipment(layout,slot_mode=true);''')
        assert connected_components(mesh) == 4
        print("PASS rear deck mounts the parameter-preset board without resizing the chassis", flush=True)


if __name__ == "__main__":
    main()
