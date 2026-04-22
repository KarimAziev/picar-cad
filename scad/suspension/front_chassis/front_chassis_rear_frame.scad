/**
  * Module: The rear-mountable part of the front chassis that holds the steering servo.
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
use <../../lib/slider.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../placeholders/dservo.scad>
use <../bellcrank/bellcrank_slots.scad>
use <../bellcrank_steering_slots.scad>
use <../bulkhead/front_bulkhead.scad>
use <../bulkhead/front_bulkhead_chassis.scad>
use <../bulkhead/front_bulkhead_housing.scad>
use <../steering_servo_bracket/steering_servo_chassis_slots.scad>
use <../wishbone_arms/lower_arm.scad>
use <front_chassis_joint.scad>

module front_chassis_rear_frame(debug=false,
                                color=white_smoke_1) {

  bellcrank_x_start = bellcrank_x + bellcrank_mount_r;
  joint_x = joint_w / 2;

  servo_end_y = -bellcrank_y_distance_from_bulkhead + bellcrank_zone_y_len;

  pts = [[0, -bellcrank_y_distance_from_bulkhead + bellcrank_y_dist],
         [joint_x,
          -bellcrank_y_distance_from_bulkhead + bellcrank_y_dist],
         [joint_x,
          -bellcrank_y_distance_from_bulkhead - bellcrank_mount_r],
         [bellcrank_x_start,
          -bellcrank_y_distance_from_bulkhead - bellcrank_mount_r],
         [servo_slot_min_w,
          -bellcrank_y_distance_from_bulkhead + bellcrank_y_dist],
         [servo_slot_min_w,
          servo_end_y - joint_l],
         [joint_x, servo_end_y - joint_l],
         [joint_x, servo_end_y],
         [0, servo_end_y]];

  union() {
    translate([0, -bellcrank_y_distance_from_bulkhead - bellcrank_mount_r, 0]) {
      front_chassis_joint_slot(color=color);
    }
    difference() {
      maybe_color(color) {
        linear_extrude(height=front_chassis_thickness,
                       center=false,
                       convexity=2) {
          mirror_copy([1, 0, 0]) {
            polygon(pts);
          }
        }
      }
      front_bulk_head_housing_slots_non_center_y();
      translate([0,
                 -bellcrank_y_distance_from_bulkhead,
                 0]) {
        bellcrank_steering_slots();
      }
    }
    translate([0,
               servo_end_y,
               0]) {
      front_chassis_joint_slot(color=color);
    }
  }

  if (debug) {
    translate([0, 0, front_chassis_thickness + 0.1]) {
      debug_polygon_text(pts);
      mirror_copy([1, 0, 0]) {
        debug_polygon_text(pts, rotation=[0, 180, 0]);
      }
    }
  }
}

front_chassis_rear_frame();