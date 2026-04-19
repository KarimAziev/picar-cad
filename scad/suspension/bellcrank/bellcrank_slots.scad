include <../../steering_params.scad>

use <../../lib/slots.scad>

module bellcrank_slots() {
  four_corner_counterbores(d=upper_chassis_bellcrank_bolt_d,
                           h=upper_chassis_t,
                           bore_d=upper_chassis_bellcrank_bolt_bore_d,
                           bore_h=upper_chassis_bellcrank_bolt_bore_h,
                           size=[chassis_bellcrank_spacing, 0],
                           reverse=true,
                           center=true);
}

bellcrank_slots();
