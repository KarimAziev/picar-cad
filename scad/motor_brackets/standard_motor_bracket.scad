/**
 * Module: A dummy mockup of the cheap and popular yellow motor.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
include <../placeholders/motor.scad>

module motor_bracket_screws_2d(d=m2_hole_dia) {
  for (y = motor_bracket_screws) {
    translate([0, y, 0]) {
      circle(r = d / 2, $fn = 360);
    }
  }
}

module motor_bracket(size=[motor_mount_panel_width,
                           motor_bracket_panel_height,
                           motor_bracket_panel_height],
                     thickness=motor_mount_panel_thickness,
                     y_r=motor_mount_panel_width / 2,
                     z_r=motor_mount_panel_width / 2,
                     show_wheel_and_motor=false) {
  x = size[0];
  y = size[1];
  z = size[2];

  ur = (y_r == undef) ? 0 : y_r;
  lr = (z_r == undef) ? 0 : z_r;

  union() {
    linear_extrude(height=thickness, center=false) {
      difference() {
        rounded_rect_two([x, y], center=true, r=ur);
        motor_bracket_screws_2d(m2_hole_dia);
      }
    }
    translate([0, -y / 2, z / 2]) {
      rotate([90, 0, 0]) {
        linear_extrude(height=thickness, center=false) {
          difference() {
            rounded_rect_two([x, z], center=true, r=lr);
            motor_bracket_screws_2d(m3_hole_dia);
          }
        }
        if (show_wheel_and_motor) {
          translate([gearbox_body_main_len / 2 - motor_body_neck_len / 2, 0,
                     -gearbox_side_height / 2]) {
            rotate([180, 180, 0]) {
              motor(show_wheel=true);
            }
          }
        }
      }
    }
  }
}

rotate([0, 0, 90]) {
  translate([10, 14, 0]) {
    motor_bracket(show_wheel_and_motor=true);
  }
}
