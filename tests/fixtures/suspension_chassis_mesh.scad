// Geometry fixtures for independent mesh and interface inspection.
include <../../scad/parameters.scad>
include <../../scad/steering_params.scad>
include <../../scad/suspension/front_chassis/computed_params.scad>
include <../../scad/suspension/middle_chassis/computed_params.scad>

use <../../scad/suspension/front_chassis/front_chassis_front_frame.scad>
use <../../scad/suspension/front_chassis/front_chassis_rear_frame.scad>
use <../../scad/suspension/front_chassis/front_chassis_joint.scad>
use <../../scad/suspension/middle_chassis/middle_chassis.scad>
use <../../scad/suspension/front_chassis/front_chassis_assembly.scad>
use <../../scad/lib/shapes3d.scad>
use <../../scad/head/head_neck.scad>

part = "middle";
wide = true;
front_spacing = 0;
middle_spacing = 0;

module male() {
  front_chassis_joint_male(
    w=wide ? chassis_joint_wide_w : joint_w,
    rail_w=wide ? chassis_joint_wide_rail_w : joint_rail_w,
    bolt_xs=wide ? chassis_joint_wide_bolt_xs : front_chassis_joint_default_bolt_xs(),
    pin_spacing=wide ? chassis_joint_wide_pin_spacing : undef);
}

module female() {
  front_chassis_joint_female(
    w=wide ? chassis_joint_wide_w : joint_w,
    rail_w=wide ? chassis_joint_wide_rail_w : joint_rail_w,
    bolt_xs=wide ? chassis_joint_wide_bolt_xs : front_chassis_joint_default_bolt_xs(),
    pin_spacing=wide ? chassis_joint_wide_pin_spacing : undef,
    include_pin_holes=true);
}

module placed_middle() {
  translate([0, -bellcrank_y_distance_from_bulkhead + bellcrank_zone_y_len, 0]) {
    middle_chassis(anchor=[0, -1, 1]);
  }
}

if (part == "middle") middle_chassis();
if (part == "head") head_neck(center_pan_servo_slot=true, pan_servo_rotation=0);
if (part == "printable") middle_chassis_printable();
if (part == "first_layer") intersection() {
  middle_chassis_printable();
  cuboid([middle_chassis_size()[0], middle_chassis_size()[1], 0.2]);
}
if (part == "front") front_chassis_front_frame(debug=false);
if (part == "rear") front_chassis_rear_frame(debug=false);
if (part == "male") male();
if (part == "female") female();
if (part == "joint_collision") intersection() { male(); female(); }
if (part == "front_collision") intersection() {
  front_chassis_front_frame(debug=false);
  front_chassis_rear_frame(debug=false);
}
if (part == "middle_collision") intersection() {
  front_chassis_rear_frame(debug=false);
  placed_middle();
}

if (part == "placed_middle") {
  front_chassis_assembly(show_chassis_front_frame=false,
                         show_chassis_rear_frame=false,
                         show_front_chassis_components=false,
                         show_head=false,
                         show_middle_chassis_components=false,
                         show_rear_chassis=false,
                         show_rear_motor_carrier=false,
                         show_rear_motor=false,
                         show_rear_gearbox=false,
                         show_rear_driveshaft=false,
                         show_rear_dogbone=false,
                         show_rear_unused_shaft=false,
                         front_chassis_joint_spacing=front_spacing,
                         middle_chassis_joint_spacing=middle_spacing);
}

if (part == "corners") {
  for (i = [0:3]) {
    translate([i * 30, 0, 0]) {
      cuboid([20, 20, 4], r=4,
             side=["top_left", "top_right", "bottom_left", "bottom_right"][i]);
    }
  }
}

echo(middle_size=middle_chassis_size(), joint_l=joint_l,
     head_y=front_chassis_head_center_y());
