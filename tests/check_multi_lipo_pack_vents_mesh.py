"""Check rounded vent openings in case walls and the shared lid vent interface."""
from pathlib import Path
import subprocess
import tempfile

from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]
COMMON = f'''
include <{ROOT}/scad/steering_params.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_case.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_lid.scad>
$fn=32;
'''


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="lipo-vents-") as folder:
        source = Path(folder) / "fixture.scad"
        mesh = Path(folder) / "fixture.stl"

        def empty(code: str) -> None:
            source.write_text(COMMON + code)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
                 "-o", str(mesh), str(source)], capture_output=True, text=True)
            log = result.stdout + result.stderr
            assert "ERROR:" not in log and "WARNING:" not in log, log
            assert "Current top level object is empty" in log, log

        for wall, axis, cross, start in (("front", "x", 43, 6), ("right", "y", 23, 16)):
            for radius, rounded in (("0", False), ("2", True), ('"25%"', True)):
                empty(f'''
pl=["lipo_packs", [["size", [20,40,20]]], "bolt_d", 0,
    "walls", ["bottom", ["t", 3], "inner", ["t", 2],
              "front", ["t", 2], "rear", ["t", 2],
              "left", ["t", 2], "right", ["t", 2]]];
vent=["t", 2, "vent_w", 12, "vent_h", 8, "vent_corner_r", {radius},
      "vent_col_gap", 100, "vent_row_gap", 100];
module body() {{
 multi_lipo_pack_case(plist_merge(pl,["walls",plist_merge(plist_get("walls",pl),["{wall}",vent])]),
                     anchor=[1,1,1], show_packs=false, show_rail_bolts=false,
                     l_clearance=0, w_clearance=0);
}}
module probe(along,z) {{
 translate([{"along" if axis == "x" else cross},{cross if axis == "x" else "along"},z]) {{ cube(0.2); }}
}}
// All four corners retain material only when rounded.
for(a=[{start + 0.1},{start + 11.7}], z=[9.1,16.7]) {{
 {"difference" if rounded else "intersection"}() {{ probe(a,z); body(); }}
}}
// The center and middles of all four edges remain open.
for(p=[[{start + 5},12],[{start + 0.1},12],[{start + 11.7},12],
       [{start + 5},9.1],[{start + 5},16.7]]) {{
 intersection() {{ body(); probe(p[0],p[1]); }}
}}
// Material immediately below the opening remains intact.
difference() {{ probe({start + 5},8.5); body(); }}
''')
        print("PASS vent corners: square/numeric/percentage, four corners, both wall axes", flush=True)

        # Symmetric differences prove the dedicated lid alias and explicit override
        # produce the same openings. Compare with square vents to prove they exist.
        common_lid = '''
spec=plist_get("lid",multi_lipo_packs_case);
vent=["vent_w", "12%", "vent_h", 4.5, "vent_col_gap", 5, "vent_pad", 1.5];
function lid_pl(v)=plist_merge(multi_lipo_packs_case,["lid",plist_merge(spec,["vents",v])]);
a=lid_pl(plist_merge(vent,["corner_r","40%"]));
b=lid_pl(plist_merge(vent,["vent_corner_r",1.8]));
c=lid_pl(plist_merge(vent,["corner_r",0,"vent_corner_r",1.8]));
'''
        for other in ("b", "c"):
            empty(common_lid + f'''
difference() {{ multi_lipo_pack_lid(a); multi_lipo_pack_lid({other}); }}
difference() {{ multi_lipo_pack_lid({other}); multi_lipo_pack_lid(a); }}
''')
        source.write_text(COMMON + common_lid + '''
difference() {
 multi_lipo_pack_lid(a);
 multi_lipo_pack_lid(lid_pl(vent));
}
''')
        result = subprocess.run(
            [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
             "-o", str(mesh), str(source)], capture_output=True, text=True)
        log = result.stdout + result.stderr
        assert result.returncode == 0 and "ERROR:" not in log and "WARNING:" not in log, log
        assert mesh.stat().st_size > 84
        print("PASS lid vents: nonempty rounding, alias, numeric equivalence and explicit override", flush=True)


if __name__ == "__main__":
    main()
