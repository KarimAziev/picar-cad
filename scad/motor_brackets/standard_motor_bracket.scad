/**
 * Module: A bracket for mounting standard yellow TT DC motors onto a robot chassis.
 * This module provides a simplistic and effective bracket for securing the widely-used
 * "yellow gear motors" (TT DC dual shaft or single shaft motors) to a flat chassis.
 * The bracket is L-shaped and includes separate bolt holes on both horizontal and vertical faces
 * to ensure reliable attachment to both the robot body and the motor itself.
 *
 * The bracket is built from two perpendicular panels with optional rounded corners, and can be
 * customized in size and mounting hole diameter. It also supports visualizing the motor and
 * optionally a wheel for positional context when modeling complete robot assemblies.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/shapes2d.scad>
use <../placeholders/motor.scad>

module standard_motor_bracket_bolts_holes_2d(d) {
  for (y=standard_motor_bracket_bolt_spacing) {
    translate([0, y, 0]) {
      circle(r = d / 2, $fn = 360);
    }
  }
}

module standard_motor_bracket(size=[standard_motor_bracket_width,
                                    standard_motor_bracket_height,
                                    standard_motor_bracket_height],
                              thickness=standard_motor_bracket_thickness,
                              chassis_bolt_d=standard_motor_bracket_chassis_bolt_hole,
                              motor_bolt_d=standard_motor_bracket_motor_bolt_hole,
                              y_r=standard_motor_bracket_width / 2,
                              z_r=standard_motor_bracket_width / 2,
                              show_motor=false,
                              show_wheel=false) {
  x = size[0];
  y = size[1];
  z = size[2];

  ur = (y_r == undef) ? 0 : y_r;
  lr = (z_r == undef) ? 0 : z_r;

  union() {
    color(matte_black, alpha=1) {
      linear_extrude(height=thickness, center=false) {
        difference() {
          rounded_rect_two([x, y], center=true, r=ur);
          standard_motor_bracket_bolts_holes_2d(chassis_bolt_d);
        }
      }
    }
    translate([0, -y / 2, z / 2]) {
      rotate([90, 0, 0]) {
        color(matte_black, alpha=1) {
          linear_extrude(height=thickness, center=false) {
            difference() {
              rounded_rect_two([x, z], center=true, r=lr);
              standard_motor_bracket_bolts_holes_2d(motor_bolt_d);
            }
          }
        }
        if (show_motor || show_wheel) {
          translate([standard_motor_gearbox_body_main_len / 2
                     - standard_motor_body_neck_len / 2,
                     0,
                     -standard_motor_gearbox_side_height / 2]) {
            rotate([180, 180, 0]) {
              motor(show_wheel=show_wheel);
            }
          }
        }
      }
    }
  }
}

standard_motor_bracket(show_motor=false);
//standard_motor_bracket_bolts_holes_2d(3);