# Module: Gearbox loft mesh checks
#
# Check winding, concavity, warped sides, and use in Boolean operations.
#
# Author: Karim Aziiev <karim.aziiev@gmail.com>
# Copyright (C) 2026 Karim Aziiev
# License: GPL-3.0-or-later; see LICENSE in the repository root.


from pathlib import Path
import subprocess
import tempfile

import trimesh

from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    common = f"""
use <{ROOT}/scad/motor_brackets/rc/gearbox_bracket.scad>
use <{ROOT}/scad/motor_brackets/rc/util.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/lib/functions.scad>
// A concave L with an independently known area of 7 square millimeters.
a = [[0,0], [4,0], [4,1], [1,1], [1,4], [0,4]];
b = [[0,0], [4,0], [4,4], [0,4]];
"""
    with tempfile.TemporaryDirectory(prefix="gearbox-loft-") as folder:
        source = Path(folder) / "fixture.scad"
        output = Path(folder) / "fixture.stl"

        def check(label: str, code: str, volume: float | None = None) -> None:
            source.write_text(common + code)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics",
                 "--hardwarnings", "--export-format", "binstl",
                 "-o", str(output), str(source)],
                capture_output=True, text=True,
            )
            log = result.stdout + result.stderr
            assert result.returncode == 0, (label, log)
            assert "ERROR:" not in log and "WARNING:" not in log, (label, log)
            mesh = trimesh.load_mesh(output)
            assert isinstance(mesh, trimesh.Trimesh)
            assert mesh.is_watertight and mesh.is_winding_consistent and mesh.is_volume, label
            assert len(mesh.split()) == 1, (label, "disconnected solid")
            assert mesh.nondegenerate_faces().all(), (label, "degenerate faces")
            assert mesh.unique_faces().all(), (label, "duplicate faces")
            if volume is not None:
                assert abs(mesh.volume - volume) < 1e-5, (label, mesh.volume, volume)
            print(f"PASS {label}", flush=True)

        check("concave CCW prism", "loft_polyhedron(a,a,3);", 21)
        check("concave CW prism", "loft_polyhedron(reverse(a),reverse(a),3);", 21)
        check("point metadata", '''
c = [for (p = a) concat(p, [["text", "vertex"]])];
loft_polyhedron(c,c,3);
''', 21)
        check("tapered concave loft", "loft_polyhedron(a,2*a,3,steps=8);", 49)
        check("Boolean cut", '''
difference() {
  loft_polyhedron(a,a,3);
  translate([0.25,0.25,-1]) { cube([0.5,0.5,5]); }
}
''', 20.25)
        check("nonplanar sides", '''
t = [[0,0],[3,0.5],[4,3],[0.5,4]];
loft_polyhedron(b,t,3,steps=12);
''')
        check("gearbox profiles", '''
p = gearmotor_bracket_compute_params();
loft_polyhedron(plist_get("pts_2",p),plist_get("pts",p),
                plist_get("bracket_thickness",p),steps=24);
''')

        for label, call in [
            ("mismatched vertices", "loft_polyhedron(a,b,3);"),
            ("opposite winding", "loft_polyhedron(a,reverse(a),3);"),
            ("zero height", "loft_polyhedron(a,a,0);"),
            ("fractional steps", "loft_polyhedron(a,a,3,steps=1.5);"),
            ("duplicate vertex", "loft_polyhedron([[0,0],[0,0],[1,1]],[[0,0],[1,0],[1,1]],3);"),
        ]:
            source.write_text(common + call)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics",
                 "-o", str(output), str(source)],
                capture_output=True, text=True,
            )
            assert "ERROR: Assertion" in result.stderr, (label, result.stderr)
            print(f"PASS rejects {label}", flush=True)


if __name__ == "__main__":
    main()
