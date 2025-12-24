/**
 * Module: Placeholder for Servo Horn. Not printable
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
include <../colors.scad>

use <../lib/shapes2d.scad>
use <../lib/trapezoids.scad>
use <../lib/transforms.scad>

module servo_horn_single(arm_len=(servo_horn_len / 2),
                         center_ring_dia=servo_horn_center_ring_outer_dia,
                         screw_d=servo_horn_screw_d,
                         screw_holes_count=servo_horn_holes_n,
                         arm_bottom_width=servo_horn_starting_arm_w,
                         arm_top_width=servo_horn_ending_arm_w,
                         screws_gap=servo_horn_screws_distance) {
  rad = center_ring_dia / 2;
  step = screw_d + screws_gap;

  screw_rad = screw_d / 2;
  difference() {
    hull() {
      circle(r=rad, $fn=60);
      mirror_copy([0, 1, 0]) {
        translate([0, arm_top_width / 2 + rad, 0]) {
          trapezoid_rounded_top(b=arm_bottom_width,
                                t=arm_top_width,
                                r_factor=0.4,
                                h=arm_len,
                                center=true);
        }
      }
    }
    for (dir = [-1, 1]) {
      group_offst = (dir < 0
                     ? -rad
                     - screws_gap
                     : rad
                     + screws_gap);

      translate([0, group_offst, 0]) {
        for (i = [0 : screw_holes_count - 1]) {
          x = i * step * dir;
          translate([0, x, 0]) {
            circle(r=screw_rad, $fn=60);
          }
        }
      }
    }
  }
}

module servo_horn(single=false,
                  center_ring_dia=servo_horn_center_ring_outer_dia,
                  center_ring_inner_dia=servo_horn_center_ring_inner_dia,
                  center_hole_dia=servo_horn_center_hole_dia,
                  thickness=servo_horn_arm_thickness,
                  arm_z_offset=servo_horn_arm_z_offset,
                  horn_height=servo_horn_ring_height,
                  arm_len=(servo_horn_len / 2),
                  screw_d=servo_horn_screw_d,
                  screw_holes_count=servo_horn_holes_n,
                  arm_bottom_width=servo_horn_starting_arm_w,
                  arm_top_width=servo_horn_ending_arm_w,
                  screws_gap=servo_horn_screws_distance,
                  single_rotation=90,
                  center=true) {
  rad = center_ring_dia / 2;

  module servo_horn_trapezoid() {
    servo_horn_single(arm_len=arm_len,
                      center_ring_dia=center_ring_dia,
                      screw_d=screw_d,
                      screw_holes_count=screw_holes_count,
                      arm_bottom_width=arm_bottom_width,
                      arm_top_width=arm_top_width,
                      screws_gap=screws_gap);
  }
  translate([center ? 0 : arm_len, center ? 0 : arm_len, 0]) {
    color(light_grey, alpha=1) {
      union() {
        translate([0, 0, arm_z_offset]) {
          linear_extrude(height=thickness, center=false) {
            difference() {
              union() {
                servo_horn_trapezoid();
                if (!single) {
                  rotate([0, 0, single_rotation]) {
                    servo_horn_trapezoid();
                  }
                }
                circle(r=rad, $fn=60);
              }
              circle(r=center_hole_dia / 2, $fn=40);
            }
          }
        }
        linear_extrude(height=horn_height, center=false) {
          ring_2d(r=rad,
                  w=(center_ring_dia - center_ring_inner_dia) / 2,
                  fn=40,
                  outer=false);
        }
      }
    }
  }
}

servo_horn(center=false);
