/**
 * Module: Placeholder for Servo Horn. Not printable
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
include <../parameters.scad>

use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/transforms.scad>
use <../lib/trapezoids.scad>
use <bolt.scad>

module with_servo_horn_holes(center_ring_dia=servo_horn_center_ring_outer_dia,
                             screw_d=servo_horn_screw_d,
                             screw_holes_count=servo_horn_holes_n,
                             screws_gap=servo_horn_screws_distance) {
  rad = center_ring_dia / 2;
  step = screw_d + screws_gap;
  for (dir = [-1, 1]) {
    group_offst = (dir < 0
                   ? -rad
                   - screws_gap
                   : rad
                   + screws_gap);

    translate([0, group_offst, 0]) {
      for (i = [0 : screw_holes_count - 1]) {
        $i = i;
        x = i * step * dir;
        translate([0, x, 0]) {
          children();
        }
      }
    }
  }
}

module servo_horn_single(arm_len=(servo_horn_len / 2),
                         center_ring_dia=servo_horn_center_ring_outer_dia,
                         screw_d=servo_horn_screw_d,
                         screw_holes_count=servo_horn_holes_n,
                         arm_bottom_width=servo_horn_starting_arm_w,
                         arm_top_width=servo_horn_ending_arm_w,
                         screws_gap=servo_horn_screws_distance) {
  rad = center_ring_dia / 2;
  screw_rad = screw_d / 2;

  union() {
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
      with_servo_horn_holes(center_ring_dia=center_ring_dia,
                            screw_d=screw_d,
                            screw_holes_count=screw_holes_count,
                            screws_gap=screws_gap) {
        circle(r=screw_rad, $fn=10);
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
                  bolt_color=matte_black,
                  screw_side="vertical", // | "vertical" | "horizontal"
                  show_bolt=true,
                  show_screws=true,
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
    union() {
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
      if (show_bolt) {
        let (d = center_hole_dia,
             bolt_h = round(horn_height)) {
          translate([0, 0, -bolt_h + arm_z_offset + thickness]) {
            bolt(d=d, h=bolt_h, bolt_color=bolt_color);
          }
        }
      }

      if (show_screws) {

        let (d = screw_d,
             bolt_h = thickness + 1,

             z = arm_z_offset + thickness - bolt_h) {
          if (!screw_side || screw_side == "vertical") {
            with_servo_horn_holes(center_ring_dia=center_ring_dia,
                                  screw_d=screw_d,
                                  screw_holes_count=screw_holes_count,
                                  screws_gap=screws_gap) {
              if ($i % 2 != 0 || screw_holes_count == 1) {
                translate([0, 0, z]) {
                  bolt(d=d,
                       h=bolt_h,
                       screw_mode=true,
                       bolt_color=metallic_silver_1);
                }
              }
            }
          }

          if (!single && (!screw_side || screw_side == "horizontal")) {
            rotate([0, 0, single_rotation]) {
              with_servo_horn_holes(center_ring_dia=center_ring_dia,
                                    screw_d=screw_d,
                                    screw_holes_count=screw_holes_count,
                                    screws_gap=screws_gap) {
                if ($i % 2 != 0 || screw_holes_count == 1) {
                  translate([0, 0, z]) {
                    bolt(d=d,
                         h=bolt_h,
                         screw_mode=true,
                         bolt_color=metallic_silver_1);
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

servo_horn(center=false);
