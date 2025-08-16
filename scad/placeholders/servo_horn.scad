/**
 * Module: Placeholder for Servo Horn. Not printable
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
include <../colors.scad>
use <../util.scad>

module servo_horn_single() {
  servo_horn_arm_len = (servo_horn_len / 2);
  rad = servo_horn_outer_dia / 2;
  step = servo_horn_screw_d + servo_horn_screws_distance;
  amount = servo_horn_holes_n;
  screw_rad = servo_horn_screw_d / 2;
  difference() {
    hull() {
      circle(r=rad, $fn=100);
      mirror_copy([0, 1, 0]) {
        translate([0, servo_horn_w_2 / 2 + rad, 0]) {
          trapezoid_rounded_top(b=servo_horn_w_1,
                                t=servo_horn_w_2,
                                r_factor=0.4,
                                h=servo_horn_arm_len,
                                center=true);
        }
      }
    }
    for (dir = [-1, 1]) {
      group_offst = (dir < 0
                     ? -rad
                     - servo_horn_screws_distance
                     : rad
                     + servo_horn_screws_distance);

      translate([0, group_offst, 0]) {
        for (i = [0 : amount - 1]) {
          x = i * step * dir;
          translate([0, x, 0]) {
            circle(r=screw_rad, $fn=360);
          }
        }
      }
    }
  }
}

module servo_horn(single=false) {
  rad = servo_horn_outer_dia / 2;
  color(light_grey, alpha=1) {
    union() {
      translate([0, 0, servo_horn_arm_z_offset]) {
        linear_extrude(height=servo_horn_thickness, center=false) {
          difference() {
            union() {
              servo_horn_single();
              if (!single) {
                rotate([0, 0, 90]) {
                  servo_horn_single();
                }
              }
              circle(r=rad, $fn=100);
            }
            circle(r=servo_horn_hole_dia / 2, $fn=40);
          }
        }
      }
      linear_extrude(height=servo_horn_h, center=false) {
        ring_2d(r=rad,
                w=(servo_horn_outer_dia - servo_horn_inner_dia) / 2,
                fn=40,
                outer=false);
      }
    }
  }
}

servo_horn();
