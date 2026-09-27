"""Check wall relief geometry, reference bounds, and the configured pack's fit."""
from pathlib import Path
import struct
import subprocess
import tempfile

from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]
PREAMBLE = f'''
include <{ROOT}/scad/steering_params.scad>
use <{ROOT}/scad/lipo_pack_case/multi_lipo_pack_case.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/placeholders/lipo_pack.scad>
$fn=32;
pl = ["lipo_packs", [["size", [20,40,10]]],
      "walls", ["bottom", ["t", 3], "inner", ["t", 2, "h", 100],
                "front", ["t", 2, "h", 15, "l", "50%"],
                "rear", ["t", 2, "h", 0],
                "left", ["t", 2, "h", "50%",
                         "cutouts", [["l", 8, "h", 2]]],
                "right", ["t", 2, "h", 12]],
      "bolt_d", 3, "bore_d", 5, "bore_h", 1];
module sample() {{
  multi_lipo_pack_case(pl, anchor=[1,1,1], l_clearance=0, w_clearance=0);
}}
'''


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="multi-lipo-mesh-") as folder:
        source = Path(folder) / "fixture.scad"
        mesh = Path(folder) / "fixture.stl"

        def render(code: str, empty: bool = False) -> bytes:
            source.write_text(PREAMBLE + code)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics",
                 "--hardwarnings", "--export-format", "binstl", "-o", str(mesh),
                 str(source)], capture_output=True, text=True)
            log = result.stdout + result.stderr
            assert "ERROR:" not in log and "WARNING:" not in log, log
            if empty:
                assert "Current top level object is empty" in log, log
                return b""
            assert result.returncode == 0, log
            return mesh.read_bytes()

        data = render("sample();")
        points = [triangle[start:start + 3]
                  for triangle in struct.iter_unpack("<12fH", data[84:])
                  for start in (3, 6, 9)]
        assert [min(p[i] for p in points) for i in range(3)] == [0, 0, 0]
        assert [max(p[i] for p in points) for i in range(3)] == [24, 44, 18]

        # Small probes are strictly within material or strictly within an opening.
        for point, empty in [([0.5, 4, 6.5], True),   # notch
                             ([0.5, 4, 4], False),   # material below notch
                             ([0.5, 12, 7], False),  # retained left wall
                             ([0.5, 12, 9], True),   # half-height left wall
                             ([12, 0.5, 4], True),   # disabled rear
                             ([4, 43, 12], True),    # shortened front
                             ([12, 43, 16], False),  # taller front
                             ([0.5, 4, 1], False)]:  # floor below notch
            render(f"intersection() {{ sample(); translate({point}) cube(0.2); }}", empty)
        print("PASS: shortened/taller walls, top-open relief, and intact floor")

        # Geometry bounds must follow the custom tallest wall through rotations.
        sizes = {"wlh": [24, 44, 18], "lwh": [44, 24, 18],
                 "whl": [24, 18, 44], "lhw": [44, 18, 24],
                 "hlw": [18, 44, 24], "hwl": [18, 24, 44]}
        for orientation, size in sizes.items():
            for anchor in ([1, 1, 1], [0, 0, 0], [-1, -1, -1]):
                data = render(f'''
multi_lipo_pack_case(plist_merge(pl, ["orientation", "{orientation}"]),
                    anchor={anchor}, l_clearance=0, w_clearance=0);
''')
                points = [triangle[start:start + 3]
                          for triangle in struct.iter_unpack("<12fH", data[84:])
                          for start in (3, 6, 9)]
                for i in range(3):
                    low = (anchor[i] - 1) * size[i] / 2
                    assert abs(min(p[i] for p in points) - low) < 0.001
                    assert abs(max(p[i] for p in points) - low - size[i]) < 0.001
        print("PASS: asymmetric wall bounds in all six orientations and three anchors")

        for axis, probes in (("x", [([23, 13, 18], True), ([23, 20, 18], False),
                                    ([23, 5, 6], True)]),
                             ("y", [([8, 43, 18], True), ([12, 43, 18], False),
                                    ([4, 43, 6], True)])):
            for point, empty in probes:
                render(f'''
divider_walls = plist_merge(plist_get("walls", pl),
  ["inner", ["t", 2, "h", 18, "l", "50%", "cutouts", [["l", 3, "h", 4]]]]);
intersection() {{
  multi_lipo_pack_case(plist_merge(pl,
    ["pack_layout", "{axis}", "lipo_packs", [["size", [20,40,10]], ["size", [20,40,10]]],
     "walls", divider_walls]), anchor=[1,1,1], l_clearance=0, w_clearance=0);
  translate({point}) cube(0.2);
}}
''', empty)
        print("PASS: divider length, height, and cutouts in both pack layouts")

        # Test the actual user preset, including the bent leads and connector.
        # A micron above the floor excludes intentional coplanar contact.
        for lift in (0.001, 5, 15):
            render(f'''
props = multi_lipo_pack_props(multi_lipo_packs_case);
intersection() {{
  multi_lipo_pack_case(multi_lipo_packs_case, anchor=[1,1,1]);
  translate(plist_get("pack_positions", props)[0] + [0,0,{lift}]) {{
    lipo_pack_from_pl(lipo_pack_base_pl, anchor=[1,1,1]);
  }}
}}
''', empty=True)
        print("PASS: configured pack and leads clear the case at seated and raised positions")


if __name__ == "__main__":
    main()
