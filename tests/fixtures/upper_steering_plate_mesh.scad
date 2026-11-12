/**
  * Module: Upper steering bridge interface and interference probes.
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/rc_params.scad>

use <../../scad/suspension/bellcrank_steering_assembly.scad>
use <../../scad/suspension/bulkhead/front_bulkhead.scad>
use <../../scad/suspension/bulkhead/front_upper_suspension_holder.scad>
use <../../scad/suspension/front_suspension_assembly.scad>
use <../../scad/suspension/upper_steering_plate.scad>

part           = "plate";
arm_angle      = 0;
steering_angle = 0;
plate_anchor   = [1, 1, 1];

// Holder placement follows the bulkhead and front-suspension assembly transforms.
module holder_position() {
  translate([0,
             bellcrank_y_distance_from_bulkhead
             - front_upper_suspension_holder_pin_barrel_h - front_bulkhead_extra_len,
             front_bulkhead_housing_h + front_bulkhead_shock_tower_mount_offset
             + front_shock_tower_pin_y_offset + front_upper_arm_hinge_barrel_hole_d / 2]) {
    rotate([90, 0, 180]) {
      children();
    }
  }
}

if (part == "holder") {
  front_upper_suspension_holder();
} else if (part == "holder_slots") {
  intersection() {
    front_upper_suspension_holder();
    front_upper_suspension_holder_steering_slots();
  }
} else if (part == "bulkhead_contact") {
  intersection() {
    translate([0, 0, -0.1]) {
      upper_steering_plate_position() {
        upper_steering_plate();
      }
    }
    translate([0,
               bellcrank_y_distance_from_bulkhead + front_bulkhead_len / 2,
               front_bulkhead_housing_h]) {
      front_bulkhead();
    }
    // Inset annular probes avoid coincident bore and boss surfaces.
    for (p = [upper_steering_plate_mounts()[2], upper_steering_plate_mounts()[3]]) {
      translate(p - [0, 0, 0.2]) {
        difference() {
          cylinder(d=upper_steering_panel_boss_od - 0.1, h=0.3, $fn=120);
          translate([0, 0, -0.01]) {
            cylinder(d=max(upper_steering_panel_bolt_d,
                           upper_steering_panel_bulkhead_bore_d) + 0.1,
                     h=0.32,
                     $fn=120);
          }
        }
      }
    }
  }
} else if (part == "holder_contact") {
  intersection() {
    translate([0, 0, -0.1]) {
      upper_steering_plate_position() {
        upper_steering_plate();
      }
    }
    holder_position() {
      front_upper_suspension_holder();
    }
    // Inset the bearing probe from shared outer and bore surfaces.
    holder_position() {
      for (p = front_upper_suspension_holder_steering_mounts()) {
        translate(p + [0, 0.01, 0]) {
          rotate([90, 0, 0]) {
            difference() {
              cylinder(d=front_upper_suspension_holder_steering_bolt_d
                         + 2 * front_upper_suspension_holder_steering_mount_pad - 0.1,
                       h=0.2,
                       $fn=120);
              translate([0, 0, -0.01]) {
                cylinder(d=front_upper_suspension_holder_steering_bolt_d + 0.1,
                         h=0.22,
                         $fn=120);
              }
            }
          }
        }
      }
    }
  }
} else if (part == "plate") {
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
    union() {
      upper_steering_plate_position() {
        upper_steering_plate();
      }
      holder_position() {
        front_upper_suspension_holder();
      }
    }
    union() {
      // Probe both holder bores through the plate and the holder itself.
      for (side = [-1, 1]) {
        translate([side * front_upper_suspension_holder_steering_bolt_spacing / 2,
                   bellcrank_y_distance_from_bulkhead
                   - front_upper_suspension_holder_pin_barrel_h
                   - front_bulkhead_extra_len
                   - front_upper_suspension_holder_steering_mount_pad
                   - front_upper_suspension_holder_steering_bolt_d / 2,
                   0]) {
          cylinder(d=front_upper_suspension_holder_steering_bolt_d - 0.05,
                   h=50,
                   $fn=40);
        }
      }
      for (side = [-1, 1]) {
        translate([side * chassis_bellcrank_spacing / 2, 0, 0]) {
          cylinder(d=upper_steering_panel_bolt_d - 0.05, h=50, $fn=40);
        }
      }
      for (side = [-1, 1]) {
        translate([side * upper_steering_panel_bulkhead_spacing / 2,
                   bellcrank_y_distance_from_bulkhead - front_bulkhead_extra_len
                   - front_upper_suspension_holder_pin_barrel_h
                   + front_upper_suspension_holder_thickness
                   + upper_steering_panel_bolt_d / 2
                   + upper_steering_panel_bulkhead_edge_distance,
                   0]) {
          cylinder(d=upper_steering_panel_bolt_d - 0.05, h=50, $fn=40);
        }
      }
    }
  }
}
