"""Verify rear joint attachment lands and clearance between assembled halves.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""

import ast
from pathlib import Path
import subprocess
import tempfile

import numpy as np
import trimesh

from check_rear_chassis_mesh import ray_hits, read_triangles
from scad_test_support import OPENSCAD, echo_value

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="rear-joint-mesh-") as folder:
        source = Path(folder) / "fixture.scad"
        output = Path(folder) / "fixture.stl"
        source.write_text(f"""
include <{ROOT}/scad/suspension/rear_chassis/computed_params.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/suspension/rear_chassis/rear_chassis_frame.scad>
use <{ROOT}/scad/suspension/rear_suspension/rear_suspension_mount.scad>
use <{ROOT}/scad/suspension/rear_suspension/rear_suspension_joint.scad>
part = "frame";
changed = false;
original = rear_chassis_layout();
layout = changed
    ? plist_merge(original,
                  ["suspension_w", plist_get("suspension_w", original) + 8,
                   "transition_y_end", plist_get("transition_y_end", original) - 2])
    : original;
start = plist_get("transition_y_start", layout);
end = plist_get("transition_y_end", layout);
w = plist_get("suspension_w", layout);
echo(probes=[for (x = [-w / 4, 0, w / 4], dy = [-0.1, 0, 0.2])
                [x, end + dy]]);
if (part == "frame") {{
  rear_chassis_frame(layout=layout);
}} else if (part == "mount") {{
  rear_suspension_mount(layout=layout);
}} else if (part == "female_root") {{
  intersection() {{
    rear_suspension_chassis_joint(mode="female", layout=layout,
                                  anchor=[0, -1, 1]);
    translate([-w / 2, 0, 0]) {{
      cube([w, 0.01, chassis_thickness]);
    }}
  }}
}} else if (part == "collision") {{
  intersection() {{
    rear_chassis_frame(layout=layout);
    rear_suspension_mount(layout=layout);
  }}
}}
""")
        for changed in (False, True):
            # Synthetic joint dimensions do not carry the stock deck's harness.
            wiring_args = ["-D", 'rear_power_wiring=["enabled", false]'] if changed else []
            for part in ("frame", "mount", "female_root", "collision"):
                result = subprocess.run(
                    [OPENSCAD, "--backend=Manifold", "--enable=textmetrics",
                     "--hardwarnings", "--export-format", "binstl",
                     "-o", str(output), "-D", f'part="{part}"',
                     "-D", f"changed={str(changed).lower()}", *wiring_args, str(source)],
                    capture_output=True, text=True,
                )
                log = result.stdout + result.stderr
                assert "WARNING:" not in log and "ERROR:" not in log, log
                if part == "collision" and "Current top level object is empty" in log:
                    continue
                assert result.returncode == 0, log
                mesh = trimesh.load_mesh(output)
                assert isinstance(mesh, trimesh.Trimesh)
                if part == "collision":
                    triangles = mesh.triangles
                    volume = np.einsum(
                        "ij,ij->i", triangles[:, 0],
                        np.cross(triangles[:, 1], triangles[:, 2]),
                    ).sum() / 6
                    assert abs(volume) < 1e-6, (changed, volume, mesh.bounds)
                    continue
                assert mesh.is_watertight and mesh.volume > 0, (part, changed)
                if part != "female_root":
                    assert len(mesh.split()) == 1, (part, changed)
                if part == "frame":
                    triangles = read_triangles(output)
                    for x, y in ast.literal_eval(echo_value(log, "probes")):
                        assert ray_hits(triangles, x, y), (
                            "Slit at chassis joint attachment", changed, x, y,
                        )
            print(f"PASS rear joint changed={changed}: solid attachment lands, "
                  "connected halves, female root overlap and no interference")


if __name__ == "__main__":
    main()
