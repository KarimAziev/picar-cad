"""Check dovetail attachment, sliding fit, hardware, and roof-down printing."""
import ast
from pathlib import Path
import subprocess
import tempfile

from scad_test_support import OPENSCAD, echo_value
from check_gearmotor_encoder_mesh import connected_components, mesh_volume
from check_panel_stack_mesh import bounds, close, vertices

ROOT = Path(__file__).resolve().parents[1]
COMMON = f'''
include <{ROOT}/scad/rc_params.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_case.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_lid.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_rail.scad>
use <{ROOT}/scad/placeholders/lipo_pack.scad>
use <{ROOT}/scad/placeholders/bolt.scad>
$fn=32;
pl=multi_lipo_packs_case;
module case_body() {{ multi_lipo_pack_case(pl, anchor=[0,0,1], show_packs=false, show_rail_bolts=false); }}
module lid_body(slide=0, lift=0) {{
  multi_lipo_pack_lid_on_case(pl, slide=slide, lift=lift, show_lidar=false,
                              show_adapter=false, show_equipment=false);
}}
module pack() {{
  props=multi_lipo_pack_props(pl);
  body=plist_get("body_size",props);
  translate([-body[0]/2,-body[1]/2,0]) {{
    translate(plist_get("pack_positions",props)[0]) {{
      lipo_pack_from_pl(plist_get("lipo_packs",pl)[0], anchor=[1,1,1]);
    }}
  }}
}}
'''


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="lipo-lid-") as folder:
        source = Path(folder) / "fixture.scad"
        mesh = Path(folder) / "fixture.stl"

        def render(code: str, empty: bool = False, common: str = COMMON) -> str:
            source.write_text(common + code)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
                 "--export-format", "binstl", "-o", str(mesh), str(source)],
                capture_output=True, text=True)
            log = result.stdout + result.stderr
            assert "ERROR:" not in log and "WARNING:" not in log, log
            if empty and "Current top level object is empty" in log:
                return log
            assert result.returncode == 0, log
            if empty:
                assert mesh_volume(mesh) < 0.00001, (mesh_volume(mesh), log)
            return log

        for label, code in (("case and attached rails", "case_body();"),
                            ("sliding lid", "lid_body();"),
                            ("printable lid", "multi_lipo_pack_lid_printable(pl);")):
            render(code)
            assert connected_components(mesh) == 1, label
            if label == "printable lid":
                close([bounds(vertices(mesh))[0][2]], [0])
            print(f"PASS {label}: one connected printable solid", flush=True)

        for slide in (-170, -120, -60, -10, 0, 10, 60, 120, 170):
            render(f"intersection() {{ case_body(); lid_body(slide={slide}); }}", empty=True)
            render(f"intersection() {{ pack(); lid_body(slide={slide}); }}", empty=True)
        print("PASS case and wired pack clear the lid throughout sliding removal in both directions", flush=True)

        # The undercut must physically prevent lifting the lid straight off.
        render("intersection() { case_body(); lid_body(lift=1); }")
        assert mesh_volume(mesh) > 1
        print("PASS dovetail shoulders retain the lid against vertical removal", flush=True)

        render('''intersection() {
  multi_lipo_pack_lid(pl);
  multi_lipo_pack_lid(pl, show_lid=false, show_lidar=true, show_bolts=true);
}''', empty=True)
        print("PASS lidar standoffs and rail-locking hardware clear the printed lid", flush=True)

        render('''intersection() {
  case_body();
  multi_lipo_pack_lid_on_case(pl, show_lid=false, show_lidar=false, show_bolts=true);
}''', empty=True)
        print("PASS rail-locking bolts align with the case passages", flush=True)
        render('''intersection() {
  pack();
  multi_lipo_pack_lid_on_case(pl, show_lid=false, show_lidar=false, show_bolts=true);
}''', empty=True)
        print("PASS locking bolts and full-size hex nuts clear the wired pack", flush=True)


        # Mounting holes must stay open and coincide with the slot-mode interface.
        render('''intersection() {
  multi_lipo_pack_lid(pl);
  multi_lipo_pack_lid(pl, slot_mode=true);
}''', empty=True)
        print("PASS lid slot mode matches all mounting holes", flush=True)

        # A second rail axis and a wire notch through a supporting wall.
        changed = '''
pl=plist_merge(multi_lipo_packs_case,
 ["lipo_packs", [["size", [25,60,15]]],
  "mount_ear_d", 10, "bolt_spacing", [50,80], "mount_nut_pockets", false,
  "walls", ["bottom", ["t", 3], "inner", ["t", 3],
            "front", ["t", 3, "h", 12], "rear", ["t", 3, "h", 12],
            "left", ["t", 3, "h", 20, "corner_r", 5,
                     "cutouts", [["offset", "45%", "l", "10%", "h", 8, "corner_r", "25%"]]],
            "right", ["t", 3, "h", 20, "corner_r", "25%"]],
  "lid", ["t", 3, "headroom", 5], "orientation", "ORIENTATION"]);
'''
        # Check each nut in isolation: its entire axial extent must sit beyond
        # the outside skirt, with its near face exactly on the bearing surface.
        for axis, common in (
                ("x", COMMON),
                ("y", COMMON.replace("pl=multi_lipo_packs_case;",
                                     changed.replace("ORIENTATION", "wlh")))):
            for index in (0, 1):
                log = render(f'''
props=multi_lipo_pack_props(pl);
rails=plist_get("rail_props",props);
rail=plist_get("rails",rails)[{index}];
assert(plist_get("axis",rails)=="{axis}");
echo(cross=plist_get("cross",rail));
echo(grip=plist_get("locking_depth",rail));
echo(nut_h=find_nut_prop("height",plist_get("bolt_d",rails)));
multi_lipo_packs_rail_bolts(rails,rail,show_bolts=false,show_nuts=true);
''', common=common)
                cross, grip, nut_h = [float(ast.literal_eval(echo_value(log, name)))
                                      for name in ("cross", "grip", "nut_h")]
                cross_axis = 1 if axis == "x" else 0
                actual = bounds(vertices(mesh))
                expected = ([cross - grip / 2 - nut_h, cross - grip / 2]
                            if index == 0 else
                            [cross + grip / 2, cross + grip / 2 + nut_h])
                close([actual[0][cross_axis], actual[1][cross_axis]], expected)
                assert connected_components(mesh) == 2
            render('''intersection() {
  union() { case_body(); lid_body(); pack(); }
  props=multi_lipo_pack_props(pl);
  body=plist_get("body_size",props);
  rails=plist_get("rail_props",props);
  translate([-body[0]/2,-body[1]/2,0]) {
    for (rail=plist_get("rails",rails)) {
      multi_lipo_packs_rail_bolts(rails,rail,show_nuts=true);
    }
  }
}''', empty=True, common=common)
        print("PASS nuts seat outside both opposing skirts on X and Y rails; hardware clears case, lid, and pack", flush=True)

        for orientation in ("wlh", "lwh", "whl", "lhw", "hlw", "hwl"):
            common = COMMON.replace("pl=multi_lipo_packs_case;", changed.replace("ORIENTATION", orientation))
            render("case_body();", common=common)
            assert connected_components(mesh) == 1
            for anchor in ("[0,0,1]", "[-1,1,0]", "[1,-1,-1]"):
                render(f'''intersection() {{
  multi_lipo_pack_case(pl, anchor={anchor}, show_packs=false, show_rail_bolts=false);
  multi_lipo_pack_lid_on_case(pl, anchor={anchor}, show_lidar=false);
}}''', empty=True, common=common)
            if orientation == "wlh":
                for slide in (-80, -15, 15, 80):
                    render(f"intersection() {{ case_body(); lid_body(slide={slide}); }}", empty=True, common=common)
        print("PASS interrupted Y rails and lid alignment in all orientations and three case anchors", flush=True)


if __name__ == "__main__":
    main()
