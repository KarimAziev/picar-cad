/**
  * Module: Front bumper assembly and head-frame fit preview.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../rc_params.scad>

use <../../lib/transforms.scad>
use <../front_chassis/head_frame/front_chassis_head_frame.scad>
use <common.scad>
use <front_bumper_top_plate.scad>
use <front_bumper_foam.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_bumper_assembly
  ─────────────────────────────────────────────────────────────────────────────
  Assemble the top retainer and TPU body in a canonical positive reference box.
  **Parameters:**
  - `pl`: Shared bumper dimension overrides.
  - `anchor`: Anchor for the complete assembly, excluding hardware.
  - `show_top_plate`: Show the rigid retainer and posts.
  - `show_foam`: Show the TPU body.
  - `show_bolts`: Show screws and underside nuts when the retainer is visible.
  **Behavior:** Use `front_bumper_position(pl)` to place the default anchor
  on the chassis. The bumper follows the head frame's +Y assembly separation.
 */
module front_bumper_assembly(pl=front_bumper_plist,
                             anchor=[1, 1, 1],
                             show_top_plate=true,
                             show_foam=true,
                             show_bolts=false) {
  size = front_bumper_size(pl);
  plate_size = front_bumper_size(pl, "plate");
  with_anchor(size=size, anchor=anchor) {
    if (show_foam) {
      color([0.18, 0.20, 0.23]) {
        front_bumper_foam(pl);
      }
    }
    if (show_top_plate) {
      translate([(size[0] - plate_size[0]) / 2, 0, 0]) {
        front_bumper_top_plate(pl,
                               show_bolts=show_bolts,
                               color=[0.14, 0.52, 0.72]);
      }
    }
  }
}

bumper_pl = front_bumper_plist;
front_chassis_head_frame();
translate(front_bumper_position(bumper_pl)) {
  front_bumper_assembly(bumper_pl, show_bolts=true);
}
