/**
  * Module: Upper steering plate, flat top on the print bed and feet upward.
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <upper_steering_plate.scad>

size = upper_steering_plate_size();
translate([0, size[1], size[2]]) {
  rotate([180, 0, 0]) {
    upper_steering_plate(color=undef);
  }
}
