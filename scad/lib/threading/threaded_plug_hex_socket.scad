/**
  * Module: Hex socket threaded plug
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>

use <thread_funcs.scad>
use <threads.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  threaded_plug_hex_socket
  ─────────────────────────────────────────────────────────────────────────────

  **Example**:
  ```scad
  threaded_plug_hex_socket(d=9.8, l=5.8, hex_size=5);
  ```
  */
module threaded_plug_hex_socket(d=9.8,
                                l=5.8,
                                hex_size=5,
                                tolerance=0.4,
                                color=metallic_silver_1) {
  drive_tolerance = pow(3 * tolerance / hex_drive_across_corners(d), 2)
    + 0.75 * tolerance;

  hex_r = (hex_drive_across_corners(hex_size) + drive_tolerance) / 2;

  render() {
    difference() {
      color(color) {
        screw_thread(d,
                     height=l + 0.01,
                     tolerance=tolerance,
                     tip_height=thread_pitch(d),
                     tip_min_fract=0.75);
      }
      translate([0, 0, -0.5]) {
        cylinder(h=l + 1,
                 r=hex_r,
                 $fn=6,
                 center=false);
      }
    }
  }
}

module threaded_plug_hex_socket_slot(d=9.8,
                                     l=5.8,
                                     tolerance=0.4) {
  screw_hole_thread(d=d, h=l, tolerance=tolerance);
}
