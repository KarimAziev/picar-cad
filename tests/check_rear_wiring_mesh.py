"""Check rear-payload harness placement and exclusion from chassis cutters.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""
from pathlib import Path
import subprocess
import tempfile

from scad_test_support import OPENSCAD
from check_gearmotor_encoder_mesh import mesh_volume

ROOT = Path(__file__).resolve().parents[1]
COMMON = f'''
include <{ROOT}/scad/suspension/rear_chassis/computed_params.scad>
use <{ROOT}/scad/suspension/rear_chassis/rear_payload.scad>
use <{ROOT}/scad/lipo_pack_case/lid_wiring.scad>
use <{ROOT}/scad/lib/plist.scad>
payload=plist_get("power_case",rear_chassis_layout());
module actual() {{rear_power_payload(payload,show_lidar=false);}}
module expected() {{
 rear_power_payload(payload,show_lidar=false,show_wiring=false);
 translate(plist_get("pos",payload)+[0,0,plist_get("mount_z",payload)]) {{
  lid_wiring(rear_power_lid_plist(plist_get("plist",payload),plist_get("lidar",payload)));
 }}
}}
'''


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="rear-wiring-") as folder:
        source = Path(folder) / "fixture.scad"
        mesh = Path(folder) / "fixture.stl"

        def empty(code: str) -> None:
            source.write_text(COMMON + code)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
                 "--export-format", "binstl", "-o", str(mesh), str(source)],
                capture_output=True, text=True)
            log = result.stdout + result.stderr
            assert "ERROR:" not in log and "WARNING:" not in log, log
            if "Current top level object is empty" in log:
                return
            assert result.returncode == 0, log
            assert mesh_volume(mesh) < 0.00001, (mesh_volume(mesh), log)

        empty('''union() {
 difference() {actual(); expected();}
 difference() {expected(); actual();}
}''')
        print("PASS default rear wiring matches the resolved lid and raised case frame", flush=True)
        empty('''union() {
 difference() {
  rear_power_payload(payload,slot_mode=true,show_wiring=true);
  rear_power_payload(payload,slot_mode=true,show_wiring=false);
 }
 difference() {
  rear_power_payload(payload,slot_mode=true,show_wiring=false);
  rear_power_payload(payload,slot_mode=true,show_wiring=true);
 }
 rear_power_payload(payload,show_case=false,show_standoffs=false,
                    show_lid=false,show_lidar=false);
}''')
        print("PASS wiring does not enter chassis cutters or hidden payload previews", flush=True)


if __name__ == "__main__":
    main()
