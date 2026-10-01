/**
  * Module: Rear chassis frame with its joint top faces on the print bed.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../steering_params.scad>

use <rear_chassis_frame.scad>

translate([0, 0, chassis_thickness]) {
  rotate([180, 0, 0]) {
    rear_chassis_frame(anchor=[0, 0, 1], color=undef);
  }
}
