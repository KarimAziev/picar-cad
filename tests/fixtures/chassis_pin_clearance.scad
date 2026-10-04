/**
  * Module: Chassis joint pin and mounting-cutout clearance checks.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/suspension/front_chassis/computed_params.scad>
include <../../scad/suspension/rear_chassis/rear_chassis_params.scad>

use <../../scad/components/plate_joint/plate_joint.scad>
use <../../scad/components/plate_joint/plate_joint_parameters.scad>
use <../../scad/lib/plist.scad>
use <../../scad/lib/slots.scad>
use <../../scad/suspension/bellcrank/bellcrank_slots.scad>
use <../../scad/suspension/bellcrank_steering_slots.scad>
use <../../scad/suspension/bulkhead/front_bulkhead_chassis.scad>
use <../../scad/suspension/front_chassis/front_chassis_access_slots.scad>
use <../../scad/suspension/front_chassis/front_chassis_controls.scad>
use <../../scad/suspension/front_chassis/front_chassis_front_frame.scad>
use <../../scad/suspension/front_chassis/front_chassis_head_joint.scad>
use <../../scad/suspension/front_chassis/front_chassis_head_slots.scad>
use <../../scad/suspension/front_chassis/front_chassis_joint.scad>
use <../../scad/suspension/front_chassis/front_chassis_rear_frame.scad>
use <../../scad/suspension/front_chassis/front_chassis_ribbon_slots.scad>
use <../../scad/suspension/rear_chassis/computed_params.scad>
use <../../scad/suspension/rear_chassis/rear_chassis_frame.scad>
use <../../scad/suspension/rear_chassis/rear_chassis_slots.scad>
use <../../scad/suspension/rear_suspension/rear_suspension_mount.scad>
use <../../scad/suspension/rear_suspension/rear_suspension_slots.scad>
use <../../scad/suspension/steering_servo_bracket/steering_servo_chassis_slots.scad>

joint               = "wide";
part                = "collision";
margin              = 0;
candidate_spacing   = undef;
candidate_length    = undef;
include_joint_bolts = true;
layout              = rear_chassis_layout();
width               = plist_get("join_w", layout);
rear_joint_y        = rear_suspension_joint_y_bounds(layout);
rear_start          = rear_joint_y[1];
rear_end            = rear_joint_y[0];
rear_p = plate_joint_parameters(plate_h=chassis_thickness,
                                bolt_d=chassis_bolt_d,
                                w=plist_get("suspension_w", layout),
                                l=rear_start - rear_end,
                                bolt_n_center=2,
                                include_pin_holes=true,
                                pin_d=front_chassis_joint_pin_d,
                                pin_l=rear_suspension_joint_pin_l,
                                pin_spacing="60%");
head_p              = front_chassis_head_joint_params();
wide_rail           = front_chassis_body_joint_rail_w(width);
pattern             = joint == "head"
                       ? [front_chassis_head_joint_pin_spacing, front_chassis_head_joint_pin_l,
                       plist_get("root_y", head_p), plist_get("pin_z", head_p)]
                       : joint == "compact"
                       ? [joint_rail_w / 2 + joint_recess_w / 2, front_chassis_joint_pin_l,
                       y_front_chassis_rear_frame_joint_1_start - joint_l / 2,
                       joint_base_h + (joint_base_h + joint_rail_h) / 2]
                       : joint == "wide"
                       ? [front_chassis_body_joint_pin_spacing(width), front_chassis_joint_pin_l,
                       front_chassis_y_joint_2_end + joint_l / 2,
                       joint_base_h + (joint_base_h + joint_rail_h) / 2]
                       : [plist_get("pin_spacing", rear_p), rear_suspension_joint_pin_l,
                       (rear_start + rear_end) / 2, plist_get("pin_z", rear_p)];
span                = is_undef(candidate_spacing) ? pattern[0] : candidate_spacing;
length              = is_undef(candidate_length) ? pattern[1] : candidate_length;
echo(pattern=[span, length, pattern[2], pattern[3]],
     width=width,
     rear_joint=[rear_end, rear_start],
     front_joint_l=joint_l);

module pins() {
  d = part == "obstruction" || part == "view" ? 3 : front_chassis_joint_pin_d;
  for (x = [-span / 2, span / 2]) {
    translate([x, pattern[2], pattern[3]]) {
      rotate([90, 0, 0]) {
        cylinder(d=d + 2 * margin,
                 h=length + 2 * margin,
                 center=true,
                 $fn=48);
      }
    }
  }
}

module rear_in_front_coordinates() {
  translate([0, front_chassis_y_joint_2_end, 0]) {
    rotate([0, 0, 180]) {
      translate([0, -plist_get("min_y", layout), 0]) {
        children();
      }
    }
  }
}

module front_cutouts() {
  bumper_y = front_chassis_front_frame_start_y()
             - front_bumper_bolt_d / 2 - front_bumper_bolt_pad_y;
  translate([0, bumper_y, 0]) {
    counterbore(h=chassis_thickness, d=front_bumper_bolt_d);
  }
  for (x = [-1, 1] * front_bumper_bolt_spacing_x / 2) {
    translate([x, bumper_y - front_bumper_center_bolt_y_offset, 0]) {
      counterbore(h=chassis_thickness, d=front_bumper_bolt_d);
    }
  }
  front_bulkhead_housing_slots_non_center_y();
  translate([0, -bellcrank_y_distance_from_bulkhead, 0]) {
    bellcrank_slots();
    bellcrank_steering_with_servo_position() {
      steering_servo_chassis_slots(center_y=false, sink="countersunk");
    }
  }
  translate([0, front_chassis_head_center_y(), 0]) {
    front_chassis_head_slots();
  }
  front_chassis_access_slots(front_chassis_head_center_y());
  front_chassis_rpi(slot_mode=true);
  front_chassis_ribbon_slots();
  translate(front_chassis_wiring_slot_pos() - [0, 0, 0.1]) {
    cylinder(d=front_chassis_wiring_slot_d, h=chassis_thickness + 0.2, $fn=80);
  }
}

module joint_bolts() {
  if (joint == "head") {
    translate([0, plist_get("root_y", head_p), 0]) {
      plate_joint(plate_h=chassis_thickness,
                  bolt_d=front_chassis_joint_bolt_d,
                  w=plist_get("w", head_p),
                  l=plist_get("l", head_p),
                  rail_w=front_chassis_head_joint_rail_w,
                  bolt_n_center=2,
                  include_pin_holes=false,
                  mode="male",
                  slot_mode=true);
    }
  } else if (joint == "compact") {
    translate([0, y_front_chassis_rear_frame_joint_1_start, 0]) {
      front_chassis_joint(mode="male", slot_mode=true, include_pin_holes=false);
    }
  } else if (joint == "wide") {
    xs = front_chassis_body_joint_bolt_xs(width);
    translate([0, front_chassis_y_joint_2_end + joint_l, 0]) {
      front_chassis_joint(mode="male",
                          w=width,
                          rail_w=wide_rail,
                          bolt_xs=xs,
                          include_pin_holes=false,
                          slot_mode=true);
    }
  } else {
    translate([0, rear_start, 0]) {
      plate_joint_bolt_holes(bolt_d=chassis_bolt_d,
                             plate_h=chassis_thickness,
                             l=rear_start - rear_end,
                             bolt_xs=plist_get("bolt_xs", rear_p),
                             no_bore=true);
    }
  }
}

module cutouts() {
  if (include_joint_bolts) {
    joint_bolts();
  }
  if (joint == "rear") {
    rear_chassis_slots(layout=layout);
    rear_suspension_mount_slots(layout=layout);
  } else {
    front_cutouts();
    if (joint == "wide") {
      rear_in_front_coordinates() {
        rear_chassis_slots(layout=layout);
      }
    }
  }
}

module plates() {
  if (joint == "rear") {
    rear_chassis_frame(layout=layout);
    rear_suspension_mount(layout=layout);
  } else if (joint == "head") {
    front_chassis_head_frame();
    front_chassis_front_frame(debug=false);
  } else if (joint == "compact") {
    front_chassis_front_frame(debug=false);
    front_chassis_rear_frame(debug=false);
  } else {
    front_chassis_rear_frame(debug=false);
    rear_in_front_coordinates() {
      rear_chassis_frame(layout=layout);
    }
  }
}

if (part == "collision") {
  intersection() {
    pins();
    cutouts();
  }
} else if (part == "obstruction") {
  intersection() {
    pins();
    plates();
  }
} else if (part == "plates") {
  plates();
} else if (part == "side_lands") {
  xs = front_chassis_body_joint_bolt_xs(width);
  difference() {
    for (x = [xs[0], xs[len(xs) - 1]]) {
      translate([x, front_chassis_y_joint_2_end + joint_l / 2, 3]) {
        difference() {
          cylinder(r=front_chassis_joint_bolt_d / 2
                     + suspension_chassis_joint_wide_bolt_pad - 0.2,
                   h=0.2,
                   $fn=96);
          translate([0, 0, -0.1]) {
            cylinder(d=front_chassis_joint_bolt_d + 0.2, h=0.4, $fn=96);
          }
        }
      }
    }
    front_chassis_rear_frame(debug=false);
  }
} else if (part == "pins") {
  pins();
} else {
  color("orange") {
    pins();
  }
  color("lightgray") {
    intersection() {
      plates();
      translate([-500, -500, 0]) {
        cube([1000, 1000, pattern[3] - 0.25]);
      }
    }
  }
}
