/**
  * Module: Front chassis assembly.
  *
  * Combines the front and rear sections of the front chassis. The sections can
  * be displayed assembled or separated by a spacing for preview
  * and debugging.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>
include <computed_params.scad>

use <front_chassis_front_frame.scad>
use <front_chassis_joint.scad>
use <front_chassis_rear_frame.scad>

module front_chassis(show_front_frame=true,
                     show_rear_frame=true,
                     debug=false,
                     spacing=0) {

  if (show_front_frame) {
    front_chassis_front_frame(debug=debug);
  }
  if (show_rear_frame) {
    translate([0, -spacing, 0]) {
      front_chassis_rear_frame(debug=debug);
    }
  }
}

front_chassis(show_front_frame=true,
              show_rear_frame=true,
              debug=false,
              spacing=joint_l + 5);
