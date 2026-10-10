/**
  * Module: Separate head and bulkhead sections of the front chassis.
  *
  * The removable head retains the camera ribbon bank and bumper mounts.
  * The bulkhead and bellcrank section carries the matching head socket and
  * the existing rear joint for the steering-servo frame.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../../colors.scad>
include <../../../parameters.scad>
include <../../../rc_params.scad>
include <../computed_params.scad>

use <../../../lib/plist.scad>
use <../front_frame_util.scad>
use <../head_frame/head_joint.scad>

front_chassis_front_frame_debug = true;
show_front_access_slots         = true;

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_suspension_frame
  ─────────────────────────────────────────────────────────────────────────────
  Build the bulkhead and bellcrank frame with a socket for the separate head.
  **Parameters:**
  - `debug`: Show outline labels within this part.
  - `show_access_slots`: Retain the head access-slot configuration in the source outline.
  - `debug_font`: Outline label font.
  - `debug_color`: Outline label color.
  - `color`: Body color; undef inherits the caller's color.
  **Behavior:** Original vehicle coordinates and the rear steering joint stay fixed.
 */
module front_chassis_suspension_frame(debug=front_chassis_front_frame_debug,
                                      show_access_slots=show_front_access_slots,
                                      debug_font="Gill Sans:style=Bold",
                                      debug_color=green_2,
                                      color=white_smoke_1) {
  p = front_chassis_head_joint_params();
  bounds = front_chassis_front_frame_bounds();
  eps = front_chassis_joint_boolean_overlap;
  // Outline labels extend beyond the solid's bounding box.
  clip_pad = debug ? norm(bounds[1] - bounds[0]) : eps;
  difference() {
    intersection() {
      front_chassis_front_frame_unsplit(debug=debug,
                                        show_access_slots=show_access_slots,
                                        debug_font=debug_font,
                                        debug_color=debug_color,
                                        color=color);
      translate(bounds[0] - [clip_pad, clip_pad, clip_pad]) {
        cube([bounds[1][0] - bounds[0][0] + 2 * clip_pad,
              plist_get("root_y", p) - bounds[0][1] + clip_pad,
              chassis_thickness + 2 * clip_pad]);
      }
    }
    front_chassis_head_joint(mode="female", slot_mode=true);
  }
}

front_chassis_suspension_frame();
