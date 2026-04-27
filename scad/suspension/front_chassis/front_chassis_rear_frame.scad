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

module front_chassis_rear_frame(debug=true,
                                color=white_smoke_1,
                                debug_font=".ADT Slab Soft Numeric:style=Bold") {

  bellcrank_x_start = bellcrank_x + bellcrank_mount_r;
  joint_x = joint_w / 2;
  servo_end_y = -bellcrank_y_distance_from_bulkhead + bellcrank_zone_y_len;
  y_start = -bellcrank_y_distance_from_bulkhead + bellcrank_y_dist;
  y_joint_1_end = -bellcrank_y_distance_from_bulkhead - bellcrank_mount_r;
  y_joint_2_end = servo_end_y - joint_l;

  pts = [[0, y_start],
         [joint_x, y_start],
         [joint_x, y_joint_1_end],
         [bellcrank_x_start, y_joint_1_end],
         [servo_slot_min_w, y_start],
         [servo_slot_min_w, y_joint_2_end],
         [joint_x, y_joint_2_end],
         [joint_x, servo_end_y],
         [0, servo_end_y]];

  union() {
    translate([0, y_joint_1_end, 0]) {
      front_chassis_joint_female(color=color);
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
      translate([0, y_start, 0]) {
        front_chassis_pin_joint_holes(center=true,
                                      direction=1,
                                      use_pad=false,
                                      pad_side="bottom");
      }
      translate([0,
                 -bellcrank_y_distance_from_bulkhead,
                 0]) {
        bellcrank_steering_with_servo_position() {
          steering_servo_chassis_slots(center_y=false,
                                       sink="countersunk");
        }
      }
    }
    translate([0, servo_end_y, 0]) {
      front_chassis_joint_female(color=color);
    }
  }

  if (debug) {
    font_size = min(abs(bellcrank_zone_y_len * 0.065), 5);
    translate([0, 0, front_chassis_thickness + 0.1]) {
      debug_polygon_text(pts,
                         font_size=font_size,
                         color=cobalt_blue_light_2,
                         font=debug_font);
      mirror([1, 0, 0]) {
        debug_polygon_text(pts,
                           rotation=[0, 180, 0],
                           font_size=font_size,
                           color=cobalt_blue_light_2);
      }
    }
  }
}

module front_chassis_rear_frame_printable(debug=false, color=white_smoke_1) {
  front_chassis_rear_frame(debug=$preview ? false : debug, color=color);
}

front_chassis_rear_frame_printable();
