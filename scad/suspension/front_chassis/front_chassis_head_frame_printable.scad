/**
  * Module: Removable head frame with its top face on the print bed.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../rc_params.scad>

use <front_chassis_front_frame.scad>

translate([0, 0, chassis_thickness]) {
  rotate([180, 0, 0]) {
    front_chassis_head_frame(color=undef);
  }
}
