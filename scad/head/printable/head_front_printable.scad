/**
  * Module: Printable Head Front Frame
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../parameters.scad>

use <../../lib/transforms.scad>
use <../head_mount.scad>

show_bolts = false;
show_nuts = false;

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_front_printable
  ─────────────────────────────────────────────────────────────────────────────
  Front plate with its outward face on Z=0 and rear flanges pointing upward.
  **Parameters:**
  - `anchor`: Anchor on [head_front_width, head_front_height, flange depth].
  - `slot_mode`: Emit the flange holes in printable coordinates.
  - `show_bolts`, `show_nuts`: Independently show frame hardware for inspection.
 */
module head_front_printable(anchor=[1, 1, 1],
                            slot_mode=false,
                            show_bolts=false,
                            show_nuts=false) {
  size = [head_front_width, head_front_height, head_front_flange_depth];
  with_anchor(size=size, anchor=anchor) {
    translate([head_front_width / 2, 0, 0]) {
      mirror([0, 0, 1]) {
        head_front_plate(slot_mode=slot_mode,
                         show_frame_bolts=show_bolts,
                         show_frame_nuts=show_nuts);
      }
    }
  }
}

head_front_printable(show_bolts=show_bolts, show_nuts=show_nuts);
