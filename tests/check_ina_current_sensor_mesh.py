"""Check optional INA specifications, pin layout and mounting alignment.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""

from pathlib import Path
import subprocess
import tempfile

from scad_test_support import OPENSCAD
from check_gearmotor_encoder_mesh import connected_components, mesh_volume

ROOT = Path(__file__).resolve().parents[1]
COMMON = f'''
include <{ROOT}/scad/parameters.scad>
use <{ROOT}/scad/lib/plist.scad>
use <{ROOT}/scad/placeholders/ina_current_sensor.scad>
minimal = ["size", [22.9, 23.1, 1.65],
           "bolt_spacing", [17.78, 0], "bolt_d", 2.6];
$fn=24;
'''


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="ina-current-sensor-") as folder:
        source = Path(folder) / "fixture.scad"

        def render(code: str, *, csg: bool = False, empty: bool = False,
                   reject: str = "") -> Path:
            output = source.with_suffix(".csg" if csg else ".stl")
            source.write_text(COMMON + code)
            result = subprocess.run(
                [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
                 *([] if csg else ["--export-format", "binstl"]),
                 "-o", str(output), str(source)],
                capture_output=True, text=True)
            log = result.stdout + result.stderr
            if reject:
                assert "ERROR: Assertion" in log and reject in log, log
                assert "WARNING:" not in log, log
                return output
            assert "ERROR:" not in log and "WARNING:" not in log, log
            if empty and "Current top level object is empty" in log:
                return output
            assert result.returncode == 0, log
            if empty:
                assert mesh_volume(output) < 0.00001, log
            return output

        # Each optional key may be removed without disabling unrelated features.
        render('''
module check(pl) {
  ina_current_sensor(pl, show_pins=true, show_terminal=true, show_standoffs=true);
}
for (key = plist_keys(ina_plist)) {
  if (key != "size" && key != "bolt_spacing" && key != "bolt_d") {
    check(plist_remove(key, ina_plist));
    check(plist_merge(ina_plist, [key, undef]));
  }
}
for (key = ["chip", "pin", "power_pad", "i2c", "screw_terminal"]) {
  group = plist_get(key, ina_plist);
  for (prop = plist_keys(group)) {
    check(plist_merge(ina_plist, [key, plist_remove(prop, group)]));
    check(plist_merge(ina_plist, [key, plist_merge(group, [prop, undef])]));
  }
  for (value = [[], undef]) {
    check(plist_merge(ina_plist, [key, value]));
  }
}
for (key = ["header", "text_style"]) {
  pin = plist_get("pin", ina_plist);
  group = plist_get(key, pin);
  for (prop = plist_keys(group)) {
    check(plist_merge(ina_plist,
      ["pin", plist_merge(pin, [key, plist_remove(prop, group)])]));
  }
}
for (key = ["top_texts", "bottom_texts"]) {
  for (spec = plist_get(key, ina_plist)) {
    for (prop = plist_keys(spec)) {
      check(plist_merge(minimal, [key, [plist_remove(prop, spec)]]));
    }
  }
}
check(minimal);
''', csg=True)
        print("PASS optional groups and properties can be omitted", flush=True)

        for key in ("size", "bolt_spacing", "bolt_d"):
            render(f'ina_current_sensor(plist_remove("{key}", minimal));',
                   csg=True, reject=key)
        print("PASS required board properties produce clear assertions", flush=True)

        # A minimal PCB retains its mounting pattern in every supported frame.
        for orientation in ("wlh", "lwh", "whl", "lhw", "hlw", "hwl"):
            render(f'''
intersection() {{
  ina_current_sensor(minimal, orientation="{orientation}", anchor=[-1,1,0]);
  ina_current_sensor(minimal, orientation="{orientation}", anchor=[-1,1,0],
                     slot_mode=true);
}}
''', empty=True)
        for spacing, count in (("[17.78,0]", 2), ("[17.78,16]", 4)):
            mesh = render(f'''ina_current_sensor(
plist_merge(minimal, ["bolt_spacing", {spacing}]), slot_mode=true);''')
            assert connected_components(mesh) == count
        print("PASS mounting cutters align with two/four-hole boards and all orientations",
              flush=True)

        # Header holes are independent of labels, pad decoration and hardware.
        for cols in (1, 3, 8):
            render(f'''
pin = ["cols", {cols}, "pitch", 2.54, "y_offset", 2.25, "hole_d", 1];
intersection() {{
  ina_current_sensor(plist_merge(minimal, ["pin", pin]));
  for (i = [0 : {cols - 1}]) {{
    translate([(i - ({cols} - 1) / 2) * 2.54, -9.3, -0.1]) {{
      cylinder(d=0.95, h=1.85);
    }}
  }}
}}
''', empty=True)
            mesh = render(f'''ina_current_sensor(plist_merge(minimal,
["pin", ["cols", {cols}, "pitch", 2.54, "y_offset", 2.25, "hole_d", 1]]));''')
            assert connected_components(mesh) == 1
        print("PASS one, three and eight unlabeled holes cut a connected PCB", flush=True)

        render('''ina_current_sensor(show_pins=true, show_terminal=true,
show_standoffs=true, parent_thickness=4, anchor_z_mode="standoff");''')
        render('''ina_current_sensor(minimal, show_pins=true, show_terminal=true,
show_standoffs=true, anchor_z_mode="pin");''')
        print("PASS complete and minimal configurations export meshes", flush=True)


if __name__ == "__main__":
    main()
