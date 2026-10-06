/**
  * Module: Lowered chassis mounting surfaces and hardware clearance probes.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/suspension/front_chassis/computed_params.scad>

use <../../scad/suspension/bellcrank_steering_assembly.scad>
use <../../scad/suspension/front_chassis/front_chassis_mount_recesses.scad>
use <../../scad/suspension/front_chassis/head_frame/front_chassis_head_frame.scad>
use <../../scad/suspension/front_chassis/head_frame/head_joint.scad>
use <../../scad/suspension/front_chassis/rear_frame/front_chassis_rear_frame.scad>
use <../../scad/suspension/front_chassis/suspension_frame/front_chassis_suspension_frame.scad>
use <../../scad/suspension/front_chassis/suspension_frame/front_chassis_suspension_frame_printable.scad>
use <../../scad/suspension/front_suspension_assembly.scad>
use <../../scad/suspension/rear_chassis/computed_params.scad>
use <../../scad/suspension/rear_chassis/rear_chassis_frame.scad>
use <../../scad/suspension/rear_suspension/rear_suspension_mount.scad>

part           = "front";
arm_angle      = 0;
steering_angle = 0;
module front_plates() {
  front_chassis_suspension_frame(debug=false);
  front_chassis_head_frame();
  front_chassis_rear_frame(debug=false);
}
module front_hardware() {
  translate([0, 0, suspension_chassis_mount_h]) {
    front_suspension_assembly(solve_linkage=true,
                              lower_arm_angle=arm_angle,
                              bellcrank_angle=steering_angle);
    translate([0, -bellcrank_y_distance_from_bulkhead, 0]) {
      bellcrank_steering_assembly(steering_servo_angle=steering_angle,
                                  show_steering_servo_chassis_bolt=false,
                                  show_steering_servo_chassis_bolt_nut=false,
                                  show_steering_servo_bracket_bolt=false,
                                  show_steering_servo_bracket_bolt_nut=false);
    }
  }
}
if (part == "front") {
  front_chassis_suspension_frame(debug=false);
}
if (part == "head") {
  front_chassis_head_frame();
}
if (part == "servo") {
  front_chassis_rear_frame(debug=false);
}
if (part == "rear_mount") {
  rear_suspension_mount();
}
if (part == "rear_frame") {
  rear_chassis_frame();
}
if (part == "front_collision") {
  intersection() {
    front_plates();
    front_hardware();
  }
}
if (part == "rear_collision") {
  intersection() {
    rear_suspension_mount();
    rear_chassis_frame();
  }
}
if (part == "view") {
  front_plates();
  front_hardware();
}
if (part == "plates_view") {
  front_plates();
}
if (part == "front_printable") {
  front_chassis_suspension_frame_printable(debug=false);
}
if (part == "front_first_layer") {
  intersection() {
    front_chassis_suspension_frame_printable(debug=false);
    translate([-200, -200, 0]) {
      cube([400, 400, 0.2]);
    }
  }
}
if (part == "rear_view") {
  rear_suspension_mount();
  rear_chassis_frame();
}
