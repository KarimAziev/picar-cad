/**
  * Module: Printable Suspension Arm Pad
  *
  * Creates the pad and center hook that sit in the lower front recess of the
  * bulkhead. The hook captures the suspension-arm hinge pins and helps prevent
  * them from sliding out.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../../colors.scad>

use <../suspension_arm_pad.scad>

module suspension_arm_pad_printable(color=cobalt_blue_light_3,) {
  suspension_arm_pad(debug=false, color=color);
}

suspension_arm_pad_printable();