"""Check selective polygon fillets, rounded wire rims, and preview-only labels.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""
from pathlib import Path
import subprocess
import tempfile

from check_gearmotor_encoder_mesh import connected_components, mesh_volume
from check_panel_stack_mesh import bounds, close, vertices
from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]
COMMON = f'''
include <{ROOT}/scad/steering_params.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_case.scad>
$fn=32;
rect = [[0,0], [20,0], [20,20], [0,20]];
module sample(shape=[], edge=0, axis="x") {{
  wall = ["t", 2, "l", 20, "offset", 2, "edge_r", edge,
          "shape", "custom", "shape_props",
          plist_merge(["h", 20, "points", rect, "corner_r", 3,
                       "round_bottom", false], shape)];
  walls = plist_put(axis == "x" ? "front" : "right", wall,
    ["bottom", ["t", 3], "inner", ["t", 2, "h", 0],
     "rear", ["t", 2, "h", 0], "front", ["t", 2, "h", 0],
     "left", ["t", 2, "h", 0], "right", ["t", 2, "h", 0]]);
  multi_lipo_pack_case(["lipo_packs", [["size", [20,40,10]]],
                       "walls", walls, "bolt_d", 0], anchor=[1,1,1],
                       l_clearance=0, w_clearance=0, show_packs=false,
                       show_standoffs=false, show_rail_bolts=false);
}}
'''


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="lipo-wall-profiles-") as folder:
        source = Path(folder) / "fixture.scad"
        mesh = Path(folder) / "fixture.stl"

        def render(code: str, empty: bool = False, invalid: bool = False) -> None:
            source.write_text(COMMON + code)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics",
                 "--hardwarnings", "--export-format", "binstl", "-o", str(mesh),
                 str(source)], capture_output=True, text=True)
            log = result.stdout + result.stderr
            if invalid:
                assert "ERROR: Assertion" in log, log
                return
            assert "ERROR:" not in log and "WARNING:" not in log, log
            if empty:
                assert "Current top level object is empty" in log, log
            else:
                assert result.returncode == 0, log

        for axis, cross in (("x", 42), ("y", 22)):
            for along, z, empty in ((0.05, 0.05, False), (19.8, 0.05, False),
                                    (0.05, 19.8, True), (19.8, 19.8, True)):
                pt = [2 + along, cross + 0.5, 3 + z] if axis == "x" else [cross + 0.5, 2 + along, 3 + z]
                render(f'intersection() {{ sample(axis="{axis}"); translate({pt}) cube(0.05); }}', empty)
            # These points distinguish actual thickness rounding from a pretty
            # side silhouette: both face edges recede, the middle still reaches Z=23.
            for thickness, z, empty in ((0.02, 19.95, True), (1.93, 19.95, True),
                                        (0.98, 19.95, False), (0.02, 19.2, False)):
                pt = [12, cross + thickness, 3 + z] if axis == "x" else [cross + thickness, 12, 3 + z]
                render(f'intersection() {{ sample(edge=0.5, axis="{axis}"); translate({pt}) cube(0.03); }}', empty)
            base = [2.05, cross + 1, 3.05] if axis == "x" else [cross + 1, 2.05, 3.05]
            render(f'intersection() {{ sample(edge=0.5, axis="{axis}"); translate({base}) cube(0.03); }}')
            render(f'sample(edge=0.5, axis="{axis}");')
            assert connected_components(mesh) == 1, "Rounded wall must join its floor"
            close(bounds(vertices(mesh))[0], [0, 0, 0])
            close(bounds(vertices(mesh))[1], [24, 44, 23])
            render(f'difference() {{ sample(edge=0.5, axis="{axis}"); sample(axis="{axis}"); }}', empty=True)
        print("PASS square polygon bases, rounded rim cross-sections, unchanged bounds and connected floors on both axes", flush=True)

        shape = '["points", [[0,0],[20,0],[20,8],[8,8],[8,20],[0,20]], "corner_r", 0, "corner_radii", [0,0,0,3,0,0]]'
        for point, empty in (([10.1, 43, 11.1], False), ([12.5, 43, 13.5], True)):
            render(f'intersection() {{ sample({shape}); translate({point}) cube(0.05); }}', empty)
        render(f'sample({shape});')
        volume = mesh_volume(mesh)
        render('sample(["points", [[0,20],[8,20],[8,8],[20,8],[20,0],[0,0]], "corner_r", 0, "corner_radii", [0,0,3,0,0,0]]);')
        assert abs(mesh_volume(mesh) - volume) < 0.001
        print("PASS concave fillets add the intended tangent transition in either winding", flush=True)

        slots = '["slots", [["pos",[8,8],"size",[4,4]]]]'
        for point, empty in (([9.85, 42.02, 13], True), ([9.85, 43, 13], False)):
            render(f'intersection() {{ sample({slots}, edge=0.5); translate({point}) cube(0.03); }}', empty)
        render('sample(edge=0.5);')
        volume = mesh_volume(mesh)
        render('sample(["debug", true], edge=0.5);')
        assert abs(mesh_volume(mesh) - volume) < 0.001
        assert connected_components(mesh) == 1
        close(bounds(vertices(mesh))[1], [24, 44, 23])
        print("PASS slot edges round through thickness; debug labels do not enter exported meshes", flush=True)

        render('multi_lipo_pack_case(multi_lipo_packs_case, anchor=[1,1,1], show_packs=false, show_standoffs=false, show_rail_bolts=false);')
        assert connected_components(mesh) == 1
        render('''intersection() {
  multi_lipo_pack_case(multi_lipo_packs_case, anchor=[1,1,1],
                      show_packs=false, show_standoffs=false, show_rail_bolts=false);
  body=plist_get("body_size",multi_lipo_pack_props(multi_lipo_packs_case));
  translate([body[0]-1.5,0.5,9.65]) cube(0.05);
}''', empty=True)
        print("PASS configured wire-facing wall is connected and the former corner lip is absent", flush=True)

        for code in ('sample(["corner_radii", [0,0]]);',
                     'sample(["corner_radii", [0,0,-1,2]]);',
                     'sample(["round_bottom", "no"]);',
                     'sample(["points", [[0,0],[20,0],[20,0],[20,20],[0,20]]]);',
                     'sample(edge=1);'):
            render(code, invalid=True)
        print("PASS malformed radii, repeated points, invalid toggles and oversized rim radii rejected", flush=True)


if __name__ == "__main__":
    main()
