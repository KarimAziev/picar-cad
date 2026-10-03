/**
  * Module: Front chassis assembly.
  *
  * Combines the head, bulkhead and steering sections of the front chassis. They can
  * be displayed assembled or separated by a spacing for preview
  * and debugging.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../parameters.scad>
include <../../rc_params.scad>
include <computed_params.scad>

use <front_chassis_front_frame.scad>
use <front_chassis_rear_frame.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis
  ─────────────────────────────────────────────────────────────────────────────
  Assemble the three front chassis plates at their original vehicle datums.
  **Parameters:**
  - `show_front_frame`: Show the bulkhead and bellcrank plate.
  - `show_rear_frame`: Show the steering-servo plate.
  - `debug`: Show outline labels.
  - `spacing`: Separate the steering plate toward -Y.
  - `show_access_slots`: Include the head's side and front cable openings.
  - `width`: Steering plate width.
  - `show_head_frame`: Show the head plate; undef follows `show_front_frame`.
  - `head_spacing`: Separate the head plate toward +Y.
 */
module front_chassis(show_front_frame=true,
                     show_rear_frame=true,
                     debug=false,
                     spacing=0,
                     show_access_slots=true,
                     width=front_chassis_rear_frame_w,
                     show_head_frame=undef,
                     head_spacing=0) {

  if (show_front_frame) {
    front_chassis_front_frame(debug=debug, show_access_slots=show_access_slots);
  }
  if (is_undef(show_head_frame) ? show_front_frame : show_head_frame) {
    translate([0, head_spacing, 0]) {
      front_chassis_head_frame(debug=debug,
                               show_access_slots=show_access_slots);
    }
  }
  if (show_rear_frame) {
    translate([0, -spacing, 0]) {
      front_chassis_rear_frame(debug=debug, width=width);
    }
  }
}

front_chassis(show_front_frame=true,
              show_rear_frame=true,
              debug=false,
              spacing=joint_l + 5);
