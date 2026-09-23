"""Export both encoder mount parts and check modeled hardware clearances.

Run: python3 tests/check_gearmotor_encoder_mesh.py
Requires OpenSCAD; uses only the Python standard library.
"""
from pathlib import Path
import struct
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def connected_components(path):
    data = path.read_bytes()
    count = struct.unpack_from("<I", data, 80)[0]
    assert len(data) == 84 + 50 * count
    parent = {}

    def find(v):
        parent.setdefault(v, v)
        if parent[v] != v:
            parent[v] = find(parent[v])
        return parent[v]

    for row in struct.iter_unpack("<12fH", data[84:]):
        vertices = [tuple(round(v, 5) for v in row[start:start + 3]) for start in (3, 6, 9)]
        a, b, c = map(find, vertices)
        parent[b] = a
        parent[c] = a
    return len({find(v) for v in parent})


def mesh_volume(path):
    volume = 0.0
    for t in struct.iter_unpack("<12fH", path.read_bytes()[84:]):
        a, b, c = t[3:6], t[6:9], t[9:12]
        volume += sum(a[i] * (b[(i+1) % 3] * c[(i+2) % 3]
                              - b[(i+2) % 3] * c[(i+1) % 3])
                      for i in range(3)) / 6
    return abs(volume)


def main():
    common = f'''
use <{ROOT}/scad/motor_brackets/rc/gearbox_bracket.scad>
use <{ROOT}/scad/motor_brackets/rc/gearmotor_encoder_bracket.scad>
use <{ROOT}/scad/placeholders/motors/rc/gearmotor.scad>
use <{ROOT}/scad/lib/plist.scad>
p=gearmotor_bracket_compute_params();
e=plist_get("encoder_mount",p);
module base() {{
  gearmotor_bracket(params=p, anchor=[0,0,1], show_gearbox=false, show_motor=false,
    show_bearing=false, show_drive_shaft=false, show_mount_bolts=false, show_nuts=false,
    show_shaft_seeve=false, show_extra_drive_shaft=false,
    show_encoder_bracket=false, show_encoder=false, show_encoder_magnet=false);
}}
module mount() {{ gearmotor_encoder_bracket(e); }}
module hardware() {{
  gearmotor(plist_get("motor",p), parent_thickness=plist_get("bracket_thickness",p));
}}
module electronics() {{
  gearmotor_encoder_bracket(e, show_bracket=false, show_encoder=true,
                            show_mount_bolts=false);
}}
module fasteners() {{
  gearmotor_encoder_bracket(e, show_bracket=false, show_encoder=true,
                            show_mount_bolts=true);
}}
'''
    cases = [
        ("base", "base();", False),
        ("mount", "mount();", False),
        ("separate-parts", "intersection() { base(); mount(); }", True),
        ("motor-mount", "intersection() { hardware(); mount(); }", True),
        ("motor-pcb", "intersection() { hardware(); electronics(); }", True),
        ("motor-fasteners", "intersection() { hardware(); fasteners(); }", True),
        ("pcb-mount", "intersection() { electronics(); mount(); }", True),
        ("base-fasteners", "intersection() { base(); fasteners(); }", True),
        ("mount-fasteners", "intersection() { mount(); fasteners(); }", True),
    ]
    with tempfile.TemporaryDirectory(prefix="gearmotor-encoder-") as folder:
        source = Path(folder) / "fixture.scad"
        for label, call, empty in cases:
            source.write_text(common + call + "\n")
            mesh = Path(folder) / f"{label}.stl"
            result = subprocess.run(
                ["openscad", "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
                 "--export-format", "binstl", "-o", str(mesh), str(source)],
                text=True, capture_output=True)
            log = result.stdout + result.stderr
            assert "WARNING:" not in log and "ERROR:" not in log, log
            if empty:
                # Manifold can export zero-volume contact faces at the foot/base
                # seating plane; these are contact, not material interference.
                if "Current top level object is empty" not in log:
                    assert result.returncode == 0 and mesh_volume(mesh) < 0.000001, (label, mesh_volume(mesh), log)
            else:
                assert result.returncode == 0, log
                assert connected_components(mesh) == 1, (label, "disconnected print")
            print(f"PASS {label}: {'no interference' if empty else 'one connected printable solid'}", flush=True)


if __name__ == "__main__":
    main()
