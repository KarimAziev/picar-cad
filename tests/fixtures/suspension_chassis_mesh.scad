// Current chassis solids and interfaces for independent mesh checks.
include <../../scad/parameters.scad>
include <../../scad/rc_params.scad>
include <../../scad/suspension/front_chassis/computed_params.scad>

use <../../scad/lib/shapes3d.scad>
use <../../scad/suspension/front_chassis/front_chassis.scad>
use <../../scad/suspension/front_chassis/suspension_frame/front_chassis_suspension_frame.scad>
use <../../scad/suspension/front_chassis/front_chassis_joint.scad>
use <../../scad/suspension/front_chassis/rear_frame/front_chassis_rear_frame.scad>

part          = "front";
wide          = true;
front_spacing = 0;

module male() {
  front_chassis_joint_male(w=wide ? chassis_joint_wide_w : joint_w,
                           rail_w=wide ? chassis_joint_wide_rail_w : joint_rail_w,
                           bolt_xs=wide ? chassis_joint_wide_bolt_xs : front_chassis_joint_default_bolt_xs(),
                           pin_spacing=wide ? chassis_joint_wide_pin_spacing : undef);
}

module female() {
  front_chassis_joint_female(w=wide ? chassis_joint_wide_w : joint_w,
                             rail_w=wide ? chassis_joint_wide_rail_w : joint_rail_w,
                             bolt_xs=wide ? chassis_joint_wide_bolt_xs : front_chassis_joint_default_bolt_xs(),
                             pin_spacing=wide ? chassis_joint_wide_pin_spacing : undef,
                             include_pin_holes=true);
}

if (part == "front") {
  front_chassis_suspension_frame(debug=false);
}
if (part == "rear") {
  front_chassis_rear_frame(debug=false);
}
if (part == "male") {
  male();
}
if (part == "female") {
  female();
}
if (part == "joint_collision") {
  intersection() {
    male();
    female();
  }
}
if (part == "front_collision") {
  intersection() {
    front_chassis_suspension_frame(debug=false);
    front_chassis_rear_frame(debug=false);
  }
}
if (part == "placed_rear") {
  front_chassis(show_front_frame=false,
                show_head_frame=false,
                show_rear_frame=true,
                debug=false,
                spacing=front_spacing);
}
if (part == "corners") {
  for (i = [0:3]) {
    translate([i * 30, 0, 0]) {
      cuboid([20, 20, 4],
             r=4,
             side=["top_left", "top_right",
                   "bottom_left", "bottom_right"][i]);
    }
  }
}
