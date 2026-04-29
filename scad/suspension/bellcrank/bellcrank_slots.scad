/**
  * Module: Bellcrank slots on the chassis
  *
  * This module adds two slots to the chassis: one for the bellcrank drive and one for the bellcrank idler.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../steering_params.scad>

use <../../lib/slots.scad>

module bellcrank_slots() {
  tool_access_offset_y = -bellcrank_arm_l
    + bellcrank_arm_bolt_d / 2
    + bellcrank_arm_bolt_edge_offset;

  union() {
    translate([0, -tool_access_offset_y, 0]) {
      four_corner_counterbores(d=front_chassis_bellcrank_tool_access_hole_d,
                               h=front_chassis_thickness,
                               size=[chassis_bellcrank_spacing, 0]);
    }
    four_corner_counterbores(d=front_chassis_bellcrank_bolt_d,
                             h=front_chassis_thickness,
                             bore_d=front_chassis_bellcrank_bolt_bore_d,
                             bore_h=front_chassis_bellcrank_bolt_bore_h,
                             size=[chassis_bellcrank_spacing, 0],
                             reverse=true,
                             center=true);
  }
}

bellcrank_slots();
