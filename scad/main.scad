/**
 * Module: Robot Build Plate Arrangement
 *
 * This file arranges all robot parts on the printer’s build plate for fabrication.
 *
 * It assembles a robot chassis with a four-wheeled configuration:
 *    - The front wheels are steered via a servo mechanism.
 *    - The rear wheels are driven by two motors.
 *
 * In addition, the design prioritizes mounting options for multiple independent power modules - for example:
 *    - One for the servo HAT,
 *    - One for the motor driver HAT, and
 *    - One for a UPS module (e.g., UPS_Module_3S) that can power the Raspberry Pi 5.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <parameters.scad>
include <colors.scad>
use <chassis.scad>
use <front_panel.scad>
use <rear_panel.scad>
use <head/head_mount.scad>
use <head/head_neck_mount.scad>
use <motor_brackets/n20_motor_bracket.scad>
use <motor_brackets/standard_motor_bracket.scad>
use <steering_system/knuckle_shaft.scad>
use <steering_system/steering_pinion.scad>
use <steering_system/bracket.scad>
use <steering_system/steering_panel.scad>
use <steering_system/knuckle.scad>
use <steering_system/rack.scad>
use <wheels/tire.scad>
use <wheels/rear_wheel.scad>
use <wheels/front_wheel.scad>

show_chasssis       = true;
show_front_panel    = true;
show_head_neck      = true;
show_head           = true;
show_steering_panel = true;
show_rack           = true;
show_pinion         = true;
show_motor_brackets = true;
show_rear_panel     = true;
show_front_wheels   = true;
show_rear_wheels    = true;
show_tires          = true;

module printable() {
  if (show_chasssis) {
    chassis();
  }

  translate([(chassis_width / 2 + head_plate_width * 0.5) + 6, 0, 0]) {
    if (show_head) {
      color("white") {
        head_mount();
      }
    }
    translate([0, head_plate_height + knuckle_shaft_lower_horiz_len +
               knuckle_dia +
               knuckle_shaft_dia, 0]) {
      knuckle_print_plate();
      translate([0, knuckle_shaft_lower_horiz_len, 0]) {
        color(blue_grey_carbon, alpha=1) {
          knuckle_shaft_print_plate();
        }
      }
    }

    translate([0, -head_plate_height
               - head_neck_pan_servo_slot_height / 2, 0]) {
      if (show_head_neck) {
        color("white", alpha=1) {
          head_neck_mount();
        }
      }

      translate([0, -head_neck_pan_servo_slot_height, 0]) {
        if (show_motor_brackets && motor_type == "n20") {
          translate([0, -n20_motor_screws_panel_len, 0]) {
            color(blue_grey_carbon) {
              rotate([0, 90, 90]) {
                n20_standard_motor_bracket();
                translate([0, 0, -n20_motor_width() - 1]) {
                  n20_standard_motor_bracket();
                }
              }
            }
          }
        } else if (show_motor_brackets && motor_type == "standard") {
          color(blue_grey_carbon) {
            translate([0, -standard_motor_bracket_height, 0]) {
              standard_motor_bracket();
              translate([standard_motor_bracket_width + 5, 0, 0]) {
                standard_motor_bracket();
              }
            }
          }
        }
      }
    }
  }

  translate([-chassis_width / 2 - front_panel_width / 2 - 5,
             chassis_len * 0.5 - front_panel_height * 0.5,
             0]) {
    if (show_front_panel) {
      color("white", alpha=1) {
        front_panel_printable();
      }
    }

    translate([0, -front_panel_height / 2
               - steering_panel_length / 2
               - knuckle_dia / 2 - 5,
               0]) {
      rotate([0, 0, 90]) {
        if (show_steering_panel) {
          color("white", alpha=1) {
            steering_panel();
          }
        }

        translate([0, steering_center_panel_width / 2
                   + steering_rack_width / 2 +
                   steering_bracket_rack_side_h_length +
                   steering_bracket_linkage_width / 2, 0]) {
          color(blue_grey_carbon, alpha=1) {
            steering_rack();
          }
        }
      }

      bracket_offst = steering_bracket_rack_side_h_length
        + steering_bracket_bearing_outer_d + steering_bracket_linkage_width;
      pinion_offst = steering_pinion_d + steering_pinion_tooth_height() * 2;
      translate([0, -steering_panel_length / 2 - knuckle_dia / 2
                 - max(pinion_offst / 2, bracket_offst / 2) - 5, 0]) {
        if (show_pinion) {
          color(blue_grey_carbon, alpha=1) {
            steering_pinion();
          }
        }

        translate([-pinion_offst / 2
                   - (steering_bracket_rack_side_w_length
                      + steering_bracket_linkage_width
                      + steering_bracket_bearing_outer_d)
                   / 2 - 5, 0, 0]) {
          steering_brackets_printable();
        }
      }
    }
  }

  translate([0, -chassis_len / 2 - max(rear_panel_size[1]
                                       + rear_panel_thickness
                                       * 2, wheel_dia) / 2 - 10, 0]) {
    color("white") {
      if (show_rear_panel) {
        rear_panel();
      }
    }
    if (show_front_wheels) {
      color(blue_grey_carbon) {
        translate([-rear_panel_size[0] / 2 - rear_panel_thickness
                   - wheel_dia / 2 - 5, 0, 0]) {
          front_wheel();
          translate([-wheel_dia - 5, 0, 0]) {
            front_wheel();
          }
        }
      }
    }

    if (show_rear_wheels) {
      color(blue_grey_carbon) {
        translate([rear_panel_size[0] / 2 + rear_panel_thickness
                   + wheel_dia / 2 + 5, 0, 0]) {
          rear_wheel();
          translate([wheel_dia + 5, 0, 0]) {
            rear_wheel();
          }
        }
      }
    }

    if (show_tires) {
      inner_tire_r = wheel_dia / 2;
      outer_tire_r = inner_tire_r + wheel_tire_thickness
        + wheel_rim_h + wheel_tire_fillet_gap;
      color(matte_black) {
        translate([0, -max(rear_panel_size[1]
                           + rear_panel_thickness
                           * 2, wheel_dia) / 2 - outer_tire_r - 5, 0]) {
          tire();
          translate([-outer_tire_r * 2 - 5, 0, 0]) {
            tire();
          }
          translate([outer_tire_r * 2 + 5, 0, 0]) {
            tire();
            translate([outer_tire_r * 2 + 5, 0, 0]) {
              tire();
            }
          }
        }
      }
    }
  }
}

printable();