/**
  * Module: The front section of the front chassis
  *
  * It contains slots for the front bulkhead and bellcrank. The rear section of
  * the front chassis, which includes the steering servo slot, is connected to
  * this frame with dedicated dovetail joints and bolts.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>
include <computed_params.scad>

use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/placement.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slider.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../placeholders/dservo.scad>
use <../bellcrank/bellcrank_slots.scad>
use <../bellcrank_steering_slots.scad>
use <../bulkhead/front_bulkhead.scad>
use <../bulkhead/front_bulkhead_chassis.scad>
use <../bulkhead/front_bulkhead_housing.scad>
use <../wishbone_arms/front_lower_arm.scad>
use <front_chassis_front_frame.scad>
use <front_chassis_joint.scad>
use <front_chassis_rear_frame.scad>

module front_chassis_front_frame_probe(color=white_smoke_1,
                                       probe_len=2) {
  x = ((bellcrank_x + bellcrank_mount_r) * 2) + 0.2;
  y1_end = (bulkhead_transition_len - front_lower_arm_lower_hinge_barrel_h);

  start_y1 = front_chassis_front_frame_start_y() + y1_end;

  y_end = -bellcrank_y_distance_from_bulkhead - bellcrank_mount_r;
  l = abs(y_end) + start_y1 + 1;
  pin_hole_depth  = ((front_chassis_joint_pin_l - joint_l) / 2);

  difference() {
    front_chassis_front_frame(debug=false, color=color);
    translate([0, y_end + pin_hole_depth + probe_len, -0.5]) {
      cube_center_x([x, l, front_chassis_thickness + 1]);
    }
  }
}

module front_chassis_rear_frame_probe(debug=false, probe_len=2) {
  pin_hole_depth  = ((front_chassis_joint_pin_l - joint_l) / 2);
  servo_end_y = -bellcrank_y_distance_from_bulkhead + bellcrank_zone_y_len;
  y_start = -bellcrank_y_distance_from_bulkhead + bellcrank_y_dist;

  cube_len = abs(servo_end_y - y_start - joint_l);

  difference() {
    front_chassis_rear_frame(debug=debug);
    translate([0,
               y_start - cube_len - pin_hole_depth - probe_len + cube_len / 2,
               front_chassis_thickness / 2]) {
      cube([servo_slot_min_w * 2 + 1, cube_len, front_chassis_thickness + 1],
           center=true);
    }
  }
}

module front_chassis_joint_probe(probe_len=2, spacing=2) {
  front_chassis_front_frame_probe(probe_len=probe_len);
  translate([0, -joint_l - spacing, 0]) {
    front_chassis_rear_frame_probe(probe_len=probe_len);
  }
}

front_chassis_joint_probe();