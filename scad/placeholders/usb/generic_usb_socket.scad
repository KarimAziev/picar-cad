
include <../../colors.scad>
include <../../parameters.scad>

use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <generic_usb_plug.scad>

module usb_socket(plist,
                  usb_plist,
                  orientation="wlh",
                  anchor=[0, 1, 1],
                  show_usb_plug=false,
                  rotate_z_180=false) {
  plist = with_default(plist, []);
  usb_params = usb_plug_params(usb_plist);

  plug_shell_size = plist_get("plug_shell_size", usb_params);

  usb_offset = plist_get("offsets", plist, [0, 0, 0]);

  size = plist_get("size",
                   plist,
                   [plug_shell_size[0] + 0.5,
                    plug_shell_size[1] + 2,
                    plug_shell_size[2] + 3]);

  color = plist_get("color", plist, metallic_silver_4);

  with_orientation(from="wlh",
                   to=orientation,
                   anchor=anchor,
                   size=size,
                   rotate_z_180=rotate_z_180) {
    translate([0, -size[1] / 2, size[2] / 2]) {
      difference() {
        color(color) {
          cuboid(size=size, anchor=[0, 1, 0]);
        }
        translate(usb_offset) {
          translate([0, -0.1, 0]) {
            cuboid(anchor=[0, 1, 0], size=plug_shell_size);
          }
        }
      }

      if (show_usb_plug) {
        translate([0, plug_shell_size[1], 0]) {
          generic_usb_plug(usb_plist, anchor=[0, -1, 0]);
        }
      }
    }
  }
}

usb_socket(usb_plist=usb_a_plist, plist=usb_a_socket_plist);
