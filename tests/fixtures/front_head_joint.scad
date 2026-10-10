/**
  * Module: Removable head-frame joint and hardware clearance probes.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/suspension/front_chassis/computed_params.scad>

use <../../scad/lib/plist.scad>
use <../../scad/suspension/bulkhead/front_bulkhead_chassis.scad>
use <../../scad/suspension/front_chassis/front_chassis_access_slots.scad>
use <../../scad/suspension/front_chassis/front_frame_util.scad>
use <../../scad/suspension/front_chassis/head_frame/front_chassis_head_frame.scad>
use <../../scad/suspension/front_chassis/head_frame/head_joint.scad>
use <../../scad/suspension/front_chassis/head_frame/head_slots.scad>
use <../../scad/suspension/front_chassis/suspension_frame/front_chassis_suspension_frame.scad>
use <../../scad/suspension/front_chassis/suspension_frame/front_chassis_suspension_frame_printable.scad>

part    = "assembly";
spacing = 0;
p       = front_chassis_head_joint_params();
head_y  = front_chassis_head_center_y();

module head() {
  translate([0, spacing, 0]) {
    front_chassis_head_frame(color="wheat");
  }
}
module frame() {
  front_chassis_suspension_frame(debug=false, color="lightsteelblue");
}
module assembly() {
  head();
  frame();
}
module hardware_slots() {
  front_bulkhead_housing_slots_non_center_y();
  translate([0, head_y, 0]) {
    front_chassis_head_slots();
  }
  front_chassis_access_slots(head_y);
}

if (part == "head") {
  head();
} else if (part == "frame") {
  frame();
} else if (part == "original") {
  front_chassis_front_frame_unsplit(debug=false);
} else if (part == "collision") {
  intersection() {
    head();
    frame();
  }
} else if (part == "pins") {
  front_chassis_head_joint_pins();
} else if (part == "pin_keepout") {
  intersection() {
    front_chassis_head_joint_pins(extra=1);
    hardware_slots();
  }
} else if (part == "pin_obstruction") {
  intersection() {
    assembly();
    front_chassis_head_joint_pins(extra=-0.1);
  }
} else if (part == "bolt_obstruction") {
  intersection() {
    assembly();
    for (side = [-1, 1]) {
      translate([side * (plist_get("w", p) + front_chassis_head_joint_rail_w) / 4,
                 plist_get("root_y", p) - plist_get("l", p) / 2,
                 -1]) {
        cylinder(d=front_chassis_joint_bolt_d * 0.8,
                 h=chassis_thickness + 2,
                 $fn=32);
      }
    }
  }
} else if (part == "transition_void") {
  difference() {
    start_y = max(plist_get("tab_end_y", p), front_chassis_mount_end_y) + 0.1;
    end_y = head_y - front_chassis_head_mount_size()[1] / 2
            + front_chassis_head_wire_land;
    translate([-10, start_y, 0]) {
      cube([20, end_y - start_y, chassis_thickness]);
    }
    head();
  }
} else if (part == "head_printable") {
  translate([0, 0, chassis_thickness]) {
    rotate([180, 0, 0]) {
      head();
    }
  }
} else if (part == "frame_printable") {
  front_chassis_suspension_frame_printable(debug=false);
} else {
  assembly();
}
