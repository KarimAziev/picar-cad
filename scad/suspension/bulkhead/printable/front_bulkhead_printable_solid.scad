/**
  * Module: The front bulkhead can be printed either as a single part or as two separate parts.
  *
  * This module provides the front bulkhead as a solid part.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../../colors.scad>

use <../front_bulkhead.scad>

module front_bulkhead_printable(color=cobalt_blue_light_1) {
  front_bulkhead(color=color,
                 show_upper_suspension_holder=false,
                 show_shock_tower=false,
                 show_suspension_arm_pad=false,
                 show_front_upper_arm=false,
                 show_upper_arm_ball_stud=false,
                 show_front_upper_arm_pin=false,
                 show_front_upper_pin_e_clip=false);
}

front_bulkhead_printable();