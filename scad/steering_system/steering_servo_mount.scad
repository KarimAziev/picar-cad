/**
 * Module: Steering Servo Mount
 *
 * This file defines a detachable vertical panel with a servo slot.
 *
 * This panel attaches to the steering panel with two bolts. By default, M3
 * bolts are used, but this can be changed via the
 * `steering_servo_mount_connector_bolt_dia` variable.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/l_bracket.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/steering_servo.scad>
use <rack_util.scad>
use <steering_pinion.scad>

function steering_servo_mount_pass_through_len() =
  steering_rack_support_width
  + steering_vertical_panel_thickness
  + steering_servo_mount_connector_length;

module steering_servo_mount_connector(clearance=0.0) {
  thickness = steering_servo_mount_connector_thickness + clearance;
  length = clearance + steering_servo_mount_connector_length;
  translate([-steering_servo_mount_width / 2,
             -steering_rack_support_width / 2,
             -thickness / 2]) {
    cube([steering_servo_mount_width,
          length,
          thickness]);
  }
}

module steering_servo_mount_with_bolt_mirror_x_positions() {
  r = steering_servo_mount_connector_bolt_dia / 2;

  mirror_copy([1, 0, 0]) {
    translate([steering_servo_mount_width / 2
               - r
               - steering_servo_mount_connector_bolt_x,
               0,
               0]) {
      children();
    }
  }
}

module steering_servo_mount_panel_bolt_holes() {
  h = steering_servo_mount_pass_through_len()
    + 1;

  steering_servo_mount_with_bolt_mirror_x_positions() {
    rotate([90, 0, 0]) {
      cylinder(h=h,
               d=steering_servo_mount_connector_bolt_dia,
               center=false,
               $fn=150);
    }
  }
}

module steering_servo_mount(show_servo=false,
                            show_pinion=false,
                            panel_color="white",
                            pinion_color=blue_grey_carbon) {
  slot_w = steering_servo_slot_width + 0.4;
  slot_h = steering_servo_slot_height + 0.2;
  bolts_offst_y = bolt_x_offst(slot_h,
                               steering_servo_bolt_dia,
                               steering_servo_bolts_offset);
  z_r = min(0.1 * steering_servo_mount_height, 3);

  union() {
    difference() {
      union() {

        translate([-steering_servo_mount_width / 2,
                   - steering_servo_mount_length
                   - steering_rack_support_width / 2
                   - steering_vertical_panel_thickness / 2,
                   - steering_rack_support_thickness / 2]) {
          l_bracket(size=[steering_servo_mount_width,
                          steering_servo_mount_length,
                          steering_servo_mount_height],
                    convexity=2,
                    bracket_color=panel_color,
                    vertical_thickness=steering_vertical_panel_thickness,
                    debug_vertical=true,
                    center=false,
                    thickness=steering_rack_support_thickness,
                    children_modes=[["difference", "vertical"],
                                    ["union", "vertical"]],
                    y_r=0,
                    z_r=z_r) {

            union() {
              translate([0,
                         steering_servo_mount_height / 2
                         - bolts_offst_y
                         - steering_servo_bolt_dia * 0.5
                         - steering_servo_bolt_distance_from_top,
                         0]) {
                square([slot_w, slot_h], center=true);
                for (y = [-bolts_offst_y, bolts_offst_y]) {
                  translate([0, y, 0]) {
                    circle(r=steering_servo_bolt_dia * 0.5, $fn=360);
                  }
                };
              }
            }
          }
        }
        color(panel_color, alpha=1) {
          steering_servo_mount_connector();
        }
      }
      steering_servo_mount_panel_bolt_holes();
    }

    if (show_servo) {
      servo_dia = steering_servo_bolt_dia + 0.3;
      servo_w = steering_servo_size[1];

      servo_y = -steering_servo_height_after_hat()
        - steering_servo_hat_thickness
        - steering_servo_mount_length
        - steering_vertical_panel_thickness / 2
        - steering_rack_support_width / 2;

      z_offset = steering_servo_mount_height -
        (steering_rack_support_thickness / 2)
        - steering_servo_bolts_offset
        - servo_dia
        - servo_dia / 2;
      translate([servo_w / 2, servo_y, z_offset]) {
        rotate([0, 90, 90]) {
          steering_servo(center=false) {
            if (show_pinion) {
              rotate([0, 0, $t == 0 ? 12.0 : 7 + pinion_angle(t=$t)]) {
                translate([0, 0, 2]) {
                  color(pinion_color, alpha=1) {
                    steering_pinion();
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

steering_servo_mount(show_servo=true);
