"""Check calibration recess dimensions, label modes, anchors, and invalid inputs.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""
from math import pi, sin
from pathlib import Path
import struct
import subprocess
import tempfile

from check_gearmotor_encoder_mesh import connected_components, mesh_volume
from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]
COMMON = f'''
use <{ROOT}/scad/counterbore_probes.scad>
use <{ROOT}/scad/lib/plist.scad>
specs = [["d", 2, "bore_d", 4, "bore_h", 1, "sink", sink]];
'''


def z_bounds(path: Path) -> tuple[float, float]:
    values = [row[i] for row in struct.iter_unpack("<12fH", path.read_bytes()[84:])
              for i in (5, 8, 11)]
    return min(values), max(values)


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="counterbore-probes-") as folder:
        source = Path(folder) / "probe.scad"
        mesh = source.with_suffix(".stl")

        def render(code: str, reject: str = "", empty: bool = False,
                   sink: bool = False) -> float:
            source.write_text(f"sink = {str(sink).lower()};\n" + COMMON + code)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics",
                 "--hardwarnings", "--export-format", "binstl",
                 "-o", str(mesh), str(source)], capture_output=True, text=True)
            log = result.stdout + result.stderr
            if reject:
                assert "ERROR: Assertion" in log and reject in log, log
                assert "WARNING:" not in log, log
                return 0
            assert "ERROR:" not in log and "WARNING:" not in log, log
            if empty and "Current top level object is empty" in log:
                return 0
            assert result.returncode == 0, log
            volume = mesh_volume(mesh)
            if empty:
                assert volume < 0.00001, log
            return volume

        # Polygon cross sections account for the configured cylinder resolution.
        factor = 100 * sin(2 * pi / 100) / 2
        for sink, removed in [(False, 6 * factor), (True, (2 + 7 / 3) * factor)]:
            volume = render('''
hole_probes(specs, label_mode="none", corner_r=0);
''', sink=sink)
            assert abs(volume - (8 * 8 * 3 - removed)) < 0.0001
            assert connected_components(mesh) == 1
            assert z_bounds(mesh) == (0, 3)
        print("PASS exact counterbore and countersink dimensions")

        body = render('hole_probes(specs, part="body");')
        raised = render('hole_probes(specs);')
        assert connected_components(mesh) == 1
        assert abs(z_bounds(mesh)[1] - 3.2) < 0.00001
        labels = render('hole_probes(specs, part="labels");')
        assert abs(z_bounds(mesh)[0] - 3) < 0.00001
        assert abs(raised - body - labels) < 0.0001
        engraved = render('hole_probes(specs, label_mode="engraved");')
        assert z_bounds(mesh) == (0, 3)
        assert connected_components(mesh) == 1
        assert abs(body - engraved - labels) < 0.0001
        render('''
p = hole_probes_layout(specs, label_mode="engraved");
size = plist_get("size", p);
difference() {
  difference() {
    cube(size);
    hole_probes(specs, label_mode="engraved", slot_mode=true);
  }
  hole_probes(specs, label_mode="engraved", corner_r=0);
}
''', empty=True)
        render('hole_probes(specs, label_mode="none", anchor=[-1, 0, -1]);')
        assert z_bounds(mesh) == (-3, 0)
        print("PASS raised/engraved labels, material parts, cutters, and anchors")

        for code, message in [
            ('hole_probes([]);', "specs must not be empty"),
            ('hole_probes([["d", 2, "bore_d", [], "bore_h", 1]]);',
             "bore_d must not be empty"),
            ('hole_probes([["d", 4, "bore_d", 4, "bore_h", 1]]);',
             "bore_d must be larger than d"),
            ('hole_probes(specs, thickness=2);', "thickness must be at least"),
            ('hole_probes(specs, gap=0);', "gap must be positive"),
            ('hole_probes(specs, text_h=3);', "text_h must be positive"),
        ]:
            render(code, reject=message)
        print("PASS invalid probe specifications and dimensions are rejected")


if __name__ == "__main__":
    main()
