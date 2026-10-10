/**
  * Module: Steering encoder bracket and chassis interface fixtures.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/suspension/front_chassis/computed_params.scad>

use <../../scad/components/encoder_l_bracket.scad>
use <../../scad/components/servo_encoder_bracket/steering_servo_encoder_bracket.scad>
use <../../scad/placeholders/dservo.scad>
use <../../scad/suspension/front_chassis/rear_frame/front_chassis_rear_frame.scad>
use <../../scad/suspension/steering_servo_bracket/helpers.scad>
use <../../scad/suspension/steering_servo_bracket/steering_servo_bracket_assembly.scad>

mode = "bracket";

module servo_position() {
  translate([0,
             -bellcrank_y_distance_from_bulkhead,
             suspension_chassis_mount_h]) {
    bellcrank_steering_with_servo_position() {
      children();
    }
  }
}

module bracket_position() {
  servo_position() {
    steering_servo_encoder_bracket_position() {
      children();
    }
  }
}

module bracket() {
  bracket_position() {
    steering_servo_encoder_bracket(show_encoder=false);
  }
}

module assembly_bracket() {
  servo_position() {
    difference() {
      steering_servo_bracket_assembly(show_servo_brackets=false,
                                      show_encoder=false,
                                      show_magnet=false);
      steering_servo_bracket_assembly(show_servo_brackets=false,
                                      show_encoder_bracket=false,
                                      show_magnet=false);
    }
  }
}

if (mode == "placement_difference") {
  union() {
    difference() {
      bracket(); assembly_bracket();
    }
    difference() {
      assembly_bracket(); bracket();
    }
  }
} else if (mode == "frame_collision") {
  intersection() {
    bracket();
    front_chassis_rear_frame();
  }
} else if (mode == "hole_obstruction") {
  intersection() {
    union() {
      bracket(); front_chassis_rear_frame();
    }
    bracket_position() {
      encoder_l_bracket_bottom_pan_bolt_children(bottom_pan_bolt_spacing=steering_encoder_bottom_pan_bolt_spacing,
                                                 bottom_pan_bolt_d=steering_encoder_bottom_pan_bolt_d,
                                                 bottom_pan_bolt_pad=steering_encoder_bottom_pan_bolt_pad) {
        translate([0, 0, -suspension_chassis_mount_h - 0.01]) {
          cylinder(d=steering_encoder_bottom_pan_bolt_d - 0.05,
                   h=chassis_thickness + steering_encoder_bottom_thickness + 1,
                   $fn=32);
        }
      }
    }
  }
} else if (mode == "magnet_collision") {
  intersection() {
    steering_servo_harness(show_servo_horn=false,
                           show_tie_rod=false,
                           show_encoder_bracket=false,
                           show_bolt=false);
    steering_servo_harness(show_servo_horn=false,
                           show_tie_rod=false,
                           show_magnet_sleeve=false,
                           show_bolt=false);
  }
} else if (mode == "frame") {
  front_chassis_rear_frame();
} else {
  bracket();
}
