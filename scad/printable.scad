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
use <ir_case.scad>
use <front_panel.scad>
use <rear_panel.scad>
use <head/head_mount.scad>
use <head/head_neck.scad>
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
use <wheels/wheel_hub.scad>
use <util.scad>

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
show_wheel_hubs     = true;
show_tires          = true;
show_ir_case        = true;
show_ir_case_rail   = true;

module printable(spacing=5) {
  half_of_chassis_len = chassis_len / 2;
  half_of_chassis_width = chassis_width / 2;

  if (show_chasssis) {
    chassis();
  }
  translate([half_of_chassis_width
             + head_plate_width / 2
             + head_plate_thickness / 2
             + spacing,
             0,
             0]) {
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
          head_neck();
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
              translate([standard_motor_bracket_width + spacing, 0, 0]) {
                standard_motor_bracket();
              }
            }
          }
        }
      }
    }
  }

  translate([-ir_case_width / 2,
             half_of_chassis_len
             + ir_case_height,
             0]) {
    ir_case_printable(show_case=show_ir_case,
                      spacing=-2,
                      show_rail=show_ir_case_rail);
  }

  translate([-half_of_chassis_width
             - front_panel_width / 2 - spacing,
             half_of_chassis_len
             - front_panel_height * 0.5,
             0]) {
    if (show_front_panel) {
      color("white", alpha=1) {
        front_panel_printable();
      }
    }

    translate([0, -front_panel_height / 2
               - steering_panel_length / 2
               - knuckle_dia / 2 - spacing,
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
                 - max(pinion_offst / 2, bracket_offst / 2) - spacing, 0]) {
        if (show_pinion) {
          color(blue_grey_carbon, alpha=1) {
            steering_pinion();
          }
        }

        translate([-pinion_offst / 2
                   - (steering_bracket_rack_side_w_length
                      + steering_bracket_linkage_width
                      + steering_bracket_bearing_outer_d)
                   / 2 - spacing, 0, 0]) {
          steering_brackets_printable();
        }
      }
    }
  }

  translate([0, -half_of_chassis_len - max(rear_panel_size[1]
                                           + rear_panel_thickness
                                           * 2, wheel_dia) / 2 - 10, 0]) {
    front_wheels_x = -rear_panel_size[0] / 2 - rear_panel_thickness
      - wheel_dia / 2 - spacing;
    wheel_hub_x = show_front_wheels
      ? front_wheels_x - wheel_dia - spacing - wheel_dia
      : -rear_panel_size[0] / 2
      - rear_panel_thickness
      - wheel_hub_outer_d / 2
      - spacing;

    if (show_rear_panel) {
      color("white") {
        rear_panel();
      }
    }
    if (show_front_wheels) {
      color(blue_grey_carbon) {
        translate([front_wheels_x,
                   0,
                   0]) {
          front_wheel();
          translate([-wheel_dia - spacing, 0, 0]) {
            front_wheel();
          }
        }
      }
    }

    if (show_wheel_hubs) {
      color(blue_grey_carbon) {
        translate([wheel_hub_x - spacing,
                   0,
                   0]) {
          wheel_hub_upper();
          translate([show_front_wheels ? 0 : -wheel_hub_outer_d - spacing,
                     show_front_wheels ? -wheel_hub_outer_d - spacing : 0,
                     0]) {
            wheel_hub_upper();
          }
        }
      }
    }

    if (show_rear_wheels) {
      color(blue_grey_carbon) {
        translate([rear_panel_size[0] / 2 + rear_panel_thickness
                   + wheel_dia / 2 + spacing, 0, 0]) {
          rear_wheel();
          translate([wheel_dia + spacing, 0, 0]) {
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
                           * 2, wheel_dia) / 2 - outer_tire_r - spacing, 0]) {
          tire();
          translate([-outer_tire_r * 2 - spacing, 0, 0]) {
            tire();
          }
          translate([outer_tire_r * 2 + spacing, 0, 0]) {
            tire();
            translate([outer_tire_r * 2 + spacing, 0, 0]) {
              tire();
            }
          }
        }
      }
    }
  }
}

printable();