/**
  * Module: Chassis joint counterbores and printed male interface probes.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/suspension/front_chassis/computed_params.scad>
include <../../scad/suspension/rear_chassis/rear_chassis_params.scad>

use <../../scad/components/plate_joint/plate_joint.scad>
use <../../scad/lib/plist.scad>
use <../../scad/suspension/front_chassis/front_chassis_joint.scad>
use <../../scad/suspension/front_chassis/front_chassis_head_joint.scad>
use <../../scad/suspension/rear_suspension/rear_suspension_joint.scad>

part = "male";
joint = "wide";

module half(mode) {
  if (joint == "wide") {
    front_chassis_body_joint(mode=mode, w=160.4);
  } else if (joint == "compact") {
    front_chassis_joint(mode=mode, countersink_fallback=mode == "female");
  } else if (joint == "head") {
    translate([0, -plist_get("root_y", front_chassis_head_joint_params()), 0]) {
      front_chassis_head_joint(mode=mode);
    }
  } else {
    rear_suspension_chassis_joint(mode=mode);
  }
}

// These dimensions describe the printed rear frame's two male interfaces.
module printed_male() {
  wide = joint == "wide";
  difference() {
    plate_joint(plate_h=6, bolt_d=wide ? 3 : 3.2,
                w=wide ? 160.4 : 45.5,
                l=wide ? 14.03939124 : 10,
                rail_w=wide ? 141.6 : 29.5,
                rail_h=3, base_h=1.5, clearance=0.4, axial_clearance=0.4,
                bolt_n_center=wide ? 0 : 2,
                bolt_spacing_center=37.5,
                pin_d=3.1, pin_l=40, pin_spacing=wide ? 80 : 17.7,
                include_pin_holes=true, pin_use_pad=false,
                mode="male", root_side=wide ? 1 : -1);
    if (wide) {
      plate_joint_bolt_holes(bolt_d=3, plate_h=6, l=14.03939124,
                             bolt_xs=[-75.7, -45.05, 0, 45.05, 75.7]);
    }
  }
}

if (part == "male") {
  half("male");
} else if (part == "female") {
  half("female");
} else if (part == "printed") {
  printed_male();
} else if (part == "printed_collision") {
  intersection() {
    printed_male();
    half("female");
  }
} else if (part == "printed_difference") {
  difference() {
    printed_male();
    half("male");
  }
  difference() {
    half("male");
    printed_male();
  }
} else if (part == "collision") {
  intersection() {
    half("male");
    half("female");
  }
} else {
  color("lightsteelblue") {
    half("female");
  }
  translate([0, 18, 0]) {
    color("wheat") {
      half("male");
    }
  }
}
