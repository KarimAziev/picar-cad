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
use <../../lib/slider.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../placeholders/dservo.scad>
use <../bellcrank/bellcrank_slots.scad>
use <../bellcrank_steering_slots.scad>
use <../bulkhead/front_bulkhead.scad>
use <../bulkhead/front_bulkhead_chassis.scad>
use <../bulkhead/front_bulkhead_housing.scad>
use <../wishbone_arms/lower_arm.scad>
use <front_chassis_joint.scad>

module front_chassis_front_frame(debug=false, color=white_smoke_1) {
  extra_l = front_bulkhead_pad_distance_to_hinge();

  start_y1 = bulkhead_size_y
    + bulkhead_transition_len
    + extra_l
    + front_bumper_bolt_y_offset
    + front_bumper_center_bolt_y_offset
    + front_bumper_bolt_d;

  start_y2 = start_y1 - front_bumper_center_bolt_y_offset;

  pts = [[0, start_y1],
         [bulkhead_size_x / 2, start_y2],
         [bulkhead_size_x / 2, bulkhead_transition_len],
         [bellcrank_x,
          -bellcrank_y_distance_from_bulkhead + bellcrank_mount_r],
         [bellcrank_x + bellcrank_mount_r,
          -bellcrank_y_distance_from_bulkhead],
         [bellcrank_x + bellcrank_mount_r,
          -bellcrank_y_distance_from_bulkhead - bellcrank_mount_r],
         [0,
          -bellcrank_y_distance_from_bulkhead - bellcrank_mount_r]];

  union() {
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
      // bumper
      translate([0,
                 start_y1
                 - front_bumper_bolt_d / 2
                 - front_bumper_bolt_pad_y,
                 0]) {
        counterbore(h=front_chassis_thickness,
                    d=front_bumper_bolt_d);
      }
      translate([0,
                 start_y2
                 - front_bumper_bolt_d / 2
                 - front_bumper_bolt_pad_y,
                 0]) {

        translate([0, 0, 0]) {
          four_corner_counterbores(size=[bulkhead_size_x
                                         - front_bumper_bolt_d
                                         - front_bumper_bolt_pad_x * 2, 0],
                                   center=true,
                                   d=front_bumper_bolt_d,
                                   h=front_chassis_thickness);
        }
      }
    }

    translate([0, -bellcrank_y_distance_from_bulkhead - bellcrank_mount_r, 0]) {
      front_chassis_frame_joint(color=color);
    }
  }

  if (debug) {
    translate([0, 0, front_chassis_thickness + 0.1]) {
      debug_polygon_text(pts, font_size=4);
      mirror([1, 0, 0]) {
        debug_polygon_text(pts, rotation=[0, 180, 0], font_size=4);
      }
    }
  }
}

front_chassis_front_frame();