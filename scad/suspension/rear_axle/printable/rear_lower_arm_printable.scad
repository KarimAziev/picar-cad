/**
  * Module: Printable rear lower suspension arm.
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../arm_hub_params.scad>

use <../rear_lower_arm.scad>

rear_lower_arm(pl=rear_lower_arm_spec,
               anchor=[1, 1, 1],
               slot_mode=false,
               show_pins=false,
               show_ball_studs=false);
