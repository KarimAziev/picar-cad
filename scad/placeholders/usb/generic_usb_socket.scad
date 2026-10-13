/**
  * Module: Generic Usb Socket
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>

use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <generic_usb_plug.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  usb_socket_size
  ─────────────────────────────────────────────────────────────────────────────
  Return a USB socket's oriented body reference size.

  **Parameters:**
  - `plist`: Socket properties, including local `size=[width, depth, height]`.
  - `usb_plist`: Plug properties used to derive an omitted socket size.
  - `orientation`: Body orientation, default `"wlh"`.

  **Returns:** Oriented `[x, y, z]` body dimensions, excluding an inserted plug.
  Local width is across the opening on X; depth follows insertion along +Y.
 */
function usb_socket_size(plist=[], usb_plist=[], orientation="wlh") =
  let (shell = plist_get("plug_shell_size", usb_plug_params(usb_plist)),
       size = plist_get("size", plist,
                        [shell[0] + 0.5, shell[1] + 2, shell[2] + 3]))
  assert(len(size) == 3 && min(size) > 0, "Socket size must be positive XYZ")
  orientation_size(orientation, size);

/**
  ─────────────────────────────────────────────────────────────────────────────
  usb_socket
  ─────────────────────────────────────────────────────────────────────────────
  Render a USB socket opening toward local -Y and an optional seated plug.

  **Parameters:**
  - `plist`: Local `size=[width, depth, height]`, `color`, `corner_r`,
    `round_axis` and opening-center `offsets=[x,y,z]`.
  - `usb_plist`: Plug properties accepted by `generic_usb_plug`.
  - `orientation`: Orientation of the complete socket and plug.
  - `anchor`: Placement against the socket body, excluding the plug.
  - `show_usb_plug`: Display the seated plug and strain relief.
  - `rotate_z_180`: Apply an additional half-turn to socket and plug together.

  `orientation="lwh"` points the opening toward +X. The plug body meets the
  mouth plane and follows the same offsets as the opening.
 */
module usb_socket(plist,
                  usb_plist,
                  orientation="wlh",
                  anchor=[0, 1, 1],
                  show_usb_plug=false,
                  rotate_z_180=false) {
  plist = with_default(plist, []);
  usb_params = usb_plug_params(with_default(usb_plist, []));

  plug_shell_size = plist_get("plug_shell_size", usb_params);
  plug_shell_round_axis = plist_get("plug_shell_round_axis", usb_params);
  plug_shell_corner_r = plist_get("plug_shell_corner_r", usb_params);

  usb_offset = plist_get("offsets", plist, [0, 0, 0]);

  corner_r = plist_get("corner_r", plist);
  round_axis = plist_get("round_axis", plist, "z");

  size = usb_socket_size(plist, with_default(usb_plist, []));

  color = plist_get("color", plist, metallic_silver_4);

  with_orientation(from="wlh",
                   to=orientation,
                   anchor=anchor,
                   size=size,
                   rotate_z_180=rotate_z_180) {
    translate([0, -size[1] / 2, size[2] / 2]) {
      difference() {
        color(color) {
          cuboid(size=size, anchor=[0, 1, 0], r=corner_r, axis=round_axis);
        }
        translate(usb_offset) {
          translate([0, -0.1, 0]) {
            cuboid(anchor=[0, 1, 0],
                   size=plug_shell_size,
                   r=plug_shell_corner_r,
                   axis=plug_shell_round_axis);
          }
        }
      }

      if (show_usb_plug) {
        translate(usb_offset + [0, plug_shell_size[1], 0]) {
          generic_usb_plug(usb_plist, anchor=[0, -1, 0]);
        }
      }
    }
  }
}

module multi_usb_socket(size=rpi_usb_a_size,
                        usb_rows=2,
                        color=metallic_yellow_silver,
                        offsets=[0, 0, 1],
                        plugged_usb_idxes=[],
                        usb_plist=usb_a_plist,
                        orientation="wlh",
                        rotate_z_180=true,
                        anchor=[0, 1, 1]) {

  single_h = size[2] / usb_rows;

  with_orientation(from="wlh", to=orientation, anchor=anchor, size=size) {
    for (i = [0: usb_rows - 1]) {
      let (z = i * single_h) {
        translate([0, 0, z]) {
          usb_socket(usb_plist=usb_plist,
                     rotate_z_180=rotate_z_180,
                     show_usb_plug=in_list(i, plugged_usb_idxes),
                     anchor=[0, 0, 1],
                     plist=["size", [size[0], size[1], single_h],
                            "color", color,
                            "offsets", offsets]);
        }
      }
    }
  }
}
// multi_usb_socket();
usb_socket(usb_plist=usb_c_plist,
           plist=usb_c_socket_plist,
           show_usb_plug=false);

// generic_usb_plug(plist=usb_c_plist,
//                  anchor=[1, 1, 0]);