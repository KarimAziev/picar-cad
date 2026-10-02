/**
  * Module: Front-to-rear chassis connection geometry checks.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/suspension/front_chassis/computed_params.scad>

use <../../scad/lib/plist.scad>
use <../../scad/suspension/front_chassis/front_chassis_rear_frame.scad>
use <../../scad/suspension/rear_chassis/computed_params.scad>
use <../../scad/suspension/rear_chassis/rear_chassis_frame.scad>

part = "assembly";
extra_width = 0;
spacing = 0;
layout = rear_chassis_layout(min_width=front_chassis_rear_frame_w + extra_width);
w = plist_get("join_w", layout);
edge_y = front_chassis_y_joint_2_end;

module front() {
  front_chassis_rear_frame(debug=false, width=w, color="lightsteelblue");
}

module rear(front_joint=true) {
  translate([0, edge_y - spacing, 0]) {
    rotate([0, 0, 180]) {
      rear_chassis_frame(layout=layout, anchor=[0, 1, 1], color="wheat",
                         front_joint=front_joint);
    }
  }
}

module assembly() {
  front();
  rear();
}

module pin_probes() {
  rail_w = w - (front_chassis_joint_bolt_d + front_chassis_joint_bolt_pad
                + front_chassis_joint_rail_bolt_clearance) * 2;
  pin_z = joint_base_h + (joint_base_h + joint_rail_h) / 2;
  for (x = [-rail_w / 4, rail_w / 4]) {
    translate([x, edge_y + joint_l / 2, pin_z]) {
      rotate([90, 0, 0]) {
        cylinder(d=front_chassis_joint_pin_d * 0.8,
                 h=front_chassis_joint_pin_l - 0.2,
                 center=true, $fn=32);
      }
    }
  }
}

module bolt_probes() {
  edge_x = w / 2 - front_chassis_joint_bolt_pad - front_chassis_joint_bolt_d / 2;
  n = suspension_chassis_joint_wide_bolt_cols;
  for (i = [0:n - 1]) {
    translate([-edge_x + i * 2 * edge_x / (n - 1), edge_y + joint_l / 2, -1]) {
      cylinder(d=front_chassis_joint_bolt_d * 0.8,
               h=chassis_thickness + 2, $fn=32);
    }
  }
}

echo(edge_y=edge_y, joint_l=joint_l, width=w,
     rear_l=plist_get("transition_y_start", layout) - plist_get("min_y", layout));

if (part == "front") {
  front();
} else if (part == "rear") {
  rear();
} else if (part == "rear_flat") {
  rear(front_joint=false);
} else if (part == "collision") {
  intersection() {
    front();
    rear();
  }
} else if (part == "pin_obstruction" || part == "bolt_obstruction") {
  intersection() {
    assembly();
    if (part == "pin_obstruction") {
      pin_probes();
    } else {
      bolt_probes();
    }
  }
} else if (part == "root_land") {
  intersection() {
    rear();
    translate([-0.25, edge_y - 0.25, chassis_thickness - 0.4]) {
      cube([0.5, 0.5, 0.2]);
    }
  }
} else {
  assembly();
}
