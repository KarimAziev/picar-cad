/**
  * Module: Front camera ribbon opening and material-clearance probes.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/suspension/front_chassis/computed_params.scad>

use <../../scad/suspension/front_chassis/front_chassis_rear_frame.scad>
use <../../scad/suspension/front_chassis/front_chassis_ribbon_slots.scad>
use <../../scad/suspension/bellcrank_steering_slots.scad>
use <../../scad/suspension/steering_servo_bracket/steering_servo_bracket_assembly.scad>

part = "frame";
poses = front_chassis_ribbon_slot_poses();
w = front_chassis_head_ribbon_slot_w;
l = front_chassis_head_ribbon_slot_l;

module slot_prism(p, pad=0) {
  translate([p[0], p[1], 0.05]) {
    rotate([0, 0, p[2]]) {
      translate([-w / 2 - pad, -l / 2 - pad, 0]) {
        cube([w + pad * 2, l + pad * 2, chassis_thickness - 0.1]);
      }
    }
  }
}

if (part == "frame" || part == "baseline") {
  front_chassis_rear_frame(debug=false, show_ribbon_slots=part == "frame");
} else if (part == "slots") {
  intersection() {
    front_chassis_ribbon_slots();
    front_chassis_rear_frame(debug=false, show_ribbon_slots=false);
  }
} else if (part == "land") {
  difference() {
    union() {
      for (p = poses) {
        slot_prism(p, pad=1.5);
      }
    }
    front_chassis_rear_frame(debug=false, show_ribbon_slots=false);
  }
} else if (part == "separation") {
  for (i = [0:len(poses) - 2], j = [i + 1:len(poses) - 1]) {
    intersection() {
      slot_prism(poses[i], pad=front_chassis_ribbon_land / 2);
      slot_prism(poses[j], pad=front_chassis_ribbon_land / 2);
    }
  }
}

if (part == "servo") {
  intersection() {
    union() {
      for (p = poses) {
        slot_prism(p, pad=1.5);
      }
    }
    linear_extrude(height=chassis_thickness) {
      projection(cut=false) {
        translate([0, -bellcrank_y_distance_from_bulkhead, chassis_thickness]) {
          bellcrank_steering_with_servo_position() {
            steering_servo_bracket_assembly();
          }
        }
      }
    }
  }
}
