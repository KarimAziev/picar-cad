# Module: Rear camber-link mounting bore checks.
#
# Author: Karim Aziiev <karim.aziiev@gmail.com>
# License: GPL-3.0-or-later

"""Check that spherical rod-end bores remain open along vehicle Y."""

from pathlib import Path
import subprocess
import tempfile

from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    common = f"""
include <{ROOT}/scad/suspension/rear_axle/rear_camber_link_params.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/suspension/rear_axle/rear_camber_link.scad>
start = [0, 0, 0];
"""
    with tempfile.TemporaryDirectory(prefix="rear-camber-link-") as folder:
        source = Path(folder) / "fixture.scad"
        output = Path(folder) / "fixture.stl"
        for delta in ("[50, 0, 0]", "[50, 7, 12]"):
            source.write_text(common + f"""
end = {delta};
fit = rear_camber_link_fit(start, end, rear_camber_link_spec);
intersection() {{
  rear_camber_link_between(start, end, rear_camber_link_spec);
  union() {{
    for (p = [start, plist_get("hardware_end", fit)]) {{
      translate(p) {{
        rotate([90, 0, 0]) {{
          cylinder(d=plist_get("bushing_d", rear_camber_link_spec) - 0.05,
                   h=plist_get("bushing_h", rear_camber_link_spec) + 2,
                   center=true, $fn=64);
        }}
      }}
    }}
  }}
}}
""")
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics",
                 "--hardwarnings", "-o", str(output), str(source)],
                capture_output=True, text=True,
            )
            log = result.stdout + result.stderr
            assert "ERROR:" not in log and "WARNING:" not in log, log
            assert "Current top level object is empty" in log, log
            print(f"PASS camber-link Y bores remain open for {delta}", flush=True)


if __name__ == "__main__":
    main()
