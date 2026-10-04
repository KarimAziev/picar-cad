/**
  * Module: Upper steering bridge interface and interference probes.
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/rc_params.scad>

use <../../scad/suspension/bellcrank_steering_assembly.scad>
use <../../scad/suspension/front_suspension_assembly.scad>
use <../../scad/suspension/upper_steering_plate.scad>

part           = "plate";
arm_angle      = 0;
steering_angle = 0;
plate_anchor   = [1, 1, 1];

if (part == "plate") {
  upper_steering_plate(anchor=plate_anchor);
} else if (part == "slots") {
  intersection() {
    upper_steering_plate(anchor=plate_anchor);
    upper_steering_plate(anchor=plate_anchor, slot_mode=true);
  }
} else if (part == "collision") {
  intersection() {
    upper_steering_plate_position() {
      upper_steering_plate();
    }
    union() {
      translate([0, bellcrank_y_distance_from_bulkhead, 0]) {
        front_suspension_assembly(solve_linkage=true,
                                  lower_arm_angle=arm_angle,
                                  bellcrank_angle=steering_angle);
      }
      bellcrank_steering_assembly(steering_servo_angle=steering_angle);
    }
  }
} else if (part == "mount_bores") {
  // Independent mounting coordinates from the existing hardware layout.
  intersection() {
    upper_steering_plate_position() {
      upper_steering_plate();
    }
    union() {
      for (side = [-1, 1]) {
        translate([side * chassis_bellcrank_spacing / 2, 0, 0]) {
          cylinder(d=upper_steering_panel_bolt_d - 0.05, h=50, $fn=40);
        }
      }
      for (side = [-1, 0, 1]) {
        translate([side * upper_steering_panel_bulkhead_spacing / 2,
                   bellcrank_y_distance_from_bulkhead,
                   0]) {
          cylinder(d=upper_steering_panel_bolt_d - 0.05, h=50, $fn=40);
        }
      }
    }
  }
}
