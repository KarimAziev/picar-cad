/**
  * Module: Stock chassis pins and wide-joint bolt lands.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/suspension/front_chassis/computed_params.scad>
include <../scad/suspension/rear_chassis/rear_chassis_params.scad>

use <../scad/suspension/front_chassis/front_chassis_joint.scad>

stock = [[23.8, 4], [33, 8], [38, 2], [39.5, 9], [43, 6]];
pins = [front_chassis_head_joint_pin_l,
        front_chassis_joint_pin_l,
        front_chassis_joint_pin_l,
        rear_suspension_joint_pin_l];
for (length = pins) {
  assert(len([for (item = stock) if (item[0] == length) 1]) == 1,
         "Each chassis joint needs an available stock pin length");
}
for (item = stock) {
  assert(2 * len([for (length = pins) if (length == item[0]) 1]) <= item[1],
         "Chassis pin usage exceeds the stock remaining after the front arms");
}
assert((front_chassis_joint_pin_l - joint_l) / 2 >= 10);

for (w = [front_chassis_rear_frame_w, front_chassis_rear_frame_w + 20]) {
  xs = front_chassis_body_joint_bolt_xs(w);
  rail_w = front_chassis_body_joint_rail_w(w);
  pin_x = front_chassis_body_joint_pin_spacing(w) / 2;
  bolt_r = front_chassis_joint_bolt_d / 2;
  edge_x = xs[len(xs) - 1];
  pad = suspension_chassis_joint_wide_bolt_pad;
  assert(w / 2 - edge_x - bolt_r >= pad - 0.000001);
  assert(edge_x - bolt_r - rail_w / 2 - front_chassis_joint_clearance
         >= pad - 0.000001);
  for (x = xs) {
    assert(abs(abs(x) - pin_x) - bolt_r - front_chassis_joint_pin_d / 2
           >= suspension_chassis_joint_wide_pin_bolt_land - 0.000001);
  }
}
echo("PASS available stock pins, engagement, padded side bolts and pin/bolt separation");
