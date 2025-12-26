/**
 * Module: Placeholder for XT90 connector
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../lib/holes.scad>
use <../lib/shapes3d.scad>
use <../lib/shapes2d.scad>
use <../lib/transforms.scad>

module xt90_contact_pin(pin_d,
                        contact_d,
                        contact_wall_h,
                        contact_base_h,
                        pin_thickness,
                        contact_thickness,
                        pin_color,
                        pin_h,
                        contact_h) {
  color(pin_color, alpha=1) {
    union() {
      translate([0, 0, 0]) {
        difference() {
          cylinder(d=pin_d, h=pin_h, $fn=8);
          translate([0, 0, -0.1]) {
            cube_3d([0.5, pin_d + 1, pin_h]);
            cube_3d([pin_d + 1, 0.5, pin_h]);
            counterbore(d=contact_d
                        - pin_thickness * 2,
                        no_bore=true,
                        h=contact_h);
          }
        }
        translate([0, 0, pin_h]) {
          cylinder(d=contact_d, h=0.1);
        }
      }
      translate([0, 0, pin_h]) {

        difference() {
          cylinder(d=contact_d,
                   h=contact_h,
                   $fn=40);
          translate([0, 0, contact_base_h]) {
            counterbore(d=contact_d - contact_thickness * 2,
                        no_bore=true,
                        h=contact_h);
          }
          translate([0, contact_d / 2, contact_h - contact_wall_h]) {

            cube_3d([contact_d, contact_d, contact_wall_h + 0.1]);
          }
        }
      }
    }
  }
}

module xt90_shell(size=[xt_90_size[0], xt_90_size[1], 15.1],
                  round_side="top",
                  r_factor=0.5,
                  thickness,
                  pin_length,
                  center=true) {
  w = size[0];
  length = size[1];
  h = size[2];
  translate([center ? 0 : w / 2,
             center ? 0 : length / 2,
             0]) {
    difference() {
      linear_extrude(height=h,
                     center=false,
                     convexity=2) {
        rounded_rect(size,
                     center=true,
                     side=round_side,
                     r_factor=r_factor);
      }
      if (!is_undef(pin_length) && !is_undef(thickness)) {
        rect_slot(size=[size[0] - thickness / 2, size[1] - thickness],
                  h=pin_length,
                  r_factor=r_factor,
                  side=round_side,
                  reverse=false,
                  center=true);
      }
    }
  }
}
