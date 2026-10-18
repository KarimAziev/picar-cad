/**
  * Module: Front bumper top plate with its flat top face on the print bed.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../rc_params.scad>

use <common.scad>
use <front_bumper_top_plate.scad>

bumper_pl = front_bumper_plist;
size = front_bumper_size(bumper_pl, "plate");
translate([0, size[1], size[2]]) {
  rotate([180, 0, 0]) {
    front_bumper_top_plate(bumper_pl);
  }
}
