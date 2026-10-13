"""Check inserted microSD and USB-C geometry, attachment and board transforms.

Author: Karim Aziiev <karim.aziiev@gmail.com>
License: GPL-3.0-or-later
"""

from pathlib import Path
import subprocess
import tempfile

from check_rear_chassis_mesh import read_triangles
from scad_test_support import OPENSCAD

ROOT = Path(__file__).resolve().parents[1]
Bounds = tuple[list[float], list[float]]


def render(folder: Path, name: str, body: str) -> Bounds:
    source = folder / f"{name}.scad"
    mesh = folder / f"{name}.stl"
    source.write_text(f"""
include <{ROOT}/scad/parameters.scad>
use <{ROOT}/scad/placeholders/rpi_5.scad>
use <{ROOT}/scad/placeholders/rpi_5_grid.scad>
use <{ROOT}/scad/placeholders/micro_sd.scad>
use <{ROOT}/scad/placeholders/usb/generic_usb_socket.scad>
use <{ROOT}/scad/core/pcb_placeholder_renderer.scad>
use <{ROOT}/tests/test_rpi_5_grid.scad>

module component(type, plug=false, card=true) {{
  boxes = board_boxes(rpi_5_grid(show_usb_c_plug=plug, show_sd_card=card),
                       rpi_thickness);
  box = of_type(boxes, type)[0];
  translate(box[1]) {{
    pcb_placeholder_renderer(plist=box[0]);
  }}
}}
{body}
""")
    result = subprocess.run(
        [OPENSCAD, "--backend=Manifold", "--enable=textmetrics", "--hardwarnings",
         "--export-format", "binstl", "-o", str(mesh), str(source)],
        capture_output=True, text=True,
    )
    log = result.stdout + result.stderr
    assert result.returncode == 0 and "ERROR:" not in log and "WARNING:" not in log, log
    points = [point for triangle in read_triangles(mesh) for point in triangle]
    return ([min(p[i] for p in points) for i in range(3)],
            [max(p[i] for p in points) for i in range(3)])


def near(actual: list[float], expected: list[float]) -> None:
    assert all(abs(a - b) < 0.02 for a, b in zip(actual, expected)), (actual, expected)


def main() -> None:
    with tempfile.TemporaryDirectory(prefix="rpi-accessories-") as temporary:
        folder = Path(temporary)
        card = render(folder, "card", "micro_sd_card();")
        near(card[0], [0, 0, 0])
        near(card[1], [11, 15, 1])
        empty = render(folder, "sd_empty", 'component("micro_sd_socket", card=false);')
        inserted = render(folder, "sd_inserted", 'component("micro_sd_socket");')
        near(empty[0], [21.94, 2.25, -1.45])
        near(empty[1], [33.89, 13.65, -0.03])
        near(inserted[0], [21.94, -2, -1.45])
        near(inserted[1], empty[1])
        print("PASS microSD: full card envelope, socket position and 2 mm PCB overhang")

        socket = render(folder, "usb_empty", 'component("usb_socket");')
        plugged = render(folder, "usb_plugged", 'component("usb_socket", plug=true);')
        near(socket[0], [49.6, 7.1, 1.406])
        near(socket[1], [57.2, 15.3, 4.566])
        near(plugged[0], [49.6, 5.585, -0.864])
        near(plugged[1], [79.1, 16.815, 6.836])
        # Socket opening offsets also locate the inserted plug.
        shifted = render(folder, "usb_offset", """
usb_socket(plist=["size", [12, 10, 5], "offsets", [1, 0, 0.5]],
            usb_plist=usb_c_plist, anchor=[1, 1, 1], show_usb_plug=true);
""")
        near(shifted[0], [0, -21.9, -0.85])
        near(shifted[1], [12.615, 10, 6.85])
        print("PASS USB-C: local axes, seated plug, strain relief and opening offsets")

        for orientation, anchor, expected in [
            ("wlh", "[1,1,1]", [-2, 79.1]),
            ("lwh", "[1,1,1]", [90, 79.1]),
            ("lwh", "[0,0,1]", [46, 51.1]),
        ]:
            bounds = render(folder, f"board_{orientation}_{anchor}", f"""
rpi_5(show_sd_card=true, show_usb_c_plug=true, plugged_usb_a=[],
       orientation="{orientation}", anchor={anchor});
""")
            measured = ([bounds[0][1], bounds[1][0]] if orientation == "wlh"
                        else bounds[1][:2])
            near(measured, expected)
        hidden = render(folder, "board_hidden", """
rpi_5(show_sd_card=false, show_usb_c_plug=false, plugged_usb_a=[]);
""")
        near([hidden[0][1], hidden[1][0]], [-0.4, 57.63])
        print("PASS board: accessory toggles, rotation and centered anchoring")


if __name__ == "__main__":
    main()
