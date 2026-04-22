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
  four_corner_counterbores(d=front_chassis_bellcrank_bolt_d,
                           h=front_chassis_thickness,
                           bore_d=front_chassis_bellcrank_bolt_bore_d,
                           bore_h=front_chassis_bellcrank_bolt_bore_h,
                           size=[chassis_bellcrank_spacing, 0],
                           reverse=true,
                           center=true);
}

bellcrank_slots();
