/**
  * Module: Suspension Arm Pad
  *
  * Creates the pad and center hook that sit in the lower front recess of the
  * bulkhead. The hook captures the suspension-arm hinge pins and helps prevent
  * them from sliding out.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../lib/transforms.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/debug.scad>
use <../../lib/shapes2d.scad>
use <../../lib/trapezoids.scad>

module suspension_arm_pad(color=cobalt_blue_light_3,
                          pin_d=front_upper_arm_hinge_barrel_hole_d,
                          pad=front_suspension_arm_pad_pin_hole_pad_r,
                          thickness=front_suspension_arm_pad_thickness,
                          bulkhead_w=front_bulkhead_w,
                          barrel_pin_hole_offset=front_bulkhead_barrel_pin_hole_offset,
                          barrel_w=front_bulkhead_barrel_hinge_w,
                          h=front_suspension_arm_pad_len_y,
                          hook_lower_corner_r=front_suspension_arm_pad_hook_lower_corner_r,
                          hook_upper_corner_r=front_suspension_arm_pad_hook_upper_corner_r,
                          hook_h=front_suspension_arm_pad_hook_len_y,
                          hook_w=front_suspension_arm_pad_hook_w,
                          debug=false) {

  spacing = bulkhead_w + (barrel_w - barrel_pin_hole_offset - pin_d / 2) * 2;

  hs = spacing / 2;

  pin_pad_d = pad * 2 + pin_d;

  left_pts =
    [[0, 0],
     [-hs, 0],
     [-hs, pin_pad_d],
     [-hs + pad / 2, pin_pad_d],
     [-hs + pad * 3, h],
     [-hook_w / 2 - hook_lower_corner_r, h],
     [-hook_w / 2, h + hook_lower_corner_r],
     [-hook_w / 2, h + hook_h - hook_upper_corner_r],
     [0, h + hook_h - hook_upper_corner_r]];

  right_pts = [for (v = left_pts) [v[0] * -1, v[1]]];;

  pts = concat(left_pts, right_pts);

  module _shape() {
    difference() {
      union() {
        polygon(pts);

        mirror_copy([1, 0, 0]) {
          translate([-spacing / 2, pin_pad_d / 2, 0]) {
            circle(r=pin_pad_d / 2, $fn=$preview ? 15 : 300);
          }
        }
      }
      translate([0, pad, 0]) {
        mirror_copy([1, 0, 0]) {
          translate([spacing / 2, pin_d / 2, 0]) {
            circle(r=pin_d / 2, $fn=$preview ? 30 : 50);
          }
        }
      }
    }
  }

  maybe_color(color) {
    union() {
      linear_extrude(height=thickness, center=false) {
        _shape();
      }
      hull() {
        linear_extrude(height=thickness, center=false) {
          translate([0, h + hook_h - hook_upper_corner_r - 0.1, 0]) {
            square([hook_w, 0.1], center=true);
          }
        }
        linear_extrude(height=thickness * 0.6, center=false) {
          translate([0, h + hook_h - hook_upper_corner_r / 2 , 0]) {
            trapezoid(t=hook_w - hook_upper_corner_r * 2,
                      b=hook_w,
                      h=hook_upper_corner_r,
                      center=true);
          }
        }
      }
    }
  }

  if (debug) {
    translate([0, 0, thickness]) {
      debug_polygon_text(left_pts, font_size=1.6);
      debug_polygon_text(right_pts, font_size=1.6);
    }
  }
}

suspension_arm_pad(debug=false);
