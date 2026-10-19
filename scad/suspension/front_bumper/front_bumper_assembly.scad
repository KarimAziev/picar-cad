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
use <front_bumper_foam.scad>
use <front_bumper_top_plate.scad>

show_foam          = true;
show_top_plate     = false;
show_bolts         = false;
foam_alpha         = 0.4; // [0:0.1:1]
foam_z_offset      = 0; // [-200:1:200]
top_plate_z_offset = 0; // [-200:1:200]

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
  - `show_bolts`: Show screws and nuts when the retainer is visible.
  - `foam_z_offset`: Vertical preview separation of the TPU body.
  - `foam_alpha`: TPU preview opacity, from 0 to 1.
  - `top_plate_z_offset`: Vertical preview separation of the retainer and hardware.
  - `reverse_bolts`: Put screw heads underneath the chassis and nuts on the plate.
    Defaults to the counterbore-driven `front_bumper_reverse_bolts` setting.
  **Behavior:** Use `front_bumper_position(pl)` to place the default anchor
  on the chassis. The bumper follows the head frame's +Y assembly separation.
 */
module front_bumper_assembly(pl=front_bumper_plist,
                             anchor=[1, 1, 1],
                             show_top_plate=show_top_plate,
                             show_foam=show_foam,
                             show_bolts=show_bolts,
                             foam_z_offset=foam_z_offset,
                             foam_alpha=foam_alpha,
                             top_plate_z_offset=top_plate_z_offset,
                             reverse_bolts=front_bumper_reverse_bolts) {
  size = front_bumper_size(pl);
  plate_size = front_bumper_size(pl, "plate");
  with_anchor(size=size, anchor=anchor) {
    if (show_foam) {
      translate([0, 0, foam_z_offset]) {
        color([0.18, 0.20, 0.23], alpha=foam_alpha) {
          front_bumper_foam(pl);
        }
      }
    }
    if (show_top_plate) {
      translate([(size[0] - plate_size[0]) / 2, 0, top_plate_z_offset]) {
        front_bumper_top_plate(pl,
                               show_bolts=show_bolts,
                               reverse_bolts=reverse_bolts,
                               color=[0.14, 0.52, 0.72]);
      }
    }
  }
}

bumper_pl = front_bumper_plist;
front_chassis_head_frame();
translate(front_bumper_position(bumper_pl)) {
  front_bumper_assembly(bumper_pl,
                        show_top_plate=show_top_plate,
                        show_bolts=show_bolts,
                        show_foam=show_foam,
                        foam_z_offset=foam_z_offset,
                        foam_alpha=foam_alpha,
                        top_plate_z_offset=top_plate_z_offset,
                        reverse_bolts=front_bumper_reverse_bolts);
}
