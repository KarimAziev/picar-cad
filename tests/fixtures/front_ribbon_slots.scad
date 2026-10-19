/**
  * Module: Front camera ribbon opening and material-clearance probes.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/suspension/front_chassis/computed_params.scad>

use <../../scad/suspension/bellcrank_steering_slots.scad>
use <../../scad/suspension/front_chassis/front_chassis_access_slots.scad>
use <../../scad/suspension/front_chassis/head_frame/head_slots.scad>
use <../../scad/lib/shapes3d.scad>
use <../../scad/suspension/front_chassis/rear_frame/front_chassis_rear_frame.scad>
use <../../scad/suspension/front_chassis/rear_frame/front_chassis_ribbon_slots.scad>
use <../../scad/suspension/steering_servo_bracket/steering_servo_bracket_assembly.scad>

part  = "frame";
poses = front_chassis_ribbon_slot_poses();
w     = front_chassis_ribbon_slot_w;
l     = front_chassis_ribbon_slot_l;

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

if (part == "servo" || part == "wiring_servo") {
  intersection() {
    union() {
      if (part == "servo") {
        for (p = poses) {
          slot_prism(p, pad=1.5);
        }
      }
      translate([0, 0, 0.05]) {
        front_chassis_wiring_slot(thickness=chassis_thickness - 0.1, pad=1.5);
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

if (part == "wiring_land") {
  difference() {
    translate([0, 0, 0.05]) {
      front_chassis_wiring_slot(thickness=chassis_thickness - 0.1, pad=1.5);
    }
    front_chassis_rear_frame(debug=false, show_wiring_slot=false);
  }
} else if (part == "wiring") {
  difference() {
    front_chassis_rear_frame(debug=false, show_wiring_slot=false);
    front_chassis_rear_frame(debug=false);
  }
}

if (part == "camera_frame" || part == "camera_baseline") {
  front_chassis_rear_frame(show_ribbon_slots=false,
                           show_camera_slot=part == "camera_frame");
} else if (part == "camera_removed") {
  difference() {
    front_chassis_rear_frame(show_ribbon_slots=false, show_camera_slot=false);
    front_chassis_rear_frame(show_ribbon_slots=false, show_camera_slot=true);
  }
} else if (part == "camera_land") {
  difference() {
    translate(front_chassis_rear_camera_slot_pos()
               - [front_chassis_head_pan_servo_top_ribbon_cutout_len / 2 + 2,
                  front_chassis_head_pan_servo_top_ribbon_cutout_h / 2 + 2,
                  -0.05]) {
      cube([front_chassis_head_pan_servo_top_ribbon_cutout_len + 4,
            front_chassis_head_pan_servo_top_ribbon_cutout_h + 4,
            chassis_thickness - 0.1]);
    }
    front_chassis_rear_frame(show_ribbon_slots=false, show_camera_slot=false);
    translate(front_chassis_rear_camera_slot_pos()) {
      front_chassis_camera_ribbon_slot(anchor=[0, 0, 1]);
    }
  }
}

if (part == "servo_cables") {
  difference() {
    front_chassis_rear_frame(show_servo_cable_slots=false);
    front_chassis_rear_frame(show_servo_cable_slots=true);
  }
} else if (part == "servo_cable_land") {
  difference() {
    for (pos = front_chassis_rear_servo_cable_positions()) {
      translate(pos + [0, 0, 0.05]) {
        cuboid([head_servo_cable_slot_size[0] + 2,
                head_servo_cable_slot_size[1] + 2, chassis_thickness - 0.1],
               anchor=[0, 0, 1]);
      }
    }
    front_chassis_rear_frame(show_servo_cable_slots=false);
  }
}
