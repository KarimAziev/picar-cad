"""Check changed shaft fits, open bores, anchors and printable separation."""

from pathlib import Path
import struct
import subprocess
import tempfile

import trimesh

from check_gearmotor_encoder_mesh import connected_components, mesh_volume
from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]


def mesh_bounds(path: Path) -> list[list[float]]:
    vertices = [
        row[start:start + 3]
        for row in struct.iter_unpack("<12fH", path.read_bytes()[84:])
        for start in (3, 6, 9)
    ]
    return [[f(v[i] for v in vertices) for i in range(3)] for f in (min, max)]


def main() -> None:
    imports = f"""
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/motor_brackets/rc/driveshaft_magnet_sleeve.scad>
use <{ROOT}/scad/placeholders/motors/rc/motor_drive_shaft.scad>
use <{ROOT}/scad/placeholders/suspension_arm_pin.scad>
"""
    with tempfile.TemporaryDirectory(prefix="magnet-sleeve-") as folder:
        source = Path(folder) / "fixture.scad"
        mesh = Path(folder) / "fixture.stl"

        def check(label: str, code: str, empty: bool = False, components: int = 1) -> None:
            source.write_text(imports + code)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
                 "--export-format", "binstl", "-o", str(mesh), str(source)],
                text=True, capture_output=True,
            )
            log = result.stdout + result.stderr
            assert "ERROR:" not in log and "WARNING:" not in log, (label, log)
            if empty and "Current top level object is empty" in log:
                return
            assert result.returncode == 0, (label, log)
            if empty:
                assert mesh_volume(mesh) < 1e-6, (label, mesh_volume(mesh))
            else:
                assert connected_components(mesh) == components, label
                solid = trimesh.load_mesh(mesh)
                assert isinstance(solid, trimesh.Trimesh), label
                assert solid.is_watertight, (label, "open or non-manifold edges")
                assert solid.is_winding_consistent and solid.is_volume, (label, "invalid solid")
                assert solid.nondegenerate_faces().all(), (label, "degenerate triangles")
                assert solid.unique_faces().all(), (label, "duplicate triangles")
            print(f"PASS {label}", flush=True)

        check("default sleeve manifold", "driveshaft_magnet_sleeve();")
        check("default bore open through magnet pocket", """
intersection() {
  translate([-0.5,-0.5,-0.1]) { cube([1,1,12]); }
  driveshaft_magnet_sleeve();
}
""", empty=True)

        # Both flat styles, alternative hardware, positive/negative lip allowance,
        # and a flattened outer cup must retain the same shaft and seat datums.
        for both, recess, hull in [(False, -0.3, False), (True, 0.3, True)]:
            common = f"""
spec=["d",5,"pad_l",8,"flat_d",3.8,"flat_both_sides",{str(both).lower()},
      "hole_d",2.6,"hole_edge_dist",1.5];
p=driveshaft_magnet_sleeve_params(spec, magnet_d=6, magnet_h=2.5,
    h_clearance=0.4, magnet_h_clearance={recess});
module sleeve(anchor=[0,0,1], slot=false) {{
  driveshaft_magnet_sleeve(p, anchor=anchor, slot_mode=slot,
    use_flat_d_form={str(hull).lower()}, use_hull={str(hull).lower()});
}}
module shaft() {{
  translate([0,0,8]) {{
    rotate([0,180,0]) {{
      motor_drive_shaft(d=5,l=30,pad_l=8,pad_w=3.8,hole_d=2.6,hole_edge_dist=1.5,
        pad_horizontal_one_side={str(not both).lower()});
    }}
  }}
}}
"""
            check(f"changed sleeve, two flats={both}", common + "sleeve();")
            check(f"changed shaft fit, two flats={both}", common +
                  "intersection() { sleeve(); shaft(); }", empty=True)
            check(f"open shaft-to-magnet passage, two flats={both}", common + """
intersection() {
  translate([-1,-1,-0.1]) { cube([2,2,14]); }
  sleeve();
}
""", empty=True)
            check(f"rotating envelope, two flats={both}", common +
                  "difference() { sleeve(); sleeve(slot=true); }", empty=True)
            check(f"negative anchor, two flats={both}", common + "sleeve(anchor=[-1,-1,-1]);")
            bounds = mesh_bounds(mesh)
            height = 8 + 0.4 + 2.5 + recess
            expected = [[-8.5, -8.5, -height], [0, 0, 0]]
            assert all(abs(a-b) < 0.002 for row, exp in zip(bounds, expected)
                       for a, b in zip(row, exp)), (bounds, expected)

        # Single-ended flats used to shorten or disconnect the pin; no flats
        # must preserve a complete cylinder even with pad dimensions supplied.
        for side in ("top", "bottom", "all", "none"):
            pin = f'suspension_arm_pin(d=4,l=30,pad_l=5,pad_w=3,pad_side="{side}",fn=64);'
            check(f"pin full length/{side}", pin)
            bounds = mesh_bounds(mesh)
            assert abs(bounds[0][2]) < 1e-5 and abs(bounds[1][2]-30) < 1e-5, bounds
            for z, cut in [(1, side in ("bottom", "all")), (28, side in ("top", "all"))]:
                probe = f'translate([-0.1,1.7,{z}]) {{ cube([0.2,0.1,0.5]); }}'
                expression = f'intersection() {{ {probe} {pin} }}' if cut else f'difference() {{ {probe} {pin} }}'
                check(f"pin flat selection/{side}/{z}", expression, empty=True)

        check("five separate printable parts", f'include <{ROOT}/scad/motor_brackets/rc/printable.scad>',
              components=5)
        assert abs(mesh_bounds(mesh)[0][2]) < 1e-5
        check("encoder bracket on bed", f'include <{ROOT}/scad/motor_brackets/rc/gearmotor_encoder_printable.scad>')
        assert abs(mesh_bounds(mesh)[0][2]) < 1e-5

    print("PASS sleeve variants, open bores, manifold surfaces, anchors, pin flats and printable layouts", flush=True)


if __name__ == "__main__":
    main()
